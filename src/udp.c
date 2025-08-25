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

#include <stdlib.h>

#include "moonbit.h"
#include "uv#include#uv.h"
#include "uv.h"

#include "stream.h"

typedef struct moonbit_uv_udp_s {
  uv_udp_t udp;
} moonbit_uv_udp_t;

static inline void
moonbit_uv_udp_finalize(void *object) {
  moonbit_uv_udp_t *udp = (moonbit_uv_udp_t *)object;
  if (udp->udp.data) {
    moonbit_decref(udp->udp.data);
    udp->udp.data = NULL;
  }
  if (udp->udp.loop) {
    moonbit_decref(udp->udp.loop);
    udp->udp.loop = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_udp_t *
moonbit_uv_udp_make(void) {
  moonbit_uv_udp_t *udp = (moonbit_uv_udp_t *)moonbit_make_external_object(
    moonbit_uv_udp_finalize, sizeof(moonbit_uv_udp_t)
  );
  memset(udp, 0, sizeof(moonbit_uv_udp_t));
  return udp;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_init(uv_loop_t *loop, moonbit_uv_udp_t *udp) {
  return uv_udp_init(loop, &udp->udp);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_connect(moonbit_uv_udp_t *udp, struct sockaddr *addr) {
  int result = uv_udp_connect(&udp->udp, addr);
  moonbit_decref(addr);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_bind(
  moonbit_uv_udp_t *udp,
  struct sockaddr *addr,
  uint32_t flags
) {
  int result = uv_udp_bind(&udp->udp, addr, flags);
  moonbit_decref(addr);
  moonbit_decref(udp);
  return result;
}

typedef struct moonbit_uv_udp_send_s {
  uv_udp_send_t req;
} moonbit_uv_udp_send_t;

static inline void
moonbit_uv_udp_send_finalize(void *object) {
  moonbit_uv_udp_send_t *send = object;
  if (send->req.data) {
    moonbit_decref(send->req.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_udp_send_t *
moonbit_uv_udp_send_make(void) {
  moonbit_uv_udp_send_t *send =
    (moonbit_uv_udp_send_t *)moonbit_make_external_object(
      moonbit_uv_udp_send_finalize, sizeof(moonbit_uv_udp_send_t)
    );
  memset(send, 0, sizeof(moonbit_uv_udp_send_t));
  return send;
}

typedef struct moonbit_uv_udp_send_cb_s {
  int32_t (*code)(
    struct moonbit_uv_udp_send_cb_s *,
    moonbit_uv_udp_send_t *req,
    int status
  );
} moonbit_uv_udp_send_cb_t;

typedef struct moonbit_uv_udp_send_data_s {
  moonbit_uv_udp_send_cb_t *cb;
  moonbit_bytes_t *bufs;
} moonbit_uv_udp_send_data_t;

static inline void
moonbit_uv_udp_send_data_finalize(void *object) {
  moonbit_uv_udp_send_data_t *data = object;
  if (data->bufs) {
    moonbit_decref(data->bufs);
  }
  if (data->cb) {
    moonbit_decref(data->cb);
  }
}

static inline moonbit_uv_udp_send_data_t *
moonbit_uv_udp_send_data_make(void) {
  moonbit_uv_udp_send_data_t *send_data =
    (moonbit_uv_udp_send_data_t *)moonbit_make_external_object(
      moonbit_uv_udp_send_data_finalize, sizeof(moonbit_uv_udp_send_data_t)
    );
  memset(send_data, 0, sizeof(moonbit_uv_udp_send_data_t));
  return send_data;
}

static inline void
moonbit_uv_udp_send_cb(uv_udp_send_t *req, int status) {
  moonbit_uv_udp_send_data_t *data = req->data;
  moonbit_uv_udp_send_cb_t *cb = data->cb;
  data->cb = NULL;
  moonbit_uv_udp_send_t *send = containerof(req, moonbit_uv_udp_send_t, req);
  cb->code(cb, send, status);
}

static inline void
moonbit_uv_udp_send_set_data(
  moonbit_uv_udp_send_t *req,
  moonbit_uv_udp_send_data_t *data
) {
  if (req->req.data) {
    moonbit_decref(req->req.data);
  }
  req->req.data = data;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_send(
  moonbit_uv_udp_send_t *req,
  moonbit_uv_udp_t *udp,
  moonbit_bytes_t *bufs,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  struct sockaddr *addr,
  moonbit_uv_udp_send_cb_t *cb
) {
  int bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_udp_send_data_t *data = moonbit_uv_udp_send_data_make();
  data->bufs = bufs;
  data->cb = cb;
  moonbit_uv_udp_send_set_data(req, data);
  int result = uv_udp_send(
    &req->req, &udp->udp, bufs_data, bufs_size, addr, moonbit_uv_udp_send_cb
  );
  free(bufs_data);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  moonbit_decref(addr);
  moonbit_decref(udp);
  return result;
}

typedef struct moonbit_uv_udp_recv_cb {
  int32_t (*code)(
    struct moonbit_uv_udp_recv_cb *,
    uv_udp_t *udp,
    ssize_t nread,
    moonbit_bytes_t buf,
    int32_t buf_offset,
    int32_t buf_length,
    const struct sockaddr *addr,
    unsigned flags
  );
} moonbit_uv_udp_recv_cb_t;

typedef struct moonbit_uv_udp_data_s {
  moonbit_bytes_t bytes;
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_udp_recv_cb_t *read_cb;
} moonbit_uv_udp_data_t;

static inline void
moonbit_uv_udp_data_finalize(void *object) {
  moonbit_uv_tracef("object = %p\n", object);
  moonbit_uv_udp_data_t *data = object;
  if (data->bytes) {
    moonbit_decref(data->bytes);
  }
  if (data->read_cb) {
    moonbit_decref(data->read_cb);
  }
  if (data->alloc_cb) {
    moonbit_decref(data->alloc_cb);
  }
}

static inline moonbit_uv_udp_data_t *
moonbit_uv_udp_data_make(void) {
  moonbit_uv_udp_data_t *data =
    (moonbit_uv_udp_data_t *)moonbit_make_external_object(
      moonbit_uv_udp_data_finalize, sizeof(moonbit_uv_udp_data_t)
    );
  memset(data, 0, sizeof(moonbit_uv_udp_data_t));
  moonbit_uv_tracef("data = %p\n", (void *)data);
  return data;
}

static inline void
moonbit_uv_udp_set_data(uv_udp_t *udp, moonbit_uv_udp_data_t *data) {
  if (udp->data) {
    moonbit_decref(udp->data);
  }
  udp->data = data;
}

static inline void
moonbit_uv_udp_recv_start_alloc_cb(
  uv_handle_t *handle,
  size_t suggested_size,
  uv_buf_t *buf
) {
  moonbit_uv_udp_data_t *udp_data = handle->data;
  moonbit_uv_alloc_cb_t *alloc_cb = udp_data->alloc_cb;
  int32_t buf_offset = 0;
  int32_t buf_length = 0;
  moonbit_incref(alloc_cb);
  moonbit_incref(handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_bytes_t buf_base =
    alloc_cb->code(alloc_cb, handle, suggested_size, &buf_offset, &buf_length);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_tracef("buf_base = %p\n", (void *)buf_base);
  buf->base = (char *)buf_base + buf_offset;
  buf->len = buf_length;
  udp_data->bytes = buf_base;
}

static inline void
moonbit_uv_udp_recv_start_cb(
  uv_udp_t *udp,
  ssize_t nread,
  const uv_buf_t *buf,
  const struct sockaddr *addr,
  unsigned flags
) {
  moonbit_uv_tracef("udp = %p\n", (void *)udp);
  moonbit_uv_udp_data_t *udp_data = udp->data;
  moonbit_uv_udp_recv_cb_t *read_cb = udp_data->read_cb;
  moonbit_bytes_t buf_base = udp_data->bytes;
  udp_data->bytes = NULL;
  int32_t buf_offset = buf->base - (char *)buf_base;
  int32_t buf_length = buf->len;
  moonbit_incref(read_cb);
  moonbit_incref(udp);
  moonbit_uv_tracef("udp->rc (before) = %d\n", Moonbit_object_header(udp)->rc);
  void *addr_copied;
  if (addr->sa_family == AF_INET) {
    moonbit_uv_trace("addr->sa_family = AF_INET\n");
    addr_copied = moonbit_make_bytes(sizeof(struct sockaddr_in), 0);
  } else if (addr->sa_family == AF_INET6) {
    moonbit_uv_trace("addr->sa_family = AF_INET6\n");
    addr_copied = moonbit_make_bytes(sizeof(struct sockaddr_in6), 0);
  } else {
    moonbit_uv_tracef("addr->sa_family = %d\n", addr->sa_family);
    addr_copied = moonbit_make_bytes(sizeof(struct sockaddr), 0);
  }
  memcpy(addr_copied, addr, sizeof(struct sockaddr));
  read_cb->code(
    read_cb, udp, nread, buf_base, buf_offset, buf_length, addr_copied, flags
  );
  moonbit_uv_tracef("udp->rc (after ) = %d\n", Moonbit_object_header(udp)->rc);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_recv_start(
  uv_udp_t *udp,
  moonbit_uv_alloc_cb_t *alloc_cb,
  moonbit_uv_udp_recv_cb_t *read_cb
) {
  moonbit_uv_tracef("udp = %p\n", (void *)udp);
  moonbit_uv_tracef("udp->rc = %d\n", Moonbit_object_header(udp)->rc);
  moonbit_uv_udp_data_t *data = moonbit_uv_udp_data_make();
  data->read_cb = read_cb;
  data->alloc_cb = alloc_cb;
  moonbit_uv_udp_set_data(udp, data);
  // Move `udp` into `loop`. This helps `udp` remains valid when
  // `alloc_cb` or `recv_cb` is called.
  int32_t status = uv_udp_recv_start(
    udp, moonbit_uv_udp_recv_start_alloc_cb, moonbit_uv_udp_recv_start_cb
  );
  moonbit_decref(udp);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_recv_stop(uv_udp_t *udp) {
  moonbit_uv_tracef("udp = %p\n", (void *)udp);
  moonbit_uv_tracef("udp->rc = %d\n", Moonbit_object_header(udp)->rc);
  moonbit_uv_udp_set_data(udp, NULL);
  int32_t status = uv_udp_recv_stop(udp);
  moonbit_decref(udp);
  return status;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_UDP_RECVMMSG() {
  return UV_UDP_RECVMMSG;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_init_ex(uv_loop_t *loop, moonbit_uv_udp_t *udp, uint32_t flags) {
  return uv_udp_init_ex(loop, &udp->udp, flags);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_open(moonbit_uv_udp_t *udp, uv_os_sock_t sock) {
  int result = uv_udp_open(&udp->udp, sock);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_getpeername(moonbit_uv_udp_t *udp, struct sockaddr *name) {
  int namelen = sizeof(struct sockaddr_storage);
  int result = uv_udp_getpeername(&udp->udp, name, &namelen);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_getsockname(moonbit_uv_udp_t *udp, struct sockaddr *name) {
  int namelen = sizeof(struct sockaddr_storage);
  int result = uv_udp_getsockname(&udp->udp, name, &namelen);
  moonbit_decref(udp);
  moonbit_decref(name);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_membership(
  moonbit_uv_udp_t *udp,
  moonbit_bytes_t multicast_addr,
  moonbit_bytes_t interface_addr,
  int32_t membership
) {
  char *multicast_str = (char *)multicast_addr;
  char *interface_str = interface_addr ? (char *)interface_addr : NULL;
  int result =
    uv_udp_set_membership(&udp->udp, multicast_str, interface_str, membership);
  moonbit_decref(multicast_addr);
  if (interface_addr) {
    moonbit_decref(interface_addr);
  }
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_source_membership(
  moonbit_uv_udp_t *udp,
  moonbit_bytes_t multicast_addr,
  moonbit_bytes_t interface_addr,
  moonbit_bytes_t source_addr,
  int32_t membership
) {
  char *multicast_str = (char *)multicast_addr;
  char *interface_str = interface_addr ? (char *)interface_addr : NULL;
  char *source_str = (char *)source_addr;
  int result = uv_udp_set_source_membership(
    &udp->udp, multicast_str, interface_str, source_str, membership
  );
  moonbit_decref(multicast_addr);
  if (interface_addr) {
    moonbit_decref(interface_addr);
  }
  moonbit_decref(source_addr);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_multicast_loop(moonbit_uv_udp_t *udp, bool on) {
  int result = uv_udp_set_multicast_loop(&udp->udp, on ? 1 : 0);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_multicast_ttl(moonbit_uv_udp_t *udp, int32_t ttl) {
  int result = uv_udp_set_multicast_ttl(&udp->udp, ttl);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_multicast_interface(
  moonbit_uv_udp_t *udp,
  moonbit_bytes_t interface_addr
) {
  char *interface_str = (char *)interface_addr;
  int result = uv_udp_set_multicast_interface(&udp->udp, interface_str);
  moonbit_decref(interface_addr);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_broadcast(moonbit_uv_udp_t *udp, bool on) {
  int result = uv_udp_set_broadcast(&udp->udp, on ? 1 : 0);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_set_ttl(moonbit_uv_udp_t *udp, int32_t ttl) {
  int result = uv_udp_set_ttl(&udp->udp, ttl);
  moonbit_decref(udp);
  return result;
}
MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_try_send(
  moonbit_uv_udp_t *udp,
  moonbit_bytes_t *bufs,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  struct sockaddr *addr
) {
  int bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs[i] + bufs_offset[i], bufs_length[i]);
  }
  int result = uv_udp_try_send(&udp->udp, bufs_data, bufs_size, addr);
  free(bufs_data);
  moonbit_decref(bufs);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  if (addr) {
    moonbit_decref(addr);
  }
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_udp_using_recvmmsg(moonbit_uv_udp_t *udp) {
  int result = uv_udp_using_recvmmsg(&udp->udp);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_udp_get_send_queue_size(moonbit_uv_udp_t *udp) {
  size_t result = uv_udp_get_send_queue_size(&udp->udp);
  moonbit_decref(udp);
  return result;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_udp_get_send_queue_count(moonbit_uv_udp_t *udp) {
  size_t result = uv_udp_get_send_queue_count(&udp->udp);
  moonbit_decref(udp);
  return result;
}