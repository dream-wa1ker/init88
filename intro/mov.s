# name : mov.s 
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
    # lets now get to the mov instruction. 
    # mov instruction has the following syntax
    # mov dst, src 
    # move into the destination from the source 
    # we can either move the anything that is valid into anything that is valid, but one restrictoin
    # both the operands cannot be memory references
    # suppose we can do this : mov into rax register the value 60
    mov rax, 60
    # or move into rdi, 40
    mov rdi, 40
    # or move into rsi whatever is in rax
    mov rsi, rax
    # or move into rdi whatever is in the address stored in rax (that is whatver in the address 40)
    mov rdi, [rax] # we have successfully wrote our first dereference operator. 
    # rdi = *rax 
    # mov dst, [src] => dst = *src
    # [x] simply means dereference, which means get the value of whatever is stored in the memory address x.
    # here the above mov instruction will mov whatver is in the memory address 6 million into rdi. 
    # or we can move into memory address 6 million 1, whatever is stored in rsi
    mov [6000001], rsi
    mov rdi, [6000001]
    syscall

# this almost always gets a sigsegv because the memory address 6 milllion are unmapped. as well as the address 40





