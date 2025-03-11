-module(cuid2_gleam_ffi).

-export([create_counter/1, tick_counter/1]).

create_counter(Start) ->
    Counter = atomics:new(1, [{signed, false}]),
    atomics:exchange(Counter, 1, Start),
    Counter.

tick_counter(CounterRef) ->
    atomics:add_get(CounterRef, 1, 1).
