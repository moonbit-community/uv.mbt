///|
pub fn async_run(f : async () -> Unit) -> Unit = "%async.run"

///|
async fn async_suspend[T](f : ((T) -> Unit) -> Unit) -> T = "%async.suspend"

///|
async fn async_suspend_with_error[T, E : Error](
  f : ((T) -> Unit, (E) -> Unit) -> Unit
) -> T!E = "%async.suspend"
