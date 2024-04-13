#ifndef service_h
#define service_h

#include <stdint.h>
#include <errno.h>

typedef struct service_if {
    void (*ini)(void);
    void (*load)(const char* file); // load model from file
    void (*loaded)(errno_t err, const char* text); // callback
    void (*generate)(const char* prompt);
    void (*token)(const char* token); // callback:
    void (*generated)(void); // callback: end of tokens stream
    // TODO: mirror only for preliminary testing:
    errno_t (*mirror)(const uint8_t* input, int64_t input_bytes, 
                      uint8_t* output, int64_t *output_bytes);
    void (*fini)(void);
} service_if;

extern service_if service;

#endif /* service_h */
