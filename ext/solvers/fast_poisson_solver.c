#include "ruby.h"

static VALUE solve(VALUE self) {
  return rb_str_new2("Nils <3!");
}

void Init_fast_poisson_solver() {
  VALUE FastPoissonSolver = rb_define_module("FastPoissonSolver");
  rb_define_singleton_method(FastPoissonSolver, "solve", solve, 0);
}
