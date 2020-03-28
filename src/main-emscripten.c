#include <emscripten.h>
#include <emscripten/html5.h>
#include <emscripten/fetch.h>

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


void downloadSucceeded(emscripten_fetch_t *fetch) {
    printf("Finished downloading %llu bytes from URL %s.\n", fetch->numBytes, fetch->url);

    uint8_t* bin = (uint8_t*)malloc(fetch->numBytes);
    memcpy(bin,fetch->data,fetch->numBytes);
    emscripten_fetch_close(fetch); // Free data associated with the fetch.

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

void downloadFailed(emscripten_fetch_t *fetch) {
  printf("Downloading %s failed, HTTP failure status code: %d.\n", fetch->url, fetch->status);
  emscripten_fetch_close(fetch); // Also free data on failure.
}

void downloadProgress(emscripten_fetch_t *fetch) {
  if (fetch->totalBytes) {
    printf("Downloading %s.. %.2f%% complete.\n", fetch->url, fetch->dataOffset * 100.0 / fetch->totalBytes);
  } else {
    printf("Downloading %s.. %lld bytes complete.\n", fetch->url, fetch->dataOffset + fetch->numBytes);
  }
}


int main(int argc, char* argv[])
{
  // emscripten_set_mousedown_callback(0, NULL, EM_FALSE, on_mouse_click);
  // emscripten_set_touchstart_callback(0, NULL, EM_FALSE, on_touch);

  emscripten_fetch_attr_t attr;
  emscripten_fetch_attr_init(&attr);
  strcpy(attr.requestMethod, "GET");
  attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY;
  attr.onsuccess = downloadSucceeded;
  attr.onprogress = downloadProgress;
  attr.onerror = downloadFailed;
  emscripten_fetch(&attr, MRB_FILE_PATH);

  return 0;
}
