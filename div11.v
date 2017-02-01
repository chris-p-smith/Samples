// Circuit consists of 5 edge-triggered flip flops, numbered 0 through 4. 
// 
//Vcc---|
//      |        Q0         Q1         Q2        Q3
//      |_>[   ]---|  [   ]---|  [   ]---|  [   ]--->{}
//         [FF0]   |  [FF1]   |  [FF2]   |  [FF3]
//CLK----->[___]   |->[___]   |->[___]   |->[___]
//           o    {}    o    {}    o    {}    o   {~Q0&Q1&Q2&~Q3 = W1}
//           |__________|__________|__________|_________
//                                                      |
//                                 {Q4||W1}->[   ]->Q4  |
//                                           [FF4]      |
//                                  CLK----->[   ]------|->CLK_BY_11       
//                                             o
//                                     RST-----|

`timescale 1us / 1ns

module div11(q0,q1,q2,q3,q4,clk,rst,clk_by_11);
input clk,rst; 
output clk_by_11,q0,q1,q2,q3,q4;
reg q0,q1,q2,q3,q4;
wire w1,w2;  

assign clk_by_11 = ~q4;

always @ (posedge clk or negedge clk_by_11)
    if (~clk_by_11) q0 <= 1; //The output of clk/11 serves as the high-reset for FF1-4
    else q0 <= ~q0; //1st FF flops when clk's posedge is triggered

always @ (posedge q0 or negedge clk_by_11)        
    if (~clk_by_11) q1 <= 1;
    else q1 <= ~q1; //2nd FF flops when 1FF flops
    
always @ (posedge q1 or negedge clk_by_11)
    if (~clk_by_11) q2 <= 1;    
    else q2 <= ~q2; //3rd FF flops when 2FF flops
    
always @ (posedge q2 or negedge clk_by_11)
    if (~clk_by_11) q3 <= 1;    
    else q3 <= ~q3; //4th FF flops when 3FF flops

    assign w1 = (~q0&q1&q2&~q3); //AND gate that triggers with 0110
    assign w2 = ((w1|q4)); //The trigger of 5FF is set when the AND gate or the output coincide with the clk

always @ (posedge clk or negedge rst)
    if (~rst) q4<=1; //rst=0 drives 5th FF to 1
    else if (w2&clk) q4 <= ~q4;

endmodule

