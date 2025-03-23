#include "uv.h"
#include "uv/unix.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr) - offsetof(type, member)))

typedef struct tty_stdin_s {
  uv_tty_t tty_stdin;
  uv_stream_t *tcp_server;
} tty_stdin_t;

typedef struct tty_write_s {
  uv_fs_t req;
  uv_buf_t buf;
} tty_write_t;

typedef struct tcp_server_s {
  uv_tcp_t tcp_server;
  uv_tty_t *tty_stdin;
} tcp_server_t;

typedef struct tcp_write_s {
  uv_write_t write;
  uv_buf_t buf;
} tcp_write_t;

void
on_tty_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf);

void
on_tcp_close(uv_handle_t *handle) {
  tcp_server_t *tcp_server = containerof(handle, tcp_server_t, tcp_server);
  free(tcp_server);
}

void
on_tcp_write(uv_write_t *req, int status) {
  tcp_write_t *write = containerof(req, tcp_write_t, write);
  if (status < 0) {
    fprintf(stderr, "Write error: %s\n", uv_strerror(status));
  }
  free(write->buf.base);
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
  tty_stdin_t *tty_stdin = containerof(handle, tty_stdin_t, tty_stdin);
  free(tty_stdin);
}

void
on_tty_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf) {
  tty_stdin_t *tty_stdin = containerof(stream, tty_stdin_t, tty_stdin);
  if (nread > 0) {
    tcp_write_t *write = malloc(sizeof(tcp_write_t));
    write->buf = uv_buf_init(buf->base, nread);
    uv_write(
      &write->write, tty_stdin->tcp_server, &write->buf, 1, on_tcp_write
    );
    return;
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    }
    uv_read_stop(tty_stdin->tcp_server);
    uv_close((uv_handle_t *)tty_stdin->tcp_server, on_tcp_close);
    uv_read_stop(stream);
    uv_close((uv_handle_t *)stream, on_tty_close);
    uv_stop(uv_default_loop());
  }
  free(buf->base);
}

void
on_tty_write(uv_fs_t *req) {
  tty_write_t *write = containerof(req, tty_write_t, req);
  if (req->result < 0) {
    fprintf(stderr, "Write error: %s\n", uv_strerror(req->result));
  }
  free(write->buf.base);
  free(write);
}

void
on_tcp_read(uv_stream_t *stream, ssize_t nread, const uv_buf_t *buf) {
  tcp_server_t *tcp_server = containerof(stream, tcp_server_t, tcp_server);
  if (nread > 0) {
    tty_write_t *write = malloc(sizeof(tty_write_t));
    write->buf = uv_buf_init(buf->base, nread);
    uv_fs_write(
      uv_default_loop(), &write->req, STDOUT_FILENO, &write->buf, 1, -1,
      on_tty_write
    );
    return;
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    }
    uv_read_stop(stream);
    uv_close((uv_handle_t *)stream, on_tcp_close);
    uv_read_stop((uv_stream_t *)tcp_server->tty_stdin);
    uv_close((uv_handle_t *)tcp_server->tty_stdin, on_tty_close);
    uv_stop(uv_default_loop());
  }
  free(buf->base);
}

void
on_connect(uv_connect_t *connect, int status) {
  if (status < 0) {
    fprintf(stderr, "Connect error: %s\n", uv_strerror(status));
    return;
  }

  tcp_server_t *tcp_server =
    containerof(connect->handle, tcp_server_t, tcp_server);

  tty_stdin_t *tty_stdin = malloc(sizeof(tty_stdin_t));
  uv_tty_init(uv_default_loop(), &tty_stdin->tty_stdin, STDOUT_FILENO, true);

  tcp_server->tty_stdin = &tty_stdin->tty_stdin;
  tty_stdin->tcp_server = connect->handle;
  uv_read_start(
    (uv_stream_t *)&tcp_server->tcp_server, alloc_buffer, on_tcp_read
  );
  uv_read_start(
    (uv_stream_t *)&tty_stdin->tty_stdin, alloc_buffer, on_tty_read
  );
  free(connect);
}

int
main(void) {
  tcp_server_t *tcp_server = malloc(sizeof(tcp_server_t));
  uv_tcp_init(uv_default_loop(), &tcp_server->tcp_server);
  struct sockaddr_in addr;
  uv_ip4_addr("127.0.0.1", 7001, &addr);
  uv_connect_t *connect = malloc(sizeof(uv_connect_t));
  uv_tcp_connect(
    connect, &tcp_server->tcp_server, (const struct sockaddr *)&addr, on_connect
  );
  uv_run(uv_default_loop(), UV_RUN_DEFAULT);
  return 0;
}
