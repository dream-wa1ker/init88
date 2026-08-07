.intel_syntax noprefix
# this is a comment in the intel syntax of x86
# .intel_syntax noprefix tells the assembler to use the intel syntax of assembly 
# instead of using the AT and T syntax. 
# to assemble this code in linux, we gotta use the GNU assembler. 
# as file.s -o file.o which will generate us the object file. 
# then we need to use the linker to link the files. 
# ld file.o -o file which will produce the final executable file. 
