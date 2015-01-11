#ifndef __log_h__
#define __log_h__

#if ANDROID
	#include <android/log.h>
#elif IOS || MACOSX
	#import <Foundation/Foundation.h>
#endif

#if ANDROID
	#undef LOG_TAG
	#undef LOGD
	#undef LOGW
	#undef LOGE
	#define LOG_TAG "glwater"
	#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
	#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,LOG_TAG,__VA_ARGS__)
	#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#elif IOS || MACOSX
	#define LOGD(fmt, ...) NSLog(@fmt, ##__VA_ARGS__)
	#define LOGW(fmt, ...) NSLog(@fmt, ##__VA_ARGS__) 
	#define LOGE(fmt, ...) NSLog(@fmt, ##__VA_ARGS__)
#endif

#endif // __log_h__
