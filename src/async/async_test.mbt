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
test "structural-concurrency" {
  let records = []
  @async.start(() => { // <- scope 0
    records.push(0)
    @async.launch(() => { // <- scope 1
      @async.delay(100)
      records.push(1)
    })
    records.push(2)
    @async.scope(() => { // <- scope 2
      records.push(3)
      @async.launch(() => { // <- scope 3
        @async.delay(100)
        records.push(4)
        @async.launch(() => { // <- scope 5
          @async.delay(100)
          records.push(5)
        })
        records.push(6)
      })
      records.push(7)
      @async.launch(() => { // <- scope 4
        @async.delay(100)
        records.push(8)
      })
      records.push(9)
    })
    records.push(10)
  })
  @json.inspect(records, content=[0, 2, 3, 7, 9, 8, 4, 6, 1, 5, 10])
}

///|
test "structural-concurrency-cancel" {
  let records = []
  @async.start(() => { // <- scope 0
    records.push("0")
    @async.launch(() => { // <- scope 1
      @async.delay(100)
      records.push("1")
    })
    records.push("2")
    @async.launch(() => { // <- scope 2
      @async.delay(50)
      records.push("cancel")
      @async.cancel()
    })
    @async.scope(() => { // <- scope 3
      records.push("3")
      @async.launch(() => { // <- scope 4
        @async.delay(100)
        records.push("4")
        @async.launch(() => { // <- scope 6
          @async.delay(100)
          records.push("5")
        })
        records.push("6")
      })
      records.push("7")
      @async.launch(() => { // <- scope 5
        @async.delay(100)
        records.push("8")
      })
      records.push("9")
    })
    records.push("10")
  }) catch {
    @async.MultiError(_) =>
      @json.inspect(records, content=["0", "2", "3", "7", "9", "cancel"])
    error => raise error
  }
}
