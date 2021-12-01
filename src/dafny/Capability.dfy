

class Capability {
    var subspace: set<int>
    var stack: seq<int>
    var files: seq<int>
    var entries: seq<string>

    constructor () {
        subspace := {};
        stack := [];
        files := [];
        entries := [];
    }

    constructor setCapability (subspace:set<int>, files:seq<int>) {
        this.subspace := subspace;
        this.files := files;
    }

}