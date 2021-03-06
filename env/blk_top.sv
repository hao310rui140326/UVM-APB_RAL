
// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 

`include "blk_dut.sv"

module blk_top;
   bit clk = 0;
   bit rst = 0;

   apb_if apb0(clk);
   blk_dut dut(apb0, rst);

   always #10 clk = ~clk;

   initial begin
       $vcdpluson;	   
   end


endmodule: blk_top

