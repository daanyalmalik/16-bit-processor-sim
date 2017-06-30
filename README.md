# 16-bit-processor-simulator
The processor has 5 stages for instruction cycle
-Fetch
-Decode
-Load
-Execute 
-Store

	At the beginning of the program, the first state it Fetch; this state is to get the instruction from hard disk and send it to the instruction register (IR). The program Counter (PC) is also incremented at this stage. In the second state, Load, the instruction is decoded by the IR and the addresses of the operands are sent to the relevant register. On the next Execute state, the operands are loaded into the ALU; a signal is sent to enable the ALU for a specific operation and another signal may be sent to enable RAM if we have to write to or read from it. At the Store state, all operations are stored in RAM. 

	Hard disk and RAM cannot be declared by using variables/ arrays, these modules should be separate files, and file handling will involve for read/write operations. 

