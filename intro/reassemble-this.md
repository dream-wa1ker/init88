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

- `push rbp` : As stated above, we just save the caller's base pointer onto the top of the stack frame. 
- `mov rbp, rsp` : overwrites the value of the rbp to whatever the current stack pointer is.
- `sub rsp, 0x10` : subtract from the rsp's address 16 bytes. (0x10 is hex for 16), which is done to align the stack, reserving 16 bytes on the top of the stack frame.
- `lea rax, [rip+0xec0]` : loads the effective address 0xec0 into rax. 
- `mov [rbp-0x8], rax` : copies whatever is in rax currently to the address that is 8 bytes above the base of the current stack frame.
- `mov rax, [rbp-0x8]` : derefernces the address and copies whatever is in there to rax. 
- `sub rsp, 0x8` : reserves 8 bytes on the top of stack.
- `push 0xa` : reserves 8 bytes on top of the stack and copies value 0xa (int 10) to stack's top.
... similarly, all those following values : 0xa, 0x9, 0xa, 0x9... in integers respectively are - 10, 10, 9, 10, 9, 10, 34.
- `push [rbp-0x8]`: copies on top of the stack what is in address [rbp-0x8]. 
- `push 0x22`: copies on top of stack the value 34. 
- copies the values into the respective registers. 
- rax : is a pointer to address rbp-0x8
- rdi : rax is then copied onto rdi, the rdi has a value which is a pointer to rbp-0x8. 
- esi: 10 
- edx : 10 
- ecx, and r8d are 10 
- r9d is 9. 
- clear the eax. 
- calls the printf
- adds to rsp 80.
- sets return code for the main program in eax.
- leave?

`leave` is just two instructions. It resets the rsp back to rbp and then pops the rbp off from the stack. 
`leave` => `mov rsp, rbp` and `pop rbp`. 
- returns. 



After some research, found that the number of arguments the registers can hold is only 6. 

In 64-bit Linux calling conventions, functions accept their first 6 integer/pointer arguments in CPU registers (rdi, rsi, rdx, rcx, r8d, r9d).

Because printf is called here with 15 total arguments (1 format string + 14 values), there aren't enough registers to hold them all:
Plaintext

Arg 1 (rdi) : Format string ('fixed') - starting from the address 2008 relative to the rip. 
Arg 2 (rsi) : 10 ('\n')
Arg 3 (rdx) : 10 ('\n')
Arg 4 (rcx) : 10 ('\n')
Arg 5 (r8d) : 10 ('\n')
Arg 6 (r9d) : 9 ('\t')
----------------------------------------- [Register limit reached]
Arg 7 (Stack): 34 ('"')
Arg 8 (Stack): fixed pointer
Arg 9 (Stack): 34 ('"')
Arg 10 (Stack): 10 ('\n')
Arg 11 (Stack): 9 ('\t')
Arg 12 (Stack): 10 ('\n')
Arg 13 (Stack): 9 ('\t')
Arg 14 (Stack): 10 ('\n')
Arg 15 (Stack): 10 ('\n')

Because stack arguments are pushed in reverse order (right-to-left in C), Argument 15 is pushed first (push 0xa) and Argument 7 is pushed last (push 0x22). Cause the stack is first in first out data structure. 

Seems like these all are arguments into the printf. with the first argument being at 2008?

before that, what the hell is even in rip+0xec0 ?
after the disassembly of the `elf` program. that is at # 2008 <_IO_stdin_used+0x8> relative to the rip, which happens to be this un-understandable piece of code. 

```asm 
0000000000002000 <_IO_stdin_used>:
    2000:	01 00                	add    DWORD PTR [rax],eax
    2002:	02 00                	add    al,BYTE PTR [rax]
    2004:	00 00                	add    BYTE PTR [rax],al
    2006:	00 00                	add    BYTE PTR [rax],al


    2008:	23 69 6e             	and    ebp,DWORD PTR [rcx+0x6e] --> here starts our format string. we should interpret these raw bytes. starting from this address till we next see the null terminator (00)


    200b:	63 6c 75 64          	movsxd ebp,DWORD PTR [rbp+rsi*2+0x64]
    200f:	65 20 3c 73          	and    BYTE PTR gs:[rbx+rsi*2],bh
    2013:	74 64                	je     2079 <_IO_stdin_used+0x79>
    2015:	69 6f 2e 68 3e 25 63 	imul   ebp,DWORD PTR [rdi+0x2e],0x63253e68
    201c:	23 69 6e             	and    ebp,DWORD PTR [rcx+0x6e]
    201f:	63 6c 75 64          	movsxd ebp,DWORD PTR [rbp+rsi*2+0x64]
    2023:	65 20 3c 73          	and    BYTE PTR gs:[rbx+rsi*2],bh
    2027:	74 64                	je     208d <_IO_stdin_used+0x8d>
    2029:	6c                   	ins    BYTE PTR [rdi],dx
    202a:	69 62 2e 68 3e 25 63 	imul   esp,DWORD PTR [rdx+0x2e],0x63253e68
    2031:	25 63 69 6e 74       	and    eax,0x746e6963
    2036:	20 6d 61             	and    BYTE PTR [rbp+0x61],ch
    2039:	69 6e 28 76 6f 69 64 	imul   ebp,DWORD PTR [rsi+0x28],0x64696f76
    2040:	29 20                	sub    DWORD PTR [rax],esp
    2042:	7b 25                	jnp    2069 <_IO_stdin_used+0x69>
    2044:	63 25 63 63 6f 6e    	movsxd esp,DWORD PTR [rip+0x6e6f6363]        # 6e6f83ad <_end+0x6e6f438d>
    204a:	73 74                	jae    20c0 <_IO_stdin_used+0xc0>
    204c:	20 63 68             	and    BYTE PTR [rbx+0x68],ah
    204f:	61                   	(bad)
    2050:	72 2a                	jb     207c <_IO_stdin_used+0x7c>
    2052:	20 66 69             	and    BYTE PTR [rsi+0x69],ah
    2055:	78 65                	js     20bc <_IO_stdin_used+0xbc>
    2057:	64 20 3d 20 25 63 25 	and    BYTE PTR fs:[rip+0x25632520],bh        # 2563457e <_end+0x2563055e>
    205e:	73 25                	jae    2085 <_IO_stdin_used+0x85>
    2060:	63 3b                	movsxd edi,DWORD PTR [rbx]
    2062:	25 63 25 63 70       	and    eax,0x70632563
    2067:	72 69                	jb     20d2 <__GNU_EH_FRAME_HDR+0x6>
    2069:	6e                   	outs   dx,BYTE PTR [rsi]
    206a:	74 66                	je     20d2 <__GNU_EH_FRAME_HDR+0x6>
    206c:	28 66 69             	sub    BYTE PTR [rsi+0x69],ah
    206f:	78 65                	js     20d6 <__GNU_EH_FRAME_HDR+0xa>
    2071:	64 2c 20             	fs sub al,0x20
    2074:	31 30                	xor    DWORD PTR [rax],esi
    2076:	2c 20                	sub    al,0x20
    2078:	31 30                	xor    DWORD PTR [rax],esi
    207a:	2c 20                	sub    al,0x20
    207c:	31 30                	xor    DWORD PTR [rax],esi
    207e:	2c 20                	sub    al,0x20
    2080:	31 30                	xor    DWORD PTR [rax],esi
    2082:	2c 20                	sub    al,0x20
    2084:	39 2c 20             	cmp    DWORD PTR [rax+riz*1],ebp
    2087:	33 34 2c             	xor    esi,DWORD PTR [rsp+rbp*1]
    208a:	20 66 69             	and    BYTE PTR [rsi+0x69],ah
    208d:	78 65                	js     20f4 <__GNU_EH_FRAME_HDR+0x28>
    208f:	64 2c 20             	fs sub al,0x20
    2092:	33 34 2c             	xor    esi,DWORD PTR [rsp+rbp*1]
    2095:	20 31                	and    BYTE PTR [rcx],dh
    2097:	30 2c 20             	xor    BYTE PTR [rax+riz*1],ch
    209a:	39 2c 20             	cmp    DWORD PTR [rax+riz*1],ebp
    209d:	31 30                	xor    DWORD PTR [rax],esi
    209f:	2c 20                	sub    al,0x20
    20a1:	39 2c 20             	cmp    DWORD PTR [rax+riz*1],ebp
    20a4:	31 30                	xor    DWORD PTR [rax],esi
    20a6:	2c 20                	sub    al,0x20
    20a8:	31 30                	xor    DWORD PTR [rax],esi
    20aa:	29 3b                	sub    DWORD PTR [rbx],edi
    20ac:	25 63 25 63 72       	and    eax,0x72632563
    20b1:	65 74 75             	gs je  2129 <__GNU_EH_FRAME_HDR+0x5d>
    20b4:	72 6e                	jb     2124 <__GNU_EH_FRAME_HDR+0x58>
    20b6:	20 45 58             	and    BYTE PTR [rbp+0x58],al
    20b9:	49 54                	rex.WB push r12
    20bb:	5f                   	pop    rdi
    20bc:	53                   	push   rbx
    20bd:	55                   	push   rbp
    20be:	43                   	rex.XB
    20bf:	43                   	rex.XB
    20c0:	45 53                	rex.RB push r11
    20c2:	53                   	push   rbx
    20c3:	3b 25 63 7d 25 63    	cmp    esp,DWORD PTR [rip+0x63257d63]        # 63259e2c <_end+0x63255e0c>
	...
```

Then put this into AI for processing the raw bytes. Seems like the disassembler also coverts raw bytes into pseudo instructions assuming the bytes as assembly op code. So only few code in assembly is valid instruction. Remaining are just pseudo invalid instructions. 

The string here is : at the line 20c3, it happens that c4, c5, c6, c7, c8, c9 are converted to -> cmp    esp,DWORD PTR [rip+0x63257d63]  which is c9 being our NULL terminator!.....


The string turned out to be this : (which can be simply reassured by running the `strings` command on the `elf` file). To be honest, THIS WAS HARD. And now that I know that when arguments are limited in registers, it just goes with the stack frame. Which is an interesting new concept for me btw. 

```c 
#include <stdio.h>%c#include <stdlib.h>%c%cint main(void) {%c%cconst char* fixed = %c%s%c;%c%cprintf(fixed, 10, 10, 10, 10, 9, 34, fixed, 34, 10, 9, 10, 9, 10, 10);%c%creturn EXIT_SUCCESS;%c}%c
```



so our main function should be like this 

```c
int main(void) {
    // the string @ address 2008 
    const *fixed = "#include <stdio.h>%c#include <stdlib.h>%c%cint main(void) {%c%cconst char* fixed = %c%s%c;%c%cprintf(fixed, 10, 10, 10, 10, 9, 34, fixed, 34, 10, 9, 10, 9, 10, 10);%c%creturn EXIT_SUCCESS;%c}%c"
    // and simply the printf was called after setting up the stack and all the arguments that has to be going into printf, with the first argument being the rax : the string itself. And the argument 8 which happens to be pushed into the stack via this instruction - push   QWORD PTR [rbp-0x8]. 
    printf(fixed, 10, 10, 10, 10, 9, 34, fixed, 34, 10, 9, 10, 9, 10, 10 );
    // exit success is 0, that is main setting up the eax to 0. return value. Then leaves and returns. 
    return EXIT_SUCCESS;
}
```
