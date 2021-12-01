include "Endo.dfy"
include "Thread.dfy"

class Process {
    var pid:int;
    var memorySpace: set<int>; 
    var endokernel: Endokernel;
    var thread: Thread;

    constructor(pid:int, memorySpace:set<int>, endokernel_:Endokernel, thread_:Thread)
    ensures this.endokernel == old(endokernel_);
    ensures this.thread == old(thread_);
    {
        this.pid := pid;
        this.memorySpace := memorySpace;
        this.endokernel := endokernel_;
        this.thread := thread_;
    }

    method exec() modifies this, thread, thread.endokernel {
        thread.exec();
    }

}
