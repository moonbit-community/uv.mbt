#include "uv.h"
#include "uv/unix.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr)-offsetof(type, member)))

typedef struct tty_write_req_s {
  uv_write_t write;
} tty_write_req_t;

typedef struct stdin_tty_s {
  uv_tty_t tty;
  uv_stream_t *server;
} stdin_tty_t;

typedef struct tcp_write_s {
  uv_write_t write;
  stdin_tty_t *tty_read_req;
} tcp_write_t;

typedef struct tcp_server_s {
  uv_stream_t *server;
  uv_tty_t *stdin_tty;
} tcp_server_t;

void
on_tty_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf);

void
on_tcp_close(uv_handle_t *handle) {
  free(handle);
}

void
on_tcp_write(uv_write_t *req, int status) {
  tcp_write_t *write = containerof(req, tcp_write_t, write);
  if (status < 0) {
    fprintf(stderr, "Write error: %s\n", uv_strerror(status));
  }
  free(write);
}

void
alloc_buffer(uv_handle_t *handle, size_t suggested_size, uv_buf_t *buf) {
  (void)handle;
  buf->base = malloc(suggested_size);
  buf->len = suggested_size;
}

void
on_tty_close(uv_handle_t *handle) {
  stdin_tty_t *stdin_tty = containerof(handle, stdin_tty_t, tty);
  free(stdin_tty);
}

void
on_tty_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf) {
  stdin_tty_t *stdin_tty = containerof(stream, stdin_tty_t, tty);
  if (nread > 0) {
    tcp_write_t *write = malloc(sizeof(tcp_write_t));
    write->tty_read_req = stdin_tty;
    uv_buf_t write_buf = uv_buf_init(buf->base, nread);
    uv_write(&write->write, stdin_tty->server, &write_buf, 1, on_tcp_write);
    return;
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    } else {
      fprintf(stderr, "Read EOF\n");
    }
  }
  uv_read_stop(stdin_tty->server);
  uv_close((uv_handle_t *)stdin_tty->server, on_tcp_close);
  uv_read_stop(stream);
  uv_close((uv_handle_t *)stream, on_tty_close);
  uv_stop(uv_default_loop());
}

void
on_tty_write(uv_fs_t *req) {
  if (req->result < 0) {
    fprintf(stderr, "Write error: %s\n", uv_strerror(req->result));
  }
  free(req);
}

void
on_tcp_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf) {
  tcp_server_t *server = containerof(stream, tcp_server_t, server);
  if (nread > 0) {
    uv_fs_t *req = malloc(sizeof(uv_fs_t));
    uv_buf_t write_buf = uv_buf_init(buf->base, nread);
    uv_fs_write(
      uv_default_loop(), req, STDOUT_FILENO, &write_buf, 1, -1, on_tty_write
    );
    return;
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    } else {
      fprintf(stderr, "Read EOF\n");
    }
  }
  uv_read_stop(stream);
  uv_close((uv_handle_t *)stream, on_tcp_close);
  uv_read_stop((uv_stream_t *)server->stdin_tty);
  uv_close((uv_handle_t *)server->stdin_tty, on_tty_close);
  uv_stop(uv_default_loop());
}

void
on_connect(uv_connect_t *connect, int status) {
  if (status < 0) {
    fprintf(stderr, "Connect error: %s\n", uv_strerror(status));
    return;
  }

  tcp_server_t *server = malloc(sizeof(tcp_server_t));
  server->server = connect->handle;

  stdin_tty_t *stdin_tty = malloc(sizeof(stdin_tty_t));
  uv_tty_init(uv_default_loop(), &stdin_tty->tty, STDOUT_FILENO, true);

  server->stdin_tty = &stdin_tty->tty;
  stdin_tty->server = connect->handle;
  uv_read_start(server->server, alloc_buffer, on_tcp_read);
  uv_read_start((uv_stream_t *)&stdin_tty->tty, alloc_buffer, on_tty_read);
}

int
main(void) {
  uv_tcp_t *server = malloc(sizeof(uv_tcp_t));
  uv_tcp_init(uv_default_loop(), server);
  struct sockaddr_in addr;
  uv_ip4_addr("127.0.0.1", 7001, &addr);
  uv_connect_t *connect = malloc(sizeof(uv_connect_t));
  uv_tcp_connect(connect, server, (const struct sockaddr *)&addr, on_connect);
  uv_run(uv_default_loop(), UV_RUN_DEFAULT);
  return 0;
}
