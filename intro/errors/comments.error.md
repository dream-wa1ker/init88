init88/intro on  main [?] via  v16.1.1-gcc ❯ ls
󰡯 comments   comments.o   comments.s   echo.s   errors   hello-intel.s   hello.c   hello.s
init88/intro on  main [?] via  v16.1.1-gcc ❯ ls
󰡯 comments   comments.o   comments.s   echo.s   errors   hello-intel.s   hello.c   hello.s
init88/intro on  main [?] via  v16.1.1-gcc ❯ rm comments comments.o
init88/intro on  main [?] via  v16.1.1-gcc ❯ as comments.s -o comments.o
init88/intro on  main [?] via  v16.1.1-gcc ❯ ld comments.o -o comments
/usr/bin/ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000
init88/intro on  main [?] via  v16.1.1-gcc ❯ ./comments
fish: Job 1, './comments' terminated by signal SIGSEGV (Address boundary error)
init88/intro on  main [?] via  v16.1.1-gcc ❯ cat comments.s
.intel_syntax noprefix
# this is a comment in the intel syntax of x86
# .intel_syntax noprefix tells the assembler to use the intel syntax of assembly 
# instead of using the AT and T syntax. 
# to assemble this code in linux, we gotta use the GNU assembler. 
# as file.s -o file.o which will generate us the object file. 
# then we need to use the linker to link the files. 
# ld file.o -o file which will produce the final executable file. 
init88/intro on  main [?] via  v16.1.1-gcc ❯

This is the exact error(s) that were produced during the

1) assembling 
2) and linking of the comments.s assembly program. 

The reason why this happened is?

- first the assembler was doing what it is supposed to do : assemble the file, convert the assembly to object file. 
- the object file must be then linked by the linker. 
- error 1 that is encountered with the linker, (warning actually) is because - the linker looks for a specific global symbol named _start, that was actually not in the program. The program neither contained any actual executable code nor any entry point(the _start). Therefore the linker defaulted to an address as per the warning : 401000. Marking it as the start of the executable code. 

- error 2 that is when we run the program, there it encounters a SIGSEGV. Because it tried to read the contents from that 401000 address that is simply not having rxw, the x flag enabled, that is a simplified version though, the actual reason behind it is - there was no code loaded at that address, the CPU tried to read invalid/unmapped memory, triggering a Segmentation Fault (SIGSEGV).

To fix it : we need to define a start, then exit gracefully. If we do not exit, the program simply keep executing all the instructions starting from the _start address and continues indefinitely till it reads invalid data (unmapped), triggering a SIGSEGV.

