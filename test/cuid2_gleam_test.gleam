import cuid2_gleam
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn can_create_id_test() {
  let generator = cuid2_gleam.default()
  let id = cuid2_gleam.create(generator)

  string.length(id)
  |> should.equal(24)
}

pub fn can_create_custom_generator_test() {
  let generator =
    cuid2_gleam.new()
    |> cuid2_gleam.with_length(10)
    |> cuid2_gleam.build

  let id = cuid2_gleam.create(generator)

  string.length(id)
  |> should.equal(10)
}

pub fn can_validate_cuid_output_test() {
  let default_generator = cuid2_gleam.default()
  let default_id = cuid2_gleam.create(default_generator)

  cuid2_gleam.is_valid(default_generator, default_id)
  |> should.equal(True)

  let custom_gen =
    cuid2_gleam.new()
    |> cuid2_gleam.with_length(10)
    |> cuid2_gleam.build()
  let custom_id = cuid2_gleam.create(custom_gen)

  cuid2_gleam.is_valid(custom_gen, custom_id)
  |> should.equal(True)

  cuid2_gleam.is_valid(default_generator, custom_id)
  |> should.equal(False)

  cuid2_gleam.is_valid(custom_gen, default_id)
  |> should.equal(False)
}
