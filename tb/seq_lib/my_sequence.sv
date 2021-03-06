class my_sequence extends uvm_reg_sequence();
   `uvm_object_utils (my_sequence)
   function new (string name = "my_sequence");
      super.new (name);
   endfunction

     ral_block_traffic_cfg    m_ral_model;  

   virtual task body ();

     // ral_block_traffic_cfg    m_ral_model;  
      
      uvm_reg_data_t rdata;
      uvm_status_e   status;
      int            reg_idx = 1;

      //$cast(m_ral_model, model);
      //m_ral_model=model;

      write_reg(m_ral_model.ctrl, status, 32'd3);
      write_reg(m_ral_model.timer[0], status, 32'b00000010000000000000100000000001);
      write_reg(m_ral_model.timer[1], status, 32'hcc);
      //write_reg(m_ral_model.stat, status, 32'h0);

      read_reg(m_ral_model.timer[1], status, rdata );

      write_reg(m_ral_model.ctrl, status, 32'd5,UVM_BACKDOOR);      
      write_reg(m_ral_model.timer[0], status, 32'h5a,UVM_BACKDOOR);
      write_reg(m_ral_model.timer[1], status, 32'ha5,UVM_BACKDOOR);
      //write_reg(m_ral_model.stat, status, 32'h1,UVM_BACKDOOR);


      read_reg(m_ral_model.timer[0], status, rdata );
      read_reg(m_ral_model.timer[1], status, rdata );
      read_reg(m_ral_model.ctrl, status, rdata );
      read_reg(m_ral_model.stat, status, rdata );
      read_reg(m_ral_model.ctrl, status, rdata );
       

   endtask
endclass
