import gleam/erlang/atom
import gleam/float

pub opaque type Counter {
  Counter(ref: atom.Atom)
}

@external(erlang, "cuid2_gleam_ffi", "create_counter")
fn erlang_create_counter(start_value: Int) -> atom.Atom

@external(erlang, "cuid2_gleam_ffi", "tick_counter")
fn erlang_tick_counter(counter_ref: atom.Atom) -> Int

const initial_count_max = 476_782_367.0

pub fn new() -> Counter {
  let start_value = float.truncate(float.random() *. initial_count_max)
  with_value(start_value)
}

pub fn with_value(start_value: Int) -> Counter {
  erlang_create_counter(start_value)
  |> Counter
}

pub fn tick(counter: Counter) -> Int {
  erlang_tick_counter(counter.ref)
}
