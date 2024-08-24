Here,this a Router 1X3 design module where all the logic blocks involved in the proccess are designed like synchroniser,fifo,controller and fsm.The router follows 
IP Network layer 3 protocol which is packet based protocol.The pakcet consist of header,payload and parity.The header consist of 8-bit in which [7:2] of header 
represent the payload length and [2:0] of header shows the address into which the packt should be routed.The payload data length is according the length in header[7:2] and
parity is to verify the data recieved is exact or corrupted one.
