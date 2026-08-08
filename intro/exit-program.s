# name : exit_program.s 
# date : 2026-08-07 
# syn  : intel 

#---------------------------------- define the syntax -------------------------------
.intel_syntax noprefix


#---------------------------------- define the datas---------------------------------
.section .data

#---------------------------------- define the execs---------------------------------
# initialise the start of executable
.section .text
# define the global _start symbol
.globl _start
# prepare the _start function
_start:
    # for now, it is ok to just know that the call instruction calls a function(symbol) in the text section. 
    # though it has way more instuctions going underneath., assume its a fuction call, but truely itz not.
    call exit


# define the exit function.(symobl)
exit:
    # exit_syscall(int code) has syscall number 60, and code 0 for exit_success. 
    # rax : the syscall number goes here. 
    # rdi : the destination index - first arg of a syscall function. 
    # mow : the mov function mov dst, src : mov into destination from the source.
    mov rax, 60
    mov rdi, 0
    # perform the syscall
    syscall


