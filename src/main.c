#include <bi/bi_sdl.h>

#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/dump.h>

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define MRB_FILE_PATH ( "main.mrb")

int main(int argc, char* argv[])
{
  mrb_state *mrb = mrb_open();

  FILE *file = fopen(MRB_FILE_PATH,"rb");
  mrb_value obj = mrb_load_irep_file(mrb,file);

  if (mrb->exc) {
    printf("exception:\n");
    if (mrb_undef_p(obj)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
  }

  return 0;
}
