.intel_syntax noprefix

# this is the data section, where we have the datas, .bss. .rodata, .data. etc stuffs.
# .bss has the uninitialised and zero initialised global and static variables that are mutable. 
# .rodata has the readonly data, the constants, string literals, etc stuffs.
# .data has the initialised global and static variables. 
# .text is the real executable code. 
# we define a vaild section using a .section 
# to define the executable section. 

.section .text # this is no mandatate if only executable code is present.
# case there were any data, we need to specify the sections. 
# to initialise the _start as a global symbol recognisable by the linker. 
.globl _start
# then we program the _start as a function. The start function.
# we do so by using it as a label - _start:
_start:
# now that we have all the mandatate code blocks, we proceed. 
