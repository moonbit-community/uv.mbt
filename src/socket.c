/*
 * Copyright 2026 International Digital Economy Academy
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
struct in_addr
moonbit_uv_in_addr_make(
  uint32_t b0, // uint8_t
  uint32_t b1, // uint8_t
  uint32_t b2, // uint8_t
  uint32_t b3  // uint8_t
) {
  union {
    struct in_addr addr;
    uint8_t uint8[4];
  } addr;
  addr.uint8[0] = (uint8_t)b0;
  addr.uint8[1] = (uint8_t)b1;
  addr.uint8[2] = (uint8_t)b2;
  addr.uint8[3] = (uint8_t)b3;
  return addr.addr;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_in_addr_to_bytes(struct in_addr addr) {
  moonbit_bytes_t bytes = moonbit_make_bytes(sizeof(addr), 0);
  memcpy(bytes, &addr, sizeof(addr));
  return bytes;
}

MOONBIT_FFI_EXPORT
struct in6_addr
moonbit_uv_in6_addr_make(
  uint32_t h0, // uint16_t
  uint32_t h1, // uint16_t
  uint32_t h2, // uint16_t
  uint32_t h3, // uint16_t
  uint32_t h4, // uint16_t
  uint32_t h5, // uint16_t
  uint32_t h6, // uint16_t
  uint32_t h7  // uint16_t
) {
  union {
    struct in6_addr in6_addr;
    uint16_t uint16[8];
  } addr;
  addr.uint16[0] = htons((uint16_t)h0);
  addr.uint16[1] = htons((uint16_t)h1);
  addr.uint16[2] = htons((uint16_t)h2);
  addr.uint16[3] = htons((uint16_t)h3);
  addr.uint16[4] = htons((uint16_t)h4);
  addr.uint16[5] = htons((uint16_t)h5);
  addr.uint16[6] = htons((uint16_t)h6);
  addr.uint16[7] = htons((uint16_t)h7);
  return addr.in6_addr;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_in6_addr_to_bytes(struct in6_addr addr) {
  moonbit_bytes_t bytes = moonbit_make_bytes(sizeof(addr), 0);
  memcpy(bytes, &addr, sizeof(addr));
  return bytes;
}

MOONBIT_FFI_EXPORT
struct sockaddr_in *
moonbit_uv_sockaddr_in_make(void) {
  return (struct sockaddr_in *)moonbit_make_bytes(
    sizeof(struct sockaddr_in), 0
  );
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_sockaddr_in_port(struct sockaddr_in *addr) {
  return ntohs(addr->sin_port);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_sockaddr_in_addr(struct sockaddr_in *addr) {
  return addr->sin_addr.s_addr;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_in_addr_ntop(uint32_t src, moonbit_bytes_t dst) {
  struct in_addr addr;
  addr.s_addr = src;
  return uv_inet_ntop(AF_INET, &addr, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_in_addr_pton(moonbit_bytes_t src, struct in_addr *dst) {
  return uv_inet_pton(AF_INET, (const char *)src, dst);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_INET_ADDRSTRLEN() {
  return INET_ADDRSTRLEN;
}

MOONBIT_FFI_EXPORT struct sockaddr_in6 *
moonbit_uv_sockaddr_in6_make(void) {
  return (struct sockaddr_in6 *)moonbit_make_bytes(
    sizeof(struct sockaddr_in6), 0
  );
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_sockaddr_in6_port(struct sockaddr_in6 *addr) {
  return ntohs(addr->sin6_port);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_sockaddr_in6_scope_id(struct sockaddr_in6 *addr) {
  return addr->sin6_scope_id;
}

MOONBIT_FFI_EXPORT
struct in6_addr
moonbit_uv_sockaddr_in6_addr(struct sockaddr_in6 *addr) {
  return addr->sin6_addr;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_in6_addr_ntop(struct in6_addr src, moonbit_bytes_t dst) {
  return uv_inet_ntop(AF_INET6, &src, (char *)dst, Moonbit_array_length(dst));
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_in6_addr_pton(moonbit_bytes_t src, struct in6_addr *dst) {
  return uv_inet_pton(AF_INET6, (const char *)src, dst);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_INET6_ADDRSTRLEN() {
  return INET6_ADDRSTRLEN;
}

MOONBIT_FFI_EXPORT
struct sockaddr *
moonbit_uv_sockaddr_make(void) {
  return (struct sockaddr *)moonbit_make_bytes(
    sizeof(struct sockaddr_storage), 0
  );
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_sockaddr_family(struct sockaddr *addr) {
  return addr->sa_family;
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
moonbit_uv_AF_UNIX(void) {
  return AF_UNIX;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_IPPROTO_IP(void) {
  return IPPROTO_IP;
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
