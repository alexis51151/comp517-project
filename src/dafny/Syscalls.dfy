include "Capability.dfy"
include "Instructions.dfy"

datatype Syscall = 
    Write(fd:int, addr:int, size:int) 
    | Read(addr:int)

method getImplementation(sc:Syscall, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool) 
    {
    match sc
        case Write(fd, addr, size) => 
        if (addr >= 0) {
            ret := writeImplementation(fd, addr, size, instructionMap, instruction);
        } else {
            ret := false;
        }
        case Read(addr) => ret := false; 
    }

/* function method getSemantics(sc:Syscall, instructionMap:map<Instruction, Capability>, instruction:Instruction) : bool 
    reads *;
{
    match sc
        case Write(fd, addr, size) => if addr > 0 then checkWrite(fd, addr, size, instructionMap, instruction) else false
        case Read(addr) => false
}

 */
predicate isWriteSyscall(sc:Syscall) {
    match sc 
        case Write(fd, addr, size) => true
        case Read(addr) => false
}

method writeImplementation(fd:int, addr:int, size:int, instructionMap:map<Instruction, Capability>, instruction:Instruction) returns (ret:bool)  
    requires addr >= 0
    {
        ret := true;
        // Check if we can access the buffer memory
        if (size < 0) {
            ret := false;
        }
        if (instruction in instructionMap) {
            var low := instructionMap[instruction].subspace.0;
            var high := instructionMap[instruction].subspace.1;
            if !(addr >= low && addr + size <= high ) {
                ret := false;
            }
        }
        // Check if we can access the file
        if (instruction !in instructionMap || fd !in instructionMap[instruction].files) {
            ret := false;
        }
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

