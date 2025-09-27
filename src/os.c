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

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_free_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_total_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_constrained_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_available_memory(void) {
  return uv_get_available_memory();
}

typedef struct moonbit_uv_passwd_s {
  uv_passwd_t passwd;
} moonbit_uv_passwd_t;

static inline void
moonbit_uv_os_free_passwd(void *object) {
  moonbit_uv_passwd_t *passwd = (moonbit_uv_passwd_t *)object;
  uv_os_free_passwd(&passwd->passwd);
}

MOONBIT_FFI_EXPORT
moonbit_uv_passwd_t *
moonbit_uv_passwd_make(void) {
  moonbit_uv_passwd_t *passwd = moonbit_make_external_object(
    moonbit_uv_os_free_passwd, sizeof(moonbit_uv_passwd_t)
  );
  memset(passwd, 0, sizeof(moonbit_uv_passwd_t));
  return passwd;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_get_passwd(moonbit_uv_passwd_t *passwd) {
  int32_t result = uv_os_get_passwd(&passwd->passwd);
  moonbit_decref(passwd);
  return result;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_passwd_get_username(moonbit_uv_passwd_t *passwd) {
  size_t length = strlen(passwd->passwd.username);
  moonbit_bytes_t username = moonbit_make_bytes(length, 0);
  memcpy(username, passwd->passwd.username, length);
  moonbit_decref(passwd);
  return username;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_passwd_get_uid(moonbit_uv_passwd_t *passwd) {
  uint64_t uid = passwd->passwd.uid;
  moonbit_decref(passwd);
  return uid;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_passwd_get_gid(moonbit_uv_passwd_t *passwd) {
  uint64_t gid = passwd->passwd.gid;
  moonbit_decref(passwd);
  return gid;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_passwd_get_homedir(moonbit_uv_passwd_t *passwd) {
  size_t length = strlen(passwd->passwd.homedir);
  moonbit_bytes_t homedir = moonbit_make_bytes(length, 0);
  memcpy(homedir, passwd->passwd.homedir, length);
  moonbit_decref(passwd);
  return homedir;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_passwd_get_shell(moonbit_uv_passwd_t *passwd) {
  if (passwd->passwd.shell) {
    size_t length = strlen(passwd->passwd.shell);
    moonbit_bytes_t shell = moonbit_make_bytes(length, 0);
    memcpy(shell, passwd->passwd.shell, length);
    moonbit_decref(passwd);
    return shell;
  } else {
    moonbit_decref(passwd);
    return moonbit_empty_int8_array;
  }
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_gethostname(moonbit_bytes_t name, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_gethostname((char *)name, &size_value);
  *size = size_value;
  moonbit_decref(name);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_uptime(double *uptime) {
  return uv_uptime(uptime);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_resident_set_memory(uint64_t *rss) {
  size_t rss_value = (size_t)*rss;
  int32_t status = uv_resident_set_memory(&rss_value);
  *rss = (uint64_t)rss_value;
  moonbit_decref(rss);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_loadavg(double avg[3]) {
  uv_loadavg(avg);
  moonbit_decref(avg);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_available_parallelism(void) {
  return uv_available_parallelism();
}
