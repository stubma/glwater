# macros to include all files with same extension

define all-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find $(1) -name "$(2)" -and -not -name ".*") \
 )
endef

define all-cpp-files-under
$(call all-files-under,$(1),*.cpp)
endef

# build app lib

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := game
LOCAL_LDLIBS := -lGLESv3
LOCAL_SRC_FILES := $(call all-cpp-files-under,.)
LOCAL_C_INCLUDES := $(LOCAL_PATH)
include $(BUILD_SHARED_LIBRARY)