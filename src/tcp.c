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

#include "handle.h"
#include "moonbit.h"
#include "socket.h"
#include "stream.h"
#include "uv#include#uv.h"
#include "uv.h"

typedef struct moonbit_uv_tcp_s {
  uv_tcp_t tcp;
} moonbit_uv_tcp_t;

static inline void
moonbit_uv_tcp_finalize(void *object) {
  moonbit_uv_tcp_t *tcp = (moonbit_uv_tcp_t *)object;
  moonbit_uv_tracef("tcp = %p\n", (void *)tcp);
  moonbit_uv_tracef("tcp->rc = %d\n", Moonbit_object_header(tcp)->rc);
  if (tcp->tcp.data) {
    moonbit_decref(tcp->tcp.data);
    tcp->tcp.data = NULL;
  }
  if (tcp->tcp.loop) {
    moonbit_uv_tracef("tcp->loop = %p\n", (void *)tcp->tcp.loop);
    moonbit_decref(tcp->tcp.loop);
    tcp->tcp.loop = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_tcp_t *
moonbit_uv_tcp_make(void) {
  moonbit_uv_tcp_t *tcp = (moonbit_uv_tcp_t *)moonbit_make_external_object(
    moonbit_uv_tcp_finalize, sizeof(moonbit_uv_tcp_t)
  );
  moonbit_uv_tracef("tcp = %p\n", (void *)tcp);
  memset(tcp, 0, sizeof(moonbit_uv_tcp_t));
  return tcp;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_init(uv_loop_t *loop, moonbit_uv_tcp_t *tcp) {
  moonbit_uv_tracef("tcp = %p\n", (void *)tcp);
  moonbit_uv_tracef("tcp->rc = %d\n", Moonbit_object_header(tcp)->rc);
  return uv_tcp_init(loop, &tcp->tcp);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_open(moonbit_uv_tcp_t *tcp, moonbit_uv_os_sock_t *sock) {
  moonbit_uv_tracef("tcp = %p\n", (void *)tcp);
  moonbit_uv_tracef("sock = %p\n", (void *)sock);
  int result = uv_tcp_open(&tcp->tcp, sock->sock);
  moonbit_decref(tcp);
  moonbit_decref(sock);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_bind(
  moonbit_uv_tcp_t *tcp,
  struct sockaddr *addr,
  uint32_t flags
) {
  int result = uv_tcp_bind(&tcp->tcp, addr, flags);
  moonbit_decref(tcp);
  moonbit_decref(addr);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_connect(
  uv_connect_t *connect,
  moonbit_uv_tcp_t *tcp,
  struct sockaddr *addr,
  moonbit_uv_connection_cb_t *cb
) {
  if (connect->data) {
    moonbit_decref(connect->data);
  }
  connect->data = cb;
  // The ownership of `connect` is transferred into `loop`.
  int result = uv_tcp_connect(connect, &tcp->tcp, addr, moonbit_uv_connect_cb);
  moonbit_decref(addr);
  moonbit_decref(tcp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_nodelay(moonbit_uv_tcp_t *tcp, bool enable) {
  int result = uv_tcp_nodelay(&tcp->tcp, enable ? 1 : 0);
  moonbit_decref(tcp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_keepalive(moonbit_uv_tcp_t *tcp, bool enable, uint32_t delay) {
  int result = uv_tcp_keepalive(&tcp->tcp, enable ? 1 : 0, delay);
  moonbit_decref(tcp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_getsockname(moonbit_uv_tcp_t *tcp, struct sockaddr *addr) {
  int namelen = sizeof(struct sockaddr_storage);
  int result = uv_tcp_getsockname(&tcp->tcp, addr, &namelen);
  moonbit_decref(tcp);
  moonbit_decref(addr);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_getpeername(moonbit_uv_tcp_t *tcp, struct sockaddr *addr) {
  int namelen = sizeof(struct sockaddr_storage);
  int result = uv_tcp_getpeername(&tcp->tcp, addr, &namelen);
  moonbit_decref(tcp);
  moonbit_decref(addr);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_close_reset(
  moonbit_uv_tcp_t *tcp,
  moonbit_uv_close_cb_t *close_cb
) {
  if (tcp->tcp.data) {
    moonbit_decref(tcp->tcp.data);
  }
  tcp->tcp.data = close_cb;

  int result = uv_tcp_close_reset(&tcp->tcp, moonbit_uv_close_cb);
  moonbit_decref(tcp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_simultaneous_accepts(moonbit_uv_tcp_t *tcp, bool enable) {
  int result = uv_tcp_simultaneous_accepts(&tcp->tcp, enable ? 1 : 0);
  moonbit_decref(tcp);
  return result;
}
