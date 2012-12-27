OS = $(shell uname -s)
CC = gcc

ifeq ($(OS), Darwin)
JARSUFFIX=mac
endif
ifeq ($(OS), Linux)
JARSUFFIX=linux
endif
ifneq (,$(findstring WIN,$(OS)))
JARSUFFIX=win32
endif

# APIVERSION is used in soname
APIVERSION = 1
CFLAGS = -Os -g
CFLAGS += -fPIC
CFLAGS += -Wall
CFLAGS += -Wextra

LIBOBJS = test.o

STATICLIB = test.a
ifeq ($(OS), Darwin)
  SHAREDLIB = test.dylib
  SONAME = $(basename $(SHAREDLIB)).$(APIVERSION).dylib
  CFLAGS := -DMACOSX -D_DARWIN_C_SOURCE $(CFLAGS)
else
ifeq ($(JARSUFFIX), win32)
  SHAREDLIB = test.dll
else
  SHAREDLIB = libtest.so
  SONAME = $(SHAREDLIB).$(APIVERSION)
endif
endif

HEADERS = test.h

JAVA = java
# see http://code.google.com/p/jnaerator/
JNAERATOR = jnaerator-0.10-shaded.jar
JNAERATORBASEURL = http://jnaerator.googlecode.com/files/


.PHONY:	all clean depend 

all: $(STATICLIB) $(SHAREDLIB) 

clean:
	$(RM) $(LIBOBJS) $(STATICLIB) $(SHAREDLIB)
	$(RM) -r build/ dist/
	$(RM) _jnaerator.* java/test_$(OS).jar

depend:
	makedepend -f$(MAKEFILE_LIST) -Y $(OBJS:.o=.c) 2>/dev/null


jnaerator-0.10-shaded.jar:
	wget $(JNAERATORBASEURL)/$@ || curl -o $@ $(JNAERATORBASEURL)/$@

jar: $(SHAREDLIB)  $(JNAERATOR)
	$(JAVA) -jar $(JNAERATOR) -runtime JNAerator -mode StandaloneJar \
	-library test $(SHAREDLIB) test.h \
	-package org.getlantern.test -o . \
	-libFile $(SHAREDLIB) -jar java/test_$(JARSUFFIX).jar

$(STATICLIB):	$(LIBOBJS)
	$(AR) crs $@ $?

$(SHAREDLIB):	$(LIBOBJS)
ifeq ($(OS), Darwin)
	$(CC) -dynamiclib -Wl,-install_name,$(SONAME) -o $@ $^
else
	$(CC) -shared -Wl,-soname,$(SONAME) -o $@ $^
endif

test.o: test.h

