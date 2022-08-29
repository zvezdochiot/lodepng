# This makefile only makes the unit test, benchmark and pngdetail and showpng
# utilities. It does not make the PNG codec itself as shared or static library.
# That is because:
# LodePNG itself has only 1 source file (lodepng.cpp, can be renamed to
# lodepng.c) and is intended to be included as source file in other projects and
# their build system directly.


CC ?= gcc
CXX ?= g++

CBASEFLAGS = -W -Wall -Wextra -ansi -pedantic -O3

ifneq ($(shell uname -m), i386)
    CBASEFLAGS += -fPIC
endif

override CFLAGS := $(CBASEFLAGS) -Wno-unused-function $(CFLAGS)
override CXXFLAGS := $(CBASEFLAGS) $(CXXFLAGS)

BIN       = unittest benchmark pngdetail pngshow pnglossy
STATICLIB = $(PREFIX)liblodepng.a
SHAREDLIB = $(PREFIX)liblodepng.so.0
SHAREDBIN = pngdetail-shared pngreencode-shared pnglossy-shared pngshow-shared
LIBOBJS   = src/lodepng.o src/lodepng_util.o
LIBSDL    = -lSDL2
RM        = rm -f

all:  $(STATICLIB) $(BIN)

%.o: %.cpp
	$(CXX) -Isrc $(CXXFLAGS) -c $< -o $@

unittest: src/lodepng_unittest.o $(STATICLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

benchmark: src/lodepng_benchmark.o $(STATICLIB)
	$(CXX) $(CXXFLAGS) $^ $(LIBSDL) -o $@

pngdetail: src/pngdetail.o $(STATICLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

pngshow:  src/examples/example_sdl.o $(STATICLIB)
	$(CXX) $(CXXFLAGS) $^ $(LIBSDL) -o $@

pnglossy: src/examples/example_lossy.o $(STATICLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

shared: $(STATICLIB) $(SHAREDLIB) $(SHAREDBIN)

$(STATICLIB): $(LIBOBJS)
	$(AR) rcs $@ $^
	$(if $(RANLIB), $(RANLIB) $@)

$(SHAREDLIB): $(LIBOBJS)
	$(CXX) -shared -Wl,-soname,$@ $(CXXFLAGS) $^ $(LDFLAGS) -o $@

pngdetail-shared: src/pngdetail.o $(SHAREDLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

pngreencode-shared: src/examples/example_reencode.o $(SHAREDLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

pnglossy-shared: src/examples/example_lossy.o $(SHAREDLIB)
	$(CXX) $(CXXFLAGS) $^ -o $@

pngshow-shared: src/examples/example_sdl.o $(SHAREDLIB)
	$(CXX) $(CXXFLAGS) $^ $(LIBSDL) -o $@

clean:
	$(RM) $(BIN) $(STATICLIB) $(SHAREDLIB) $(SHAREDBIN) src/*.o src/examples/*.o
