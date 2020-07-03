#include <bi/bi_sdl.h>

#include <mruby.h>
#include <mruby/array.h>
#include <mruby/irep.h>
#include <mruby/dump.h>

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define MRB_FILE_PATH ( "main.mrb")

static void _define_argv(mrb_state *mrb, int argc, const char* argv[])
{
  mrb_value ARGV;
  if(argc>1){
    ARGV = mrb_ary_new_capa(mrb, argc-1);
    for (int i = 1; i < argc; i++) {
      char* utf8 = mrb_utf8_from_locale(argv[i], -1);
      if (utf8) {
        mrb_ary_push(mrb, ARGV, mrb_str_new_cstr(mrb, utf8));
        mrb_utf8_free(utf8);
      }
    }
  }else{
    ARGV = mrb_ary_new_capa(mrb, 0);
  }
  mrb_define_global_const(mrb, "ARGV", ARGV);
}

int main(int argc, char* argv[])
{
  mrb_state *mrb = mrb_open();
  _define_argv( mrb, argc, (const char**)argv );
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
