`timescale 1ns / 1ps

module FSMStreetLight(
    input GoN,
    input GoE,
    input walk,
    input clk,
    input reset,
    output reg [1:0] lightN,
    output reg [1:0] lightE,
    output [3:0] Anode_Activate,
    output [6:0] LED_out
    );
    
    reg walkLight; 
    reg [3:0] current_state;
    reg [3:0] next_state; 
    reg counterone_enable, countertwo_enable, counterthree_enable;
    wire counterone_done, countertwo_done, counterthree_done;
    
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [5:0] timerone, timertwo, timerthree;
    wire fsm_enable;
        
    parameter s0 = 4'b0000; 
    parameter s1 = 4'b0001;
    parameter s2 = 4'b0010;
    parameter s3 = 4'b0011;
    parameter s4 = 4'b0100;
    parameter s5 = 4'b0101;
    parameter s6 = 4'b0110;
    parameter s7 = 4'b0111;
    parameter s8 = 4'b1000;
    parameter s9 = 4'b1001;
    parameter s10 = 4'b1010;
    
    always @ (posedge fsm_enable, posedge reset) 
    begin 
        if (reset == 1'b1)
            current_state <= s0; 
        else
            current_state <= next_state; 
    end 
    
    always @ (fsm_enable)
    begin
        if (one_second_enable ==1) 
        begin
        case (current_state)
        s0: begin 
                if (GoE == 1'b1 && GoN == 1'b0)
                next_state = s4; 
                else 
                next_state = s1;
            end
        s1: begin 
                if (walk == 1'b1) 
                next_state = s5;
                else if (GoE == 1'b1)
                next_state = s2; 
                else 
                next_state = s1; 
            end 
       s2: begin 
                next_state = s3;
           end
       s3: begin 
                if (walk == 1'b1)
                next_state = s7;
                else if (GoN == 1'b1) 
                next_state = s4; 
                else 
                next_state = s3;
           end 
       s4: begin
                next_state = s1; 
           end  
       s5: begin 
                if (GoE == 1'b1) 
                next_state = s2;
                else if (walk == 1'b1)
                next_state = s6; 
                else 
                next_state = s1; 
           end 
       s6: begin 
                next_state = s9; 
           end 
       s7: begin 
                if (GoN == 1'b1)
                next_state = s4;
                else if (walk == 1'b1) 
                next_state = s8; 
                else 
                next_state = s3; 
           end 
       s8: begin 
                next_state = s9; 
           end 
       s9: begin 
                next_state = s10; 
           end  
       s10: begin 
                next_state = s0; 
           end  
   endcase 
   end
end

always @ (current_state)
begin 
       case (current_state)
            s0: begin
                lightN = 2'b10; //red
                lightE = 2'b10; //red
                walkLight = 1'b1; 
                end 
            s1: begin 
                lightN = 2'b01; //green
                lightE = 2'b10; //red
                walkLight = 1'b1;
                end  
            s2: begin 
                lightN = 2'b11; //yellow 
                lightE = 2'b10; //red
                walkLight = 1'b1;
                end   
            s3: begin 
                lightN = 2'b10; //red 
                lightE = 2'b01; //green
                walkLight = 1'b1;
                end 
            s4: begin 
                lightN = 2'b10; //red 
                lightE = 2'b11; //yellow 
                walkLight = 1'b1;
                end
            s5: begin 
                lightN = 2'b01; //green
                lightE = 2'b10; //red
                walkLight = 1'b1;
                end 
            s6: begin 
                lightN = 2'b11; //yellow 
                lightE = 2'b10; //red
                walkLight = 1'b1;
                end 
            s7: begin 
                lightN = 2'b10; //red
                lightE = 2'b01; //green 
                walkLight = 1'b1;
                end
            s8: begin 
                lightN = 2'b10; //red
                lightE = 2'b11; //yellow 
                walkLight = 1'b1;
                end  
            s9: begin 
                lightN = 2'b10; //red 
                lightE = 2'b10; //red 
                walkLight = 1'b0;   //walk
                end
            s10:begin 
                lightN = 2'b10; //red 
                lightE = 2'b10; //red 
                walkLight = 1'b0;   //walk
                end
        endcase 
end 
               
   always @(posedge clk or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=99999999)
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    assign one_second_enable = (one_second_counter==99999999)?1:0;
    
 always @(current_state)
    begin
         if (walkLight ==1'b0)
            counterthree_enable <= 1;
         else counterthree_enable <= 0;
         if ((lightN == 2'b01 || lightE == 2'b01) || (current_state == s0)) //green N or E or walk or state 0
            counterone_enable <= 1;
         else counterone_enable <= 0;
         if (lightN == 2'b11 || lightE == 2'b11) //yellow N or E
            countertwo_enable <= 1;
         else countertwo_enable <= 0;        
    end
    
 always @(posedge reset or posedge one_second_enable)
    begin
        if(reset == 1) 
            timerone <= 0;
        else if (counterone_enable) begin
            if(timerone >= 30)
                 timerone <= 0;
            else if(one_second_enable)
                timerone <= timerone + 1;
        end
    end 
    
    assign counterone_done = (timerone == 30 || counterone_enable == 0)?1:0;
    
  always @(posedge reset or posedge one_second_enable)
    begin
         if (reset==1) timertwo <=0;
         else if (countertwo_enable) begin
            if(timertwo >= 10)
                 timertwo <= 0;
            else if(one_second_enable)
                timertwo <= timertwo + 1;
        end
    end 
    
    assign countertwo_done = (timertwo==10 || countertwo_enable==0)?1:0;  
    
     always @(posedge reset or posedge one_second_enable)
    begin
        if(reset == 1) 
            timerthree <= 0;
        else if (counterthree_enable) begin
            if(timerthree >= 60)
                 timerthree <= 0;
            else if(one_second_enable)
                timerthree <= timerthree + 1;
        end
    end 
    
    assign counterthree_done = (timerthree == 60 || counterthree_enable == 0)?1:0;
    assign fsm_enable = (reset ==1 || ((counterthree_done==1 && countertwo_done == 1) && counterone_done ==1))?1:0; 
    
    Seven_segment_LED_Display_Controller d1 (clk,walkLight,Anode_Activate,LED_out);
      
endmodule
