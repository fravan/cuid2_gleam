import cuid2_gleam
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn can_create_id_test() {
  let generator = cuid2_gleam.new()
  let id = generator()
  string.length(id)
  |> should.equal(24)
}
