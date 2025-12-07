# --- CONFIGURATION (CRITICAL HARDCODED PATHS) ---
# Paste the ABSOLUTE path to your 32-bit i686-elf/bin folder here.
# Example: /home/nothing/toolchain_fix/i686-elf-tools-linux/bin
TOOLCHAIN_DIR = /i686-elf-tools

CC      = $(TOOLCHAIN_DIR)/bin/i686-elf-gcc
LD      = $(TOOLCHAIN_DIR)/bin/i686-elf-ld
OBJCOPY = $(TOOLCHAIN_DIR)/bin/i686-elf-objcopy
AS      = nasm
QEMU    = qemu-system-i386  # Use 32-bit QEMU system

# --- SOURCE FILES ---
# Add your source files here.
ASM_SRC = boot.asm pm_entry.asm
SOURCE  = kernel.C vga-vgt.c interrupts.c memory.c process.c

# --- BUILD VARIABLES ---
ASM_OBJ = $(ASM_SRC:.asm=.o)
C_OBJ   = $(C_SRC:.C=.o)
OBJ     = $(ASM_OBJ) $(C_OBJ)


# --- TARGETS ---
.PHONY: all clean run

all: disk.img
# Rule to compile the boot sector assembly file (boot.asm) into a raw binary (boot.bin)
boot.bin: boot.asm
	$(AS) -f bin $< -o $@

# 1. FINAL IMAGE: Combine the bootloader and the kernel binary
disk.img: boot.bin GumballKernel.bin
	cat boot.bin GumballKernel.bin > disk.img

# 2. KERNEL BINARY: Strip the debugging headers from the ELF executable
GumballKernel.bin: GumballKernel.elf
	$(OBJCOPY) -O binary GumballKernel.elf GumballKernel.bin

# 3. KERNEL EXECUTABLE: Link all object files using the linker script
GumballKernel.elf: $(OBJ) linker.ld

	 $(LD) -T linker.ld -o GumballKernel.elf $(OBJ) $(CCFLAGS) -m elf_i386 

# 4. C++ COMPILATION RULE: Compile all .C files into .o files
%.o: %.C
	$(CC) $(CFLAGS) -c $< -o $@

# 5. ASSEMBLY COMPILATION RULE: Compile all .asm files into .o files. -f elf is for 32-bit.
%.o: %.asm
	$(AS) $< -f elf32 -o $@

# --- UTILITIES ---
run: all
	$(QEMU) -fda disk.img

clean:
		rm -f $(OBJ) GumballKernel.elf GumballKernel.bin disk.img

