# name : printf-number.s 
# date : 2026-08-08 
# syn  : intel 

#---------------------------------- define the syntax -------------------------------
.intel_syntax noprefix


#---------------------------------- define the datas---------------------------------
.section .data
.section .rodata

fmt_string: .asciz "This is a number : %d; whose address is : %p\n"
a: .long 800

#---------------------------------- define the execs---------------------------------
# initialise the start of executable
.section .text
.extern printf
# define the global main symbol
.globl main
# prepare the main function
main:
    push rbp 
    mov rbp, rsp
    lea rdi, [rip + fmt_string]
    # we use esi because constant 'a' is 32 bit integer, that is 32 bits of register space, which is esi
    mov esi, [rip + a]
    lea rdx, [rip + a]
    xor eax, eax
    call printf
    # set up the main function's return value. else it would print the printf's return value.
    xor eax, eax
    pop rbp
    ret



