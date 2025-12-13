[BITS 32]
protected_mode_start:
    ; Load the 32-bit data selector (0x10 is often the offset for the Data Segment in GDT)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up the 32-bit stack pointer for the kernel
    mov esp, 0x90000 ; A temporary safe stack location 
    
    ; *** Next step is to load the kernel binary from disk! ***
    ; 2. Set up the 32-bit Stack Pointer (ESP)
    ; Choose a high address (e.g., 1MB + 64KB) as a safe temporary stack
    mov esp, 0x110000 
    
    mov EAX, CR0 ; 3. Load the CR0 register to enable protected mode
    or EAX, 1    ; Set the PE (Protection Enable) bit 
 ; 4. Jump to the C++ Kernel Entry Point
jmp kernel_main ; Or call kernel_main if using OTHER syntax
