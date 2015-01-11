#include <jni.h>
#include <GLES3/gl3.h>

extern "C" {

JNIEXPORT void JNICALL Java_com_luma_glwater_MainActivity_draw
  (JNIEnv * env, jobject thiz) {
	glClearColor(1, 1, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

}
