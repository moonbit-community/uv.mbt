/* Copyright 2025 International Digital Economy Academy
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

#include "moonbit.h"
#include "uv#include#uv.h"
#include "uv.h"

typedef struct moonbit_uv_addrinfo_hints_s {
  struct addrinfo addrinfo;
} moonbit_uv_addrinfo_hints_t;

MOONBIT_FFI_EXPORT
moonbit_uv_addrinfo_hints_t *
moonbit_uv_addrinfo_hints(
  int32_t flags,
  int32_t family,
  int32_t socktype,
  int32_t protocol
) {
  moonbit_uv_addrinfo_hints_t *hints = (moonbit_uv_addrinfo_hints_t *)
    moonbit_make_bytes(sizeof(moonbit_uv_addrinfo_hints_t), 0);
  hints->addrinfo.ai_flags = flags;
  hints->addrinfo.ai_family = family;
  hints->addrinfo.ai_socktype = socktype;
  hints->addrinfo.ai_protocol = protocol;
  return hints;
}

typedef struct moonbit_uv_addrinfo_results_s {
  struct addrinfo *addrinfo;
} moonbit_uv_addrinfo_results_t;

static inline void
moonbit_uv_addrinfo_results_finalize(void *object) {
  moonbit_uv_addrinfo_results_t *results = object;
  if (results->addrinfo) {
    uv_freeaddrinfo(results->addrinfo);
  }
}

static inline moonbit_uv_addrinfo_results_t *
moonbit_uv_addrinfo_results_make(struct addrinfo *addrinfo) {
  moonbit_uv_addrinfo_results_t *results =
    (moonbit_uv_addrinfo_results_t *)moonbit_make_external_object(
      moonbit_uv_addrinfo_results_finalize,
      sizeof(moonbit_uv_addrinfo_results_t)
    );
  memset(results, 0, sizeof(moonbit_uv_addrinfo_results_t));
  results->addrinfo = addrinfo;
  return results;
}

typedef struct moonbit_uv_getaddrinfo_s {
  uv_getaddrinfo_t getaddrinfo;
} moonbit_uv_getaddrinfo_t;

static inline void
moonbit_uv_getaddrinfo_finalize(void *object) {
  moonbit_uv_getaddrinfo_t *getaddrinfo = object;
  if (getaddrinfo->getaddrinfo.data) {
    moonbit_decref(getaddrinfo->getaddrinfo.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_getaddrinfo_t *
moonbit_uv_getaddrinfo_make(void) {
  moonbit_uv_getaddrinfo_t *getaddrinfo =
    (moonbit_uv_getaddrinfo_t *)moonbit_make_external_object(
      moonbit_uv_getaddrinfo_finalize, sizeof(moonbit_uv_getaddrinfo_t)
    );
  memset(getaddrinfo, 0, sizeof(moonbit_uv_getaddrinfo_t));
  return getaddrinfo;
}

typedef struct moonbit_uv_getaddrinfo_cb_s {
  int32_t (*code)(
    struct moonbit_uv_getaddrinfo_cb_s *,
    moonbit_uv_getaddrinfo_t *req,
    int32_t status,
    moonbit_uv_addrinfo_results_t *results
  );
} moonbit_uv_getaddrinfo_cb_t;

static inline void
moonbit_uv_getaddrinfo_cb(
  uv_getaddrinfo_t *req,
  int32_t status,
  struct addrinfo *addrinfo
) {
  moonbit_uv_getaddrinfo_cb_t *cb = req->data;
  req->data = NULL;
  moonbit_uv_getaddrinfo_t *getaddrinfo =
    containerof(req, moonbit_uv_getaddrinfo_t, getaddrinfo);
  moonbit_uv_addrinfo_results_t *results =
    moonbit_uv_addrinfo_results_make(addrinfo);
  cb->code(cb, getaddrinfo, status, results);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_getaddrinfo(
  uv_loop_t *loop,
  moonbit_uv_getaddrinfo_t *req,
  moonbit_uv_getaddrinfo_cb_t *cb,
  moonbit_bytes_t node,
  moonbit_bytes_t service,
  moonbit_uv_addrinfo_hints_t *hints
) {
  if (req->getaddrinfo.data) {
    moonbit_decref(req->getaddrinfo.data);
  }
  req->getaddrinfo.data = cb;
  struct addrinfo *addrinfo = NULL;
  if (hints) {
    addrinfo = &hints->addrinfo;
  }
  int32_t status = uv_getaddrinfo(
    loop, &req->getaddrinfo, moonbit_uv_getaddrinfo_cb, (const char *)node,
    (const char *)service, addrinfo
  );
  moonbit_decref(loop);
  moonbit_decref(node);
  moonbit_decref(service);
  if (hints) {
    moonbit_decref(hints);
  }
  return status;
}

typedef struct moonbit_uv_addrinfo_results_iterate_cb_s {
  int32_t (*code)(
    struct moonbit_uv_addrinfo_results_iterate_cb_s *,
    int32_t ai_flags,
    int32_t ai_family,
    int32_t ai_socktype,
    int32_t ai_protocol,
    moonbit_bytes_t ai_addr,
    char *ai_canonname
  );
} moonbit_uv_addrinfo_results_iterate_cb_t;

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_addrinfo_results_iterate(
  moonbit_uv_addrinfo_results_t *results,
  moonbit_uv_addrinfo_results_iterate_cb_t *cb
) {
  int32_t terminated = 0;
  for (struct addrinfo *ai = results->addrinfo; ai != NULL; ai = ai->ai_next) {
    moonbit_bytes_t sockaddr = moonbit_make_bytes(ai->ai_addrlen, 0);
    memcpy((void *)sockaddr, ai->ai_addr, ai->ai_addrlen);
    moonbit_incref(cb);
    terminated = cb->code(
      cb, ai->ai_flags, ai->ai_family, ai->ai_socktype, ai->ai_protocol,
      sockaddr, ai->ai_canonname
    );
    if (terminated) {
      break;
    }
  }
  return terminated;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_PASSIVE(void) {
  return AI_PASSIVE;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_V4MAPPED(void) {
  return AI_V4MAPPED;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_ALL(void) {
  return AI_ALL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_ADDRCONFIG(void) {
  return AI_ADDRCONFIG;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_NUMERICHOST(void) {
  return AI_NUMERICHOST;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_NUMERICSERV(void) {
  return AI_NUMERICSERV;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AI_CANONNAME(void) {
  return AI_CANONNAME;
}
