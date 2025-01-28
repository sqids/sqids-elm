# CHANGELOG

## Unreleased

Expose `Sqids.Context.Context` also from the main module as `Sqids.Context` for convenience: This way consumers using custom contexts only need to import the `Sqids.Context` module where the context is created. The modules for encoding or decoding sqids can just import `Sqids`.

## 1.0.0

Port of [sqid-javascript](https://github.com/sqids/sqids-javascript/tree/94d69d1205849ca0a229346b435644b0cf38a574) to Elm
