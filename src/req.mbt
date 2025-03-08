///|
priv extern type Req

///|
priv trait ToReq {
  to_req(Self) -> Req
}
