# Elm Optimizations

Running tests:
```text
$ cd elm-optimizations/XXX
$ elm-test src/*
```

Running benchmarks:
```text
$ cd elm-optimizations/XXX
$ elm make --optimize src/*
```
Then open the generated `index.html` in browser.

Benchmark is based on [Mersenne Twister](https://en.wikipedia.org/wiki/Mersenne_Twister)🢅 initialization.

## Tuple or not

Directory: `TupleOrNot`

Using tuple inside custom type is faster than without tuple.
```elm
type TypeA
    = TypeA Int Int Int

type TypeB
    = TypeB ( Int, Int, Int )
```

```text
                            Firefox          Chromium
                           --------          --------
TypeA Int Int Int           8 200/s          28 000/s
TypeB ( Int, Int, Int )    11 400/s  >30%    34 000/s  >20%
```
(2020-06-25, Elm 0.19.1, Firefox 68, Chromium 80, Debian Linux, Core i5 3570K 3.4 GHz)
