
obj/user/faultalloc:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b5 00 00 00       	call   8000e6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 10 80 00       	push   $0x801080
  800045:	e8 cf 01 00 00       	call   800219 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 91 0b 00 00       	call   800bef <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 32                	js     800097 <handler+0x64>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);

	cprintf("Finish alloc for %x\n",addr);
  800065:	83 ec 08             	sub    $0x8,%esp
  800068:	53                   	push   %ebx
  800069:	68 9c 10 80 00       	push   $0x80109c
  80006e:	e8 a6 01 00 00       	call   800219 <cprintf>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800073:	53                   	push   %ebx
  800074:	68 00 11 80 00       	push   $0x801100
  800079:	6a 64                	push   $0x64
  80007b:	53                   	push   %ebx
  80007c:	e8 1d 07 00 00       	call   80079e <snprintf>
	cprintf("Finish write string for %x\n",addr);
  800081:	83 c4 18             	add    $0x18,%esp
  800084:	53                   	push   %ebx
  800085:	68 b1 10 80 00       	push   $0x8010b1
  80008a:	e8 8a 01 00 00       	call   800219 <cprintf>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800095:	c9                   	leave  
  800096:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	50                   	push   %eax
  80009b:	53                   	push   %ebx
  80009c:	68 d4 10 80 00       	push   $0x8010d4
  8000a1:	6a 0e                	push   $0xe
  8000a3:	68 8a 10 80 00       	push   $0x80108a
  8000a8:	e8 91 00 00 00       	call   80013e <_panic>

008000ad <umain>:

void
umain(int argc, char **argv)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  8000b3:	68 33 00 80 00       	push   $0x800033
  8000b8:	e8 e1 0c 00 00       	call   800d9e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000bd:	83 c4 08             	add    $0x8,%esp
  8000c0:	68 ef be ad de       	push   $0xdeadbeef
  8000c5:	68 cd 10 80 00       	push   $0x8010cd
  8000ca:	e8 4a 01 00 00       	call   800219 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000cf:	83 c4 08             	add    $0x8,%esp
  8000d2:	68 fe bf fe ca       	push   $0xcafebffe
  8000d7:	68 cd 10 80 00       	push   $0x8010cd
  8000dc:	e8 38 01 00 00       	call   800219 <cprintf>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    

008000e6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ee:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t env_id=sys_getenvid();
  8000f1:	e8 bb 0a 00 00       	call   800bb1 <sys_getenvid>
	thisenv =((struct Env*)envs)+ENVX(env_id);
  8000f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800103:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800108:	85 db                	test   %ebx,%ebx
  80010a:	7e 07                	jle    800113 <libmain+0x2d>
		binaryname = argv[0];
  80010c:	8b 06                	mov    (%esi),%eax
  80010e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	e8 90 ff ff ff       	call   8000ad <umain>

	// exit gracefully
	exit();
  80011d:	e8 0a 00 00 00       	call   80012c <exit>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800132:	6a 00                	push   $0x0
  800134:	e8 37 0a 00 00       	call   800b70 <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800143:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800146:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014c:	e8 60 0a 00 00       	call   800bb1 <sys_getenvid>
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	ff 75 0c             	push   0xc(%ebp)
  800157:	ff 75 08             	push   0x8(%ebp)
  80015a:	56                   	push   %esi
  80015b:	50                   	push   %eax
  80015c:	68 2c 11 80 00       	push   $0x80112c
  800161:	e8 b3 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800166:	83 c4 18             	add    $0x18,%esp
  800169:	53                   	push   %ebx
  80016a:	ff 75 10             	push   0x10(%ebp)
  80016d:	e8 56 00 00 00       	call   8001c8 <vcprintf>
	cprintf("\n");
  800172:	c7 04 24 cf 10 80 00 	movl   $0x8010cf,(%esp)
  800179:	e8 9b 00 00 00       	call   800219 <cprintf>
  80017e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800181:	cc                   	int3   
  800182:	eb fd                	jmp    800181 <_panic+0x43>

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 13                	mov    (%ebx),%edx
  800190:	8d 42 01             	lea    0x1(%edx),%eax
  800193:	89 03                	mov    %eax,(%ebx)
  800195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a1:	74 09                	je     8001ac <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	68 ff 00 00 00       	push   $0xff
  8001b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b7:	50                   	push   %eax
  8001b8:	e8 76 09 00 00       	call   800b33 <sys_cputs>
		b->idx = 0;
  8001bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb db                	jmp    8001a3 <putch+0x1f>

008001c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	push   0xc(%ebp)
  8001e8:	ff 75 08             	push   0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 84 01 80 00       	push   $0x800184
  8001f7:	e8 14 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 22 09 00 00       	call   800b33 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800222:	50                   	push   %eax
  800223:	ff 75 08             	push   0x8(%ebp)
  800226:	e8 9d ff ff ff       	call   8001c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 1c             	sub    $0x1c,%esp
  800236:	89 c7                	mov    %eax,%edi
  800238:	89 d6                	mov    %edx,%esi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 d1                	mov    %edx,%ecx
  800242:	89 c2                	mov    %eax,%edx
  800244:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800247:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800253:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025a:	39 c2                	cmp    %eax,%edx
  80025c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025f:	72 3e                	jb     80029f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 18             	push   0x18(%ebp)
  800267:	83 eb 01             	sub    $0x1,%ebx
  80026a:	53                   	push   %ebx
  80026b:	50                   	push   %eax
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 e4             	push   -0x1c(%ebp)
  800272:	ff 75 e0             	push   -0x20(%ebp)
  800275:	ff 75 dc             	push   -0x24(%ebp)
  800278:	ff 75 d8             	push   -0x28(%ebp)
  80027b:	e8 c0 0b 00 00       	call   800e40 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 9f ff ff ff       	call   80022d <printnum>
  80028e:	83 c4 20             	add    $0x20,%esp
  800291:	eb 13                	jmp    8002a6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	ff 75 18             	push   0x18(%ebp)
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7f ed                	jg     800293 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	ff 75 e4             	push   -0x1c(%ebp)
  8002b0:	ff 75 e0             	push   -0x20(%ebp)
  8002b3:	ff 75 dc             	push   -0x24(%ebp)
  8002b6:	ff 75 d8             	push   -0x28(%ebp)
  8002b9:	e8 a2 0c 00 00       	call   800f60 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 4f 11 80 00 	movsbl 0x80114f(%eax),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff d7                	call   *%edi
}
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e5:	73 0a                	jae    8002f1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	88 02                	mov    %al,(%edx)
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <printfmt>:
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fc:	50                   	push   %eax
  8002fd:	ff 75 10             	push   0x10(%ebp)
  800300:	ff 75 0c             	push   0xc(%ebp)
  800303:	ff 75 08             	push   0x8(%ebp)
  800306:	e8 05 00 00 00       	call   800310 <vprintfmt>
}
  80030b:	83 c4 10             	add    $0x10,%esp
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 3c             	sub    $0x3c,%esp
  800319:	8b 75 08             	mov    0x8(%ebp),%esi
  80031c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800322:	eb 0a                	jmp    80032e <vprintfmt+0x1e>
			putch(ch, putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	53                   	push   %ebx
  800328:	50                   	push   %eax
  800329:	ff d6                	call   *%esi
  80032b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032e:	83 c7 01             	add    $0x1,%edi
  800331:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800335:	83 f8 25             	cmp    $0x25,%eax
  800338:	74 0c                	je     800346 <vprintfmt+0x36>
			if (ch == '\0')
  80033a:	85 c0                	test   %eax,%eax
  80033c:	75 e6                	jne    800324 <vprintfmt+0x14>
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    
		padc = ' ';
  800346:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800351:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800358:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 17             	movzbl (%edi),%edx
  80036d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800370:	3c 55                	cmp    $0x55,%al
  800372:	0f 87 bb 03 00 00    	ja     800733 <vprintfmt+0x423>
  800378:	0f b6 c0             	movzbl %al,%eax
  80037b:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800385:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800389:	eb d9                	jmp    800364 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800392:	eb d0                	jmp    800364 <vprintfmt+0x54>
  800394:	0f b6 d2             	movzbl %dl,%edx
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039a:	b8 00 00 00 00       	mov    $0x0,%eax
  80039f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003af:	83 f9 09             	cmp    $0x9,%ecx
  8003b2:	77 55                	ja     800409 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b7:	eb e9                	jmp    8003a2 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 40 04             	lea    0x4(%eax),%eax
  8003c7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d1:	79 91                	jns    800364 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e0:	eb 82                	jmp    800364 <vprintfmt+0x54>
  8003e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	0f 49 c2             	cmovns %edx,%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f5:	e9 6a ff ff ff       	jmp    800364 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800404:	e9 5b ff ff ff       	jmp    800364 <vprintfmt+0x54>
  800409:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	eb bc                	jmp    8003cd <vprintfmt+0xbd>
			lflag++;
  800411:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800417:	e9 48 ff ff ff       	jmp    800364 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 30                	push   (%eax)
  800428:	ff d6                	call   *%esi
			break;
  80042a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800430:	e9 9d 02 00 00       	jmp    8006d2 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 78 04             	lea    0x4(%eax),%edi
  80043b:	8b 10                	mov    (%eax),%edx
  80043d:	89 d0                	mov    %edx,%eax
  80043f:	f7 d8                	neg    %eax
  800441:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800444:	83 f8 08             	cmp    $0x8,%eax
  800447:	7f 23                	jg     80046c <vprintfmt+0x15c>
  800449:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800450:	85 d2                	test   %edx,%edx
  800452:	74 18                	je     80046c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800454:	52                   	push   %edx
  800455:	68 70 11 80 00       	push   $0x801170
  80045a:	53                   	push   %ebx
  80045b:	56                   	push   %esi
  80045c:	e8 92 fe ff ff       	call   8002f3 <printfmt>
  800461:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800464:	89 7d 14             	mov    %edi,0x14(%ebp)
  800467:	e9 66 02 00 00       	jmp    8006d2 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80046c:	50                   	push   %eax
  80046d:	68 67 11 80 00       	push   $0x801167
  800472:	53                   	push   %ebx
  800473:	56                   	push   %esi
  800474:	e8 7a fe ff ff       	call   8002f3 <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047f:	e9 4e 02 00 00       	jmp    8006d2 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	83 c0 04             	add    $0x4,%eax
  80048a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800492:	85 d2                	test   %edx,%edx
  800494:	b8 60 11 80 00       	mov    $0x801160,%eax
  800499:	0f 45 c2             	cmovne %edx,%eax
  80049c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a3:	7e 06                	jle    8004ab <vprintfmt+0x19b>
  8004a5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a9:	75 0d                	jne    8004b8 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ae:	89 c7                	mov    %eax,%edi
  8004b0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	eb 55                	jmp    80050d <vprintfmt+0x1fd>
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 d8             	push   -0x28(%ebp)
  8004be:	ff 75 cc             	push   -0x34(%ebp)
  8004c1:	e8 0a 03 00 00       	call   8007d0 <strnlen>
  8004c6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c9:	29 c1                	sub    %eax,%ecx
  8004cb:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004d3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	eb 0f                	jmp    8004eb <vprintfmt+0x1db>
					putch(padc, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	ff 75 e0             	push   -0x20(%ebp)
  8004e3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ef 01             	sub    $0x1,%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 ff                	test   %edi,%edi
  8004ed:	7f ed                	jg     8004dc <vprintfmt+0x1cc>
  8004ef:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	0f 49 c2             	cmovns %edx,%eax
  8004fc:	29 c2                	sub    %eax,%edx
  8004fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800501:	eb a8                	jmp    8004ab <vprintfmt+0x19b>
					putch(ch, putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	53                   	push   %ebx
  800507:	52                   	push   %edx
  800508:	ff d6                	call   *%esi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800510:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	83 c7 01             	add    $0x1,%edi
  800515:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800519:	0f be d0             	movsbl %al,%edx
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 4b                	je     80056b <vprintfmt+0x25b>
  800520:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800524:	78 06                	js     80052c <vprintfmt+0x21c>
  800526:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052a:	78 1e                	js     80054a <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800530:	74 d1                	je     800503 <vprintfmt+0x1f3>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 c6                	jbe    800503 <vprintfmt+0x1f3>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 3f                	push   $0x3f
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb c3                	jmp    80050d <vprintfmt+0x1fd>
  80054a:	89 cf                	mov    %ecx,%edi
  80054c:	eb 0e                	jmp    80055c <vprintfmt+0x24c>
				putch(' ', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 20                	push   $0x20
  800554:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800556:	83 ef 01             	sub    $0x1,%edi
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 ff                	test   %edi,%edi
  80055e:	7f ee                	jg     80054e <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800560:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
  800566:	e9 67 01 00 00       	jmp    8006d2 <vprintfmt+0x3c2>
  80056b:	89 cf                	mov    %ecx,%edi
  80056d:	eb ed                	jmp    80055c <vprintfmt+0x24c>
	if (lflag >= 2)
  80056f:	83 f9 01             	cmp    $0x1,%ecx
  800572:	7f 1b                	jg     80058f <vprintfmt+0x27f>
	else if (lflag)
  800574:	85 c9                	test   %ecx,%ecx
  800576:	74 63                	je     8005db <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	99                   	cltd   
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb 17                	jmp    8005a6 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 50 04             	mov    0x4(%eax),%edx
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	0f 89 ff 00 00 00    	jns    8006b8 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	f7 da                	neg    %edx
  8005c9:	83 d1 00             	adc    $0x0,%ecx
  8005cc:	f7 d9                	neg    %ecx
  8005ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d6:	e9 dd 00 00 00       	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	99                   	cltd   
  8005e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f0:	eb b4                	jmp    8005a6 <vprintfmt+0x296>
	if (lflag >= 2)
  8005f2:	83 f9 01             	cmp    $0x1,%ecx
  8005f5:	7f 1e                	jg     800615 <vprintfmt+0x305>
	else if (lflag)
  8005f7:	85 c9                	test   %ecx,%ecx
  8005f9:	74 32                	je     80062d <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	b9 00 00 00 00       	mov    $0x0,%ecx
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800610:	e9 a3 00 00 00       	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	8b 48 04             	mov    0x4(%eax),%ecx
  80061d:	8d 40 08             	lea    0x8(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800623:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800628:	e9 8b 00 00 00       	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 10                	mov    (%eax),%edx
  800632:	b9 00 00 00 00       	mov    $0x0,%ecx
  800637:	8d 40 04             	lea    0x4(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800642:	eb 74                	jmp    8006b8 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7f 1b                	jg     800664 <vprintfmt+0x354>
	else if (lflag)
  800649:	85 c9                	test   %ecx,%ecx
  80064b:	74 2c                	je     800679 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800662:	eb 54                	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	8b 48 04             	mov    0x4(%eax),%ecx
  80066c:	8d 40 08             	lea    0x8(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800672:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800677:	eb 3f                	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800689:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80068e:	eb 28                	jmp    8006b8 <vprintfmt+0x3a8>
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 30                	push   $0x30
  800696:	ff d6                	call   *%esi
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 78                	push   $0x78
  80069e:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006bf:	50                   	push   %eax
  8006c0:	ff 75 e0             	push   -0x20(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	51                   	push   %ecx
  8006c5:	52                   	push   %edx
  8006c6:	89 da                	mov    %ebx,%edx
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	e8 5e fb ff ff       	call   80022d <printnum>
			break;
  8006cf:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d5:	e9 54 fc ff ff       	jmp    80032e <vprintfmt+0x1e>
	if (lflag >= 2)
  8006da:	83 f9 01             	cmp    $0x1,%ecx
  8006dd:	7f 1b                	jg     8006fa <vprintfmt+0x3ea>
	else if (lflag)
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	74 2c                	je     80070f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006f8:	eb be                	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800702:	8d 40 08             	lea    0x8(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800708:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80070d:	eb a9                	jmp    8006b8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800724:	eb 92                	jmp    8006b8 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			break;
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 9f                	jmp    8006d2 <vprintfmt+0x3c2>
			putch('%', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 25                	push   $0x25
  800739:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	89 f8                	mov    %edi,%eax
  800740:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800744:	74 05                	je     80074b <vprintfmt+0x43b>
  800746:	83 e8 01             	sub    $0x1,%eax
  800749:	eb f5                	jmp    800740 <vprintfmt+0x430>
  80074b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074e:	eb 82                	jmp    8006d2 <vprintfmt+0x3c2>

00800750 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	push   0x14(%ebp)
  800778:	ff 75 10             	push   0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 d6 02 80 00       	push   $0x8002d6
  800784:	e8 87 fb ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb f7                	jmp    800795 <vsnprintf+0x45>

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	push   0x10(%ebp)
  8007ab:	ff 75 0c             	push   0xc(%ebp)
  8007ae:	ff 75 08             	push   0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 08                	je     8007ef <strnlen+0x1f>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
  8007ed:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ef:	89 d0                	mov    %edx,%eax
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800806:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	84 d2                	test   %dl,%dl
  80080e:	75 f2                	jne    800802 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800810:	89 c8                	mov    %ecx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 10             	sub    $0x10,%esp
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800821:	53                   	push   %ebx
  800822:	e8 91 ff ff ff       	call   8007b8 <strlen>
  800827:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80082a:	ff 75 0c             	push   0xc(%ebp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	50                   	push   %eax
  800830:	e8 be ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  800835:	89 d8                	mov    %ebx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
  800847:	89 f3                	mov    %esi,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	eb 0f                	jmp    80085f <strncpy+0x23>
		*dst++ = *src;
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	0f b6 0a             	movzbl (%edx),%ecx
  800856:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 f9 01             	cmp    $0x1,%cl
  80085c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80085f:	39 d8                	cmp    %ebx,%eax
  800861:	75 ed                	jne    800850 <strncpy+0x14>
	}
	return ret;
}
  800863:	89 f0                	mov    %esi,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800874:	8b 55 10             	mov    0x10(%ebp),%edx
  800877:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 21                	je     80089e <strlcpy+0x35>
  80087d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 09                	jmp    80088e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
  80088b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80088e:	39 c2                	cmp    %eax,%edx
  800890:	74 09                	je     80089b <strlcpy+0x32>
  800892:	0f b6 19             	movzbl (%ecx),%ebx
  800895:	84 db                	test   %bl,%bl
  800897:	75 ec                	jne    800885 <strlcpy+0x1c>
  800899:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80089b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089e:	29 f0                	sub    %esi,%eax
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ad:	eb 06                	jmp    8008b5 <strcmp+0x11>
		p++, q++;
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b5:	0f b6 01             	movzbl (%ecx),%eax
  8008b8:	84 c0                	test   %al,%al
  8008ba:	74 04                	je     8008c0 <strcmp+0x1c>
  8008bc:	3a 02                	cmp    (%edx),%al
  8008be:	74 ef                	je     8008af <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 c0             	movzbl %al,%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	89 c3                	mov    %eax,%ebx
  8008d6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d9:	eb 06                	jmp    8008e1 <strncmp+0x17>
		n--, p++, q++;
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e1:	39 d8                	cmp    %ebx,%eax
  8008e3:	74 18                	je     8008fd <strncmp+0x33>
  8008e5:	0f b6 08             	movzbl (%eax),%ecx
  8008e8:	84 c9                	test   %cl,%cl
  8008ea:	74 04                	je     8008f0 <strncmp+0x26>
  8008ec:	3a 0a                	cmp    (%edx),%cl
  8008ee:	74 eb                	je     8008db <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 00             	movzbl (%eax),%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
		return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800902:	eb f4                	jmp    8008f8 <strncmp+0x2e>

00800904 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	eb 03                	jmp    800913 <strchr+0xf>
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 10             	movzbl (%eax),%edx
  800916:	84 d2                	test   %dl,%dl
  800918:	74 06                	je     800920 <strchr+0x1c>
		if (*s == c)
  80091a:	38 ca                	cmp    %cl,%dl
  80091c:	75 f2                	jne    800910 <strchr+0xc>
  80091e:	eb 05                	jmp    800925 <strchr+0x21>
			return (char *) s;
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800931:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	74 09                	je     800941 <strfind+0x1a>
  800938:	84 d2                	test   %dl,%dl
  80093a:	74 05                	je     800941 <strfind+0x1a>
	for (; *s; s++)
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	eb f0                	jmp    800931 <strfind+0xa>
			break;
	return (char *) s;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094f:	85 c9                	test   %ecx,%ecx
  800951:	74 2f                	je     800982 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800953:	89 f8                	mov    %edi,%eax
  800955:	09 c8                	or     %ecx,%eax
  800957:	a8 03                	test   $0x3,%al
  800959:	75 21                	jne    80097c <memset+0x39>
		c &= 0xFF;
  80095b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095f:	89 d0                	mov    %edx,%eax
  800961:	c1 e0 08             	shl    $0x8,%eax
  800964:	89 d3                	mov    %edx,%ebx
  800966:	c1 e3 18             	shl    $0x18,%ebx
  800969:	89 d6                	mov    %edx,%esi
  80096b:	c1 e6 10             	shl    $0x10,%esi
  80096e:	09 f3                	or     %esi,%ebx
  800970:	09 da                	or     %ebx,%edx
  800972:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800974:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800977:	fc                   	cld    
  800978:	f3 ab                	rep stos %eax,%es:(%edi)
  80097a:	eb 06                	jmp    800982 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097f:	fc                   	cld    
  800980:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800982:	89 f8                	mov    %edi,%eax
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5f                   	pop    %edi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 75 0c             	mov    0xc(%ebp),%esi
  800994:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800997:	39 c6                	cmp    %eax,%esi
  800999:	73 32                	jae    8009cd <memmove+0x44>
  80099b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099e:	39 c2                	cmp    %eax,%edx
  8009a0:	76 2b                	jbe    8009cd <memmove+0x44>
		s += n;
		d += n;
  8009a2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a5:	89 d6                	mov    %edx,%esi
  8009a7:	09 fe                	or     %edi,%esi
  8009a9:	09 ce                	or     %ecx,%esi
  8009ab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b1:	75 0e                	jne    8009c1 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b3:	83 ef 04             	sub    $0x4,%edi
  8009b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 09                	jmp    8009ca <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c1:	83 ef 01             	sub    $0x1,%edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 1a                	jmp    8009e7 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	89 f2                	mov    %esi,%edx
  8009cf:	09 c2                	or     %eax,%edx
  8009d1:	09 ca                	or     %ecx,%edx
  8009d3:	f6 c2 03             	test   $0x3,%dl
  8009d6:	75 0a                	jne    8009e2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 05                	jmp    8009e7 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f1:	ff 75 10             	push   0x10(%ebp)
  8009f4:	ff 75 0c             	push   0xc(%ebp)
  8009f7:	ff 75 08             	push   0x8(%ebp)
  8009fa:	e8 8a ff ff ff       	call   800989 <memmove>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 c6                	mov    %eax,%esi
  800a0e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	eb 06                	jmp    800a19 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a19:	39 f0                	cmp    %esi,%eax
  800a1b:	74 14                	je     800a31 <memcmp+0x30>
		if (*s1 != *s2)
  800a1d:	0f b6 08             	movzbl (%eax),%ecx
  800a20:	0f b6 1a             	movzbl (%edx),%ebx
  800a23:	38 d9                	cmp    %bl,%cl
  800a25:	74 ec                	je     800a13 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a27:	0f b6 c1             	movzbl %cl,%eax
  800a2a:	0f b6 db             	movzbl %bl,%ebx
  800a2d:	29 d8                	sub    %ebx,%eax
  800a2f:	eb 05                	jmp    800a36 <memcmp+0x35>
	}

	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a48:	eb 03                	jmp    800a4d <memfind+0x13>
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	39 d0                	cmp    %edx,%eax
  800a4f:	73 04                	jae    800a55 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	75 f5                	jne    800a4a <memfind+0x10>
			break;
	return (void *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	eb 03                	jmp    800a68 <strtol+0x11>
		s++;
  800a65:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a68:	0f b6 02             	movzbl (%edx),%eax
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f6                	je     800a65 <strtol+0xe>
  800a6f:	3c 09                	cmp    $0x9,%al
  800a71:	74 f2                	je     800a65 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	74 2a                	je     800aa1 <strtol+0x4a>
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7c:	3c 2d                	cmp    $0x2d,%al
  800a7e:	74 2b                	je     800aab <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 0f                	jne    800a97 <strtol+0x40>
  800a88:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8b:	74 28                	je     800ab5 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a94:	0f 44 d8             	cmove  %eax,%ebx
  800a97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9f:	eb 46                	jmp    800ae7 <strtol+0x90>
		s++;
  800aa1:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa9:	eb d5                	jmp    800a80 <strtol+0x29>
		s++, neg = 1;
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab3:	eb cb                	jmp    800a80 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab9:	74 0e                	je     800ac9 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 d8                	jne    800a97 <strtol+0x40>
		s++, base = 8;
  800abf:	83 c2 01             	add    $0x1,%edx
  800ac2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac7:	eb ce                	jmp    800a97 <strtol+0x40>
		s += 2, base = 16;
  800ac9:	83 c2 02             	add    $0x2,%edx
  800acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad1:	eb c4                	jmp    800a97 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad3:	0f be c0             	movsbl %al,%eax
  800ad6:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800adc:	7d 3a                	jge    800b18 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ade:	83 c2 01             	add    $0x1,%edx
  800ae1:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ae5:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ae7:	0f b6 02             	movzbl (%edx),%eax
  800aea:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 09             	cmp    $0x9,%bl
  800af2:	76 df                	jbe    800ad3 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 70 9f             	lea    -0x61(%eax),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800afe:	0f be c0             	movsbl %al,%eax
  800b01:	83 e8 57             	sub    $0x57,%eax
  800b04:	eb d3                	jmp    800ad9 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b10:	0f be c0             	movsbl %al,%eax
  800b13:	83 e8 37             	sub    $0x37,%eax
  800b16:	eb c1                	jmp    800ad9 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 05                	je     800b23 <strtol+0xcc>
		*endptr = (char *) s;
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b23:	89 c8                	mov    %ecx,%eax
  800b25:	f7 d8                	neg    %eax
  800b27:	85 ff                	test   %edi,%edi
  800b29:	0f 45 c8             	cmovne %eax,%ecx
}
  800b2c:	89 c8                	mov    %ecx,%eax
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	89 c3                	mov    %eax,%ebx
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	89 c6                	mov    %eax,%esi
  800b4a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	89 cb                	mov    %ecx,%ebx
  800b88:	89 cf                	mov    %ecx,%edi
  800b8a:	89 ce                	mov    %ecx,%esi
  800b8c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 03                	push   $0x3
  800ba0:	68 a4 13 80 00       	push   $0x8013a4
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 c1 13 80 00       	push   $0x8013c1
  800bac:	e8 8d f5 ff ff       	call   80013e <_panic>

00800bb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_yield>:

void
sys_yield(void)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be0:	89 d1                	mov    %edx,%ecx
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	89 d7                	mov    %edx,%edi
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf8:	be 00 00 00 00       	mov    $0x0,%esi
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	89 f7                	mov    %esi,%edi
  800c0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7f 08                	jg     800c1b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 04                	push   $0x4
  800c21:	68 a4 13 80 00       	push   $0x8013a4
  800c26:	6a 23                	push   $0x23
  800c28:	68 c1 13 80 00       	push   $0x8013c1
  800c2d:	e8 0c f5 ff ff       	call   80013e <_panic>

00800c32 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7f 08                	jg     800c5d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 05                	push   $0x5
  800c63:	68 a4 13 80 00       	push   $0x8013a4
  800c68:	6a 23                	push   $0x23
  800c6a:	68 c1 13 80 00       	push   $0x8013c1
  800c6f:	e8 ca f4 ff ff       	call   80013e <_panic>

00800c74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7f 08                	jg     800c9f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 06                	push   $0x6
  800ca5:	68 a4 13 80 00       	push   $0x8013a4
  800caa:	6a 23                	push   $0x23
  800cac:	68 c1 13 80 00       	push   $0x8013c1
  800cb1:	e8 88 f4 ff ff       	call   80013e <_panic>

00800cb6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7f 08                	jg     800ce1 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 08                	push   $0x8
  800ce7:	68 a4 13 80 00       	push   $0x8013a4
  800cec:	6a 23                	push   $0x23
  800cee:	68 c1 13 80 00       	push   $0x8013c1
  800cf3:	e8 46 f4 ff ff       	call   80013e <_panic>

00800cf8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	89 df                	mov    %ebx,%edi
  800d13:	89 de                	mov    %ebx,%esi
  800d15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7f 08                	jg     800d23 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 09                	push   $0x9
  800d29:	68 a4 13 80 00       	push   $0x8013a4
  800d2e:	6a 23                	push   $0x23
  800d30:	68 c1 13 80 00       	push   $0x8013c1
  800d35:	e8 04 f4 ff ff       	call   80013e <_panic>

00800d3a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	89 cb                	mov    %ecx,%ebx
  800d75:	89 cf                	mov    %ecx,%edi
  800d77:	89 ce                	mov    %ecx,%esi
  800d79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7f 08                	jg     800d87 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 0c                	push   $0xc
  800d8d:	68 a4 13 80 00       	push   $0x8013a4
  800d92:	6a 23                	push   $0x23
  800d94:	68 c1 13 80 00       	push   $0x8013c1
  800d99:	e8 a0 f3 ff ff       	call   80013e <_panic>

00800d9e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da4:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dab:	74 0a                	je     800db7 <set_pgfault_handler+0x19>
			panic("Failed to set env page fault upcall with error %e\n",r);
		} 
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)) < 0){
  800db7:	a1 04 20 80 00       	mov    0x802004,%eax
  800dbc:	8b 40 48             	mov    0x48(%eax),%eax
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	6a 07                	push   $0x7
  800dc4:	68 00 f0 bf ee       	push   $0xeebff000
  800dc9:	50                   	push   %eax
  800dca:	e8 20 fe ff ff       	call   800bef <sys_page_alloc>
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 2f                	js     800e05 <set_pgfault_handler+0x67>
		if((r=sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall)) < 0 ){
  800dd6:	a1 04 20 80 00       	mov    0x802004,%eax
  800ddb:	8b 40 48             	mov    0x48(%eax),%eax
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	68 17 0e 80 00       	push   $0x800e17
  800de6:	50                   	push   %eax
  800de7:	e8 0c ff ff ff       	call   800cf8 <sys_env_set_pgfault_upcall>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 ba                	jns    800dad <set_pgfault_handler+0xf>
			panic("Failed to set env page fault upcall with error %e\n",r);
  800df3:	50                   	push   %eax
  800df4:	68 00 14 80 00       	push   $0x801400
  800df9:	6a 25                	push   $0x25
  800dfb:	68 33 14 80 00       	push   $0x801433
  800e00:	e8 39 f3 ff ff       	call   80013e <_panic>
			panic("Failed to alloc exception stack with error %e\n",r);
  800e05:	50                   	push   %eax
  800e06:	68 d0 13 80 00       	push   $0x8013d0
  800e0b:	6a 21                	push   $0x21
  800e0d:	68 33 14 80 00       	push   $0x801433
  800e12:	e8 27 f3 ff ff       	call   80013e <_panic>

00800e17 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e17:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e18:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e1d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e1f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  800e22:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp, %ebx
  800e26:	89 e3                	mov    %esp,%ebx
	movl 48(%esp), %esp
  800e28:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800e2c:	50                   	push   %eax
	movl %esp, 48(%esp)
  800e2d:	89 64 24 30          	mov    %esp,0x30(%esp)
	movl %ebx, %esp
  800e31:	89 dc                	mov    %ebx,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e33:	83 c4 08             	add    $0x8,%esp
	popal
  800e36:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e37:	83 c4 04             	add    $0x4,%esp
	popfl
  800e3a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800e3b:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800e3e:	c3                   	ret    
  800e3f:	90                   	nop

00800e40 <__udivdi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	75 19                	jne    800e78 <__udivdi3+0x38>
  800e5f:	39 f3                	cmp    %esi,%ebx
  800e61:	76 4d                	jbe    800eb0 <__udivdi3+0x70>
  800e63:	31 ff                	xor    %edi,%edi
  800e65:	89 e8                	mov    %ebp,%eax
  800e67:	89 f2                	mov    %esi,%edx
  800e69:	f7 f3                	div    %ebx
  800e6b:	89 fa                	mov    %edi,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 f0                	cmp    %esi,%eax
  800e7a:	76 14                	jbe    800e90 <__udivdi3+0x50>
  800e7c:	31 ff                	xor    %edi,%edi
  800e7e:	31 c0                	xor    %eax,%eax
  800e80:	89 fa                	mov    %edi,%edx
  800e82:	83 c4 1c             	add    $0x1c,%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	0f bd f8             	bsr    %eax,%edi
  800e93:	83 f7 1f             	xor    $0x1f,%edi
  800e96:	75 48                	jne    800ee0 <__udivdi3+0xa0>
  800e98:	39 f0                	cmp    %esi,%eax
  800e9a:	72 06                	jb     800ea2 <__udivdi3+0x62>
  800e9c:	31 c0                	xor    %eax,%eax
  800e9e:	39 eb                	cmp    %ebp,%ebx
  800ea0:	77 de                	ja     800e80 <__udivdi3+0x40>
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	eb d7                	jmp    800e80 <__udivdi3+0x40>
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d9                	mov    %ebx,%ecx
  800eb2:	85 db                	test   %ebx,%ebx
  800eb4:	75 0b                	jne    800ec1 <__udivdi3+0x81>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f3                	div    %ebx
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 c6                	mov    %eax,%esi
  800ec9:	89 e8                	mov    %ebp,%eax
  800ecb:	89 f7                	mov    %esi,%edi
  800ecd:	f7 f1                	div    %ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 f9                	mov    %edi,%ecx
  800ee2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ee7:	29 fa                	sub    %edi,%edx
  800ee9:	d3 e0                	shl    %cl,%eax
  800eeb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eef:	89 d1                	mov    %edx,%ecx
  800ef1:	89 d8                	mov    %ebx,%eax
  800ef3:	d3 e8                	shr    %cl,%eax
  800ef5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ef9:	09 c1                	or     %eax,%ecx
  800efb:	89 f0                	mov    %esi,%eax
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 e3                	shl    %cl,%ebx
  800f05:	89 d1                	mov    %edx,%ecx
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f0f:	89 eb                	mov    %ebp,%ebx
  800f11:	d3 e6                	shl    %cl,%esi
  800f13:	89 d1                	mov    %edx,%ecx
  800f15:	d3 eb                	shr    %cl,%ebx
  800f17:	09 f3                	or     %esi,%ebx
  800f19:	89 c6                	mov    %eax,%esi
  800f1b:	89 f2                	mov    %esi,%edx
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	f7 74 24 08          	divl   0x8(%esp)
  800f23:	89 d6                	mov    %edx,%esi
  800f25:	89 c3                	mov    %eax,%ebx
  800f27:	f7 64 24 0c          	mull   0xc(%esp)
  800f2b:	39 d6                	cmp    %edx,%esi
  800f2d:	72 19                	jb     800f48 <__udivdi3+0x108>
  800f2f:	89 f9                	mov    %edi,%ecx
  800f31:	d3 e5                	shl    %cl,%ebp
  800f33:	39 c5                	cmp    %eax,%ebp
  800f35:	73 04                	jae    800f3b <__udivdi3+0xfb>
  800f37:	39 d6                	cmp    %edx,%esi
  800f39:	74 0d                	je     800f48 <__udivdi3+0x108>
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	31 ff                	xor    %edi,%edi
  800f3f:	e9 3c ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f4b:	31 ff                	xor    %edi,%edi
  800f4d:	e9 2e ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	f3 0f 1e fb          	endbr32 
  800f64:	55                   	push   %ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 1c             	sub    $0x1c,%esp
  800f6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800f77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	89 da                	mov    %ebx,%edx
  800f7f:	85 ff                	test   %edi,%edi
  800f81:	75 15                	jne    800f98 <__umoddi3+0x38>
  800f83:	39 dd                	cmp    %ebx,%ebp
  800f85:	76 39                	jbe    800fc0 <__umoddi3+0x60>
  800f87:	f7 f5                	div    %ebp
  800f89:	89 d0                	mov    %edx,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	83 c4 1c             	add    $0x1c,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	39 df                	cmp    %ebx,%edi
  800f9a:	77 f1                	ja     800f8d <__umoddi3+0x2d>
  800f9c:	0f bd cf             	bsr    %edi,%ecx
  800f9f:	83 f1 1f             	xor    $0x1f,%ecx
  800fa2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fa6:	75 40                	jne    800fe8 <__umoddi3+0x88>
  800fa8:	39 df                	cmp    %ebx,%edi
  800faa:	72 04                	jb     800fb0 <__umoddi3+0x50>
  800fac:	39 f5                	cmp    %esi,%ebp
  800fae:	77 dd                	ja     800f8d <__umoddi3+0x2d>
  800fb0:	89 da                	mov    %ebx,%edx
  800fb2:	89 f0                	mov    %esi,%eax
  800fb4:	29 e8                	sub    %ebp,%eax
  800fb6:	19 fa                	sbb    %edi,%edx
  800fb8:	eb d3                	jmp    800f8d <__umoddi3+0x2d>
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	89 e9                	mov    %ebp,%ecx
  800fc2:	85 ed                	test   %ebp,%ebp
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x71>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f5                	div    %ebp
  800fcf:	89 c1                	mov    %eax,%ecx
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f1                	div    %ecx
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	f7 f1                	div    %ecx
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	eb ac                	jmp    800f8d <__umoddi3+0x2d>
  800fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fec:	ba 20 00 00 00       	mov    $0x20,%edx
  800ff1:	29 c2                	sub    %eax,%edx
  800ff3:	89 c1                	mov    %eax,%ecx
  800ff5:	89 e8                	mov    %ebp,%eax
  800ff7:	d3 e7                	shl    %cl,%edi
  800ff9:	89 d1                	mov    %edx,%ecx
  800ffb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fff:	d3 e8                	shr    %cl,%eax
  801001:	89 c1                	mov    %eax,%ecx
  801003:	8b 44 24 04          	mov    0x4(%esp),%eax
  801007:	09 f9                	or     %edi,%ecx
  801009:	89 df                	mov    %ebx,%edi
  80100b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80100f:	89 c1                	mov    %eax,%ecx
  801011:	d3 e5                	shl    %cl,%ebp
  801013:	89 d1                	mov    %edx,%ecx
  801015:	d3 ef                	shr    %cl,%edi
  801017:	89 c1                	mov    %eax,%ecx
  801019:	89 f0                	mov    %esi,%eax
  80101b:	d3 e3                	shl    %cl,%ebx
  80101d:	89 d1                	mov    %edx,%ecx
  80101f:	89 fa                	mov    %edi,%edx
  801021:	d3 e8                	shr    %cl,%eax
  801023:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801028:	09 d8                	or     %ebx,%eax
  80102a:	f7 74 24 08          	divl   0x8(%esp)
  80102e:	89 d3                	mov    %edx,%ebx
  801030:	d3 e6                	shl    %cl,%esi
  801032:	f7 e5                	mul    %ebp
  801034:	89 c7                	mov    %eax,%edi
  801036:	89 d1                	mov    %edx,%ecx
  801038:	39 d3                	cmp    %edx,%ebx
  80103a:	72 06                	jb     801042 <__umoddi3+0xe2>
  80103c:	75 0e                	jne    80104c <__umoddi3+0xec>
  80103e:	39 c6                	cmp    %eax,%esi
  801040:	73 0a                	jae    80104c <__umoddi3+0xec>
  801042:	29 e8                	sub    %ebp,%eax
  801044:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801048:	89 d1                	mov    %edx,%ecx
  80104a:	89 c7                	mov    %eax,%edi
  80104c:	89 f5                	mov    %esi,%ebp
  80104e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801052:	29 fd                	sub    %edi,%ebp
  801054:	19 cb                	sbb    %ecx,%ebx
  801056:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	d3 e0                	shl    %cl,%eax
  80105f:	89 f1                	mov    %esi,%ecx
  801061:	d3 ed                	shr    %cl,%ebp
  801063:	d3 eb                	shr    %cl,%ebx
  801065:	09 e8                	or     %ebp,%eax
  801067:	89 da                	mov    %ebx,%edx
  801069:	83 c4 1c             	add    $0x1c,%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    
