include "Process.dfy"
include "Endo.dfy"
include "Kernel.dfy"
include "Thread.dfy"
include "Instructions.dfy"

class Init {

    method initProcess1() {
        // Example of a simple execution of the Endokernel abstraction
        var kernel:Kernel := new Kernel();
        var endokernel:Endokernel := new Endokernel(kernel);
        var instruction:Instruction := Instruction.Write(0, 0, 2);
        var thread:Thread := new Thread(0, 0, 0, [instruction], endokernel);
        var p:Process := new Process(0, (0,3), endokernel, thread);
        p.exec();
    }

/*     method initProcess2() {
        // Example of a simple execution of the Endokernel abstraction that is not handled
        var kernel:Kernel := new Kernel();
        var endokernel:Endokernel := new Endokernel(kernel);
        var instruction:string := "read(0,a)";
        var thread:Thread := new Thread(0, 0, 0, [instruction], endokernel);
        var p:Process := new Process(0, [0,1,2,3], endokernel, thread);
    }
 */

    method Main()  {
        initProcess1();
        //initProcess2();
    }
}