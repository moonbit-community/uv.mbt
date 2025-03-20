// ///|
// fn main {
//   try {
//     @uv.start!(fn(uv) {
//       @uv.spawn(fn() {
//         let mut counter = 0
//         while true {
//           uv.idle!!()
//           counter += 1
//           println("counter: \{counter}")
//           if counter >= 1000 {
//             break
//           }
//         }
//       })
//       println("Idling...")
//     })
//   } catch {
//     error => println("Error: \{error}")
//   }
// }

///|
fn main {

}
