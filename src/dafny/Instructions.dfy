datatype Instruction = 
    Write(fd:int, addr:int, size:int) 
    | Read(addr:int)



function method isWriteInstruction(i:Instruction) : bool {
    match i 
        case Write(fd, addr, size) => true
        case Read(addr) => false
}
