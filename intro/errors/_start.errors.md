init88/intro on  main [?] via  v16.1.1-gcc ❯ as _start.s -o _start.o
init88/intro on  main [?] via  v16.1.1-gcc ❯ ld _start.o -o _start 
init88/intro on  main [?] via  v16.1.1-gcc ❯ ./_start 
fish: Job 1, './_start' terminated by signal SIGSEGV (Address boundary error)
init88/intro on  main [?] via  v16.1.1-gcc ❯


As stated, Since there are only comments after _start:, the CPU ran out of valid machine code almost instantly and kept executing into empty/unmapped memory right past the end of the binary. And since the program tried to access memory with invalid or insufficient permissions, the OS stops it via sigsegv (aka the segmentation fault - accessing invalid data segment either due to lack of permissions, unmapped, or non existent address)

