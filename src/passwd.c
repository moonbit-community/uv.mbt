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
int32_t
moonbit_uv_os_get_passwd2(moonbit_uv_passwd_t *passwd, uint64_t uid) {
  int32_t result = uv_os_get_passwd2(&passwd->passwd, uid);
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

typedef struct moonbit_uv_group_s {
  uv_group_t group;
} moonbit_uv_group_t;

static inline void
moonbit_uv_os_free_group(void *object) {
  moonbit_uv_group_t *group = (moonbit_uv_group_t *)object;
  uv_os_free_group(&group->group);
}

MOONBIT_FFI_EXPORT
moonbit_uv_group_t *
moonbit_uv_group_make(void) {
  moonbit_uv_group_t *group = moonbit_make_external_object(
    moonbit_uv_os_free_group, sizeof(moonbit_uv_group_t)
  );
  memset(group, 0, sizeof(moonbit_uv_group_t));
  return group;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_group_get_groupname(moonbit_uv_group_t *group) {
  size_t length = strlen(group->group.groupname);
  moonbit_bytes_t groupname = moonbit_make_bytes(length, 0);
  memcpy(groupname, group->group.groupname, length);
  moonbit_decref(group);
  return groupname;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_group_get_gid(moonbit_uv_group_t *group) {
  uint64_t gid = group->group.gid;
  moonbit_decref(group);
  return gid;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t *
moonbit_uv_group_get_members(moonbit_uv_group_t *group) {
  size_t count = 0;
  while (group->group.members[count]) {
    count++;
  }
  moonbit_bytes_t *members =
    (moonbit_bytes_t *)moonbit_make_ref_array(count, NULL);
  for (size_t i = 0; i < count; i++) {
    size_t length = strlen(group->group.members[i]);
    members[i] = moonbit_make_bytes(length, 0);
    memcpy(members[i], group->group.members[i], length);
  }
  moonbit_decref(group);
  return members;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_get_group(moonbit_uv_group_t *group, uint64_t gid) {
  int32_t result = uv_os_get_group(&group->group, gid);
  moonbit_decref(group);
  return result;
}
