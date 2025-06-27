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
type Env Unit

///|
fn init {
  ignore(env.inner())
}

///|
priv suberror ValueError {
  NotFound(String)
} derive(Show)

///|
pub fn Env::op_get(self : Env, name : String) -> String raise {
  guard self.get(name) is Some(value) else { raise ValueError::NotFound(name) }
  value
}

///|
pub fn Env::get(_ : Env, name : String) -> String? raise {
  @uv.os_getenv(name)
}

///|
pub fn Env::op_set(_ : Env, name : String, value : String) -> Unit raise {
  @uv.os_setenv(name, value)
}

///|
pub fn Env::iter2(_ : Env) -> Iter2[String, String] raise {
  @uv.os_environ().iter2()
}

///|
pub let env : Env = ()
