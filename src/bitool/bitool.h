#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/dump.h>
#include <mruby/array.h>
#include <mruby/class.h>
#include <mruby/string.h>
#include <mruby/proc.h>
#include <mruby/compile.h>
#include <mruby/variable.h>

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#include "bitool_rb.h"

//
// innner functions
//

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

static char* _construct_error_text(struct mrb_parser_state *p)
{
  const size_t ERROR_TEXT_BUFFER_SIZE = 1024;
  char* error_text = NULL;
  if( p->nerr > 0 ) {
    error_text = (char*)malloc(ERROR_TEXT_BUFFER_SIZE);
    memset(error_text,0,ERROR_TEXT_BUFFER_SIZE);
    char buf[256];
    for(uint32_t i=0; i<p->nerr; i++) {
      strcpy(buf, "line ");
      snprintf(buf, 256, "line %d:%d: %s\n",
        p->error_buffer[i].lineno,
        p->error_buffer[i].column,
        p->error_buffer[i].message
      );
      strncat(error_text,buf, ERROR_TEXT_BUFFER_SIZE - strlen(error_text) - 1 );
    }
  }
  return error_text;
}

static mrb_value _load(mrb_state *mrb, struct mrb_parser_state **p, const char* filename, const char* source, bool exec)
{
  mrbc_context *c = mrbc_context_new(mrb);
  c->dump_result = FALSE;
  c->no_exec = ! exec;
  c->capture_errors = TRUE;

  mrbc_filename(mrb, c, filename);
  // mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), mrb_str_new_cstr(mrb, filename));

  mrb_value obj;
  *p = mrb_parse_nstring(mrb, source, strlen(source), c);
  obj = mrb_load_exec(mrb, *p, c);
  mrbc_context_free(mrb, c);

  return obj;
}

static char* _run(const char* filename, const char* source, int argc, const char* argv[])
{
  mrb_state *mrb = mrb_open();
  _define_argv(mrb,argc,argv);
  struct mrb_parser_state *p;
  _load(mrb,&p,filename,source,true);
  return _construct_error_text(p);
}

static char* _check_syntax(const char* filename, const char* source)
{
  mrb_state *mrb = mrb_open();
  struct mrb_parser_state *p;
  _load(mrb,&p,filename,source,false);
  return _construct_error_text(p);
}

static char* _compile(const char* filename, const char* source, const char* outfile)
{
  const size_t ERROR_TEXT_BUFFER_SIZE = 1024;
  mrb_state *mrb = mrb_open();
  char* error_text;

  struct mrb_parser_state *p;
  mrb_value obj = _load(mrb,&p,filename,source,false);

  error_text = _construct_error_text(p);
  if(error_text){
    return error_text;
  }

  FILE *fp = stdout;
  if( strcmp("-", outfile ) != 0 ) {
    fp = fopen(outfile, "wb");
  }
  if( fp == NULL) {
    error_text = (char*)malloc(ERROR_TEXT_BUFFER_SIZE);
    snprintf(error_text,ERROR_TEXT_BUFFER_SIZE,"cannot open output file:(%s)\n", outfile);
    return error_text;
  }

  unsigned int flags = DUMP_ENDIAN_LIL | DUMP_DEBUG_INFO; // DUMP_DEBUG_INFO , DUMP_ENDIAN_BIG, DUMP_ENDIAN_LIL...
  int dump_result = MRB_DUMP_OK;
  struct RProc *proc = mrb_proc_ptr(obj);
  mrb_irep *irep = proc->body.irep;
  mrb_irep_remove_lv(mrb, irep);
  dump_result = mrb_dump_irep_binary(mrb, irep, flags, fp);

  if( dump_result != MRB_DUMP_OK ){
    error_text = (char*)malloc(ERROR_TEXT_BUFFER_SIZE);
    snprintf(error_text,ERROR_TEXT_BUFFER_SIZE,"mrb_dump_irep_binary failed:(%s)\n", outfile);
    return error_text;
  }

  return NULL;
}

//
// mruby functions
//
static mrb_value bi_check_syntax(mrb_state* mrb, mrb_value self)
{
  mrb_value _filename,_source;
  mrb_get_args(mrb, "SS", &_filename, &_source );

  char* syntax_error = _check_syntax( mrb_string_cstr(mrb,_filename), mrb_string_cstr(mrb,_source) );
  if(syntax_error!=NULL) {
    mrb_value result = mrb_str_new(mrb,syntax_error,strlen(syntax_error));
    free(syntax_error);
    return result;
  }
  return mrb_nil_value();
}

static mrb_value bi_compile(mrb_state* mrb, mrb_value self)
{
  mrb_value _filename, _source, _outfile;
  mrb_get_args(mrb, "SSS", &_filename, &_source, &_outfile );

  const char* filename = mrb_string_cstr(mrb,_filename);
  const char* source = mrb_string_cstr(mrb,_source);
  const char* outfile = mrb_string_cstr(mrb,_outfile);

  char* error_text = _compile(filename,source,outfile);
  if(error_text!=NULL) {
    mrb_value result = mrb_str_new(mrb,error_text,strlen(error_text));
    free(error_text);
    return result;
  }

  return mrb_nil_value();
}

static mrb_value bi_run(mrb_state* mrb, mrb_value self)
{
  mrb_value _source, _filename, _argv;
  mrb_get_args(mrb, "SSA", &_filename, &_source, &_argv );

  const char* filename = mrb_string_cstr(mrb,_filename);
  const char* source = mrb_string_cstr(mrb,_source);

  int argc = RARRAY_LEN(_argv);
  const char* argv[argc];
  for(int i=0; i<argc; i++) {
    argv[i] = mrb_string_cstr(mrb, mrb_ary_entry(_argv,i) );
  }

  char* error_text = _run(filename, source, argc, argv);
  if(error_text!=NULL) {
    mrb_value result = mrb_str_new(mrb,error_text,strlen(error_text));
    free(error_text);
    return result;
  }

  return mrb_nil_value();
}

static void create_mruby_inner_methods(mrb_state* mrb)
{
  struct RClass *bi;
  bi = mrb_define_class(mrb, "Bi", mrb->object_class);

  mrb_define_class_method(mrb, bi, "check_syntax", bi_check_syntax, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, bi, "compile", bi_compile, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, bi, "run", bi_run, MRB_ARGS_REQ(3));
}
