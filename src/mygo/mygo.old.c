#include "moonbit.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define mygo_trace(string) fprintf(stderr, "%s: " string, __func__)
#define mygo_tracef(format, ...)                                               \
  fprintf(stderr, "%s: " format, __func__, __VA_ARGS__)

// start a new coroutine
// save main context
// -> load empty context, which contains current context @ x19
// -> call trampoline
// -> call coroutine function
// -> switch back to main context (in C!!!)

typedef enum mygo_errno {
  MYGO_OK = 0,
  MYGO_ENOMEM = -1,
} mygo_errno_t;

#define STACK_SIZE (1024 * 1024) // 1MB stack size

// MoonBit callback structure for coroutine functions
typedef struct mygo_coroutine_cb_s {
  int32_t (*code)(struct mygo_coroutine_cb_s *);
} mygo_coroutine_cb_t;

typedef struct mygo_context {
#if defined(__x86_64__)
  uint64_t rsp, rbp, rbx, r12, r13, r14, r15;
#elif defined(__aarch64__)
  uint64_t sp, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30;
#endif
  int32_t id;
  void *stack_ptr;
  void *stack_base;
  size_t stack_size;
  mygo_coroutine_cb_t *moonbit_callback;
} mygo_context_t;

static int32_t mygo_coroutine_id = 0;

static void
coroutine_entry_wrapper(void) {
#if defined(__x86_64__)
  mygo_context_t *ctx;
  __asm__ volatile("mov %%rbx, %0\n\t" : "=r"(ctx));
#elif defined(__aarch64__)
  mygo_context_t *ctx;
  __asm__ volatile("mov %0, x19\n\t" : "=r"(ctx));
#endif
  mygo_tracef("ctx: %p\n", ctx);
  mygo_tracef("ctx->x30: %p\n", (void *)ctx->x30);
  mygo_tracef("executing coroutine %d\n", ctx->id);
  mygo_tracef("stack pointer: %p\n", ctx->stack_ptr);
  mygo_tracef("callback: %p\n", ctx->moonbit_callback);
  if (ctx->moonbit_callback) {
    mygo_coroutine_cb_t *cb = (mygo_coroutine_cb_t *)ctx->moonbit_callback;
    ctx->moonbit_callback = NULL; // Prevent double free
    mygo_tracef("callback: %p\n", cb);
    mygo_tracef("callback code: %p\n", cb->code);
    cb->code(cb);
  }
  // Switch back to main context (this should not return)
  while (1) {
    __builtin_trap();
  }
}

#if defined(__x86_64__)
// x86_64 context switching assembly
static void
mygo_context_switch_x86_64(mygo_context_t *from, mygo_context_t *to) {
  __asm__ volatile(
    // Save current context
    "movq %%rsp, %0\n\t"
    "movq %%rbp, %1\n\t"
    "movq %%rbx, %2\n\t"
    "movq %%r12, %3\n\t"
    "movq %%r13, %4\n\t"
    "movq %%r14, %5\n\t"
    "movq %%r15, %6\n\t"

    // Load new context
    "movq %7, %%rsp\n\t"
    "movq %8, %%rbp\n\t"
    "movq %9, %%rbx\n\t"
    "movq %10, %%r12\n\t"
    "movq %11, %%r13\n\t"
    "movq %12, %%r14\n\t"
    "movq %13, %%r15\n\t"

    : "=m"(from->rsp), "=m"(from->rbp), "=m"(from->rbx), "=m"(from->r12),
      "=m"(from->r13), "=m"(from->r14), "=m"(from->r15)
    : "m"(to->rsp), "m"(to->rbp), "m"(to->rbx), "m"(to->r12), "m"(to->r13),
      "m"(to->r14), "m"(to->r15)
    : "memory"
  );
}
#elif defined(__aarch64__)
// ARM64 context switching assembly
static void __attribute__((noinline))
mygo_context_switch_aarch64(mygo_context_t *from, mygo_context_t *to) {
  __asm__ volatile(
    // Save current context
    "mov x9, sp\n\t"
    "str x9, [%0]\n\t"
    "stp x19, x20, [%0, #8]\n\t"
    "stp x21, x22, [%0, #24]\n\t"
    "stp x23, x24, [%0, #40]\n\t"
    "stp x25, x26, [%0, #56]\n\t"
    "stp x27, x28, [%0, #72]\n\t"
    "stp x29, x30, [%0, #88]\n\t"

    // Load new context
    "ldr x9, [%1]\n\t"
    "mov sp, x9\n\t"
    "ldp x19, x20, [%1, #8]\n\t"
    "ldp x21, x22, [%1, #24]\n\t"
    "ldp x23, x24, [%1, #40]\n\t"
    "ldp x25, x26, [%1, #56]\n\t"
    "ldp x27, x28, [%1, #72]\n\t"
    "ldp x29, x30, [%1, #88]\n\t"

    :
    : "r"(from), "r"(to)
    : "x9", "memory"
  );
}
#endif

static inline void
mygo_context_finalize(void *object) {
  mygo_tracef("Finalizing context %p\n", object);
  mygo_context_t *ctx = (mygo_context_t *)object;
  if (ctx->stack_base) {
    free(ctx->stack_base);
  }
  if (ctx->moonbit_callback) {
    moonbit_decref(ctx->moonbit_callback);
  }
}

MOONBIT_FFI_EXPORT
mygo_context_t *
mygo_context_make(void) {
  mygo_context_t *context =
    moonbit_make_external_object(mygo_context_finalize, sizeof(mygo_context_t));
  mygo_tracef("Creating context %p\n", context);
  memset(context, 0, sizeof(mygo_context_t));
  context->id = mygo_coroutine_id++;
  return context;
}

MOONBIT_FFI_EXPORT
mygo_errno_t
mygo_context_init(mygo_context_t *context, mygo_coroutine_cb_t *callback) {
  assert(context != NULL);
  assert(callback != NULL);
  context->moonbit_callback = callback;
  context->stack_base = malloc(STACK_SIZE);
  if (!context->stack_base) {
    return MYGO_ENOMEM;
  }
  context->stack_size = STACK_SIZE;

  // Set up stack pointer (stack grows downward)
  context->stack_ptr = (char *)context->stack_base + STACK_SIZE;

  // Initialize stack for first execution
#if defined(__x86_64__)
  // Align stack to 16 bytes
  context->stack_ptr = (void *)((uintptr_t)context->stack_ptr & ~0xF);

  // Push return address for coroutine_entry_wrapper
  context->stack_ptr = (char *)context->stack_ptr - sizeof(void *);
  *((void **)context->stack_ptr) = (void *)coroutine_entry_wrapper;

  // Set up initial register state
  context->rsp = (uint64_t)context->stack_ptr;
  context->rbp = 0;
  context->rbx = (uint64_t)context; // Pass context as first argument
  context->r12 = 0;
  context->r13 = 0;
  context->r14 = 0;
  context->r15 = 0;
#elif defined(__aarch64__)
  // Align stack to 16 bytes
  context->stack_ptr = (void *)((uintptr_t)context->stack_ptr & ~0xF);

  // Set up initial register state
  context->sp = (uint64_t)context->stack_ptr;
  context->x19 = (uint64_t)context; // Pass context as first argument
  context->x20 = 0;
  context->x21 = 0;
  context->x22 = 0;
  context->x23 = 0;
  context->x24 = 0;
  context->x25 = 0;
  context->x26 = 0;
  context->x27 = 0;
  context->x28 = 0;
  context->x29 = 0;
  context->x30 = (uint64_t)coroutine_entry_wrapper; // Return address
#endif
  return MYGO_OK;
}

MOONBIT_FFI_EXPORT
void
mygo_context_switch(mygo_context_t *from, mygo_context_t *to) {
  mygo_tracef("switch from context %d to context %d\n", from->id, to->id);
  mygo_tracef("from: %p\n", from);
  mygo_tracef("to: %p\n", to);
  mygo_tracef("to stack pointer: %p\n", to->stack_ptr);
  mygo_tracef("to->callback: %p\n", to->moonbit_callback);
  mygo_tracef("to->x19: %p\n", (void *)to->x19);
  mygo_tracef("to->x30: %p\n", (void *)to->x30);
  // Passing NULL pointers is a programmer error, assert to catch it.
  assert(from != NULL && to != NULL);
#if defined(__x86_64__)
  mygo_context_switch_x86_64(from, to);
#elif defined(__aarch64__)
  mygo_context_switch_aarch64(from, to);
#else
#error "Unsupported architecture"
#endif
}

static void __attribute__((naked))
mygo_context__start(
  mygo_coroutine_cb_t *function,
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
mygo_context_start(mygo_context_t *context, mygo_coroutine_cb_t *function) {
  assert(context != NULL);
  assert(function != NULL);
  context->moonbit_callback = function;

  // Allocate stack memory
  context->stack_base = malloc(STACK_SIZE);
  if (!context->stack_base) {
    mygo_trace("Failed to allocate stack memory\n");
    return;
  }

  context->stack_size = STACK_SIZE;
  context->stack_ptr = (char *)context->stack_base + STACK_SIZE;

  // Start the coroutine
  mygo_context__start(function, context->stack_ptr, context);
}
