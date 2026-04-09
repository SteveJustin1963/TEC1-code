
**This program solves the 2D heat equation** on a rectangular plate using a **double Fourier sine series**.

### What it actually computes:
It calculates the **temperature distribution** inside a rectangular metal plate (or similar material) at a specific time `t`, given:
- Initial temperature distribution (here a constant `initial_temp`)
- Plate dimensions `L` (length in x) and `W` (width in y)
- Thermal diffusivity `alpha`
- Time `t`

### Key details from the code:

- **Domain**: Rectangle from (0,0) to (L, W)
- **Boundary conditions**: All four edges are held at **0°C** (Dirichlet boundaries)
- **Initial condition**: The plate starts at a uniform temperature (`initial_temp`)
- **Solution method**: Analytical solution using separation of variables → double infinite series, truncated to **MODES = 10** (10 terms in both m and n directions)

For each point (x, y), it computes:
$$
u(x,y,t) = \sum_{m=1}^{10} \sum_{n=1}^{10} B_{mn} \sin\left(\frac{m\pi x}{L}\right) \sin\left(\frac{n\pi y}{W}\right) e^{-\alpha \lambda_{mn} t}
$$
where $B_{mn}$ are the Fourier coefficients and $\lambda_{mn}$ comes from the eigenvalues.

### What the program outputs:

It prints a small table for **9 points** on the plate (x and y = 0.2, 0.5, 0.8) at time `t = 10.0` seconds:

```
Temperature distribution at t = 10.0:
X	Y	Temp
0.20	0.20	xxxx.xxxx
0.20	0.50	xxxx.xxxx
...
0.80	0.80	xxxx.xxxx
```

### Hardware it targets:
- **Z80 CPU** at 4 MHz
- **AMD 9511** (or Intel 8231) floating-point coprocessor at 2 MHz for fast sin(), exp(), mul, div etc.

This is a classic example of using an 8-bit CPU + math coprocessor to do non-trivial scientific/engineering computation in the early 1980s style.

### Summary:
It's a **numerical demonstration** of how heat spreads (and cools down) in a square/rectangular plate with cool edges, using a high-precision analytical method accelerated by the 9511 APU.

Would you like me to explain any specific part (the math, how the APU is used, the performance, or what the output numbers mean)?



//

**Rough estimate: 0.8 to 2.5 seconds on a 4 MHz Z80 + 2 MHz 9511 APU (most likely around 1.2–1.8 seconds).**

### Why this range?
The program does a **double Fourier series** (MODES=10) for the 2D heat equation at **9 grid points** (x,y = 0.2/0.5/0.8).

Key workload in `solve_2d_heat()` per grid point:
- 2 × 10 sin() precomputes (m*x and n*y)
- 10 × 10 = **100 inner loop iterations**
  - `get_Bmn()` → 1 divide + some mul
  - lambda_mn calculation → several muls/divs
  - `sin_mx[m] * sin_ny[n]` → 1 mul
  - `exp(-alpha * lambda * t)` → 1 exp + muls
  - 2–3 more muls + 1 add to accumulate

**Total heavy APU ops per grid point ≈ 800–1200** (mostly MUL/DIV/EXP/SIN + overhead).

× 9 points → **~8000–11,000 APU floating-point commands**.

### APU Timings (9511 at 2 MHz)
Each APU command (push 4 bytes + command byte + wait + pop 4 bytes) costs:

| Operation     | Typical cycles (9511) | Time @ 2 MHz |
|---------------|-----------------------|--------------|
| MUL / DIV     | 140–210               | 70–105 µs   |
| ADD / SUB     | 70–120                | 35–60 µs    |
| SIN / COS     | ~900–1400             | 450–700 µs  |
| EXP           | ~800–1300             | 400–650 µs  |

Plus **Z80 overhead** per command (~80–150 Z80 cycles for the push/cmd/wait/pop dance in the provided routines).

At 4 MHz Z80 (250 ns/cycle), Z80 overhead is small compared to the APU waits.

### Rough Breakdown
- **~1000–1500 SIN/EXP** total (the expensive ones) → dominant cost
- **~6000–8000 MUL/DIV/ADD**

**Conservative total APU busy time**: 0.7–1.6 seconds  
**Z80 overhead + loop control + printf**: 0.1–0.4 seconds extra

### Real-World Context
On real 4 MHz Z80 + 2 MHz 9511 systems (RC2014, YAZ180, etc.), similar double-loop Fourier or series calculations with 10×10 modes typically take **1–2 seconds**. Your code is well-written for the APU (heavy use of `apu_mulf`/`apu_expf` etc.), so it should be on the faster side of that.

### How to Measure Exactly
If you can run it on real hardware or a good emulator (e.g. with cycle-accurate 9511 model), the `apu_wait()` loop will tell you. You could also add a simple timer using a CTC or just count main loop iterations.

**Bottom line**: Expect it to finish in **well under 3 seconds**, probably **around 1.5 seconds** — very usable for an 8-bit system in 1981! The 9511 is doing the heavy lifting beautifully here.


