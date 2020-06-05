//--------------------------------------------------
// Top Module : Digilent Basys 3               
// BeeInvaders Tutorial 4 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

module Top(
    input wire CLK,         // Onboard clock 100MHz : INPUT Pin W5
    input wire PS2Clk,
    input wire PS2Data,
    input wire btnC,       // Reset button / Centre Button : INPUT Pin U18
    output wire HSYNC,      // VGA horizontal sync : OUTPUT Pin P19
    output wire VSYNC,      // VGA vertical sync : OUTPUT Pin R19
    output reg [3:0] RED,   // 4-bit VGA Red : OUTPUT Pin G19, Pin H19, Pin J19, Pin N19
    output reg [3:0] GREEN, // 4-bit VGA Green : OUTPUT Pin J17, Pin H17, Pin G17, Pin D17
    output reg [3:0] BLUE,  // 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18/ 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18
    input btnR,             // Right button : INPUT Pin T17
    input btnL,              // Left button : INPUT Pin W19
    input btnU,
    input btnD
    );
    
    reg [3:0] state = 0;
    wire rst = 0;       // Setup Reset button

    // instantiate vga640x480 code
    wire [9:0] x;           // pixel x position: 10-bit value: 0-1023 : only need 800
    wire [9:0] y;           // pixel y position: 10-bit value: 0-1023 : only need 525
    wire active;            // high during active pixel drawing
    wire PixCLK;            // 25MHz pixel clock
    vga800x600 display (.i_clk(CLK),.i_rst(rst),.o_hsync(HSYNC), 
                        .o_vsync(VSYNC),.o_x(x),.o_y(y),.o_active(active),
                        .pix_clk(PixCLK));
                        
    wire [3:0] bulletRED;
    wire [3:0] bulletGREEN;
    wire [3:0] bulletBLUE;
    BulletScene bulletScene (.ix(x), .iy(y), .iactive(active),
        .ibtnL(btnL), .ibtnR(btnR), .ibtnU(btnU), .ibtnD(btnD),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
        .oRED(bulletRED), .oGREEN(bulletGREEN), .oBLUE(bulletBLUE));
        
    wire [3:0] titleRED;
    wire [3:0] titleGREEN;
    wire [3:0] titleBLUE;
    wire [3:0] nextState;
    TitleScene titleScene (.ix(x), .iy(y), .iactive(active),
        .ibtnC(btnC),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
        .oRED(titleRED), .oGREEN(titleGREEN), .oBLUE(titleBLUE),
        .nextState(nextState));
    
    wire [3:0] barRED;
    wire [3:0] barGREEN;
    wire [3:0] barBLUE;
    wire [10:0] nextHealth;
    wire isEnding;
    BarScene barScene (.xx(x), .yy(y), .aactive(active),
    .Pclk(PixCLK),
    .Reset(0), .ibtnX(btnC),
    .oRED(barRED), .oGREEN(barGREEN), .oBLUE(barBLUE),
    .isEnding(isEnding),
    .health(10),
    .nextHealth(nextHealth)
    );
    
    // draw on the active area of the screen
    always @ (posedge PixCLK)
    begin
        case(state)
            0: 
                begin
                    RED <= titleRED;
                    GREEN <= titleGREEN;
                    BLUE <= titleBLUE;
//                    state <= nextState;
                end
            1: 
                begin
                    RED <= bulletRED;
                    GREEN <= bulletGREEN;
                    BLUE <= bulletBLUE;
                end
            2: 
                begin
                    RED <= barRED;
                    GREEN <= barGREEN;
                    BLUE <= barBLUE;
                end
            default:
                begin
                    RED <= 1;
                    GREEN <= 1;
                    BLUE <= 1;
                end
        endcase
    end
endmodule