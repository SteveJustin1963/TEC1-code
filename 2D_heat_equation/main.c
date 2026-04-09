/*
 * 2D Heat Equation Solver — Z80 + AM9511 APU version
 *
 * The AM9511 is a hardware math coprocessor. All transcendental functions
 * (sin, exp) and float arithmetic are offloaded to it via I/O ports,
 * freeing the Z80 from slow software float emulation.
 *
 * AM9511 I/O map (made up labels, adjust to your hardware):
 *   0x40 — DATA port  (read/write operand bytes)
 *   0x41 — CMD/STATUS port (write = send command, read = poll status)
 *
 * AM9511 float format is almost identical to IEEE 754 single-precision,
 * except the exponent bias is 128 instead of 127.  A small conversion
 * is applied before pushing / after popping each float.
 *
 * Push byte order: MSB first  (byte3, byte2, byte1, byte0)
 * Pop  byte order: MSB first  (byte3, byte2, byte1, byte0)
 */

#include <stdio.h>
#include <stdint.h>

/* ---------------------------------------------------------------
 * Port declarations  (SDCC __sfr generates Z80 IN/OUT instructions)
 * --------------------------------------------------------------- */
#define APU_DATA_PORT   0x40
#define APU_CMD_PORT    0x41

__sfr __at(APU_DATA_PORT) apu_data;
__sfr __at(APU_CMD_PORT)  apu_cmd;   /* write = command, read = status */

/* ---------------------------------------------------------------
 * AM9511 status bits
 * --------------------------------------------------------------- */
#define APU_BUSY    0x80    /* set while APU is executing */
#define APU_ERR     0x08    /* error flag */

/* ---------------------------------------------------------------
 * AM9511 single-precision command codes  (per AM9511 datasheet)
 * --------------------------------------------------------------- */
#define APU_SADD    0x01    /* pop two, push (a + b) */
#define APU_SSUB    0x02    /* pop two, push (a - b) */
#define APU_SMUL    0x03    /* pop two, push (a * b) */
#define APU_SDIV    0x04    /* pop two, push (a / b) */
#define APU_SIN     0x11    /* pop one, push sin(x)  — x in radians */
#define APU_COS     0x12    /* pop one, push cos(x) */
#define APU_EXP     0x19    /* pop one, push e^x */

/* ---------------------------------------------------------------
 * Simulation constants
 * --------------------------------------------------------------- */
#define MODES   10          /* Fourier terms each axis — 10 is plenty */
#define PI      3.14159265f

/* ---------------------------------------------------------------
 * Float format helpers
 *
 * IEEE 754 bias = 127; AM9511 bias = 128.
 * For normal (non-zero, non-inf) values: increment exponent by 1
 * before pushing, decrement by 1 after popping.
 * We use a union to avoid undefined-behaviour type-punning.
 * --------------------------------------------------------------- */
typedef union { float f; uint32_t u; uint8_t b[4]; } fu32;

static uint32_t ieee_to_apu(float f) {
    fu32 x;
    uint8_t exp;
    x.f = f;
    exp = (x.u >> 23) & 0xFF;
    if (exp != 0 && exp != 0xFF)
        x.u += (1UL << 23);    /* +1 to exponent field */
    return x.u;
}

static float apu_to_ieee(uint32_t raw) {
    fu32 x;
    uint8_t exp;
    x.u = raw;
    exp = (x.u >> 23) & 0xFF;
    if (exp != 0 && exp != 0xFF)
        x.u -= (1UL << 23);    /* -1 from exponent field */
    return x.f;
}

/* ---------------------------------------------------------------
 * Low-level APU primitives
 * --------------------------------------------------------------- */
static void apu_wait(void) {
    while (apu_cmd & APU_BUSY)
        ;
}

static void apu_push(float f) {
    uint32_t raw = ieee_to_apu(f);
    apu_data = (uint8_t)(raw >> 24);
    apu_data = (uint8_t)(raw >> 16);
    apu_data = (uint8_t)(raw >>  8);
    apu_data = (uint8_t)(raw      );
}

static float apu_pop(void) {
    uint32_t raw;
    raw  = (uint32_t)apu_data << 24;
    raw |= (uint32_t)apu_data << 16;
    raw |= (uint32_t)apu_data <<  8;
    raw |= (uint32_t)apu_data;
    return apu_to_ieee(raw);
}

static void apu_exec(uint8_t cmd) {
    apu_cmd = cmd;
    apu_wait();
}

/* ---------------------------------------------------------------
 * High-level APU math wrappers
 * --------------------------------------------------------------- */
static float apu_sinf(float x)           { apu_push(x); apu_exec(APU_SIN); return apu_pop(); }
static float apu_expf(float x)           { apu_push(x); apu_exec(APU_EXP); return apu_pop(); }
static float apu_mulf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SMUL); return apu_pop(); }
static float apu_divf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SDIV); return apu_pop(); }
static float apu_addf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SADD); return apu_pop(); }

/* ---------------------------------------------------------------
 * Heat solver
 * --------------------------------------------------------------- */
static float get_Bmn(int m, int n, float u0) {
    if (m % 2 == 0 || n % 2 == 0) return 0.0f;
    /* (16 * u0) / (m * n * PI^2) */
    return apu_divf(16.0f * u0, (float)(m * n) * PI * PI);
}

static float solve_2d_heat(float x, float y, float t,
                            float L, float W, float alpha, float u0) {
    float u = 0.0f;
    float sin_mx[MODES + 1];
    float sin_ny[MODES + 1];
    int m, n;

    /*
     * Precompute sin arrays — sin(m*PI*x/L) depends only on m and x,
     * not on n.  Computing it inside the inner loop would waste 10x the
     * APU calls. Same for the y-direction.
     */
    for (m = 1; m <= MODES; m++)
        sin_mx[m] = apu_sinf(apu_divf((float)m * PI * x, L));
    for (n = 1; n <= MODES; n++)
        sin_ny[n] = apu_sinf(apu_divf((float)n * PI * y, W));

    for (m = 1; m <= MODES; m++) {
        for (n = 1; n <= MODES; n++) {
            float b_mn, lambda_mn, spatial, decay, term;

            b_mn = get_Bmn(m, n, u0);
            if (b_mn == 0.0f) continue;     /* odd/even shortcut */

            /* lambda_mn = PI^2 * (m^2/L^2 + n^2/W^2) */
            lambda_mn = PI * PI * (
                (float)(m * m) / (L * L) +
                (float)(n * n) / (W * W)
            );

            /* spatial  = sin_mx[m] * sin_ny[n]  (lookup, no APU call) */
            spatial = apu_mulf(sin_mx[m], sin_ny[n]);

            /* decay = exp(-alpha * lambda_mn * t) */
            decay = apu_expf(-alpha * lambda_mn * t);

            /* accumulate: u += b_mn * spatial * decay */
            term = apu_mulf(apu_mulf(b_mn, spatial), decay);
            u    = apu_addf(u, term);
        }
    }
    return u;
}

/* ---------------------------------------------------------------
 * Main
 * --------------------------------------------------------------- */
int main(void) {
    float L = 1.0f, W = 1.0f;
    float alpha = 0.01f;
    float initial_temp = 100.0f;
    float t = 5.0f;
    float x, y, temp;

    printf("Temperature distribution at t = %.1f:\n", t);
    printf("X\tY\tTemp\n");

    for (x = 0.2f; x <= 0.8f; x += 0.3f) {
        for (y = 0.2f; y <= 0.8f; y += 0.3f) {
            temp = solve_2d_heat(x, y, t, L, W, alpha, initial_temp);
            printf("%.2f\t%.2f\t%.4f\n", x, y, temp);
        }
    }

    return 0;
}
