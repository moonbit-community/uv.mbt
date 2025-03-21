#include "uv.h"
#include <moonbit.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>

uv_loop_t *
moonbit_uv_default_loop() {
  return uv_default_loop();
}

uv_loop_t *
moonbit_uv_loop_alloc() {
  return (uv_loop_t *)moonbit_malloc(sizeof(uv_loop_t));
};

int
moonbit_uv_loop_init(uv_loop_t *loop) {
  int rc = uv_loop_init(loop);
  moonbit_decref(loop);
  return rc;
}

int
moonbit_uv_loop_close(uv_loop_t *loop) {
  int rc = uv_loop_close(loop);
  moonbit_decref(loop);
  return rc;
}

void
moonbit_uv_stop(uv_loop_t *loop) {
  uv_stop(loop);
  moonbit_decref(loop);
}

int
moonbit_uv_run(uv_loop_t *loop, uv_run_mode mode) {
  int rc = uv_run(loop, mode);
  moonbit_decref(loop);
  return rc;
}

int
moonbit_uv_loop_alive(uv_loop_t *loop) {
  int alive = uv_loop_alive(loop);
  moonbit_decref(loop);
  return alive;
}

typedef struct moonbit_uv_idle_cb {
  int32_t (*code)(struct moonbit_uv_idle_cb *, uv_idle_t *);
} moonbit_uv_idle_cb_t;

uv_idle_t *
moonbit_uv_idle_alloc() {
  return moonbit_malloc(sizeof(uv_idle_t));
}

int
moonbit_uv_idle_init(uv_loop_t *loop, uv_idle_t *idle) {
  int rc = uv_idle_init(loop, idle);
  moonbit_decref(loop);
  moonbit_decref(idle);
  return rc;
}

void
moonbit_uv_idle_cb(uv_idle_t *idle) {
  moonbit_uv_idle_cb_t *cb = idle->data;
  moonbit_incref(cb);
  moonbit_incref(idle);
  cb->code(cb, idle);
}

int
moonbit_uv_idle_start(uv_idle_t *idle, moonbit_uv_idle_cb_t *cb) {
  idle->data = cb;
  int rc = uv_idle_start(idle, moonbit_uv_idle_cb);
  moonbit_decref(idle);
  return rc;
}

int
moonbit_uv_idle_stop(uv_idle_t *idle) {
  int rc = uv_idle_stop(idle);
  moonbit_decref(idle);
  return rc;
}

uv_buf_t *
moonbit_uv_buf_alloc() {
  return ((uv_buf_t *)malloc(sizeof(uv_buf_t)));
}

void
moonbit_uv_buf_init(
  uv_buf_t *buf,
  moonbit_bytes_t bytes,
  size_t offset,
  size_t length
) {
  char *data = (char *)bytes;
  *buf = uv_buf_init(data + offset, length);
}

void
moonbit_uv_buf_set_len(uv_buf_t *buf, size_t len) {
  buf->len = len;
}

moonbit_bytes_t
moonbit_uv_buf_get(uv_buf_t *buf) {
  return (moonbit_bytes_t)buf->base;
}

void
moonbit_uv_buf_free(uv_buf_t *buf) {
  free(buf);
}

static inline uv_buf_t *
moonbit_uv__refs_to_bufs(uv_buf_t *refs[], unsigned int size) {
  uv_buf_t *bufs = malloc(sizeof(uv_buf_t) * size);
  for (int i = 0; i < size; i++) {
    bufs[i] = *refs[i];
  }
  return bufs;
}

typedef struct moonbit_uv_fs_cb {
  int32_t (*code)(struct moonbit_uv_fs_cb *, uv_fs_t *);
} moonbit_uv_fs_cb_t;

static inline void
moonbit_uv_fs_cb(uv_fs_t *req) {
  moonbit_uv_fs_cb_t *cb = req->data;
  moonbit_incref(cb);
  cb->code(cb, req);
}

uv_fs_t *
moonbit_uv_fs_alloc() {
  return malloc(sizeof(uv_fs_t));
}

ssize_t
moonbit_uv_fs_get_result(uv_fs_t *fs) {
  return fs->result;
}

enum moonbit_uv_fs_open_flag_t {
  MOONBIT_UV_FS_O_RDONLY = 0x0,
  MOONBIT_UV_FS_O_WRONLY = 0x1,
  MOONBIT_UV_FS_O_RDWR = 0x2,
};

int
moonbit_uv_fs_open(
  uv_loop_t *loop,
  uv_fs_t *fs,
  moonbit_bytes_t path,
  int flags,
  int mode,
  moonbit_uv_fs_cb_t *cb
) {
  fs->data = cb;
  int uv_flags = 0;
  if (flags & MOONBIT_UV_FS_O_RDONLY) {
    uv_flags |= UV_FS_O_RDONLY;
  }
  if (flags & MOONBIT_UV_FS_O_WRONLY) {
    uv_flags |= UV_FS_O_WRONLY;
  }
  if (flags & MOONBIT_UV_FS_O_RDWR) {
    uv_flags |= UV_FS_O_RDWR;
  }
  return uv_fs_open(
    loop, fs, (const char *)path, uv_flags, mode, moonbit_uv_fs_cb
  );
}

int
moonbit_uv_fs_close(
  uv_loop_t *loop,
  uv_fs_t *fs,
  uv_file file,
  moonbit_uv_fs_cb_t *cb
) {
  fs->data = cb;
  return uv_fs_close(loop, fs, file, moonbit_uv_fs_cb);
}

int
moonbit_uv_fs_read(
  uv_loop_t *loop,
  uv_fs_t *fs,
  uv_file file,
  uv_buf_t **bufs,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  fs->data = cb;
  int rc =
    uv_fs_read(loop, fs, file, bufs_val, bufs_len, offset, moonbit_uv_fs_cb);
  free(bufs_val);
  return rc;
}

int
moonbit_uv_fs_write(
  uv_loop_t *loop,
  uv_fs_t *fs,
  uv_file file,
  uv_buf_t **bufs,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  fs->data = cb;
  int rc =
    uv_fs_write(loop, fs, file, bufs_val, bufs_len, offset, moonbit_uv_fs_cb);
  free(bufs_val);
  return rc;
}

int
moonbit_uv_accept(uv_stream_t *server, uv_stream_t *client) {
  return uv_accept(server, client);
}

typedef struct moonbit_uv_connection_cb {
  int32_t (*code)(
    struct moonbit_uv_connection_cb *,
    uv_stream_t *server,
    int status
  );
} moonbit_uv_connection_cb_t;

void
moonbit_uv_listen_cb(uv_stream_t *server, int status) {
  moonbit_uv_connection_cb_t *cb = server->data;
  moonbit_incref(cb);
  cb->code(cb, server, status);
}

int
moonbit_uv_listen(
  uv_stream_t *stream,
  int backlog,
  moonbit_uv_connection_cb_t *cb
) {
  stream->data = cb;
  return uv_listen(stream, backlog, moonbit_uv_listen_cb);
}

typedef struct moonbit_uv_close_cb {
  int32_t (*code)(struct moonbit_uv_close_cb *, uv_handle_t *handle);
} moonbit_uv_close_cb_t;

static inline void
moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_close_cb_t *cb = handle->data;
  moonbit_incref(cb);
  cb->code(cb, handle);
}

void
moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  handle->data = close_cb;
  uv_close(handle, moonbit_uv_close_cb);
}

uv_loop_t *
moonbit_uv_handle_get_loop(uv_handle_t *handle) {
  return handle->loop;
}

struct sockaddr_in *
moonbit_uv_sockaddr_in_alloc() {
  return malloc(sizeof(struct sockaddr_in));
}

void
moonbit_uv_ip4_addr(moonbit_bytes_t ip, int port, struct sockaddr_in *addr) {
  uv_ip4_addr((const char *)ip, port, addr);
}

uv_tcp_t *
moonbit_uv_tcp_alloc() {
  return ((uv_tcp_t *)malloc(sizeof(uv_tcp_t)));
}

int
moonbit_uv_tcp_init(uv_loop_t *loop, uv_tcp_t *tcp) {
  return uv_tcp_init(loop, tcp);
}

int
moonbit_uv_tcp_bind(
  uv_tcp_t *tcp,
  const struct sockaddr *addr,
  unsigned int flags
) {
  return uv_tcp_bind(tcp, addr, flags);
}

typedef struct moonbit_uv_alloc_cb {
  int32_t (*code)(
    struct moonbit_uv_alloc_cb *,
    uv_handle_t *,
    size_t suggested_size,
    uv_buf_t *buf
  );
} moonbit_uv_alloc_cb_t;

typedef struct moonbit_uv_read_cb {
  int32_t (*code)(
    struct moonbit_uv_read_cb *,
    uv_stream_t *,
    ssize_t nread,
    const uv_buf_t *buf
  );
} moonbit_uv_read_cb_t;

typedef struct moonbit_uv_stream_cb {
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_read_cb_t *read_cb;
} moonbit_uv_read_start_cb_t;

static inline void
moonbit_uv_read_start_alloc_cb(
  uv_handle_t *handle,
  size_t suggested_size,
  uv_buf_t *buf
) {
  moonbit_uv_read_start_cb_t *stream_cb = handle->data;
  moonbit_uv_alloc_cb_t *alloc_cb = stream_cb->alloc_cb;
  moonbit_incref(alloc_cb);
  alloc_cb->code(alloc_cb, handle, suggested_size, buf);
}

static inline void
moonbit_uv_read_start_read_cb(
  uv_stream_t *stream,
  ssize_t nread,
  const uv_buf_t *buf
) {
  moonbit_uv_read_start_cb_t *stream_cb = stream->data;
  moonbit_uv_read_cb_t *read_cb = stream_cb->read_cb;
  moonbit_incref(read_cb);
  read_cb->code(read_cb, stream, nread, buf);
}

int
moonbit_uv_read_start(
  uv_stream_t *stream,
  moonbit_uv_alloc_cb_t *alloc_cb,
  moonbit_uv_read_cb_t *read_cb
) {
  moonbit_uv_read_start_cb_t *cb = malloc(sizeof(moonbit_uv_read_start_cb_t));
  cb->read_cb = read_cb;
  cb->alloc_cb = alloc_cb;
  stream->data = cb;
  return uv_read_start(
    stream, moonbit_uv_read_start_alloc_cb, moonbit_uv_read_start_read_cb
  );
}

int
moonbit_uv_read_stop(uv_stream_t *stream) {
  return uv_read_stop(stream);
}

uv_write_t *
moonbit_uv_write_alloc() {
  return malloc(sizeof(uv_write_t));
}

typedef struct moonbit_uv_write_cb {
  int32_t (*code)(struct moonbit_uv_write_cb *, uv_write_t *req, int status);
} moonbit_uv_write_cb_t;

static inline void
moonbit_uv_write_cb(uv_write_t *req, int status) {
  moonbit_uv_write_cb_t *moonbit_uv_cb = req->data;
  moonbit_incref(moonbit_uv_cb);
  moonbit_uv_cb->code(moonbit_uv_cb, req, status);
}

int
moonbit_uv_write(
  uv_write_t *req,
  uv_stream_t *handle,
  uv_buf_t **bufs,
  moonbit_uv_write_cb_t *cb
) {
  uint32_t bufs_len = Moonbit_array_length(bufs);
  uv_buf_t *bufs_val = moonbit_uv__refs_to_bufs(bufs, bufs_len);
  req->data = cb;
  return uv_write(req, handle, bufs_val, bufs_len, moonbit_uv_write_cb);
}

void
moonbit_uv_strerror_r(int err, moonbit_bytes_t bytes) {
  size_t bytes_len = Moonbit_array_length(bytes);
  char *bytes_ptr = (char *)bytes;
  uv_strerror_r(err, bytes_ptr, bytes_len);
}

typedef struct moonbit_uv_timer_cb {
  int32_t (*code)(struct moonbit_uv_timer_cb *, uv_timer_t *timer);
} moonbit_uv_timer_cb_t;

uv_timer_t *
moonbit_uv_timer_alloc() {
  return ((uv_timer_t *)malloc(sizeof(uv_timer_t)));
}

static inline void
moonbit_uv_timer_cb(uv_timer_t *timer) {
  moonbit_uv_timer_cb_t *cb = timer->data;
  moonbit_incref(cb);
  cb->code(cb, timer);
}

int
moonbit_uv_timer_start(
  uv_timer_t *handle,
  moonbit_uv_timer_cb_t *cb,
  uint64_t timeout,
  uint64_t repeat
) {
  handle->data = cb;
  return uv_timer_start(handle, moonbit_uv_timer_cb, timeout, repeat);
}

typedef struct moonbit_uv_process_s {
  void (*finalize)(void *self);
  uv_process_t process;
} moonbit_uv_process_t;

void
moonbit_uv_process_finalize(void *object) {
  moonbit_uv_process_t *process = object;
  if (process->process.data) {
    moonbit_decref(process->process.data);
  }
}

moonbit_uv_process_t *
moonbit_uv_process_alloc() {
  moonbit_uv_process_t *process =
    (moonbit_uv_process_t *)moonbit_make_external_object(moonbit_uv_process_finalize, sizeof(uv_process_t));
  memset(&process->process, 0, sizeof(uv_process_t));
  return process;
}

int
moonbit_uv_process_get_pid(uv_process_t *process) {
  return process->pid;
}

typedef struct moonbit_uv_process_options_s {
  void (*finalize)(void *self);
  uv_process_options_t options;
} moonbit_uv_process_options_t;

void
moonbit_uv_process_options_finalize(void *object) {
  moonbit_uv_process_options_t *options = object;
  if (options->options.file) {
    moonbit_decref((void *)options->options.file);
  }
  if (options->options.cwd) {
    moonbit_decref((void *)options->options.cwd);
  }
  if (options->options.args) {
    moonbit_decref(options->options.args);
  }
  if (options->options.env) {
    moonbit_decref(options->options.env);
  }
}

moonbit_uv_process_options_t *
moonbit_uv_process_options_alloc() {
  moonbit_uv_process_options_t *options =
    (moonbit_uv_process_options_t *)moonbit_make_external_object(moonbit_uv_process_options_finalize, sizeof(uv_process_options_t));
  memset(&options->options, 0, sizeof(uv_process_options_t));
  return options;
}

typedef struct moonbit_uv_exit_cb_s {
  int32_t (*code)(struct moonbit_uv_exit_cb_s *, uv_process_t *, int64_t, int);
} moonbit_uv_exit_cb_t;

static inline void
moonbit_uv_exit_cb(uv_process_t *process, int64_t exit_status, int term_signal) {
  moonbit_uv_exit_cb_t *cb = process->data;
  moonbit_incref(cb);
  cb->code(cb, process, exit_status, term_signal);
}

void
moonbit_uv_process_options_set_file(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t file
) {
  if (options->options.file) {
    moonbit_decref((void *)options->options.file);
  }
  options->options.file = (char *)file;
  moonbit_decref(options);
}

void
moonbit_uv_process_options_set_args(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t *args
) {
  if (options->options.args) {
    moonbit_decref(options->options.args);
  }
  options->options.args = (char **)args;
  moonbit_decref(options);
}

void
moonbit_uv_process_options_set_env(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t *env
) {
  if (options->options.env) {
    moonbit_decref(options->options.env);
  }
  options->options.env = (char **)env;
  moonbit_decref(options);
}

void
moonbit_uv_process_options_set_cwd(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t cwd
) {
  if (options->options.cwd) {
    moonbit_decref((void *)options->options.cwd);
  }
  options->options.cwd = (char *)cwd;
  moonbit_decref(options);
}

void
moonbit_uv_process_options_set_flags(
  uv_process_options_t *options,
  unsigned int flags
) {
  options->flags |= flags;
  moonbit_decref(options);
}

uv_stdio_container_t *
moonbit_uv_stdio_container_alloc() {
  return malloc(sizeof(uv_stdio_container_t));
}

void
moonbit_uv_stdio_container_set_flags(
  uv_stdio_container_t *container,
  uv_stdio_flags flags
) {
  container->flags |= flags;
  moonbit_decref(container);
}

void
moonbit_uv_stdio_container_set_stream(
  uv_stdio_container_t *container,
  uv_stream_t *stream
) {
  container->data.stream = stream;
  moonbit_decref(container);
}

void
moonbit_uv_stdio_container_set_fd(uv_stdio_container_t *container, int fd) {
  container->data.fd = fd;
  moonbit_decref(container);
}

void
moonbit_uv_process_options_set_stdio(
  moonbit_uv_process_options_t *options,
  uv_stdio_container_t **stdio
) {
  size_t stdio_count = Moonbit_array_length(stdio);
  options->options.stdio_count = stdio_count;
  options->options.stdio = malloc(sizeof(uv_stdio_container_t) * stdio_count);
  for (int i = 0; i < stdio_count; i++) {
    options->options.stdio[i] = *stdio[i];
  }
  moonbit_decref(options);
  moonbit_decref(stdio);
}

int
moonbit_uv_spawn(
  uv_loop_t *loop,
  uv_process_t *process,
  moonbit_uv_process_options_t *options,
  moonbit_uv_exit_cb_t *exit_cb
) {
  options->options.exit_cb = moonbit_uv_exit_cb;
  int result = uv_spawn(loop, process, &options->options);
  process->data = exit_cb;
  moonbit_decref(loop);
  moonbit_decref(process);
  moonbit_decref(options);
  return result;
}
