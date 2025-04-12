///|
fn moonbit_get_cli_args() -> FixedArray[Bytes] = "$moonbit.get_cli_args"

///|
pub fn argv() -> Array[Bytes] {
  let argv = moonbit_get_cli_args()
  Array::makei(argv.length(), fn(i) { argv[i] })
}

///|
pub fn args() -> Array[String]! {
  let argv = moonbit_get_cli_args()
  let args = []
  for i in 0..<argv.length() {
    args.push(@encoding.decoder(UTF8).decode!(argv[i]))
  }
  args
}
