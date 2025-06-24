///|
fn moonbit_get_cli_args() -> FixedArray[Bytes] = "$moonbit.get_cli_args"

///|
let _args : FixedArray[String] = {
  let argv = moonbit_get_cli_args()
  FixedArray::makei(argv.length(), fn(i) {
    @encoding.decode_lossy(encoding=UTF8, argv[i])
  })
}

///|
#deprecated("Use `args` instead")
pub fn argv() -> Array[Bytes] {
  let argv = moonbit_get_cli_args()
  Array::makei(argv.length(), fn(i) { argv[i] })
}

///|
/// Returns a _copy_ of command-line arguments passed to the program.
///
/// The arguments are copied to prevent accidental/intentional modification to
/// the original command-line arguments.
///
/// Example:
///
/// ```moonbit
/// println(@uv.args())
/// ```
pub fn args() -> Array[String] {
  Array::from_fixed_array(_args)
}
