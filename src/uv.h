/*
 * Copyright 2026 International Digital Economy Academy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MOONBIT_UV_H
#define MOONBIT_UV_H

#include "moonbit.h"

#ifdef DEBUG
#include <stdio.h>

static inline void
moonbit_uv_decref(const char *func, const char *name, void *object) {
  fprintf(stderr, "%s: (decref) %s = %p\n", func, name, object);
  fprintf(
    stderr, "%s: (decref) %s->rc = %d -> %d\n", func, name,
    Moonbit_object_header(object)->rc, Moonbit_object_header(object)->rc - 1
  );
  moonbit_decref(object);
}

static inline void
moonbit_uv_incref(const char *func, const char *name, void *object) {
  fprintf(stderr, "%s: (incref) %s = %p\n", func, name, object);
  fprintf(
    stderr, "%s: (incref) %s->rc = %d -> %d\n", func, name,
    Moonbit_object_header(object)->rc, Moonbit_object_header(object)->rc + 1
  );
  moonbit_incref(object);
}

#define moonbit_incref(object) moonbit_uv_incref(__func__, #object, object)
#define moonbit_decref(object) moonbit_uv_decref(__func__, #object, object)
#define moonbit_uv_trace(string) fprintf(stderr, "%s: " string, __func__)
#define moonbit_uv_tracef(format, ...)                                         \
  fprintf(stderr, "%s: " format, __func__, __VA_ARGS__)
#else
#define moonbit_uv_trace(...)
#define moonbit_uv_tracef(...)
#endif

#define moonbit_uv_ignore(var) (void)(var)

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr) - offsetof(type, member)))

#endif // MOONBIT_UV_H
