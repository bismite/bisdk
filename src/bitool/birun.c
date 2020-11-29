#include <bi/bi_sdl.h>
#include "bitool.h"

int main(int argc, char* argv[])
{
  mrb_state *mrb = mrb_open();
  _define_argv( mrb, argc, (const char**)argv );
  create_mruby_inner_methods(mrb);
  mrb_value obj = mrb_load_irep(mrb,bitool_rb);

  mrb_funcall(mrb, obj, "run", 0);

  if (mrb->exc) {
    if (mrb_undef_p(obj)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
    return 1;
  }

  return 0;
}
