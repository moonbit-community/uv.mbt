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
#include <stdlib.h>
#ifdef _WIN32
#else
#include <unistd.h>
#endif
#include "uv.h"

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
moonbit_uv_fs_fsync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_fsync(loop, &fs->fs, file, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fsync_sync(uv_loop_t *loop, moonbit_uv_fs_t *fs, int32_t file) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_fsync(loop, &fs->fs, file, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fdatasync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_fdatasync(loop, &fs->fs, file, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fdatasync_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_fdatasync(loop, &fs->fs, file, NULL);
  moonbit_decref(fs);
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
  uv_dirent_t *dirent = malloc(sizeof(uv_dirent_t) * length);
  memset(dirent, 0, sizeof(uv_dirent_t) * length);
  return dirent;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_dirent_get_name(uv_dirent_t *dirent, int32_t offset) {
  return dirent[offset].name;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_dirent_get_type(uv_dirent_t *dirent, int32_t offset) {
  return dirent[offset].type;
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
moonbit_uv_fs_lstat_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_lstat(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
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

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_link(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_link(
    loop, &fs->fs, (const char *)path, (const char *)new_path, moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_link_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status =
    uv_fs_link(loop, &fs->fs, (const char *)path, (const char *)new_path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_UV_FS_SYMLINK_DIR(void) {
  return UV_FS_SYMLINK_DIR;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_UV_FS_SYMLINK_JUNCTION(void) {
  return UV_FS_SYMLINK_JUNCTION;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_symlink(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  int32_t flags,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_symlink(
    loop, &fs->fs, (const char *)path, (const char *)new_path, flags,
    moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_symlink_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_bytes_t new_path,
  int32_t flags
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_symlink(
    loop, &fs->fs, (const char *)path, (const char *)new_path, flags, NULL
  );
  moonbit_decref(fs);
  moonbit_decref(path);
  moonbit_decref(new_path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_readlink(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_readlink(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_readlink_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_readlink(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_chown(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  uint32_t uid,
  uint32_t gid,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_chown(
    loop, &fs->fs, (const char *)path, (uv_uid_t)uid, (uv_gid_t)gid,
    moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_chown_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  uint32_t uid,
  uint32_t gid
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_chown(
    loop, &fs->fs, (const char *)path, (uv_uid_t)uid, (uv_gid_t)gid, NULL
  );
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fchown(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  uint64_t uid,
  uint64_t gid,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_fchown(
    loop, &fs->fs, file, (uv_uid_t)uid, (uv_gid_t)gid, moonbit_uv_fs_cb
  );
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fchown_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  uint64_t uid,
  uint64_t gid
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status =
    uv_fs_fchown(loop, &fs->fs, file, (uv_uid_t)uid, (uv_gid_t)gid, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_lchown(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  uint64_t uid,
  uint64_t gid,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_lchown(
    loop, &fs->fs, (const char *)path, (uv_uid_t)uid, (uv_gid_t)gid,
    moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_lchown_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  uint64_t uid,
  uint64_t gid
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_lchown(
    loop, &fs->fs, (const char *)path, (uv_uid_t)uid, (uv_gid_t)gid, NULL
  );
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_sendfile(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t out_fd,
  int32_t in_fd,
  int64_t in_offset,
  uint64_t length,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_sendfile(
    loop, &fs->fs, out_fd, in_fd, in_offset, length, moonbit_uv_fs_cb
  );
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_sendfile_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t out_fd,
  int32_t in_fd,
  int64_t in_offset,
  uint64_t length
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status =
    uv_fs_sendfile(loop, &fs->fs, out_fd, in_fd, in_offset, length, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_chmod(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_chmod(loop, &fs->fs, (const char *)path, mode, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_chmod_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  int32_t mode
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_chmod(loop, &fs->fs, (const char *)path, mode, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fchmod(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  int32_t mode,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_fchmod(loop, &fs->fs, file, mode, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_fchmod_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  int32_t mode
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_fchmod(loop, &fs->fs, file, mode, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_statfs(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_statfs(loop, &fs->fs, (const char *)path, moonbit_uv_fs_cb);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_statfs_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_statfs(loop, &fs->fs, (const char *)path, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
uv_statfs_t *
moonbit_uv_fs_get_statfs(moonbit_uv_fs_t *fs) {
  uv_statfs_t *statfs =
    (uv_statfs_t *)moonbit_make_bytes(sizeof(uv_statfs_t), 0);
  memcpy(statfs, fs->fs.ptr, sizeof(uv_statfs_t));
  moonbit_decref(fs);
  return statfs;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_utime(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  double atime,
  double mtime,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_utime(
    loop, &fs->fs, (const char *)path, atime, mtime, moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_utime_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  double atime,
  double mtime
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status =
    uv_fs_utime(loop, &fs->fs, (const char *)path, atime, mtime, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_futime(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  double atime,
  double mtime,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status =
    uv_fs_futime(loop, &fs->fs, file, atime, mtime, moonbit_uv_fs_cb);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_futime_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  int32_t file,
  double atime,
  double mtime
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status = uv_fs_futime(loop, &fs->fs, file, atime, mtime, NULL);
  moonbit_decref(fs);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_lutime(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  double atime,
  double mtime,
  moonbit_uv_fs_cb_t *cb
) {
  moonbit_uv_fs_set_data(fs, cb);
  int status = uv_fs_lutime(
    loop, &fs->fs, (const char *)path, atime, mtime, moonbit_uv_fs_cb
  );
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_lutime_sync(
  uv_loop_t *loop,
  moonbit_uv_fs_t *fs,
  moonbit_bytes_t path,
  double atime,
  double mtime
) {
  moonbit_uv_fs_set_data(fs, NULL);
  int status =
    uv_fs_lutime(loop, &fs->fs, (const char *)path, atime, mtime, NULL);
  moonbit_decref(fs);
  moonbit_decref(path);
  return status;
}
