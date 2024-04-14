#ifndef service_h
#define service_h

#include <stdint.h>
#include <errno.h>

typedef struct service_if {
    void (*ini)(void);
    void (*load)(const char* file); // load model from file
    void (*loaded)(errno_t err, const char* text); // callback
    void (*generate)(const uint8_t* prompt);
    void (*token)(const uint8_t* token); // callback:
    void (*generated)(void); // callback: end of tokens stream
    void (*fini)(void);
} service_if;

extern service_if service;

#endif /* service_h */
