class Endokernel {
    constructor() {}
}

class Process {
    var endokernel: Endokernel;

    constructor(endokernel:Endokernel)
    {
        this.endokernel := endokernel;
    }

    method exec() modifies this, endokernel {
        // Uncommenting the following line can't eliminate the error on Line 25
        // this.endokernel := new Endokernel();
    }
}

class Test {

    method testProcess1() {
        // Example of a simple execution of the Endokernel abstraction
        var endokernel:Endokernel := new Endokernel();
        var p:Process := new Process(endokernel);
        p.exec(); // ERROR: call may violate context's modifies clause 
                  //   Execution trace:
                  //       (0,0): anon0
    }

    method Main()  {
        testProcess1();
        //testProcess2();
    }
}