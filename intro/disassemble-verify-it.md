alright people. This is our file. Here I will do the instructions to disassemble this `verify-it` file. First we might need to understand what that does. We just run that binary. 

```bash
verify-it
```

It seems like the program takes some password to allow us in. On wrong password, it prints Failure. Catting it produces some garbage, which we cannot understand. But yet the answer is already near to it. We just have to run the `strings` program on this file to get the list of all the printable, human readable strings in the program, which might have an hash or atmost the real unhashed password itself. But we are not gonna do that. We are gonna disassemble this program, piece by piece understand what is happening underneath the program. 

To start with, this is a binary file, we need to get some context on the file type of this binary. So we use the `file` command to get the filetype and other useful informations like using what program it is compiled, what is it's kinda word size, 64 bit or 32 bit program, whether it is for linux or for windows. 

```bash
file verify-it
# this provides the ouput as given below. 
```

```txt
verify-it: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=8b1fbade92cfcfdb94ba157ac4181fcfb4863072, for GNU/Linux 4.4.0, not stripped
```

So, 

- ELF : it is for linux : Executable and Linkable Format 
- OS word size : 64 bit operating systems. 
- Platform : Linux, GNU/Linux
- The binary is not striped. 
- It is a PIE executable : PIE = Position Independent Executable. (We'll just google to know what it is. )
- It is also dynamically linked via the interpreter /lib64/ld-linux-x86-64.so.2, which is the dynamic linker for linux to link the C or GCC or C++ programs and objects/symbols. 
- GNU/LINUX Version 4.4.0 

Now we gotta use the OG OBJDUMP command. 

First, the output might seem scary, but tbh, not. It should feel interesting and will teach you more C than ever. Whatever the hell is happening underneath cannot be hidden. 

```bash
man objdump 
# for the manpages for objdump command. 
objdump --help
# inbuilt help command for the objdump program. 
```

Though the objdump manual seems like a mess, I am not gonna use all the flags given in there. We just use 3 flags and we are done. 
I have highlighted some text in this recording, the -M flag, the -d flag, and the -D flag. 

- d : disassemble only the executable section of the binary. 
- D : disassemble all the sections of the binary. 
- M : switch between the AT&T assembly syntax and Intel syntax. 

Here, first, we just peep into the executable section alone, i.e, first use the -d flag. 
And we prefer the intel syntax over the AT&T syntax. 

From the usage of the objdump program, it should be used like this : 

```bash
init88/intro/binaries on  main [?] ❯ objdump --help
Usage: objdump <option(s)> <file(s)>
```

So we turn on all the flags that are required and do the following 

```bash
# run this
objdump -M intel -d ./verify-it
```


And we take a look at the sections. 

We have the following sections. 

- .init 
- .plt 
- .text 
- .fini 

A quick google search may help if you wanna know what these are. But for short, the init section initialises the GNU GCC, the c runtime environment, sets up the stack and stuffs. 

The plt is called the procedural linker table section, that is used by the dynamic linker to link the symbols during linking stage of the GCC. I am not sure on the above line btw. But something similar happens. 

The text section is our executable section, the one where all the C code sits on. The C program the person wrote. Let's say it `verify-it.c`. 

The symbols/functions/programs/objects that are linked by the dynamic linker can be found via the procedural linker table section. AKA the .plt section. 
Let's first take a look at what functions are used here. 

So, as highlighted, only 4 functions are used from the GCC, GLIBC library. 

- printf 
- puts 
- scanf
- strcmp 

And we should know the function signatures of all these commands, that would help us using and understanding the register `mov` operations. 

For arch linux users, I would tell you to install the man-pages package via pacman like this. 

```bash
sudo pacman -S man-pages
# This will install man-pages manual pages, which includes the C manual. 
```


Usage for the man pages is simple enough. `man 3 <function name>`
man 3 is specifically for the C standard library : the GLIBC in the GNU/LINUX. 

```bash
man 3 printf 
man 3 puts
man 3 scanf
man 3 strcmp
```

You just execute and read the manual for all the above C functions. 
And you will be just as fine to go. Just remember what goes into each argument. 


### printf

The first argument is a format string : type - `const char *` that is a pointer (char pointer), in 64 bit systems, it is 8 bytes in size. The word 8 is called as QWORD in assembly that means - quadword, or 8. and for specifying it as a pointer, we just denote PTR. Pointers are variables/consts/ or something that holds address to another location. 

The second argument and the third and so forth are the format characters, that are as many in numbers as the format specifiers in the format string. You just learn what `printf` does and you are good here. 

### puts

The puts function takes only one argument. the string. : type - `const char *`, again, same as the `printf`'s format string. And hence a 8 byte pointer. Remember how it is called in the Assembly programming? 

### scanf

The first argument is a format string : type - `const char *`, same again. 
The second argument however is a pointer, something that points to memory address in some other location. You just gotta have that intuition. 
NOt only second argument, there are as many arguments as there are format specifiers in the format string. You just want to be aware of it. Everything is just same as `printf` here. 

### strcmp

It takes only two arguments. 
The first and second, both are strings. : type - `const char *`. 


## Understanding what arguments and what registers. 

A short googling can help : 

Here is how the x86-64 System V ABI calling convention looks using Intel syntax.
The main difference in Intel syntax is that the destination comes first, followed by the source (operation destination, source), and registers do not use the % prefix. [1, 2, 3, 4, 5] 
## The 6 Integer Argument Registers
When calling a function, the first 6 integer or pointer arguments are loaded into these registers from left to right: [6, 7] 

* 1st Argument: rdi
* 2nd Argument: rsi
* 3rd Argument: rdx
* 4th Argument: rcx
* 5th Argument: r8
* 6th Argument: r9

Just remember the names of the above given registers. 

rdi - register destination index
rsi - register source index
rdx - register d expanded
rcx - register c expanded
r8 - general purpose register 8
r9 - general purpose register 9

I am not gonna die next summer, just a joke. 

## Visualizing with an Assembly Example
Consider this C function call: process(10, 20, 30);
In Intel syntax, the compiler generates the following assembly to pass these three arguments before triggering the call: [8] 

mov rdi, 10    ; 1st argument (destination rdi, source 10)
mov rsi, 20    ; 2nd argument (destination rsi, source 20)
mov rdx, 30    ; 3rd argument (destination rdx, source 30)
call process   ; Call the function

## Accessing Different Data Sizes
Depending on the size of the argument variable (like char, short, int, or long), you use different sub-sections of those same registers: [9] 

| Argument | 64-bit (long, ptr) | 32-bit (int) | 16-bit (short) | 8-bit (char) |
|---|---|---|---|---|
| 1st | rdi | edi | di | dil |
| 2nd | rsi | esi | si | sil |
| 3rd | rdx | edx | dx | dl |
| 4th | rcx | ecx | cx | cl |
| 5th | r8 | r8d | r8w | r8b |
| 6th | r9 | r9d | r9w | r9b |

For example, passing a 32-bit integer as the first argument looks like this:

mov edi, 10    ; Clears the upper 32 bits of rdi automatically


## Returning Values

* Integers/Pointers: The function places the final return value into rax.
* Floating-point numbers: The function places the return value into xmm0. [14, 15, 16] 

; Inside a function returning the number 5
mov rax, 5     ; Set up return value
ret            ; Return to caller


Alright, that's enough for it. 
Nah that song is not nice..right. 



## Starting with the main program. 

As we know, the `c` program, starts with the `main` @ the executable section, where everything goes on. Inside the text section, we need to check for the main label and look at it. 

```asm
0000000000001179 <main>:
    1179:	55                   	push   rbp
    117a:	48 89 e5             	mov    rbp,rsp
    117d:	48 81 ec 10 02 00 00 	sub    rsp,0x210
    1184:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    118b:	00 00 
    118d:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    1191:	31 c0                	xor    eax,eax
    1193:	48 8d 05 6e 0e 00 00 	lea    rax,[rip+0xe6e]        # 2008 <_IO_stdin_used+0x8>
    119a:	48 89 c7             	mov    rdi,rax
    119d:	b8 00 00 00 00       	mov    eax,0x0
    11a2:	e8 a9 fe ff ff       	call   1050 <printf@plt>
    11a7:	48 8d 85 f0 fd ff ff 	lea    rax,[rbp-0x210]
    11ae:	48 8d 15 7d 0e 00 00 	lea    rdx,[rip+0xe7d]        # 2032 <_IO_stdin_used+0x32>
    11b5:	48 89 c6             	mov    rsi,rax
    11b8:	48 89 d7             	mov    rdi,rdx
    11bb:	b8 00 00 00 00       	mov    eax,0x0
    11c0:	e8 9b fe ff ff       	call   1060 <__isoc23_scanf@plt>
    11c5:	48 8d 85 f0 fd ff ff 	lea    rax,[rbp-0x210]
    11cc:	48 89 c7             	mov    rdi,rax
    11cf:	e8 40 00 00 00       	call   1214 <check_password>
    11d4:	83 f8 01             	cmp    eax,0x1
    11d7:	75 11                	jne    11ea <main+0x71>
    11d9:	48 8d 05 55 0e 00 00 	lea    rax,[rip+0xe55]        # 2035 <_IO_stdin_used+0x35>
    11e0:	48 89 c7             	mov    rdi,rax
    11e3:	e8 48 fe ff ff       	call   1030 <puts@plt>
    11e8:	eb 0f                	jmp    11f9 <main+0x80>
    11ea:	48 8d 05 4f 0e 00 00 	lea    rax,[rip+0xe4f]        # 2040 <_IO_stdin_used+0x40>
    11f1:	48 89 c7             	mov    rdi,rax
    11f4:	e8 37 fe ff ff       	call   1030 <puts@plt>
    11f9:	b8 00 00 00 00       	mov    eax,0x0
    11fe:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    1202:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    1209:	00 00 
    120b:	74 05                	je     1212 <main+0x99>
    120d:	e8 2e fe ff ff       	call   1040 <__stack_chk_fail@plt>
    1212:	c9                   	leave
    1213:	c3                   	ret
```

The scary as fuck above code is x86-64 assembly. That might look like a mess and too big. But its just easy to understand. 

Now, we decode the function. 

`push rbp` : pushes the rbp (register base pointer) onto the stack i.e, copies the value of the caller's base pointer onto the stack (i.e, saves it). This consists of two micro operations. : the `sub rsp, 8`, it subtracts the memory address by 8 bytes, since the address to be coppied, the `rbp` is a pointer, 8 bytes in x86-64 os. Then copies the `rbp` in the memory address in `rsp`. (AKA, the top of the stack) using the `mov` operation : `mov [rsp], rbp`

`mov    rbp,rsp` : This is copying into the `rbp` (register base pointer) the value of the stack pointer `rsp`, to set up a new stack frame for the main function. 

`sub    rsp,0x210` : This is something that subtracts the rsp, the stack pointer, hence growing the stack downwards. This is because stack grows downwards from higher to lower address. But the value `0x210` is hexadecimal notation for some number. We figure it out using a hexadecimal to integer converter or just use `python` btw, like this. My arch linux ships with the latest version of python. If yo uneed some python, just install it via : 

```bash
sudo pacman -S python
```

So the number 0x210 is equivalent to 528. Why 528? 

Because as per the system V conventions, the stack addresses should always be a multiple of 16. I don't yet know the reason, but a small google search might help us. 

RIGHT BEFORE THE CALL INSTRUCTION IS EXECUTED. 

So, its good for cache efficiency and other reasons which are not required to be known to us in this current state of knowledge. 


For now, we are reserving 528 bytes of space on top of the stack. But is 528 a multiple of 16? Nice, its a perfect multiple. 

`mov    rax,QWORD PTR fs:0x28` : mov into rax register, a pointer from where? This is something that canary has to do with. I don't yet understand it. 

`mov QWORD PTR [rbp-0x8],rax` : then mov into the address that is 8 bytes less than the base address of tha stack, the value in rax. What's in the rax? that's the secret canary something. 

`xor    eax,eax` : essentially, zero out the eax register : the `rax` register is wiped. eax is just a subregister, a part of the rax register. 

`lea    rax,[rip+0xe6e]` : this loads the effective address which is 0xe6e relative to the rip : `register instruction pointer` : the register instruction pointer points to the next instruction the CPU is about to execute. and the lea loads the address of something +0xe6e from that rip address. 

And as per the comment it is : `# 2008 <_IO_stdin_used+0x8>`, at address location 2008 within some crazy label : IO_stdin_used... smtg as above. 

`mov    rdi,rax` : now move into register d expanded the value that is in register a expanded. i.e, mov into rdi, the value @ rax. 

What is in rax? the address that is 2008, a pointer. And remember that rdi is the first argument.

`mov    eax,0x0` : now move into the eax (the part of rax) the value 0x0 which is 0. 

`call   1050 <printf@plt>` : Then it calls the printf function that is to be resolved at the section plt, by the dynamic linker. So it calls the printf and the first argument that is setup at the stack, the register `rdi` is meant for printf. And printf just prints it. Also note that there is not second argument set before the `printf` function is called, and hence, this `printf` call takes only one argument (from `rax`) and no other arguments like second argument (from `rsi`). 

`lea    rax,[rbp-0x210]` : After the call, the program loads the effective address of whatever is 528 bytes less than the current base pointer. I don't know what is it. It loads it into the rax. 

`lea    rdx,[rip+0xe7d]` : So, here it loads the effective address of something that is 0xe7d from the instruction pointer. into rdx. 

And as per the comments, that stuff is located at relative address - `# 2032 <_IO_stdin_used+0x32>`

`mov    rsi,rax` : moves into the rsi the value at rax, which is from line 293 of this file - the effective address of `rbp-0x210`. And rsi is the second argument. 

`mov    rdi,rdx` : then moves into the first argument, aka the rdi register the value at rdx. What's in the rdx currently? something that is at relative address `# 2032 <_IO_stdin_used+0x32>`. So now our first and second arguments are setup. 

`mov    eax,0x0` : zero's the eax. 

`call   1060 <__isoc23_scanf@plt>` : calls the scanf function, resolved from the plt via the dynamic linker. 

It is now clear that after the `printf` function, the program procceeds to setup two arguments for `scanf` - because only the registers `rdi` and `rsi` were set before the function call. 

NOTE THAT, BEFORE EVERY FUNCTION CALL THE STACK ADDRESS SHOULD BE MULTIPLE OF 16 BYTES. 

And that is somehow done during the call instructions and the micro instructions in them. Ig.


```asm
lea    rax,[rbp-0x210]
mov    rdi,rax
call   1214 <check_password>
```

These are the immediate next instructions. Clear right? loads the effective address of something that is rbp - 528 bytes. The same first argument that is used for the `scanf` function. Loads into rax. 

And then moves (ie, copies) the value in rax into rdi. `rdi` is the first argument of any function call. 

And then the function call is executed. 
And the function is some function that is at the address 1214. and that function is called as `check_password`. 

## Enough of main. We just go to check password. 

`push   rbp` and `mov    rbp,rsp` : set's up the stack frame, copies the caller's base pointer onto the stack and sets up a new stack frame by copying the rsp into rbp. 

`sub    rsp,0x10` : then it subtracts exactly 16 bytes from the stack pointer address. The stack alignment and space reservation. 

`mov    QWORD PTR [rbp-0x8],rdi` : then copies from the rdi, whatever value it has, into the address that is 8 bytes less than the rbp, the base pointer. 

What's in rdi right now? 

In rdi, right now, whatever is in the rax of the main function is there. What is in the rax of the main function? Some effective address of this address `rbp-0x210`. 

So, currently in the check password function, the rdi has rbp-0x210, but not relative to the rbp of the check_password, but the value already that is moved into the rdi before the check_password's stack was setup. 

`lea    rdx,[rip+0xe24]        # 204b <_IO_stdin_used+0x4b>` : load the effective address (lea) of rip+0xe24 (relative to the instruction pointer) into the register `rdx`. 

`mov    rax,QWORD PTR [rbp-0x8]` : mov into rax, whatever is in that rbp-0x8, that is actually what is moved from rdi to into this address, which is rbp 528 bytes that is relative to the main's stack frame. The context and stack frame matters. Since there are no variables. Just copied onto registers to registers, acting as a temproary storage. 

`mov    rsi,rdx` : ok, the second argument of some function that is to be called is getting set up. copy into the rsi, whatever is in rdx. 
Nah, the pointer to relative address 204b is in the rdx. So this is copied on as the second argument. 

`mov    rdi,rax` : Here comes the rax. Whatever is in rax is copied onto the rdi. 
What is in rax? `mov    rax,QWORD PTR [rbp-0x8]` : this one. What is in the rbp-0x8? : `mov    QWORD PTR [rbp-0x8],rdi` this one. What is in the rdi? (context here comes to the rdi setup before stack of check_password is even setup - i.e, this one : `lea    rax,[rbp-0x210]`). Just back propagation. gotta remember or note down what is from where, what is moved or copied or loaded into which register from where. 

Now that the first and second arguments are setup for the call of the 

`call   1070 <strcmp@plt>` : the legendary strcmp. So we gotta use the context. Why would anyone use the strcmp under a function named check_password? to compare whatever user inputed with the original password? And where do we get the user input from? See the context again, the `scanf` function is used. and the input from the user is stored in a pointer - the second argument of the scanf. What is the second argument of the `scanf`? `rbp-0x210` (contexted from the stack frame of the main.) Seems like the free initial 528 bytes that are set up during the start setup of the main's stack frame is a reserve for storing whatever is taken from the user input, then temproarily stored in registers to registers, finally getting compared via strcmp. That could possibly be one explanation. 

What is the second argument of the strcmp? Whatever string(mem locatoin/ char array) the address in rsi is pointing to. What we have in the `rsi`? `mov    rsi,rdx` as per this instruction we have whatever is in rdx, is in rsi currently. So what is in rdx?  `lea    rdx,[rip+0xe24]        # 204b <_IO_stdin_used+0x4b>` As per this instruction, rdx has the pointer to address 204b which is relative to rip. (register instruction pointer.). (note that it is absolute address that is loaded, aka the effective address). 

Now, definitely, based on the only context we have, the address 204b should be the start of the secret string. Continue tomorrow.. !! gonna sleep. 


Alright, this is the next day. 

But we don't get to see the address 204b. Our diassembly with the `-d` flag ends with the `.fini` section, relative address - 1254. (as per the below given block). 

```asm
0000000000001248 <_fini>:
    1248:	f3 0f 1e fa          	endbr64
    124c:	48 83 ec 08          	sub    rsp,0x8
    1250:	48 83 c4 08          	add    rsp,0x8
    1254:	c3                   	ret
```


So, we would need to disassemble all the sections in the binary. For that we use the `-D` flag in the objdump. 

What is the value in the `rsi` currently? it is some pointer pointing to the address 204b, in the section `.rodata` (read only data) under the label `<_IO_stdin_used>` and is at `+0x4b` from the start of the label. (i.e, 75 bytes.). 

The disassembly of the `.rodata` section is given below. 

```asm
Disassembly of section .rodata:

0000000000002000 <_IO_stdin_used>:
    2000:	01 00                	add    DWORD PTR [rax],eax
    2002:	02 00                	add    al,BYTE PTR [rax]
    2004:	00 00                	add    BYTE PTR [rax],al
    2006:	00 00                	add    BYTE PTR [rax],al
    2008:	45 6e                	rex.RB outs dx,BYTE PTR [rsi]
    200a:	74 65                	je     2071 <__GNU_EH_FRAME_HDR+0x11>
    200c:	72 20                	jb     202e <_IO_stdin_used+0x2e>
    200e:	74 68                	je     2078 <__GNU_EH_FRAME_HDR+0x18>
    2010:	65 20 70 61          	and    BYTE PTR gs:[rax+0x61],dh
    2014:	73 73                	jae    2089 <__GNU_EH_FRAME_HDR+0x29>
    2016:	77 6f                	ja     2087 <__GNU_EH_FRAME_HDR+0x27>
    2018:	72 64                	jb     207e <__GNU_EH_FRAME_HDR+0x1e>
    201a:	20 74 6f 20          	and    BYTE PTR [rdi+rbp*2+0x20],dh
    201e:	70 72                	jo     2092 <__GNU_EH_FRAME_HDR+0x32>
    2020:	69 6e 74 20 74 68 65 	imul   ebp,DWORD PTR [rsi+0x74],0x65687420
    2027:	20 73 65             	and    BYTE PTR [rbx+0x65],dh
    202a:	63 72 65             	movsxd esi,DWORD PTR [rdx+0x65]
    202d:	74 20                	je     204f <_IO_stdin_used+0x4f>
    202f:	3a 20                	cmp    ah,BYTE PTR [rax]
    2031:	00 25 73 00 53 75    	add    BYTE PTR [rip+0x75530073],ah        # 755320aa <_end+0x7552e06a>
    2037:	63 63 65             	movsxd esp,DWORD PTR [rbx+0x65]
    203a:	73 73                	jae    20af <__GNU_EH_FRAME_HDR+0x4f>
    203c:	21 21                	and    DWORD PTR [rcx],esp
    203e:	21 00                	and    DWORD PTR [rax],eax
    2040:	46 61                	rex.RX (bad)
    2042:	69 6c 75 72 65 21 21 	imul   ebp,DWORD PTR [rbp+rsi*2+0x72],0x21212165
    2049:	21 
    204a:	00 41 6a             	add    BYTE PTR [rcx+0x6a],al
    204d:	61                   	(bad)
    204e:	78 4b                	js     209b <__GNU_EH_FRAME_HDR+0x3b>
    2050:	31 32                	xor    DWORD PTR [rdx],esi
    2052:	33 26                	xor    esp,DWORD PTR [rsi]
    2054:	6c                   	ins    BYTE PTR [rdi],dx
    2055:	6f                   	outs   dx,DWORD PTR [rsi]
    2056:	6c                   	ins    BYTE PTR [rdi],dx
    2057:	63 61 74             	movsxd esp,DWORD PTR [rcx+0x74]
    205a:	2d 68 75 61 3b       	sub    eax,0x3b617568
	...
```


Again, it just seems like a mess. But if we see with EYES OPEN, the `<_IO_stdin_used>` section starts at the relative address `2000`, and the pointer at `rsi` (second argument) points to + 75 bytes from this address, that is `204b`. So, our string should probably start from that address, all the way down, till we find the first null terminator. `00` byte. But as usual, some of the valid bytes are converted into `opcodes` by the objdump program. I.e, it misinterets some bytes to be valid assembly instructions and builds up the fake instructions that are never meant to exist. Those are called as pseudoinstructions. Most of the bytes in the `.rodata` section, are not meant to be operations, but just bytecodes misinterepted as operations. In reality, the program never executes those operations. 

All we have to do to decode the string now is start from the `204b` address, copy the stuff, put in gemini to spit out the string it represents. 


But alas, where is the 204b byte address? It does not exist? Nah, it is just hidden. So copy the entire label <_IO_stdin_used> and ask some AI to find the string that starts at 204b. 

## The friendly gemini conversation 

Question 1 : 

```txt 
Disassembly of section .rodata:

0000000000002000 <_IO_stdin_used>:
    2000:    01 00                    add    DWORD PTR [rax],eax
    2002:    02 00                    add    al,BYTE PTR [rax]
    2004:    00 00                    add    BYTE PTR [rax],al
    2006:    00 00                    add    BYTE PTR [rax],al
    2008:    45 6e                    rex.RB outs dx,BYTE PTR [rsi]
    200a:    74 65                    je     2071 <__GNU_EH_FRAME_HDR+0x11>
    200c:    72 20                    jb     202e <_IO_stdin_used+0x2e>
    200e:    74 68                    je     2078 <__GNU_EH_FRAME_HDR+0x18>
    2010:    65 20 70 61              and    BYTE PTR gs:[rax+0x61],dh
    2014:    73 73                    jae    2089 <__GNU_EH_FRAME_HDR+0x29>
    2016:    77 6f                    ja     2087 <__GNU_EH_FRAME_HDR+0x27>
    2018:    72 64                    jb     207e <__GNU_EH_FRAME_HDR+0x1e>
    201a:    20 74 6f 20              and    BYTE PTR [rdi+rbp*2+0x20],dh
    201e:    70 72                    jo     2092 <__GNU_EH_FRAME_HDR+0x32>
    2020:    69 6e 74 20 74 68 65     imul   ebp,DWORD PTR [rsi+0x74],0x65687420
    2027:    20 73 65                 and    BYTE PTR [rbx+0x65],dh
    202a:    63 72 65                 movsxd esi,DWORD PTR [rdx+0x65]
    202d:    74 20                    je     204f <_IO_stdin_used+0x4f>
    202f:    3a 20                    cmp    ah,BYTE PTR [rax]
    2031:    00 25 73 00 53 75        add    BYTE PTR [rip+0x75530073],ah        # 755320aa <_end+0x7552e06a>
    2037:    63 63 65                 movsxd esp,DWORD PTR [rbx+0x65]
    203a:    73 73                    jae    20af <__GNU_EH_FRAME_HDR+0x4f>
    203c:    21 21                    and    DWORD PTR [rcx],esp
    203e:    21 00                    and    DWORD PTR [rax],eax
    2040:    46 61                    rex.RX (bad)
    2042:    69 6c 75 72 65 21 21     imul   ebp,DWORD PTR [rbp+rsi*2+0x72],0x21212165
    2049:    21 
    204a:    00 41 6a                 add    BYTE PTR [rcx+0x6a],al
    204d:    61                       (bad)
    204e:    78 4b                    js     209b <__GNU_EH_FRAME_HDR+0x3b>
    2050:    31 32                    xor    DWORD PTR [rdx],esi
    2052:    33 26                    xor    esp,DWORD PTR [rsi]
    2054:    6c                       ins    BYTE PTR [rdi],dx
    2055:    6f                       outs   dx,DWORD PTR [rsi]
    2056:    6c                       ins    BYTE PTR [rdi],dx
    2057:    63 61 74                 movsxd esp,DWORD PTR [rcx+0x74]
    205a:    2d 68 75 61 3b           sub    eax,0x3b617568


Where does the address 204b start here?
```


Answer: 

Address **`204b`** is located inside the byte sequence on the line starting at **`204a`**:

```text
 204a:    00 41 6a                 add    BYTE PTR [rcx+0x6a],al

```

### Byte-by-Byte Breakdown at `204a`

Because the instruction starting at `204a` is 3 bytes long (`00 41 6a`), the addresses map to individual hex bytes as follows:

* **`204a`**: `00`
* **`204b`**: **`41`** *(starts here)*
* **`204c`**: `6a`


### Context: ASCII Data in `.rodata`

Because this section is `.rodata` (read-only data), the bytes are actually string data that `objdump` tried to disassemble as x86 assembly code.

If you translate the hex bytes starting from **`204b`** (`41 6a 61 78 4b 31 32 33 26...`) into ASCII text, it reveals the stored string:

| Address | Hex Byte | ASCII Character |
| --- | --- | --- |
| **`204b`** | **`41`** | **A** |
| **`204c`** | `6a` | **j** |
| **`204d`** | `61` | **a** |
| **`204e`** | `78` | **x** |
| **`204f`** | `4b` | **K** |
| **`2050`** | `31` | **1** |
| **`2051`** | `32` | **2** |
| **`2052`** | `33` | **3** |
| ... | ... | ... |

Starting at address `204b`, the ASCII string reads: **`AjaxK123&lolcat-hua;`**

Ah, here it is, on the single stroke it delivered the string. How did it know when to stop the string sequencing? As stated earilier somewhere, the C strings are null terminated. So, the sequencing of the string stops when it meets the first null terminator, starting from the byte address 204b. 


Here is the exact table matching the bytes.

| Address | Hex Byte | ASCII Character | Disassembly Source Line |
| --- | --- | --- | --- |
| **`204b`** | **`41`** | **A** | `204a: 00 41 6a` |
| `204c` | `6a` | **j** | `204a: 00 41 6a` |
| `204d` | `61` | **a** | `204d: 61` |
| `204e` | `78` | **x** | `204e: 78 4b` |
| `204f` | `4b` | **K** | `204e: 78 4b` |
| `2050` | `31` | **1** | `2050: 31 32` |
| `2051` | `32` | **2** | `2050: 31 32` |
| `2052` | `33` | **3** | `2052: 33 26` |
| `2053` | `26` | **&** | `2052: 33 26` |
| `2054` | `6c` | **l** | `2054: 6c` |
| `2055` | `6f` | **o** | `2055: 6f` |
| `2056` | `6c` | **l** | `2056: 6c` |
| `2057` | `63` | **c** | `2057: 63 61 74` |
| `2058` | `61` | **a** | `2057: 63 61 74` |
| `2059` | `74` | **t** | `2057: 63 61 74` |
| `205a` | `2d` | **-** | `205a: 2d 68 75 61 3b` |
| `205b` | `68` | **h** | `205a: 2d 68 75 61 3b` |
| `205c` | `75` | **u** | `205a: 2d 68 75 61 3b` |
| `205d` | `61` | **a** | `205a: 2d 68 75 61 3b` |
| `205e` | `3b` | **;** | `205a: 2d 68 75 61 3b` |


Now that we need to finalise. Though I am not yet clear with the micro operations of the call, leave, jmp etc instructions, we have done a pretty good amount of disassembly to map the control flow and find the string. Run the `verify-it` binary once again and we'll see if we do not get a Failure!!!. 


Enter the string we just found. 

```txt
init88/intro/binaries on  main [?] ❯ ./verify-it
Enter the password to print the secret : AjaxK123&lolcat-hua;
Success!!!
init88/intro/binaries on  main [?] took 18s ❯
```


And yay, we just cracked the code. But there is an even easier way. 
You just `cat` the binary and check for the readable strings. It would be some gibberish unprintable alongside the valid strings. If we don't need the gibberish, we just use the `strings` command as given 


```bash
strings verify-it
```

Which produces this output : 


```txt
0r/lib64/ld-linux-x86-64.so.2
puts
__stack_chk_fail
__isoc23_scanf
__libc_start_main
__cxa_finalize
printf
strcmp
libc.so.6
GLIBC_2.38
GLIBC_2.4
GLIBC_2.2.5
GLIBC_2.34
_ITM_deregisterTMCloneTable
__gmon_start__
_ITM_registerTMCloneTable
PTE1
u3UH
Enter the password to print the secret : 
Success!!!
Failure!!!
AjaxK123&lolcat-hua;
;*3$"
GCC: (GNU) 16.1.1 20260728
Scrt1.o
__abi_tag
crtbeginS.o
deregister_tm_clones
__do_global_dtors_aux
completed.0
__do_global_dtors_aux_fini_array_entry
frame_dummy
__frame_dummy_init_array_entry
verify-it.c
crtendS.o
__FRAME_END__
_DYNAMIC
__GNU_EH_FRAME_HDR
_GLOBAL_OFFSET_TABLE_
__libc_start_main@GLIBC_2.34
_ITM_deregisterTMCloneTable
puts@GLIBC_2.2.5
_edata
_fini
__stack_chk_fail@GLIBC_2.4
printf@GLIBC_2.2.5
__isoc23_scanf@GLIBC_2.38
__data_start
strcmp@GLIBC_2.2.5
__gmon_start__
__dso_handle
_IO_stdin_used
_end
__bss_start
main
check_password
__TMC_END__
_ITM_registerTMCloneTable
__cxa_finalize@GLIBC_2.2.5
_init
.symtab
.strtab
.shstrtab
.note.gnu.build-id
.interp
.gnu.hash
.dynsym
.dynstr
.gnu.version
.gnu.version_r
.rela.dyn
.rela.plt
.init
.text
.fini
.rodata
.eh_frame_hdr
.eh_frame
.sframe
.note.gnu.property
.note.ABI-tag
.init_array
.fini_array
.dynamic
.got
.got.plt
.data
.bss
.comment
```


Right there is the `AjaxK123&lolcat-hua;` string. But alongside with many other strings. We might have to take a wild guess if it could be a password. Also, if there are multiple similar strings, then there will be a complication in guessing. so direct disassembly is useful, yet overkill, but a learning for this binary. 

I shall explain the remaining part of the executable section below. 


