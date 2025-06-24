///|
extern "c" fn strerror_r(err : Int, bytes : Bytes) = "moonbit_uv_strerror_r"

///|
fn strerror(errno : Int) -> @string.View {
  let bytes = Bytes::make(256, 0)
  strerror_r(errno, bytes)
  let buffer = @buffer.new()
  for byte in bytes {
    if byte == 0 {
      break
    }
    buffer.write_byte(byte)
  }
  @encoding.decode_lossy(encoding=UTF8, buffer.to_bytes())
}

///|
#visibility(change_to="readonly")
pub(all) enum Status {
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
pub suberror Errno Status derive(Eq, Hash)

///|
let errno_messages : Map[Errno, @string.View] = Map::new()

///|
let errno_errors : Map[Int, Errno] = Map::new()

///|
let errno_values : Map[Errno, Int] = Map::new()

///|
fn init {
  errno_errors[uv_E2BIG()] = Errno(E2BIG)
  errno_errors[uv_EACCES()] = Errno(EACCES)
  errno_errors[uv_EADDRINUSE()] = Errno(EADDRINUSE)
  errno_errors[uv_EADDRNOTAVAIL()] = Errno(EADDRNOTAVAIL)
  errno_errors[uv_EAFNOSUPPORT()] = Errno(EAFNOSUPPORT)
  errno_errors[uv_EAGAIN()] = Errno(EAGAIN)
  errno_errors[uv_EAI_ADDRFAMILY()] = Errno(EAI_ADDRFAMILY)
  errno_errors[uv_EAI_AGAIN()] = Errno(EAI_AGAIN)
  errno_errors[uv_EAI_BADFLAGS()] = Errno(EAI_BADFLAGS)
  errno_errors[uv_EAI_BADHINTS()] = Errno(EAI_BADHINTS)
  errno_errors[uv_EAI_CANCELED()] = Errno(EAI_CANCELED)
  errno_errors[uv_EAI_FAIL()] = Errno(EAI_FAIL)
  errno_errors[uv_EAI_FAMILY()] = Errno(EAI_FAMILY)
  errno_errors[uv_EAI_MEMORY()] = Errno(EAI_MEMORY)
  errno_errors[uv_EAI_NODATA()] = Errno(EAI_NODATA)
  errno_errors[uv_EAI_NONAME()] = Errno(EAI_NONAME)
  errno_errors[uv_EAI_OVERFLOW()] = Errno(EAI_OVERFLOW)
  errno_errors[uv_EAI_PROTOCOL()] = Errno(EAI_PROTOCOL)
  errno_errors[uv_EAI_SERVICE()] = Errno(EAI_SERVICE)
  errno_errors[uv_EAI_SOCKTYPE()] = Errno(EAI_SOCKTYPE)
  errno_errors[uv_EALREADY()] = Errno(EALREADY)
  errno_errors[uv_EBADF()] = Errno(EBADF)
  errno_errors[uv_EBUSY()] = Errno(EBUSY)
  errno_errors[uv_ECANCELED()] = Errno(ECANCELED)
  errno_errors[uv_ECHARSET()] = Errno(ECHARSET)
  errno_errors[uv_ECONNABORTED()] = Errno(ECONNABORTED)
  errno_errors[uv_ECONNREFUSED()] = Errno(ECONNREFUSED)
  errno_errors[uv_ECONNRESET()] = Errno(ECONNRESET)
  errno_errors[uv_EDESTADDRREQ()] = Errno(EDESTADDRREQ)
  errno_errors[uv_EEXIST()] = Errno(EEXIST)
  errno_errors[uv_EFAULT()] = Errno(EFAULT)
  errno_errors[uv_EFBIG()] = Errno(EFBIG)
  errno_errors[uv_EHOSTUNREACH()] = Errno(EHOSTUNREACH)
  errno_errors[uv_EINTR()] = Errno(EINTR)
  errno_errors[uv_EINVAL()] = Errno(EINVAL)
  errno_errors[uv_EIO()] = Errno(EIO)
  errno_errors[uv_EISCONN()] = Errno(EISCONN)
  errno_errors[uv_EISDIR()] = Errno(EISDIR)
  errno_errors[uv_ELOOP()] = Errno(ELOOP)
  errno_errors[uv_EMFILE()] = Errno(EMFILE)
  errno_errors[uv_EMSGSIZE()] = Errno(EMSGSIZE)
  errno_errors[uv_ENAMETOOLONG()] = Errno(ENAMETOOLONG)
  errno_errors[uv_ENETDOWN()] = Errno(ENETDOWN)
  errno_errors[uv_ENETUNREACH()] = Errno(ENETUNREACH)
  errno_errors[uv_ENFILE()] = Errno(ENFILE)
  errno_errors[uv_ENOBUFS()] = Errno(ENOBUFS)
  errno_errors[uv_ENODEV()] = Errno(ENODEV)
  errno_errors[uv_ENOENT()] = Errno(ENOENT)
  errno_errors[uv_ENOMEM()] = Errno(ENOMEM)
  errno_errors[uv_ENONET()] = Errno(ENONET)
  errno_errors[uv_ENOPROTOOPT()] = Errno(ENOPROTOOPT)
  errno_errors[uv_ENOSPC()] = Errno(ENOSPC)
  errno_errors[uv_ENOSYS()] = Errno(ENOSYS)
  errno_errors[uv_ENOTCONN()] = Errno(ENOTCONN)
  errno_errors[uv_ENOTDIR()] = Errno(ENOTDIR)
  errno_errors[uv_ENOTEMPTY()] = Errno(ENOTEMPTY)
  errno_errors[uv_ENOTSOCK()] = Errno(ENOTSOCK)
  errno_errors[uv_ENOTSUP()] = Errno(ENOTSUP)
  errno_errors[uv_EOVERFLOW()] = Errno(EOVERFLOW)
  errno_errors[uv_EPERM()] = Errno(EPERM)
  errno_errors[uv_EPIPE()] = Errno(EPIPE)
  errno_errors[uv_EPROTO()] = Errno(EPROTO)
  errno_errors[uv_EPROTONOSUPPORT()] = Errno(EPROTONOSUPPORT)
  errno_errors[uv_EPROTOTYPE()] = Errno(EPROTOTYPE)
  errno_errors[uv_ERANGE()] = Errno(ERANGE)
  errno_errors[uv_EROFS()] = Errno(EROFS)
  errno_errors[uv_ESHUTDOWN()] = Errno(ESHUTDOWN)
  errno_errors[uv_ESPIPE()] = Errno(ESPIPE)
  errno_errors[uv_ESRCH()] = Errno(ESRCH)
  errno_errors[uv_ETIMEDOUT()] = Errno(ETIMEDOUT)
  errno_errors[uv_ETXTBSY()] = Errno(ETXTBSY)
  errno_errors[uv_EXDEV()] = Errno(EXDEV)
  errno_errors[uv_UNKNOWN()] = Errno(UNKNOWN)
  errno_errors[uv_EOF()] = Errno(EOF)
  errno_errors[uv_ENXIO()] = Errno(ENXIO)
  errno_errors[uv_EMLINK()] = Errno(EMLINK)
  errno_errors[uv_EHOSTDOWN()] = Errno(EHOSTDOWN)
  errno_errors[uv_EREMOTEIO()] = Errno(EREMOTEIO)
  errno_errors[uv_ENOTTY()] = Errno(ENOTTY)
  errno_errors[uv_EFTYPE()] = Errno(EFTYPE)
  errno_errors[uv_EILSEQ()] = Errno(EILSEQ)
  errno_errors[uv_ESOCKTNOSUPPORT()] = Errno(ESOCKTNOSUPPORT)
  errno_errors[uv_ENODATA()] = Errno(ENODATA)
  errno_errors[uv_EUNATCH()] = Errno(EUNATCH)
  errno_errors[uv_ENOEXEC()] = Errno(ENOEXEC)
  for value, error in errno_errors {
    errno_values[error] = value
  }
}

///|
#deprecated
pub fn errno(errno : Status) -> Errno {
  Errno(errno)
}

///|
fn Errno::of_int(errno : Int) -> Errno {
  errno_errors.get(errno).or(Errno(UNKNOWN))
}

///|
fn Errno::to_int(self : Errno) -> Int {
  errno_values.get(self).or(uv_UNKNOWN())
}

///|
pub impl Show for Errno with output(self : Errno, logger : &Logger) -> Unit {
  if errno_messages.get(self) is Some(message) {
    logger.write_string(message.to_string())
    return
  }
  let message = strerror(self.to_int())
  errno_messages[self] = message
  logger.write_string(message.to_string())
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

///|
let _E2BIG : Int = uv_E2BIG()

///|
let _EACCES : Int = uv_EACCES()

///|
let _EADDRINUSE : Int = uv_EADDRINUSE()

///|
let _EADDRNOTAVAIL : Int = uv_EADDRNOTAVAIL()

///|
let _EAFNOSUPPORT : Int = uv_EAFNOSUPPORT()

///|
let _EAGAIN : Int = uv_EAGAIN()

///|
let _EAI_ADDRFAMILY : Int = uv_EAI_ADDRFAMILY()

///|
let _EAI_AGAIN : Int = uv_EAI_AGAIN()

///|
let _EAI_BADFLAGS : Int = uv_EAI_BADFLAGS()

///|
let _EAI_BADHINTS : Int = uv_EAI_BADHINTS()

///|
let _EAI_CANCELED : Int = uv_EAI_CANCELED()

///|
let _EAI_FAIL : Int = uv_EAI_FAIL()

///|
let _EAI_FAMILY : Int = uv_EAI_FAMILY()

///|
let _EAI_MEMORY : Int = uv_EAI_MEMORY()

///|
let _EAI_NODATA : Int = uv_EAI_NODATA()

///|
let _EAI_NONAME : Int = uv_EAI_NONAME()

///|
let _EAI_OVERFLOW : Int = uv_EAI_OVERFLOW()

///|
let _EAI_PROTOCOL : Int = uv_EAI_PROTOCOL()

///|
let _EAI_SERVICE : Int = uv_EAI_SERVICE()

///|
let _EAI_SOCKTYPE : Int = uv_EAI_SOCKTYPE()

///|
let _EALREADY : Int = uv_EALREADY()

///|
let _EBADF : Int = uv_EBADF()

///|
let _EBUSY : Int = uv_EBUSY()

///|
let _ECANCELED : Int = uv_ECANCELED()

///|
let _ECHARSET : Int = uv_ECHARSET()

///|
let _ECONNABORTED : Int = uv_ECONNABORTED()

///|
let _ECONNREFUSED : Int = uv_ECONNREFUSED()

///|
let _ECONNRESET : Int = uv_ECONNRESET()

///|
let _EDESTADDRREQ : Int = uv_EDESTADDRREQ()

///|
let _EEXIST : Int = uv_EEXIST()

///|
let _EFAULT : Int = uv_EFAULT()

///|
let _EFBIG : Int = uv_EFBIG()

///|
let _EHOSTUNREACH : Int = uv_EHOSTUNREACH()

///|
let _EINTR : Int = uv_EINTR()

///|
let _EINVAL : Int = uv_EINVAL()

///|
let _EIO : Int = uv_EIO()

///|
let _EISCONN : Int = uv_EISCONN()

///|
let _EISDIR : Int = uv_EISDIR()

///|
let _ELOOP : Int = uv_ELOOP()

///|
let _EMFILE : Int = uv_EMFILE()

///|
let _EMSGSIZE : Int = uv_EMSGSIZE()

///|
let _ENAMETOOLONG : Int = uv_ENAMETOOLONG()

///|
let _ENETDOWN : Int = uv_ENETDOWN()

///|
let _ENETUNREACH : Int = uv_ENETUNREACH()

///|
let _ENFILE : Int = uv_ENFILE()

///|
let _ENOBUFS : Int = uv_ENOBUFS()

///|
let _ENODEV : Int = uv_ENODEV()

///|
let _ENOENT : Int = uv_ENOENT()

///|
let _ENOMEM : Int = uv_ENOMEM()

///|
let _ENONET : Int = uv_ENONET()

///|
let _ENOPROTOOPT : Int = uv_ENOPROTOOPT()

///|
let _ENOSPC : Int = uv_ENOSPC()

///|
let _ENOSYS : Int = uv_ENOSYS()

///|
let _ENOTCONN : Int = uv_ENOTCONN()

///|
let _ENOTDIR : Int = uv_ENOTDIR()

///|
let _ENOTEMPTY : Int = uv_ENOTEMPTY()

///|
let _ENOTSOCK : Int = uv_ENOTSOCK()

///|
let _ENOTSUP : Int = uv_ENOTSUP()

///|
let _EOVERFLOW : Int = uv_EOVERFLOW()

///|
let _EPERM : Int = uv_EPERM()

///|
let _EPIPE : Int = uv_EPIPE()

///|
let _EPROTO : Int = uv_EPROTO()

///|
let _EPROTONOSUPPORT : Int = uv_EPROTONOSUPPORT()

///|
let _EPROTOTYPE : Int = uv_EPROTOTYPE()

///|
let _ERANGE : Int = uv_ERANGE()

///|
let _EROFS : Int = uv_EROFS()

///|
let _ESHUTDOWN : Int = uv_ESHUTDOWN()

///|
let _ESPIPE : Int = uv_ESPIPE()

///|
let _ESRCH : Int = uv_ESRCH()

///|
let _ETIMEDOUT : Int = uv_ETIMEDOUT()

///|
let _ETXTBSY : Int = uv_ETXTBSY()

///|
let _EXDEV : Int = uv_EXDEV()

///|
let _UNKNOWN : Int = uv_UNKNOWN()

///|
let _EOF : Int = uv_EOF()

///|
let _ENXIO : Int = uv_ENXIO()

///|
let _EMLINK : Int = uv_EMLINK()

///|
let _EHOSTDOWN : Int = uv_EHOSTDOWN()

///|
let _EREMOTEIO : Int = uv_EREMOTEIO()

///|
let _ENOTTY : Int = uv_ENOTTY()

///|
let _EFTYPE : Int = uv_EFTYPE()

///|
let _EILSEQ : Int = uv_EILSEQ()

///|
let _ESOCKTNOSUPPORT : Int = uv_ESOCKTNOSUPPORT()

///|
let _ENODATA : Int = uv_ENODATA()

///|
let _EUNATCH : Int = uv_EUNATCH()

///|
let _ENOEXEC : Int = uv_ENOEXEC()
