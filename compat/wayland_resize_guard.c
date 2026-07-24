#define _GNU_SOURCE
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

struct wl_proxy;
struct wl_registry;
union wl_argument {
    int32_t i;
    uint32_t u;
    int32_t f;
    const char *s;
    void *o;
    uint32_t n;
    void *a;
    int32_t h;
};
extern void *dlsym(void *handle, const char *symbol);
#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *) -1l)
#endif

typedef const char *(*get_class_fn)(struct wl_proxy *proxy);
typedef void *(*marshal_flags_fn)();
typedef void *(*marshal_array_flags_fn)(struct wl_proxy *proxy, uint32_t opcode, const void *interface, uint32_t version, uint32_t flags, union wl_argument *args);
typedef void (*marshal_fn)();
typedef void (*marshal_var_fn)(struct wl_proxy *proxy, uint32_t opcode, ...);
typedef void (*marshal_array_fn)(struct wl_proxy *proxy, uint32_t opcode, union wl_argument *args);
typedef void *(*marshal_constructor_fn)();
typedef void *(*marshal_constructor3_fn)(struct wl_proxy *proxy, uint32_t opcode, const void *interface);
typedef int (*registry_add_listener_fn)(struct wl_registry *registry, const struct wl_registry_listener *listener, void *data);
typedef int (*proxy_add_listener_fn)(struct wl_proxy *proxy, void (**implementation)(void), void *data);

struct wl_registry_listener {
    void (*global)(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version);
    void (*global_remove)(void *data, struct wl_registry *registry, uint32_t name);
};

struct registry_listener_entry {
    struct wl_registry *registry;
    const struct wl_registry_listener *listener;
    void *data;
};

static get_class_fn real_wl_proxy_get_class;
static marshal_flags_fn real_wl_proxy_marshal_flags;
static marshal_array_flags_fn real_wl_proxy_marshal_array_flags;
static marshal_fn real_wl_proxy_marshal;
static marshal_array_fn real_wl_proxy_marshal_array;
static marshal_constructor_fn real_wl_proxy_marshal_constructor;
static marshal_constructor_fn real_wl_proxy_marshal_constructor_versioned;
static registry_add_listener_fn real_wl_registry_add_listener;
static proxy_add_listener_fn real_wl_proxy_add_listener;
static struct registry_listener_entry registry_entries[16];
static const struct wl_registry_listener filtering_registry_listener;

__attribute__((constructor))
static void guard_loaded(void) {
}

static void init_real_symbols(void) {
    if (!real_wl_proxy_get_class) {
        real_wl_proxy_get_class = (get_class_fn)dlsym(RTLD_NEXT, "wl_proxy_get_class");
    }
    if (!real_wl_proxy_marshal_flags) {
        real_wl_proxy_marshal_flags = (marshal_flags_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal_flags");
    }
    if (!real_wl_proxy_marshal_array_flags) {
        real_wl_proxy_marshal_array_flags = (marshal_array_flags_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal_array_flags");
    }
    if (!real_wl_proxy_marshal) {
        real_wl_proxy_marshal = (marshal_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal");
    }
    if (!real_wl_proxy_marshal_array) {
        real_wl_proxy_marshal_array = (marshal_array_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal_array");
    }
    if (!real_wl_proxy_marshal_constructor) {
        real_wl_proxy_marshal_constructor = (marshal_constructor_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal_constructor");
    }
    if (!real_wl_proxy_marshal_constructor_versioned) {
        real_wl_proxy_marshal_constructor_versioned = (marshal_constructor_fn)dlsym(RTLD_NEXT, "wl_proxy_marshal_constructor_versioned");
    }
    if (!real_wl_registry_add_listener) {
        real_wl_registry_add_listener = (registry_add_listener_fn)dlsym(RTLD_NEXT, "wl_registry_add_listener");
    }
    if (!real_wl_proxy_add_listener) {
        real_wl_proxy_add_listener = (proxy_add_listener_fn)dlsym(RTLD_NEXT, "wl_proxy_add_listener");
    }
}

static int should_drop_resize(struct wl_proxy *proxy, uint32_t opcode, union wl_argument *args) {
    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }
    if (klass && (!strcmp(klass, "xdg_toplevel") || !strcmp(klass, "zxdg_toplevel_v6"))) {
        if (opcode == 7 || opcode == 8) {
            return 1;
        }
    }
    return klass
        && opcode == 6
        && args
        && args[0].o == NULL
        && (!strcmp(klass, "xdg_toplevel") || !strcmp(klass, "zxdg_toplevel_v6"));
}

void *wl_proxy_marshal_array_flags(struct wl_proxy *proxy, uint32_t opcode, const void *interface, uint32_t version, uint32_t flags, union wl_argument *args) {
    init_real_symbols();

    if (should_drop_resize(proxy, opcode, args)) {
        fprintf(stderr, "[wayland-resize-guard] dropped xdg_toplevel.resize(null,...)\n");
        return NULL;
    }

    return real_wl_proxy_marshal_array_flags(proxy, opcode, interface, version, flags, args);
}

void wl_proxy_marshal_array(struct wl_proxy *proxy, uint32_t opcode, union wl_argument *args) {
    init_real_symbols();

    if (should_drop_resize(proxy, opcode, args)) {
        fprintf(stderr, "[wayland-resize-guard] dropped old xdg_toplevel.resize(null,...)\n");
        return;
    }

    real_wl_proxy_marshal_array(proxy, opcode, args);
}

__attribute__((noinline))
void *wl_proxy_marshal_constructor(struct wl_proxy *proxy, uint32_t opcode, const void *interface, ...) {
    init_real_symbols();

    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }

    if (0 && klass && !strcmp(klass, "xdg_surface") && opcode == 1) {
        marshal_constructor3_fn real_ctor = (marshal_constructor3_fn)real_wl_proxy_marshal_constructor;
        void *created = real_ctor(proxy, opcode, interface);
        marshal_var_fn real = (marshal_var_fn)real_wl_proxy_marshal;
        real((struct wl_proxy *)created, 9);
        real((struct wl_proxy *)created, 11, NULL);
        return created;
    }

    void *args = __builtin_apply_args();
    void *ret_block = __builtin_apply((void (*)())real_wl_proxy_marshal_constructor, args, 512);
    __builtin_return(ret_block);
}

__attribute__((noinline))
void *wl_proxy_marshal_constructor_versioned(struct wl_proxy *proxy, uint32_t opcode, const void *interface, uint32_t version, ...) {
    init_real_symbols();

    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }

    void *args = __builtin_apply_args();
    void *ret_block = __builtin_apply((void (*)())real_wl_proxy_marshal_constructor_versioned, args, 512);
    __builtin_return(ret_block);
}

__attribute__((noinline))
void wl_proxy_marshal(struct wl_proxy *proxy, uint32_t opcode, ...) {
    init_real_symbols();

    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }
    if (klass && (!strcmp(klass, "xdg_toplevel") || !strcmp(klass, "zxdg_toplevel_v6"))) {
        marshal_var_fn real = (marshal_var_fn)real_wl_proxy_marshal;
        va_list ap;
        va_start(ap, opcode);
        switch (opcode) {
        case 1: {
            void *parent = va_arg(ap, void *);
            va_end(ap);
            real(proxy, opcode, parent);
            return;
        }
        case 2:
        case 3: {
            const char *text = va_arg(ap, const char *);
            va_end(ap);
            real(proxy, opcode, text);
            return;
        }
        case 4: {
            void *seat = va_arg(ap, void *);
            uint32_t serial = va_arg(ap, uint32_t);
            int32_t x = va_arg(ap, int32_t);
            int32_t y = va_arg(ap, int32_t);
            va_end(ap);
            if (seat) {
                real(proxy, opcode, seat, serial, x, y);
            }
            return;
        }
        case 5: {
            void *seat = va_arg(ap, void *);
            uint32_t serial = va_arg(ap, uint32_t);
            va_end(ap);
            if (seat) {
                real(proxy, opcode, seat, serial);
            }
            return;
        }
        case 6: {
            void *seat = va_arg(ap, void *);
            uint32_t serial = va_arg(ap, uint32_t);
            uint32_t edges = va_arg(ap, uint32_t);
            va_end(ap);
            if (seat) {
                real(proxy, opcode, seat, serial, edges);
            }
            return;
        }
        case 7:
        case 8:
            va_end(ap);
            return;
        case 9:
        case 10:
        case 12:
        case 13:
            va_end(ap);
            real(proxy, opcode);
            return;
        case 11: {
            void *output = va_arg(ap, void *);
            va_end(ap);
            real(proxy, opcode, output);
            return;
        }
        default:
            va_end(ap);
            break;
        }
    }

    void *args = __builtin_apply_args();
    void *ret = __builtin_apply((void (*)())real_wl_proxy_marshal, args, 512);
    __builtin_return(ret);
}

__attribute__((noinline))
void *wl_proxy_marshal_flags(struct wl_proxy *proxy, uint32_t opcode, const void *interface, uint32_t version, uint32_t flags, ...) {
    init_real_symbols();

    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }
    if (opcode == 6 && klass && (!strcmp(klass, "xdg_toplevel") || !strcmp(klass, "zxdg_toplevel_v6"))) {
        va_list ap;
        va_start(ap, flags);
        void *seat = va_arg(ap, void *);
        va_end(ap);
        if (seat == NULL) {
            return NULL;
        }
    }

    void *args = __builtin_apply_args();
    void *ret = __builtin_apply((void (*)())real_wl_proxy_marshal_flags, args, 512);
    __builtin_return(ret);
}

static struct registry_listener_entry *find_registry_entry(struct wl_registry *registry) {
    for (int i = 0; i < 16; i++) {
        if (registry_entries[i].registry == registry) {
            return &registry_entries[i];
        }
    }
    return NULL;
}

static void filtering_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    struct registry_listener_entry *entry = find_registry_entry(registry);
    if (0 && interface && !strcmp(interface, "xdg_wm_base")) {
        return;
    }
    if (entry && entry->listener && entry->listener->global) {
        entry->listener->global(entry->data, registry, name, interface, version);
    }
}

static void filtering_global_remove(void *data, struct wl_registry *registry, uint32_t name) {
    struct registry_listener_entry *entry = find_registry_entry(registry);
    if (entry && entry->listener && entry->listener->global_remove) {
        entry->listener->global_remove(entry->data, registry, name);
    }
}

static const struct wl_registry_listener filtering_registry_listener = {
    filtering_global,
    filtering_global_remove,
};

int wl_registry_add_listener(struct wl_registry *registry, const struct wl_registry_listener *listener, void *data) {
    init_real_symbols();
    for (int i = 0; i < 16; i++) {
        if (registry_entries[i].registry == NULL || registry_entries[i].registry == registry) {
            registry_entries[i].registry = registry;
            registry_entries[i].listener = listener;
            registry_entries[i].data = data;
            break;
        }
    }
    return real_wl_registry_add_listener(registry, &filtering_registry_listener, NULL);
}

int wl_proxy_add_listener(struct wl_proxy *proxy, void (**implementation)(void), void *data) {
    init_real_symbols();
    const char *klass = NULL;
    if (real_wl_proxy_get_class && proxy) {
        klass = real_wl_proxy_get_class(proxy);
    }
    if (0 && klass && !strcmp(klass, "wl_registry")) {
        struct wl_registry *registry = (struct wl_registry *)proxy;
        for (int i = 0; i < 16; i++) {
            if (registry_entries[i].registry == NULL || registry_entries[i].registry == registry) {
                registry_entries[i].registry = registry;
                registry_entries[i].listener = (const struct wl_registry_listener *)implementation;
                registry_entries[i].data = data;
                break;
            }
        }
        return real_wl_proxy_add_listener(proxy, (void (**)(void))&filtering_registry_listener, NULL);
    }
    return real_wl_proxy_add_listener(proxy, implementation, data);
}
