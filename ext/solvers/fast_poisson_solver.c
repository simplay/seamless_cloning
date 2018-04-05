#include "ruby.h"

static double* rb_ary_c_ary(VALUE ary, int len) {
  double* c_ary = malloc(sizeof(double) * len);

  int i;
  for (i = 0; i < len; i++) {
    VALUE v = rb_ary_entry(ary, i);
    c_ary[i] = NUM2DBL(v);
  }
  return c_ary;
}

static double get_val(double* ary, int width, int x, int y) {
  return ary[y * width + x];
}

// copy values in double array from src to dst
static void double_copy(double* dst, double* src, int len) {
  memcpy(dst, src, (sizeof(double) * len));
}

static double MAX_ERROR = 1E-4;

static VALUE solve(VALUE self,
                   VALUE width,
                   VALUE height,
                   VALUE iters,
                   VALUE target,
                   VALUE mask,
                   VALUE vx,
                   VALUE vy) {

  int len = RARRAY_LEN(target);
  int c_width = NUM2INT(width);
  int c_height = NUM2INT(height);
  int max_iter = NUM2INT(iters);

  VALUE result = rb_ary_new2(len);

  double* c_target = rb_ary_c_ary(target, len);
  double* c_prev = rb_ary_c_ary(target, len);

  double* c_mask = rb_ary_c_ary(mask, len);
  double* c_vx = rb_ary_c_ary(vx, len);
  double* c_vy = rb_ary_c_ary(vy, len);

  int i, w, h, k;

  double left, right, top, bottom;
  double dvx2, dvx1, dvy2, dvy1, dv, v_tmp;
  double img_neighbors;
  double error, e_tmp;

  int m;
  for (m = 0; m < max_iter; m++) {
    double_copy(c_prev, c_target, len);

    for (w = 0; w < c_width; w++) {
      for (h = 0; h < c_height; h++) {

        if (get_val(c_mask, c_width, w, h) > 0.0d) {
          continue;
        }

        left   = get_val(c_prev, c_width, w - 1, h);
        right  = get_val(c_prev, c_width, w + 1, h);
        top    = get_val(c_prev, c_width, w,     h + 1);
        bottom = get_val(c_prev, c_width, w,     h - 1);

        img_neighbors = left + right + top + bottom;

        dvx2 = get_val(c_vx, c_width, w    , h - 1);
        dvx1 = get_val(c_vx, c_width, w    , h);

        dvy2 = get_val(c_vy, c_width, w - 1, h);
        dvy1 = get_val(c_vy, c_width, w    , h);

        dv = dvx2 - dvx1 + dvy2 - dvy1;

        v_tmp = (img_neighbors + dv) / 4.0;
        c_target[h * c_width + w] = v_tmp;
      }
    }

    if (m % 200 == 0) {
      error = 0.0;
      for (k = 0; k < len; k++) {
        e_tmp = c_target[k] - c_prev[k];
        e_tmp *= e_tmp;
        e_tmp = sqrt(e_tmp);
        error += e_tmp;
      }

      printf("Iteration %i: Error: %f \n", m, error);

      // Finish computation when max error boundery has been reached.
      if (error <= MAX_ERROR) {
        printf("Returning solver result: Error smaller than %f\n", MAX_ERROR);
        break;
      }
    }
  }

  // write back to ruby array object
  for (i = 0; i < len; i++) {
    rb_ary_store(result, i, DBL2NUM(c_target[i]));
  }

  return result;
}

void Init_fast_poisson_solver() {
  VALUE FastPoissonSolver = rb_define_module("FastPoissonSolver");
  rb_define_singleton_method(FastPoissonSolver, "solve", solve, 7);
}
