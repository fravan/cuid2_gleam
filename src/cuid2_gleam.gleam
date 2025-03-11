import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import gleam/time/timestamp
import internal/counter

const big_length = 32

/// Randomiser used to create entropy, needs to return between [0, 1[
pub type Randomiser =
  fn() -> Float

pub type DefaultCounter

pub type CustomCounter

pub type DefaultLength

pub type CustomLength

pub type DefaultFingerprint

pub type CustomFingerprint

pub type DefaultRandomiser

pub type CustomRandomiser

pub opaque type Generator {
  Generator(
    counter: counter.Counter,
    randomiser: Randomiser,
    fingerprint: String,
    length: Int,
  )
}

pub opaque type Builder(counter, randomiser, fingerprint, length) {
  Builder(
    counter: option.Option(counter.Counter),
    randomiser: option.Option(Randomiser),
    fingerprint: option.Option(String),
    length: option.Option(Int),
  )
}

/// Creates a Builder with default options so you can customise them
/// as needed
pub fn new() -> Builder(
  DefaultCounter,
  DefaultRandomiser,
  DefaultFingerprint,
  DefaultLength,
) {
  Builder(option.None, option.None, option.None, option.None)
}

/// Will change the length of the created ids (default is 24)
pub fn with_length(
  builder: Builder(c, r, f, DefaultLength),
  length: Int,
) -> Builder(c, r, f, CustomLength) {
  Builder(..builder, length: option.Some(length))
}

/// Generation uses a counter that is expected to increment on each `create` call.
/// You can customise that, I don't fully understand all of it, so do this at your own risks.
pub fn with_counter(
  builder: Builder(DefaultCounter, r, f, l),
  counter: counter.Counter,
) -> Builder(CustomCounter, r, f, l) {
  Builder(..builder, counter: option.Some(counter))
}

/// The randomiser used can also be custom if needed
pub fn with_randomiser(
  builder: Builder(c, DefaultRandomiser, f, l),
  randomiser: Randomiser,
) -> Builder(c, CustomRandomiser, f, l) {
  Builder(..builder, randomiser: option.Some(randomiser))
}

/// The fingerprint is to allow to differentiate even more
/// on distributed system, I think… not 100% sure.
/// Default is random
pub fn with_fingerprint(
  builder: Builder(c, r, DefaultFingerprint, l),
  fingerprint: String,
) -> Builder(c, r, CustomFingerprint, l) {
  Builder(..builder, fingerprint: option.Some(fingerprint))
}

/// Build a Generator from a Builder!
pub fn build(builder: Builder(c, r, f, l)) -> Generator {
  let counter = option.lazy_unwrap(builder.counter, counter.new)
  let randomiser = option.unwrap(builder.randomiser, float.random)
  let fingerprint =
    option.lazy_unwrap(builder.fingerprint, fn() {
      create_fingerprint(randomiser)
    })
  let length = option.unwrap(builder.length, 24)
  Generator(counter:, randomiser:, fingerprint:, length:)
}

/// Returns a new Generator with Default values
/// same as `createId` from JS implementation.
pub fn default() -> Generator {
  new()
  |> build
}

/// Returns a cuid following the Generator configuration.
pub fn create(generator: Generator) -> String {
  let first_letter = get_first_letter()
  let time = get_system_time()
  let count = int.to_base36(counter.tick(generator.counter))
  let salt = create_entropy(generator.length, generator.randomiser)
  let hash_input = time <> salt <> count <> generator.fingerprint
  first_letter <> string.slice(hash(hash_input), 1, generator.length - 1)
}

/// Returns true if the given string has been generated by this generator
pub fn is_valid(generator: Generator, maybe_cuid: String) {
  case generator.length == string.length(maybe_cuid) {
    True -> is_cuid_like(maybe_cuid)
    False -> False
  }
}

/// Returns true if the given string looks like a cuid.
/// It's just a regex check, so "thisisacuid" is true.
pub fn is_cuid_like(maybe_cuid: String) {
  let assert Ok(regex) = regexp.from_string("^[a-z][0-9a-z]+$")
  regexp.check(regex, maybe_cuid)
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
  int.to_base36(int_input) |> string.drop_start(1) |> string.lowercase
}

fn bit_array_to_int(bit: BitArray, value: Int) {
  case bit {
    <<x:int>> -> int.bitwise_shift_left(value, 8) + x
    <<x:int, rest:bits>> ->
      bit_array_to_int(rest, int.bitwise_shift_left(value, 8) + x)
    // Should we panic?
    _ -> panic as "BitArray hash contains something else than int"
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
