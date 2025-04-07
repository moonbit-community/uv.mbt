# tonyfettes/uv

This is a MoonBit binding to the [libuv](https://libuv.org) library.

## Quickstart

1. Add this module as a dependency to your MoonBit project.

   ```bash
   moon update
   moon add tonyfettes/uv
   ```

2. Import `tonyfettes/uv` package where you need it.

   ```json
   {
     "import": [
       "tonyfettes/uv"
     ]
   }
   ```

3. Use the `tonyfettes/uv` package in your MoonBit project.

   ```moonbit
   let uv = @uv.loop_alloc()
   ignore(@uv.loop_init(uv))
   let mut test_exit_status = None
   let mut test_term_signal = None
   fn on_exit(
     req : @uv.Process,
     exit_status : Int64,
     term_signal : Int
   ) -> Unit {
     test_exit_status = Some(exit_status)
     test_term_signal = Some(term_signal)
     @uv.process_close(req, fn(_) { @uv.stop(uv) })
   }

   let options = @uv.process_options_alloc()
   let args : FixedArray[Bytes?] = [
     Some(b"moon\x00"),
     Some(b"version\x00"),
     None,
   ]
   @uv.process_options_set_args(options, args)
   @uv.process_options_set_file(options, b"moon\x00")
   let child_req = @uv.process_alloc()
   ignore(@uv.spawn(uv, child_req, options, on_exit))
   ignore(@uv.run(uv, @uv.RunMode::Default))
   ignore(@uv.loop_close(uv))
   ```
