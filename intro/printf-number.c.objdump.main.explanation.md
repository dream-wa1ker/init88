```asm
0000000000001139 <main>:
    1139:	55                   	push   rbp
    113a:	48 89 e5             	mov    rbp,rsp
    113d:	b9 20 03 00 00       	mov    ecx,0x320
    1142:	48 8b 05 cf 2e 00 00 	mov    rax,QWORD PTR [rip+0x2ecf]        # 4018 <fmt_string>
    1149:	48 8d 15 b8 0e 00 00 	lea    rdx,[rip+0xeb8]        # 2008 <a>
    1150:	89 ce                	mov    esi,ecx
    1152:	48 89 c7             	mov    rdi,rax
    1155:	b8 00 00 00 00       	mov    eax,0x0
    115a:	e8 d1 fe ff ff       	call   1030 <printf@plt>
    115f:	b8 00 00 00 00       	mov    eax,0x0
    1164:	5d                   	pop    rbp
    1165:	c3                   	ret
```

That's it, a couple registers and instructions, everyone should be good to go with this main function. 
As far from this disassembly, we can understand that : 
- main is located in 0x1139 mem address
- push rbp : saves the current frame to the stack (pushes it into stack)
- mov rbp, rsp : sets up a new stack by making base pointer point to whatever rsp is currently pointing to. 
- mov ecx, 0x320 : moves the value 0x320 that is 32 bit integer 800 into the ecx (32 bit version of rcx : extended register 'c')
- mov rax, QWORD PTR [rip+0x2ecf] : this stores the QWORD:qword (64 bit) 8 byte PTR:pointer at the address 0x2ecf relative to rip, moves that absolute pointer to rax (that is address of fmt_string)
- lea rdx, [rip+0xeb8] : loads the effective address of integer a into rdx relative to the rip.  here 0xeb8 is address of 'a' relative to rip. (instruction pointer)
- mov esi, ecx : move into esi whatever is in ecx (that is moves value 800 into esi)
- mov rdi, rax : move into rdi whatever is in rax (that is moves the pointer to fmt_string into rdi)
- mov eax, 0x0 : move into eax 0 (clear the eax - return value)
- call 1030 : call the function symbol that is in address 1030 relative to rip which is <printf@plt> 
here the printf is still an unresolved symbol and will be linked via dynamic linker in the procedural linker table (PLT)
- mov eax, 0x0 : finally moves the value 0 into eax
- pop rbp : pops back the old stack frame
- ret : returns


And this is exactly what we did in the printf-number.s assembly program. And this above given code is the disassembly of the printf-number.c C program. 
Seems out they behave exactly the same?

