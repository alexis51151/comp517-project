
class Endokernel {
    var capabilities: map<string, Endoprocess>
    var endoprocesses: map<int, Endoprocess>
    var instructionMap: map<string, string>
    var nextPid:int;

    method createEndoprocess(capability:string, instruction:string) returns (endoprocess:Endoprocess) modifies this {
        endoprocess := new Endoprocess();
        this.capabilities := capabilities[capability := endoprocess];
        this.endoprocesses := this.endoprocesses[this.nextPid := endoprocess];
        this.nextPid := nextPid + 1;
    }

    method trap(instruction:string) modifies this  {
        if (instruction !in instructionMap){
           print "trap error: no policy for this instruction\n";
        } 
        else {
            var capability:string := instructionMap[instruction];
            var endoprocess:Endoprocess;
            if (capability !in capabilities) {
                endoprocess := createEndoprocess(capability, instruction);
            } else {
                endoprocess := capabilities[capability];
            }
            print "Trapping instruction " + instruction + " from Process in Endokernel\n";
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
                    }
                }
            }
        }
    }


    constructor() {
        this.nextPid := 0;
        this.capabilities := map[];
        this.endoprocesses := map[];
        var capability:string := "";
        this.instructionMap := map["write(0,a)" := capability];
    }
}

class Endoprocess {
    var id:int;
    constructor(){
        this.id := 1;
    }
}