// name : printf-number.c 
// date : 2026-08-08 
// std  : C 23 standard 
// desc : this is the printf-number.s; equivalent, but in C

//---------------------------------- include header files -------------------------------
// actually we are gonna use extern : just man printf and grab the function signature

extern int printf(const char *restrict format, ...);

const int a = 800;
const char* fmt_string = "This is a number : %d; whose address is %p\n";
//--------------------------------------- main program ----------------------------------
int main(void) {

    printf(fmt_string, a, &a);
    // we are gonna dissassemble it with objdump and see if it matches our asseebly version.
    return 0;
}

