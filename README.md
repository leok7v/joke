# YLIP: Young Lady/Lad Illustrated Primer

**YLIP** is a modern homage to Neal Stephenson's visionary novel, *The Diamond Age*, 
and its remarkable artifact: "A Young Lady's Illustrated Primer." 
Dive into the project's details on [Wikipedia](https://en.wikipedia.org/wiki/The_Diamond_Age).

[![Build Status](https://github.com/leok7v/joke/actions/workflows/build-on-push.yml/badge.svg)](https://github.com/leok7v/joke/actions/workflows/build-on-push.yml)

---

### Project Overview

In the spirit of the original Primer, YLIP leverages the power of 
Large Language Models (LLMs) to craft enchanting fairy tale-based 
bedtime stories. 

Our digital primer aims to inspire and educate, weaving tales that 
captivate both young and old. Join us on this journey as we blend 
the magic of storytelling with cutting-edge AI technology, 
creating a unique experience for the 21st-century reader.


### llama.cpp build notes

```
CFLAGS=-I. -Icommon -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE -DNDEBUG -DGGML_USE_ACCELERATE -DACCELERATE_NEW_LAPACK -DACCELERATE_LAPACK_ILP64 -DGGML_USE_METAL  -std=c11   -fPIC -O3 -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function -Wshadow -Wstrict-prototypes -Wpointer-arith -Wmissing-prototypes -Werror=implicit-int -Werror=implicit-function-declaration -pthread -Wunreachable-code-break -Wunreachable-code-return -Wdouble-promotion
cc $(CFLAGS)  -c ggml.c
cc $(CFLAGS)  -c ggml-metal.m
cc $(CFLAGS)  -c ggml-alloc.c
cc $(CFLAGS)  -c ggml-backend.c
cc $(CFLAGS)  -c ggml-quants.c

CPPFLAGS=-std=c++11 -fPIC -O3 -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function -Wmissing-declarations -Wmissing-noreturn -pthread   -Wunreachable-code-break -Wunreachable-code-return -Wmissing-prototypes -Wextra-semi -I. -Icommon -D_XOPEN_SOURCE=600 -D_DARWIN_C_SOURCE -DNDEBUG -DGGML_USE_ACCELERATE -DACCELERATE_NEW_LAPACK -DACCELERATE_LAPACK_ILP64 -DGGML_USE_METAL
c++ $(CPPFLAGS)  -c llama.cpp -o llama.o
c++ $(CPPFLAGS)  -c common/common.cpp -o common.o
c++ $(CPPFLAGS)  -c common/sampling.cpp -o sampling.o
c++ $(CPPFLAGS)  -c common/grammar-parser.cpp -o grammar-parser.o
c++ $(CPPFLAGS)  -c common/build-info.cpp -o build-info.o
c++ $(CPPFLAGS)  -c common/console.cpp -o console.o
c++ $(CPPFLAGS)  -c unicode.cpp -o unicode.o
c++ $(CPPFLAGS)  -c unicode-data.cpp -o unicode-data.o
c++ $(CPPFLAGS)  -c examples/main/main.cpp -o examples/main/main.o
c++ $(CPPFLAGS)  ggml.o llama.o common.o sampling.o grammar-parser.o build-info.o console.o ggml-metal.o ggml-alloc.o ggml-backend.o ggml-quants.o unicode.o unicode-data.o examples/main/main.o -o main -framework Accelerate -framework Foundation -framework Metal -framework MetalKit 
```

