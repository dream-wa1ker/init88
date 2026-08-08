```asm 
0000000000001139 <main>:
    1139:	55                   	push   rbp
    113a:	48 89 e5             	mov    rbp,rsp
    113d:	48 83 ec 10          	sub    rsp,0x10
    1141:	48 8d 05 c0 0e 00 00 	lea    rax,[rip+0xec0]        # 2008 <_IO_stdin_used+0x8>
    1148:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    114c:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    1150:	48 83 ec 08          	sub    rsp,0x8
    1154:	6a 0a                	push   0xa
    1156:	6a 0a                	push   0xa
    1158:	6a 09                	push   0x9
    115a:	6a 0a                	push   0xa
    115c:	6a 09                	push   0x9
    115e:	6a 0a                	push   0xa
    1160:	6a 22                	push   0x22
    1162:	ff 75 f8             	push   QWORD PTR [rbp-0x8]
    1165:	6a 22                	push   0x22
    1167:	41 b9 09 00 00 00    	mov    r9d,0x9
    116d:	41 b8 0a 00 00 00    	mov    r8d,0xa
    1173:	b9 0a 00 00 00       	mov    ecx,0xa
    1178:	ba 0a 00 00 00       	mov    edx,0xa
    117d:	be 0a 00 00 00       	mov    esi,0xa
    1182:	48 89 c7             	mov    rdi,rax
    1185:	b8 00 00 00 00       	mov    eax,0x0
    118a:	e8 a1 fe ff ff       	call   1030 <printf@plt>
    118f:	48 83 c4 50          	add    rsp,0x50
    1193:	b8 00 00 00 00       	mov    eax,0x0
    1198:	c9                   	leave
    1199:	c3                   	ret
```

Alright, this is a disassembly from a file called `elf` which is assured to have only one function, which is main. 
That is supposed to be a C program. And the objective of this is to understand the above given piece of the disassembly and figure out the source code of the program. 

For now, it is ok to just remember this : that the rsp should be aligned and should always be multiple of 16 bytes (the address). 
Initially, while calling the main function from the _start, the stack frame is subtracted 8 bytes. During the first push instuction in the main, it is again subtracted 8 bytes. 

`push` actually means, pushing a value, or placing a value on top of the stack. Stack grows downward, from higher to lower addresses. So when something is pushed onto the stack frame, then it would expand the stack, henceforth subtracting its address by 8 bytes. (since in 64 bit arch, pointers are 8 bytes). 
`push` underneath is two instuctions : 

- `sub <operand>, 8`
- `mov [rsp], <operand>`

I previously had a misconception on how the push operadn works, now that is clarified and is explained in detail below :

- so, previously, the rbp has a value : which is base of the caller's stack. 
- when we do `push rbp` => `sub rsp, 8` and `mov [rsp], rbp`, it first reserves the space on top of the stack. it reserves 8 bytes. that is what sub rsp, 8 means. the stack grows downward from higher to lower address. previously, say the address of the stack was something that ends in ...56 (assume integer address instead of hex), now it points to ...48, that is both are multiple of 8. but not both 16. only after the push rbp, the stack becomes multiple of 16 bytes. (just remember it).
- what it is doing overall is reserving 8 bytes of space on TOP of the stack frame. Then mov into that top 8 bytes the base pointer adddress of the caller's stack. (mov literally does not move, it just copies). That's it. 


### setting up the stack frame

- push rbp : As stated above, we just save the caller's base pointer onto the top of the stack frame. 
- mov rbp, rsp : overwrites the value of the rbp to whatever the current stack pointer is.
- sub rsp, 0x10 : subtract from the rsp's address 16 bytes. (0x10 is hex for 16), which is done to align the stack, reserving 16 bytes on the top of the stack frame.

