#include "service.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>

#define null NULL

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wcast-qual"

#ifndef countof
#define countof(a) (sizeof(a) / sizeof((a)[0]))
#endif

static void service_ini(void) { }

static const char* puntuation = ".\"?!";

static void* process_output(void *arg) {
    int pipe_read_fd = (int)(uintptr_t)arg;
    char buffer[128];
    ssize_t bytes_read;
    static char text[1024];
    int text_len = 0;
    while ((bytes_read = read(pipe_read_fd, buffer, sizeof(buffer) - 4)) > 0) {
        buffer[bytes_read] = 0x00;
        for (int i = 0; i < bytes_read; ++i) {
            if (buffer[i] <= 0x20) { // Check for whitespace or control characters
                if (text_len > 0) {
                    if (strrchr(puntuation, text[text_len - 1]) != null) {
                        text[text_len++] = '\n';
                    }
                    text[text_len] = 0x00;
                    service.token(text); // Call token for each word
                    text_len = 0; // Reset text array for the next word
                }
            } else {
                text[text_len++] = buffer[i]; // Accumulate characters
                if (text_len >= (int)sizeof(text) - 1) {
                    if (strrchr(puntuation, text[text_len - 1]) != null) {
                        text[text_len++] = '\n';
                    }
                    text[sizeof(text) - 1] = 0x00;
                    service.token(text);
                    text_len = 0;
                }
            }
        }
    }
    // Process any remaining characters in buffer
    if (text_len > 0) {
        if (strrchr(puntuation, text[text_len - 1]) != null) {
            text[text_len++] = '\n';
        }
        text[text_len] = 0x00;
        service.token(text);
    }
    close(pipe_read_fd); // Close the read end of the pipe
    return null;
}

int run(int argc, char ** argv);

static const char* model_name;

static void* load_thread(void *argument) {
    model_name = (const char*)argument;
    printf("model_name: %s\n", model_name);
    // TODO: preload model
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
    const char* file = (const char*)model_name;
    const char* prompt = (const char*)argument;
    printf("file: %s\n", file);
#ifdef CHAT
    const char* argv[] = {
        "joke", // executable name
        "--no-display-prompt",
        "-i",
        "-r", "User:",
        "--in-prefix", "\x20",
        "--ctx-size",  "2048",
        "--n_predict", "2048",
        "-m",
        file,
        "-p",
        prompt
    };
#else
    const char* argv[] = {
        "joke", // executable name
        "--no-display-prompt",
        "--ctx-size",  "2048",
        "--n_predict", "2048",
        "--repeat_penalty", "1.4",
        "-m",
        file,
        "-p",
        prompt
    };
#endif
    int argc = countof(argv);
    int pipefd[2];
    pipe(pipefd); // Create a pipe
    int stdout_copy = dup(STDOUT_FILENO);
    dup2(pipefd[1], STDOUT_FILENO); // Redirect stdout to the pipe
    // Prepare to launch thread for output processing
    pthread_t tid;
    pthread_create(&tid, null, process_output, (void*)(uintptr_t)pipefd[0]);
    int r = run(argc, (char**)argv); // Call the function run
    close(pipefd[1]); // Close the write end of the pipe
    // Wait for the processing thread to finish
    pthread_join(tid, null);
    dup2(stdout_copy, STDOUT_FILENO); // Restore stdout
    printf("r: %d", r);
    if (service.generated != null) {
        service.generated();
    }
    return null;
}

static pthread_t thread_generate;

static void service_generate(const char* prompt) {
    assert(thread_generate == 0);
    assert(thread_load == 0);
    static char p[128 * 1024 * 4];
    snprintf(p, countof(p) - 1, "%s", prompt);
    pthread_create(&thread_generate, null, generate_thread, p);
    pthread_detach(thread_generate);
}

static void service_fini(void) {}

static errno_t service_mirror(const uint8_t* input, int64_t input_bytes, 
                              uint8_t* output, int64_t *output_bytes) {
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
