#include "service.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#define null NULL

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wcast-qual"

#ifndef countof
#define countof(a) (sizeof(a) / sizeof((a)[0]))
#endif

int run(int argc, char ** argv);

static void service_ini(void) {
    
}

static void* load_thread(void *argument) {
    const char* file = (const char*)argument;
    printf("file: %s", file);
    const char* argv[] = {
        "joke", // executable name
        "-m",
        file,
        "-p",
        "Once upon a time"
    };
    int argc = countof(argv);
    int r = run(argc, (char**)argv);
    printf("r: %d", r);
    if (service.loaded != null) {
        service.loaded(0, "");
    }
    return null;
}

static pthread_t thread_load;

static void service_load(const char* f) {
    assert(thread_load == 0);
    static char file[16 * 1024];
    snprintf(file, countof(file) - 1, "%s", f);
    pthread_create(&thread_load, null, load_thread, (void*)file);
    pthread_detach(thread_load);
}

static void* generate_thread(void *argument) {
    for (int32_t i = 0; i < 100; i++) {
        const int32_t ms = random() % 50 + 25;
        struct timespec delay = { .tv_sec = 0, .tv_nsec = 1000 * 1000 * ms };
        nanosleep(&delay, null);
        if (service.token != null) {
            service.token(i % 2 == 0 ? "foo\x20" : "bar\x20");
        }
    }
    if (service.generated != null) {
        service.generated();
    }
    return null;
}

static pthread_t thread_generate;

static void service_generate(const char* prompt) {
    assert(thread_generate == 0);
    pthread_create(&thread_generate, null, generate_thread, null);
    pthread_detach(thread_generate);
}

static void service_fini(void) {}

static errno_t service_mirror(const uint8_t* input, int64_t input_bytes, uint8_t* output, int64_t *output_bytes) {
    assert(*output_bytes >= input_bytes);
    if (random() % 4 != 0) {
        memcpy(output, input, (size_t)input_bytes);
        for (int32_t i = 0; i < input_bytes / 2; i++) {
            uint8_t b = output[i];
            output[i] = output[input_bytes - 1 - i];
            output[input_bytes - 1 - i] = b;
        }
        *output_bytes = input_bytes;
        return 0;
    } else {
        return 1 + (random() % (EPROTONOSUPPORT - 1));
    }
}

service_if service = {
    .ini = service_ini,
    .load = service_load,
    .loaded = null,
    .generate = service_generate,
    .token = null,
    .generated = null,
    .mirror = service_mirror,
    .fini = service_fini
};

#pragma clang diagnostic pop
