/* Copyright 2025 International Digital Economy Academy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "moonbit.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define mygo_trace(string) fprintf(stderr, "%s: " string, __func__)
#define mygo_tracef(format, ...)                                               \
  fprintf(stderr, "%s: " format, __func__, __VA_ARGS__)

typedef enum mygo_errno {
  MYGO_OK = 0,
  MYGO_ENOMEM = -1,
} mygo_errno_t;

typedef struct mygo_context {
#if defined(__x86_64__)
  uint64_t rsp, rbp, rbx, r12, r13, r14, r15;
#elif defined(__aarch64__)
  uint64_t sp, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30;
#endif
} mygo_context_t;

MOONBIT_FFI_EXPORT
mygo_context_t *
mygo_context_make(void) {
  return (mygo_context_t *)moonbit_make_bytes(sizeof(mygo_context_t), 0);
}

#define mygo_noinline __attribute__((noinline))

typedef struct mygo_function {
  int32_t (*code)(struct mygo_function *);
} mygo_function_t;

static void __attribute__((naked))
mygo_context__reset(
  mygo_function_t *function,
  void *stack,
  mygo_context_t *context
) {
  __asm__ volatile(
    // Save context
    "mov x9, sp\n\t"
    "str x9, [x2]\n\t"
    "stp x19, x20, [x2, #8]\n\t"
    "stp x21, x22, [x2, #24]\n\t"
    "stp x23, x24, [x2, #40]\n\t"
    "stp x25, x26, [x2, #56]\n\t"
    "stp x27, x28, [x2, #72]\n\t"
    "stp x29, x30, [x2, #88]\n\t"

    // Store context pointer in x19.
    // We cannot move this instruction before the context saving,
    // as it would overwrite the callee-saved registers x19.
    "mov x19, x2\n\t"

    // Call the coroutine function.
    // No need to load callee-saved registers as they will be saved in the
    // coroutine function, if any of they are used.
    "mov sp, x1\n\t"
    "ldr x8, [x0]\n\t"
    "blr x8\n\t"

    // Restore context pointer to x2.
    // We can't use x19 as it will be overwritten by the context loading.
    "mov x2, x19\n\t"

    // Load context.
    "ldr x9, [x2]\n\t"
    "mov sp, x9\n\t"
    "ldp x19, x20, [x2, #8]\n\t"
    "ldp x21, x22, [x2, #24]\n\t"
    "ldp x23, x24, [x2, #40]\n\t"
    "ldp x25, x26, [x2, #56]\n\t"
    "ldp x27, x28, [x2, #72]\n\t"
    "ldp x29, x30, [x2, #88]\n\t"
    "ret\n\t"
  );
}

MOONBIT_FFI_EXPORT
void
mygo_context_reset(mygo_context_t *context, mygo_function_t *function) {
  void *stack = aligned_alloc(16, 1024 * 1024);
  mygo_context__reset(function, stack, context);
  free(stack);
  moonbit_decref(context);
}

MOONBIT_FFI_EXPORT
void __attribute__((naked))
mygo_context_shift(mygo_context_t *self, mygo_context_t *other) {
  __asm__ volatile(
    // Save context
    "mov x9, sp\n\t"
    "str x9, [x0]\n\t"
    "stp x19, x20, [x0, #8]\n\t"
    "stp x21, x22, [x0, #24]\n\t"
    "stp x23, x24, [x0, #40]\n\t"
    "stp x25, x26, [x0, #56]\n\t"
    "stp x27, x28, [x0, #72]\n\t"
    "stp x29, x30, [x0, #88]\n\t"

    // Load context
    "ldr x9, [x1]\n\t"
    "mov sp, x9\n\t"
    "ldp x19, x20, [x1, #8]\n\t"
    "ldp x21, x22, [x1, #24]\n\t"
    "ldp x23, x24, [x1, #40]\n\t"
    "ldp x25, x26, [x1, #56]\n\t"
    "ldp x27, x28, [x1, #72]\n\t"
    "ldp x29, x30, [x1, #88]\n\t"
    "ret\n\t"
  );
}