# Debugging `uv.mbt`

## Helper Functions/Macros

`libuv` has provided `uv_print_all_handles` and `uv_print_active_handles` to
help you diagnose issues with event-loops, like improper releasing of resource,
etc.

In addition to that, we have provided macros like `moonbit_uv_trace` and
`moonbit_uv_tracef` to help you print values to console during debug.

## Address Sanitizer

It requires multiple steps to enable address sanitizer for this project:

1. Modify `moon.pkg.json` to include the following field:

   ```json
   {
     "link": {
       "native": {
         "cc": "path/to/c/compiler",
         "stub-cc": "path/to/c/compiler"
       }
     }
   }
   ```

2. Run `moon test --target native` with following environment variable set:

   1. `MOON_CC="path/to/c/compiler -g -fsanitize=address"`
   2. `MOON_AR="path/to/ar"`
   3. `ASAN_OPTIONS=detect_leaks=1` if leak detection is not enabled by default.
   4. `LSAN_OPTIONS=suppressions=.lsan-suppressions"` if on macOS.

## Debugger

Run `moon test --target native` or any moon command with `-v` option:

```bash
moon test --target native -v
```

Pay close attention to the last command executed. Copy the executable path
and arguments to debugger and run it.
