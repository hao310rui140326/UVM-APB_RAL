reg_B.sv

//
//------------------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc. 
//   Copyright 2011 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`ifndef REG_B
 `define REG_B

import uvm_pkg::*;

class reg_B_R extends uvm_reg;
   rand uvm_reg_field F;

   function new(string name = "B_R");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      F = uvm_reg_field::type_id::create("F");
      F.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
   endfunction: build

   `uvm_object_utils(reg_B_R)

endclass : reg_B_R


class reg_fld_B_CTL_CTL;
   typedef enum bit[1:0] { 
		           NOP, 
		           INC, 
		           DEC, 
		           CLR
	                   } CTL_values;
endclass : reg_fld_B_CTL_CTL


class reg_B_CTL extends uvm_reg;
   rand uvm_reg_field CTL;

   function new(string name = "B_CTL");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      CTL = uvm_reg_field::type_id::create("CTL");
      CTL.configure(this, 2, 0, "WO", 0, 2'h0, 1, 0, 1);
      uvm_resource_db#(bit)::set({"REG::",get_full_name()},
                                 "NO_REG_TESTS", 1);
   endfunction: build

   `uvm_object_utils(reg_B_CTL)

endclass : reg_B_CTL


class reg_block_B extends uvm_reg_block;
   rand reg_B_R R;
   rand reg_B_CTL CTL;
   rand uvm_reg_field F;

   function new(string name = "B");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();

      // create regs
      R   =   reg_B_R::type_id::create("R");
      CTL = reg_B_CTL::type_id::create("CTL");

      // build regs
      R.build   ();
      R.configure(this, null, "R");
      CTL.build ();
      CTL.configure(this, null);

      // create map
      default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map.add_reg(R, 'h0, "RW");
      default_map.add_reg(CTL, 'h1, "RW");

      // assign field aliases
      F = R.F;
   endfunction : build

   `uvm_object_utils(reg_block_B)

endclass : reg_block_B


`endif

blk_reg_pkg.sv

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

package blk_reg_pkg;

`include "reg_B.sv"

endpackage

blk_env.sv

// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010-2011 Mentor Graphics Corporation
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


import apb_pkg::*;

class blk_env extends uvm_env;

   `uvm_component_utils(blk_env)

   reg_block_B model;
   apb_agent   apb;

   function new(string name = "blk_env", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (model == null) begin
         model = reg_block_B::type_id::create("reg_blk_B");
         model.build();
         model.set_hdl_path_root("blk_top.dut");
         model.lock_model();

         apb = apb_agent::type_id::create("apb",this);
      end
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      if (model.get_parent() == null) begin
         reg2apb_adapter reg2apb = new;
         model.default_map.set_sequencer(apb.sqr, reg2apb);
         model.default_map.set_auto_predict(1);
      end
   endfunction

endclass: blk_env

blk_seqlib.sv

// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    Copyright 2010 Cadence Design Systems, Inc.
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


// This example uses the reg/mem write/read convenience API in the
// base sequence class. The convenience methods provide the ~parent~
// argument for you when calling the corresponding method in the
// register or memory. 

class blk_R_test_seq extends uvm_reg_sequence;

   `uvm_object_utils(blk_R_test_seq)

   function new(string name = "blk_R_test_seq");
      super.new(name);
   endfunction: new

   reg_block_B model;

   virtual task body();
      uvm_status_e status;
      uvm_reg_data_t data, rd_data;
      int n;

      // Initialize R with a random value then check against mirror
      data[7:0] = $urandom();

      write_reg(model.R, status, data);
      read_reg (model.R, status, rd_data);

      if (data != rd_data)
        `uvm_error("MISCOMPARE","Unexpected value on read")

      model.R.set(23);
      update_reg(model.R, status);
      mirror_reg(model.R, status, UVM_CHECK);

      data[7:0] = $urandom();

      poke_reg(model.R, status, data);
      peek_reg(model.R, status, rd_data);

      if (data != rd_data)
        `uvm_error("MISCOMPARE","Unexpected value on peek")

      // Perform a random number of INC operations
      n = ($urandom() % 7) + 3;
      `uvm_info("blk_R_test_seq", $sformatf("Incrementing R %0d times...", n), UVM_NONE);
      repeat (n) begin
         write_reg(model.CTL, status, reg_fld_B_CTL_CTL::INC);
         data++;
         void'(model.R.predict(data));
      end
      // Check the final value
      mirror_reg(model.R, status, UVM_CHECK);

      // Perform a random number of DEC operations
      n = ($urandom() % 8) + 2;
      `uvm_info("blk_R_test_seq", $sformatf("Decrementing R %0d times...", n), UVM_NONE);
      repeat (n) begin
         write_reg(model.CTL, status, reg_fld_B_CTL_CTL::DEC);
         data--;
         void'(model.R.predict(data));
      end
      // Check the final value
      mirror_reg(model.R, status, UVM_CHECK);

      // Reset the register and check
      write_reg(model.CTL, status, reg_fld_B_CTL_CTL::CLR);
      void'(model.R.predict(0));
      mirror_reg(model.R, status, UVM_CHECK);
   endtask
   
endclass

blk_pkg.sv

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

package blk_pkg;

import uvm_pkg::*;
import blk_reg_pkg::*;

`include "blk_env.sv"
`include "blk_seqlib.sv"

endpackage

blk_dut.sv

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

module blk_dut #(int BASE_ADDR='h0) (apb_if    apb,
                                     input bit rst);

reg [7:0] R;

reg [31:0] pr_data;

wire in_range;

wire [31:0] pr_addr;

assign in_range = (apb.paddr - BASE_ADDR) < 'h100;
assign pr_addr = apb.paddr - BASE_ADDR;

assign apb.prdata = (apb.psel && apb.penable && !apb.pwrite && in_range) ? pr_data : 'z;


always @ (posedge apb.pclk)
  begin
   if (rst) begin
      R <= 'h00;
      pr_data <= 32'h0;
   end
   else begin

      // Wait for a SETUP+READ or ENABLE+WRITE cycle
      if (apb.psel == 1'b1 && apb.penable == apb.pwrite) begin
         pr_data <= 32'h0;
         if (apb.pwrite) begin
            casex (pr_addr)
              32'h00000000:
                 R <= apb.pwdata[7:0];
              32'h00000001:
                 casez (apb.pwdata[1:0]) 
                   2'b01: R++;
                   2'b10: R--;
                   2'b11: R <= 0;
                 endcase
            endcase
         end
         else begin
            casex (pr_addr)
              32'h00000000: pr_data <= {24'h0, R}; 
              default: pr_data <= 32'h0;
            endcase
            #1;
         end
         #0;
      end
   end
end

endmodule

blk_top.sv

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
endmodule: blk_top

blk_testlib.sv

//
//----------------------------------------------------------------------
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

import apb_pkg::*;

typedef class dut_reset_seq;
class blk_R_test extends uvm_test;

   `uvm_component_utils(blk_R_test)

   blk_env env;

   function new(string name="blk_R_test", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if (env == null)
         $cast(env, uvm_top.find("env"));
   endfunction

   task run_phase(uvm_phase phase);
      uvm_sequence_base reset_seq;
      blk_R_test_seq seq;

      phase.raise_objection(this);
      
      begin
         dut_reset_seq rst_seq;
         rst_seq = dut_reset_seq::type_id::create("rst_seq", this);
         rst_seq.start(null);
      end
      env.model.reset();

      seq = blk_R_test_seq::type_id::create("blk_R_test_seq",this);
      seq.model = env.model;
      seq.start(null);

      phase.drop_objection(this);
   endtask
   
endclass

blk_run.sv

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

`include "uvm_pkg.sv"
`include "apb.sv"
`include "blk_reg_pkg.sv"
`include "blk_pkg.sv"
`include "blk_top.sv"

program tb;

import uvm_pkg::*;
import blk_reg_pkg::*;
import blk_pkg::*;

`include "blk_testlib.sv"


class dut_reset_seq extends uvm_sequence;

   function new(string name = "dut_reset_seq");
      super.new(name);
   endfunction

   `uvm_object_utils(dut_reset_seq)
   
   virtual task body();
      blk_top.rst = 1;
      repeat (5) @(negedge blk_top.clk);
      blk_top.rst = 0;
   endtask
endclass


initial
begin
   static blk_env env = new("env");

   uvm_config_db#(apb_vif)::set(env, "apb", "vif", $root.blk_top.apb0);

   run_test();
end

endprogram





