import gleam/float

pub type Counter

@external(erlang, "cuid2_gleam_ffi", "create_counter")
fn erlang_create_counter(start_value: Int) -> Counter

@external(erlang, "cuid2_gleam_ffi", "tick_counter")
fn erlang_tick_counter(counter_ref: Counter) -> Int

const initial_count_max = 476_782_367.0

pub fn new() -> Counter {
  let start_value = float.truncate(float.random() *. initial_count_max)
  erlang_create_counter(start_value)
}

pub fn tick(counter: Counter) -> Int {
  erlang_tick_counter(counter)
}
