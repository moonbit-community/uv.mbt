// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
struct Channel[T] {
  mut canceled : Bool
  send : @deque.T[(T, (Unit) -> Unit, (Error) -> Unit)]
  recv : @deque.T[((T) -> Unit, (Error) -> Unit)]
}

///|
pub fn[T] Channel::new() -> Channel[T] {
  let send = @deque.new()
  let recv = @deque.new()
  { send, recv, canceled: false }
}

///|
pub async fn[T] Channel::send(self : Channel[T], value : T) -> Unit raise {
  if self.canceled {
    raise @uv.ECANCELED
  }
  if self.recv.pop_front() is Some((accept, _)) {
    accept(value)
  } else {
    let parent = active_scope.val
    let id = Id::new()
    try {
      async_suspend_with_error((accept, reject : (Error) -> Unit) => {
        if parent is Some(parent) {
          if parent.canceled {
            reject(@uv.ECANCELED)
            return
          }
          parent.scopes[id] = () => self.cancel()
        }
        self.send.push_back((value, accept, reject))
      })
      if parent is Some(parent) {
        parent.scopes.remove(id)
        if parent.canceled {
          raise @uv.ECANCELED
        }
      }
      active_scope.val = parent
    } catch {
      error => {
        if parent is Some(parent) {
          parent.scopes.remove(id)
        }
        active_scope.val = parent
        raise error
      }
    }
  }
}

///|
pub async fn[T] Channel::recv(self : Channel[T]) -> T raise {
  if self.canceled {
    raise @uv.ECANCELED
  }
  if self.send.pop_front() is Some((value, accept, _)) {
    accept(())
    return value
  } else {
    let parent = active_scope.val
    let id = Id::new()
    try {
      let value = async_suspend_with_error((accept, reject : (Error) -> Unit) => {
        if parent is Some(parent) {
          if parent.canceled {
            reject(@uv.ECANCELED)
            return
          }
          parent.scopes[id] = () => self.cancel()
        }
        self.recv.push_back((accept, reject))
      })
      if parent is Some(parent) {
        parent.scopes.remove(id)
        if parent.canceled {
          raise @uv.ECANCELED
        }
      }
      active_scope.val = parent
      value
    } catch {
      error => {
        if parent is Some(parent) {
          parent.scopes.remove(id)
        }
        active_scope.val = parent
        raise error
      }
    }
  }
}

///|
pub fn[T] Channel::cancel(self : Channel[T]) -> Unit {
  if self.canceled {
    return
  }
  self.canceled = true
  while self.send.pop_front() is Some((_, _, reject)) {
    reject(@uv.ECANCELED)
  }
  while self.recv.pop_front() is Some((_, reject)) {
    reject(@uv.ECANCELED)
  }
}

///|
test {
  start(() => { // <- scope 0
    let chan : Channel[Int] = Channel::new()
    launch(() => scope(() => { // <- scope 1
      launch(() => while true {
        let value = chan.recv()
        delay(100)
        chan.send(value + 1)
      })
      launch(() => {
        delay(1000)
        cancel()
      })
    }) catch {
      _ => ()
    })
    launch(() => try {
      chan.send(0)
      while true {
        let value = chan.recv()
        chan.send(value + 1)
      }
    } catch {
      _ => ()
    })
  }) catch {
    _ => ()
  }
}
