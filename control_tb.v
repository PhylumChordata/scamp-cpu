/* Control logic testbench */
`include "control.v"

module test;
    reg [15:0] uinstr;

    parameter vEO = 16'h8000;
    parameter vEX = 16'h4000;
    parameter vNX = 16'h2000;
    parameter vEY = 16'h1000;
    parameter vNY = 16'h0800;
    parameter vF  = 16'h0400;
    parameter vNO = 16'h0200;
    parameter vJC = 16'h0020;
    parameter vJZ = 16'h0010;
    parameter vJGT = 16'h0008;
    parameter vJLT = 16'h0004;

    parameter vPO = 0;
    parameter vIOH = vEY;
    parameter vIOL = vNX;
    parameter vRO = vNX|vEY;
    parameter vXO = vEX;
    parameter vYO = vEX|vEY;
    parameter vDO = vEX|vEY;
    parameter vRT = vNY;
    parameter vPP = vF;

    parameter vMI = 16'h0040;
    parameter vII = 16'h0080;
    parameter vRI = vMI|vII;
    parameter vXI = 16'h0100;
    parameter vYI = vXI|vMI;
    parameter vDI = vXI|vII;

    wire [5:0] ALU_flags;

    Control control (uinstr, EO, PO, IOH, IOL, RO, XO, YO, DO, RT, PP, MI, II, RI, XI, YI, DI, JC, JZ, JGT, JLT, ALU_flags);

    initial begin
        uinstr = vIOH | vJC;
        #1 if (!IOH || !JC) $display("Bad: !IOH || !JC");

        uinstr = vPO | vMI;
        #1 if (!PO || !MI) $display("Bad: !PO || !MI");

        uinstr = vRO | vMI;
        #1 if (!RO || !MI) $display("Bad: !RO || !MI");

        uinstr = vRO | vYI | vPP;
        #1 if (!RO || !YI || !PP) $display("Bad: !RO || !YI || !PP");

        uinstr = vYO | vMI;
        #1 if (!YO || !MI) $display("Bad: !YO || !MI");

        uinstr = vEO | (vNX | vEY | vNY | vF | vNO) | vMI;
        #1 if (!EO || !MI || ALU_flags !== 31) $display("Bad: !EO || !MI || ALU_flags != 31,",ALU_flags);

        uinstr = vEO;
        #1 if (PO || IOH || IOL || RO || XO || YO || DO) $display("Bad: output flags set when not wanted");

        uinstr = vPO;
        #1 if (!PO || IOH || IOL || RO || XO || YO || DO) $display("Bad: output flags set wrong");

        uinstr = vDI;
        #1 if (!DI || MI || II || RI || XI || YI) $display("Bad: input flags set wrong");

        uinstr = vEO;
        #1 if (RT || PP || JC || JZ || JGT || JLT) $display("Bad: other flags set wrong");

        uinstr = vPP;
        #1 if (!PP) $display("P+ doesn't work");

        uinstr = vRT;
        #1 if (!RT) $display("RT doesn't work");
    end
endmodule
