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

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#pragma comment(lib, "psapi.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "userenv.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "dbghelp.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")
#endif

#include "async.c"
#include "check.c"
#include "cond.c"
#include "cpu_info.c"
#include "dns.c"
#include "env.c"
#include "error.c"
#include "fs.c"
#include "fs_event.c"
#include "fs_poll.c"
#include "handle.c"
#include "idle.c"
#include "loop.c"
#include "metrics.c"
#include "mutex.c"
#include "os.c"
#include "pipe.c"
#include "prepare.c"
#include "process.c"
#include "random.c"
#include "req.c"
#include "rwlock.c"
#include "sem.c"
#include "signal.c"
#include "socket.c"
#include "stat.c"
#include "stream.c"
#include "string.c"
#include "tcp.c"
#include "thread.c"
#include "timer.c"
#include "tty.c"
#include "udp.c"
#include "work.c"
#include "write.c"
