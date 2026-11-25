# C template for multiple main files

For https://c-programming.aydos.de

Select a C main file and press <kbd>F5</kbd> to start your program. There are two examples for testing: `hello.c` and `pi-estimator.c`.

## Running tests

Run the filter regression tests from the repository root:

```sh
./tests/test-filter-by-min-age.sh
```

The script compiles `src/Filter-By-Min-Age.c` with `clang` and checks malformed rows as well as valid filtering. Set `CC` to use a different C compiler.