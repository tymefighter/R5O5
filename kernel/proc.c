#include "declarations.h"
#include "functions.h"

#define EPS 0

extern void ret_to_user(void);                      // Returns to user modec
extern void uservec(void);                          // Uservec in uservec.S

void proc_init() {
    for(int i = 0;i < NumberOfProcesses;i++)
        pd[i].slotAllocated = 0;
}

int SelectProcessToRun() {
    static int next_proc = NumberOfProcesses;
    
    if(current_process > 0
        && pd[current_process].slotAllocated
        && pd[current_process].timeLeft > 0)
        return current_process;
    
    for(int i = 0;i < NumberOfProcesses;i++) {
        next_proc ++;
        if(next_proc >= NumberOfProcesses)
            next_proc = 0;
        
        if(pd[next_proc].slotAllocated
            && (pd[next_proc].state == Created || pd[next_proc].state == Ready)) {
            pd[next_proc].state = Running;
            pd[next_proc].timeLeft = TimeQuantum;
            return next_proc;
        }
    }
    
    return -1;
}

void RunProcess() {
    if(current_process < 0) {
        panic("RunProcess");                        // for now we panic !
        intr_all_on();
        asm volatile ("wfi");
    }

    w_mstatus(r_mstatus() & (~(3 << 11)));          // setting previous privilege to user mode
                                                    // we have to set timer and software ints on, and set timer value

    w_mtvec((uint64)uservec);                       // Change vector from kernelvec to uservec
    *(uint64 *)CLINT_MTIME = 0ll;
    *(uint64 *)CLINT_MTIMECMP(0) = pd[current_process].timeLeft + EPS;
    intr_software_on();
    intr_timer_on();
    ret_to_user();
}

void dispatcher(void) {
    current_process = SelectProcessToRun();
    RunProcess();
}

void timerInterruptHandler(void) {
    if((r_mstatus() & (3 << 11)) != 0)              // if timer interrupt came in any other mode than user mode, then panic
        panic("timerInterruptHandler");

    pd[current_process].timeLeft = 0;
    pd[current_process].state = Ready;

    dispatcher();
}