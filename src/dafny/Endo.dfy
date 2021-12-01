include "Capability.dfy"
include "Kernel.dfy"
include "Instructions.dfy"
include "Syscalls.dfy"

class Endokernel {
    var capabilities: map<Capability, Endoprocess>
    var endoprocesses: map<int, Endoprocess>
    var instructionMap: map<Instruction, Capability>
    var syscalls:map<Instruction, Syscall>
    var nextPid:int
    var kernel:Kernel


    method createEndoprocess(capability:Capability, instruction:Instruction) returns (endoprocess:Endoprocess) modifies this 
        ensures capability in capabilities && capabilities[capability] == endoprocess;
    {
        endoprocess := new Endoprocess(this.nextPid, capability.subspace, instruction, this);
        this.capabilities := capabilities[capability := endoprocess];
        this.endoprocesses := this.endoprocesses[this.nextPid := endoprocess];
        this.nextPid := nextPid + 1;
    }

    method trap(instruction:Instruction) modifies this   
            requires instruction.addr >= 0; 
      { 
        if (instruction !in instructionMap){
           print "trap error: no policy for this instruction\n";
        } 
        else {
            var capability:Capability := instructionMap[instruction];
            var endoprocess:Endoprocess;
            if (capability !in capabilities) {
                endoprocess := createEndoprocess(capability, instruction);
            } else {
                endoprocess := capabilities[capability];
            }
            
            print "Trapping instruction ";
            print instruction;
            print " from Process in Endokernel\n";
            endoprocess.exec(instruction);
        }
    }

    method trapEndoprocess(instruction:Instruction, endoId:int) returns (ret:bool) 
        requires instruction.addr >= 0;
        // ensures isWriteInstruction(instruction) && instruction in instructionMap && instructionMap[instruction] in capabilities && endoId in endoprocesses
        // && instruction in syscalls 
        //  ==> ret == checkWrite(instruction.fd, instruction.addr, instruction.size, this.instructionMap, instruction)
    {
        ret := true;
        print "Trapping instruction ";
        print instruction;
        print " from Endoprocess in Endokernel\n";
        // Verifying if endoprocess has correct access rights to execute this instruction
        if (instruction !in instructionMap){
            ret := false;
           print "trapEndoprocess error: no policy for this instruction\n";
        }  
        else {
            var capability := instructionMap[instruction];
            if (capability !in capabilities) {
                ret := false;
                print "trapEndoprocess error: this endoprocess has not the required rights for such instruction\n";
            } else {
                var endoprocessExpected := capabilities[capability];
                if ( endoId !in endoprocesses) {
                    ret := false;
                    print "trapEndoprocess error: unknown endoprocess\n";
                }
                else {
/*                     var endoprocessTrapped := endoprocesses[endoId];
                    if (endoprocessTrapped != endoprocessExpected) {
                        ret := false;
                        print "trapEndoprocess error: unknown endoprocess\n";
                    }
                    else {
 */                        if (instruction in syscalls) {
                            // Enforcing the instruction semantics
                            // var ret := getImplementation(syscalls[instruction], instructionMap, instruction);
                            if (isWriteInstruction(instruction)) {
                                var ret := writeImplementation(instruction.fd, instruction.addr, instruction.size, instructionMap, instruction);
                                if (ret) {
                                    kernel.exec(syscalls[instruction]);
                                } 
                            }
                        }
                        else {
                            ret := false;
                            print "trapEndoprocess error: syscall unknown\n";
                        // }
                    }
                }
            }
        }
    }


    constructor(kernel:Kernel) {
        this.nextPid := 0;
        this.capabilities := map[];
        this.endoprocesses := map[];
        var capability:Capability := new Capability.setCapability((0,0), [0]);
        var instruction:Instruction := Instruction.Write(0,0,2);
        this.instructionMap := map[instruction := capability];
        this.kernel := kernel;
        // Definition of the allowed syscalls and mapping between instructions and syscalls
        this.syscalls := map[Instruction.Write(0,0,2) := Syscall.Write(0,0,2),
                             Instruction.Read(0) := Syscall.Read(0)];
    }
}

class Endoprocess {
    var id:int;
    var memorySpace:(int, int)
    var instructions: Instruction
    var endokernel:Endokernel;

    constructor(id:int, memorySpace:(int, int), instructions:Instruction, endokernel:Endokernel) {
        this.id := id;
        this.memorySpace := memorySpace;
        this.instructions := instructions;
        this.endokernel := endokernel;
    }

    method exec(instruction:Instruction)  
        requires instruction.addr >= 0;
    {
        print "Executing instruction ";
        print instruction;
        print " in Endoprocess\n";
        var ret := endokernel.trapEndoprocess(instruction, this.id);
    }
}