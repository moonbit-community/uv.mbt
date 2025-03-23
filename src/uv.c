#include "uv.h"
#include "uv/unix.h"
#include <moonbit.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr) - offsetof(type, member)))

uv_loop_t *
moonbit_uv_default_loop(void) {
  return uv_default_loop();
}

uv_loop_t *
moonbit_uv_loop_alloc(void) {
  return (uv_loop_t *)moonbit_malloc(sizeof(uv_loop_t));
}

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
moonbit_uv_idle_alloc(void) {
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

typedef struct moonbit_uv_buf_s {
  void (*finalize)(void *self);
  uv_buf_t buf;
} moonbit_uv_buf_t;

static inline void
moonbit_uv_buf_finalize(void *object) {
  moonbit_uv_buf_t *buf = object;
  if (buf->buf.base) {
    moonbit_decref((void *)buf->buf.base);
  }
}

moonbit_uv_buf_t *
moonbit_uv_buf_alloc(void) {
  moonbit_uv_buf_t *buf = (moonbit_uv_buf_t *)moonbit_make_external_object(
    moonbit_uv_buf_finalize, sizeof(uv_buf_t)
  );
  memset(&buf->buf, 0, sizeof(uv_buf_t));
  return buf;
}

void
moonbit_uv_buf_init(
  moonbit_uv_buf_t *buf,
  moonbit_bytes_t bytes,
  size_t length
) {
  if (buf->buf.base) {
    moonbit_decref((void *)buf->buf.base);
  }
  buf->buf = uv_buf_init((char *)bytes, length);
  moonbit_decref(buf);
}

void
moonbit_uv_buf_set_len(moonbit_uv_buf_t *buf, size_t len) {
  buf->buf.len = len;
  moonbit_decref(buf);
}

moonbit_bytes_t
moonbit_uv_buf_get_base(moonbit_uv_buf_t *buf) {
  moonbit_bytes_t bytes = (moonbit_bytes_t)buf->buf.base;
  moonbit_incref((void *)bytes);
  moonbit_decref(buf);
  return bytes;
}

static inline uv_buf_t *
moonbit_uv_bufs_to_uv_bufs(moonbit_uv_buf_t **moonbit_uv_bufs, size_t size) {
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * size);
  for (size_t i = 0; i < size; i++) {
    bufs_data[i] = moonbit_uv_bufs[i]->buf;
    moonbit_incref(bufs_data[i].base);
  }
  moonbit_decref(moonbit_uv_bufs);
  return bufs_data;
}

typedef struct moonbit_uv_fs_s {
  void (*finalize)(void *self);
  uv_fs_t fs;
  uv_buf_t *bufs_data;
  size_t bufs_size;
} moonbit_uv_fs_t;

typedef struct moonbit_uv_fs_cb_s {
  int32_t (*code)(struct moonbit_uv_fs_cb_s *, moonbit_uv_fs_t *);
} moonbit_uv_fs_cb_t;

static inline void
moonbit_uv_fs_cb(uv_fs_t *req) {
  moonbit_uv_fs_t *fs = containerof(req, moonbit_uv_fs_t, fs);
  moonbit_uv_fs_cb_t *cb = fs->fs.data;
  fs->fs.data = NULL;
  cb->code(cb, fs);
}

static inline void
moonbit_uv_fs_finalize(void *object) {
  moonbit_uv_fs_t *fs = (moonbit_uv_fs_t *)object;
  if (fs->fs.data) {
    moonbit_decref(fs->fs.data);
  }
  if (fs->bufs_data) {
    for (size_t i = 0; i < fs->bufs_size; i++) {
      moonbit_decref(fs->bufs_data[i].base);
    }
    free(fs->bufs_data);
  }
}

moonbit_uv_fs_t *
moonbit_uv_fs_alloc(void) {
  moonbit_uv_fs_t *fs = (moonbit_uv_fs_t *)moonbit_make_external_object(
    moonbit_uv_fs_finalize, sizeof(struct {
      uv_fs_t fs;
      uv_buf_t *bufs_data;
      size_t bufs_size;
    })
  );
  memset(&fs->fs, 0, sizeof(uv_fs_t));
  fs->bufs_data = NULL;
  fs->bufs_size = 0;
  return fs;
}

ssize_t
moonbit_uv_fs_get_result(moonbit_uv_fs_t *fs) {
  ssize_t result = fs->fs.result;
  moonbit_decref(fs);
  return result;
}

static inline void
moonbit_uv_fs_set_data(moonbit_uv_fs_t *fs, moonbit_uv_fs_cb_t *cb) {
  if (fs->fs.data) {
    moonbit_decref(fs->fs.data);
  }
  fs->fs.data = cb;
}

static inline void
moonbit_uv_fs_set_bufs(moonbit_uv_fs_t *fs, uv_buf_t *bufs_data, size_t bufs_size) {
  if (fs->bufs_data) {
    for (size_t i = 0; i < fs->bufs_size; i++) {
      moonbit_decref(fs->bufs_data[i].base);
    }
    free(fs->bufs_data);
  }
  fs->bufs_data = bufs_data;
  fs->bufs_size = bufs_size;
}

enum moonbit_uv_fs_open_flag_t {
  MOONBIT_UV_FS_O_RDONLY = 0x0,
  MOONBIT_UV_FS_O_WRONLY = 0x1,
  MOONBIT_UV_FS_O_RDWR = 0x2,
};

int
moonbit_uv_fs_open(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int flags,
  int mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
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
  int result = uv_fs_open(
    loop, &fs->fs, (const char *)path, uv_flags, mode, moonbit_uv_fs_cb
  );
  moonbit_decref(loop);
  moonbit_decref(path);
  return result;
}

int
moonbit_uv_fs_close(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_file file,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int result = uv_fs_close(loop, &fs->fs, file, moonbit_uv_fs_cb);
  moonbit_decref(loop);
  return result;
}

int
moonbit_uv_fs_read(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_file file,
  moonbit_uv_buf_t **bufs,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  uint32_t bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = moonbit_uv_bufs_to_uv_bufs(bufs, bufs_size);
  // The ownership of `cb` is transferred into `fs`.
  moonbit_uv_fs_set_data(fs, cb);
  moonbit_uv_fs_set_bufs(fs, bufs_data, bufs_size);
  // The ownership of `fs` is transferred into `loop`.
  int rc = uv_fs_read(
    loop, &fs->fs, file, bufs_data, bufs_size, offset, moonbit_uv_fs_cb
  );
  moonbit_decref(loop);
  // No need to call `decref` on `cb` and `fs`, as it can be fused with
  // the incref that would happen before when we transfer their ownerships
  // and yield a no-op.
  return rc;
}

int
moonbit_uv_fs_write(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_file file,
  moonbit_uv_buf_t **bufs,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  uint32_t bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = moonbit_uv_bufs_to_uv_bufs(bufs, bufs_size);
  moonbit_uv_fs_set_data(fs, cb);
  moonbit_uv_fs_set_bufs(fs, bufs_data, bufs_size);
  int rc = uv_fs_write(
    loop, &fs->fs, file, bufs_data, bufs_size, offset, moonbit_uv_fs_cb
  );
  moonbit_decref(loop);
  return rc;
}

void
moonbit_uv_fs_req_cleanup(moonbit_uv_fs_t *fs) {
  uv_fs_req_cleanup(&fs->fs);
  moonbit_decref(fs);
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
moonbit_uv_sockaddr_in_alloc(void) {
  return moonbit_malloc(sizeof(struct sockaddr_in));
}

void
moonbit_uv_ip4_addr(moonbit_bytes_t ip, int port, struct sockaddr_in *addr) {
  uv_ip4_addr((const char *)ip, port, addr);
  moonbit_decref(addr);
}

uv_tcp_t *
moonbit_uv_tcp_alloc(void) {
  return ((uv_tcp_t *)malloc(sizeof(uv_tcp_t)));
}

int
moonbit_uv_tcp_init(uv_loop_t *loop, uv_tcp_t *tcp) {
  int result = uv_tcp_init(loop, tcp);
  moonbit_decref(loop);
  return result;
}

int
moonbit_uv_tcp_bind(uv_tcp_t *tcp, struct sockaddr *addr, unsigned int flags) {
  int result = uv_tcp_bind(tcp, addr, flags);
  moonbit_decref(addr);
  return result;
}

uv_connect_t *
moonbit_uv_connect_alloc(void) {
  uv_connect_t *connect = moonbit_malloc(sizeof(uv_connect_t));
  return connect;
}

typedef struct moonbit_uv_connect_cb_s {
  int32_t (*code)(
    struct moonbit_uv_connect_cb_s *,
    uv_connect_t *req,
    int status
  );
} moonbit_uv_connect_cb_t;

static inline void
moonbit_uv_connect_cb(uv_connect_t *req, int status) {
  moonbit_uv_connect_cb_t *cb = req->data;
  moonbit_incref(cb);
  cb->code(cb, req, status);
}

int
moonbit_uv_tcp_connect(
  uv_connect_t *connect,
  uv_tcp_t *tcp,
  struct sockaddr *addr,
  moonbit_uv_connection_cb_t *cb
) {
  connect->data = cb;
  int result = uv_tcp_connect(connect, tcp, addr, moonbit_uv_connect_cb);
  moonbit_decref(addr);
  return result;
}

typedef struct moonbit_uv_alloc_cb_s {
  int32_t (*code)(
    struct moonbit_uv_alloc_cb_s *,
    uv_handle_t *,
    size_t suggested_size,
    moonbit_uv_buf_t *buf
  );
} moonbit_uv_alloc_cb_t;

typedef struct moonbit_uv_read_cb {
  int32_t (*code)(
    struct moonbit_uv_read_cb *,
    uv_stream_t *,
    ssize_t nread,
    moonbit_uv_buf_t *buf
  );
} moonbit_uv_read_cb_t;

typedef struct moonbit_uv_read_start_cb_s {
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_read_cb_t *read_cb;
} moonbit_uv_read_start_cb_t;

static inline void
moonbit_uv_read_start_alloc_cb(
  uv_handle_t *handle,
  size_t suggested_size,
  uv_buf_t *buf
) {
  moonbit_uv_read_start_cb_t *read_start_cb = handle->data;
  moonbit_uv_alloc_cb_t *alloc_cb = read_start_cb->alloc_cb;
  moonbit_incref(alloc_cb);
  moonbit_uv_buf_t *moonbit_buf = moonbit_uv_buf_alloc();
  // Incref the buffer so it doesn't get garbage collected inside the callback.
  moonbit_incref(moonbit_buf);
  alloc_cb->code(alloc_cb, handle, suggested_size, moonbit_buf);
  // Incref the buffer as we are storing it in the uv_buf_t.
  moonbit_incref(moonbit_buf->buf.base);
  buf->base = moonbit_buf->buf.base;
  buf->len = moonbit_buf->buf.len;
  moonbit_decref(moonbit_buf);
}

static inline void
moonbit_uv_read_start_read_cb(
  uv_stream_t *stream,
  ssize_t nread,
  const uv_buf_t *buf
) {
  moonbit_uv_read_start_cb_t *read_start_cb = stream->data;
  moonbit_uv_read_cb_t *read_cb = read_start_cb->read_cb;
  moonbit_incref(read_cb);
  moonbit_uv_buf_t *moonbit_buf = moonbit_uv_buf_alloc();
  moonbit_buf->buf = *buf;
  // We moved the buffer into the callback so there is no need to incref nor
  // decref it.
  read_cb->code(read_cb, stream, nread, moonbit_buf);
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
  if (stream->data) {
    moonbit_uv_read_start_cb_t *cb = stream->data;
    moonbit_decref(cb->read_cb);
    moonbit_decref(cb->alloc_cb);
    free(cb);
    stream->data = NULL;
  }
  return uv_read_stop(stream);
}

typedef struct moonbit_uv_write_s {
  void (*finalize)(void *self);
  uv_write_t write;
  uv_buf_t *bufs_data;
  size_t bufs_size;
} moonbit_uv_write_t;

void
moonbit_uv_write_finalize(void *object) {
  moonbit_uv_write_t *write = object;
  if (write->write.data) {
    moonbit_decref(write->write.data);
  }
  if (write->bufs_data) {
    for (size_t i = 0; i < write->bufs_size; i++) {
      moonbit_decref(write->bufs_data[i].base);
    }
    free(write->bufs_data);
  }
}

moonbit_uv_write_t *
moonbit_uv_write_alloc(void) {
  moonbit_uv_write_t *write =
    (moonbit_uv_write_t *)moonbit_make_external_object(
      moonbit_uv_write_finalize, sizeof(struct { uv_write_t write; uv_buf_t *bufs_data; size_t bufs_size; })
    );
  memset(&write->write, 0, sizeof(uv_write_t));
  write->bufs_data = NULL;
  write->bufs_size = 0;
  return write;
}
typedef struct moonbit_uv_write_cb {
  int32_t (*code)(
    struct moonbit_uv_write_cb *,
    moonbit_uv_write_t *req,
    int status
  );
} moonbit_uv_write_cb_t;

static inline void
moonbit_uv_write_cb(uv_write_t *req, int status) {
  moonbit_uv_write_cb_t *moonbit_uv_cb = req->data;
  moonbit_uv_write_t *write = containerof(req, moonbit_uv_write_t, write);
  moonbit_uv_cb->code(moonbit_uv_cb, write, status);
}

static inline void
moonbit_uv_write_set_data(moonbit_uv_write_t *req, moonbit_uv_write_cb_t *cb) {
  if (req->write.data) {
    moonbit_decref(req->write.data);
  }
  req->write.data = cb;
}

static inline void
moonbit_uv_write_set_bufs(moonbit_uv_write_t *req, uv_buf_t *bufs_data, size_t bufs_size) {
  if (req->bufs_data) {
    for (size_t i = 0; i < req->bufs_size; i++) {
      moonbit_decref(req->bufs_data[i].base);
    }
    free(req->bufs_data);
  }
  req->bufs_data = bufs_data;
  req->bufs_size = bufs_size;
}

int
moonbit_uv_write(
  moonbit_uv_write_t *req,
  uv_stream_t *handle,
  moonbit_uv_buf_t **bufs,
  moonbit_uv_write_cb_t *cb
) {
  uint32_t bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = moonbit_uv_bufs_to_uv_bufs(bufs, bufs_size);
  moonbit_uv_write_set_data(req, cb);
  moonbit_uv_write_set_bufs(req, bufs_data, bufs_size);
  int result =
    uv_write(&req->write, handle, bufs_data, bufs_size, moonbit_uv_write_cb);
  return result;
}

void
moonbit_uv_strerror_r(int err, moonbit_bytes_t bytes) {
  size_t bytes_len = Moonbit_array_length(bytes);
  char *bytes_ptr = (char *)bytes;
  uv_strerror_r(err, bytes_ptr, bytes_len);
  moonbit_decref(bytes);
}

typedef struct moonbit_uv_timer_cb {
  int32_t (*code)(struct moonbit_uv_timer_cb *, uv_timer_t *timer);
} moonbit_uv_timer_cb_t;

uv_timer_t *
moonbit_uv_timer_alloc(void) {
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

static inline void
moonbit_uv_process_finalize(void *object) {
  moonbit_uv_process_t *process = object;
  if (process->process.data) {
    moonbit_decref(process->process.data);
  }
}

moonbit_uv_process_t *
moonbit_uv_process_alloc(void) {
  moonbit_uv_process_t *process =
    (moonbit_uv_process_t *)moonbit_make_external_object(
      moonbit_uv_process_finalize, sizeof(uv_process_t)
    );
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

static inline void
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
moonbit_uv_process_options_alloc(void) {
  moonbit_uv_process_options_t *options =
    (moonbit_uv_process_options_t *)moonbit_make_external_object(
      moonbit_uv_process_options_finalize, sizeof(uv_process_options_t)
    );
  memset(&options->options, 0, sizeof(uv_process_options_t));
  return options;
}

typedef struct moonbit_uv_exit_cb_s {
  int32_t (*code)(struct moonbit_uv_exit_cb_s *, uv_process_t *, int64_t, int);
} moonbit_uv_exit_cb_t;

static inline void
moonbit_uv_exit_cb(
  uv_process_t *process,
  int64_t exit_status,
  int term_signal
) {
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
moonbit_uv_stdio_container_alloc(void) {
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
  for (size_t i = 0; i < stdio_count; i++) {
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

uv_tty_t *
moonbit_uv_tty_alloc(void) {
  uv_tty_t *tty = (uv_tty_t *)moonbit_malloc(sizeof(uv_tty_t));
  memset(tty, 0, sizeof(uv_tty_t));
  return tty;
}

int
moonbit_uv_tty_init(uv_loop_t *loop, uv_tty_t *handle, uv_file fd) {
  int result = uv_tty_init(loop, handle, fd, 0);
  moonbit_decref(loop);
  moonbit_decref(handle);
  return result;
}

int
moonbit_uv_tty_set_mode(uv_tty_t *handle, uv_tty_mode_t mode) {
  int result = uv_tty_set_mode(handle, mode);
  moonbit_decref(handle);
  return result;
}
