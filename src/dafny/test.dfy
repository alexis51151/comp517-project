class Endokernel {
    method trap(instruction:string) modifies this  {}

    constructor() {}
}

class Process {
    var endokernel: Endokernel;

    constructor(endokernel:Endokernel)
    {
        this.endokernel := endokernel;
    }

    method exec() modifies endokernel {
        this.endokernel.trap("");
    }
}

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