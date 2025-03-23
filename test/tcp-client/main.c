#include "uv.h"
#include "uv/unix.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define containerof(ptr, type, member)                                         \
  ((type *)((char *)(ptr)-offsetof(type, member)))

typedef struct tty_write_req_s {
  uv_write_t write;
} tty_write_req_t;

typedef struct tty_read_req_s {
  uv_fs_t req;
  uv_stream_t *stream;
  char data[1024];
} tty_read_req_t;

typedef struct tcp_write_req_s {
  uv_write_t write;
  tty_read_req_t *tty_read_req;
} tcp_write_req_t;

void
on_tty_read(uv_fs_t *req);

void
on_close(uv_handle_t *handle) {
  free(handle);
}

void
on_tcp_write(uv_write_t *req, int status) {
  tcp_write_req_t *write = containerof(req, tcp_write_req_t, write);
  if (status < 0) {
    fprintf(stderr, "Write error: %s\n", uv_strerror(status));
  }
  uv_buf_t tty_read_buf =
    uv_buf_init(write->tty_read_req->data, sizeof(write->tty_read_req->data));
  uv_fs_read(
    uv_default_loop(), &write->tty_read_req->req, 0, &tty_read_buf, 1, -1,
    on_tty_read
  );
  free(write);
}

void
alloc_buffer(uv_handle_t *handle, size_t suggested_size, uv_buf_t *buf) {
  (void)handle;
  buf->base = malloc(suggested_size);
  buf->len = suggested_size;
}

void
on_tty_read(uv_fs_t *req) {
  tty_read_req_t *tty_read_req = containerof(req, tty_read_req_t, req);
  ssize_t nread = req->result;
  if (nread > 0) {
    tcp_write_req_t *write = malloc(sizeof(tcp_write_req_t));
    write->tty_read_req = tty_read_req;
    uv_buf_t buf = uv_buf_init(tty_read_req->data, nread);
    uv_write(&write->write, tty_read_req->stream, &buf, 1, on_tcp_write);
    return;
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    } else {
      fprintf(stderr, "Read EOF\n");
    }
    uv_close((uv_handle_t *)tty_read_req->stream, on_close);
  }
  free(tty_read_req);
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
  if (nread > 0) {
    uv_fs_t *req = malloc(sizeof(uv_fs_t));
    uv_buf_t write_buf = uv_buf_init(buf->base, nread);
    uv_fs_write(
      uv_default_loop(), req, STDOUT_FILENO, &write_buf, 1, -1, on_tty_write
    );
  }
  if (nread < 0) {
    if (nread != UV_EOF) {
      fprintf(stderr, "Read error: %s\n", uv_strerror(nread));
    } else {
      fprintf(stderr, "Read EOF\n");
    }
    uv_close((uv_handle_t *)stream, NULL);
  }
}

void
on_connect(uv_connect_t *connect, int status) {
  if (status < 0) {
    fprintf(stderr, "Connect error: %s\n", uv_strerror(status));
    return;
  }
  uv_stream_t *stream = connect->handle;
  tty_read_req_t *tty_read_req = malloc(sizeof(tty_read_req_t));
  tty_read_req->stream = stream;
  uv_read_start(stream, alloc_buffer, on_tcp_read);
  uv_buf_t tty_read_buf =
    uv_buf_init(tty_read_req->data, sizeof(tty_read_req->data));
  uv_fs_read(
    uv_default_loop(), &tty_read_req->req, STDIN_FILENO, &tty_read_buf, 1, -1,
    on_tty_read
  );
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
