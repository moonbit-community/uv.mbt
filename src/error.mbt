///|
extern "c" fn strerror_r(err : Int, bytes : Bytes) -> Unit = "moonbit_uv_strerror_r"

///|
pub fn strerror(errno : Int) -> String {
  let bytes = Bytes::make(256, 0)
  strerror_r(errno, bytes)
  let buffer = @buffer.new()
  for byte in bytes {
    if byte == 0 {
      break
    }
    buffer.write_byte(byte)
  }
  let message = @encoding.decoder(UTF8).decode_lossy(buffer.to_bytes())
  return message
}

///|
pub type! Errno {
  E2BIG
  EACCES
  EADDRINUSE
  EADDRNOTAVAIL
  EAFNOSUPPORT
  EAGAIN
  EAI_ADDRFAMILY
  EAI_AGAIN
  EAI_BADFLAGS
  EAI_BADHINTS
  EAI_CANCELED
  EAI_FAIL
  EAI_FAMILY
  EAI_MEMORY
  EAI_NODATA
  EAI_NONAME
  EAI_OVERFLOW
  EAI_PROTOCOL
  EAI_SERVICE
  EAI_SOCKTYPE
  EALREADY
  EBADF
  EBUSY
  ECANCELED
  ECHARSET
  ECONNABORTED
  ECONNREFUSED
  ECONNRESET
  EDESTADDRREQ
  EEXIST
  EFAULT
  EFBIG
  EHOSTUNREACH
  EINTR
  EINVAL
  EIO
  EISCONN
  EISDIR
  ELOOP
  EMFILE
  EMSGSIZE
  ENAMETOOLONG
  ENETDOWN
  ENETUNREACH
  ENFILE
  ENOBUFS
  ENODEV
  ENOENT
  ENOMEM
  ENONET
  ENOPROTOOPT
  ENOSPC
  ENOSYS
  ENOTCONN
  ENOTDIR
  ENOTEMPTY
  ENOTSOCK
  ENOTSUP
  EOVERFLOW
  EPERM
  EPIPE
  EPROTO
  EPROTONOSUPPORT
  EPROTOTYPE
  ERANGE
  EROFS
  ESHUTDOWN
  ESPIPE
  ESRCH
  ETIMEDOUT
  ETXTBSY
  EXDEV
  UNKNOWN
  EOF
  ENXIO
  EMLINK
  EHOSTDOWN
  EREMOTEIO
  ENOTTY
  EFTYPE
  EILSEQ
  ESOCKTNOSUPPORT
  ENODATA
  EUNATCH
  ENOEXEC
} derive(Eq, Hash)

///|
let errno_messages : Map[Errno, String] = Map::new()

///|
let errno_errors : Map[Int, Errno] = Map::new()

///|
let errno_values : Map[Errno, Int] = Map::new()

///|
fn init {
  errno_errors[moonbit_uv_E2BIG()] = Errno::E2BIG
  errno_errors[moonbit_uv_EACCES()] = Errno::EACCES
  errno_errors[moonbit_uv_EADDRINUSE()] = Errno::EADDRINUSE
  errno_errors[moonbit_uv_EADDRNOTAVAIL()] = Errno::EADDRNOTAVAIL
  errno_errors[moonbit_uv_EAFNOSUPPORT()] = Errno::EAFNOSUPPORT
  errno_errors[moonbit_uv_EAGAIN()] = Errno::EAGAIN
  errno_errors[moonbit_uv_EAI_ADDRFAMILY()] = Errno::EAI_ADDRFAMILY
  errno_errors[moonbit_uv_EAI_AGAIN()] = Errno::EAI_AGAIN
  errno_errors[moonbit_uv_EAI_BADFLAGS()] = Errno::EAI_BADFLAGS
  errno_errors[moonbit_uv_EAI_BADHINTS()] = Errno::EAI_BADHINTS
  errno_errors[moonbit_uv_EAI_CANCELED()] = Errno::EAI_CANCELED
  errno_errors[moonbit_uv_EAI_FAIL()] = Errno::EAI_FAIL
  errno_errors[moonbit_uv_EAI_FAMILY()] = Errno::EAI_FAMILY
  errno_errors[moonbit_uv_EAI_MEMORY()] = Errno::EAI_MEMORY
  errno_errors[moonbit_uv_EAI_NODATA()] = Errno::EAI_NODATA
  errno_errors[moonbit_uv_EAI_NONAME()] = Errno::EAI_NONAME
  errno_errors[moonbit_uv_EAI_OVERFLOW()] = Errno::EAI_OVERFLOW
  errno_errors[moonbit_uv_EAI_PROTOCOL()] = Errno::EAI_PROTOCOL
  errno_errors[moonbit_uv_EAI_SERVICE()] = Errno::EAI_SERVICE
  errno_errors[moonbit_uv_EAI_SOCKTYPE()] = Errno::EAI_SOCKTYPE
  errno_errors[moonbit_uv_EALREADY()] = Errno::EALREADY
  errno_errors[moonbit_uv_EBADF()] = Errno::EBADF
  errno_errors[moonbit_uv_EBUSY()] = Errno::EBUSY
  errno_errors[moonbit_uv_ECANCELED()] = Errno::ECANCELED
  errno_errors[moonbit_uv_ECHARSET()] = Errno::ECHARSET
  errno_errors[moonbit_uv_ECONNABORTED()] = Errno::ECONNABORTED
  errno_errors[moonbit_uv_ECONNREFUSED()] = Errno::ECONNREFUSED
  errno_errors[moonbit_uv_ECONNRESET()] = Errno::ECONNRESET
  errno_errors[moonbit_uv_EDESTADDRREQ()] = Errno::EDESTADDRREQ
  errno_errors[moonbit_uv_EEXIST()] = Errno::EEXIST
  errno_errors[moonbit_uv_EFAULT()] = Errno::EFAULT
  errno_errors[moonbit_uv_EFBIG()] = Errno::EFBIG
  errno_errors[moonbit_uv_EHOSTUNREACH()] = Errno::EHOSTUNREACH
  errno_errors[moonbit_uv_EINTR()] = Errno::EINTR
  errno_errors[moonbit_uv_EINVAL()] = Errno::EINVAL
  errno_errors[moonbit_uv_EIO()] = Errno::EIO
  errno_errors[moonbit_uv_EISCONN()] = Errno::EISCONN
  errno_errors[moonbit_uv_EISDIR()] = Errno::EISDIR
  errno_errors[moonbit_uv_ELOOP()] = Errno::ELOOP
  errno_errors[moonbit_uv_EMFILE()] = Errno::EMFILE
  errno_errors[moonbit_uv_EMSGSIZE()] = Errno::EMSGSIZE
  errno_errors[moonbit_uv_ENAMETOOLONG()] = Errno::ENAMETOOLONG
  errno_errors[moonbit_uv_ENETDOWN()] = Errno::ENETDOWN
  errno_errors[moonbit_uv_ENETUNREACH()] = Errno::ENETUNREACH
  errno_errors[moonbit_uv_ENFILE()] = Errno::ENFILE
  errno_errors[moonbit_uv_ENOBUFS()] = Errno::ENOBUFS
  errno_errors[moonbit_uv_ENODEV()] = Errno::ENODEV
  errno_errors[moonbit_uv_ENOENT()] = Errno::ENOENT
  errno_errors[moonbit_uv_ENOMEM()] = Errno::ENOMEM
  errno_errors[moonbit_uv_ENONET()] = Errno::ENONET
  errno_errors[moonbit_uv_ENOPROTOOPT()] = Errno::ENOPROTOOPT
  errno_errors[moonbit_uv_ENOSPC()] = Errno::ENOSPC
  errno_errors[moonbit_uv_ENOSYS()] = Errno::ENOSYS
  errno_errors[moonbit_uv_ENOTCONN()] = Errno::ENOTCONN
  errno_errors[moonbit_uv_ENOTDIR()] = Errno::ENOTDIR
  errno_errors[moonbit_uv_ENOTEMPTY()] = Errno::ENOTEMPTY
  errno_errors[moonbit_uv_ENOTSOCK()] = Errno::ENOTSOCK
  errno_errors[moonbit_uv_ENOTSUP()] = Errno::ENOTSUP
  errno_errors[moonbit_uv_EOVERFLOW()] = Errno::EOVERFLOW
  errno_errors[moonbit_uv_EPERM()] = Errno::EPERM
  errno_errors[moonbit_uv_EPIPE()] = Errno::EPIPE
  errno_errors[moonbit_uv_EPROTO()] = Errno::EPROTO
  errno_errors[moonbit_uv_EPROTONOSUPPORT()] = Errno::EPROTONOSUPPORT
  errno_errors[moonbit_uv_EPROTOTYPE()] = Errno::EPROTOTYPE
  errno_errors[moonbit_uv_ERANGE()] = Errno::ERANGE
  errno_errors[moonbit_uv_EROFS()] = Errno::EROFS
  errno_errors[moonbit_uv_ESHUTDOWN()] = Errno::ESHUTDOWN
  errno_errors[moonbit_uv_ESPIPE()] = Errno::ESPIPE
  errno_errors[moonbit_uv_ESRCH()] = Errno::ESRCH
  errno_errors[moonbit_uv_ETIMEDOUT()] = Errno::ETIMEDOUT
  errno_errors[moonbit_uv_ETXTBSY()] = Errno::ETXTBSY
  errno_errors[moonbit_uv_EXDEV()] = Errno::EXDEV
  errno_errors[moonbit_uv_UNKNOWN()] = Errno::UNKNOWN
  errno_errors[moonbit_uv_EOF()] = Errno::EOF
  errno_errors[moonbit_uv_ENXIO()] = Errno::ENXIO
  errno_errors[moonbit_uv_EMLINK()] = Errno::EMLINK
  errno_errors[moonbit_uv_EHOSTDOWN()] = Errno::EHOSTDOWN
  errno_errors[moonbit_uv_EREMOTEIO()] = Errno::EREMOTEIO
  errno_errors[moonbit_uv_ENOTTY()] = Errno::ENOTTY
  errno_errors[moonbit_uv_EFTYPE()] = Errno::EFTYPE
  errno_errors[moonbit_uv_EILSEQ()] = Errno::EILSEQ
  errno_errors[moonbit_uv_ESOCKTNOSUPPORT()] = Errno::ESOCKTNOSUPPORT
  errno_errors[moonbit_uv_ENODATA()] = Errno::ENODATA
  errno_errors[moonbit_uv_EUNATCH()] = Errno::EUNATCH
  errno_errors[moonbit_uv_ENOEXEC()] = Errno::ENOEXEC
  for value, error in errno_errors {
    errno_values[error] = value
  }
}

///|
pub fn errno(errno : Int) -> Errno {
  errno_errors[errno].or(Errno::UNKNOWN)
}

///|
fn Errno::of_int(errno : Int) -> Errno {
  errno_errors[errno].or(Errno::UNKNOWN)
}

///|
fn Errno::to_int(self : Errno) -> Int {
  errno_values[self].or(moonbit_uv_UNKNOWN())
}

///|
pub impl Show for Errno with output(self : Errno, logger : &Logger) -> Unit {
  if errno_messages.get(self) is Some(message) {
    logger.write_string(message)
    return
  }
  let message = strerror(self.to_int())
  errno_messages[self] = message
  logger.write_string(message)
}

///|
extern "c" fn moonbit_uv_E2BIG() -> Int = "moonbit_uv_E2BIG"

///|
extern "c" fn moonbit_uv_EACCES() -> Int = "moonbit_uv_EACCES"

///|
extern "c" fn moonbit_uv_EADDRINUSE() -> Int = "moonbit_uv_EADDRINUSE"

///|
extern "c" fn moonbit_uv_EADDRNOTAVAIL() -> Int = "moonbit_uv_EADDRNOTAVAIL"

///|
extern "c" fn moonbit_uv_EAFNOSUPPORT() -> Int = "moonbit_uv_EAFNOSUPPORT"

///|
extern "c" fn moonbit_uv_EAGAIN() -> Int = "moonbit_uv_EAGAIN"

///|
extern "c" fn moonbit_uv_EAI_ADDRFAMILY() -> Int = "moonbit_uv_EAI_ADDRFAMILY"

///|
extern "c" fn moonbit_uv_EAI_AGAIN() -> Int = "moonbit_uv_EAI_AGAIN"

///|
extern "c" fn moonbit_uv_EAI_BADFLAGS() -> Int = "moonbit_uv_EAI_BADFLAGS"

///|
extern "c" fn moonbit_uv_EAI_BADHINTS() -> Int = "moonbit_uv_EAI_BADHINTS"

///|
extern "c" fn moonbit_uv_EAI_CANCELED() -> Int = "moonbit_uv_EAI_CANCELED"

///|
extern "c" fn moonbit_uv_EAI_FAIL() -> Int = "moonbit_uv_EAI_FAIL"

///|
extern "c" fn moonbit_uv_EAI_FAMILY() -> Int = "moonbit_uv_EAI_FAMILY"

///|
extern "c" fn moonbit_uv_EAI_MEMORY() -> Int = "moonbit_uv_EAI_MEMORY"

///|
extern "c" fn moonbit_uv_EAI_NODATA() -> Int = "moonbit_uv_EAI_NODATA"

///|
extern "c" fn moonbit_uv_EAI_NONAME() -> Int = "moonbit_uv_EAI_NONAME"

///|
extern "c" fn moonbit_uv_EAI_OVERFLOW() -> Int = "moonbit_uv_EAI_OVERFLOW"

///|
extern "c" fn moonbit_uv_EAI_PROTOCOL() -> Int = "moonbit_uv_EAI_PROTOCOL"

///|
extern "c" fn moonbit_uv_EAI_SERVICE() -> Int = "moonbit_uv_EAI_SERVICE"

///|
extern "c" fn moonbit_uv_EAI_SOCKTYPE() -> Int = "moonbit_uv_EAI_SOCKTYPE"

///|
extern "c" fn moonbit_uv_EALREADY() -> Int = "moonbit_uv_EALREADY"

///|
extern "c" fn moonbit_uv_EBADF() -> Int = "moonbit_uv_EBADF"

///|
extern "c" fn moonbit_uv_EBUSY() -> Int = "moonbit_uv_EBUSY"

///|
extern "c" fn moonbit_uv_ECANCELED() -> Int = "moonbit_uv_ECANCELED"

///|
extern "c" fn moonbit_uv_ECHARSET() -> Int = "moonbit_uv_ECHARSET"

///|
extern "c" fn moonbit_uv_ECONNABORTED() -> Int = "moonbit_uv_ECONNABORTED"

///|
extern "c" fn moonbit_uv_ECONNREFUSED() -> Int = "moonbit_uv_ECONNREFUSED"

///|
extern "c" fn moonbit_uv_ECONNRESET() -> Int = "moonbit_uv_ECONNRESET"

///|
extern "c" fn moonbit_uv_EDESTADDRREQ() -> Int = "moonbit_uv_EDESTADDRREQ"

///|
extern "c" fn moonbit_uv_EEXIST() -> Int = "moonbit_uv_EEXIST"

///|
extern "c" fn moonbit_uv_EFAULT() -> Int = "moonbit_uv_EFAULT"

///|
extern "c" fn moonbit_uv_EFBIG() -> Int = "moonbit_uv_EFBIG"

///|
extern "c" fn moonbit_uv_EHOSTUNREACH() -> Int = "moonbit_uv_EHOSTUNREACH"

///|
extern "c" fn moonbit_uv_EINTR() -> Int = "moonbit_uv_EINTR"

///|
extern "c" fn moonbit_uv_EINVAL() -> Int = "moonbit_uv_EINVAL"

///|
extern "c" fn moonbit_uv_EIO() -> Int = "moonbit_uv_EIO"

///|
extern "c" fn moonbit_uv_EISCONN() -> Int = "moonbit_uv_EISCONN"

///|
extern "c" fn moonbit_uv_EISDIR() -> Int = "moonbit_uv_EISDIR"

///|
extern "c" fn moonbit_uv_ELOOP() -> Int = "moonbit_uv_ELOOP"

///|
extern "c" fn moonbit_uv_EMFILE() -> Int = "moonbit_uv_EMFILE"

///|
extern "c" fn moonbit_uv_EMSGSIZE() -> Int = "moonbit_uv_EMSGSIZE"

///|
extern "c" fn moonbit_uv_ENAMETOOLONG() -> Int = "moonbit_uv_ENAMETOOLONG"

///|
extern "c" fn moonbit_uv_ENETDOWN() -> Int = "moonbit_uv_ENETDOWN"

///|
extern "c" fn moonbit_uv_ENETUNREACH() -> Int = "moonbit_uv_ENETUNREACH"

///|
extern "c" fn moonbit_uv_ENFILE() -> Int = "moonbit_uv_ENFILE"

///|
extern "c" fn moonbit_uv_ENOBUFS() -> Int = "moonbit_uv_ENOBUFS"

///|
extern "c" fn moonbit_uv_ENODEV() -> Int = "moonbit_uv_ENODEV"

///|
extern "c" fn moonbit_uv_ENOENT() -> Int = "moonbit_uv_ENOENT"

///|
extern "c" fn moonbit_uv_ENOMEM() -> Int = "moonbit_uv_ENOMEM"

///|
extern "c" fn moonbit_uv_ENONET() -> Int = "moonbit_uv_ENONET"

///|
extern "c" fn moonbit_uv_ENOPROTOOPT() -> Int = "moonbit_uv_ENOPROTOOPT"

///|
extern "c" fn moonbit_uv_ENOSPC() -> Int = "moonbit_uv_ENOSPC"

///|
extern "c" fn moonbit_uv_ENOSYS() -> Int = "moonbit_uv_ENOSYS"

///|
extern "c" fn moonbit_uv_ENOTCONN() -> Int = "moonbit_uv_ENOTCONN"

///|
extern "c" fn moonbit_uv_ENOTDIR() -> Int = "moonbit_uv_ENOTDIR"

///|
extern "c" fn moonbit_uv_ENOTEMPTY() -> Int = "moonbit_uv_ENOTEMPTY"

///|
extern "c" fn moonbit_uv_ENOTSOCK() -> Int = "moonbit_uv_ENOTSOCK"

///|
extern "c" fn moonbit_uv_ENOTSUP() -> Int = "moonbit_uv_ENOTSUP"

///|
extern "c" fn moonbit_uv_EOVERFLOW() -> Int = "moonbit_uv_EOVERFLOW"

///|
extern "c" fn moonbit_uv_EPERM() -> Int = "moonbit_uv_EPERM"

///|
extern "c" fn moonbit_uv_EPIPE() -> Int = "moonbit_uv_EPIPE"

///|
extern "c" fn moonbit_uv_EPROTO() -> Int = "moonbit_uv_EPROTO"

///|
extern "c" fn moonbit_uv_EPROTONOSUPPORT() -> Int = "moonbit_uv_EPROTONOSUPPORT"

///|
extern "c" fn moonbit_uv_EPROTOTYPE() -> Int = "moonbit_uv_EPROTOTYPE"

///|
extern "c" fn moonbit_uv_ERANGE() -> Int = "moonbit_uv_ERANGE"

///|
extern "c" fn moonbit_uv_EROFS() -> Int = "moonbit_uv_EROFS"

///|
extern "c" fn moonbit_uv_ESHUTDOWN() -> Int = "moonbit_uv_ESHUTDOWN"

///|
extern "c" fn moonbit_uv_ESPIPE() -> Int = "moonbit_uv_ESPIPE"

///|
extern "c" fn moonbit_uv_ESRCH() -> Int = "moonbit_uv_ESRCH"

///|
extern "c" fn moonbit_uv_ETIMEDOUT() -> Int = "moonbit_uv_ETIMEDOUT"

///|
extern "c" fn moonbit_uv_ETXTBSY() -> Int = "moonbit_uv_ETXTBSY"

///|
extern "c" fn moonbit_uv_EXDEV() -> Int = "moonbit_uv_EXDEV"

///|
extern "c" fn moonbit_uv_UNKNOWN() -> Int = "moonbit_uv_UNKNOWN"

///|
extern "c" fn moonbit_uv_EOF() -> Int = "moonbit_uv_EOF"

///|
extern "c" fn moonbit_uv_ENXIO() -> Int = "moonbit_uv_ENXIO"

///|
extern "c" fn moonbit_uv_EMLINK() -> Int = "moonbit_uv_EMLINK"

///|
extern "c" fn moonbit_uv_EHOSTDOWN() -> Int = "moonbit_uv_EHOSTDOWN"

///|
extern "c" fn moonbit_uv_EREMOTEIO() -> Int = "moonbit_uv_EREMOTEIO"

///|
extern "c" fn moonbit_uv_ENOTTY() -> Int = "moonbit_uv_ENOTTY"

///|
extern "c" fn moonbit_uv_EFTYPE() -> Int = "moonbit_uv_EFTYPE"

///|
extern "c" fn moonbit_uv_EILSEQ() -> Int = "moonbit_uv_EILSEQ"

///|
extern "c" fn moonbit_uv_ESOCKTNOSUPPORT() -> Int = "moonbit_uv_ESOCKTNOSUPPORT"

///|
extern "c" fn moonbit_uv_ENODATA() -> Int = "moonbit_uv_ENODATA"

///|
extern "c" fn moonbit_uv_EUNATCH() -> Int = "moonbit_uv_EUNATCH"

///|
extern "c" fn moonbit_uv_ENOEXEC() -> Int = "moonbit_uv_ENOEXEC"
