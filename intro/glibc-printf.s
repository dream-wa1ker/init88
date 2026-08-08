# name : glibc-printf.s 
# date : 2026-08-08 
# syn  : intel 

#---------------------------------- define the syntax -------------------------------
.intel_syntax noprefix


#---------------------------------- define the datas---------------------------------
.section .data
.section .rodata

# create a 8 byte constant number storing value 100
number: .quad 100
# create the format string
fmt_string: .asciz "The address of the \'number\' constant relative to the rip is : %p\n"
#---------------------------------- define the execs---------------------------------
# initialise the start of executable
.section .text
# extern the printf function from the glibc
.extern printf
# define the global main symbol
.globl main
# prepare the main function
main:
    # save current frame
    push rbp
    # load new frame
    mov rbp, rsp
    # load effective address of the format string into first arg
    lea rdi, [rip + fmt_string]
    # load the effective address of the number as the second argument
    lea rsi, [rip + number]
    # clear rax before calling printf (caus the return value will be stored in rax)
    xor rax, rax
    # call the printf function
    call printf
    # restore the old frame and return
    pop rbp
    ret


