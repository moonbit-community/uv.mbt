///|
struct Scope {
  mut launched : Int
  mut finished : Int
  mut canceled : Bool
  mut error : Error?
  resolve : (Unit) -> Unit
  reject : (Error) -> Unit
}

///|
fn Scope::resolve(self : Scope) -> Unit {
  (self.resolve)(())
}

///|
fn Scope::reject(self : Scope, error : Error) -> Unit {
  (self.reject)(error)
}

///|
fn Scope::finish(self : Scope) -> Unit {
  self.finished += 1
  if self.finished == self.launched {
    match self.error {
      Some(error) => self.reject(error)
      None => self.resolve()
    }
  }
}

///|
fn Scope::launch(self : Scope) -> Unit {
  self.launched += 1
}

///|
fn Scope::failed(self : Scope, error : Error) -> Unit {
  self.error = Some(error)
  self.finish()
}

///|
let scopes : Array[Scope] = []

///|
fn Scope::new(resolve : (Unit) -> Unit, reject : (Error) -> Unit) -> Scope {
  { launched: 0, finished: 0, canceled: false, error: None, resolve, reject }
}

///|
fn Scope::scope() -> Scope {
  scopes.last().unwrap()
}

///|
pub async fn scope(f : () -> Unit) -> Unit! {
  async_suspend_with_error!!(fn(resolve, reject) {
    let scope = Scope::new(resolve, reject)
    scopes.push(scope)
    f()
  })
}

///|
pub fn spawn(f : async () -> Unit!) -> Unit {
  let scope = Scope::scope()
  async_run(fn() {
    try {
      scope.launch()
      f!!()
      scope.finish()
    } catch {
      error => scope.failed(error)
    }
  })
}

///|
pub fn start(f : async (Loop) -> Unit!) -> Unit! {
  let self = Loop::new!()
  let mut error = None
  async_run(fn() {
    try {
      scope!!(fn() { spawn(fn() { f!!(self) }) })
    } catch {
      e => error = Some(e)
    }
  })
  run!(self, Default)
  stop(self)
  self.close!()
  if error is Some(error) {
    raise error
  }
}
