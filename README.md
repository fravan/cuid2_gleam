# cuid2_gleam

[![Package Version](https://img.shields.io/hexpm/v/cuid2_gleam)](https://hex.pm/packages/cuid2_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cuid2_gleam/)

Reimplementation of [https://github.com/paralleldrive/cuid2](https://github.com/paralleldrive/cuid2) in Gleam!

```sh
gleam add cuid2_gleam
```
```gleam
import cuid2_gleam

pub fn main() {
  // Start by building a generator
  // You can take the default one (id of length 24)
  let generator = cuid2_gleam.default()

  // and get some ids!
  let id = cuid2_gleam.create(generator) // will have length 24

  // You can also build your own generator with some custom options
  let custom_generator = cuid2_gleam.new()
  |> cuid2_gleam.with_length(10)
  |> cuid2_gleam.with_fingerprint("Some custom fingerprint")
  |> cuid2_gleam.build
  let custom_id = cuid2_gleam.create(custom_generator) // will have length 10
}
```

Further documentation can be found at <https://hexdocs.pm/cuid2_gleam>.
