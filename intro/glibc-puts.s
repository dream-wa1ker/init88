# name : glibc-puts.s 
# date : 2026-08-08 
# syn  : intel 

#---------------------------------- define the syntax -------------------------------
.intel_syntax noprefix


#---------------------------------- define the datas---------------------------------
.section .data
.section .rodata
message: .asciz "This is a message being printed out by puts..."

#---------------------------------- define the execs---------------------------------
# initialise the start of executable
.section .text
.extern puts
# define the global main symbol
.globl main
# prepare the main function
main:
    # save the old frame to stack (push the old frame to stack)
    push rbp
    # mov into the base pointer the current stack pointer to set up a new frame.
    mov rbp, rsp
    # load the effective address of the message into the first argument : rdi with respect to the instruction pointer.
    lea rdi, [rip + message]
    # clear the rax before calling puts. (rax has the return value + syscall numbers. clear before every function call)
    xor rax, rax # or mov rax, 0 => xor is just xor reg, reg will as per boolean algebra nullify or zero the register.
    # restore the old frame from the stack
    # call the puts function (from glibc, available via extern)
    call puts
    pop rbp
    # finally return to the caller function
    ret
    

# for any assembly program that involves the glibc library, we need to use the gcc to assemble the program. Internally it would automatically resolve the unknown symbols (here puts) from the PLT (in most cases). Whereas bare ld cannot simply link the glibc.
