/*
 * Copyright 2025 International Digital Economy Academy
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
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "userenv.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "dbghelp.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")
#else
#include <unistd.h>
#endif

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr) - offsetof(type, member)))

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

// 1. All pointers without annotation is borrow ()
// 2. It is OK to pass an owning pointer to a borrowed parameter
// 3. It is OK to pass a borrowed pointer to a borrowed parameter
// 4. When passing a borrowed pointer to an owning parameter, the
//    pointer should be incref'd.
// 5. When passing an owning pointer to an owning parameter, the
//    pointer should be incref'd or moved.
// 6. When the scope of an owning pointer ends, the pointer should be
//    decref'd.

MOONBIT_FFI_EXPORT
uv_loop_t *
moonbit_uv_default_loop(void) {
  return uv_default_loop();
}

MOONBIT_FFI_EXPORT
uv_loop_t *
moonbit_uv_loop_make(void) {
  uv_loop_t *loop = (uv_loop_t *)moonbit_make_bytes(sizeof(uv_loop_t), 0);
  memset(loop, 0, sizeof(uv_loop_t));
  return loop;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_init(uv_loop_t *loop) {
  int result = uv_loop_init(loop);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_close(uv_loop_t *loop) {
  int result = uv_loop_close(loop);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_stop(uv_loop_t *loop) {
  uv_stop(loop);
  moonbit_decref(loop);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_run(uv_loop_t *loop, uv_run_mode mode) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  int status = uv_run(loop, mode);
  moonbit_decref(loop);
  return status;
}

typedef struct moonbit_uv_walk_cb_s {
  int32_t (*code)(struct moonbit_uv_walk_cb_s *, uv_handle_t *);
} moonbit_uv_walk_cb_t;

static inline void
moonbit_uv_walk_cb(uv_handle_t *handle, void *arg) {
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_walk_cb_t *cb = arg;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(handle);
  cb->code(cb, handle);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_walk(uv_loop_t *loop, void *walk_cb) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("walk_cb = %p\n", walk_cb);
  moonbit_uv_tracef("walk_cb->rc = %d\n", Moonbit_object_header(walk_cb)->rc);
  uv_walk(loop, moonbit_uv_walk_cb, walk_cb);
  moonbit_decref(loop);
  moonbit_decref(walk_cb);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_alive(uv_loop_t *loop) {
  int alive = uv_loop_alive(loop);
  moonbit_decref(loop);
  return alive;
}

typedef struct moonbit_uv_idle_s {
  uv_idle_t idle;
} moonbit_uv_idle_t;

typedef struct moonbit_uv_idle_cb {
  int32_t (*code)(struct moonbit_uv_idle_cb *, moonbit_uv_idle_t *);
} moonbit_uv_idle_cb_t;

static inline void
moonbit_uv_idle_finalize(void *object) {
  moonbit_uv_idle_t *idle = (moonbit_uv_idle_t *)object;
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  moonbit_uv_tracef("idle->rc = %d\n", Moonbit_object_header(idle)->rc);
  if (idle->idle.loop) {
    moonbit_uv_tracef("idle->idle.loop = %p\n", (void *)idle->idle.loop);
    moonbit_uv_tracef(
      "idle->idle.loop->rc = %d\n", Moonbit_object_header(idle->idle.loop)->rc
    );
    moonbit_decref(idle->idle.loop);
    idle->idle.loop = NULL;
  }
  if (idle->idle.data) {
    moonbit_uv_tracef("idle->idle.data = %p\n", (void *)idle->idle.data);
    moonbit_uv_tracef(
      "idle->idle.data->rc = %d\n", Moonbit_object_header(idle->idle.data)->rc
    );
    moonbit_decref(idle->idle.data);
    idle->idle.data = NULL;
  }
}

static inline void
moonbit_uv_idle_set_data(moonbit_uv_idle_t *idle, void *data) {
  if (idle->idle.data) {
    moonbit_decref(idle->idle.data);
  }
  idle->idle.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_idle_t *
moonbit_uv_idle_make(void) {
  moonbit_uv_idle_t *idle = moonbit_make_external_object(
    moonbit_uv_idle_finalize, sizeof(moonbit_uv_idle_t)
  );
  memset(idle, 0, sizeof(moonbit_uv_idle_t));
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  return idle;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_init(uv_loop_t *loop, moonbit_uv_idle_t *idle) {
  return uv_idle_init(loop, &idle->idle);
}

static inline void
moonbit_uv_idle_cb(uv_idle_t *idle) {
  moonbit_uv_idle_t *moonbit_idle = containerof(idle, moonbit_uv_idle_t, idle);
  moonbit_uv_tracef("moonbit_idle = %p\n", (void *)moonbit_idle);
  moonbit_uv_tracef(
    "moonbit_idle->rc = %d\n", Moonbit_object_header(moonbit_idle)->rc
  );
  moonbit_uv_idle_cb_t *cb = moonbit_idle->idle.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_idle);
  cb->code(cb, moonbit_idle);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_start(moonbit_uv_idle_t *idle, moonbit_uv_idle_cb_t *cb) {
  moonbit_uv_idle_set_data(idle, cb);
  int status = uv_idle_start(&idle->idle, moonbit_uv_idle_cb);
  moonbit_decref(idle);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_stop(moonbit_uv_idle_t *idle) {
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  moonbit_uv_tracef("idle->rc = %d\n", Moonbit_object_header(idle)->rc);
  moonbit_uv_idle_set_data(idle, NULL);
  int status = uv_idle_stop(&idle->idle);
  moonbit_decref(idle);
  return status;
}

typedef struct moonbit_uv_fs_s {
  uv_fs_t fs;
  moonbit_bytes_t *bufs_base;
} moonbit_uv_fs_t;

typedef struct moonbit_uv_fs_cb_s {
  int32_t (*code)(struct moonbit_uv_fs_cb_s *, moonbit_uv_fs_t *);
} moonbit_uv_fs_cb_t;

static inline void
moonbit_uv_fs_cb(uv_fs_t *req) {
  moonbit_uv_fs_t *fs = containerof(req, moonbit_uv_fs_t, fs);
  moonbit_uv_fs_cb_t *cb = fs->fs.data;
  fs->fs.data = NULL;
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_uv_tracef("fs->fs.loop = %p\n", (void *)fs->fs.loop);
  moonbit_uv_tracef(
    "fs->fs.loop->rc = %d\n", Moonbit_object_header(fs->fs.loop)->rc
  );
  moonbit_uv_trace("calling cb ...\n");
  cb->code(cb, fs);
  moonbit_uv_trace("called  cb ...\n");
}

static inline void
moonbit_uv_fs_finalize(void *object) {
  moonbit_uv_fs_t *fs = (moonbit_uv_fs_t *)object;
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  if (fs->fs.loop) {
    moonbit_decref(fs->fs.loop);
    fs->fs.loop = NULL;
  }
  if (fs->fs.data) {
    moonbit_decref(fs->fs.data);
    fs->fs.data = NULL;
  }
  if (fs->bufs_base) {
    moonbit_decref(fs->bufs_base);
    fs->bufs_base = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_fs_t *
moonbit_uv_fs_make(void) {
  moonbit_uv_fs_t *fs = (moonbit_uv_fs_t *)moonbit_make_external_object(
    moonbit_uv_fs_finalize, sizeof(moonbit_uv_fs_t)
  );
  memset(fs, 0, sizeof(moonbit_uv_fs_t));
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  return fs;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_fs_req_cleanup(moonbit_uv_fs_t *fs) {
  uv_fs_req_cleanup(&fs->fs);
  moonbit_decref(fs);
}

MOONBIT_FFI_EXPORT
int64_t
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
moonbit_uv_fs_set_bufs(moonbit_uv_fs_t *fs, moonbit_bytes_t *bufs_base) {
  if (fs->bufs_base) {
    moonbit_decref(fs->bufs_base);
  }
  fs->bufs_base = bufs_base;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_RDONLY(void) {
  return UV_FS_O_RDONLY;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_WRONLY(void) {
  return UV_FS_O_WRONLY;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_RDWR(void) {
  return UV_FS_O_RDWR;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_CREAT(void) {
  return UV_FS_O_CREAT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_TRUNC(void) {
  return UV_FS_O_TRUNC;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_APPEND(void) {
  return UV_FS_O_APPEND;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_O_EXCL(void) {
  return UV_FS_O_EXCL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_open(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t flags,
  int32_t mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_uv_fs_set_data(fs, cb);
  int result = uv_fs_open(
    loop, &fs->fs, (const char *)path, flags, mode, moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_open_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t flags,
  int32_t mode
) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_fs_set_data(fs, NULL);
  int result = uv_fs_open(loop, &fs->fs, (const char *)path, flags, mode, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_close(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_uv_fs_set_data(fs, cb);
  int result = uv_fs_close(loop, &fs->fs, file, moonbit_uv_fs_cb);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_close_sync(uv_loop_t *loop, moonbit_uv_fs_t *fs, int32_t file) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  moonbit_uv_fs_set_data(fs, NULL);
  int result = uv_fs_close(loop, &fs->fs, file, NULL);
  moonbit_decref(fs);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_read(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_bytes_t *bufs_base,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  int bufs_size = Moonbit_array_length(bufs_base);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs_base[i] + bufs_offset[i], bufs_length[i]);
  }
  // The ownership of `cb` is transferred into `fs`.
  moonbit_uv_fs_set_data(fs, cb);
  // The ownership of `bufs_base` is transferred into `fs`.
  moonbit_uv_fs_set_bufs(fs, bufs_base);
  // The ownership of `fs` is transferred into `loop`.
  int result = uv_fs_read(
    loop, &fs->fs, file, bufs_data, bufs_size, offset, moonbit_uv_fs_cb
  );
  // Releasing `bufs` here, as it is only a box for the `bufs` array and should
  // not causing the `bufs` to be decref'd.
  free(bufs_data);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_read_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_bytes_t *bufs_base,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  int64_t offset
) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  int bufs_size = Moonbit_array_length(bufs_base);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs_base[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_fs_set_data(fs, NULL);
  moonbit_uv_fs_set_bufs(fs, NULL);
  int result =
    uv_fs_read(loop, &fs->fs, file, bufs_data, bufs_size, offset, NULL);
  free(bufs_data);
  moonbit_decref(fs);
  moonbit_decref(bufs_base);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_write(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_bytes_t *bufs_base,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  int bufs_size = Moonbit_array_length(bufs_base);
  moonbit_uv_tracef("bufs_size = %d\n", bufs_size);
  uv_buf_t *bufs = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs[i] =
      uv_buf_init((char *)bufs_base[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_fs_set_data(fs, cb);
  moonbit_uv_fs_set_bufs(fs, bufs_base);
  int result =
    uv_fs_write(loop, &fs->fs, file, bufs, bufs_size, offset, moonbit_uv_fs_cb);
  free(bufs);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_write_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_bytes_t *bufs_base,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  int64_t offset
) {
  int bufs_size = Moonbit_array_length(bufs_base);
  moonbit_uv_tracef("bufs_size = %d\n", bufs_size);
  uv_buf_t *bufs = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs[i] =
      uv_buf_init((char *)bufs_base[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_fs_set_data(fs, NULL);
  moonbit_uv_fs_set_bufs(fs, bufs_base);
  int result = uv_fs_write(loop, &fs->fs, file, bufs, bufs_size, offset, NULL);
  free(bufs);
  moonbit_decref(fs);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_ftruncate(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  int64_t offset,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_ftruncate(loop, &fs->fs, file, offset, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkdir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_mkdir(loop, &fs->fs, (const char *)path, mode, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkdir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_mkdir(loop, &fs->fs, (const char *)path, mode, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_rmdir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_rmdir(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_rmdir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_rmdir(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_COPYFILE_EXCL(void) {
  return UV_FS_COPYFILE_EXCL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_COPYFILE_FICLONE(void) {
  return UV_FS_COPYFILE_FICLONE;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_COPYFILE_FICLONE_FORCE(void) {
  return UV_FS_COPYFILE_FICLONE_FORCE;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_copyfile(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  int32_t flags,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_copyfile(
    loop, &fs->fs, (const char *)path, (const char *)new_path, flags,
    moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_copyfile_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  int32_t flags
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_copyfile(
    loop, &fs->fs, (const char *)path, (const char *)new_path, flags, NULL
  );
  moonbit_decref(fs);
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_unlink(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_unlink(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_unlink_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_unlink(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
uv_dirent_t *
moonbit_uv_dirent_make(int32_t length) {
  return malloc(sizeof(uv_dirent_t) * length);
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_dirent_get_name(uv_dirent_t *dirent, int32_t offset) {
  const char *name = dirent[offset].name;
  return name;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_dirent_get_type(uv_dirent_t *dirent, int32_t offset) {
  int32_t type = dirent[offset].type;
  return type;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_dirent_delete(uv_dirent_t *dirent) {
  free(dirent);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_scandir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t flags,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int result =
    uv_fs_scandir(loop, &fs->fs, (const char *)path, flags, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_scandir_next(moonbit_uv_fs_t *fs, uv_dirent_t *ent) {
  int status = uv_fs_scandir_next(&fs->fs, ent);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_scandir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t flags
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_scandir(loop, &fs->fs, (const char *)path, flags, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_rename(
  uv_loop_t *loop,
  moonbit_uv_fs_t *req,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(req, cb);
  int status = uv_fs_rename(
    loop, &req->fs, (const char *)path, (const char *)new_path, moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_rename_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *req,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path
) {
  moonbit_uv_fs_set_data(req, NULL);
  int status = uv_fs_rename(
    loop, &req->fs, (const char *)path, (const char *)new_path, NULL
  );
  moonbit_decref(req);
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
void *
moonbit_uv_fs_get_ptr(moonbit_uv_fs_t *fs) {
  void *ptr = fs->fs.ptr;
  moonbit_uv_tracef("ptr = %p\n", ptr);
  moonbit_decref(fs);
  return ptr;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFMT(void) {
  return S_IFMT;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFREG(void) {
  return S_IFREG;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFDIR(void) {
  return S_IFDIR;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFLNK(void) {
  return S_IFLNK;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFSOCK(void) {
#ifdef S_IFSOCK
  return S_IFSOCK;
#else
  return UINT64_MAX;
#endif
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFIFO(void) {
  return S_IFIFO;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFBLK(void) {
#ifdef S_IFBLK
  return S_IFBLK;
#else
  return UINT64_MAX;
#endif
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_fs_S_IFCHR(void) {
  return S_IFCHR;
}

MOONBIT_FFI_EXPORT
uv_stat_t *
moonbit_uv_fs_get_statbuf(moonbit_uv_fs_t *fs) {
  uv_stat_t *statbuf = (uv_stat_t *)moonbit_make_bytes(sizeof(uv_stat_t), 0);
  memcpy(statbuf, &fs->fs.statbuf, sizeof(uv_stat_t));
  moonbit_decref(fs);
  return statbuf;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_stat(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_stat(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_stat_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_stat(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_lstat(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_lstat(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fstat(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_fstat(loop, &fs->fs, file, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_realpath(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_realpath(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_realpath_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_realpath(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_F_OK(void) {
  return F_OK;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_R_OK(void) {
  return R_OK;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_W_OK(void) {
  return W_OK;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_X_OK(void) {
  return X_OK;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_access(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_access(loop, &fs->fs, (const char *)path, mode, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_access_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_access(loop, &fs->fs, (const char *)path, mode, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_fs_get_path(moonbit_uv_fs_t *fs) {
  const char *path = fs->fs.path;
  size_t length = strlen(path);
  moonbit_bytes_t bytes = moonbit_make_bytes(length, 0);
  for (size_t i = 0; i < length; i++) {
    bytes[i] = path[i];
  }
  moonbit_decref(fs);
  return bytes;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkdtemp(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t template_path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_mkdtemp(loop, &fs->fs, (const char *)template_path, moonbit_uv_fs_cb);
  moonbit_decref(template_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkdtemp_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t template_path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_mkdtemp(loop, &fs->fs, (const char *)template_path, NULL);
  moonbit_decref(fs);
  moonbit_decref(template_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkstemp(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t template_path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_mkstemp(loop, &fs->fs, (const char *)template_path, moonbit_uv_fs_cb);
  moonbit_decref(template_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_mkstemp_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t template_path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_mkstemp(loop, &fs->fs, (const char *)template_path, NULL);
  moonbit_decref(fs);
  moonbit_decref(template_path);
  return status;
}

MOONBIT_FFI_EXPORT
uv_dir_t *
moonbit_uv_fs_get_dir(moonbit_uv_fs_t *fs) {
  uv_dir_t *dir = fs->fs.ptr;
  dir->dirents = NULL;
  dir->nentries = 0;
  moonbit_uv_tracef("dir = %p\n", (void *)dir);
  moonbit_uv_tracef("dir->entries = %p\n", (void *)dir->dirents);
  moonbit_uv_tracef("dir->nentries = %lu\n", dir->nentries);
  moonbit_decref(fs);
  return dir;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_dir_set(uv_dir_t *dir, uv_dirent_t *dirents, int32_t nentries) {
  moonbit_uv_tracef("dir = %p\n", (void *)dir);
  moonbit_uv_tracef("dir->dirents = %p\n", (void *)dir->dirents);
  moonbit_uv_tracef("dir->nentries = %lu\n", dir->nentries);
  moonbit_uv_tracef("dirents = %p\n", (void *)dirents);
  moonbit_uv_tracef("nentries = %d\n", nentries);
  dir->dirents = dirents;
  dir->nentries = nentries;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_opendir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_opendir(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_opendir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_opendir(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_closedir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_dir_t *dir,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_closedir(loop, &fs->fs, dir, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_closedir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_dir_t *dir
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_closedir(loop, &fs->fs, dir, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_readdir(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_dir_t *dir,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("fs = %p\n", (void *)fs);
  moonbit_uv_tracef("fs->rc = %d\n", Moonbit_object_header(fs)->rc);
  moonbit_uv_tracef("dir = %p\n", (void *)dir);
  moonbit_uv_tracef("dir->entries = %p\n", (void *)dir->dirents);
  moonbit_uv_tracef("dir->nentries = %lu\n", dir->nentries);
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_readdir(loop, &fs->fs, dir, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_readdir_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  uv_dir_t *dir
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_readdir(loop, &fs->fs, dir, NULL);
  moonbit_decref(fs);
  return status;
}

typedef struct moonbit_uv_fs_event_s {
  uv_fs_event_t fs_event;
} moonbit_uv_fs_event_t;

static inline void
moonbit_uv_fs_event_finalize(void *object) {
  moonbit_uv_fs_event_t *fs_event = (moonbit_uv_fs_event_t *)object;
  moonbit_uv_tracef("fs_event = %p\n", (void *)fs_event);
  if (fs_event->fs_event.data) {
    moonbit_decref(fs_event->fs_event.data);
    fs_event->fs_event.data = NULL;
  }
  if (fs_event->fs_event.loop) {
    moonbit_uv_tracef("fs_event->loop = %p\n", (void *)fs_event->fs_event.loop);
    moonbit_decref(fs_event->fs_event.loop);
    fs_event->fs_event.loop = NULL;
  }
}

static inline void
moonbit_uv_fs_event_set_data(moonbit_uv_fs_event_t *fs_event, void *data) {
  if (fs_event->fs_event.data) {
    moonbit_decref(fs_event->fs_event.data);
  }
  fs_event->fs_event.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_fs_event_t *
moonbit_uv_fs_event_make(void) {
  moonbit_uv_fs_event_t *fs_event = moonbit_make_external_object(
    moonbit_uv_fs_event_finalize, sizeof(moonbit_uv_fs_event_t)
  );
  memset(fs_event, 0, sizeof(moonbit_uv_fs_event_t));
  return fs_event;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_init(uv_loop_t *loop, moonbit_uv_fs_event_t *handle) {
  return uv_fs_event_init(loop, &handle->fs_event);
}

typedef struct moonbit_uv_fs_event_cb_s {
  int32_t (*code)(
    struct moonbit_uv_fs_event_cb_s *,
    moonbit_uv_fs_event_t *handle,
    const char *filename,
    int32_t events,
    int32_t status
  );
} moonbit_uv_fs_event_cb_t;

static inline void
moonbit_uv_fs_event_cb(
  uv_fs_event_t *fs_event,
  const char *filename,
  int32_t events,
  int32_t status
) {
  moonbit_uv_fs_event_t *moonbit_fs_event =
    containerof(fs_event, moonbit_uv_fs_event_t, fs_event);
  moonbit_uv_fs_event_cb_t *cb = moonbit_fs_event->fs_event.data;
  moonbit_incref(cb);
  moonbit_incref(moonbit_fs_event);
  cb->code(cb, moonbit_fs_event, filename, events, status);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_start(
  moonbit_uv_fs_event_t *handle,
  moonbit_uv_fs_cb_t *cb,
  moonbit_bytes_t path,
  int32_t flags
) {
  moonbit_uv_fs_event_set_data(handle, cb);
  int status = uv_fs_event_start(
    &handle->fs_event, moonbit_uv_fs_event_cb, (const char *)path, flags
  );
  moonbit_decref(handle);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_stop(moonbit_uv_fs_event_t *handle) {
  int status = uv_fs_event_stop(&handle->fs_event);
  moonbit_decref(handle);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_accept(uv_stream_t *server, uv_stream_t *client) {
  int status = uv_accept(server, client);
  moonbit_decref(server);
  moonbit_decref(client);
  return status;
}

typedef struct moonbit_uv_connection_cb {
  int32_t (*code)(
    struct moonbit_uv_connection_cb *,
    uv_stream_t *server,
    int status
  );
} moonbit_uv_connection_cb_t;

static inline void
moonbit_uv_listen_cb(uv_stream_t *server, int status) {
  moonbit_uv_connection_cb_t *cb = server->data;
  moonbit_incref(cb);
  moonbit_incref(server);
  cb->code(cb, server, status);
  moonbit_uv_tracef("server->rc = %d\n", Moonbit_object_header(server)->rc);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_listen(
  uv_stream_t *stream,
  int32_t backlog,
  moonbit_uv_connection_cb_t *cb
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  stream->data = cb;
  int result = uv_listen(stream, backlog, moonbit_uv_listen_cb);
  moonbit_decref(stream);
  return result;
}

typedef struct moonbit_uv_close_cb {
  int32_t (*code)(struct moonbit_uv_close_cb *, uv_handle_t *handle);
} moonbit_uv_close_cb_t;

static inline void
moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_tracef("handle->type = %s\n", uv_handle_type_name(handle->type));
  moonbit_uv_tracef(
    "uv_has_ref(handle) = %s\n", uv_has_ref(handle) ? "true" : "false"
  );
  moonbit_uv_close_cb_t *cb = handle->data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  handle->data = NULL;
  moonbit_decref(handle);
  // The callback will be called only once, so there is no need to incref here.
  cb->code(cb, handle);
}

static inline void
moonbit_uv_handle_set_data(uv_handle_t *handle, void *cb) {
  if (handle->data) {
    moonbit_decref(handle->data);
  }
  handle->data = cb;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  moonbit_uv_tracef("cb = %p\n", (void *)close_cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(close_cb)->rc);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_handle_set_data(handle, close_cb);
  moonbit_uv_tracef("handle->type = %s\n", uv_handle_type_name(handle->type));
  moonbit_uv_tracef(
    "uv_has_ref(handle) = %s\n", uv_has_ref(handle) ? "true" : "false"
  );
  uv_close(handle, moonbit_uv_close_cb);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_is_closing(uv_handle_t *handle) {
  int32_t is_closing = uv_is_closing(handle);
  moonbit_decref(handle);
  return is_closing;
}

MOONBIT_FFI_EXPORT
uv_loop_t *
moonbit_uv_handle_loop(uv_handle_t *handle) {
  uv_loop_t *loop = handle->loop;
  moonbit_incref(loop);
  moonbit_decref(handle);
  return loop;
}

MOONBIT_FFI_EXPORT
struct sockaddr_in *
moonbit_uv_sockaddr_in_make(void) {
  return (struct sockaddr_in *)moonbit_make_bytes(
    sizeof(struct sockaddr_in), 0
  );
}

MOONBIT_FFI_EXPORT
struct sockaddr_in6 *
moonbit_uv_sockaddr_in6_make(void) {
  return (struct sockaddr_in6 *)moonbit_make_bytes(
    sizeof(struct sockaddr_in6), 0
  );
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_ip4_addr(
  moonbit_bytes_t ip,
  int32_t port,
  struct sockaddr_in *addr
) {
  return uv_ip4_addr((const char *)ip, port, addr);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_ip6_addr(
  moonbit_bytes_t ip,
  int32_t port,
  struct sockaddr_in6 *addr
) {
  return uv_ip6_addr((const char *)ip, port, addr);
}

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
uv_connect_t *
moonbit_uv_connect_make(void) {
  uv_connect_t *connect =
    (uv_connect_t *)moonbit_make_bytes(sizeof(uv_connect_t), 0);
  return connect;
}

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
  cb->code(cb, req, status);
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

typedef struct moonbit_uv_alloc_cb_s {
  moonbit_bytes_t (*code)(
    struct moonbit_uv_alloc_cb_s *,
    uv_handle_t *handle,
    size_t suggested_size,
    int32_t *buf_offset,
    int32_t *buf_length
  );
} moonbit_uv_alloc_cb_t;

typedef struct moonbit_uv_read_cb {
  int32_t (*code)(
    struct moonbit_uv_read_cb *,
    uv_stream_t *stream,
    ssize_t nread,
    moonbit_bytes_t buf,
    int32_t buf_offset,
    int32_t buf_length
  );
} moonbit_uv_read_cb_t;

typedef struct moonbit_uv_stream_data_s {
  moonbit_bytes_t bytes;
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_read_cb_t *read_cb;
} moonbit_uv_stream_data_t;

static inline void
moonbit_uv_stream_data_finalize(void *object) {
  moonbit_uv_tracef("object = %p\n", object);
  moonbit_uv_stream_data_t *data = object;
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

static inline moonbit_uv_stream_data_t *
moonbit_uv_stream_data_make(void) {
  moonbit_uv_stream_data_t *data =
    (moonbit_uv_stream_data_t *)moonbit_make_external_object(
      moonbit_uv_stream_data_finalize, sizeof(moonbit_uv_stream_data_t)
    );
  memset(data, 0, sizeof(moonbit_uv_stream_data_t));
  moonbit_uv_tracef("data = %p\n", (void *)data);
  return data;
}

static inline void
moonbit_uv_read_start_alloc_cb(
  uv_handle_t *handle,
  size_t suggested_size,
  uv_buf_t *buf
) {
  moonbit_uv_stream_data_t *stream_data = handle->data;
  handle->data = NULL;
  moonbit_uv_alloc_cb_t *alloc_cb = stream_data->alloc_cb;
  int32_t buf_offset = 0;
  int32_t buf_length = 0;
  moonbit_incref(alloc_cb);
  moonbit_incref(handle);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_bytes_t buf_base =
    alloc_cb->code(alloc_cb, handle, suggested_size, &buf_offset, &buf_length);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_tracef("handle->data = %p\n", handle->data);
  moonbit_uv_tracef("buf_base = %p\n", (void *)buf_base);
  buf->base = (char *)buf_base + buf_offset;
  buf->len = buf_length;
  stream_data->bytes = buf_base;
  moonbit_uv_handle_set_data(handle, stream_data);
}

static inline void
moonbit_uv_read_start_read_cb(
  uv_stream_t *stream,
  ssize_t nread,
  const uv_buf_t *buf
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_stream_data_t *stream_data = stream->data;
  moonbit_uv_read_cb_t *read_cb = stream_data->read_cb;
  moonbit_bytes_t buf_base = stream_data->bytes;
  stream_data->bytes = NULL;
  int32_t buf_offset = buf->base - (char *)buf_base;
  int32_t buf_length = buf->len;
  moonbit_incref(read_cb);
  moonbit_incref(stream);
  moonbit_uv_tracef(
    "stream->rc (before) = %d\n", Moonbit_object_header(stream)->rc
  );
  read_cb->code(read_cb, stream, nread, buf_base, buf_offset, buf_length);
  moonbit_uv_tracef(
    "stream->rc (after ) = %d\n", Moonbit_object_header(stream)->rc
  );
}

static inline void
moonbit_uv_stream_set_data(
  uv_stream_t *stream,
  moonbit_uv_stream_data_t *data
) {
  if (stream->data) {
    moonbit_decref(stream->data);
  }
  stream->data = data;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_read_start(
  uv_stream_t *stream,
  moonbit_uv_alloc_cb_t *alloc_cb,
  moonbit_uv_read_cb_t *read_cb
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  moonbit_uv_stream_data_t *data = moonbit_uv_stream_data_make();
  data->read_cb = read_cb;
  data->alloc_cb = alloc_cb;
  moonbit_uv_stream_set_data(stream, data);
  // Move `stream` into `loop`. This helps `stream` remains valid when
  // `alloc_cb` or `read_cb` is called.
  int32_t status = uv_read_start(
    stream, moonbit_uv_read_start_alloc_cb, moonbit_uv_read_start_read_cb
  );
  moonbit_decref(stream);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_read_stop(uv_stream_t *stream) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  moonbit_uv_stream_set_data(stream, NULL);
  int32_t status = uv_read_stop(stream);
  moonbit_decref(stream);
  return status;
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
int32_t
moonbit_uv_is_readable(uv_stream_t *stream) {
  return uv_is_readable(stream);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_is_writable(uv_stream_t *stream) {
  return uv_is_writable(stream);
}

typedef struct moonbit_uv_write_s {
  uv_write_t write;
} moonbit_uv_write_t;

static inline void
moonbit_uv_write_finalize(void *object) {
  moonbit_uv_write_t *write = object;
  if (write->write.data) {
    moonbit_decref(write->write.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_write_t *
moonbit_uv_write_make(void) {
  moonbit_uv_write_t *write =
    (moonbit_uv_write_t *)moonbit_make_external_object(
      moonbit_uv_write_finalize, sizeof(moonbit_uv_write_t)
    );
  memset(write, 0, sizeof(moonbit_uv_write_t));
  return write;
}

typedef struct moonbit_uv_write_cb {
  int32_t (*code)(
    struct moonbit_uv_write_cb *,
    moonbit_uv_write_t *req,
    int32_t status
  );
} moonbit_uv_write_cb_t;

typedef struct moonbit_uv_write_data_s {
  moonbit_uv_write_cb_t *cb;
  moonbit_bytes_t *bufs;
} moonbit_uv_write_data_t;

static inline void
moonbit_uv_write_cb(uv_write_t *req, int status) {
  moonbit_uv_write_data_t *data = req->data;
  moonbit_uv_write_cb_t *cb = data->cb;
  data->cb = NULL;
  moonbit_uv_write_t *write = containerof(req, moonbit_uv_write_t, write);
  cb->code(cb, write, status);
}

static inline void
moonbit_uv_write_data_finalize(void *object) {
  moonbit_uv_write_data_t *data = object;
  if (data->bufs) {
    moonbit_decref(data->bufs);
  }
  if (data->cb) {
    moonbit_decref(data->cb);
  }
}

static inline moonbit_uv_write_data_t *
moonbit_uv_write_data_make(void) {
  moonbit_uv_write_data_t *write_data =
    (moonbit_uv_write_data_t *)moonbit_make_external_object(
      moonbit_uv_write_data_finalize, sizeof(moonbit_uv_write_data_t)
    );
  memset(write_data, 0, sizeof(moonbit_uv_write_data_t));
  return write_data;
}

static inline void
moonbit_uv_write_set_data(
  moonbit_uv_write_t *req,
  moonbit_uv_write_data_t *data
) {
  if (req->write.data) {
    moonbit_decref(req->write.data);
  }
  req->write.data = data;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_write(
  moonbit_uv_write_t *req,
  uv_stream_t *handle,
  moonbit_bytes_t *bufs,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  moonbit_uv_write_cb_t *cb
) {
  int bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_write_data_t *data = moonbit_uv_write_data_make();
  data->bufs = bufs;
  data->cb = cb;
  moonbit_uv_write_set_data(req, data);
  int result =
    uv_write(&req->write, handle, bufs_data, bufs_size, moonbit_uv_write_cb);
  free(bufs_data);
  moonbit_decref(handle);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_strerror_r(int32_t err, moonbit_bytes_t bytes) {
  size_t bytes_len = Moonbit_array_length(bytes);
  char *bytes_ptr = (char *)bytes;
  uv_strerror_r(err, bytes_ptr, bytes_len);
  moonbit_decref(bytes);
}

typedef struct moonbit_uv_timer_cb {
  int32_t (*code)(struct moonbit_uv_timer_cb *, uv_timer_t *timer);
} moonbit_uv_timer_cb_t;

typedef struct moonbit_uv_timer_s {
  uv_timer_t timer;
} moonbit_uv_timer_t;

static inline void
moonbit_uv_timer_finalize(void *object) {
  moonbit_uv_timer_t *timer = (moonbit_uv_timer_t *)object;
  moonbit_decref(timer->timer.loop);
  if (timer->timer.data) {
    moonbit_decref(timer->timer.data);
  }
}

static inline void
moonbit_uv_timer_set_data(moonbit_uv_timer_t *timer, void *data) {
  if (timer->timer.data) {
    moonbit_decref(timer->timer.data);
  }
  timer->timer.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_timer_t *
moonbit_uv_timer_make(void) {
  moonbit_uv_timer_t *timer =
    (moonbit_uv_timer_t *)moonbit_make_external_object(
      moonbit_uv_timer_finalize, sizeof(moonbit_uv_timer_t)
    );
  memset(timer, 0, sizeof(moonbit_uv_timer_t));
  return timer;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_init(uv_loop_t *loop, moonbit_uv_timer_t *timer) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("timer = %p\n", (void *)timer);
  return uv_timer_init(loop, &timer->timer);
}

static inline void
moonbit_uv_timer_cb(uv_timer_t *timer) {
  moonbit_uv_timer_cb_t *cb = timer->data;
  moonbit_incref(cb);
  moonbit_incref(timer);
  cb->code(cb, timer);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_start(
  moonbit_uv_timer_t *timer,
  moonbit_uv_timer_cb_t *cb,
  uint64_t timeout,
  uint64_t repeat
) {
  moonbit_uv_tracef("timer = %p\n", (void *)timer);
  moonbit_uv_tracef("timer->rc = %d\n", Moonbit_object_header(timer)->rc);
  moonbit_uv_timer_set_data(timer, cb);
  int result =
    uv_timer_start(&timer->timer, moonbit_uv_timer_cb, timeout, repeat);
  moonbit_decref(timer);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_stop(moonbit_uv_timer_t *timer) {
  moonbit_uv_timer_set_data(timer, NULL);
  int status = uv_timer_stop(&timer->timer);
  moonbit_decref(timer);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_timer_set_repeat(moonbit_uv_timer_t *timer, uint64_t repeat) {
  uv_timer_set_repeat(&timer->timer, repeat);
  moonbit_decref(timer);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_timer_get_repeat(moonbit_uv_timer_t *timer) {
  uint64_t repeat = uv_timer_get_repeat(&timer->timer);
  moonbit_decref(timer);
  return repeat;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_timer_get_due_in(moonbit_uv_timer_t *timer) {
  uint64_t due_in = uv_timer_get_due_in(&timer->timer);
  moonbit_decref(timer);
  return due_in;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_disable_stdio_inheritance(void) {
  uv_disable_stdio_inheritance();
}

typedef struct moonbit_uv_process_s {
  uv_process_t process;
} moonbit_uv_process_t;

static inline void
moonbit_uv_process_finalize(void *object) {
  moonbit_uv_process_t *process = object;
  if (process->process.data) {
    moonbit_decref(process->process.data);
    process->process.data = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_process_t *
moonbit_uv_process_make(void) {
  moonbit_uv_process_t *process =
    (moonbit_uv_process_t *)moonbit_make_external_object(
      moonbit_uv_process_finalize, sizeof(moonbit_uv_process_t)
    );
  moonbit_uv_tracef("process = %p\n", (void *)process);
  memset(process, 0, sizeof(moonbit_uv_process_t));
  return process;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_process_get_pid(moonbit_uv_process_t *process) {
  int pid = process->process.pid;
  moonbit_decref(process);
  return pid;
}

typedef struct moonbit_uv_exit_cb_s {
  int32_t (*code)(
    struct moonbit_uv_exit_cb_s *,
    moonbit_uv_process_t *,
    int64_t,
    int
  );
} moonbit_uv_exit_cb_t;

static inline void
moonbit_uv_exit_cb(
  uv_process_t *process,
  int64_t exit_status,
  int term_signal
) {
  moonbit_uv_tracef("process = %p\n", (void *)process);
  moonbit_uv_process_t *moonbit_process =
    containerof(process, moonbit_uv_process_t, process);
  if (process->data) {
    moonbit_uv_exit_cb_t *cb = process->data;
    process->data = NULL;
    moonbit_incref(moonbit_process);
    cb->code(cb, moonbit_process, exit_status, term_signal);
  } else {
    moonbit_decref(moonbit_process);
  }
}

typedef struct moonbit_uv_stdio_container_s {
  uv_stdio_container_t container;
} moonbit_uv_stdio_container_t;

static inline void
moonbit_uv_stdio_container_finalize(void *object) {
  moonbit_uv_stdio_container_t *container =
    (moonbit_uv_stdio_container_t *)object;
  if (container->container.data.stream) {
    moonbit_decref(container->container.data.stream);
  }
}

static inline moonbit_uv_stdio_container_t *
moonbit_uv_stdio_container_make(void) {
  moonbit_uv_stdio_container_t *container =
    (moonbit_uv_stdio_container_t *)moonbit_make_external_object(
      moonbit_uv_stdio_container_finalize, sizeof(moonbit_uv_stdio_container_t)
    );
  memset(container, 0, sizeof(moonbit_uv_stdio_container_t));
  return container;
}

MOONBIT_FFI_EXPORT
moonbit_uv_stdio_container_t *
moonbit_uv_stdio_container_ignore(void) {
  moonbit_uv_stdio_container_t *container = moonbit_uv_stdio_container_make();
  container->container.flags = UV_IGNORE;
  return container;
}

MOONBIT_FFI_EXPORT
moonbit_uv_stdio_container_t *
moonbit_uv_stdio_container_create_pipe(
  uv_stream_t *stream,
  int32_t readable,
  int32_t writable,
  int32_t non_block
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_stdio_container_t *container = moonbit_uv_stdio_container_make();
  container->container.flags = UV_CREATE_PIPE;
  if (readable) {
    container->container.flags |= UV_READABLE_PIPE;
  }
  if (writable) {
    container->container.flags |= UV_WRITABLE_PIPE;
  }
  if (non_block) {
    container->container.flags |= UV_NONBLOCK_PIPE;
  }
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  container->container.data.stream = stream;
  return container;
}

MOONBIT_FFI_EXPORT
moonbit_uv_stdio_container_t *
moonbit_uv_stdio_container_inherit_fd(int32_t fd) {
  moonbit_uv_stdio_container_t *container = moonbit_uv_stdio_container_make();
  container->container.flags = UV_INHERIT_FD;
  container->container.data.fd = fd;
  return container;
}

MOONBIT_FFI_EXPORT
moonbit_uv_stdio_container_t *
moonbit_uv_stdio_container_inherit_stream(uv_stream_t *stream) {
  moonbit_uv_stdio_container_t *container = moonbit_uv_stdio_container_make();
  container->container.flags = UV_INHERIT_STREAM;
  container->container.data.stream = stream;
  return container;
}

typedef struct moonbit_uv_process_options_s {
  uv_process_options_t options;
} moonbit_uv_process_options_t;

static inline void
moonbit_uv_process_options_finalize(void *object) {
  moonbit_uv_process_options_t *options =
    (moonbit_uv_process_options_t *)object;
  if (options->options.exit_cb) {
    moonbit_decref((moonbit_uv_exit_cb_t *)options->options.exit_cb);
    options->options.exit_cb = NULL;
  }
  if (options->options.file) {
    moonbit_decref((void *)options->options.file);
    options->options.file = NULL;
  }
  if (options->options.args) {
    moonbit_decref(options->options.args);
    options->options.args = NULL;
  }
  if (options->options.env) {
    moonbit_decref(options->options.env);
    options->options.env = NULL;
  }
  if (options->options.cwd) {
    moonbit_decref((void *)options->options.cwd);
    options->options.cwd = NULL;
  }
  if (options->options.stdio) {
    for (int i = 0; i < options->options.stdio_count; i++) {
      uv_stdio_flags flags = options->options.stdio[i].flags;
      moonbit_uv_tracef("stdio[%d].flags = %d\n", i, flags);
      if (flags & (UV_INHERIT_STREAM | UV_CREATE_PIPE)) {
        moonbit_uv_tracef(
          "stdio[%d].stream = %p\n", i,
          (void *)options->options.stdio[i].data.stream
        );
        moonbit_uv_tracef(
          "stdio[%d].stream->rc = %d\n", i,
          Moonbit_object_header(options->options.stdio[i].data.stream)->rc
        );
        moonbit_decref(options->options.stdio[i].data.stream);
      }
    }
    free(options->options.stdio);
    options->options.stdio = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_process_options_t *
moonbit_uv_process_options_make(void) {
  moonbit_uv_process_options_t *options =
    (moonbit_uv_process_options_t *)moonbit_make_external_object(
      moonbit_uv_process_options_finalize, sizeof(moonbit_uv_process_options_t)
    );
  memset(options, 0, sizeof(moonbit_uv_process_options_t));
  return options;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_exit_cb(
  moonbit_uv_process_options_t *options,
  moonbit_uv_exit_cb_t *exit_cb
) {
  if (options->options.exit_cb) {
    moonbit_decref((moonbit_uv_exit_cb_t *)options->options.exit_cb);
  }
  options->options.exit_cb = (uv_exit_cb)exit_cb;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_file(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t file
) {
  if (options->options.file) {
    moonbit_decref((void *)options->options.file);
  }
  options->options.file = (const char *)file;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
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

MOONBIT_FFI_EXPORT
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

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_cwd(
  moonbit_uv_process_options_t *options,
  moonbit_bytes_t cwd
) {
  if (options->options.cwd) {
    moonbit_decref((void *)options->options.cwd);
  }
  options->options.cwd = (const char *)cwd;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_flags(
  moonbit_uv_process_options_t *options,
  uint32_t flags
) {
  options->options.flags = flags;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_stdio(
  moonbit_uv_process_options_t *options,
  moonbit_uv_stdio_container_t **stdio
) {
  if (options->options.stdio) {
    free(options->options.stdio);
  }
  options->options.stdio_count = Moonbit_array_length(stdio);
  moonbit_uv_tracef("stdio_count = %d\n", options->options.stdio_count);
  options->options.stdio =
    malloc(sizeof(uv_stdio_container_t) * (size_t)options->options.stdio_count);
  for (int i = 0; i < options->options.stdio_count; i++) {
    // We move the ownership of possible `stream` inside the container to
    // `options.stdio[i]`.
    options->options.stdio[i] = stdio[i]->container;
    memset(&stdio[i]->container, 0, sizeof(uv_stdio_container_t));
  }
  moonbit_decref(stdio);
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_uid(
  moonbit_uv_process_options_t *options,
  uv_uid_t uid
) {
  options->options.uid = uid;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_process_options_set_gid(
  moonbit_uv_process_options_t *options,
  uv_gid_t gid
) {
  options->options.gid = gid;
  moonbit_decref(options);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_spawn(
  uv_loop_t *loop,
  moonbit_uv_process_t *process,
  moonbit_uv_process_options_t *options
) {
  moonbit_uv_tracef("process = %p\n", (void *)process);
  moonbit_uv_tracef("process->rc = %d\n", Moonbit_object_header(process)->rc);
  if (options->options.exit_cb) {
    if (process->process.data) {
      moonbit_decref((moonbit_uv_exit_cb_t *)process->process.data);
    }
    process->process.data = (void *)options->options.exit_cb;
  }
  options->options.exit_cb = moonbit_uv_exit_cb;
  int result = uv_spawn(loop, &process->process, &options->options);
  // The ownership of `options` is transferred into `loop`.
  // We need to set the `exit_cb` to NULL so it doesn't get decref'd.
  options->options.exit_cb = NULL;
  moonbit_decref(loop);
  moonbit_decref(options);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_process_kill(moonbit_uv_process_t *process, int32_t signum) {
  int result = uv_process_kill(&process->process, signum);
  moonbit_decref(process);
  return result;
}

MOONBIT_FFI_EXPORT
uv_tty_t *
moonbit_uv_tty_make(void) {
  uv_tty_t *tty = (uv_tty_t *)moonbit_make_bytes(sizeof(uv_tty_t), 0);
  memset(tty, 0, sizeof(uv_tty_t));
  return tty;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_init(uv_loop_t *loop, uv_tty_t *handle, int32_t fd) {
  int result = uv_tty_init(loop, handle, fd, 0);
  moonbit_decref(loop);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_set_mode(uv_tty_t *handle, uv_tty_mode_t mode) {
  int result = uv_tty_set_mode(handle, mode);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_reset_mode(void) {
  int result = uv_tty_reset_mode();
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_get_winsize(uv_tty_t *handle, int32_t *width, int32_t *height) {
  int status = uv_tty_get_winsize(handle, width, height);
  moonbit_decref(handle);
  moonbit_decref(width);
  moonbit_decref(height);
  return status;
}

MOONBIT_FFI_EXPORT
uv_pipe_t *
moonbit_uv_pipe_make(void) {
  uv_pipe_t *pipe = (uv_pipe_t *)moonbit_make_bytes(sizeof(uv_pipe_t), 0);
  memset(pipe, 0, sizeof(uv_pipe_t));
  moonbit_uv_tracef("pipe = %p\n", (void *)pipe);
  return pipe;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_init(uv_loop_t *loop, uv_pipe_t *handle, int32_t ipc) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("pipe = %p\n", (void *)handle);
  moonbit_uv_tracef("pipe->rc = %d\n", Moonbit_object_header(handle)->rc);
  int32_t status = uv_pipe_init(loop, handle, ipc);
  moonbit_decref(loop);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_open(uv_pipe_t *handle, int32_t fd) {
  int result = uv_pipe_open(handle, fd);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_bind(uv_pipe_t *handle, moonbit_bytes_t name, uint32_t flags) {
  size_t name_length = Moonbit_array_length(name);
  int result = uv_pipe_bind2(handle, (const char *)name, name_length, flags);
  moonbit_decref(handle);
  moonbit_decref(name);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe(int32_t *fds, int32_t read_flags, int32_t write_flags) {
  int status = uv_pipe(fds, read_flags, write_flags);
  moonbit_decref(fds);
  return status;
}

#define XX(code, _)                                                            \
  MOONBIT_FFI_EXPORT                                                           \
  int32_t moonbit_uv_##code(void) { return UV_##code; }
UV_ERRNO_MAP(XX)
#undef XX

typedef struct moonbit_uv_work_cb_s {
  int32_t (*code)(struct moonbit_uv_work_cb_s *, uv_work_t *req);
} moonbit_uv_work_cb_t;

typedef struct moonbit_uv_after_work_cb_s {
  int32_t (*code)(
    struct moonbit_uv_after_work_cb_s *,
    uv_work_t *req,
    int status
  );
} moonbit_uv_after_work_cb_t;

typedef struct moonbit_uv_work_data_s {
  moonbit_uv_work_cb_t *work_cb;
  moonbit_uv_after_work_cb_t *after_cb;
} moonbit_uv_work_data_t;

static inline void
moonbit_uv_work_data_finalize(void *object) {
  moonbit_uv_work_data_t *data = object;
  if (data->work_cb) {
    moonbit_decref(data->work_cb);
  }
  if (data->after_cb) {
    moonbit_decref(data->after_cb);
  }
}

static inline moonbit_uv_work_data_t *
moonbit_uv_work_data_make(void) {
  moonbit_uv_work_data_t *data = moonbit_make_external_object(
    moonbit_uv_work_data_finalize, sizeof(moonbit_uv_work_data_t)
  );
  memset(data, 0, sizeof(moonbit_uv_work_data_t));
  return data;
}

static inline void
moonbit_uv_work_cb(uv_work_t *req) {
  moonbit_uv_work_data_t *data = req->data;
  moonbit_uv_work_cb_t *cb = data->work_cb;
  data->work_cb = NULL;
  moonbit_incref(req);
  cb->code(cb, req);
}

static inline void
moonbit_uv_after_work_cb(uv_work_t *req, int status) {
  moonbit_uv_work_data_t *data = req->data;
  moonbit_uv_after_work_cb_t *cb = data->after_cb;
  data->after_cb = NULL;
  cb->code(cb, req, status);
}

static inline void
moonbit_uv_work_finalize(void *object) {
  uv_work_t *work = object;
  if (work->loop) {
    moonbit_decref(work->loop);
  }
  if (work->data) {
    moonbit_decref(work->data);
  }
}

MOONBIT_FFI_EXPORT
uv_work_t *
moonbit_uv_work_make(void) {
  uv_work_t *work =
    moonbit_make_external_object(moonbit_uv_work_finalize, sizeof(uv_work_t));
  memset(work, 0, sizeof(uv_work_t));
  return work;
}

static inline void
moonbit_uv_req_set_data(uv_req_t *req, void *new_data) {
  void *old_data = uv_req_get_data(req);
  if (old_data) {
    moonbit_decref(old_data);
  }
  uv_req_set_data(req, new_data);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_queue_work(
  uv_loop_t *loop,
  uv_work_t *req,
  moonbit_uv_work_cb_t *work_cb,
  moonbit_uv_after_work_cb_t *after_cb
) {
  moonbit_uv_work_data_t *data = moonbit_uv_work_data_make();
  data->work_cb = work_cb;
  data->after_cb = after_cb;
  moonbit_uv_req_set_data((uv_req_t *)req, data);
  int status =
    uv_queue_work(loop, req, moonbit_uv_work_cb, moonbit_uv_after_work_cb);
  return status;
}

typedef struct moonbit_uv_mutex_s {
  struct {
    int32_t arc;
    uv_mutex_t object;
  } *block;
} moonbit_uv_mutex_t;

static inline void
moonbit_uv_mutex_finalize(void *object) {
  moonbit_uv_mutex_t *mutex = object;
  moonbit_uv_tracef("mutex = %p\n", (void *)mutex);
  moonbit_uv_tracef("mutex->block = %p\n", (void *)mutex->block);
  if (mutex->block) {
    uv_mutex_lock(&mutex->block->object);
    int32_t arc = mutex->block->arc;
    moonbit_uv_tracef("mutex->block->arc = %d -> %d\n", arc, arc - 1);
    mutex->block->arc = arc - 1;
    uv_mutex_unlock(&mutex->block->object);
    if (arc > 1) {
      return;
    }
    uv_mutex_destroy(&mutex->block->object);
    free(mutex->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_mutex_t *
moonbit_uv_mutex_make(void) {
  moonbit_uv_mutex_t *mutex =
    (moonbit_uv_mutex_t *)moonbit_make_external_object(
      moonbit_uv_mutex_finalize, sizeof(moonbit_uv_mutex_t)
    );
  memset(mutex, 0, sizeof(moonbit_uv_mutex_t));
  return mutex;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_mutex_init(moonbit_uv_mutex_t *mutex) {
  mutex->block = malloc(sizeof(*mutex->block));
  mutex->block->arc = 1;
  int status = uv_mutex_init(&mutex->block->object);
  moonbit_decref(mutex);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_copy(moonbit_uv_mutex_t *self, moonbit_uv_mutex_t *other) {
  uv_mutex_lock(&self->block->object);
  self->block->arc += 1;
  uv_mutex_unlock(&self->block->object);
  other->block = self->block;
  moonbit_decref(self);
  moonbit_decref(other);
}

typedef struct moonbit_uv_mutex_lock_cb_s {
  int32_t (*code)(
    struct moonbit_uv_mutex_lock_cb_s *,
    moonbit_uv_mutex_t *mutex
  );
} moonbit_uv_mutex_lock_cb_t;

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_lock(moonbit_uv_mutex_t *mutex) {
  uv_mutex_lock(&mutex->block->object);
  moonbit_decref(mutex);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_mutex_trylock(moonbit_uv_mutex_t *mutex) {
  int32_t status = uv_mutex_trylock(&mutex->block->object);
  moonbit_decref(mutex);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_unlock(moonbit_uv_mutex_t *mutex) {
  uv_mutex_unlock(&mutex->block->object);
  moonbit_decref(mutex);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cwd(moonbit_bytes_t buffer, int32_t *length) {
  size_t size = *length;
  int status = uv_cwd((char *)buffer, &size);
  *length = size;
  moonbit_decref(buffer);
  moonbit_decref(length);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_chdir(moonbit_bytes_t path) {
  int status = uv_chdir((const char *)path);
  moonbit_decref(path);
  return status;
}

// Thread functions
typedef struct moonbit_uv_thread_s {
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_thread_t object;
  } *block;
} moonbit_uv_thread_t;

static inline void
moonbit_uv_thread_finalize(void *object) {
  moonbit_uv_thread_t *thread = object;
  if (thread->block) {
    uv_mutex_lock(&thread->block->mutex);
    int32_t arc = thread->block->arc;
    thread->block->arc = arc - 1;
    uv_mutex_unlock(&thread->block->mutex);
    if (arc > 1) {
      return;
    }
    free(thread->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_thread_t *
moonbit_uv_thread_make(void) {
  moonbit_uv_thread_t *thread =
    (moonbit_uv_thread_t *)moonbit_make_external_object(
      moonbit_uv_thread_finalize, sizeof(moonbit_uv_thread_t)
    );
  memset(thread, 0, sizeof(moonbit_uv_thread_t));
  return thread;
}

typedef struct moonbit_uv_thread_cb_s {
  int32_t (*code)(struct moonbit_uv_thread_cb_s *);
} moonbit_uv_thread_cb_t;

static inline void
moonbit_uv_thread_cb(void *arg) {
  moonbit_uv_thread_cb_t *cb = arg;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  cb->code(cb);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_create(
  moonbit_uv_thread_t *thread,
  moonbit_uv_thread_cb_t *cb
) {
  thread->block = malloc(sizeof(*thread->block));
  uv_mutex_init(&thread->block->mutex);
  thread->block->arc = 1;
  int status =
    uv_thread_create(&thread->block->object, moonbit_uv_thread_cb, cb);
  if (status != 0) {
    moonbit_decref(cb);
  }
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_join(moonbit_uv_thread_t *thread) {
  int32_t status = uv_thread_join(&thread->block->object);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_equal(moonbit_uv_thread_t *t1, moonbit_uv_thread_t *t2) {
  int equality = uv_thread_equal(&t1->block->object, &t2->block->object);
  moonbit_decref(t1);
  moonbit_decref(t2);
  return equality;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_self(moonbit_uv_thread_t *thread) {
  thread->block = malloc(sizeof(*thread->block));
  thread->block->arc = 1;
  int32_t status = uv_mutex_init(&thread->block->mutex);
  thread->block->object = uv_thread_self();
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_thread_copy(moonbit_uv_thread_t *self, moonbit_uv_thread_t *other) {
  uv_mutex_lock(&self->block->mutex);
  self->block->arc += 1;
  uv_mutex_unlock(&self->block->mutex);
  other->block = self->block;
  moonbit_decref(self);
  moonbit_decref(other);
}

typedef struct moonbit_uv_signal_s {
  uv_signal_t signal;
} moonbit_uv_signal_t;

static inline void
moonbit_uv_signal_finalize(void *object) {
  moonbit_uv_signal_t *signal = object;
  if (signal->signal.loop) {
    moonbit_decref(signal->signal.loop);
  }
  if (signal->signal.data) {
    moonbit_decref(signal->signal.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_signal_t *
moonbit_uv_signal_make(void) {
  moonbit_uv_signal_t *signal =
    (moonbit_uv_signal_t *)moonbit_make_external_object(
      moonbit_uv_signal_finalize, sizeof(moonbit_uv_signal_t)
    );
  memset(signal, 0, sizeof(moonbit_uv_signal_t));
  return signal;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_init(uv_loop_t *loop, moonbit_uv_signal_t *signal) {
  int status = uv_signal_init(loop, &signal->signal);
  moonbit_decref(signal);
  return status;
}

typedef struct moonbit_uv_signal_cb_s {
  int32_t (*code)(
    struct moonbit_uv_signal_cb_s *,
    uv_signal_t *signal,
    int signum
  );
} moonbit_uv_signal_cb_t;

static inline void
moonbit_uv_signal_cb(uv_signal_t *signal, int signum) {
  moonbit_uv_signal_cb_t *cb = signal->data;
  moonbit_incref(cb);
  moonbit_incref(signal);
  cb->code(cb, signal, signum);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_start(
  moonbit_uv_signal_t *signal,
  moonbit_uv_signal_cb_t *cb,
  int32_t signum
) {
  moonbit_uv_handle_set_data((uv_handle_t *)&signal->signal, cb);
  int32_t status =
    uv_signal_start(&signal->signal, moonbit_uv_signal_cb, signum);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_stop(moonbit_uv_signal_t *signal) {
  moonbit_uv_handle_set_data((uv_handle_t *)&signal->signal, NULL);
  int32_t status = uv_signal_stop(&signal->signal);
  moonbit_decref(signal);
  moonbit_decref(signal);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGHUP(void) {
  return SIGHUP;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGINT(void) {
  return SIGINT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGQUIT(void) {
  return SIGQUIT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGABRT(void) {
  return SIGABRT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGTERM(void) {
  return SIGTERM;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGWINCH(void) {
  return SIGWINCH;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGPIPE(void) {
#ifdef _WIN32
  return -1;
#else
  return SIGPIPE;
#endif
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_sleep(uint32_t milliseconds) {
  uv_sleep(milliseconds);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_hrtime(void) {
  uint64_t hrtime = uv_hrtime();
  return hrtime;
}

typedef struct moonbit_uv_random_s {
  uv_random_t random;
} moonbit_uv_random_t;

typedef struct moonbit_uv_random_cb_s {
  int32_t (*code)(
    struct moonbit_uv_random_cb_s *,
    moonbit_uv_random_t *req,
    int status,
    moonbit_bytes_t buffer,
    int32_t offset,
    int32_t length
  );
} moonbit_uv_random_cb_t;

typedef struct moonbit_uv_random_data_s {
  moonbit_bytes_t buffer;
  moonbit_uv_random_cb_t *cb;
} moonbit_uv_random_data_t;

static inline void
moonbit_uv_random_data_finalize(void *object) {
  moonbit_uv_random_data_t *data = object;
  if (data->buffer) {
    moonbit_decref(data->buffer);
  }
  if (data->cb) {
    moonbit_decref(data->cb);
  }
}

static inline moonbit_uv_random_data_t *
moonbit_uv_random_data_make(void) {
  moonbit_uv_random_data_t *data = moonbit_make_external_object(
    moonbit_uv_random_data_finalize, sizeof(moonbit_uv_random_data_t)
  );
  memset(data, 0, sizeof(moonbit_uv_random_data_t));
  return data;
}

static inline void
moonbit_uv_random_cb(uv_random_t *req, int status, void *start, size_t length) {
  moonbit_uv_random_data_t *data = req->data;
  moonbit_uv_random_cb_t *cb = data->cb;
  data->cb = NULL;
  moonbit_bytes_t buffer = data->buffer;
  data->buffer = NULL;
  ptrdiff_t offset = (char *)start - (char *)buffer;
  moonbit_uv_random_t *random = containerof(req, moonbit_uv_random_t, random);
  cb->code(cb, random, status, buffer, offset, length);
}

static inline void
moonbit_uv_random_finalize(void *object) {
  moonbit_uv_random_t *random = object;
  if (random->random.data) {
    moonbit_decref(random->random.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_random_t *
moonbit_uv_random_make(void) {
  moonbit_uv_random_t *random =
    (moonbit_uv_random_t *)moonbit_make_external_object(
      moonbit_uv_random_finalize, sizeof(moonbit_uv_random_t)
    );
  memset(random, 0, sizeof(moonbit_uv_random_t));
  return random;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_random(
  uv_loop_t *loop,
  moonbit_uv_random_t *random,
  moonbit_bytes_t buffer,
  int32_t buffer_offset,
  int32_t buffer_length,
  int32_t flags,
  moonbit_uv_random_cb_t *cb
) {
  moonbit_uv_random_data_t *data = moonbit_uv_random_data_make();
  data->buffer = buffer;
  data->cb = cb;
  if (random->random.data) {
    moonbit_decref(random->random.data);
  }
  random->random.data = data;
  int32_t status = uv_random(
    loop, &random->random, (char *)buffer + buffer_offset, buffer_length, flags,
    moonbit_uv_random_cb
  );
  moonbit_decref(loop);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_setup_args(moonbit_bytes_t *argv) {
  // `argv` is marked as borrowed on MoonBit side, so there is no need to decref
  // it here.
  int argc = Moonbit_array_length(argv);
  char **args = malloc(sizeof(char *) * (size_t)argc);
  for (int i = 0; i < argc; i++) {
    // `argv` in MoonBit is not a null-terminated byte sequence, so we need to
    // add a '\0' at the end of each argument.
    moonbit_bytes_t arg = argv[i];
    size_t arglen = Moonbit_array_length(arg);
    args[i] = malloc(arglen + 1);
    memcpy(args[i], arg, arglen);
    args[i][arglen] = '\0';
  }
  // `libuv` may take ownership of `args` here.
  uv_setup_args(argc, args);
  // `libuv` may return a copy of `args` here, but we discard it anyway since we
  // copied the arguments above.
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_uname(moonbit_bytes_t buffer) {
  int32_t status = uv_os_uname((uv_utsname_t *)buffer);
  moonbit_decref(buffer);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_tmpdir(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_tmpdir((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

typedef struct moonbit_uv_os_environ_s {
  uv_env_item_t *items;
  int32_t count;
} moonbit_uv_environ_t;

static inline void
moonbit_uv_environ_finalize(void *object) {
  moonbit_uv_environ_t *env = object;
  if (env->items) {
    uv_os_free_environ(env->items, env->count);
    env->items = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_environ_t *
moonbit_uv_environ_make() {
  moonbit_uv_environ_t *env =
    (moonbit_uv_environ_t *)moonbit_make_external_object(
      moonbit_uv_environ_finalize, sizeof(moonbit_uv_environ_t)
    );
  env->items = NULL;
  env->count = 0;
  return env;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_environ_count(moonbit_uv_environ_t *env) {
  return env->count;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_environ_get_name(moonbit_uv_environ_t *env, int32_t index) {
  return env->items[index].name;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_environ_get_value(moonbit_uv_environ_t *env, int32_t index) {
  return env->items[index].value;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_environ(moonbit_uv_environ_t *env) {
  if (env->items) {
    moonbit_uv_environ_finalize(env);
  }
  int status = uv_os_environ(&env->items, &env->count);
  moonbit_decref(env);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_getenv(
  moonbit_bytes_t name,
  moonbit_bytes_t bytes,
  int32_t *size
) {
  size_t size_value = *size;
  int32_t status = uv_os_getenv((const char *)name, (char *)bytes, &size_value);
  *size = size_value;
  moonbit_decref(name);
  moonbit_decref(bytes);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_setenv(moonbit_bytes_t name, moonbit_bytes_t value) {
  int32_t status = uv_os_setenv((const char *)name, (const char *)value);
  moonbit_decref(name);
  moonbit_decref(value);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_unsetenv(moonbit_bytes_t name) {
  int32_t status = uv_os_unsetenv((const char *)name);
  moonbit_decref(name);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_exepath(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_exepath((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_homedir(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_homedir((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

typedef struct moonbit_uv_shutdown_s {
  uv_shutdown_t shutdown;
} moonbit_uv_shutdown_t;

static inline void
moonbit_uv_shutdown_finalize(void *object) {
  moonbit_uv_shutdown_t *shutdown = object;
  if (shutdown->shutdown.data) {
    moonbit_decref(shutdown->shutdown.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_shutdown_t *
moonbit_uv_shutdown_make(void) {
  moonbit_uv_shutdown_t *shutdown =
    (moonbit_uv_shutdown_t *)moonbit_make_external_object(
      moonbit_uv_shutdown_finalize, sizeof(moonbit_uv_shutdown_t)
    );
  memset(shutdown, 0, sizeof(moonbit_uv_shutdown_t));
  return shutdown;
}

typedef struct moonbit_uv_shutdown_cb_s {
  int32_t (*code)(
    struct moonbit_uv_shutdown_cb_s *,
    moonbit_uv_shutdown_t *req,
    int status
  );
} moonbit_uv_shutdown_cb_t;

static inline void
moonbit_uv_shutdown_cb(uv_shutdown_t *req, int status) {
  moonbit_uv_shutdown_cb_t *cb = req->data;
  req->data = NULL;
  moonbit_uv_shutdown_t *shutdown =
    containerof(req, moonbit_uv_shutdown_t, shutdown);
  cb->code(cb, shutdown, status);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_shutdown(
  moonbit_uv_shutdown_t *req,
  uv_stream_t *handle,
  moonbit_uv_shutdown_cb_t *cb
) {
  if (req->shutdown.data) {
    moonbit_decref(req->shutdown.data);
  }
  req->shutdown.data = cb;
  int32_t status = uv_shutdown(&req->shutdown, handle, moonbit_uv_shutdown_cb);
  moonbit_decref(handle);
  return status;
}

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
moonbit_uv_IF_NAMESIZE(void) {
  return UV_IF_NAMESIZE;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_ip4_name(const struct sockaddr_in *src, moonbit_bytes_t dst) {
  return uv_ip4_name(src, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_ip6_name(const struct sockaddr_in6 *src, moonbit_bytes_t dst) {
  return uv_ip6_name(src, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_ip_name(const struct sockaddr *src, moonbit_bytes_t dst) {
  return uv_ip_name(src, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SOCK_RAW(void) {
  return SOCK_RAW;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SOCK_DGRAM(void) {
  return SOCK_DGRAM;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SOCK_STREAM(void) {
  return SOCK_STREAM;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AF_INET(void) {
  return AF_INET;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AF_INET6(void) {
  return AF_INET6;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_AF_UNSPEC(void) {
  return AF_UNSPEC;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_IPPROTO_UDP(void) {
  return IPPROTO_UDP;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_IPPROTO_TCP(void) {
  return IPPROTO_TCP;
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

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_dev(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_dev;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_mode(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_mode;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_nlink(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_nlink;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_uid(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_uid;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_gid(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_gid;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_rdev(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_rdev;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_ino(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_ino;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_size(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_size;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_blksize(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_blksize;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_blocks(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_blocks;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_flags(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_flags;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_gen(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_gen;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_atim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_atim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_atim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_atim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_mtim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_mtim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_mtim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_mtim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_ctim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_ctim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_ctim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_ctim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_birthtim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_birthtim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_birthtim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_birthtim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_print_all_handles(uv_loop_t *loop, int fd) {
  FILE *stream = fdopen(fd, "w");
  moonbit_uv_tracef("stream: %p\n", (void *)stream);
  if (!stream) {
    return uv_translate_sys_error(errno);
  }
  uv_print_all_handles(loop, stream);
  moonbit_decref(loop);
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cancel(uv_req_t *req) {
  moonbit_uv_tracef("req: %p\n", (void *)req);
  moonbit_uv_tracef("req->type: %s\n", uv_req_type_name(req->type));
  moonbit_uv_tracef("req->rc: %d\n", Moonbit_object_header(req)->rc);
  int32_t result = uv_cancel(req);
  moonbit_uv_tracef("result: %d\n", result);
  moonbit_decref(req);
  return result;
}
