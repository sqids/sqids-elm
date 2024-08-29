# [Sqids Elm](https://sqids.org/elm)

[Sqids](https://sqids.org/elm) (_pronounced "squids"_) is a small library that lets you **generate unique IDs from numbers**. It is good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

Features:

- **Encode multiple numbers** - generate short IDs from one or several non-negative numbers
- **Quick decoding** - easily decode IDs back into numbers
- **Unique IDs** - generate unique IDs by shuffling the alphabet once
- **ID padding** - provide minimum length to make IDs more uniform
- **URL safe** - auto-generated IDs do not contain common profanity
- **Randomized output** - Sequential input provides nonconsecutive IDs
- **Many implementations** - Support for [40+ programming languages](https://sqids.org/)

## 🧰 Use-cases

Good for:

- Generating IDs for public URLs (eg: link shortening)
- Generating IDs for internal systems (eg: event tracking)
- Decoding for quicker database lookups (eg: by primary keys)

Not good for:

- Sensitive data (this is not an encryption library)
- User IDs (can be decoded revealing user count)

## 🚀 Getting started

Install with

```sh
elm install sqids/sqids-elm
```

## 👩‍💻 Examples

Simple encode & decode:

```elm
import Sqids

Sqids.encode [ 1, 2, 3 ]
--> (Ok "86Rf07")

Sqids.decode "86Rf07"
--> (Ok [ 1, 2, 3 ])
```

If IDs are too short, you can pad them to a certain length:

```elm
import Sqids
import Sqids.Context

context : Sqids.Context.Context
context =
    case
        Sqids.Context.from
            { alphabet = Sqids.Context.defaultAlphabet
            , minLength = 10
            , blockList = Sqids.Context.defaultBlockList
            }
    of
        Ok ok ->
            ok

        Err err ->
            Debug.todo <| Debug.toString err

Sqids.encodeWith context [ 1, 2, 3 ]
--> (Ok "86Rf07xd4z")

Sqids.decodeWith context "86Rf07xd4z"
--> (Ok [ 1, 2, 3 ])
```

Create unique IDs by shuffling the alphabet:


```elm
import Sqids
import Sqids.Context

context : Sqids.Context.Context
context =
    case
        Sqids.Context.new
            |> Sqids.Context.withAlphabet "k3G7QAe51FCsPW92uEOyq4Bg6Sp8YzVTmnU0liwDdHXLajZrfxNhobJIRcMvKt"
            |> Sqids.Context.build
    of
        Ok ok ->
            ok

        Err err ->
            Debug.todo <| Debug.toString err

Sqids.encodeWith context [ 1, 2, 3 ]
--> (Ok "XRKUdQ")

Sqids.decodeWith context "XRKUdQ"
--> (Ok [ 1, 2, 3 ])
```

## Development

You need the Elm compiler and an elm test runner (e.g. [elm-test](https://www.npmjs.com/package/elm-test) or [elm-test-rs](https://github.com/mpizenberg/elm-test-rs)).

An easy way to get started is with [node.js](https://nodejs.org) and [elm-tooling](https://elm-tooling.github.io/elm-tooling-cli/).

```sh
# Install dependencies
npm install
npx elm-tooling install
# Ensure that no unused code exists or that the documentation comments are correct
npx elm-review --fix
# Run tests in watch mode
npx elm-test-rs --watch
```

Note: Running [elm-review](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) also creates the test file `tests/DocumentationCodeSnippetTest.elm` to check the code snippets in the README.md file and also the documentation comments in source code.

### CI

@todo add the [elm-tooling-action GitHub action](https://github.com/mpizenberg/elm-tooling-action).

## License

[MIT](https://github.com/sqids/sqids-elm/blob/main/LICENSE)
