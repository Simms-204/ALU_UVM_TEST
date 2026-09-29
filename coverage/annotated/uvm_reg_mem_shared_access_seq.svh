//      // verilator_coverage annotation
        // 
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2020 Mentor Graphics Corporation
        // Copyright 2015-2024 NVIDIA Corporation
        // Copyright 2004-2010 Synopsys, Inc.
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
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/reg/sequences/uvm_reg_mem_shared_access_seq.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Shared Register and Memory Access Test Sequences
        //------------------------------------------------------------------------------
        
        // This section defines sequences for testing registers and memories that are
        // shared between two or more physical interfaces, i.e. are associated with
        // more than one <uvm_reg_map> instance.
        //------------------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_reg_shared_access_seq
        //
        // Verify the accessibility of a shared register
        // by writing through each address map
        // then reading it via every other address maps
        // in which the register is readable and the backdoor,
        // making sure that the resulting value matches the mirrored value.
        //
        // If bit-type resource named
        // "NO_REG_TESTS" or "NO_REG_SHARED_ACCESS_TEST"
        // in the "REG::" namespace
        // matches the full name of the register,
        // the register is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.r0.get_full_name()},
        //|                            "NO_REG_TESTS", 1, this);
        //
        // Registers that contain fields with unknown access policies
        // cannot be tested.
        //
        // The DUT should be idle and not modify any register during this test.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto E.4.1.1
        class uvm_reg_shared_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
           // Variable -- NODOCS -- rg
           // The register to be tested
           uvm_reg rg;
           rand uvm_reg_randval rand_reg_val;
        
%000000    `uvm_object_utils(uvm_reg_shared_access_seq)
        
           // @uvm-ieee 1800.2-2020 auto E.4.1.3
%000000    function new(string name="uvm_reg_shared_access_seq");
%000000      super.new(name);
%000000      rand_reg_val = new();
           endfunction
        
        
%000000    virtual task body();
%000000       uvm_reg_data_t  other_mask;
%000000       uvm_reg_data_t  wo_mask[$];
%000000       uvm_reg_field fields[$];
%000000       uvm_reg_map maps[$];
        
%000000       if (rg == null) begin
%000000         `uvm_error("uvm_reg_shared_access_seq", "No register specified to run sequence on")
%000000         return;
              end
        
              // Registers with some attributes are not to be tested
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},
%000000                                              "NO_REG_SHARED_ACCESS_TEST", 0) != null ) begin
                
%000000         return;
              end
        
        
              // Only look at shared registers
%000000       if (rg.get_n_maps() < 2) begin
%000000         return;
              end
        
%000000       rg.get_maps(maps);
        
              // Let's see what kind of bits we have...
%000000       rg.get_fields(fields);
        
              // Identify unpredictable bits and the ones we shouldn't change
%000000       other_mask = 0;
%000000       foreach (fields[k]) begin
%000000         int lsb, w;
                 
%000000         lsb = fields[k].get_lsb_pos();
%000000         w   = fields[k].get_n_bits();
                 
%000000         if (!fields[k].is_known_access(maps[0])) begin
%000000           repeat (w) begin
%000000             other_mask[lsb++] = 1'b1;
                  end
                end
              end
              
              // WO bits will always readback as 0's but the mirror
              // with return what is supposed to have been written
              // so we cannot use the mirror-check function
%000000       foreach (maps[j]) begin
%000000         uvm_reg_data_t  wo;
%000000         wo = 0;
%000000         foreach (fields[k]) begin
%000000           int lsb, w;
                    
%000000           lsb = fields[k].get_lsb_pos();
%000000           w   = fields[k].get_n_bits();
                    
%000000           if (fields[k].get_access(maps[j]) == "WO") begin
%000000             repeat (w) begin
%000000               wo[lsb++] = 1'b1;
                    end
                  end
                end
%000000         wo_mask[j] = wo;
              end
              
              // Try to write through each map
%000000       foreach (maps[j]) begin
%000000         uvm_status_e status;
%000000         uvm_reg_data_t  prev, v;
                 
                // The mirror should contain the initial value
%000000         prev = rg.get();
                 
                // Write a random value, except in those "don't touch" fields
%000000         void'(rand_reg_val.randomize());
%000000         v = (rand_reg_val.randval & ~other_mask) | (prev & other_mask);
                 
                `uvm_info("uvm_reg_shared_access_seq", $sformatf("Writing register %s via map \"%s\"...",
%000000         rg.get_full_name(), maps[j].get_full_name), UVM_LOW)
                 
%000000         `uvm_info("uvm_reg_shared_access_seq", $sformatf("Writing 'h%h over 'h%h", v, prev),UVM_DEBUG)
                 
%000000         rg.write(status, v, UVM_FRONTDOOR, maps[j], this);
%000000         if (status != UVM_IS_OK) begin
                  `uvm_error("uvm_reg_shared_access_seq", $sformatf("Status was %s when writing register \"%s\" through map \"%s\".",
%000000           status.name(), rg.get_full_name(), maps[j].get_full_name()))
                end
                 
%000000         foreach (maps[k]) begin
%000000           uvm_reg_data_t  actual, exp;
                    
                  `uvm_info("uvm_reg_shared_access_seq", $sformatf("Reading register %s via map \"%s\"...",
%000000           rg.get_full_name(), maps[k].get_full_name()), UVM_LOW)
                    
                  // Was it what we expected?
%000000           exp = rg.get() & ~wo_mask[k];
                    
%000000           rg.read(status, actual, UVM_FRONTDOOR, maps[k], this);
%000000           if (status != UVM_IS_OK) begin
                    `uvm_error("uvm_reg_shared_access_seq", $sformatf("Status was %s when reading register \"%s\" through map \"%s\".",
%000000             status.name(), rg.get_full_name(), maps[k].get_full_name()))
                  end
                    
                  `uvm_info("uvm_reg_shared_access_seq", $sformatf("Read 'h%h, expecting 'h%h",
%000000           actual, exp),UVM_DEBUG)
                    
%000000           if (actual !== exp) begin
                    `uvm_error("uvm_reg_shared_access_seq", $sformatf("Register \"%s\" through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                    rg.get_full_name(), maps[k].get_full_name(),
%000000             actual, exp, v, maps[j].get_full_name(), prev))
                  end
                end
              end
           endtask: body
        endclass: uvm_reg_shared_access_seq
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_mem_shared_access_seq
        //------------------------------------------------------------------------------
        //
        // Verify the accessibility of a shared memory
        // by writing through each address map
        // then reading it via every other address maps
        // in which the memory is readable and the backdoor,
        // making sure that the resulting value matches the written value.
        //
        // If bit-type resource named
        // "NO_REG_TESTS", "NO_MEM_TESTS",
        // "NO_REG_SHARED_ACCESS_TEST" or "NO_MEM_SHARED_ACCESS_TEST"
        // in the "REG::" namespace
        // matches the full name of the memory,
        // the memory is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.mem0.get_full_name()},
        //|                            "NO_MEM_TESTS", 1, this);
        //
        // The DUT should be idle and not modify the memory during this test.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto E.4.2.1
        class uvm_mem_shared_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
           // variable -- NODOCS -- mem
           // The memory to be tested
           uvm_mem mem;
           rand uvm_reg_randval rand_reg_val;
        
%000000    `uvm_object_utils(uvm_mem_shared_access_seq)
        
           // @uvm-ieee 1800.2-2020 auto E.4.2.3
%000000    function new(string name="uvm_mem_shared_access_seq");
%000000      super.new(name);
%000000      rand_reg_val = new();
           endfunction
        
%000000    virtual task body();
%000000       int read_from;
%000000       uvm_reg_map maps[$];
        
%000000       if (mem == null) begin
%000000         `uvm_error("uvm_mem_shared_access_seq", "No memory specified to run sequence on")
%000000         return;
              end
        
              // Memories with some attributes are not to be tested
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                                     "NO_MEM_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                                     "NO_REG_SHARED_ACCESS_TEST", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
%000000                                              "NO_MEM_SHARED_ACCESS_TEST", 0) != null ) begin
                    
%000000         return;
              end
        
        
              // Only look at shared memories
%000000       if (mem.get_n_maps() < 2) begin
%000000         return;
              end
        
%000000       mem.get_maps(maps);
        
              // We need at least a backdoor or a map that can read
              // the shared memory
%000000       read_from = -1;
%000000       if (mem.get_backdoor() == null) begin
%000000         foreach (maps[j]) begin
%000000           string right;
%000000           right = mem.get_access(maps[j]);
%000000           if (right == "RW" ||
%000000           right == "RO") begin
%000000             read_from = j;
%000000             break;
                  end
                end
%000000         if (read_from < 0) begin
%000000           `uvm_warning("uvm_mem_shared_access_seq", $sformatf("Memory \"%s\" cannot be read from any maps or backdoor. Shared access not verified.", mem.get_full_name()))
%000000           return;
                end
              end
              
              // Try to write through each map
%000000       foreach (maps[j]) begin
                 
                `uvm_info("uvm_mem_shared_access_seq", $sformatf("Writing shared memory \"%s\" via map \"%s\".",
%000000         mem.get_full_name(), maps[j].get_full_name()), UVM_LOW)
                 
                // All addresses
%000000         for (int offset = 0; offset < mem.get_size(); offset++) begin
%000000           uvm_status_e status;
%000000           uvm_reg_data_t  prev, v;
                    
                  // Read the initial value
%000000           if (mem.get_backdoor() != null) begin
%000000             mem.peek(status, offset, prev);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_shared_access_seq", $sformatf("Status was %s when reading initial value of \"%s\"[%0d] through backdoor.",
%000000               status.name(), mem.get_full_name(), offset))
                    end
                  end
%000000           else begin
%000000             mem.read(status, offset, prev, UVM_FRONTDOOR, maps[read_from], this);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_shared_access_seq", $sformatf("Status was %s when reading initial value of \"%s\"[%0d] through map \"%s\".",
                      status.name(), mem.get_full_name(),
%000000               offset, maps[read_from].get_full_name()))
                    end
                  end
                    
                    
                  // Write a random value,
%000000           void'(rand_reg_val.randomize());
%000000           v = rand_reg_val.randval;
                    
%000000           mem.write(status, offset, v, UVM_FRONTDOOR, maps[j], this);
%000000           if (status != UVM_IS_OK) begin
                    `uvm_error("uvm_mem_shared_access_seq", $sformatf("Status was %s when writing \"%s\"[%0d] through map \"%s\".",
%000000             status.name(), mem.get_full_name(), offset, maps[j].get_full_name()))
                  end
                    
                  // Read back from all other maps
%000000           foreach (maps[k]) begin
%000000             uvm_reg_data_t  actual, exp;
                       
%000000             mem.read(status, offset, actual, UVM_FRONTDOOR, maps[k], this);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_shared_access_seq", $sformatf("Status was %s when reading %s[%0d] through map \"%s\".",
%000000               status.name(), mem.get_full_name(), offset, maps[k].get_full_name()))
                    end
                       
                    // Was it what we expected?
%000000             exp = v;
%000000             if (mem.get_access(maps[j]) == "RO") begin
%000000               exp = prev;
                    end
%000000             if (mem.get_access(maps[k]) == "WO") begin
%000000               exp = 0;
                    end
                    // Trim to number of bits
%000000             exp &= (1 << mem.get_n_bits()) - 1;
%000000             if (actual !== exp) begin
                      `uvm_error("uvm_mem_shared_access_seq", $sformatf("%s[%0d] through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                      mem.get_full_name(), offset, maps[k].get_full_name(),
%000000               actual, exp, v, maps[j].get_full_name(), prev))
                    end
                  end
                end
              end
           endtask: body
        endclass: uvm_mem_shared_access_seq
        
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_reg_mem_shared_access_seq
        //------------------------------------------------------------------------------
        //
        // Verify the accessibility of all shared registers
        // and memories in a block
        // by executing the <uvm_reg_shared_access_seq>
        // and <uvm_mem_shared_access_seq>
        // sequence respectively on every register and memory within it.
        //
        // If bit-type resource named
        // "NO_REG_TESTS", "NO_MEM_TESTS",
        // "NO_REG_SHARED_ACCESS_TEST" or "NO_MEM_SHARED_ACCESS_TEST"
        // in the "REG::" namespace
        // matches the full name of the block,
        // the block is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.get_full_name(),".*"},
        //|                            "NO_REG_TESTS", 1, this);
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto E.4.3.1
        class uvm_reg_mem_shared_access_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
           // Variable -- NODOCS -- model
           //
           // The block to be tested
           //
           //| uvm_reg_block model; 
        
        
           // Variable -- NODOCS -- reg_seq
           //
           // The sequence used to test one register
           //
           protected uvm_reg_shared_access_seq reg_seq;
           
        
           // Variable -- NODOCS -- mem_seq
           //
           // The sequence used to test one memory
           //
           protected uvm_mem_shared_access_seq mem_seq;
           
%000000    `uvm_object_utils(uvm_reg_mem_shared_access_seq)
        
           // @uvm-ieee 1800.2-2020 auto E.4.3.3.1
%000000    function new(string name="uvm_reg_mem_shared_access_seq");
%000000      super.new(name);
           endfunction
        
        
        
           // @uvm-ieee 1800.2-2020 auto E.4.3.3.2
%000000    virtual task body();
        
%000000       if (model == null) begin
%000000         `uvm_error("uvm_reg_mem_shared_access_seq", "No register model specified to run sequence on")
%000000         return;
              end
              
%000000       uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
        
%000000       reg_seq = uvm_reg_shared_access_seq::type_id::create("reg_shared_access_seq");
%000000       mem_seq = uvm_mem_shared_access_seq::type_id::create("reg_shared_access_seq");
        
%000000       this.reset_blk(model);
%000000       model.reset();
        
%000000       do_block(model);
           endtask: body
        
        
           // Task -- NODOCS -- do_block
           //
           // Test all of the registers and memories in a block
           //
%000000    protected virtual task do_block(uvm_reg_block blk);
%000000       uvm_reg regs[$];
%000000       uvm_mem mems[$];
              
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_MEM_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_REG_SHARED_ACCESS_TEST", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
%000000                                              "NO_MEM_SHARED_ACCESS_TEST", 0) != null ) begin
                
%000000         return;
              end
        
        
%000000       this.reset_blk(model);
%000000       model.reset();
        
              // Iterate over all registers, checking accesses
%000000       blk.get_registers(regs, UVM_NO_HIER);
%000000       foreach (regs[i]) begin
                // Registers with some attributes are not to be tested
%000000         if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                "NO_REG_TESTS", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
%000000         "NO_REG_SHARED_ACCESS_TEST", 0) != null ) begin
                   
%000000           continue;
                end
        
%000000         reg_seq.rg = regs[i];
%000000         reg_seq.start(this.get_sequencer(), this);
              end
        
              // Iterate over all memories, checking accesses
%000000       blk.get_memories(mems, UVM_NO_HIER);
%000000       foreach (mems[i]) begin
                // Registers with some attributes are not to be tested
%000000         if (uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
                "NO_REG_TESTS", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
                "NO_MEM_TESTS", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
                "NO_REG_SHARED_ACCESS_TEST", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
%000000         "NO_MEM_SHARED_ACCESS_TEST", 0) != null ) begin
                    
%000000           continue;
                end
        
%000000         mem_seq.mem = mems[i];
%000000         mem_seq.start(this.get_sequencer(), this);
              end
        
%000000       begin
%000000         uvm_reg_block blks[$];
                 
%000000         blk.get_blocks(blks);
%000000         foreach (blks[i]) begin
%000000           do_block(blks[i]);
                end
              end
           endtask: do_block
        
        
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
        
        
        endclass: uvm_reg_mem_shared_access_seq
        
