// Ensure the compiler doesn't mangle this name so the assembly can find it.

// Compiler-agnostic noreturn macro so the toolchain knows this function
// will never return to its caller.
#if defined(__GNUC__) || defined(__clang__)
# define NORETURN __attribute__((noreturn))
#elif defined(_MSC_VER)
# define NORETURN __declspec(noreturn)
#else
# define NORETURN
#endif

extern "C"  void **kernel_main**()  

// Forward declarations for kernel subsystems
void initialize_vga_console();
void kprint(const char*);
void initialize_interrupts();
void initialize_memory_manager();
void launch_init_process();

// Halt loop: use CPU `hlt` when available to avoid busy-waiting.
static inline NORETURN void halt_loop(void) {
#if defined(__GNUC__) || defined(__clang__)
    for (;;) {
        __asm__ __volatile__("hlt");
    }
#else
    for (;;) { /* fallback: tight spin */ }
#endif
}

extern "C" NORETURN void _kernel_main() {

    // This is the first C++ code to run after the bootloader jump.

    // 1. Initialize the Console/VGA driver (to ensure reliable output)
    initialize_vga_console();

    // 2. Print a welcome message
    kprint("RechakedKrnl/\n");

    // 3. Initialize core features
    initialize_interrupts();
    initialize_memory_manager();

    // 4. Start the scheduler/init process
    launch_init_process();

    // 5. Never return — keep the kernel running until explicit shutdown
    halt_loop();
}


