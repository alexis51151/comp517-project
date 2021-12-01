include "Endo.dfy"
include "Instructions.dfy"

class Thread {
    var tid:int;
    var pc:int;
    var sp:int;
    var instructions:seq<Instruction>;
    var endokernel:Endokernel;

    constructor (tid:int, pc:int, sp:int, instructions:seq<Instruction>, endokernel:Endokernel)
    ensures this.endokernel == old(endokernel)
     {
        this.tid := tid;
        this.pc := pc;
        this.sp := sp;
        this.instructions := instructions;
        this.endokernel := endokernel;
    }

    method exec() modifies this, endokernel 
    {
        if (0 <= pc < |instructions| && instructions[pc].addr >= 0)
        {
            print "Executing instruction ";
            print instructions[pc];
            print " in Thread\n";
            this.endokernel.trap(instructions[pc]);
            pc := pc + 1;
        }
    }

}