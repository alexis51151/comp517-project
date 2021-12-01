

class Capability {
    var subspace: (int,int)
    var stack: seq<int>
    var files: seq<int>
    var entries: seq<string>

    constructor () {
        subspace := (0,0);
        stack := [];
        files := [];
        entries := [];
    }

    constructor setCapability (subspace:(int,int), files:seq<int>) {
        this.subspace := subspace;
        this.files := files;
    }

}