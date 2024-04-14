#include "service.h"
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
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

static const char* punctuation = ".\"?!";

static bool is_punctuation(char ch) {
    return strchr(punctuation, ch) != 0;
}

static void* process_output(void *arg) {
    int pipe_read_fd = (int)(uintptr_t)arg;
    uint8_t buffer[128];
    ssize_t bytes_read;
    static uint8_t text[1024];
    int n = 0;
    while ((bytes_read = read(pipe_read_fd, buffer, sizeof(buffer) - 4)) > 0) {
        buffer[bytes_read] = 0x00;
        for (int i = 0; i < bytes_read; ++i) {
            text[n++] = buffer[i];
            // dump UTF8: sequences:
//          if (buffer[i] >= 0x80) { fprintf(stderr, "char=0x%02X\n", buffer[i]); }
            if (buffer[i] <= 0x20) { // Check for whitespace or control characters
                if (n > 0) {
                    if (is_punctuation(text[n - 1])) {
                        text[n++] = '\n';
                    }
                    text[n] = 0x00;
                    service.token(text); // Call token for each word
                    n = 0; // Reset text array for the next word
                }
            } else {
                if (n >= (int)sizeof(text) - 1) {
                    if (is_punctuation(text[n - 1])) {
                        text[n++] = '\n';
                    }
                    text[sizeof(text) - 1] = 0x00;
                    service.token(text);
                    n = 0;
                }
            }
        }
    }
    // Process any remaining characters in buffer
    if (n > 0) {
        if (is_punctuation(text[n - 1])) {
            text[n++] = '\n';
        }
        text[n] = 0x00;
        service.token(text);
    }
    return null;
}

int run(int argc, char ** argv);

static const char* model_name;

static void* load_thread(void *argument) {
    model_name = (const char*)argument;
//  printf("model_name: %s\n", model_name);
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
//  printf("file: %s\n", file);
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
        "--n_predict", "400",
        "--repeat_penalty", "1.4",
        "-m",
        file,
        "-p",
        prompt
    };
#endif
    int argc = countof(argv);
    fflush(stdout); // any debug output flushed before we proceed
    int pipefd[2];
    pipe(pipefd); // Create a pipe
    int stdout_copy = dup(STDOUT_FILENO);
    dup2(pipefd[1], STDOUT_FILENO); // Redirect stdout to the pipe
    // Prepare to launch thread for output processing
    pthread_t tid;
    pthread_create(&tid, null, process_output, (void*)(uintptr_t)pipefd[0]);
    int r = run(argc, (char**)argv); // Call the function run
    close(pipefd[1]); // Close the write end of the pipe
    close(pipefd[0]); // Close the read end of the pipe
    // Wait for the processing thread to finish
    pthread_join(tid, null);
    dup2(stdout_copy, STDOUT_FILENO); // Restore stdout
//  printf("r: %d", r);
    (void)r; // unused
    if (service.generated != null) {
        service.generated();
    }
    return null;
}

static pthread_t thread_generate;

static void service_generate(const uint8_t* prompt) {
    assert(thread_generate == 0);
    assert(thread_load == 0);
    static char p[128 * 1024 * 4];
    snprintf(p, countof(p) - 1, "%s", prompt);
    pthread_create(&thread_generate, null, generate_thread, p);
    pthread_detach(thread_generate);
}

static void service_fini(void) {}

service_if service = {
    .ini = service_ini,
    .load = service_load,
    .loaded = null,
    .generate = service_generate,
    .token = null,
    .generated = null,
    .fini = service_fini
};

#pragma clang diagnostic pop
