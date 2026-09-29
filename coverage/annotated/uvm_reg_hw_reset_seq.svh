//      // verilator_coverage annotation
        // 
        //----------------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2021 Marvell International Ltd.
        // Copyright 2010-2011 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
        // Copyright 2018 Qualcomm, Inc.
        // Copyright 2012-2020 Semifore
        // Copyright 2004-2013 Synopsys, Inc.
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
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/reg/sequences/uvm_reg_hw_reset_seq.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        //
        // class -- NODOCS -- uvm_reg_hw_reset_seq
        // Test the hard reset values of registers
        //
        // The test sequence performs the following steps
        //
        // 1. resets the DUT and the
        // block abstraction class associated with this sequence.
        //
        // 2. reads all of the registers in the block,
        // via all of the available address maps,
        // comparing the value read with the expected reset value.
        //
        // If bit-type resource named
        // "NO_REG_TESTS" or "NO_REG_HW_RESET_TEST"
        // in the "REG::" namespace
        // matches the full name of the block or register,
        // the block or register is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.get_full_name(),".*"},
        //|                            "NO_REG_TESTS", 1, this);
        //
        // This is usually the first test executed on any DUT.
        //
        
        // @uvm-ieee 1800.2-2020 auto E.1.1
        class uvm_reg_hw_reset_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
%000000    `uvm_object_utils(uvm_reg_hw_reset_seq)
        
           // @uvm-ieee 1800.2-2020 auto E.1.2.1.1
%000000    function new(string name="uvm_reg_hw_reset_seq");
%000000      super.new(name);
           endfunction
        
        
           // Variable -- NODOCS -- model
           //
           // The block to be tested. Declared in the base class.
           //
           //| uvm_reg_block model; 
        
        
           // Variable -- NODOCS -- body
           //
           // Executes the Hardware Reset sequence.
           // Do not call directly. Use seq.start() instead.
        
           // @uvm-ieee 1800.2-2020 auto E.1.2.1.2
%000000    virtual task body();
        
%000000       if (model == null) begin
%000000         `uvm_error("uvm_reg_hw_reset_seq", "No block or system specified to run sequence on")
%000000         return;
              end
%000000       `uvm_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW)
              
%000000       this.reset_blk(model);
%000000       model.reset();
        
%000000       do_block(model);
           endtask: body
        
        // Task -- NODOCS -- do_block
           //
           // Test all of the registers in a given ~block~
           //
%000000    protected virtual task do_block(uvm_reg_block blk);
%000000       uvm_reg_map maps[$];
%000000       uvm_reg_map sub_maps[$];
%000000       uvm_reg regs[$];
        
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                 uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
%000000                                              "NO_REG_HW_RESET_TEST", 0) != null ) begin
%000000         return;
              end
        
%000000       blk.get_registers(regs, UVM_NO_HIER);
                                                     
%000000       foreach(regs[ridx]) begin
%000000         if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[ridx].get_full_name()},
                "NO_REG_TESTS", 0) != null ||
                regs[ridx].has_reset() == 0 ||
                uvm_resource_db#(bit)::get_by_name({"REG::",regs[ridx].get_full_name()},
%000000         "NO_REG_HW_RESET_TEST", 0) != null ) begin
                    
%000000           continue;
                end
        
                  
%000000         begin
%000000           uvm_reg_map rm[$];
%000000           uvm_status_e status;
%000000           uvm_reg_field fields[$];
%000000           uvm_check_e field_check_restore[uvm_reg_field];
                      
%000000           regs[ridx].get_maps(rm);
                      
%000000           regs[ridx].get_fields(fields);
                    
%000000           foreach(fields[fidx]) begin
%000000             if (fields[fidx].has_reset() == 0 ||
                    fields[fidx].get_compare() == UVM_NO_CHECK || 
                    uvm_resource_db#(bit)::get_by_name({"REG::",fields[fidx].get_full_name()},
%000000             "NO_REG_HW_RESET_TEST", 0) != null) begin
%000000               field_check_restore[fields[fidx]] = fields[fidx].get_compare();  
%000000               fields[fidx].set_compare(UVM_NO_CHECK);
                    end
                  end  
                  // if there are some fields to check
%000000           if(fields.size() != field_check_restore.size()) begin
%000000             foreach(rm[midx]) begin
                      `uvm_info(get_type_name(),
                      $sformatf("Verifying reset value of register %s in map \"%s\"...",
%000000               regs[ridx].get_full_name(), rm[midx].get_full_name()), UVM_LOW)
                       
%000000               regs[ridx].mirror(status, UVM_CHECK, UVM_FRONTDOOR, rm[midx], this);
                       
%000000               if (status != UVM_IS_OK) begin
                        `uvm_error(get_type_name(),
                        $sformatf("Status was %s when reading reset value of register \"%s\" through map \"%s\".",
%000000                 status.name(), regs[ridx].get_full_name(), rm[midx].get_full_name()))
                      end   
                    end
                  end
                  // restore compare setting
%000000           foreach(field_check_restore[field]) begin
%000000             field.set_compare(field_check_restore[field]);
                  end
                end
              end    
              
%000000       begin
%000000         uvm_reg_block blks[$];
                 
%000000         blk.get_blocks(blks, UVM_NO_HIER);
%000000         foreach (blks[i]) begin
%000000           do_block(blks[i]);
                end
              end
        
           endtask:do_block
        
        
           //
           // task -- NODOCS -- reset_blk
           // Reset the DUT that corresponds to the specified block abstraction class.
           //
           // Currently empty.
           // Will rollback the environment's phase to the ~reset~
           // phase once the new phasing is available.
           //
           // In the meantime, the DUT should be reset before executing this
           // test sequence or this method should be implemented
           // in an extension to reset the DUT.
           //
%000000    virtual task reset_blk(uvm_reg_block blk);
           endtask
        
        endclass: uvm_reg_hw_reset_seq
        
