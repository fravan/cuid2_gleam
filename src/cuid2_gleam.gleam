import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleam/time/timestamp
import internal/counter

const default_length = 24

const big_length = 32

pub type Randomiser =
  fn() -> Float

pub fn new() {
  let counter = counter.new()
  let random = float.random
  let fingerprint = create_fingerprint(random)
  let length = default_length
  fn() {
    let first_letter = get_first_letter()
    let time = get_system_time()
    let count = int.to_base36(counter.tick(counter))
    let salt = create_entropy(length, random)
    let hash_input = time <> salt <> count <> fingerprint
    first_letter <> string.slice(hash(hash_input), 1, length - 1)
  }
}

fn get_first_letter() -> String {
  let alphabet = "abcdefghijklmnopqrstuvwxyz"
  // We can assert, `list.first` will find something
  let assert Ok(first) =
    alphabet
    |> string.to_graphemes
    |> list.shuffle
    |> list.first
  first
}

fn get_system_time() -> String {
  timestamp.system_time()
  |> timestamp.to_unix_seconds
  |> float.truncate
  |> int.to_base36
}

fn hash(input: String) -> String {
  // From: https://github.com/paralleldrive/cuid2/blob/main/src/index.js#L32
  // Drop the first character because it will bias the histogram to the left.
  let hashed_input = crypto.hash(crypto.Sha512, bit_array.from_string(input))
  let int_input = bit_array_to_int(hashed_input, 0)
  int.to_base36(int_input) |> string.drop_start(1)
}

fn bit_array_to_int(bit: BitArray, value: Int) {
  case bit {
    <<x:int>> -> int.bitwise_shift_left(value, 8) + x
    <<x:int, rest:bits>> ->
      bit_array_to_int(rest, int.bitwise_shift_left(value, 8) + x)
    // Should we panic?
    _ -> panic as "We have no idea what's going on here!!"
  }
}

fn create_entropy(length: Int, random: Randomiser) -> String {
  do_create_entropy(length, random, "")
}

fn do_create_entropy(length: Int, random: Randomiser, entropy: String) -> String {
  use <- bool.guard(when: string.length(entropy) >= length, return: entropy)
  do_create_entropy(
    length,
    random,
    entropy <> int.to_base36(float.truncate(random() *. 36.0)),
  )
}

fn create_fingerprint(random: Randomiser) -> String {
  create_entropy(big_length, random)
  |> hash
  |> string.slice(0, big_length)
}
