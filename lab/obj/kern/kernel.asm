
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 98 08 ff ff    	lea    -0xf768(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 de 0a 00 00       	call   f0100b41 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 22 08 00 00       	call   f010089a <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 b4 08 ff ff    	lea    -0xf74c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 b6 0a 00 00       	call   f0100b41 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 81 16 00 00       	call   f0101750 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 cf 08 ff ff    	lea    -0xf731(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 59 0a 00 00       	call   f0100b41 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 88 08 00 00       	call   f0100989 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 57 08 00 00       	call   f0100989 <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ea 08 ff ff    	lea    -0xf716(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 ee 09 00 00       	call   f0100b41 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 ad 09 00 00       	call   f0100b0a <vcprintf>
	cprintf("\n");
f010015d:	8d 83 26 09 ff ff    	lea    -0xf6da(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 d6 09 00 00       	call   f0100b41 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 02 09 ff ff    	lea    -0xf6fe(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 a9 09 00 00       	call   f0100b41 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 66 09 00 00       	call   f0100b0a <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 26 09 ff ff    	lea    -0xf6da(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 8f 09 00 00       	call   f0100b41 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 58 09 ff 	movzbl -0xf6a8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 1c 09 ff ff    	lea    -0xf6e4(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 5e 08 00 00       	call   f0100b41 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 59 12 00 00       	call   f010179d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 28 09 ff ff    	lea    -0xf6d8(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 13 04 00 00       	call   f0100b41 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 58 0b ff ff    	lea    -0xf4a8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 7b 0b ff ff    	lea    -0xf485(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 b2 03 00 00       	call   f0100b41 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 14 0c ff ff    	lea    -0xf3ec(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 9b 03 00 00       	call   f0100b41 <cprintf>
f01007a6:	83 c4 0c             	add    $0xc,%esp
f01007a9:	8d 83 3c 0c ff ff    	lea    -0xf3c4(%ebx),%eax
f01007af:	50                   	push   %eax
f01007b0:	8d 83 8d 0b ff ff    	lea    -0xf473(%ebx),%eax
f01007b6:	50                   	push   %eax
f01007b7:	56                   	push   %esi
f01007b8:	e8 84 03 00 00       	call   f0100b41 <cprintf>
	return 0;
}
f01007bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c5:	5b                   	pop    %ebx
f01007c6:	5e                   	pop    %esi
f01007c7:	5d                   	pop    %ebp
f01007c8:	c3                   	ret    

f01007c9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	57                   	push   %edi
f01007cd:	56                   	push   %esi
f01007ce:	53                   	push   %ebx
f01007cf:	83 ec 18             	sub    $0x18,%esp
f01007d2:	e8 e5 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d7:	81 c3 31 0b 01 00    	add    $0x10b31,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007dd:	8d 83 97 0b ff ff    	lea    -0xf469(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 58 03 00 00       	call   f0100b41 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007f2:	8d 83 70 0c ff ff    	lea    -0xf390(%ebx),%eax
f01007f8:	50                   	push   %eax
f01007f9:	e8 43 03 00 00       	call   f0100b41 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007fe:	83 c4 0c             	add    $0xc,%esp
f0100801:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100807:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010080d:	50                   	push   %eax
f010080e:	57                   	push   %edi
f010080f:	8d 83 98 0c ff ff    	lea    -0xf368(%ebx),%eax
f0100815:	50                   	push   %eax
f0100816:	e8 26 03 00 00       	call   f0100b41 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081b:	83 c4 0c             	add    $0xc,%esp
f010081e:	c7 c0 89 1b 10 f0    	mov    $0xf0101b89,%eax
f0100824:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082a:	52                   	push   %edx
f010082b:	50                   	push   %eax
f010082c:	8d 83 bc 0c ff ff    	lea    -0xf344(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 09 03 00 00       	call   f0100b41 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100841:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100847:	52                   	push   %edx
f0100848:	50                   	push   %eax
f0100849:	8d 83 e0 0c ff ff    	lea    -0xf320(%ebx),%eax
f010084f:	50                   	push   %eax
f0100850:	e8 ec 02 00 00       	call   f0100b41 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010085e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100864:	50                   	push   %eax
f0100865:	56                   	push   %esi
f0100866:	8d 83 04 0d ff ff    	lea    -0xf2fc(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 cf 02 00 00       	call   f0100b41 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100872:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100875:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010087b:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087d:	c1 fe 0a             	sar    $0xa,%esi
f0100880:	56                   	push   %esi
f0100881:	8d 83 28 0d ff ff    	lea    -0xf2d8(%ebx),%eax
f0100887:	50                   	push   %eax
f0100888:	e8 b4 02 00 00       	call   f0100b41 <cprintf>
	return 0;
}
f010088d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100892:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100895:	5b                   	pop    %ebx
f0100896:	5e                   	pop    %esi
f0100897:	5f                   	pop    %edi
f0100898:	5d                   	pop    %ebp
f0100899:	c3                   	ret    

f010089a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	57                   	push   %edi
f010089e:	56                   	push   %esi
f010089f:	53                   	push   %ebx
f01008a0:	83 ec 44             	sub    $0x44,%esp
f01008a3:	e8 14 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a8:	81 c3 60 0a 01 00    	add    $0x10a60,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 e8                	mov    %ebp,%eax
    uint32_t *ebp = (uint32_t *) read_ebp();
f01008b0:	89 c7                	mov    %eax,%edi
	cprintf("%x\n", (int) ebp);
f01008b2:	50                   	push   %eax
f01008b3:	8d 83 b0 0b ff ff    	lea    -0xf450(%ebx),%eax
f01008b9:	50                   	push   %eax
f01008ba:	e8 82 02 00 00       	call   f0100b41 <cprintf>
	cprintf("Stack backtrace:\n");
f01008bf:	8d 83 b4 0b ff ff    	lea    -0xf44c(%ebx),%eax
f01008c5:	89 04 24             	mov    %eax,(%esp)
f01008c8:	e8 74 02 00 00       	call   f0100b41 <cprintf>
f01008cd:	83 c4 10             	add    $0x10,%esp
	do {
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f01008d0:	8d 83 54 0d ff ff    	lea    -0xf2ac(%ebx),%eax
f01008d6:	89 45 c0             	mov    %eax,-0x40(%ebp)
		
		uintptr_t eip = (uintptr_t) *(ebp + 1);
		struct Eipdebuginfo info;
		// if failed, return negative number, but some fields in info may be filled
		// ebp + 1 points to eip's cell
		debuginfo_eip(eip, &info);
f01008d9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008dc:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01008df:	eb 45                	jmp    f0100926 <mon_backtrace+0x8c>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
		for (int i = 0; i < info.eip_fn_namelen; i++) {
			cputchar(info.eip_fn_name[i]);
f01008e1:	83 ec 0c             	sub    $0xc,%esp
f01008e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008e7:	0f be 04 30          	movsbl (%eax,%esi,1),%eax
f01008eb:	50                   	push   %eax
f01008ec:	e8 42 fe ff ff       	call   f0100733 <cputchar>
		for (int i = 0; i < info.eip_fn_namelen; i++) {
f01008f1:	83 c6 01             	add    $0x1,%esi
f01008f4:	83 c4 10             	add    $0x10,%esp
f01008f7:	39 75 dc             	cmp    %esi,-0x24(%ebp)
f01008fa:	7f e5                	jg     f01008e1 <mon_backtrace+0x47>
		}
		cputchar('+');
f01008fc:	83 ec 0c             	sub    $0xc,%esp
f01008ff:	6a 2b                	push   $0x2b
f0100901:	e8 2d fe ff ff       	call   f0100733 <cputchar>
		cprintf("%d\n", eip - info.eip_fn_addr);
f0100906:	83 c4 08             	add    $0x8,%esp
f0100909:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010090c:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010090f:	50                   	push   %eax
f0100910:	8d 83 b0 08 ff ff    	lea    -0xf750(%ebx),%eax
f0100916:	50                   	push   %eax
f0100917:	e8 25 02 00 00       	call   f0100b41 <cprintf>

		ebp = (uint32_t *) *ebp;
f010091c:	8b 3f                	mov    (%edi),%edi
	} while (*ebp != 0);
f010091e:	83 c4 10             	add    $0x10,%esp
f0100921:	83 3f 00             	cmpl   $0x0,(%edi)
f0100924:	74 56                	je     f010097c <mon_backtrace+0xe2>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f0100926:	83 ec 0c             	sub    $0xc,%esp
f0100929:	ff 77 1c             	pushl  0x1c(%edi)
f010092c:	ff 77 18             	pushl  0x18(%edi)
f010092f:	ff 77 14             	pushl  0x14(%edi)
f0100932:	ff 77 10             	pushl  0x10(%edi)
f0100935:	ff 77 0c             	pushl  0xc(%edi)
f0100938:	ff 77 08             	pushl  0x8(%edi)
f010093b:	ff 77 04             	pushl  0x4(%edi)
f010093e:	ff 37                	pushl  (%edi)
f0100940:	ff 75 c0             	pushl  -0x40(%ebp)
f0100943:	e8 f9 01 00 00       	call   f0100b41 <cprintf>
		uintptr_t eip = (uintptr_t) *(ebp + 1);
f0100948:	8b 47 04             	mov    0x4(%edi),%eax
f010094b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		debuginfo_eip(eip, &info);
f010094e:	83 c4 28             	add    $0x28,%esp
f0100951:	ff 75 bc             	pushl  -0x44(%ebp)
f0100954:	50                   	push   %eax
f0100955:	e8 eb 02 00 00       	call   f0100c45 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f010095a:	83 c4 0c             	add    $0xc,%esp
f010095d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100960:	ff 75 d0             	pushl  -0x30(%ebp)
f0100963:	8d 83 c6 0b ff ff    	lea    -0xf43a(%ebx),%eax
f0100969:	50                   	push   %eax
f010096a:	e8 d2 01 00 00       	call   f0100b41 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++) {
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	be 00 00 00 00       	mov    $0x0,%esi
f0100977:	e9 7b ff ff ff       	jmp    f01008f7 <mon_backtrace+0x5d>
	
	return 0;
}
f010097c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100981:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100984:	5b                   	pop    %ebx
f0100985:	5e                   	pop    %esi
f0100986:	5f                   	pop    %edi
f0100987:	5d                   	pop    %ebp
f0100988:	c3                   	ret    

f0100989 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100989:	55                   	push   %ebp
f010098a:	89 e5                	mov    %esp,%ebp
f010098c:	57                   	push   %edi
f010098d:	56                   	push   %esi
f010098e:	53                   	push   %ebx
f010098f:	83 ec 68             	sub    $0x68,%esp
f0100992:	e8 25 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100997:	81 c3 71 09 01 00    	add    $0x10971,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010099d:	8d 83 8c 0d ff ff    	lea    -0xf274(%ebx),%eax
f01009a3:	50                   	push   %eax
f01009a4:	e8 98 01 00 00       	call   f0100b41 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009a9:	8d 83 b0 0d ff ff    	lea    -0xf250(%ebx),%eax
f01009af:	89 04 24             	mov    %eax,(%esp)
f01009b2:	e8 8a 01 00 00       	call   f0100b41 <cprintf>
f01009b7:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009ba:	8d bb db 0b ff ff    	lea    -0xf425(%ebx),%edi
f01009c0:	eb 4a                	jmp    f0100a0c <monitor+0x83>
f01009c2:	83 ec 08             	sub    $0x8,%esp
f01009c5:	0f be c0             	movsbl %al,%eax
f01009c8:	50                   	push   %eax
f01009c9:	57                   	push   %edi
f01009ca:	e8 44 0d 00 00       	call   f0101713 <strchr>
f01009cf:	83 c4 10             	add    $0x10,%esp
f01009d2:	85 c0                	test   %eax,%eax
f01009d4:	74 08                	je     f01009de <monitor+0x55>
			*buf++ = 0;
f01009d6:	c6 06 00             	movb   $0x0,(%esi)
f01009d9:	8d 76 01             	lea    0x1(%esi),%esi
f01009dc:	eb 79                	jmp    f0100a57 <monitor+0xce>
		if (*buf == 0)
f01009de:	80 3e 00             	cmpb   $0x0,(%esi)
f01009e1:	74 7f                	je     f0100a62 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01009e3:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009e7:	74 0f                	je     f01009f8 <monitor+0x6f>
		argv[argc++] = buf;
f01009e9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009ec:	8d 48 01             	lea    0x1(%eax),%ecx
f01009ef:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009f2:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009f6:	eb 44                	jmp    f0100a3c <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009f8:	83 ec 08             	sub    $0x8,%esp
f01009fb:	6a 10                	push   $0x10
f01009fd:	8d 83 e0 0b ff ff    	lea    -0xf420(%ebx),%eax
f0100a03:	50                   	push   %eax
f0100a04:	e8 38 01 00 00       	call   f0100b41 <cprintf>
f0100a09:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a0c:	8d 83 d7 0b ff ff    	lea    -0xf429(%ebx),%eax
f0100a12:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a15:	83 ec 0c             	sub    $0xc,%esp
f0100a18:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a1b:	e8 bb 0a 00 00       	call   f01014db <readline>
f0100a20:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a22:	83 c4 10             	add    $0x10,%esp
f0100a25:	85 c0                	test   %eax,%eax
f0100a27:	74 ec                	je     f0100a15 <monitor+0x8c>
	argv[argc] = 0;
f0100a29:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a30:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a37:	eb 1e                	jmp    f0100a57 <monitor+0xce>
			buf++;
f0100a39:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a3c:	0f b6 06             	movzbl (%esi),%eax
f0100a3f:	84 c0                	test   %al,%al
f0100a41:	74 14                	je     f0100a57 <monitor+0xce>
f0100a43:	83 ec 08             	sub    $0x8,%esp
f0100a46:	0f be c0             	movsbl %al,%eax
f0100a49:	50                   	push   %eax
f0100a4a:	57                   	push   %edi
f0100a4b:	e8 c3 0c 00 00       	call   f0101713 <strchr>
f0100a50:	83 c4 10             	add    $0x10,%esp
f0100a53:	85 c0                	test   %eax,%eax
f0100a55:	74 e2                	je     f0100a39 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a57:	0f b6 06             	movzbl (%esi),%eax
f0100a5a:	84 c0                	test   %al,%al
f0100a5c:	0f 85 60 ff ff ff    	jne    f01009c2 <monitor+0x39>
	argv[argc] = 0;
f0100a62:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a65:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a6c:	00 
	if (argc == 0)
f0100a6d:	85 c0                	test   %eax,%eax
f0100a6f:	74 9b                	je     f0100a0c <monitor+0x83>
f0100a71:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a77:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a7e:	83 ec 08             	sub    $0x8,%esp
f0100a81:	ff 36                	pushl  (%esi)
f0100a83:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a86:	e8 2a 0c 00 00       	call   f01016b5 <strcmp>
f0100a8b:	83 c4 10             	add    $0x10,%esp
f0100a8e:	85 c0                	test   %eax,%eax
f0100a90:	74 29                	je     f0100abb <monitor+0x132>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a92:	83 45 a0 01          	addl   $0x1,-0x60(%ebp)
f0100a96:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100a99:	83 c6 0c             	add    $0xc,%esi
f0100a9c:	83 f8 03             	cmp    $0x3,%eax
f0100a9f:	75 dd                	jne    f0100a7e <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aa1:	83 ec 08             	sub    $0x8,%esp
f0100aa4:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa7:	8d 83 fd 0b ff ff    	lea    -0xf403(%ebx),%eax
f0100aad:	50                   	push   %eax
f0100aae:	e8 8e 00 00 00       	call   f0100b41 <cprintf>
f0100ab3:	83 c4 10             	add    $0x10,%esp
f0100ab6:	e9 51 ff ff ff       	jmp    f0100a0c <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100abb:	83 ec 04             	sub    $0x4,%esp
f0100abe:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0100ac1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ac4:	ff 75 08             	pushl  0x8(%ebp)
f0100ac7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aca:	52                   	push   %edx
f0100acb:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100ace:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ad5:	83 c4 10             	add    $0x10,%esp
f0100ad8:	85 c0                	test   %eax,%eax
f0100ada:	0f 89 2c ff ff ff    	jns    f0100a0c <monitor+0x83>
				break;
	}
}
f0100ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae3:	5b                   	pop    %ebx
f0100ae4:	5e                   	pop    %esi
f0100ae5:	5f                   	pop    %edi
f0100ae6:	5d                   	pop    %ebp
f0100ae7:	c3                   	ret    

f0100ae8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ae8:	55                   	push   %ebp
f0100ae9:	89 e5                	mov    %esp,%ebp
f0100aeb:	53                   	push   %ebx
f0100aec:	83 ec 10             	sub    $0x10,%esp
f0100aef:	e8 c8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100af4:	81 c3 14 08 01 00    	add    $0x10814,%ebx
	cputchar(ch);
f0100afa:	ff 75 08             	pushl  0x8(%ebp)
f0100afd:	e8 31 fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100b02:	83 c4 10             	add    $0x10,%esp
f0100b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b08:	c9                   	leave  
f0100b09:	c3                   	ret    

f0100b0a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b0a:	55                   	push   %ebp
f0100b0b:	89 e5                	mov    %esp,%ebp
f0100b0d:	53                   	push   %ebx
f0100b0e:	83 ec 14             	sub    $0x14,%esp
f0100b11:	e8 a6 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b16:	81 c3 f2 07 01 00    	add    $0x107f2,%ebx
	int cnt = 0;
f0100b1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b23:	ff 75 0c             	pushl  0xc(%ebp)
f0100b26:	ff 75 08             	pushl  0x8(%ebp)
f0100b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b2c:	50                   	push   %eax
f0100b2d:	8d 83 e0 f7 fe ff    	lea    -0x10820(%ebx),%eax
f0100b33:	50                   	push   %eax
f0100b34:	e8 92 04 00 00       	call   f0100fcb <vprintfmt>
	return cnt;
}
f0100b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b3f:	c9                   	leave  
f0100b40:	c3                   	ret    

f0100b41 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b41:	55                   	push   %ebp
f0100b42:	89 e5                	mov    %esp,%ebp
f0100b44:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b4a:	50                   	push   %eax
f0100b4b:	ff 75 08             	pushl  0x8(%ebp)
f0100b4e:	e8 b7 ff ff ff       	call   f0100b0a <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b53:	c9                   	leave  
f0100b54:	c3                   	ret    

f0100b55 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b55:	55                   	push   %ebp
f0100b56:	89 e5                	mov    %esp,%ebp
f0100b58:	57                   	push   %edi
f0100b59:	56                   	push   %esi
f0100b5a:	53                   	push   %ebx
f0100b5b:	83 ec 14             	sub    $0x14,%esp
f0100b5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b64:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b6a:	8b 32                	mov    (%edx),%esi
f0100b6c:	8b 01                	mov    (%ecx),%eax
f0100b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b71:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b78:	eb 2f                	jmp    f0100ba9 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b7a:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b7d:	39 c6                	cmp    %eax,%esi
f0100b7f:	7f 49                	jg     f0100bca <stab_binsearch+0x75>
f0100b81:	0f b6 0a             	movzbl (%edx),%ecx
f0100b84:	83 ea 0c             	sub    $0xc,%edx
f0100b87:	39 f9                	cmp    %edi,%ecx
f0100b89:	75 ef                	jne    f0100b7a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b8b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b8e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b91:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b95:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b98:	73 35                	jae    f0100bcf <stab_binsearch+0x7a>
			*region_left = m;
f0100b9a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b9d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b9f:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100ba2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100ba9:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100bac:	7f 4e                	jg     f0100bfc <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bb1:	01 f0                	add    %esi,%eax
f0100bb3:	89 c3                	mov    %eax,%ebx
f0100bb5:	c1 eb 1f             	shr    $0x1f,%ebx
f0100bb8:	01 c3                	add    %eax,%ebx
f0100bba:	d1 fb                	sar    %ebx
f0100bbc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bbf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bc2:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100bc6:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bc8:	eb b3                	jmp    f0100b7d <stab_binsearch+0x28>
			l = true_m + 1;
f0100bca:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100bcd:	eb da                	jmp    f0100ba9 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bcf:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bd2:	76 14                	jbe    f0100be8 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100bd4:	83 e8 01             	sub    $0x1,%eax
f0100bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bda:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bdd:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100bdf:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100be6:	eb c1                	jmp    f0100ba9 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100be8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100beb:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bf1:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bf3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bfa:	eb ad                	jmp    f0100ba9 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bfc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c00:	74 16                	je     f0100c18 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c05:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c07:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c0a:	8b 0e                	mov    (%esi),%ecx
f0100c0c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c0f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100c12:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100c16:	eb 12                	jmp    f0100c2a <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c1b:	8b 00                	mov    (%eax),%eax
f0100c1d:	83 e8 01             	sub    $0x1,%eax
f0100c20:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c23:	89 07                	mov    %eax,(%edi)
f0100c25:	eb 16                	jmp    f0100c3d <stab_binsearch+0xe8>
		     l--)
f0100c27:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c2a:	39 c1                	cmp    %eax,%ecx
f0100c2c:	7d 0a                	jge    f0100c38 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100c2e:	0f b6 1a             	movzbl (%edx),%ebx
f0100c31:	83 ea 0c             	sub    $0xc,%edx
f0100c34:	39 fb                	cmp    %edi,%ebx
f0100c36:	75 ef                	jne    f0100c27 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100c38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c3b:	89 07                	mov    %eax,(%edi)
	}
}
f0100c3d:	83 c4 14             	add    $0x14,%esp
f0100c40:	5b                   	pop    %ebx
f0100c41:	5e                   	pop    %esi
f0100c42:	5f                   	pop    %edi
f0100c43:	5d                   	pop    %ebp
f0100c44:	c3                   	ret    

f0100c45 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c45:	55                   	push   %ebp
f0100c46:	89 e5                	mov    %esp,%ebp
f0100c48:	57                   	push   %edi
f0100c49:	56                   	push   %esi
f0100c4a:	53                   	push   %ebx
f0100c4b:	83 ec 3c             	sub    $0x3c,%esp
f0100c4e:	e8 69 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c53:	81 c3 b5 06 01 00    	add    $0x106b5,%ebx
f0100c59:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c5f:	8d 83 d8 0d ff ff    	lea    -0xf228(%ebx),%eax
f0100c65:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c67:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c6e:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c71:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c78:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c7b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c82:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c88:	0f 86 31 01 00 00    	jbe    f0100dbf <debuginfo_eip+0x17a>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c8e:	c7 c0 b9 60 10 f0    	mov    $0xf01060b9,%eax
f0100c94:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c9a:	0f 86 fe 01 00 00    	jbe    f0100e9e <debuginfo_eip+0x259>
f0100ca0:	c7 c0 36 7a 10 f0    	mov    $0xf0107a36,%eax
f0100ca6:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100caa:	0f 85 f5 01 00 00    	jne    f0100ea5 <debuginfo_eip+0x260>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100cb0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cb7:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100cbd:	c7 c2 b8 60 10 f0    	mov    $0xf01060b8,%edx
f0100cc3:	29 c2                	sub    %eax,%edx
f0100cc5:	c1 fa 02             	sar    $0x2,%edx
f0100cc8:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cce:	83 ea 01             	sub    $0x1,%edx
f0100cd1:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cd4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cd7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cda:	83 ec 08             	sub    $0x8,%esp
f0100cdd:	57                   	push   %edi
f0100cde:	6a 64                	push   $0x64
f0100ce0:	e8 70 fe ff ff       	call   f0100b55 <stab_binsearch>
	if (lfile == 0)
f0100ce5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ce8:	83 c4 10             	add    $0x10,%esp
f0100ceb:	85 c0                	test   %eax,%eax
f0100ced:	0f 84 b9 01 00 00    	je     f0100eac <debuginfo_eip+0x267>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cf3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cf9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cfc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cff:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d02:	83 ec 08             	sub    $0x8,%esp
f0100d05:	57                   	push   %edi
f0100d06:	6a 24                	push   $0x24
f0100d08:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100d0e:	e8 42 fe ff ff       	call   f0100b55 <stab_binsearch>

	if (lfun <= rfun) {
f0100d13:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d16:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d19:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100d1c:	83 c4 10             	add    $0x10,%esp
f0100d1f:	39 c8                	cmp    %ecx,%eax
f0100d21:	0f 8f b0 00 00 00    	jg     f0100dd7 <debuginfo_eip+0x192>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d27:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d2a:	c7 c1 fc 22 10 f0    	mov    $0xf01022fc,%ecx
f0100d30:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d33:	8b 11                	mov    (%ecx),%edx
f0100d35:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d38:	c7 c2 36 7a 10 f0    	mov    $0xf0107a36,%edx
f0100d3e:	81 ea b9 60 10 f0    	sub    $0xf01060b9,%edx
f0100d44:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d47:	73 0c                	jae    f0100d55 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d49:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d4c:	81 c2 b9 60 10 f0    	add    $0xf01060b9,%edx
f0100d52:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d55:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d58:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d5b:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d5d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d60:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d63:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d66:	83 ec 08             	sub    $0x8,%esp
f0100d69:	6a 3a                	push   $0x3a
f0100d6b:	ff 76 08             	pushl  0x8(%esi)
f0100d6e:	e8 c1 09 00 00       	call   f0101734 <strfind>
f0100d73:	2b 46 08             	sub    0x8(%esi),%eax
f0100d76:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d79:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d7c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d7f:	83 c4 08             	add    $0x8,%esp
f0100d82:	57                   	push   %edi
f0100d83:	6a 44                	push   $0x44
f0100d85:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100d8b:	e8 c5 fd ff ff       	call   f0100b55 <stab_binsearch>
	if  (lline <= rline) {
f0100d90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d93:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d96:	83 c4 10             	add    $0x10,%esp
f0100d99:	39 c2                	cmp    %eax,%edx
f0100d9b:	0f 8f 12 01 00 00    	jg     f0100eb3 <debuginfo_eip+0x26e>
		info->eip_line = rline;
f0100da1:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100da4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100da7:	89 d0                	mov    %edx,%eax
f0100da9:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100dac:	c7 c2 fc 22 10 f0    	mov    $0xf01022fc,%edx
f0100db2:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100db6:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100dba:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100dbd:	eb 36                	jmp    f0100df5 <debuginfo_eip+0x1b0>
  	        panic("User address");
f0100dbf:	83 ec 04             	sub    $0x4,%esp
f0100dc2:	8d 83 e2 0d ff ff    	lea    -0xf21e(%ebx),%eax
f0100dc8:	50                   	push   %eax
f0100dc9:	6a 7f                	push   $0x7f
f0100dcb:	8d 83 ef 0d ff ff    	lea    -0xf211(%ebx),%eax
f0100dd1:	50                   	push   %eax
f0100dd2:	e8 2f f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100dd7:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ddd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100de3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100de6:	e9 7b ff ff ff       	jmp    f0100d66 <debuginfo_eip+0x121>
f0100deb:	83 e8 01             	sub    $0x1,%eax
f0100dee:	83 ea 0c             	sub    $0xc,%edx
f0100df1:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100df5:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100df8:	39 c7                	cmp    %eax,%edi
f0100dfa:	7f 24                	jg     f0100e20 <debuginfo_eip+0x1db>
	       && stabs[lline].n_type != N_SOL
f0100dfc:	0f b6 0a             	movzbl (%edx),%ecx
f0100dff:	80 f9 84             	cmp    $0x84,%cl
f0100e02:	74 46                	je     f0100e4a <debuginfo_eip+0x205>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e04:	80 f9 64             	cmp    $0x64,%cl
f0100e07:	75 e2                	jne    f0100deb <debuginfo_eip+0x1a6>
f0100e09:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100e0d:	74 dc                	je     f0100deb <debuginfo_eip+0x1a6>
f0100e0f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e12:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e16:	74 3b                	je     f0100e53 <debuginfo_eip+0x20e>
f0100e18:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e1b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e1e:	eb 33                	jmp    f0100e53 <debuginfo_eip+0x20e>
f0100e20:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e26:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e29:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e2e:	39 fa                	cmp    %edi,%edx
f0100e30:	0f 8d 89 00 00 00    	jge    f0100ebf <debuginfo_eip+0x27a>
		for (lline = lfun + 1;
f0100e36:	83 c2 01             	add    $0x1,%edx
f0100e39:	89 d0                	mov    %edx,%eax
f0100e3b:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e3e:	c7 c2 fc 22 10 f0    	mov    $0xf01022fc,%edx
f0100e44:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e48:	eb 3b                	jmp    f0100e85 <debuginfo_eip+0x240>
f0100e4a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e4d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e51:	75 26                	jne    f0100e79 <debuginfo_eip+0x234>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e53:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e56:	c7 c0 fc 22 10 f0    	mov    $0xf01022fc,%eax
f0100e5c:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e5f:	c7 c0 36 7a 10 f0    	mov    $0xf0107a36,%eax
f0100e65:	81 e8 b9 60 10 f0    	sub    $0xf01060b9,%eax
f0100e6b:	39 c2                	cmp    %eax,%edx
f0100e6d:	73 b4                	jae    f0100e23 <debuginfo_eip+0x1de>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e6f:	81 c2 b9 60 10 f0    	add    $0xf01060b9,%edx
f0100e75:	89 16                	mov    %edx,(%esi)
f0100e77:	eb aa                	jmp    f0100e23 <debuginfo_eip+0x1de>
f0100e79:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e7c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e7f:	eb d2                	jmp    f0100e53 <debuginfo_eip+0x20e>
			info->eip_fn_narg++;
f0100e81:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e85:	39 c7                	cmp    %eax,%edi
f0100e87:	7e 31                	jle    f0100eba <debuginfo_eip+0x275>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e89:	0f b6 0a             	movzbl (%edx),%ecx
f0100e8c:	83 c0 01             	add    $0x1,%eax
f0100e8f:	83 c2 0c             	add    $0xc,%edx
f0100e92:	80 f9 a0             	cmp    $0xa0,%cl
f0100e95:	74 ea                	je     f0100e81 <debuginfo_eip+0x23c>
	return 0;
f0100e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9c:	eb 21                	jmp    f0100ebf <debuginfo_eip+0x27a>
		return -1;
f0100e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ea3:	eb 1a                	jmp    f0100ebf <debuginfo_eip+0x27a>
f0100ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eaa:	eb 13                	jmp    f0100ebf <debuginfo_eip+0x27a>
		return -1;
f0100eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eb1:	eb 0c                	jmp    f0100ebf <debuginfo_eip+0x27a>
		return -1;
f0100eb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eb8:	eb 05                	jmp    f0100ebf <debuginfo_eip+0x27a>
	return 0;
f0100eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec2:	5b                   	pop    %ebx
f0100ec3:	5e                   	pop    %esi
f0100ec4:	5f                   	pop    %edi
f0100ec5:	5d                   	pop    %ebp
f0100ec6:	c3                   	ret    

f0100ec7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ec7:	55                   	push   %ebp
f0100ec8:	89 e5                	mov    %esp,%ebp
f0100eca:	57                   	push   %edi
f0100ecb:	56                   	push   %esi
f0100ecc:	53                   	push   %ebx
f0100ecd:	83 ec 2c             	sub    $0x2c,%esp
f0100ed0:	e8 02 06 00 00       	call   f01014d7 <__x86.get_pc_thunk.cx>
f0100ed5:	81 c1 33 04 01 00    	add    $0x10433,%ecx
f0100edb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ede:	89 c7                	mov    %eax,%edi
f0100ee0:	89 d6                	mov    %edx,%esi
f0100ee2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ee8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100eeb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100eee:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ef6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ef9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100efc:	39 d3                	cmp    %edx,%ebx
f0100efe:	72 09                	jb     f0100f09 <printnum+0x42>
f0100f00:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100f03:	0f 87 83 00 00 00    	ja     f0100f8c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f09:	83 ec 0c             	sub    $0xc,%esp
f0100f0c:	ff 75 18             	pushl  0x18(%ebp)
f0100f0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f12:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100f15:	53                   	push   %ebx
f0100f16:	ff 75 10             	pushl  0x10(%ebp)
f0100f19:	83 ec 08             	sub    $0x8,%esp
f0100f1c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f1f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f22:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f25:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f28:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f2b:	e8 20 0a 00 00       	call   f0101950 <__udivdi3>
f0100f30:	83 c4 18             	add    $0x18,%esp
f0100f33:	52                   	push   %edx
f0100f34:	50                   	push   %eax
f0100f35:	89 f2                	mov    %esi,%edx
f0100f37:	89 f8                	mov    %edi,%eax
f0100f39:	e8 89 ff ff ff       	call   f0100ec7 <printnum>
f0100f3e:	83 c4 20             	add    $0x20,%esp
f0100f41:	eb 13                	jmp    f0100f56 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f43:	83 ec 08             	sub    $0x8,%esp
f0100f46:	56                   	push   %esi
f0100f47:	ff 75 18             	pushl  0x18(%ebp)
f0100f4a:	ff d7                	call   *%edi
f0100f4c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f4f:	83 eb 01             	sub    $0x1,%ebx
f0100f52:	85 db                	test   %ebx,%ebx
f0100f54:	7f ed                	jg     f0100f43 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f56:	83 ec 08             	sub    $0x8,%esp
f0100f59:	56                   	push   %esi
f0100f5a:	83 ec 04             	sub    $0x4,%esp
f0100f5d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f60:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f63:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f66:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f69:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f6c:	89 f3                	mov    %esi,%ebx
f0100f6e:	e8 fd 0a 00 00       	call   f0101a70 <__umoddi3>
f0100f73:	83 c4 14             	add    $0x14,%esp
f0100f76:	0f be 84 06 fd 0d ff 	movsbl -0xf203(%esi,%eax,1),%eax
f0100f7d:	ff 
f0100f7e:	50                   	push   %eax
f0100f7f:	ff d7                	call   *%edi
}
f0100f81:	83 c4 10             	add    $0x10,%esp
f0100f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f87:	5b                   	pop    %ebx
f0100f88:	5e                   	pop    %esi
f0100f89:	5f                   	pop    %edi
f0100f8a:	5d                   	pop    %ebp
f0100f8b:	c3                   	ret    
f0100f8c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f8f:	eb be                	jmp    f0100f4f <printnum+0x88>

f0100f91 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f91:	55                   	push   %ebp
f0100f92:	89 e5                	mov    %esp,%ebp
f0100f94:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f97:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f9b:	8b 10                	mov    (%eax),%edx
f0100f9d:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fa0:	73 0a                	jae    f0100fac <sprintputch+0x1b>
		*b->buf++ = ch;
f0100fa2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fa5:	89 08                	mov    %ecx,(%eax)
f0100fa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100faa:	88 02                	mov    %al,(%edx)
}
f0100fac:	5d                   	pop    %ebp
f0100fad:	c3                   	ret    

f0100fae <printfmt>:
{
f0100fae:	55                   	push   %ebp
f0100faf:	89 e5                	mov    %esp,%ebp
f0100fb1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fb4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fb7:	50                   	push   %eax
f0100fb8:	ff 75 10             	pushl  0x10(%ebp)
f0100fbb:	ff 75 0c             	pushl  0xc(%ebp)
f0100fbe:	ff 75 08             	pushl  0x8(%ebp)
f0100fc1:	e8 05 00 00 00       	call   f0100fcb <vprintfmt>
}
f0100fc6:	83 c4 10             	add    $0x10,%esp
f0100fc9:	c9                   	leave  
f0100fca:	c3                   	ret    

f0100fcb <vprintfmt>:
{
f0100fcb:	55                   	push   %ebp
f0100fcc:	89 e5                	mov    %esp,%ebp
f0100fce:	57                   	push   %edi
f0100fcf:	56                   	push   %esi
f0100fd0:	53                   	push   %ebx
f0100fd1:	83 ec 2c             	sub    $0x2c,%esp
f0100fd4:	e8 e3 f1 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fd9:	81 c3 2f 03 01 00    	add    $0x1032f,%ebx
f0100fdf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fe2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100fe5:	e9 c3 03 00 00       	jmp    f01013ad <.L35+0x48>
		padc = ' ';
f0100fea:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fee:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100ff5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100ffc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0101003:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101008:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010100b:	8d 47 01             	lea    0x1(%edi),%eax
f010100e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101011:	0f b6 17             	movzbl (%edi),%edx
f0101014:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101017:	3c 55                	cmp    $0x55,%al
f0101019:	0f 87 16 04 00 00    	ja     f0101435 <.L22>
f010101f:	0f b6 c0             	movzbl %al,%eax
f0101022:	89 d9                	mov    %ebx,%ecx
f0101024:	03 8c 83 8c 0e ff ff 	add    -0xf174(%ebx,%eax,4),%ecx
f010102b:	ff e1                	jmp    *%ecx

f010102d <.L69>:
f010102d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0101030:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101034:	eb d5                	jmp    f010100b <vprintfmt+0x40>

f0101036 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0101036:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0101039:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010103d:	eb cc                	jmp    f010100b <vprintfmt+0x40>

f010103f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f010103f:	0f b6 d2             	movzbl %dl,%edx
f0101042:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101045:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010104a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010104d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101051:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101054:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101057:	83 f9 09             	cmp    $0x9,%ecx
f010105a:	77 55                	ja     f01010b1 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f010105c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010105f:	eb e9                	jmp    f010104a <.L29+0xb>

f0101061 <.L26>:
			precision = va_arg(ap, int);
f0101061:	8b 45 14             	mov    0x14(%ebp),%eax
f0101064:	8b 00                	mov    (%eax),%eax
f0101066:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101069:	8b 45 14             	mov    0x14(%ebp),%eax
f010106c:	8d 40 04             	lea    0x4(%eax),%eax
f010106f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101072:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101075:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101079:	79 90                	jns    f010100b <vprintfmt+0x40>
				width = precision, precision = -1;
f010107b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010107e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101081:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101088:	eb 81                	jmp    f010100b <vprintfmt+0x40>

f010108a <.L27>:
f010108a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010108d:	85 c0                	test   %eax,%eax
f010108f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101094:	0f 49 d0             	cmovns %eax,%edx
f0101097:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010109a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010109d:	e9 69 ff ff ff       	jmp    f010100b <vprintfmt+0x40>

f01010a2 <.L23>:
f01010a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01010a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01010ac:	e9 5a ff ff ff       	jmp    f010100b <vprintfmt+0x40>
f01010b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010b4:	eb bf                	jmp    f0101075 <.L26+0x14>

f01010b6 <.L33>:
			lflag++;
f01010b6:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01010bd:	e9 49 ff ff ff       	jmp    f010100b <vprintfmt+0x40>

f01010c2 <.L30>:
			putch(va_arg(ap, int), putdat);
f01010c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c5:	8d 78 04             	lea    0x4(%eax),%edi
f01010c8:	83 ec 08             	sub    $0x8,%esp
f01010cb:	56                   	push   %esi
f01010cc:	ff 30                	pushl  (%eax)
f01010ce:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010d4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01010d7:	e9 ce 02 00 00       	jmp    f01013aa <.L35+0x45>

f01010dc <.L32>:
			err = va_arg(ap, int);
f01010dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01010df:	8d 78 04             	lea    0x4(%eax),%edi
f01010e2:	8b 00                	mov    (%eax),%eax
f01010e4:	99                   	cltd   
f01010e5:	31 d0                	xor    %edx,%eax
f01010e7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010e9:	83 f8 06             	cmp    $0x6,%eax
f01010ec:	7f 27                	jg     f0101115 <.L32+0x39>
f01010ee:	8b 94 83 3c 1d 00 00 	mov    0x1d3c(%ebx,%eax,4),%edx
f01010f5:	85 d2                	test   %edx,%edx
f01010f7:	74 1c                	je     f0101115 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010f9:	52                   	push   %edx
f01010fa:	8d 83 1e 0e ff ff    	lea    -0xf1e2(%ebx),%eax
f0101100:	50                   	push   %eax
f0101101:	56                   	push   %esi
f0101102:	ff 75 08             	pushl  0x8(%ebp)
f0101105:	e8 a4 fe ff ff       	call   f0100fae <printfmt>
f010110a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010110d:	89 7d 14             	mov    %edi,0x14(%ebp)
f0101110:	e9 95 02 00 00       	jmp    f01013aa <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101115:	50                   	push   %eax
f0101116:	8d 83 15 0e ff ff    	lea    -0xf1eb(%ebx),%eax
f010111c:	50                   	push   %eax
f010111d:	56                   	push   %esi
f010111e:	ff 75 08             	pushl  0x8(%ebp)
f0101121:	e8 88 fe ff ff       	call   f0100fae <printfmt>
f0101126:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101129:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010112c:	e9 79 02 00 00       	jmp    f01013aa <.L35+0x45>

f0101131 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101131:	8b 45 14             	mov    0x14(%ebp),%eax
f0101134:	83 c0 04             	add    $0x4,%eax
f0101137:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010113a:	8b 45 14             	mov    0x14(%ebp),%eax
f010113d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010113f:	85 ff                	test   %edi,%edi
f0101141:	8d 83 0e 0e ff ff    	lea    -0xf1f2(%ebx),%eax
f0101147:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010114a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010114e:	0f 8e b5 00 00 00    	jle    f0101209 <.L36+0xd8>
f0101154:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101158:	75 08                	jne    f0101162 <.L36+0x31>
f010115a:	89 75 0c             	mov    %esi,0xc(%ebp)
f010115d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101160:	eb 6d                	jmp    f01011cf <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101162:	83 ec 08             	sub    $0x8,%esp
f0101165:	ff 75 cc             	pushl  -0x34(%ebp)
f0101168:	57                   	push   %edi
f0101169:	e8 82 04 00 00       	call   f01015f0 <strnlen>
f010116e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101171:	29 c2                	sub    %eax,%edx
f0101173:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0101176:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101179:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010117d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101180:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101183:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101185:	eb 10                	jmp    f0101197 <.L36+0x66>
					putch(padc, putdat);
f0101187:	83 ec 08             	sub    $0x8,%esp
f010118a:	56                   	push   %esi
f010118b:	ff 75 e0             	pushl  -0x20(%ebp)
f010118e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101191:	83 ef 01             	sub    $0x1,%edi
f0101194:	83 c4 10             	add    $0x10,%esp
f0101197:	85 ff                	test   %edi,%edi
f0101199:	7f ec                	jg     f0101187 <.L36+0x56>
f010119b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010119e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01011a1:	85 d2                	test   %edx,%edx
f01011a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a8:	0f 49 c2             	cmovns %edx,%eax
f01011ab:	29 c2                	sub    %eax,%edx
f01011ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01011b0:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011b3:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011b6:	eb 17                	jmp    f01011cf <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01011b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011bc:	75 30                	jne    f01011ee <.L36+0xbd>
					putch(ch, putdat);
f01011be:	83 ec 08             	sub    $0x8,%esp
f01011c1:	ff 75 0c             	pushl  0xc(%ebp)
f01011c4:	50                   	push   %eax
f01011c5:	ff 55 08             	call   *0x8(%ebp)
f01011c8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011cb:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011cf:	83 c7 01             	add    $0x1,%edi
f01011d2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01011d6:	0f be c2             	movsbl %dl,%eax
f01011d9:	85 c0                	test   %eax,%eax
f01011db:	74 52                	je     f010122f <.L36+0xfe>
f01011dd:	85 f6                	test   %esi,%esi
f01011df:	78 d7                	js     f01011b8 <.L36+0x87>
f01011e1:	83 ee 01             	sub    $0x1,%esi
f01011e4:	79 d2                	jns    f01011b8 <.L36+0x87>
f01011e6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011e9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011ec:	eb 32                	jmp    f0101220 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011ee:	0f be d2             	movsbl %dl,%edx
f01011f1:	83 ea 20             	sub    $0x20,%edx
f01011f4:	83 fa 5e             	cmp    $0x5e,%edx
f01011f7:	76 c5                	jbe    f01011be <.L36+0x8d>
					putch('?', putdat);
f01011f9:	83 ec 08             	sub    $0x8,%esp
f01011fc:	ff 75 0c             	pushl  0xc(%ebp)
f01011ff:	6a 3f                	push   $0x3f
f0101201:	ff 55 08             	call   *0x8(%ebp)
f0101204:	83 c4 10             	add    $0x10,%esp
f0101207:	eb c2                	jmp    f01011cb <.L36+0x9a>
f0101209:	89 75 0c             	mov    %esi,0xc(%ebp)
f010120c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010120f:	eb be                	jmp    f01011cf <.L36+0x9e>
				putch(' ', putdat);
f0101211:	83 ec 08             	sub    $0x8,%esp
f0101214:	56                   	push   %esi
f0101215:	6a 20                	push   $0x20
f0101217:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f010121a:	83 ef 01             	sub    $0x1,%edi
f010121d:	83 c4 10             	add    $0x10,%esp
f0101220:	85 ff                	test   %edi,%edi
f0101222:	7f ed                	jg     f0101211 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101224:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101227:	89 45 14             	mov    %eax,0x14(%ebp)
f010122a:	e9 7b 01 00 00       	jmp    f01013aa <.L35+0x45>
f010122f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101232:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101235:	eb e9                	jmp    f0101220 <.L36+0xef>

f0101237 <.L31>:
f0101237:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010123a:	83 f9 01             	cmp    $0x1,%ecx
f010123d:	7e 40                	jle    f010127f <.L31+0x48>
		return va_arg(*ap, long long);
f010123f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101242:	8b 50 04             	mov    0x4(%eax),%edx
f0101245:	8b 00                	mov    (%eax),%eax
f0101247:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010124a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010124d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101250:	8d 40 08             	lea    0x8(%eax),%eax
f0101253:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101256:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010125a:	79 55                	jns    f01012b1 <.L31+0x7a>
				putch('-', putdat);
f010125c:	83 ec 08             	sub    $0x8,%esp
f010125f:	56                   	push   %esi
f0101260:	6a 2d                	push   $0x2d
f0101262:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101265:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101268:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010126b:	f7 da                	neg    %edx
f010126d:	83 d1 00             	adc    $0x0,%ecx
f0101270:	f7 d9                	neg    %ecx
f0101272:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101275:	b8 0a 00 00 00       	mov    $0xa,%eax
f010127a:	e9 10 01 00 00       	jmp    f010138f <.L35+0x2a>
	else if (lflag)
f010127f:	85 c9                	test   %ecx,%ecx
f0101281:	75 17                	jne    f010129a <.L31+0x63>
		return va_arg(*ap, int);
f0101283:	8b 45 14             	mov    0x14(%ebp),%eax
f0101286:	8b 00                	mov    (%eax),%eax
f0101288:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010128b:	99                   	cltd   
f010128c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010128f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101292:	8d 40 04             	lea    0x4(%eax),%eax
f0101295:	89 45 14             	mov    %eax,0x14(%ebp)
f0101298:	eb bc                	jmp    f0101256 <.L31+0x1f>
		return va_arg(*ap, long);
f010129a:	8b 45 14             	mov    0x14(%ebp),%eax
f010129d:	8b 00                	mov    (%eax),%eax
f010129f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012a2:	99                   	cltd   
f01012a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a9:	8d 40 04             	lea    0x4(%eax),%eax
f01012ac:	89 45 14             	mov    %eax,0x14(%ebp)
f01012af:	eb a5                	jmp    f0101256 <.L31+0x1f>
			num = getint(&ap, lflag);
f01012b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012b7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012bc:	e9 ce 00 00 00       	jmp    f010138f <.L35+0x2a>

f01012c1 <.L37>:
f01012c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012c4:	83 f9 01             	cmp    $0x1,%ecx
f01012c7:	7e 18                	jle    f01012e1 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01012c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cc:	8b 10                	mov    (%eax),%edx
f01012ce:	8b 48 04             	mov    0x4(%eax),%ecx
f01012d1:	8d 40 08             	lea    0x8(%eax),%eax
f01012d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012d7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012dc:	e9 ae 00 00 00       	jmp    f010138f <.L35+0x2a>
	else if (lflag)
f01012e1:	85 c9                	test   %ecx,%ecx
f01012e3:	75 1a                	jne    f01012ff <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01012e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e8:	8b 10                	mov    (%eax),%edx
f01012ea:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012ef:	8d 40 04             	lea    0x4(%eax),%eax
f01012f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012f5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012fa:	e9 90 00 00 00       	jmp    f010138f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101302:	8b 10                	mov    (%eax),%edx
f0101304:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101309:	8d 40 04             	lea    0x4(%eax),%eax
f010130c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010130f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101314:	eb 79                	jmp    f010138f <.L35+0x2a>

f0101316 <.L34>:
f0101316:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101319:	83 f9 01             	cmp    $0x1,%ecx
f010131c:	7e 15                	jle    f0101333 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f010131e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101321:	8b 10                	mov    (%eax),%edx
f0101323:	8b 48 04             	mov    0x4(%eax),%ecx
f0101326:	8d 40 08             	lea    0x8(%eax),%eax
f0101329:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010132c:	b8 08 00 00 00       	mov    $0x8,%eax
f0101331:	eb 5c                	jmp    f010138f <.L35+0x2a>
	else if (lflag)
f0101333:	85 c9                	test   %ecx,%ecx
f0101335:	75 17                	jne    f010134e <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0101337:	8b 45 14             	mov    0x14(%ebp),%eax
f010133a:	8b 10                	mov    (%eax),%edx
f010133c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101341:	8d 40 04             	lea    0x4(%eax),%eax
f0101344:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101347:	b8 08 00 00 00       	mov    $0x8,%eax
f010134c:	eb 41                	jmp    f010138f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010134e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101351:	8b 10                	mov    (%eax),%edx
f0101353:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101358:	8d 40 04             	lea    0x4(%eax),%eax
f010135b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010135e:	b8 08 00 00 00       	mov    $0x8,%eax
f0101363:	eb 2a                	jmp    f010138f <.L35+0x2a>

f0101365 <.L35>:
			putch('0', putdat);
f0101365:	83 ec 08             	sub    $0x8,%esp
f0101368:	56                   	push   %esi
f0101369:	6a 30                	push   $0x30
f010136b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010136e:	83 c4 08             	add    $0x8,%esp
f0101371:	56                   	push   %esi
f0101372:	6a 78                	push   $0x78
f0101374:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101377:	8b 45 14             	mov    0x14(%ebp),%eax
f010137a:	8b 10                	mov    (%eax),%edx
f010137c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101381:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101384:	8d 40 04             	lea    0x4(%eax),%eax
f0101387:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010138a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010138f:	83 ec 0c             	sub    $0xc,%esp
f0101392:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101396:	57                   	push   %edi
f0101397:	ff 75 e0             	pushl  -0x20(%ebp)
f010139a:	50                   	push   %eax
f010139b:	51                   	push   %ecx
f010139c:	52                   	push   %edx
f010139d:	89 f2                	mov    %esi,%edx
f010139f:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a2:	e8 20 fb ff ff       	call   f0100ec7 <printnum>
			break;
f01013a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01013aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013ad:	83 c7 01             	add    $0x1,%edi
f01013b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01013b4:	83 f8 25             	cmp    $0x25,%eax
f01013b7:	0f 84 2d fc ff ff    	je     f0100fea <vprintfmt+0x1f>
			if (ch == '\0')
f01013bd:	85 c0                	test   %eax,%eax
f01013bf:	0f 84 91 00 00 00    	je     f0101456 <.L22+0x21>
			putch(ch, putdat);
f01013c5:	83 ec 08             	sub    $0x8,%esp
f01013c8:	56                   	push   %esi
f01013c9:	50                   	push   %eax
f01013ca:	ff 55 08             	call   *0x8(%ebp)
f01013cd:	83 c4 10             	add    $0x10,%esp
f01013d0:	eb db                	jmp    f01013ad <.L35+0x48>

f01013d2 <.L38>:
f01013d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013d5:	83 f9 01             	cmp    $0x1,%ecx
f01013d8:	7e 15                	jle    f01013ef <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01013da:	8b 45 14             	mov    0x14(%ebp),%eax
f01013dd:	8b 10                	mov    (%eax),%edx
f01013df:	8b 48 04             	mov    0x4(%eax),%ecx
f01013e2:	8d 40 08             	lea    0x8(%eax),%eax
f01013e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013e8:	b8 10 00 00 00       	mov    $0x10,%eax
f01013ed:	eb a0                	jmp    f010138f <.L35+0x2a>
	else if (lflag)
f01013ef:	85 c9                	test   %ecx,%ecx
f01013f1:	75 17                	jne    f010140a <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f6:	8b 10                	mov    (%eax),%edx
f01013f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013fd:	8d 40 04             	lea    0x4(%eax),%eax
f0101400:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101403:	b8 10 00 00 00       	mov    $0x10,%eax
f0101408:	eb 85                	jmp    f010138f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010140a:	8b 45 14             	mov    0x14(%ebp),%eax
f010140d:	8b 10                	mov    (%eax),%edx
f010140f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101414:	8d 40 04             	lea    0x4(%eax),%eax
f0101417:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010141a:	b8 10 00 00 00       	mov    $0x10,%eax
f010141f:	e9 6b ff ff ff       	jmp    f010138f <.L35+0x2a>

f0101424 <.L25>:
			putch(ch, putdat);
f0101424:	83 ec 08             	sub    $0x8,%esp
f0101427:	56                   	push   %esi
f0101428:	6a 25                	push   $0x25
f010142a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010142d:	83 c4 10             	add    $0x10,%esp
f0101430:	e9 75 ff ff ff       	jmp    f01013aa <.L35+0x45>

f0101435 <.L22>:
			putch('%', putdat);
f0101435:	83 ec 08             	sub    $0x8,%esp
f0101438:	56                   	push   %esi
f0101439:	6a 25                	push   $0x25
f010143b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010143e:	83 c4 10             	add    $0x10,%esp
f0101441:	89 f8                	mov    %edi,%eax
f0101443:	eb 03                	jmp    f0101448 <.L22+0x13>
f0101445:	83 e8 01             	sub    $0x1,%eax
f0101448:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010144c:	75 f7                	jne    f0101445 <.L22+0x10>
f010144e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101451:	e9 54 ff ff ff       	jmp    f01013aa <.L35+0x45>
}
f0101456:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101459:	5b                   	pop    %ebx
f010145a:	5e                   	pop    %esi
f010145b:	5f                   	pop    %edi
f010145c:	5d                   	pop    %ebp
f010145d:	c3                   	ret    

f010145e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010145e:	55                   	push   %ebp
f010145f:	89 e5                	mov    %esp,%ebp
f0101461:	53                   	push   %ebx
f0101462:	83 ec 14             	sub    $0x14,%esp
f0101465:	e8 52 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010146a:	81 c3 9e fe 00 00    	add    $0xfe9e,%ebx
f0101470:	8b 45 08             	mov    0x8(%ebp),%eax
f0101473:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101476:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101479:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010147d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101487:	85 c0                	test   %eax,%eax
f0101489:	74 2b                	je     f01014b6 <vsnprintf+0x58>
f010148b:	85 d2                	test   %edx,%edx
f010148d:	7e 27                	jle    f01014b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010148f:	ff 75 14             	pushl  0x14(%ebp)
f0101492:	ff 75 10             	pushl  0x10(%ebp)
f0101495:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101498:	50                   	push   %eax
f0101499:	8d 83 89 fc fe ff    	lea    -0x10377(%ebx),%eax
f010149f:	50                   	push   %eax
f01014a0:	e8 26 fb ff ff       	call   f0100fcb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014ae:	83 c4 10             	add    $0x10,%esp
}
f01014b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014b4:	c9                   	leave  
f01014b5:	c3                   	ret    
		return -E_INVAL;
f01014b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014bb:	eb f4                	jmp    f01014b1 <vsnprintf+0x53>

f01014bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014bd:	55                   	push   %ebp
f01014be:	89 e5                	mov    %esp,%ebp
f01014c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014c6:	50                   	push   %eax
f01014c7:	ff 75 10             	pushl  0x10(%ebp)
f01014ca:	ff 75 0c             	pushl  0xc(%ebp)
f01014cd:	ff 75 08             	pushl  0x8(%ebp)
f01014d0:	e8 89 ff ff ff       	call   f010145e <vsnprintf>
	va_end(ap);

	return rc;
}
f01014d5:	c9                   	leave  
f01014d6:	c3                   	ret    

f01014d7 <__x86.get_pc_thunk.cx>:
f01014d7:	8b 0c 24             	mov    (%esp),%ecx
f01014da:	c3                   	ret    

f01014db <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014db:	55                   	push   %ebp
f01014dc:	89 e5                	mov    %esp,%ebp
f01014de:	57                   	push   %edi
f01014df:	56                   	push   %esi
f01014e0:	53                   	push   %ebx
f01014e1:	83 ec 1c             	sub    $0x1c,%esp
f01014e4:	e8 d3 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014e9:	81 c3 1f fe 00 00    	add    $0xfe1f,%ebx
f01014ef:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 13                	je     f0101509 <readline+0x2e>
		cprintf("%s", prompt);
f01014f6:	83 ec 08             	sub    $0x8,%esp
f01014f9:	50                   	push   %eax
f01014fa:	8d 83 1e 0e ff ff    	lea    -0xf1e2(%ebx),%eax
f0101500:	50                   	push   %eax
f0101501:	e8 3b f6 ff ff       	call   f0100b41 <cprintf>
f0101506:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	6a 00                	push   $0x0
f010150e:	e8 41 f2 ff ff       	call   f0100754 <iscons>
f0101513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101516:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101519:	bf 00 00 00 00       	mov    $0x0,%edi
f010151e:	eb 46                	jmp    f0101566 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101520:	83 ec 08             	sub    $0x8,%esp
f0101523:	50                   	push   %eax
f0101524:	8d 83 e4 0f ff ff    	lea    -0xf01c(%ebx),%eax
f010152a:	50                   	push   %eax
f010152b:	e8 11 f6 ff ff       	call   f0100b41 <cprintf>
			return NULL;
f0101530:	83 c4 10             	add    $0x10,%esp
f0101533:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101538:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010153b:	5b                   	pop    %ebx
f010153c:	5e                   	pop    %esi
f010153d:	5f                   	pop    %edi
f010153e:	5d                   	pop    %ebp
f010153f:	c3                   	ret    
			if (echoing)
f0101540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101544:	75 05                	jne    f010154b <readline+0x70>
			i--;
f0101546:	83 ef 01             	sub    $0x1,%edi
f0101549:	eb 1b                	jmp    f0101566 <readline+0x8b>
				cputchar('\b');
f010154b:	83 ec 0c             	sub    $0xc,%esp
f010154e:	6a 08                	push   $0x8
f0101550:	e8 de f1 ff ff       	call   f0100733 <cputchar>
f0101555:	83 c4 10             	add    $0x10,%esp
f0101558:	eb ec                	jmp    f0101546 <readline+0x6b>
			buf[i++] = c;
f010155a:	89 f0                	mov    %esi,%eax
f010155c:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101563:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101566:	e8 d8 f1 ff ff       	call   f0100743 <getchar>
f010156b:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010156d:	85 c0                	test   %eax,%eax
f010156f:	78 af                	js     f0101520 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101571:	83 f8 08             	cmp    $0x8,%eax
f0101574:	0f 94 c2             	sete   %dl
f0101577:	83 f8 7f             	cmp    $0x7f,%eax
f010157a:	0f 94 c0             	sete   %al
f010157d:	08 c2                	or     %al,%dl
f010157f:	74 04                	je     f0101585 <readline+0xaa>
f0101581:	85 ff                	test   %edi,%edi
f0101583:	7f bb                	jg     f0101540 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101585:	83 fe 1f             	cmp    $0x1f,%esi
f0101588:	7e 1c                	jle    f01015a6 <readline+0xcb>
f010158a:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101590:	7f 14                	jg     f01015a6 <readline+0xcb>
			if (echoing)
f0101592:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101596:	74 c2                	je     f010155a <readline+0x7f>
				cputchar(c);
f0101598:	83 ec 0c             	sub    $0xc,%esp
f010159b:	56                   	push   %esi
f010159c:	e8 92 f1 ff ff       	call   f0100733 <cputchar>
f01015a1:	83 c4 10             	add    $0x10,%esp
f01015a4:	eb b4                	jmp    f010155a <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01015a6:	83 fe 0a             	cmp    $0xa,%esi
f01015a9:	74 05                	je     f01015b0 <readline+0xd5>
f01015ab:	83 fe 0d             	cmp    $0xd,%esi
f01015ae:	75 b6                	jne    f0101566 <readline+0x8b>
			if (echoing)
f01015b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015b4:	75 13                	jne    f01015c9 <readline+0xee>
			buf[i] = 0;
f01015b6:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015bd:	00 
			return buf;
f01015be:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015c4:	e9 6f ff ff ff       	jmp    f0101538 <readline+0x5d>
				cputchar('\n');
f01015c9:	83 ec 0c             	sub    $0xc,%esp
f01015cc:	6a 0a                	push   $0xa
f01015ce:	e8 60 f1 ff ff       	call   f0100733 <cputchar>
f01015d3:	83 c4 10             	add    $0x10,%esp
f01015d6:	eb de                	jmp    f01015b6 <readline+0xdb>

f01015d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015d8:	55                   	push   %ebp
f01015d9:	89 e5                	mov    %esp,%ebp
f01015db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015de:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e3:	eb 03                	jmp    f01015e8 <strlen+0x10>
		n++;
f01015e5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015ec:	75 f7                	jne    f01015e5 <strlen+0xd>
	return n;
}
f01015ee:	5d                   	pop    %ebp
f01015ef:	c3                   	ret    

f01015f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015f0:	55                   	push   %ebp
f01015f1:	89 e5                	mov    %esp,%ebp
f01015f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015fe:	eb 03                	jmp    f0101603 <strnlen+0x13>
		n++;
f0101600:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101603:	39 d0                	cmp    %edx,%eax
f0101605:	74 06                	je     f010160d <strnlen+0x1d>
f0101607:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010160b:	75 f3                	jne    f0101600 <strnlen+0x10>
	return n;
}
f010160d:	5d                   	pop    %ebp
f010160e:	c3                   	ret    

f010160f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010160f:	55                   	push   %ebp
f0101610:	89 e5                	mov    %esp,%ebp
f0101612:	53                   	push   %ebx
f0101613:	8b 45 08             	mov    0x8(%ebp),%eax
f0101616:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101619:	89 c2                	mov    %eax,%edx
f010161b:	83 c1 01             	add    $0x1,%ecx
f010161e:	83 c2 01             	add    $0x1,%edx
f0101621:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101625:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101628:	84 db                	test   %bl,%bl
f010162a:	75 ef                	jne    f010161b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010162c:	5b                   	pop    %ebx
f010162d:	5d                   	pop    %ebp
f010162e:	c3                   	ret    

f010162f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010162f:	55                   	push   %ebp
f0101630:	89 e5                	mov    %esp,%ebp
f0101632:	53                   	push   %ebx
f0101633:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101636:	53                   	push   %ebx
f0101637:	e8 9c ff ff ff       	call   f01015d8 <strlen>
f010163c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010163f:	ff 75 0c             	pushl  0xc(%ebp)
f0101642:	01 d8                	add    %ebx,%eax
f0101644:	50                   	push   %eax
f0101645:	e8 c5 ff ff ff       	call   f010160f <strcpy>
	return dst;
}
f010164a:	89 d8                	mov    %ebx,%eax
f010164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010164f:	c9                   	leave  
f0101650:	c3                   	ret    

f0101651 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101651:	55                   	push   %ebp
f0101652:	89 e5                	mov    %esp,%ebp
f0101654:	56                   	push   %esi
f0101655:	53                   	push   %ebx
f0101656:	8b 75 08             	mov    0x8(%ebp),%esi
f0101659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010165c:	89 f3                	mov    %esi,%ebx
f010165e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101661:	89 f2                	mov    %esi,%edx
f0101663:	eb 0f                	jmp    f0101674 <strncpy+0x23>
		*dst++ = *src;
f0101665:	83 c2 01             	add    $0x1,%edx
f0101668:	0f b6 01             	movzbl (%ecx),%eax
f010166b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010166e:	80 39 01             	cmpb   $0x1,(%ecx)
f0101671:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101674:	39 da                	cmp    %ebx,%edx
f0101676:	75 ed                	jne    f0101665 <strncpy+0x14>
	}
	return ret;
}
f0101678:	89 f0                	mov    %esi,%eax
f010167a:	5b                   	pop    %ebx
f010167b:	5e                   	pop    %esi
f010167c:	5d                   	pop    %ebp
f010167d:	c3                   	ret    

f010167e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010167e:	55                   	push   %ebp
f010167f:	89 e5                	mov    %esp,%ebp
f0101681:	56                   	push   %esi
f0101682:	53                   	push   %ebx
f0101683:	8b 75 08             	mov    0x8(%ebp),%esi
f0101686:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101689:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010168c:	89 f0                	mov    %esi,%eax
f010168e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101692:	85 c9                	test   %ecx,%ecx
f0101694:	75 0b                	jne    f01016a1 <strlcpy+0x23>
f0101696:	eb 17                	jmp    f01016af <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101698:	83 c2 01             	add    $0x1,%edx
f010169b:	83 c0 01             	add    $0x1,%eax
f010169e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01016a1:	39 d8                	cmp    %ebx,%eax
f01016a3:	74 07                	je     f01016ac <strlcpy+0x2e>
f01016a5:	0f b6 0a             	movzbl (%edx),%ecx
f01016a8:	84 c9                	test   %cl,%cl
f01016aa:	75 ec                	jne    f0101698 <strlcpy+0x1a>
		*dst = '\0';
f01016ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016af:	29 f0                	sub    %esi,%eax
}
f01016b1:	5b                   	pop    %ebx
f01016b2:	5e                   	pop    %esi
f01016b3:	5d                   	pop    %ebp
f01016b4:	c3                   	ret    

f01016b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016b5:	55                   	push   %ebp
f01016b6:	89 e5                	mov    %esp,%ebp
f01016b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016be:	eb 06                	jmp    f01016c6 <strcmp+0x11>
		p++, q++;
f01016c0:	83 c1 01             	add    $0x1,%ecx
f01016c3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016c6:	0f b6 01             	movzbl (%ecx),%eax
f01016c9:	84 c0                	test   %al,%al
f01016cb:	74 04                	je     f01016d1 <strcmp+0x1c>
f01016cd:	3a 02                	cmp    (%edx),%al
f01016cf:	74 ef                	je     f01016c0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016d1:	0f b6 c0             	movzbl %al,%eax
f01016d4:	0f b6 12             	movzbl (%edx),%edx
f01016d7:	29 d0                	sub    %edx,%eax
}
f01016d9:	5d                   	pop    %ebp
f01016da:	c3                   	ret    

f01016db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016db:	55                   	push   %ebp
f01016dc:	89 e5                	mov    %esp,%ebp
f01016de:	53                   	push   %ebx
f01016df:	8b 45 08             	mov    0x8(%ebp),%eax
f01016e2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016e5:	89 c3                	mov    %eax,%ebx
f01016e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016ea:	eb 06                	jmp    f01016f2 <strncmp+0x17>
		n--, p++, q++;
f01016ec:	83 c0 01             	add    $0x1,%eax
f01016ef:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016f2:	39 d8                	cmp    %ebx,%eax
f01016f4:	74 16                	je     f010170c <strncmp+0x31>
f01016f6:	0f b6 08             	movzbl (%eax),%ecx
f01016f9:	84 c9                	test   %cl,%cl
f01016fb:	74 04                	je     f0101701 <strncmp+0x26>
f01016fd:	3a 0a                	cmp    (%edx),%cl
f01016ff:	74 eb                	je     f01016ec <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101701:	0f b6 00             	movzbl (%eax),%eax
f0101704:	0f b6 12             	movzbl (%edx),%edx
f0101707:	29 d0                	sub    %edx,%eax
}
f0101709:	5b                   	pop    %ebx
f010170a:	5d                   	pop    %ebp
f010170b:	c3                   	ret    
		return 0;
f010170c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101711:	eb f6                	jmp    f0101709 <strncmp+0x2e>

f0101713 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101713:	55                   	push   %ebp
f0101714:	89 e5                	mov    %esp,%ebp
f0101716:	8b 45 08             	mov    0x8(%ebp),%eax
f0101719:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010171d:	0f b6 10             	movzbl (%eax),%edx
f0101720:	84 d2                	test   %dl,%dl
f0101722:	74 09                	je     f010172d <strchr+0x1a>
		if (*s == c)
f0101724:	38 ca                	cmp    %cl,%dl
f0101726:	74 0a                	je     f0101732 <strchr+0x1f>
	for (; *s; s++)
f0101728:	83 c0 01             	add    $0x1,%eax
f010172b:	eb f0                	jmp    f010171d <strchr+0xa>
			return (char *) s;
	return 0;
f010172d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101732:	5d                   	pop    %ebp
f0101733:	c3                   	ret    

f0101734 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101734:	55                   	push   %ebp
f0101735:	89 e5                	mov    %esp,%ebp
f0101737:	8b 45 08             	mov    0x8(%ebp),%eax
f010173a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010173e:	eb 03                	jmp    f0101743 <strfind+0xf>
f0101740:	83 c0 01             	add    $0x1,%eax
f0101743:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101746:	38 ca                	cmp    %cl,%dl
f0101748:	74 04                	je     f010174e <strfind+0x1a>
f010174a:	84 d2                	test   %dl,%dl
f010174c:	75 f2                	jne    f0101740 <strfind+0xc>
			break;
	return (char *) s;
}
f010174e:	5d                   	pop    %ebp
f010174f:	c3                   	ret    

f0101750 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101750:	55                   	push   %ebp
f0101751:	89 e5                	mov    %esp,%ebp
f0101753:	57                   	push   %edi
f0101754:	56                   	push   %esi
f0101755:	53                   	push   %ebx
f0101756:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101759:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010175c:	85 c9                	test   %ecx,%ecx
f010175e:	74 13                	je     f0101773 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101760:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101766:	75 05                	jne    f010176d <memset+0x1d>
f0101768:	f6 c1 03             	test   $0x3,%cl
f010176b:	74 0d                	je     f010177a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010176d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101770:	fc                   	cld    
f0101771:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101773:	89 f8                	mov    %edi,%eax
f0101775:	5b                   	pop    %ebx
f0101776:	5e                   	pop    %esi
f0101777:	5f                   	pop    %edi
f0101778:	5d                   	pop    %ebp
f0101779:	c3                   	ret    
		c &= 0xFF;
f010177a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010177e:	89 d3                	mov    %edx,%ebx
f0101780:	c1 e3 08             	shl    $0x8,%ebx
f0101783:	89 d0                	mov    %edx,%eax
f0101785:	c1 e0 18             	shl    $0x18,%eax
f0101788:	89 d6                	mov    %edx,%esi
f010178a:	c1 e6 10             	shl    $0x10,%esi
f010178d:	09 f0                	or     %esi,%eax
f010178f:	09 c2                	or     %eax,%edx
f0101791:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101793:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101796:	89 d0                	mov    %edx,%eax
f0101798:	fc                   	cld    
f0101799:	f3 ab                	rep stos %eax,%es:(%edi)
f010179b:	eb d6                	jmp    f0101773 <memset+0x23>

f010179d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010179d:	55                   	push   %ebp
f010179e:	89 e5                	mov    %esp,%ebp
f01017a0:	57                   	push   %edi
f01017a1:	56                   	push   %esi
f01017a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017a5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017ab:	39 c6                	cmp    %eax,%esi
f01017ad:	73 35                	jae    f01017e4 <memmove+0x47>
f01017af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017b2:	39 c2                	cmp    %eax,%edx
f01017b4:	76 2e                	jbe    f01017e4 <memmove+0x47>
		s += n;
		d += n;
f01017b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017b9:	89 d6                	mov    %edx,%esi
f01017bb:	09 fe                	or     %edi,%esi
f01017bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017c3:	74 0c                	je     f01017d1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017c5:	83 ef 01             	sub    $0x1,%edi
f01017c8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017cb:	fd                   	std    
f01017cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017ce:	fc                   	cld    
f01017cf:	eb 21                	jmp    f01017f2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017d1:	f6 c1 03             	test   $0x3,%cl
f01017d4:	75 ef                	jne    f01017c5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017d6:	83 ef 04             	sub    $0x4,%edi
f01017d9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017dc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017df:	fd                   	std    
f01017e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017e2:	eb ea                	jmp    f01017ce <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017e4:	89 f2                	mov    %esi,%edx
f01017e6:	09 c2                	or     %eax,%edx
f01017e8:	f6 c2 03             	test   $0x3,%dl
f01017eb:	74 09                	je     f01017f6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017ed:	89 c7                	mov    %eax,%edi
f01017ef:	fc                   	cld    
f01017f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017f2:	5e                   	pop    %esi
f01017f3:	5f                   	pop    %edi
f01017f4:	5d                   	pop    %ebp
f01017f5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017f6:	f6 c1 03             	test   $0x3,%cl
f01017f9:	75 f2                	jne    f01017ed <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017fe:	89 c7                	mov    %eax,%edi
f0101800:	fc                   	cld    
f0101801:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101803:	eb ed                	jmp    f01017f2 <memmove+0x55>

f0101805 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101805:	55                   	push   %ebp
f0101806:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101808:	ff 75 10             	pushl  0x10(%ebp)
f010180b:	ff 75 0c             	pushl  0xc(%ebp)
f010180e:	ff 75 08             	pushl  0x8(%ebp)
f0101811:	e8 87 ff ff ff       	call   f010179d <memmove>
}
f0101816:	c9                   	leave  
f0101817:	c3                   	ret    

f0101818 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101818:	55                   	push   %ebp
f0101819:	89 e5                	mov    %esp,%ebp
f010181b:	56                   	push   %esi
f010181c:	53                   	push   %ebx
f010181d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101820:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101823:	89 c6                	mov    %eax,%esi
f0101825:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101828:	39 f0                	cmp    %esi,%eax
f010182a:	74 1c                	je     f0101848 <memcmp+0x30>
		if (*s1 != *s2)
f010182c:	0f b6 08             	movzbl (%eax),%ecx
f010182f:	0f b6 1a             	movzbl (%edx),%ebx
f0101832:	38 d9                	cmp    %bl,%cl
f0101834:	75 08                	jne    f010183e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101836:	83 c0 01             	add    $0x1,%eax
f0101839:	83 c2 01             	add    $0x1,%edx
f010183c:	eb ea                	jmp    f0101828 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010183e:	0f b6 c1             	movzbl %cl,%eax
f0101841:	0f b6 db             	movzbl %bl,%ebx
f0101844:	29 d8                	sub    %ebx,%eax
f0101846:	eb 05                	jmp    f010184d <memcmp+0x35>
	}

	return 0;
f0101848:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010184d:	5b                   	pop    %ebx
f010184e:	5e                   	pop    %esi
f010184f:	5d                   	pop    %ebp
f0101850:	c3                   	ret    

f0101851 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101851:	55                   	push   %ebp
f0101852:	89 e5                	mov    %esp,%ebp
f0101854:	8b 45 08             	mov    0x8(%ebp),%eax
f0101857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010185a:	89 c2                	mov    %eax,%edx
f010185c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010185f:	39 d0                	cmp    %edx,%eax
f0101861:	73 09                	jae    f010186c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101863:	38 08                	cmp    %cl,(%eax)
f0101865:	74 05                	je     f010186c <memfind+0x1b>
	for (; s < ends; s++)
f0101867:	83 c0 01             	add    $0x1,%eax
f010186a:	eb f3                	jmp    f010185f <memfind+0xe>
			break;
	return (void *) s;
}
f010186c:	5d                   	pop    %ebp
f010186d:	c3                   	ret    

f010186e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010186e:	55                   	push   %ebp
f010186f:	89 e5                	mov    %esp,%ebp
f0101871:	57                   	push   %edi
f0101872:	56                   	push   %esi
f0101873:	53                   	push   %ebx
f0101874:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101877:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010187a:	eb 03                	jmp    f010187f <strtol+0x11>
		s++;
f010187c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010187f:	0f b6 01             	movzbl (%ecx),%eax
f0101882:	3c 20                	cmp    $0x20,%al
f0101884:	74 f6                	je     f010187c <strtol+0xe>
f0101886:	3c 09                	cmp    $0x9,%al
f0101888:	74 f2                	je     f010187c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010188a:	3c 2b                	cmp    $0x2b,%al
f010188c:	74 2e                	je     f01018bc <strtol+0x4e>
	int neg = 0;
f010188e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101893:	3c 2d                	cmp    $0x2d,%al
f0101895:	74 2f                	je     f01018c6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101897:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010189d:	75 05                	jne    f01018a4 <strtol+0x36>
f010189f:	80 39 30             	cmpb   $0x30,(%ecx)
f01018a2:	74 2c                	je     f01018d0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018a4:	85 db                	test   %ebx,%ebx
f01018a6:	75 0a                	jne    f01018b2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018a8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01018ad:	80 39 30             	cmpb   $0x30,(%ecx)
f01018b0:	74 28                	je     f01018da <strtol+0x6c>
		base = 10;
f01018b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01018b7:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018ba:	eb 50                	jmp    f010190c <strtol+0x9e>
		s++;
f01018bc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018bf:	bf 00 00 00 00       	mov    $0x0,%edi
f01018c4:	eb d1                	jmp    f0101897 <strtol+0x29>
		s++, neg = 1;
f01018c6:	83 c1 01             	add    $0x1,%ecx
f01018c9:	bf 01 00 00 00       	mov    $0x1,%edi
f01018ce:	eb c7                	jmp    f0101897 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018d0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018d4:	74 0e                	je     f01018e4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018d6:	85 db                	test   %ebx,%ebx
f01018d8:	75 d8                	jne    f01018b2 <strtol+0x44>
		s++, base = 8;
f01018da:	83 c1 01             	add    $0x1,%ecx
f01018dd:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018e2:	eb ce                	jmp    f01018b2 <strtol+0x44>
		s += 2, base = 16;
f01018e4:	83 c1 02             	add    $0x2,%ecx
f01018e7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018ec:	eb c4                	jmp    f01018b2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018ee:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018f1:	89 f3                	mov    %esi,%ebx
f01018f3:	80 fb 19             	cmp    $0x19,%bl
f01018f6:	77 29                	ja     f0101921 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018f8:	0f be d2             	movsbl %dl,%edx
f01018fb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018fe:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101901:	7d 30                	jge    f0101933 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101903:	83 c1 01             	add    $0x1,%ecx
f0101906:	0f af 45 10          	imul   0x10(%ebp),%eax
f010190a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010190c:	0f b6 11             	movzbl (%ecx),%edx
f010190f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101912:	89 f3                	mov    %esi,%ebx
f0101914:	80 fb 09             	cmp    $0x9,%bl
f0101917:	77 d5                	ja     f01018ee <strtol+0x80>
			dig = *s - '0';
f0101919:	0f be d2             	movsbl %dl,%edx
f010191c:	83 ea 30             	sub    $0x30,%edx
f010191f:	eb dd                	jmp    f01018fe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101921:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101924:	89 f3                	mov    %esi,%ebx
f0101926:	80 fb 19             	cmp    $0x19,%bl
f0101929:	77 08                	ja     f0101933 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010192b:	0f be d2             	movsbl %dl,%edx
f010192e:	83 ea 37             	sub    $0x37,%edx
f0101931:	eb cb                	jmp    f01018fe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101933:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101937:	74 05                	je     f010193e <strtol+0xd0>
		*endptr = (char *) s;
f0101939:	8b 75 0c             	mov    0xc(%ebp),%esi
f010193c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010193e:	89 c2                	mov    %eax,%edx
f0101940:	f7 da                	neg    %edx
f0101942:	85 ff                	test   %edi,%edi
f0101944:	0f 45 c2             	cmovne %edx,%eax
}
f0101947:	5b                   	pop    %ebx
f0101948:	5e                   	pop    %esi
f0101949:	5f                   	pop    %edi
f010194a:	5d                   	pop    %ebp
f010194b:	c3                   	ret    
f010194c:	66 90                	xchg   %ax,%ax
f010194e:	66 90                	xchg   %ax,%ax

f0101950 <__udivdi3>:
f0101950:	55                   	push   %ebp
f0101951:	57                   	push   %edi
f0101952:	56                   	push   %esi
f0101953:	53                   	push   %ebx
f0101954:	83 ec 1c             	sub    $0x1c,%esp
f0101957:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010195b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010195f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101963:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101967:	85 d2                	test   %edx,%edx
f0101969:	75 35                	jne    f01019a0 <__udivdi3+0x50>
f010196b:	39 f3                	cmp    %esi,%ebx
f010196d:	0f 87 bd 00 00 00    	ja     f0101a30 <__udivdi3+0xe0>
f0101973:	85 db                	test   %ebx,%ebx
f0101975:	89 d9                	mov    %ebx,%ecx
f0101977:	75 0b                	jne    f0101984 <__udivdi3+0x34>
f0101979:	b8 01 00 00 00       	mov    $0x1,%eax
f010197e:	31 d2                	xor    %edx,%edx
f0101980:	f7 f3                	div    %ebx
f0101982:	89 c1                	mov    %eax,%ecx
f0101984:	31 d2                	xor    %edx,%edx
f0101986:	89 f0                	mov    %esi,%eax
f0101988:	f7 f1                	div    %ecx
f010198a:	89 c6                	mov    %eax,%esi
f010198c:	89 e8                	mov    %ebp,%eax
f010198e:	89 f7                	mov    %esi,%edi
f0101990:	f7 f1                	div    %ecx
f0101992:	89 fa                	mov    %edi,%edx
f0101994:	83 c4 1c             	add    $0x1c,%esp
f0101997:	5b                   	pop    %ebx
f0101998:	5e                   	pop    %esi
f0101999:	5f                   	pop    %edi
f010199a:	5d                   	pop    %ebp
f010199b:	c3                   	ret    
f010199c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	39 f2                	cmp    %esi,%edx
f01019a2:	77 7c                	ja     f0101a20 <__udivdi3+0xd0>
f01019a4:	0f bd fa             	bsr    %edx,%edi
f01019a7:	83 f7 1f             	xor    $0x1f,%edi
f01019aa:	0f 84 98 00 00 00    	je     f0101a48 <__udivdi3+0xf8>
f01019b0:	89 f9                	mov    %edi,%ecx
f01019b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019b7:	29 f8                	sub    %edi,%eax
f01019b9:	d3 e2                	shl    %cl,%edx
f01019bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019bf:	89 c1                	mov    %eax,%ecx
f01019c1:	89 da                	mov    %ebx,%edx
f01019c3:	d3 ea                	shr    %cl,%edx
f01019c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019c9:	09 d1                	or     %edx,%ecx
f01019cb:	89 f2                	mov    %esi,%edx
f01019cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019d1:	89 f9                	mov    %edi,%ecx
f01019d3:	d3 e3                	shl    %cl,%ebx
f01019d5:	89 c1                	mov    %eax,%ecx
f01019d7:	d3 ea                	shr    %cl,%edx
f01019d9:	89 f9                	mov    %edi,%ecx
f01019db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019df:	d3 e6                	shl    %cl,%esi
f01019e1:	89 eb                	mov    %ebp,%ebx
f01019e3:	89 c1                	mov    %eax,%ecx
f01019e5:	d3 eb                	shr    %cl,%ebx
f01019e7:	09 de                	or     %ebx,%esi
f01019e9:	89 f0                	mov    %esi,%eax
f01019eb:	f7 74 24 08          	divl   0x8(%esp)
f01019ef:	89 d6                	mov    %edx,%esi
f01019f1:	89 c3                	mov    %eax,%ebx
f01019f3:	f7 64 24 0c          	mull   0xc(%esp)
f01019f7:	39 d6                	cmp    %edx,%esi
f01019f9:	72 0c                	jb     f0101a07 <__udivdi3+0xb7>
f01019fb:	89 f9                	mov    %edi,%ecx
f01019fd:	d3 e5                	shl    %cl,%ebp
f01019ff:	39 c5                	cmp    %eax,%ebp
f0101a01:	73 5d                	jae    f0101a60 <__udivdi3+0x110>
f0101a03:	39 d6                	cmp    %edx,%esi
f0101a05:	75 59                	jne    f0101a60 <__udivdi3+0x110>
f0101a07:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a0a:	31 ff                	xor    %edi,%edi
f0101a0c:	89 fa                	mov    %edi,%edx
f0101a0e:	83 c4 1c             	add    $0x1c,%esp
f0101a11:	5b                   	pop    %ebx
f0101a12:	5e                   	pop    %esi
f0101a13:	5f                   	pop    %edi
f0101a14:	5d                   	pop    %ebp
f0101a15:	c3                   	ret    
f0101a16:	8d 76 00             	lea    0x0(%esi),%esi
f0101a19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a20:	31 ff                	xor    %edi,%edi
f0101a22:	31 c0                	xor    %eax,%eax
f0101a24:	89 fa                	mov    %edi,%edx
f0101a26:	83 c4 1c             	add    $0x1c,%esp
f0101a29:	5b                   	pop    %ebx
f0101a2a:	5e                   	pop    %esi
f0101a2b:	5f                   	pop    %edi
f0101a2c:	5d                   	pop    %ebp
f0101a2d:	c3                   	ret    
f0101a2e:	66 90                	xchg   %ax,%ax
f0101a30:	31 ff                	xor    %edi,%edi
f0101a32:	89 e8                	mov    %ebp,%eax
f0101a34:	89 f2                	mov    %esi,%edx
f0101a36:	f7 f3                	div    %ebx
f0101a38:	89 fa                	mov    %edi,%edx
f0101a3a:	83 c4 1c             	add    $0x1c,%esp
f0101a3d:	5b                   	pop    %ebx
f0101a3e:	5e                   	pop    %esi
f0101a3f:	5f                   	pop    %edi
f0101a40:	5d                   	pop    %ebp
f0101a41:	c3                   	ret    
f0101a42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a48:	39 f2                	cmp    %esi,%edx
f0101a4a:	72 06                	jb     f0101a52 <__udivdi3+0x102>
f0101a4c:	31 c0                	xor    %eax,%eax
f0101a4e:	39 eb                	cmp    %ebp,%ebx
f0101a50:	77 d2                	ja     f0101a24 <__udivdi3+0xd4>
f0101a52:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a57:	eb cb                	jmp    f0101a24 <__udivdi3+0xd4>
f0101a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a60:	89 d8                	mov    %ebx,%eax
f0101a62:	31 ff                	xor    %edi,%edi
f0101a64:	eb be                	jmp    f0101a24 <__udivdi3+0xd4>
f0101a66:	66 90                	xchg   %ax,%ax
f0101a68:	66 90                	xchg   %ax,%ax
f0101a6a:	66 90                	xchg   %ax,%ax
f0101a6c:	66 90                	xchg   %ax,%ax
f0101a6e:	66 90                	xchg   %ax,%ax

f0101a70 <__umoddi3>:
f0101a70:	55                   	push   %ebp
f0101a71:	57                   	push   %edi
f0101a72:	56                   	push   %esi
f0101a73:	53                   	push   %ebx
f0101a74:	83 ec 1c             	sub    $0x1c,%esp
f0101a77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a7b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a83:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a87:	85 ed                	test   %ebp,%ebp
f0101a89:	89 f0                	mov    %esi,%eax
f0101a8b:	89 da                	mov    %ebx,%edx
f0101a8d:	75 19                	jne    f0101aa8 <__umoddi3+0x38>
f0101a8f:	39 df                	cmp    %ebx,%edi
f0101a91:	0f 86 b1 00 00 00    	jbe    f0101b48 <__umoddi3+0xd8>
f0101a97:	f7 f7                	div    %edi
f0101a99:	89 d0                	mov    %edx,%eax
f0101a9b:	31 d2                	xor    %edx,%edx
f0101a9d:	83 c4 1c             	add    $0x1c,%esp
f0101aa0:	5b                   	pop    %ebx
f0101aa1:	5e                   	pop    %esi
f0101aa2:	5f                   	pop    %edi
f0101aa3:	5d                   	pop    %ebp
f0101aa4:	c3                   	ret    
f0101aa5:	8d 76 00             	lea    0x0(%esi),%esi
f0101aa8:	39 dd                	cmp    %ebx,%ebp
f0101aaa:	77 f1                	ja     f0101a9d <__umoddi3+0x2d>
f0101aac:	0f bd cd             	bsr    %ebp,%ecx
f0101aaf:	83 f1 1f             	xor    $0x1f,%ecx
f0101ab2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ab6:	0f 84 b4 00 00 00    	je     f0101b70 <__umoddi3+0x100>
f0101abc:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ac1:	89 c2                	mov    %eax,%edx
f0101ac3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ac7:	29 c2                	sub    %eax,%edx
f0101ac9:	89 c1                	mov    %eax,%ecx
f0101acb:	89 f8                	mov    %edi,%eax
f0101acd:	d3 e5                	shl    %cl,%ebp
f0101acf:	89 d1                	mov    %edx,%ecx
f0101ad1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ad5:	d3 e8                	shr    %cl,%eax
f0101ad7:	09 c5                	or     %eax,%ebp
f0101ad9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101add:	89 c1                	mov    %eax,%ecx
f0101adf:	d3 e7                	shl    %cl,%edi
f0101ae1:	89 d1                	mov    %edx,%ecx
f0101ae3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101ae7:	89 df                	mov    %ebx,%edi
f0101ae9:	d3 ef                	shr    %cl,%edi
f0101aeb:	89 c1                	mov    %eax,%ecx
f0101aed:	89 f0                	mov    %esi,%eax
f0101aef:	d3 e3                	shl    %cl,%ebx
f0101af1:	89 d1                	mov    %edx,%ecx
f0101af3:	89 fa                	mov    %edi,%edx
f0101af5:	d3 e8                	shr    %cl,%eax
f0101af7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101afc:	09 d8                	or     %ebx,%eax
f0101afe:	f7 f5                	div    %ebp
f0101b00:	d3 e6                	shl    %cl,%esi
f0101b02:	89 d1                	mov    %edx,%ecx
f0101b04:	f7 64 24 08          	mull   0x8(%esp)
f0101b08:	39 d1                	cmp    %edx,%ecx
f0101b0a:	89 c3                	mov    %eax,%ebx
f0101b0c:	89 d7                	mov    %edx,%edi
f0101b0e:	72 06                	jb     f0101b16 <__umoddi3+0xa6>
f0101b10:	75 0e                	jne    f0101b20 <__umoddi3+0xb0>
f0101b12:	39 c6                	cmp    %eax,%esi
f0101b14:	73 0a                	jae    f0101b20 <__umoddi3+0xb0>
f0101b16:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101b1a:	19 ea                	sbb    %ebp,%edx
f0101b1c:	89 d7                	mov    %edx,%edi
f0101b1e:	89 c3                	mov    %eax,%ebx
f0101b20:	89 ca                	mov    %ecx,%edx
f0101b22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b27:	29 de                	sub    %ebx,%esi
f0101b29:	19 fa                	sbb    %edi,%edx
f0101b2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b2f:	89 d0                	mov    %edx,%eax
f0101b31:	d3 e0                	shl    %cl,%eax
f0101b33:	89 d9                	mov    %ebx,%ecx
f0101b35:	d3 ee                	shr    %cl,%esi
f0101b37:	d3 ea                	shr    %cl,%edx
f0101b39:	09 f0                	or     %esi,%eax
f0101b3b:	83 c4 1c             	add    $0x1c,%esp
f0101b3e:	5b                   	pop    %ebx
f0101b3f:	5e                   	pop    %esi
f0101b40:	5f                   	pop    %edi
f0101b41:	5d                   	pop    %ebp
f0101b42:	c3                   	ret    
f0101b43:	90                   	nop
f0101b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b48:	85 ff                	test   %edi,%edi
f0101b4a:	89 f9                	mov    %edi,%ecx
f0101b4c:	75 0b                	jne    f0101b59 <__umoddi3+0xe9>
f0101b4e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b53:	31 d2                	xor    %edx,%edx
f0101b55:	f7 f7                	div    %edi
f0101b57:	89 c1                	mov    %eax,%ecx
f0101b59:	89 d8                	mov    %ebx,%eax
f0101b5b:	31 d2                	xor    %edx,%edx
f0101b5d:	f7 f1                	div    %ecx
f0101b5f:	89 f0                	mov    %esi,%eax
f0101b61:	f7 f1                	div    %ecx
f0101b63:	e9 31 ff ff ff       	jmp    f0101a99 <__umoddi3+0x29>
f0101b68:	90                   	nop
f0101b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b70:	39 dd                	cmp    %ebx,%ebp
f0101b72:	72 08                	jb     f0101b7c <__umoddi3+0x10c>
f0101b74:	39 f7                	cmp    %esi,%edi
f0101b76:	0f 87 21 ff ff ff    	ja     f0101a9d <__umoddi3+0x2d>
f0101b7c:	89 da                	mov    %ebx,%edx
f0101b7e:	89 f0                	mov    %esi,%eax
f0101b80:	29 f8                	sub    %edi,%eax
f0101b82:	19 ea                	sbb    %ebp,%edx
f0101b84:	e9 14 ff ff ff       	jmp    f0101a9d <__umoddi3+0x2d>
