#include <emscripten.h>
#include <emscripten/html5.h>

#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/dump.h>

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define MRB_FILE_PATH ( "main.mrb")

extern EM_BOOL on_mouse_click(int eventType, const EmscriptenMouseEvent *mouseEvent, void *userData);
extern EM_BOOL on_touch(int eventType, const EmscriptenTouchEvent *touchEvent, void *userData);

static void onload(unsigned int handle, void* _context, void* data, unsigned int size)
{
  uint8_t* bin = (uint8_t*)malloc(size);
  memcpy(bin,data,size);

  mrb_state *mrb = mrb_open();

  mrb_value obj = mrb_load_irep(mrb, bin );
  if (mrb->exc) {
    if (mrb_undef_p(obj)) {
      mrb_p(mrb, mrb_obj_value(mrb->exc));
    } else {
      mrb_print_error(mrb);
    }
  }
}

static void onerror(unsigned int handle, void *_context, int http_status_code, const char* desc)
{
  printf("%d onerror %d : %s\n",handle,http_status_code,desc);
}

static void onprogress(unsigned int handle, void *_context, int loaded, int total)
{
  printf("%d onprogress %d/%d\n", handle, loaded, total);
}

int main(int argc, char* argv[])
{
  // emscripten_set_mousedown_callback(0, NULL, EM_FALSE, on_mouse_click);
  // emscripten_set_touchstart_callback(0, NULL, EM_FALSE, on_touch);

  emscripten_async_wget2_data(MRB_FILE_PATH,"GET","",NULL,TRUE,onload,onerror,onprogress);

  return 0;
}
