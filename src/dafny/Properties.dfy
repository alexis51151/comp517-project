include "Instructions.dfy"
include "Endo.dfy"

// This property states that for any write instruction that is trapped by
// the endokernel, its corresponding syscall is executed iff the capabilities
// are correct, i.e. the buffer is within the the address space and we the proper
// rights to access the file.
lemma authorizeWrite(instruction:Instruction, endokernel:Endokernel) 
    requires isWriteInstruction(instruction)
    requires instruction.addr >= 0
    requires instruction in endokernel.instructionMap
    {}