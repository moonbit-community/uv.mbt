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

#include "socket.h"
#include "moonbit.h"
#include "uv#include#uv.h"

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_inet_ntop(uint32_t src, moonbit_bytes_t dst) {
  struct in_addr addr;
  addr.s_addr = src;
  return uv_inet_ntop(AF_INET, &addr, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_inet_pton(moonbit_bytes_t src, struct in_addr *dst) {
  return uv_inet_pton(AF_INET, (const char *)src, dst);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_inet6_ntop(struct in6_addr *src, moonbit_bytes_t dst) {
  return uv_inet_ntop(AF_INET6, src, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_inet6_pton(moonbit_bytes_t src, struct in6_addr *dst) {
  return uv_inet_pton(AF_INET6, (const char *)src, dst);
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
moonbit_uv_os_sock_t *
moonbit_uv_os_sock_make(void) {
  moonbit_uv_os_sock_t *sock =
    (moonbit_uv_os_sock_t *)moonbit_make_bytes(sizeof(moonbit_uv_os_sock_t), 0);
  sock->sock = -1; // Initialize to an invalid socket
  return sock;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_sock_to_int(moonbit_uv_os_sock_t *sock) {
  return (int32_t)sock->sock;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_socketpair(
  int32_t type,
  int32_t protocol,
  moonbit_uv_os_sock_t *sock0,
  int32_t flags0,
  moonbit_uv_os_sock_t *sock1,
  int32_t flags1
) {
  uv_os_sock_t s[2];
  int r = uv_socketpair(type, protocol, s, flags0, flags1);
  if (r == 0) {
    sock0->sock = s[0];
    sock1->sock = s[1];
  }
  moonbit_decref(sock0);
  moonbit_decref(sock1);
  return r;
}
