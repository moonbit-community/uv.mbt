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
  if (random->random.loop) {
    moonbit_decref(random->random.loop);
  }
  if (random->random.data) {
    moonbit_decref(random->random.data);
    random->random.data = NULL;
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
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_random_sync(
  uv_loop_t *loop,
  moonbit_uv_random_t *random,
  moonbit_bytes_t buffer,
  int32_t buffer_offset,
  int32_t buffer_length,
  int32_t flags
) {
  if (random->random.data) {
    moonbit_decref(random->random.data);
  }
  random->random.data = NULL;
  int32_t status = uv_random(
    loop, &random->random, (char *)buffer + buffer_offset, buffer_length, flags,
    NULL
  );
  // It seems that synchronous uv_random does set the `loop` field in `random`.
  // Therefore we have to decref the loop here.
  moonbit_decref(loop);
  moonbit_decref(random);
  moonbit_decref(buffer);
  return status;
}
