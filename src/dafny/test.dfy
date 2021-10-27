include "Process.dfy"
include "Endo.dfy"

class Test {

    method testProcess1() {
        // Example of a simple execution of the Endokernel abstraction
        var endokernel:Endokernel := new Endokernel();
        var p:Process := new Process(endokernel);
        p.exec();
    }

    method Main()  {
        testProcess1();
        //testProcess2();
    }
}
