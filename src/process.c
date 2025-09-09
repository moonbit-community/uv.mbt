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
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

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
  if (process->process.loop) {
    moonbit_decref(process->process.loop);
    process->process.loop = NULL;
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
    container->container.data.stream = NULL;
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
int32_t
moonbit_uv_os_getpid(void) {
  return uv_os_getpid();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_getppid(void) {
  return uv_os_getppid();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_kill(int32_t pid, int32_t signum) {
  return uv_kill(pid, signum);
}
