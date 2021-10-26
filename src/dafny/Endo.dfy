include "Capability.dfy"
include "Kernel.dfy"

class Endokernel {
    var capabilities: map<Capability, Endoprocess>
    var endoprocesses: map<int, Endoprocess>
    var instructionMap: map<string, Capability>
    var nextPid:int;
    var kernel:Kernel;

    method createEndoprocess(capability:Capability, instruction:string) returns (endoprocess:Endoprocess) modifies this {
        endoprocess := new Endoprocess(this.nextPid, capability.subspace, instruction, this);
        this.capabilities := capabilities[capability := endoprocess];
        this.endoprocesses := this.endoprocesses[this.nextPid := endoprocess];
        this.nextPid := nextPid + 1;
    }

    method trap(instruction:string) modifies this  {
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
            print "Trapping instruction " + instruction + " from Process in Endokernel\n";
            endoprocess.exec(instruction);
        }
    }

    method trapEndoprocess(instruction:string, endoId:int) {
        // Verifying if endoprocess has correct access rights to execute this instruction
        if (instruction !in instructionMap){
           print "trapEndoprocess error: no policy for this instruction\n";
        }  
        else {
            var capability := instructionMap[instruction];
            if (capability !in capabilities) {
                print "trapEndoprocess error: this endoprocess has not the required rights for such instruction\n";
            } else {
                var endoprocessExpected := capabilities[capability];
                if ( endoId !in endoprocesses) {
                    print "trapEndoprocess error: unknown endoprocess\n";
                }
                else {
                    var endoprocessTrapped := endoprocesses[endoId];
                    if (endoprocessTrapped != endoprocessExpected) {
                        print "trapEndoprocess error: unknown endoprocess\n";
                    }
                    else {
                        print "Trapping back instruction " + instruction + " from Endoprocess in Endokernel\n";
                        kernel.exec(instruction);
                    }
                }
            }
        }
    }


    constructor(kernel:Kernel) {
        this.nextPid := 0;
        this.capabilities := map[];
        this.endoprocesses := map[];
        var capability:Capability := new Capability();
        this.instructionMap := map["write(0,a)" := capability];
        this.kernel := kernel;
    }
}

class Endoprocess {
    var id:int;
    var memorySpace:seq<int>
    var instructions: string
    var endokernel:Endokernel;

    constructor(id:int, memorySpace:seq<int>, instructions:string, endokernel:Endokernel) {
        this.id := id;
        this.memorySpace := memorySpace;
        this.instructions := instructions;
        this.endokernel := endokernel;
    }

    method exec(instruction:string)  {
        print "Executing instruction " + instruction + " in Endoprocess\n";
        endokernel.trapEndoprocess(instruction, this.id);
    }
}