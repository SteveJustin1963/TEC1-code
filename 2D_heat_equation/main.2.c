#include <stdio.h>
#include <math.h>

#define PI 3.141592653589793
#define MODES 100  // Number of terms in the series (m and n)

// Initial Condition: f(x, y) = 100 degrees everywhere
// The Fourier coefficient B_mn for a constant initial temp U0 is:
// B_mn = (16 * U0) / (m * n * PI^2) for odd m, n; else 0.
double get_Bmn(int m, int n, double u0) {
    if (m % 2 == 0 || n % 2 == 0) return 0.0;
    return (16.0 * u0) / (m * n * PI * PI);
}

double solve_2d_heat(double x, double y, double t, double L, double W, double alpha, double u0) {
    double u = 0.0;

    for (int m = 1; m <= MODES; m++) {
        for (int n = 1; n <= MODES; n++) {
            double b_mn = get_Bmn(m, n, u0);
            if (b_mn == 0.0) continue;

            // Eigenvalue calculation
            double lambda_mn = PI * PI * ( (m*m)/(L*L) + (n*n)/(W*W) );
            
            // Spatial components
            double spatial = sin((m * PI * x) / L) * sin((n * PI * y) / W);
            
            // Time decay component
            double decay = exp(-alpha * lambda_mn * t);

            u += b_mn * spatial * decay;
        }
    }
    return u;
}

int main() {
    double L = 1.0, W = 1.0;     // Plate dimensions
    double alpha = 0.01;         // Thermal diffusivity
    double initial_temp = 100.0; // Initial plate temp
    double time = 5.0;           // Time elapsed

    printf("Temperature distribution at t = %.1f:\n", time);
    printf("X\tY\tTemp\n");
    
    // Sample a few points on the plate
    for (double x = 0.2; x <= 0.8; x += 0.3) {
        for (double y = 0.2; y <= 0.8; y += 0.3) {
            double temp = solve_2d_heat(x, y, time, L, W, alpha, initial_temp);
            printf("%.2f\t%.2f\t%.4f\n", x, y, temp);
        }
    }

    return 0;
}
