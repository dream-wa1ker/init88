Foundational mechanics - 

FLAGS register. The CPU has hidden register called the RFLAGS. that is called the register flags. Alright. What next? This rflags is where some of the most important values are written. like the instructions - cmp, test, sub, add, and, or, etc, write bits into it as a side effect of their arithmetic. So what is this about? What is the RFLAGS register? how is it used? how to interpret the instructions related to it and connect things? is it evn possible? and yes it is of course. 


### The two flags 

ZF : The zero flag - is set to true value (1) if the instruction's result was 0.
SF : The sign flag - is set to true value (1) if the result's most significant bit is 1, i.e, the result is negative, as a signed number. 

so, the `jne` and `je` instructions (jump if not equal) and (jump if equal) will just read the values from the RFLAGS - the ZF and the SF whether or not to redirect the instruction pointer. The RIP. 

`cmp` dst, src : subtract the source from the destination and update the rflags respectively => dst - src and updates the RFLAGS. 

if dst - src = 0, then the ZF flag is set to true => 1 
if dst - src < 0, then the SF flag is set to true => 1 
if dst - src > 0, then both the ZF and the SF flags are set to false => 0

`je` label : jump to the label (label is the name of the function) if the ZF flag is equal 1, ie the previous instruction set the ZF flag to true. Else, it does not jump to the label and continues. 

`jne` label : jump to the label if the ZF flag is not equal to 1, ie the previous instruction set the ZF flag to false. Else, it continues without jumping to the function. 

`jmp` label : this is unconditionally jumping to the label. Like, there is not ZF or SF flag that is read to make a jump to a label. 

`test` dst, src : this will do the bitwise operation : dst & src => which will set the ZF flag to true (1) if the result of the AND bitwise operation is purely 0.

Some examples of the test operation is this : 

`test rax, rax` : checks if the register rax is zero (often followed by je or jz).
`test rbx, 1` : checks if the lowest bit of rbx is set (testing if a number is odd or even).


