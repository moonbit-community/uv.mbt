#include "moonbit.h"
#include <netinet/in.h>
#include <stdlib.h>
#include <uv.h>

uv_loop_t *moonbit_uv_default_loop() { return uv_default_loop(); }

uv_loop_t *moonbit_uv_loop_alloc() { return malloc(sizeof(uv_loop_t)); };

void moonbit_uv_loop_free(uv_loop_t *loop) { free(loop); }

int moonbit_uv_loop_init(uv_loop_t *loop) { return uv_loop_init(loop); }

int moonbit_uv_loop_close(uv_loop_t *loop) { return uv_loop_close(loop); }

void moonbit_uv_stop(uv_loop_t *loop) { return uv_stop(loop); }

int moonbit_uv_run(uv_loop_t *loop, uv_run_mode mode) {
  return uv_run(loop, mode);
}

int moonbit_uv_loop_alive(uv_loop_t *loop) { return uv_loop_alive(loop); }

typedef struct moonbit_ffi_closure {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_ffi_closure *);
} moonbit_ffi_closure_t;

moonbit_ffi_closure_t *
moonbit_ffi_make_closure(int32_t (*code)(moonbit_ffi_closure_t *),
                         moonbit_ffi_closure_t *data) {
  return data;
}

typedef struct moonbit_uv_idle_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_idle_cb *, uv_idle_t *);
} moonbit_uv_idle_cb_t;

struct moonbit_uv_idle {
  uv_idle_t idle;
  moonbit_uv_idle_cb_t *cb;
};

uv_idle_t *moonbit_uv_idle_alloc() {
  return ((uv_idle_t *)malloc(sizeof(uv_idle_t)));
}

int moonbit_uv_idle_init(uv_loop_t *loop, uv_idle_t *idle) {
  return uv_idle_init(loop, idle);
}

void moonbit_uv_idle_cb(uv_idle_t *idle) {
  moonbit_uv_idle_cb_t *cb = idle->data;
  moonbit_incref(cb);
  cb->code(cb, idle);
}

int moonbit_uv_idle_start(uv_idle_t *idle, moonbit_uv_idle_cb_t *cb) {
  idle->data = cb;
  return uv_idle_start(idle, moonbit_uv_idle_cb);
}

int moonbit_uv_idle_stop(uv_idle_t *idle) { return uv_idle_stop(idle); }

void moonbit_uv_idle_free(uv_idle_t *idle) {
  if (idle->data) {
    moonbit_decref(idle->data);
  }
  free(idle);
}

uv_buf_t *moonbit_uv_buf_alloc() {
  return ((uv_buf_t *)malloc(sizeof(uv_buf_t)));
}

void moonbit_uv_buf_init(uv_buf_t *buf, moonbit_bytes_t bytes, size_t offset,
                         size_t length) {
  char *data = (char *)bytes;
  *buf = uv_buf_init(data + offset, length);
}

void moonbit_uv_buf_set_len(uv_buf_t *buf, size_t len) { buf->len = len; }

moonbit_bytes_t moonbit_uv_buf_get(uv_buf_t *buf) {
  return (moonbit_bytes_t)buf->base;
}

void moonbit_uv_buf_free(uv_buf_t *buf) { free(buf); }

static inline uv_buf_t *moonbit_uv__refs_to_bufs(uv_buf_t *refs[],
                                                 unsigned int size) {
  uv_buf_t *bufs = malloc(sizeof(uv_buf_t) * size);
  for (int i = 0; i < size; i++) {
    bufs[i] = *refs[i];
  }
  return bufs;
}

typedef struct moonbit_uv_fs_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_fs_cb *, uv_fs_t *);
} moonbit_uv_fs_cb_t;

static inline void moonbit_uv_fs_cb(uv_fs_t *req) {
  moonbit_uv_fs_cb_t *cb = req->data;
  moonbit_incref(cb);
  cb->code(cb, req);
}

uv_fs_t *moonbit_uv_fs_alloc() { return malloc(sizeof(uv_fs_t)); }

ssize_t moonbit_uv_fs_get_result(uv_fs_t *fs) { return fs->result; }

static inline const char *moonbit_uv__bytes_to_str(moonbit_bytes_t bytes) {
  int len = Moonbit_array_length(bytes);
  return strndup((char *)bytes, len);
}

int moonbit_uv_fs_open(uv_loop_t *loop, uv_fs_t *fs, moonbit_bytes_t path,
                       int flags, int mode, moonbit_uv_fs_cb_t *cb) {
  const char *path_str = moonbit_uv__bytes_to_str(path);
  fs->data = cb;
  return uv_fs_open(loop, fs, path_str, flags, mode, moonbit_uv_fs_cb);
}

int moonbit_uv_fs_close(uv_loop_t *loop, uv_fs_t *fs, uv_file file,
                        moonbit_uv_fs_cb_t *cb) {
  fs->data = cb;
  return uv_fs_close(loop, fs, file, moonbit_uv_fs_cb);
}

int moonbit_uv_fs_read(uv_loop_t *loop, uv_fs_t *fs, uv_file file,
                       uv_buf_t **bufs, int64_t offset,
                       moonbit_uv_fs_cb_t *cb) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  fs->data = cb;
  int rc =
      uv_fs_read(loop, fs, file, bufs_val, bufs_len, offset, moonbit_uv_fs_cb);
  free(bufs_val);
  return rc;
}

int moonbit_uv_fs_write(uv_loop_t *loop, uv_fs_t *fs, uv_file file,
                        uv_buf_t **bufs, int64_t offset,
                        moonbit_uv_fs_cb_t *cb) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  fs->data = cb;
  int rc =
      uv_fs_write(loop, fs, file, bufs_val, bufs_len, offset, moonbit_uv_fs_cb);
  free(bufs_val);
  return rc;
}

int moonbit_uv_accept(uv_stream_t *server, uv_stream_t *client) {
  return uv_accept(server, client);
}

typedef struct moonbit_uv_connection_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_connection_cb *, uv_stream_t *server,
                  int status);
} moonbit_uv_connection_cb_t;

void moonbit_uv_listen_cb(uv_stream_t *server, int status) {
  moonbit_uv_connection_cb_t *cb = server->data;
  moonbit_incref(cb);
  cb->code(cb, server, status);
}

int moonbit_uv_listen(uv_stream_t *stream, int backlog,
                      moonbit_uv_connection_cb_t *cb) {
  stream->data = cb;
  return uv_listen(stream, backlog, moonbit_uv_listen_cb);
}

typedef struct moonbit_uv_close_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_close_cb *, uv_handle_t *handle);
} moonbit_uv_close_cb_t;

static inline void moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_close_cb_t *cb = handle->data;
  moonbit_incref(cb);
  cb->code(cb, handle);
}

void moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  handle->data = close_cb;
  uv_close(handle, moonbit_uv_close_cb);
}

uv_loop_t *moonbit_uv_handle_get_loop(uv_handle_t *handle) {
  return handle->loop;
}

struct sockaddr_in *moonbit_uv_sockaddr_in_alloc() {
  return malloc(sizeof(struct sockaddr_in));
}

void moonbit_uv_ip4_addr(moonbit_bytes_t ip, int port,
                         struct sockaddr_in *addr) {
  const char *ip_str = moonbit_uv__bytes_to_str(ip);
  uv_ip4_addr(ip_str, port, addr);
}

uv_tcp_t *moonbit_uv_tcp_alloc() {
  return ((uv_tcp_t *)malloc(sizeof(uv_tcp_t)));
}

int moonbit_uv_tcp_init(uv_loop_t *loop, uv_tcp_t *tcp) {
  return uv_tcp_init(loop, tcp);
}

int moonbit_uv_tcp_bind(uv_tcp_t *tcp, const struct sockaddr *addr,
                        unsigned int flags) {
  return uv_tcp_bind(tcp, addr, flags);
}

typedef struct moonbit_uv_alloc_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_alloc_cb *, uv_handle_t *,
                  size_t suggested_size, uv_buf_t *buf);
} moonbit_uv_alloc_cb_t;

typedef struct moonbit_uv_read_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_read_cb *, uv_stream_t *, ssize_t nread,
                  const uv_buf_t *buf);
} moonbit_uv_read_cb_t;

typedef struct moonbit_uv_stream_cb {
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_read_cb_t *read_cb;
} moonbit_uv_read_start_cb_t;

static inline void moonbit_uv_read_start_alloc_cb(uv_handle_t *handle,
                                                  size_t suggested_size,
                                                  uv_buf_t *buf) {
  moonbit_uv_read_start_cb_t *stream_cb = handle->data;
  moonbit_uv_alloc_cb_t *alloc_cb = stream_cb->alloc_cb;
  moonbit_incref(alloc_cb);
  alloc_cb->code(alloc_cb, handle, suggested_size, buf);
}

static inline void moonbit_uv_read_start_read_cb(uv_stream_t *stream,
                                                 ssize_t nread,
                                                 const uv_buf_t *buf) {
  moonbit_uv_read_start_cb_t *stream_cb = stream->data;
  moonbit_uv_read_cb_t *read_cb = stream_cb->read_cb;
  moonbit_incref(read_cb);
  read_cb->code(read_cb, stream, nread, buf);
}

int moonbit_uv_read_start(uv_stream_t *stream, moonbit_uv_alloc_cb_t *alloc_cb,
                          moonbit_uv_read_cb_t *read_cb) {
  moonbit_uv_read_start_cb_t *cb = malloc(sizeof(moonbit_uv_read_start_cb_t));
  cb->read_cb = read_cb;
  cb->alloc_cb = alloc_cb;
  stream->data = cb;
  return uv_read_start(stream, moonbit_uv_read_start_alloc_cb,
                       moonbit_uv_read_start_read_cb);
}

int moonbit_uv_read_stop(uv_stream_t *stream) { return uv_read_stop(stream); }

uv_write_t *moonbit_uv_write_alloc() { return malloc(sizeof(uv_write_t)); }

typedef struct moonbit_uv_write_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_write_cb *, uv_write_t *req, int status);
} moonbit_uv_write_cb_t;

static inline void moonbit_uv_write_cb(uv_write_t *req, int status) {
  moonbit_uv_write_cb_t *moonbit_uv_cb = req->data;
  moonbit_incref(moonbit_uv_cb);
  moonbit_uv_cb->code(moonbit_uv_cb, req, status);
}

int moonbit_uv_write(uv_write_t *req, uv_stream_t *handle, uv_buf_t **bufs,
                     moonbit_uv_write_cb_t *cb) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  req->data = cb;
  return uv_write(req, handle, bufs_val, bufs_len, moonbit_uv_write_cb);
}

void moonbit_uv_strerror_r(int err, moonbit_bytes_t bytes) {
  size_t bytes_len = Moonbit_array_length(bytes);
  char *bytes_ptr = (char *)bytes;
  uv_strerror_r(err, bytes_ptr, bytes_len);
}

typedef struct moonbit_uv_timer_cb {
  struct moonbit_object header;
  int32_t (*code)(struct moonbit_uv_timer_cb *, uv_timer_t *timer);
} moonbit_uv_timer_cb_t;

uv_timer_t *moonbit_uv_timer_alloc() {
  return ((uv_timer_t *)malloc(sizeof(uv_timer_t)));
}

static inline void moonbit_uv_timer_cb(uv_timer_t *timer) {
  moonbit_uv_timer_cb_t *cb = timer->data;
  moonbit_incref(cb);
  cb->code(cb, timer);
}

int moonbit_uv_timer_start(uv_timer_t *handle, moonbit_uv_timer_cb_t *cb,
                           uint64_t timeout, uint64_t repeat) {
  handle->data = cb;
  return uv_timer_start(handle, moonbit_uv_timer_cb, timeout, repeat);
}
