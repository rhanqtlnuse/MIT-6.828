## Lab 1

> “x86 Athena machine” 是指 `uname -a` 命令结果中包含 “i386 GNU/Linux” 或 “i686 GNU/Linux” 或 “x86_64 GNU/Linux” 的系统。

what does fork() do?
- copies user memory
- copies kernel state e.g. file descriptors
- so "child" is almost identical to "parent"
- child has different "process ID"
- both processes now run, in parallel
- fork returns twice, once in parent, once in child
  - child PID to parent
  - 0 to child

`wait()` 有 2 种可能的结果$^{[1]}$：

1. **If** there are at least one **child** processes running **when the call** to `wait()` is made, the caller will be blocked **until** one of its **child** processes **exits**.
2. **If** there is no **child** process running **when the call** to **wait**() is made, then this `wait()` has no effect at all.

`read()` `write()` `pipe()`

### `exec` 族

```
for ls | wc -l, shell must:
    - create a pipe
    - fork
    - set up fd 1 to be the pipe write FD
    - exec ls
    - set up wc's fd 0 to be pipe read FD
    - exec wc
    - wait for wc
```

```
pipe file descriptors are inherited across fork
    so pipes can be used to communicate between processes
```

```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      | 
|  memory mapped   | 
|     devices      | 
|                  | 
/\/\/\/\/\/\/\/\/\/\  

/\/\/\/\/\/\/\/\/\/\ 
|                  | 
|      Unused      | 
|                  | 
+------------------+  <- depends on amount of RAM 
|                  | 
|                  | 
| Extended Memory  | 
|                  | 
|                  | 
+------------------+  <- 0x00100000 (1MB) 
|     BIOS ROM     | 
+------------------+  <- 0x000F0000 (960KB) 
|  16-bit devices, | 
|  expansion ROMs  | 
+------------------+  <- 0x000C0000 (768KB) 
|   VGA Display    | 
+------------------+  <- 0x000A0000 (640KB) 
|                  | 
|    Low Memory    | 
|                  | 
+------------------+  <- 0x00000000`
```

- In early PCs the BIOS was held in true read-only memory (ROM), but current PCs store the BIOS in updateable flash memory.
- Modern PCs therefore have a "hole" in physical memory from 0x000A0000 to 0x00100000, dividing RAM into "low" or "conventional memory" (the first 640KB) and "extended memory" (everything else)
- some space at the very top of the PC's 32-bit physical address space, above all physical RAM, is now commonly reserved by the BIOS for use by 32-bit PCI devices. Recent x86 processors can support *more* than 4GB of physical RAM, so RAM can extend further above 0xFFFFFFFF. In this case the BIOS must arrange to leave a *second* hole in the system's RAM at the top of the 32-bit addressable region, to leave room for these 32-bit devices to be mapped. 
- Because the BIOS in a PC is "hard-wired" to the physical address range 0x000f0000-0x000fffff，这样的设计保证计算机启动（加电/任何系统重启）之后 BIOS 总是首先获得控制权
- On processor reset, the (simulated) processor enters real mode and sets CS to 0xf000 and the IP to 0xfff0, so that execution begins at that (CS:IP) segment address.
  - *物理地址* = 16 * *段首地址* + *段内偏移*

### PC 引导

1. BIOS 进行初始化设备（如 VGA）和检查
2. BIOS 查找可引导的设备，如软盘、硬盘、CD-ROM 等，若找到，读取 Boot Loader，将控制权移交给 Boot Loader

### BIOS

> x86 架构有两种类型的 I/O 设备，一种是 Memory-Mapped I/O，另一种是 Port-Mapped I/O
>
> [Memory-Mapped I/O](https://en.wikipedia.org/wiki/Memory-mapped_I/O)

#### 代码

```
[f000:fff0]    ljmp    $0x3630, $0xf000e05b
[f000:e05b]    cmpw    $0xffc8, %cs:(%esi)    ; (%cs*16+%esi) - 0xffc8
[f000:e062]    jne     0xd241d416
[f000:e066]    xor     %edx, %edx    ; 清空 %edx
[f000:e068]    mov     %edx, %ss     ; %ss <- %edx 的内容
[f000:e06a]    mov     $0x7000, %sp  ; %sp <- 0x7000
[f000:e070]    mov     $0x2d4e, %dx  ; %dx <- 0x2d4e
[f000:e076]    jmp     0x5575ff02
[f000:ff00]    cli                   ; 关中断
[f000:ff01]    cld                   ; cld/std 用于操作方向标志位 DF
                                     ; 方向标志位用于串操作指令
                                     ; cld 使 DF 复位，std 使 DF 置位
[f000:ff02]    mov     %ax, %cx      ; %cx <- %ax
[f000:ff05]    mov     $0x8f, %ax    ; %ax <- 0x8f
[f000:ff0b]    out     %al, $0x70    ; 将 0x8f 写至 0x70 号端口
[f000:ff0d]    in      $0x71, %al    ; 将 0x71 号端口的内容读至 %al
                                     ; 这一步有什么卵用？下一步寄存器值就被覆盖
[f000:ff0f]    in      $0x92, %al    ; 将 0x92 号端口的内容读至 %al
[f000:ff11]    or      $0x2, %al     ; %al <- %al | 0x2
                                     ; 置位，指示 A20 总线活跃
[f000:ff13]    out     %al, $0x92    ; 将 %al 的内容写至 0x92 号端口
                                     ; 
[f000:ff15]    mov     %cx, %ax      ; %ax <- %cx
[f000:ff18]    lidtl   %cs:(%esi)    ; 加载中断描述符表（IDT）
[f000:ff1e]    lgdtl   %cs:(%esi)    ; 加载全局描述符表（GDT）
[f000:ff24]    mov     %cr0, %ecx    ; %ecx <- %cr0
                                     ; %cr0 用于
[f000:ff27]    and     $0xffff, %cx  ; %cx <- %cx & 0xffff
                                     ; 这一步有什么卵用？
[f000:ff2e]    or      $0x1, %cx     ; %cx <- %cx | 0x1
                                     ; 置位：开启保护模式
[f000:ff32]    mov     %ecx, %cr0    ; %cr0 <- %ecx
[f000:ff35]    ljmpw   $0xf, $0xff3d ; 
=> 0xfff3d     mov     $0x10, %ecx   ; %ecx <- 0x10
=> 0xfff42     mov     %ecx, %ds     ; %ds <- %ecx
                                     ; 大小？
=> 0xfff44     mov     %ecx, %es     ; %es <- %ecx
=> 0xfff46     mov     %ecx, %ss     ; %ss <- %ecx
=> 0xfff48     mov     %ecx, %fs     ; %fs <- %ecx
=> 0xfff4a     mov     %ecx, %gs     ; %gs <- %ecx
=> 0xfff4c     jmp     *%edx         ; [f000:e070] 处，%edx 为 0x2d4e
                                     ; %cs 为 0xf000
=> 0xf2d4e     push    %ebx
=> 0xf2d4f     sub     $0x20, %esp   ; %esp <- %esp - 0x20
=> 0xf3d52     call    0xef7e4
=> 0xef7e4     push    $0xf60f8
=> 0xef7e9     push    $0xf3514
=> 0xef7ee     call    0xef7d1
=> 0xef7d1     lea     0x8(%esp), %ecx
=> 0xef7d5     mov     0x4(%esp), %edx
=> 0xef7d9     mov     $0xf6098, %eax
=> 0xef7de     call    0xef0f8
=> 0xef0f8     push    %ebp
=> 0xef0f9     push    %edi
=> 0xef0fa     push    %esi
=> 0xef0fb     push    %ebx
=> 0xef0fc     sub     $0x8, %esp     ; %esp <- %esp - 0x8
=> 0xef0ff     mov     %eax, %ebx
=> 0xef101     mov     %edx, %edi
=> 0xef103     mov     %ecx, %ebp
=> 0xef105     movsbl  (%edi), %edx
=> 0xef108     test    %dl, %dl
=> 0xef10a     je      0xef36f
=> 0xef110     cmp     $0x25, %dl
=> 0xef113     jne     0xef1ec
=> 0xef1ec     mov     %ebx, %eax
```

- A20 总线专门用来转换地址总线的第 21 位。在引导系统时，BIOS 先打开 A20 总线来统计和测试所有的系统内存。而当 BIOS 准备将计算机的控制权交给 OS 时会先将 A20 总线关闭。
- 关于中断描述符表和全局描述符表
- `cr0` 是“控制寄存器”（Control Register）之一，32 位（在 x86_64 下的 long mode 中为 64 位），第 0 位标识保护模式是否开启$^{[3]}$

### Boot Loader

- 软盘和硬盘被分割成大小为 512B 的区域，称为扇区，是磁盘最小的传输单元

- 如果磁盘是可引导的，那么第一个扇区中含有 Boot Loader 的代码，称为引导扇区

- BIOS 找到可引导的软/硬盘时，将引导扇区中的代码拷贝至物理地址 **0x7c00 - 0x7dff** 处，跳转至 CS:IP = 0000:7c00 处（640KB RAM 区），将控制权交给 Boot Loader

- CD-ROM 的扇区大小为 2048B

  - https://pdos.csail.mit.edu/6.828/2018/readings/boot-cdrom.pdf

- Boot Loader 的主要功能：
  - 将处理器从实模式转换到 32 位保护模式
    - it is only in this mode that software can access all the memory above 1MB in the processor's physical address space
    - 保护模式下的分段地址转换：*物理地址* = 32 * *段首地址* + *段内偏移*
  - 读取内核代码

- **Exercise 3**

  - `repnz insl`：当 `%ecx` 中的值不为 0 时，重复执行 `insl`

  - `boot/main.c`

    - `bootmain()`：`0x7d15`

      ```Plain
      0x7d18		push	%esi
      0x7d19		push	%ebx
      0x7d1a		push	$0x0
      0x7d1c		push	$0x1000
      0x7d21		push	$0x10000
      0x7d26		call	0x7cdc
      ...
      0x7d2b		add		$0xc, %esp			; %esp <- %esp + 0xc
      ```

      第一次调用 `readseg`（读取一页，大小为 4KB）之前的准备工作，三个参数

      - `push $0x0`：`offset`
      - `push $0x1000`：`count`，`SECTSIZE*8`（`#define SECTSIZE 512`）
      - `push $0x10000`：`pa`，`(uint32_t) ELFHDR`（`#define ELFHDR ...`）

    - `readseg()`：`0x7cdc`

      ```
      0x7ce1		mov		0x10(%ebp), %edi	; 0x10(%ebp) 为 offset
      										; 同理，0xc(%ebp) 为 count
      										; 0x8(%ebp) 为 pa
      0x7ce4		push	%ebx
      0x7ce5		mov		0xc(%ebp), %esi
      0x7ce8		mov		0x8(%ebp), %ebx		; %edi: offset
      										; %esi: count
      										; %ebx: pa
      0x7ceb		shr		$0x9, %edi			; 
      0x7cee		add		%ebx, %esi			; count += pa
      0x7cf0		inc		%edi				; offset++
      										; 因为 offset 为 0，
      										; 此处应该是进行了优化
      0x7cf1		and		$0xfffffe00, %ebx	; pa &= ~(SECTSIZE - 1)
      0x7cf7		cmp		%esi, %ebx			; pa < end_pa
      0x7cf9		jae		0x7d0d				; 
      0x7cfb		push	%edi				; readsect 的参数 offset
      0x7cfc		push	%ebx  				; readsect 的参数 pa
      0x7cfd		inc		%edi				; offset++
      0x7cfe		add		$0x200, %ebx		; pa += SECTSIZE
      0x7d04		call	0x7c7c				; 调用 readsect
      ...
      0x7d0d		lea		-0xc(%ebp), %esp	; %esp <- %ebp - 0xc
      										; %ebp: 0x7bdc
      ```

      - `pa` 起始地址为 `0x10000`（640KB RAM 区）

    - `readsect()`：`0x7c7c`

      ```Plain
      0x7c7f		push	%edi
      0x7c80		mov		0xc(%ebp), %ecx		; %ecx: offset
      ; waitdisk()
      ; 一系列 outb() 调用
      ; waitdisk()
      0x7cc9		mov		0x8(%ebp), %edi		; 第二个参数 dst
      0x7ccc		mov		$0x80, %ecx			; 第三个参数 SECTSIZE/4
      0x7cd1		mov		$0x1f0, %edx		; 第一个参数 0x1f0
      0x7cd6		cld
      0x7cd7		repnz insl (%dx), %es:(%edi)
      										; 重复执行至 %ecx 为 0
      										; 结束时 %edi 为 0x10200
      ```

    - `waitdisk()`：`0x7c6a`

  - `inc/x86.h`

    - `insl()`：经过优化，结束后越过 `readsect` 直接跳至 `readseg`

  - `inc/elf.h`

    - 

- 问题

  - At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
  - What is the *last* instruction of the boot loader executed, and what is the *first* instruction of the kernel it just loaded?
  - *Where* is the first instruction of the kernel?
    - `ELFHDR->e_entry`
  - How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?
    - ELF Header$^{[4][5]}$
    - GDB 中通过 `x/x 0x10000` 可以看到 `0x464c457f`，就是 `0x7f` 加 'E' 'L' 'F'（小端机），为 magic number（因为 ELF 的起始地址为 `0x10000`）

- Boot Loader 不改变内核代码，仅仅是将其载入内存并执行

> 汇编代码的重要组成部分
>
> - `.text`：可执行的指令
>
> - `.rodata`：只读数据，如字符串常量
>
> - `.data`：被初始化的数据
>
> - `.bss`（Block Started by Symbol）：未被初始化的全局变量
>
>   - C requires that "uninitialized" global variables start with a value of zero. Thus there is no need to store contents for `.bss` in the ELF binary; instead, the linker records just the address and size of the `.bss` section. The loader or the program itself must arrange to zero the `.bss`section.
>
> - 其他段可使用 `objdump -h obj/kern/kernel` 看到
>
>   - Take particular note of the "VMA" (or *link address*) and the "LMA" (or *load address*) of the `.text` section. The load address of a section is the memory address at which that section should be loaded into memory.
>
>     The link address of a section is the memory address from which the section expects to execute. The linker encodes the link address in the binary in various ways, such as when the code needs the address of a global variable, with the result that a binary usually won't work if it is executing from an address that it is not linked for. (It is possible to generate *position-independent* code that does not contain any such absolute addresses. This is used extensively by modern shared libraries, but it has performance and complexity costs)
>
>     （**上面这段不是特别理解**）
>
>   - Typically, the link and load addresses are the same
>
>   - The program headers specify which parts of the ELF object to load into memory and the destination address each should occupy.
>
> 具体可见 program_section.c

- **Exercise 5**
  - 第一条指令：`0x7c2d: ljmp $0xb866, $0x87d32`，之后无法继续执行，回到 BIOS 中（`[f000:e05b]: cmpw $0xffc8, %cs:(%esi)`，即 BIOS 的第二条指令），进入一个循环

    - `ljmp` 的行为取决于 AR 字节$^{[6]}$

      - A jump to a code segment at the same privilege level
      - A task switch

    - ```
      ljmp 的含义是长跳，长跳主要就是重新加载寄存器，32 位保护模式主要体现在段寄存器，具有可以参考段选择子和段描述符的概念，如果不用长跳的话，那么段寄存器不会重新加载，后面的取指结果仍然是老段寄存器中的值，当然保护模式不会生效了。Intel 手册上有讲可见寄存器和不可见寄存器的篇章，可以看一下，其实实模式就是保护模式的一种权限全开放的特殊情况，就是说段寄存器左移相当于右边添加 0，而这添加的 0 可以看做保护模式的 RPL，RPL 为 0 代表 Intel 的 0 环，当然是全权限了。[7]
      ```

- ELF Header 中的 `e_entry` holds the link address of the *entry point* in the program

  - `objdump -f obj/kern/kernel`，显示起始地址为 `0x10000c`

- `boot/main.c` 中的 Boot Loader reads each section of the kernel from disk into memory at the section's *load* address and then jumps to the kernel's entry point.

- **Exercise 6**

  - BIOS 进入 Boot Loader（在 `0x7c00` 设置断点）：全 0

  - Boot Loader 进入内核（在 `0x10000c` 设置断点）

    ````Plain
    0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
    0x100010:	0x34000004	0x2000b812	0x220f0011	0xc0200fd8
    ````

- 另：`0x00100000` 是扩展内存（Extended Memory）的起始地址，紧接 BIOS

### 第三部分：内核

Boot Loader 的 Link/Load Addr：

```
$ objdump -h obj/boot/boot.out

Idx	Name	Size		VMA			LMA
  0	.text	00000186	00007c00	00007c00
...
```

Kernel 的 Link/Load Addr：

```
$ objdump -h obj/kern/kernel

Idx	Name	Size		VMA			LMA
  0	.text	000019e9	f0100000	00100000
...
```

Operating system kernels often like to be linked and run at very high *virtual address*, such as 0xf0100000, in order to leave the lower part of the processor's virtual address space for user programs to use. (The reason for this arrangement will become clearer in the next lab.)

we will use the processor's memory management hardware to map virtual address 0xf0100000 (the link address at which the kernel code *expects* to run) to physical address 0x00100000 (where the boot loader loaded the kernel into physical memory)（0x00100000）是 1MB 的位置

> In fact, in the next lab, we will map the *entire* bottom 256MB of the PC's physical address space, from physical addresses 0x00000000 through 0x0fffffff, to virtual addresses 0xf0000000 through 0xffffffff respectively. You should now see why JOS can only use the first 256MB of physical memory.

CR0 的最高位（第 31 位）是分页开关，为 1 时代表开启分页，并使用 CR3 寄存器，否则禁用分页。$^{[3]}$

Up until `kern/entry.S` sets the `CR0_PG` flag, 内存引用 are treated as physical addresses (strictly speaking, they're linear addresses, but boot/boot.S set up an identity mapping from linear addresses to physical addresses and we're never going to change that). Once `CR0_PG` is set, memory references are virtual addresses that get translated by the virtual memory hardware to physical addresses.

virtual addresses in the range 0xf0000000 through 0xf0400000 to physical addresses 0x00000000 through 0x00400000, as well as virtual addresses 0x00000000 through 0x00400000 to physical addresses 0x00000000 through 0x00400000.（后半句为啥？）Any virtual address that is not in one of these two ranges will cause a hardware exception 

- **Exercise 7**（unsolved）

  - 执行 `mov %eax, %cr0` 之前，0x00100000 处非全 0，0xf0100000 全 0；执行 `mov %eax, %cr0` 之后，0x00100000 未变，0xf0100000 与 0x00100000 相同，说明

  ```Plain
  ...
  .globl entry
  entry:
  		movw	$0x1234, 0x472					; warm boot?
  		movl	$(RELOC(entry_pgdir)), %eax
  		movl	%eax, %cr3
  		movl	%cr0, %eax
  		orl		$(CR0_PE|CR0_PG|CR0_WP), %eax
  		movl	%eax, %cr0
  		mov		$relocated, %eax
  		jmp		*%eax
  relocated:
  		movl	$0x0, %ebp						; Why?
  		movl	$(bootstacktop), %esp
  		call	i386_init
  ...
  ```

  - 在 `kern/entry.S` 中有一个问题：Paging 启用之后，为什么我们依然能够在低 eip 运行？

- **Exercise 8**

  ```C
  num = getuint(&ap, lflag);
  base = 8;
  goto number;
  ```

- Be able to answer the following questions:

  1. Explain the interface between `printf.c` and `console.c`. Specifically, what function does `console.c` export? How is this function used by `printf.c`?

     > 接口：`void cputchar(int c);`
     >
     > ```C
     > void cputchar(char);
     > ```
     >
     > `console.c` 导出：
     >
     > ```C
     > 
     > ```

  2. Explain the following from `console.c`:

     0xA55A 并没有实际的意义，只是用来测试 `cp` 是否为可写入（writable）的地址。

     > This code tests if `cp` is a writable address to determine whether the mode should be CGA or MONO. If writing does not work then we cannot use this part of memory. The thing (garbage) to be written should be arbitrary. It has **no special meaning** as far as I know.
     >
     > Before this, the program saves the value at `cp` in `was` so the garbage won't poison the memory.
     >
     > In the other words, 0xa55a can it be any value, but intuitively you should avoid values like 0 [11]

     ```
     1 if (crt_pos >= CRT_SIZE) {
     2     int i;
     3     memmove(crt_buf, crt_buf + CRT_COLS, \
                   (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
     4     for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
     5         crt_buf[i] = 0x0700 | ' ';
     6     crt_pos -= CRT_COLS;
     7  }
     ```

     **答**：这一片段位于函数 `cga_putc(int c)` 中，这一部分有三个相关的全局变量：

     ```C
     static unsigned addr_6845;
     static uint16_t *crt_buf;
     static uint16_t crt_pos;
     ```

     相关的初始化位于 `cga_init(void)` 中

     `CRT_SIZE` 定义于 `kern/console.h` 中，相关的量为：

     ```C
     #define CRT_ROWS 25
     #define CRT_COLS 80
     #define CRT_SIZE (CRT_ROWS * CRT_COLS)
     ```

     说明 `crt` 应该是指一个终端。

     下面的 `c & 0xff` 是为了保证只有最低字节有效。

     这段代码用于滚屏

  3. For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86.

     Trace the execution of the following code step-by-step:

     ```
     int x = 1, y = 3, z = 4;
     cprintf("x %d, y %x, z %d\n", x, y, z);
     ```

     - In the call to `cprintf()`, to what does `fmt` point? To what does `ap` point?
     - List (in order of execution) each call to `cons_putc`, `va_arg`, and `vcprintf`. For `cons_putc`, list its argument as well. For `va_arg`, list what `ap` points to before and after the call. For `vcprintf` list the values of its two arguments.

     **答**：

     - `fmt` 指向格式化串，`ap` 指向第一个匿名参数，即 `x`

     - ```Plain
       cprintf
         *vcprintf*
           vprintfmt (lib/printfmt.c)
             putch ("x ") (kern/printf.c)
               cputchar (kern/console.c)
                 cons_putc (kern/console.c)
             getint (kern/console.c)
               va_arg
             printnum (kern/console.c)
               putch('1')
             putch(", y ")
             ...
       ```

  4. Run the following code.

     ```
     unsigned int i = 0x00646c72;
     cprintf("H%x Wo%s", 57616, &i);
     ```

     What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise.

     **答**：输出为：

     ```Plain
     He110 World
     ```

     57616$_{10}$ = e110$_{16}$

     ```
     i:
     +------+  <- high
     | 0x00 |
     +------+
     | 0x64 |
     +------+
     | 0x6c |
     +------+
     | 0x72 |
     +------+  <- low
     
     57616:
     +------+  <- high
     | 0x00 |
     +------+
     | 0x00 |
     +------+
     | 0xe1 |
     +------+
     | 0x10 |
     +------+  <- low
     ```

     The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set `i` to in order to yield the same output? Would you need to change `57616` to a different value?

     将 `i` 改为 `0x726c6400`，57616 不需要修改。

     [Here's a description of little- and big-endian](http://www.webopedia.com/TERM/b/big_endian.html) and [a more whimsical description](http://www.networksorcery.com/enp/ien/ien137.txt).

  5. In the following code, what is going to be printed after `'y='`? (note: the answer is not a specific value.) Why does this happen?

     ```
     cprintf("x=%d y=%d", 3);
     ```

     不一定，测试：-267321448，垃圾值。因为 `va_arg()` 直接将 3 上面的（高地址）的 4 字节作为整数，并不会进行检查。

  6. Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change `cprintf` or its interface so that it would still be possible to pass it a variable number of arguments?

     从后向前处理；或者预先将所有的可变参数取出，放入栈中

- **Challenge**

- **Exercise 9**. 

  - 确定内核在何处初始化栈以及栈具体在内存的什么位置

    **答**：内核在 `relocated` 中初始化栈，初始化值为 `$(bootstacktop)`，代码如下：

    ```Assembly
    movl	$0x0, %ebp
    movl	$(bootstacktop), %esp
    ```

    `$(bootstacktop)` 的值为 `$0xf0110000`

  - 内核如何为栈保留空间？

    `inc/memlayout.h` 中定义了 `KSTKSIZE`，为内核栈的大小，值为 8 * `PGSIZE` = 4096B

    （另外还有 `KSTKGAP`，是 kernel stack guard 的大小，也为 4096B），`inc/memlayout.h` 中有详细的图示。

    `NPTENTRIES`：每个页表中的最大页表项数

    `PTSIZE`：page table size，值为 PGSIZE * NPTENTRIES

  - 栈指针（esp）最初指向保留区域的那一端？

    **答**：高地址端（0xf0110000），因为栈是向低地址增长的

- Pushing a value onto the stack involves decreasing the stack pointer and then writing the value to the place the stack pointer points to. Popping a value from the stack involves reading the value the stack pointer points to and then increasing the stack pointer. 

  - 也就是说，`push %ebp` 等价于如下代码：

    ```assembly
    subl	$0x4, %esp
    movl	%ebp, %esp
    ```

    `pop %ebp` 等价于如下代码：

    ```assembly
    movl	%esp, %ebp
    addl	$0x4, %esp
    ```

- In 32-bit mode, the stack can only hold 32-bit values, and `esp` is always divisible by four. 

  - 所以有时涉及到对齐的问题，会将 esp 中的值减去某个值

- Various x86 instructions, such as `call`, are "hard-wired" to use the stack pointer register.

- The `ebp` (base pointer) register, in contrast, is associated with the stack primarily by software **convention**. On entry to a C function, the function's *prologue* code normally saves the previous function's base pointer by pushing it onto the stack, and then copies the current `esp` value into `ebp` for the duration of the function.

  ```Plain
  original:
  +--------+
  |        |  <- ebp
  +--------+          
  |        |          <--+
  /\/\/\/\/\             |
                         +--> current stack frame
  /\/\/\/\/\             |
  |        |  <- esp  <--+
  +--------+
  
  push %ebp:
  +--------+
  |        |  <- ebp
  +--------+          
  |        |          <--+
  /\/\/\/\/\             |
                         +--> last stack frame
  /\/\/\/\/\             |
  |        |          <--+
  +--------+
  |  %ebp  |  <- esp
  +--------+
  
  mov %esp, %ebp:
  +--------+
  |        |
  +--------+          
  |        |          <--+
  /\/\/\/\/\             |
                         +--> last stack frame
  /\/\/\/\/\             |
  |        |          <--+
  +--------+
  |  %ebp  |  <- esp, ebp
  +--------+
  
  sub $0x20, esp:
  +--------+
  |        |
  +--------+          
  |        |          <--+
  /\/\/\/\/\             |
                         +--> last stack frame
  /\/\/\/\/\             |
  |        |          <--+
  +--------+
  |  %ebp  |  <- ebp
  +--------+
  |        |          <--+
  /\/\/\/\/\             |
                         +--> current stack frame
  /\/\/\/\/\             |
  |        |  <- esp  <--+
  +--------+
  ```

- **Exercise 10**

  - `putch`：0xf01009f0

  - `test_backtrace` 的地址为 `0xf0100040`

  - 第一次（x=5）进入 `test_backtrace`

    - `esp` = `0xf010ffdc`
    - `ebp` = `0xf010fff8`

  - 与堆栈相关的指令：

    ```
    0xf0100040:		push	%ebp	; 实际上是保存在上一个栈帧中
    0xf0100043:		push	%esi	; x+1
    0xf0100044:		push	%ebx	; 0xf0111308
    0xf0100056:		push 	%esi	; x（cprintf 的参数）
    0xf010005d:		push	%eax	; 格式化串（cprintf 的参数）
    ; 调用 cprintf
    0xf010009b:		push	%eax	; 下一次递归调用的 x 值
    ; 调用 test_backtrace(x-1)
    ```

    ```Plain
    0xf0100040:		push	%ebp
    0xf0100043:		push	%esi
    0xf0100044:		push	%ebx
    0xf0100053:		sub		$0x8, %esp
    0xf0100056:		push	%esi
    0xf010005d:		push	%eax
    0xf0100063:		add		$0x10, %esp
    0xf0100095:		sub		$0xc, %esp
    0xf010009b:		push	%eax
    ```

    ```Plain
    (gdb) x/64x 0xf010ff10
    0xf010ff18:		0xf010ff38	0xf0100063	0xf0101a20	0x00000000
    				0xf010ff58	0xf010004a	0xf0111308	0x00000001
    0xf010ff38:		0xf010ff58	0xf01000a1	0x00000000	0x00000001
    				0xf010ff78	0xf010004a	0xf0111308	0x00000002
    0xf010ff58:		0xf010ff78	0xf01000a1	0x00000001	0x00000002
    				0xf010ff98	0xf010004a	0xf0111308	0x00000003	
    0xf010ff78:		0xf010ff98	0xf01000a1	0x00000002	0x00000003
    				0xf010ffb8	0xf010004a	0xf0111308	0x00000004
    0xf010ff98:		0xf010ffb8	0xf01000a1	0x00000003	0x00000004
    				0x00000000	0xf010004a	0xf0111308	0x00000005  
    0xf010ffb8:		0xf010ffd8	0xf01000a1	0x00000004	0x00000005
    				0x00000000	0xf010004a	0xf0111308	0x00010094
    ```

    - `0xf010004a` 对应于 `add $0x112be, %ebx`，是打印 “entering ...” 之前的工作
    - `0xf01000a1` 对应于 `add $0x10, %esp`，是递归调用返回后的善后工作
    - 堆栈的最高 32 位（`0xf010003e`）是 `kern/entry.S` 中的 `spin`

  - 为什么？

    ```Assembly
    add	$0x10, %esp
    sub	$0x8, %esp
    ```

- If the function was called with fewer than five arguments, of course, then not all five of these values will be useful. (Why can't the backtrace code detect how many arguments there actually are? How could this limitation be fixed?)

- **Exercise 11**

  - 容易实现，`%ebp` 的值连接成回溯链

- **Exercise 12**

  - `debuginfo_eip` 在 `kern/kdebug.c` 中

    ```
    extern const struct Stab __STAB_BEGIN__[]; // 没有大小！
    extern const struct Stab __STAB_END__[];
    ```

    - `struct Eipdebuginfo` 在 `kern/kdebug.h` 中：

      ```C
      struct Eipdebuginfo {
          const char *eip_file;
          int eip_line;
          
          const char *eip_fn_name;
          
          int eip_fn_namelen;
          uintptr_t eip_fn_addr;
          int eip_fn_narg;
      }
      ```

      - 其中 `uintptr_t` 在 `int/types.h` 中 `typedef uint32_t uintptr_t`

  - look in the file `kern/kernel.ld` for `__STAB_*`

    - 第 27 行和第 29 行

      ```
      .stab : {
          PROVIDE(__STAB_BEGIN__ = .);
          *(.stab);
          PROVIDE(__STAB_END__ = .);
          BYTE(0)
      }
      ```

  - run `objdump -h obj/kern/kernel`

    ```Plain
     			Size		VMA			LMA			File off	Algn
     2	.stab	00003c3d	f01021e8	001021e8	000031e8	2**2
     			CONTENTS, ALLOC, LOAD, READONLY, DATA
    ```

  - run objdump -G obj/kern/kernel

  - run gcc -pipe -nostdinc -O2 -fno-builtin -I. -MD -Wall -Wno-format -DJOS_KERNEL -gstabs -c -S kern/init.c, and look at init.s.

    - `init.s` 中的项有个特点，即每个类型，比如 `int`，只出现一次，并且有相关的取值范围：

      ```Plain
      .stabs	"int:t(0,1)=r(0,1);-2147483648;2147483647;",128,0,0,0
      ```

  - see if the bootloader loads the symbol table in memory as part of loading the kernel binary

    - 据推测，`STAB` 应该代表 symbol table，即符号表

    - 相关的数据结构在 `inc/stab.h` 中：

      ```
      struct Stab {
          uint32_t  n_strx;		// index into string table of name
          uint8_t   n_type;		// type of symbol
          uint8_t   n_other;		// misc info (usually empty)
          uint16_t  n_desc;		// description field
          uintptr_t n_value;		// value of symbol
      }
      ```

    - `inc/stab.h` 上有一句注释：“JOS uses the N_SO, N_SOL, N_FUN and N_SLINE types”，对应的类型分别为主源文件名（0x64），被包含的原文件名（0x84），函数名（0x24）以及文本段行号（0x44），而练习 12 的要求就是以如下形式打印附加的调试信息：`<源文件名>:<行号>: <函数名>+<偏移量>`（这些是从 `struct Eipdebuginf` 中取得的）

# Reference

\[1\] [The wait() System Call](http://www.csl.mtu.edu/cs4411.ck/www/NOTES/process/fork/wait.html)

\[2\] [端口号详细说明](http://bochs.sourceforge.net/techspec/PORTS.LST)

\[3\] [Wikipedia - Control Register](https://en.wikipedia.org/wiki/Control_register)

\[4\] [Wikipedia - ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)

\[5\] [ELF Spec](https://pdos.csail.mit.edu/6.828/2018/readings/elf.pdf)

\[6\] [IA-32 Assembly Language Reference Manual](https://docs.oracle.com/cd/E19455-01/806-3773/instructionset-73/index.html)

\[7\] [关于 ljmp](http://www.voidcn.com/article/p-zwyqqmvp-zw.html)

\[8\] [.bss](https://en.wikipedia.org/wiki/.bss)

\[9\] [x86 Instruction Set Ref](https://c9x.me/x86/)

\[10\] [objdump](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/objdump.html)

\[11\] ['0xA55A' in kern/console.c](https://stackoverflow.com/questions/52866314/what-does-0xa55a-mean-in-cga-init-in-xv6-source-code)