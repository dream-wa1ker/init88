.intel_syntax noprefix
.section .text
.globl _start
_start:
    pop rcx         # rcx = argc (3)
    pop rsi         # rsi = argv[0] ("./echo")
    pop rdi         # rdi = argv[1] (pointer to string "10")
    pop rsi         # rsi = argv[2] (pointer to string "some thing 10")

    # Convert ASCII string "10" in rdi to integer 10 in rdx
    xor rdx, rdx    # Clear rdx (total = 0) (the basic boolean algebra)
.loop_atoi:
    movzx rax, byte ptr [rdi]  # Read single character byte
    cmp al, 0                  # Check for null terminator
    je .done_atoi

    sub al, '0'                # Convert ASCII char to digit (e.g., '1' -> 1)
    imul rdx, rdx, 10          # Shift existing total left by 10 (0 * 10 = 0, then 1 * 10 = 10)
    add rdx, rax               # Add new digit (0 + 1 = 1, then 10 + 0 = 10)

    inc rdi                    # Move to next character
    jmp .loop_atoi
.done_atoi:

    # Now rsi points to "some thing 10" and rdx equals exactly 10
    mov rax, 1      # sys_write
    mov rdi, 1      # stdout
    syscall         # Prints exactly the first 10 characters: "some thing"

    # Exit syscall
    mov rax, 60     # sys_exit
    mov rdi, 0      # Exit code 0
    syscall

