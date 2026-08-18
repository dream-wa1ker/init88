0000000000001139 <lolcat>:
    1139:	55                   	push   rbp
    113a:	48 89 e5             	mov    rbp,rsp
    113d:	48 89 7d f8          	mov    QWORD PTR [rbp-0x8],rdi
    1141:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    1145:	8b 00                	mov    eax,DWORD PTR [rax]
    1147:	83 f8 0a             	cmp    eax,0xa
    114a:	75 07                	jne    1153 <lolcat+0x1a>
    114c:	b8 00 00 00 00       	mov    eax,0x0
    1151:	eb 05                	jmp    1158 <lolcat+0x1f>
    1153:	b8 01 00 00 00       	mov    eax,0x1
    1158:	5d                   	pop    rbp
    1159:	c3                   	ret

000000000000115a <main>:
    115a:	55                   	push   rbp
    115b:	48 89 e5             	mov    rbp,rsp
    115e:	48 83 ec 10          	sub    rsp,0x10
    1162:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    1169:	00 00 
    116b:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    116f:	31 c0                	xor    eax,eax
    1171:	c7 45 f4 0a 00 00 00 	mov    DWORD PTR [rbp-0xc],0xa
    1178:	48 8d 45 f4          	lea    rax,[rbp-0xc]
    117c:	48 89 c7             	mov    rdi,rax
    117f:	e8 b5 ff ff ff       	call   1139 <lolcat>
    1184:	85 c0                	test   eax,eax
    1186:	74 07                	je     118f <main+0x35>
    1188:	b8 ff ff ff ff       	mov    eax,0xffffffff
    118d:	eb 05                	jmp    1194 <main+0x3a>
    118f:	b8 00 00 00 00       	mov    eax,0x0
    1194:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
    1198:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
    119f:	00 00 
    11a1:	74 05                	je     11a8 <main+0x4e>
    11a3:	e8 88 fe ff ff       	call   1030 <__stack_chk_fail@plt>
    11a8:	c9                   	leave
    11a9:	c3                   	ret
