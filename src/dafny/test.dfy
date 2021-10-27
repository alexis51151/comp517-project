include "Process.dfy"
include "Endo.dfy"
include "Kernel.dfy"

class Test {

    method testProcess1() {
        // Example of a simple execution of the Endokernel abstraction
        var kernel:Kernel := new Kernel();
        var endokernel:Endokernel := new Endokernel(kernel);
        var p:Process := new Process(endokernel);
        p.exec();
    }

    method Main()  {
        testProcess1();
        //testProcess2();
    }
}