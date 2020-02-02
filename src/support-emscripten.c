#include <emscripten.h>
#include <emscripten/html5.h>
#include <SDL/SDL_mixer.h> // mixer SDL1, not 2

static void open_audio()
{
  EM_ASM({
    if(SDL.audioContext && SDL.audioContext.currentTime == 0) {
      console.log("attempting to unlock");
      var buffer = SDL.audioContext.createBuffer(1, 1, 22050);
      var source = SDL.audioContext.createBufferSource();
      source.buffer = buffer;
      source.connect(SDL.audioContext.destination);
      // source.noteOn(0);
      source.start(0);
    }
  });
}

EM_BOOL on_mouse_click(int eventType, const EmscriptenMouseEvent *mouseEvent, void *userData)
{
  open_audio();
  return EM_FALSE; // not consume event
}

EM_BOOL on_touch(int eventType, const EmscriptenTouchEvent *touchEvent, void *userData)
{
  open_audio();
  return EM_FALSE; // not consume event
}
