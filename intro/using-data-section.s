# name : using_data_section.s 
# date : 2026-08-07 
# syn  : intel 

#---------------------------------- define the syntax -------------------------------
.intel_syntax noprefix


#---------------------------------- define the datas---------------------------------
# global initialised variables go into data. 
.section .data
# create a label say number
# .quad will allocate 8 bytes initialised with value 50. 
# 8 bytes is because it is 64bits architecture. (quad = quadword)
# .long will be a double word which is 4 bytes. 
# .short will be a word which is 2 bytes.
# .byte is literally 1 byte.
exit_code: .quad 0
syscall_number: .quad 60
# note that we need to consider the range of the numbers capable with a particular word size. 
# in .data, this exit_code is a modifiable space, 8 bytes. => int64_t exit_code = 50;
#---------------------------------- define the execs---------------------------------
# initialise the start of executable
.section .text
# define the global _start symbol
.globl _start
# prepare the _start function
_start:
    # mov into rax whatever is stored in address syscall_number
    mov rax, [syscall_number]
    # mov into rdi, whatever is stored in the address exit_code 
    mov rdi, [exit_code]
    # syscall finally.
    syscall
    


