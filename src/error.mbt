///|
extern "c" fn strerror_r(err : Int, bytes : Bytes) -> Unit = "moonbit_uv_strerror_r"

///|
fn strerror(errno : Int) -> String {
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
pub enum Status {
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
pub type! Errno Status derive(Eq, Hash)

///|
let errno_messages : Map[Errno, String] = Map::new()

///|
let errno_errors : Map[Int, Errno] = Map::new()

///|
let errno_values : Map[Errno, Int] = Map::new()

///|
fn init {
  errno_errors[uv_E2BIG()] = Errno(Status::E2BIG)
  errno_errors[uv_EACCES()] = Errno(Status::EACCES)
  errno_errors[uv_EADDRINUSE()] = Errno(Status::EADDRINUSE)
  errno_errors[uv_EADDRNOTAVAIL()] = Errno(Status::EADDRNOTAVAIL)
  errno_errors[uv_EAFNOSUPPORT()] = Errno(Status::EAFNOSUPPORT)
  errno_errors[uv_EAGAIN()] = Errno(Status::EAGAIN)
  errno_errors[uv_EAI_ADDRFAMILY()] = Errno(Status::EAI_ADDRFAMILY)
  errno_errors[uv_EAI_AGAIN()] = Errno(Status::EAI_AGAIN)
  errno_errors[uv_EAI_BADFLAGS()] = Errno(Status::EAI_BADFLAGS)
  errno_errors[uv_EAI_BADHINTS()] = Errno(Status::EAI_BADHINTS)
  errno_errors[uv_EAI_CANCELED()] = Errno(Status::EAI_CANCELED)
  errno_errors[uv_EAI_FAIL()] = Errno(Status::EAI_FAIL)
  errno_errors[uv_EAI_FAMILY()] = Errno(Status::EAI_FAMILY)
  errno_errors[uv_EAI_MEMORY()] = Errno(Status::EAI_MEMORY)
  errno_errors[uv_EAI_NODATA()] = Errno(Status::EAI_NODATA)
  errno_errors[uv_EAI_NONAME()] = Errno(Status::EAI_NONAME)
  errno_errors[uv_EAI_OVERFLOW()] = Errno(Status::EAI_OVERFLOW)
  errno_errors[uv_EAI_PROTOCOL()] = Errno(Status::EAI_PROTOCOL)
  errno_errors[uv_EAI_SERVICE()] = Errno(Status::EAI_SERVICE)
  errno_errors[uv_EAI_SOCKTYPE()] = Errno(Status::EAI_SOCKTYPE)
  errno_errors[uv_EALREADY()] = Errno(Status::EALREADY)
  errno_errors[uv_EBADF()] = Errno(Status::EBADF)
  errno_errors[uv_EBUSY()] = Errno(Status::EBUSY)
  errno_errors[uv_ECANCELED()] = Errno(Status::ECANCELED)
  errno_errors[uv_ECHARSET()] = Errno(Status::ECHARSET)
  errno_errors[uv_ECONNABORTED()] = Errno(Status::ECONNABORTED)
  errno_errors[uv_ECONNREFUSED()] = Errno(Status::ECONNREFUSED)
  errno_errors[uv_ECONNRESET()] = Errno(Status::ECONNRESET)
  errno_errors[uv_EDESTADDRREQ()] = Errno(Status::EDESTADDRREQ)
  errno_errors[uv_EEXIST()] = Errno(Status::EEXIST)
  errno_errors[uv_EFAULT()] = Errno(Status::EFAULT)
  errno_errors[uv_EFBIG()] = Errno(Status::EFBIG)
  errno_errors[uv_EHOSTUNREACH()] = Errno(Status::EHOSTUNREACH)
  errno_errors[uv_EINTR()] = Errno(Status::EINTR)
  errno_errors[uv_EINVAL()] = Errno(Status::EINVAL)
  errno_errors[uv_EIO()] = Errno(Status::EIO)
  errno_errors[uv_EISCONN()] = Errno(Status::EISCONN)
  errno_errors[uv_EISDIR()] = Errno(Status::EISDIR)
  errno_errors[uv_ELOOP()] = Errno(Status::ELOOP)
  errno_errors[uv_EMFILE()] = Errno(Status::EMFILE)
  errno_errors[uv_EMSGSIZE()] = Errno(Status::EMSGSIZE)
  errno_errors[uv_ENAMETOOLONG()] = Errno(Status::ENAMETOOLONG)
  errno_errors[uv_ENETDOWN()] = Errno(Status::ENETDOWN)
  errno_errors[uv_ENETUNREACH()] = Errno(Status::ENETUNREACH)
  errno_errors[uv_ENFILE()] = Errno(Status::ENFILE)
  errno_errors[uv_ENOBUFS()] = Errno(Status::ENOBUFS)
  errno_errors[uv_ENODEV()] = Errno(Status::ENODEV)
  errno_errors[uv_ENOENT()] = Errno(Status::ENOENT)
  errno_errors[uv_ENOMEM()] = Errno(Status::ENOMEM)
  errno_errors[uv_ENONET()] = Errno(Status::ENONET)
  errno_errors[uv_ENOPROTOOPT()] = Errno(Status::ENOPROTOOPT)
  errno_errors[uv_ENOSPC()] = Errno(Status::ENOSPC)
  errno_errors[uv_ENOSYS()] = Errno(Status::ENOSYS)
  errno_errors[uv_ENOTCONN()] = Errno(Status::ENOTCONN)
  errno_errors[uv_ENOTDIR()] = Errno(Status::ENOTDIR)
  errno_errors[uv_ENOTEMPTY()] = Errno(Status::ENOTEMPTY)
  errno_errors[uv_ENOTSOCK()] = Errno(Status::ENOTSOCK)
  errno_errors[uv_ENOTSUP()] = Errno(Status::ENOTSUP)
  errno_errors[uv_EOVERFLOW()] = Errno(Status::EOVERFLOW)
  errno_errors[uv_EPERM()] = Errno(Status::EPERM)
  errno_errors[uv_EPIPE()] = Errno(Status::EPIPE)
  errno_errors[uv_EPROTO()] = Errno(Status::EPROTO)
  errno_errors[uv_EPROTONOSUPPORT()] = Errno(Status::EPROTONOSUPPORT)
  errno_errors[uv_EPROTOTYPE()] = Errno(Status::EPROTOTYPE)
  errno_errors[uv_ERANGE()] = Errno(Status::ERANGE)
  errno_errors[uv_EROFS()] = Errno(Status::EROFS)
  errno_errors[uv_ESHUTDOWN()] = Errno(Status::ESHUTDOWN)
  errno_errors[uv_ESPIPE()] = Errno(Status::ESPIPE)
  errno_errors[uv_ESRCH()] = Errno(Status::ESRCH)
  errno_errors[uv_ETIMEDOUT()] = Errno(Status::ETIMEDOUT)
  errno_errors[uv_ETXTBSY()] = Errno(Status::ETXTBSY)
  errno_errors[uv_EXDEV()] = Errno(Status::EXDEV)
  errno_errors[uv_UNKNOWN()] = Errno(Status::UNKNOWN)
  errno_errors[uv_EOF()] = Errno(Status::EOF)
  errno_errors[uv_ENXIO()] = Errno(Status::ENXIO)
  errno_errors[uv_EMLINK()] = Errno(Status::EMLINK)
  errno_errors[uv_EHOSTDOWN()] = Errno(Status::EHOSTDOWN)
  errno_errors[uv_EREMOTEIO()] = Errno(Status::EREMOTEIO)
  errno_errors[uv_ENOTTY()] = Errno(Status::ENOTTY)
  errno_errors[uv_EFTYPE()] = Errno(Status::EFTYPE)
  errno_errors[uv_EILSEQ()] = Errno(Status::EILSEQ)
  errno_errors[uv_ESOCKTNOSUPPORT()] = Errno(Status::ESOCKTNOSUPPORT)
  errno_errors[uv_ENODATA()] = Errno(Status::ENODATA)
  errno_errors[uv_EUNATCH()] = Errno(Status::EUNATCH)
  errno_errors[uv_ENOEXEC()] = Errno(Status::ENOEXEC)
  for value, error in errno_errors {
    errno_values[error] = value
  }
}

///|
pub fn errno(errno : Int) -> Errno {
  errno_errors[errno].or(Errno(Status::UNKNOWN))
}

///|
fn Errno::of_int(errno : Int) -> Errno {
  errno_errors[errno].or(Errno(Status::UNKNOWN))
}

///|
fn Errno::to_int(self : Errno) -> Int {
  errno_values[self].or(uv_UNKNOWN())
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
extern "c" fn uv_E2BIG() -> Int = "moonbit_uv_E2BIG"

///|
extern "c" fn uv_EACCES() -> Int = "moonbit_uv_EACCES"

///|
extern "c" fn uv_EADDRINUSE() -> Int = "moonbit_uv_EADDRINUSE"

///|
extern "c" fn uv_EADDRNOTAVAIL() -> Int = "moonbit_uv_EADDRNOTAVAIL"

///|
extern "c" fn uv_EAFNOSUPPORT() -> Int = "moonbit_uv_EAFNOSUPPORT"

///|
extern "c" fn uv_EAGAIN() -> Int = "moonbit_uv_EAGAIN"

///|
extern "c" fn uv_EAI_ADDRFAMILY() -> Int = "moonbit_uv_EAI_ADDRFAMILY"

///|
extern "c" fn uv_EAI_AGAIN() -> Int = "moonbit_uv_EAI_AGAIN"

///|
extern "c" fn uv_EAI_BADFLAGS() -> Int = "moonbit_uv_EAI_BADFLAGS"

///|
extern "c" fn uv_EAI_BADHINTS() -> Int = "moonbit_uv_EAI_BADHINTS"

///|
extern "c" fn uv_EAI_CANCELED() -> Int = "moonbit_uv_EAI_CANCELED"

///|
extern "c" fn uv_EAI_FAIL() -> Int = "moonbit_uv_EAI_FAIL"

///|
extern "c" fn uv_EAI_FAMILY() -> Int = "moonbit_uv_EAI_FAMILY"

///|
extern "c" fn uv_EAI_MEMORY() -> Int = "moonbit_uv_EAI_MEMORY"

///|
extern "c" fn uv_EAI_NODATA() -> Int = "moonbit_uv_EAI_NODATA"

///|
extern "c" fn uv_EAI_NONAME() -> Int = "moonbit_uv_EAI_NONAME"

///|
extern "c" fn uv_EAI_OVERFLOW() -> Int = "moonbit_uv_EAI_OVERFLOW"

///|
extern "c" fn uv_EAI_PROTOCOL() -> Int = "moonbit_uv_EAI_PROTOCOL"

///|
extern "c" fn uv_EAI_SERVICE() -> Int = "moonbit_uv_EAI_SERVICE"

///|
extern "c" fn uv_EAI_SOCKTYPE() -> Int = "moonbit_uv_EAI_SOCKTYPE"

///|
extern "c" fn uv_EALREADY() -> Int = "moonbit_uv_EALREADY"

///|
extern "c" fn uv_EBADF() -> Int = "moonbit_uv_EBADF"

///|
extern "c" fn uv_EBUSY() -> Int = "moonbit_uv_EBUSY"

///|
extern "c" fn uv_ECANCELED() -> Int = "moonbit_uv_ECANCELED"

///|
extern "c" fn uv_ECHARSET() -> Int = "moonbit_uv_ECHARSET"

///|
extern "c" fn uv_ECONNABORTED() -> Int = "moonbit_uv_ECONNABORTED"

///|
extern "c" fn uv_ECONNREFUSED() -> Int = "moonbit_uv_ECONNREFUSED"

///|
extern "c" fn uv_ECONNRESET() -> Int = "moonbit_uv_ECONNRESET"

///|
extern "c" fn uv_EDESTADDRREQ() -> Int = "moonbit_uv_EDESTADDRREQ"

///|
extern "c" fn uv_EEXIST() -> Int = "moonbit_uv_EEXIST"

///|
extern "c" fn uv_EFAULT() -> Int = "moonbit_uv_EFAULT"

///|
extern "c" fn uv_EFBIG() -> Int = "moonbit_uv_EFBIG"

///|
extern "c" fn uv_EHOSTUNREACH() -> Int = "moonbit_uv_EHOSTUNREACH"

///|
extern "c" fn uv_EINTR() -> Int = "moonbit_uv_EINTR"

///|
extern "c" fn uv_EINVAL() -> Int = "moonbit_uv_EINVAL"

///|
extern "c" fn uv_EIO() -> Int = "moonbit_uv_EIO"

///|
extern "c" fn uv_EISCONN() -> Int = "moonbit_uv_EISCONN"

///|
extern "c" fn uv_EISDIR() -> Int = "moonbit_uv_EISDIR"

///|
extern "c" fn uv_ELOOP() -> Int = "moonbit_uv_ELOOP"

///|
extern "c" fn uv_EMFILE() -> Int = "moonbit_uv_EMFILE"

///|
extern "c" fn uv_EMSGSIZE() -> Int = "moonbit_uv_EMSGSIZE"

///|
extern "c" fn uv_ENAMETOOLONG() -> Int = "moonbit_uv_ENAMETOOLONG"

///|
extern "c" fn uv_ENETDOWN() -> Int = "moonbit_uv_ENETDOWN"

///|
extern "c" fn uv_ENETUNREACH() -> Int = "moonbit_uv_ENETUNREACH"

///|
extern "c" fn uv_ENFILE() -> Int = "moonbit_uv_ENFILE"

///|
extern "c" fn uv_ENOBUFS() -> Int = "moonbit_uv_ENOBUFS"

///|
extern "c" fn uv_ENODEV() -> Int = "moonbit_uv_ENODEV"

///|
extern "c" fn uv_ENOENT() -> Int = "moonbit_uv_ENOENT"

///|
extern "c" fn uv_ENOMEM() -> Int = "moonbit_uv_ENOMEM"

///|
extern "c" fn uv_ENONET() -> Int = "moonbit_uv_ENONET"

///|
extern "c" fn uv_ENOPROTOOPT() -> Int = "moonbit_uv_ENOPROTOOPT"

///|
extern "c" fn uv_ENOSPC() -> Int = "moonbit_uv_ENOSPC"

///|
extern "c" fn uv_ENOSYS() -> Int = "moonbit_uv_ENOSYS"

///|
extern "c" fn uv_ENOTCONN() -> Int = "moonbit_uv_ENOTCONN"

///|
extern "c" fn uv_ENOTDIR() -> Int = "moonbit_uv_ENOTDIR"

///|
extern "c" fn uv_ENOTEMPTY() -> Int = "moonbit_uv_ENOTEMPTY"

///|
extern "c" fn uv_ENOTSOCK() -> Int = "moonbit_uv_ENOTSOCK"

///|
extern "c" fn uv_ENOTSUP() -> Int = "moonbit_uv_ENOTSUP"

///|
extern "c" fn uv_EOVERFLOW() -> Int = "moonbit_uv_EOVERFLOW"

///|
extern "c" fn uv_EPERM() -> Int = "moonbit_uv_EPERM"

///|
extern "c" fn uv_EPIPE() -> Int = "moonbit_uv_EPIPE"

///|
extern "c" fn uv_EPROTO() -> Int = "moonbit_uv_EPROTO"

///|
extern "c" fn uv_EPROTONOSUPPORT() -> Int = "moonbit_uv_EPROTONOSUPPORT"

///|
extern "c" fn uv_EPROTOTYPE() -> Int = "moonbit_uv_EPROTOTYPE"

///|
extern "c" fn uv_ERANGE() -> Int = "moonbit_uv_ERANGE"

///|
extern "c" fn uv_EROFS() -> Int = "moonbit_uv_EROFS"

///|
extern "c" fn uv_ESHUTDOWN() -> Int = "moonbit_uv_ESHUTDOWN"

///|
extern "c" fn uv_ESPIPE() -> Int = "moonbit_uv_ESPIPE"

///|
extern "c" fn uv_ESRCH() -> Int = "moonbit_uv_ESRCH"

///|
extern "c" fn uv_ETIMEDOUT() -> Int = "moonbit_uv_ETIMEDOUT"

///|
extern "c" fn uv_ETXTBSY() -> Int = "moonbit_uv_ETXTBSY"

///|
extern "c" fn uv_EXDEV() -> Int = "moonbit_uv_EXDEV"

///|
extern "c" fn uv_UNKNOWN() -> Int = "moonbit_uv_UNKNOWN"

///|
extern "c" fn uv_EOF() -> Int = "moonbit_uv_EOF"

///|
extern "c" fn uv_ENXIO() -> Int = "moonbit_uv_ENXIO"

///|
extern "c" fn uv_EMLINK() -> Int = "moonbit_uv_EMLINK"

///|
extern "c" fn uv_EHOSTDOWN() -> Int = "moonbit_uv_EHOSTDOWN"

///|
extern "c" fn uv_EREMOTEIO() -> Int = "moonbit_uv_EREMOTEIO"

///|
extern "c" fn uv_ENOTTY() -> Int = "moonbit_uv_ENOTTY"

///|
extern "c" fn uv_EFTYPE() -> Int = "moonbit_uv_EFTYPE"

///|
extern "c" fn uv_EILSEQ() -> Int = "moonbit_uv_EILSEQ"

///|
extern "c" fn uv_ESOCKTNOSUPPORT() -> Int = "moonbit_uv_ESOCKTNOSUPPORT"

///|
extern "c" fn uv_ENODATA() -> Int = "moonbit_uv_ENODATA"

///|
extern "c" fn uv_EUNATCH() -> Int = "moonbit_uv_EUNATCH"

///|
extern "c" fn uv_ENOEXEC() -> Int = "moonbit_uv_ENOEXEC"
