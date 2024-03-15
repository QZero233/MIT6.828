#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

// static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


extern char trap_divide_zero_handler[];
extern char trap_debug_handler[];
extern char trap_nmi_handler[];
extern char trap_brkpt_handler[];
extern char trap_oflow_handler[];
extern char trap_bound_handler[];
extern char trap_illop_handler[];
extern char trap_device_handler[];
extern char trap_dblflt_handler[];
extern char trap_tss_handler[];
extern char trap_tsegnp_handler[];
extern char trap_stack_handler[];
extern char trap_gpflt_handler[];
extern char trap_pgflt_handler[];
extern char trap_fperr_handler[];
extern char trap_align_handler[];
extern char trap_mchk_handler[];
extern char trap_smiderr_handler[];

extern char trap_syscall_handler[];

void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE],true,GD_KT,trap_divide_zero_handler,0);
	SETGATE(idt[T_DEBUG],true,GD_KT,trap_debug_handler,0);
	SETGATE(idt[T_NMI],true,GD_KT,trap_nmi_handler,0);
	SETGATE(idt[T_BRKPT],true,GD_KT,trap_brkpt_handler,3);
	SETGATE(idt[T_OFLOW],true,GD_KT,trap_oflow_handler,0);
	SETGATE(idt[T_BOUND],true,GD_KT,trap_bound_handler,0);
	SETGATE(idt[T_ILLOP],true,GD_KT,trap_illop_handler,0);
	SETGATE(idt[T_DEVICE],true,GD_KT,trap_device_handler,0);
	SETGATE(idt[T_DBLFLT],true,GD_KT,trap_dblflt_handler,0);
	SETGATE(idt[T_TSS],true,GD_KT,trap_tss_handler,0);
	SETGATE(idt[T_SEGNP],true,GD_KT,trap_tsegnp_handler,0);
	SETGATE(idt[T_STACK],true,GD_KT,trap_stack_handler,0);
	SETGATE(idt[T_GPFLT],true,GD_KT,trap_gpflt_handler,0);
	SETGATE(idt[T_PGFLT],true,GD_KT,trap_pgflt_handler,0);
	SETGATE(idt[T_FPERR],true,GD_KT,trap_fperr_handler,0);
	SETGATE(idt[T_ALIGN],true,GD_KT,trap_align_handler,0);
	SETGATE(idt[T_MCHK],true,GD_KT,trap_mchk_handler,0);
	SETGATE(idt[T_SIMDERR],true,GD_KT,trap_smiderr_handler,0);

	SETGATE(idt[T_SYSCALL],true,GD_KT,trap_syscall_handler,3);

	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// The example code here sets up the Task State Segment (TSS) and
	// the TSS descriptor for CPU 0. But it is incorrect if we are
	// running on other CPUs because each CPU has its own kernel stack.
	// Fix the code so that it works for all CPUs.
	//
	// Hints:
	//   - The macro "thiscpu" always refers to the current CPU's
	//     struct CpuInfo;
	//   - The ID of the current CPU is given by cpunum() or
	//     thiscpu->cpu_id;
	//   - Use "thiscpu->cpu_ts" as the TSS for the current CPU,
	//     rather than the global "ts" variable;
	//   - Use gdt[(GD_TSS0 >> 3) + i] for CPU i's TSS descriptor;
	//   - You mapped the per-CPU kernel stacks in mem_init_mp()
	//   - Initialize cpu_ts.ts_iomb to prevent unauthorized environments
	//     from doing IO (0 is not the correct value!)
	//
	// ltr sets a 'busy' flag in the TSS selector, so if you
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	struct Taskstate* this_ts=&thiscpu->cpu_ts;

	this_ts->ts_esp0=(uintptr_t)percpu_kstacks[cpunum()];
	this_ts->ts_ss0=GD_KD;
	this_ts->ts_iomb=sizeof(struct Taskstate);

	// ts.ts_esp0 = KSTACKTOP;
	// ts.ts_ss0 = GD_KD;
	// ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (this_ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSSi(cpunum()));

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == T_PGFLT){
		page_fault_handler(tf);
	}else if(tf->tf_trapno == T_BRKPT){
		monitor(tf);
	}else if(tf->tf_trapno == T_SYSCALL){
		uint32_t syscall_num,p1,p2,p3,p4,p5;

		// asm volatile (
		// 	"movl %%eax, %0\n\t"
		// 	"movl %%edx, %1\n\t"
		// 	"movl %%ecx, %2\n\t"
		// 	"movl %%ebx, %3\n\t"
		// 	"movl %%edi, %4\n\t"
		// 	"movl %%esi, %5\n\t"
		// 	:"=r"(syscall_num),
		// 	"=r"(p1),
		// 	"=r"(p2),
		// 	"=r"(p3),
		// 	"=r"(p4),
		// 	"=r"(p5)
		// );

		syscall_num=tf->tf_regs.reg_eax;
		p1=tf->tf_regs.reg_edx;
		p2=tf->tf_regs.reg_ecx;
		p3=tf->tf_regs.reg_ebx;
		p4=tf->tf_regs.reg_edi;
		p5=tf->tf_regs.reg_esi;

		// cprintf("1: %d 2:%d 3:%d 4:%d\n",syscall_num,p1,p2,p3);

		int32_t ret=syscall(syscall_num,p1,p2,p3,p4,p5);

		// asm volatile (
		// 	"movl %0, %%eax"
		// 	:
		// 	:"r"(ret)
		// 	:"%eax"
		// );

		tf->tf_regs.reg_eax=ret;
		return;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
	else
		sched_yield();
}

void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0){
		//Kernel page fault
		panic("Kernel page fault when addressing %x\n",fault_va);
	}

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// It is convenient for our code which returns from a page fault
	// (lib/pfentry.S) to have one word of scratch space at the top of the
	// trap-time stack; it allows us to more easily restore the eip/esp. In
	// the non-recursive case, we don't have to worry about this because
	// the top of the regular user stack is free.  In the recursive case,
	// this means we have to leave an extra word between the current top of
	// the exception stack and the new stack frame because the exception
	// stack _is_ the trap-time stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	//Assert that exception stack exists and writtable
	user_mem_assert(curenv,(void*)(UXSTACKTOP-PGSIZE),PGSIZE,PTE_W);

	//Check if exception stack overflows
	if(tf->tf_esp < UXSTACKTOP-PGSIZE && tf->tf_esp >= USTACKTOP){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	}

	if(curenv->env_pgfault_upcall != NULL){
		//Check if fault from exception stack

		struct UTrapframe* frame;
		if(curenv->env_tf.tf_esp < USTACKTOP){
			//Normal stack
			frame=(struct UTrapframe*)(UXSTACKTOP-sizeof(struct UTrapframe));
		}else{
			//Exception stack
			//Leave a blank word
			frame=(struct UTrapframe*)(tf->tf_esp-sizeof(struct UTrapframe)-sizeof(uintptr_t));
		}

		//Set up exception stack frame
		frame->utf_fault_va=fault_va;
		frame->utf_err=tf->tf_err;
		frame->utf_regs=tf->tf_regs;
		frame->utf_eip=tf->tf_eip;
		frame->utf_eflags=tf->tf_eflags;
		frame->utf_esp=tf->tf_esp;

		//Set the new esp and eip
		tf->tf_esp=(uintptr_t)frame;
		tf->tf_eip=(uintptr_t)curenv->env_pgfault_upcall;

		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

