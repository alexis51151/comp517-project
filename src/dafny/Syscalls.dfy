include "Capability.dfy"
include "Instructions.dfy"

datatype Syscall = 
    Write(fd:int, addr:int, size:int) 
    | Read(fd:int, addr:int, size:int)

method getImplementation(sc:Syscall, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool) 
        ensures isWriteSyscall(sc) ==> ret == writeSpecification(sc.fd, sc.addr, sc.size, instructionMap, instruction);
        ensures isReadSyscall(sc) ==> ret == readSpecification(sc.fd, sc.addr, sc.size, instructionMap, instruction);
    {
    match sc
        case Write(fd, addr, size) => ret := writeImplementation(fd, addr, size, instructionMap, instruction);
        case Read(fd, addr, size) => ret := readImplementation(fd, addr, size, instructionMap, instruction);
    }

predicate isWriteSyscall(sc:Syscall) {
    match sc 
        case Write(fd, addr, size) => true
        case _ => false
}

predicate isReadSyscall(sc:Syscall) {
    match sc 
        case Read(fd, addr, size) => true
        case _ => false
}

method writeImplementation(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool)  
    ensures ret == writeSpecification(fd, addr, size, instructionMap, instruction)
    {
        ret := true;
        // Check if we can access the buffer memory
        if (size < 0 || addr < 0) {
            ret := false;
        }
        else if (instruction !in instructionMap) {
            ret := false;
        } 
        else {
            var i := (set i | addr <= i <= addr + size);
            if !(i * instructionMap[instruction].subspace == i) {
                ret := false;
            } 
            // Check if we can access the file to write to
            else if (fd !in instructionMap[instruction].files) {
                ret := false;
            }
        }
    }

method readImplementation(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool)  
    ensures ret == readSpecification(fd, addr, size, instructionMap, instruction)
    {
        ret := true;
        // Check if we can access the buffer memory
        if (size < 0 || addr < 0) {
            ret := false;
        }
        else if (instruction !in instructionMap) {
            ret := false;
        } 
        else {
            var i := (set i | addr <= i <= addr + size);
            if !(i * instructionMap[instruction].subspace == i) {
                ret := false;
            } 
            // Check if we can access the file to write to
            else if (fd !in instructionMap[instruction].files) {
                ret := false;
            }
        }
    }

function checkRangeSet(low:int, high:int, S:set<int>) : bool {
    (set i | low <= i <= high) * S == (set i | low <= i <= high)
}

function writeSpecification(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool 
    reads *
{
    if (size < 0 || addr < 0) then false 
    else if instruction !in instructionMap then false
    else if !checkRangeSet(addr, addr+size, instructionMap[instruction].subspace) then false
    else if fd !in instructionMap[instruction].files then false
    else true
}

function readSpecification(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool 
    reads *
{
    if (size < 0 || addr < 0) then false 
    else if instruction !in instructionMap then false
    else if !checkRangeSet(addr, addr+size, instructionMap[instruction].subspace) then false
    else if fd !in instructionMap[instruction].files then false
    else true
}



// method writeImplementation(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool)  
//     requires addr >= 0
//     // ensures ret == writeSpecification(fd, addr, size, instructionMap, instruction) 
// {
//     var r:bool := writeCheck(fd, addr, size, instructionMap, instruction);
//     ret := true;
//     ret := (ret && r);
//     var i:int := size;
//     while (i > 0) 
//         invariant i <= size
//         invariant r == writeCheck(fd, addr, i, instructionMap, instruction)
//         // invariant ret == (ret && r)
//         invariant ret == r && writeSpecification(fd, addr, i, instructionMap, instruction)
//         decreases i
//     {
//         i := i - 1;
//         if (i == 0) {
//             r := true;
//         } 
//         else {
//             r := writeCheck(fd, addr, i, instructionMap, instruction);
//         }
//         ret := (ret && r);
//     }
// }


// function method writeSpecification(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool 
//     reads *
//     requires addr >= 0
//     decreases size;
// {
//     if (size == 0) then true
//     else writeCheck(fd, addr, size, instructionMap, instruction) && writeSpecification(fd, addr, size-1, instructionMap, instruction) 
// }

// function method writeCheck(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool 
//     reads *
//     requires addr >= 0
// {
//     if (size == 0) then true
//     else if (size < 0) then false 
//     else if instruction !in instructionMap || addr+size !in instructionMap[instruction].subspace then false  
//     else true
// }



/* method writeSemantics(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool)
    requires addr >= 0;
 {
    ret := true;
    // Check if we can access the buffer memory
    if (size < 0) {
        ret := false;
    }
    else if (size > 0) {
        for i := addr to (addr + size) {
            if (i !in instructionMap[instruction].subspace) {
                ret := false;
            }
        }
    }
    // Check if we can access the file
    if (instruction !in instructionMap || fd !in instructionMap[instruction].files) {
        ret := false;
    }
 }
 



// function method checkWrite(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool
//     reads *;
//     requires addr >= 0;
//  {
//     // Check if we can access the buffer memory
//     if instruction !in instructionMap then false
//     else if (size < 0) then false
//     else if (size > 0) then checkWriteSubspace(instruction, instructionMap, addr + size, addr) && fd in instructionMap[instruction].files
//     else false
//  }


// function method checkWriteSubspace(instruction:Instruction, instructionMap:map<Instruction, Capability>, curAddr:int, minAddr:int) : bool 
//     requires minAddr >= 0;
//     requires instruction in instructionMap
//     reads instructionMap[instruction]
// {
//     if (curAddr < minAddr) then true
//     else if (curAddr !in instructionMap[instruction].subspace) then false
//     else checkWriteSubspace(instruction, instructionMap, curAddr - 1, minAddr)
// }

