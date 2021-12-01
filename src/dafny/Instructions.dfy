datatype Instruction = 
    Write(fd:int, addr:int, size:int) 
    | Read(fd:int, addr:int, size:int) 

