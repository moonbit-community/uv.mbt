///|
struct Channel[T] {
  capacity : Int
  buffer : @deque.T[T]
  pusher : @deque.T[(Unit) -> Unit]
  puller : @deque.T[(T) -> Unit]
}

///|
pub async fn Channel::push[T](self : Channel[T], value : T) -> Unit {
  if self.buffer.length() >= self.capacity {
    async_suspend!!(fn(resolve) { self.pusher.push_back(resolve) })
  }
  self.buffer.push_back(value)
  while self.buffer.pop_front() is Some(value) &&
        self.puller.pop_front() is Some(puller) {
    puller(value)
  }
}

///|
pub async fn Channel::pull[T](self : Channel[T]) -> T {
  guard self.buffer.pop_front() is Some(value) else {
    async_suspend!!(fn(resolve) { self.puller.push_back(resolve) })
  }
  while self.buffer.length() < self.capacity &&
        self.pusher.pop_front() is Some(pusher) {
    pusher(())
  }
  return value
}
