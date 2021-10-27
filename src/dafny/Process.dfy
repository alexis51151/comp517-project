include "Endo.dfy"

class Process {
    var endokernel: Endokernel;

    constructor(endokernel:Endokernel)
    {
        this.endokernel := endokernel;
    }

    method exec() modifies this, endokernel {
    }
}
