///|
priv struct Channel[T] {
  capacity : Int
  buffer : @deque.T[T]
  pusher : @deque.T[(Unit) -> Unit]
  puller : @deque.T[(T) -> Unit]
}

///|
type Send[T] Channel[T]

///|
type Recv[T] Channel[T]

///|
pub async fn channel[T](capacity~ : Int = 1) -> (Send[T], Recv[T]) {
  let channel = {
    capacity,
    buffer: @deque.new(),
    pusher: @deque.new(),
    puller: @deque.new(),
  }
  (Send(channel), Recv(channel))
}

///|
pub async fn Send::push[T : Show](self : Send[T], value : T) -> Unit {
  if self.buffer.length() >= self.capacity {
    async_suspend!!(fn(resolve) { self.pusher.push_back(resolve) })
  }
  self.buffer.push_back(value)
  while self.puller.front() is Some(puller) &&
        self.buffer.front() is Some(value) {
    puller(value)
    self.puller.unsafe_pop_front()
    self.buffer.unsafe_pop_front()
  }
}

///|
pub async fn Recv::pull[T](self : Recv[T]) -> T {
  guard self.buffer.pop_front() is Some(value) else {
    async_suspend!!(fn(resolve) {
      self.puller.push_back(resolve)
    })
  }
  while self.buffer.length() < self.capacity &&
        self.pusher.pop_front() is Some(pusher) {
    pusher(())
  }
  return value
}
