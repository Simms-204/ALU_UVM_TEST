//      // verilator_coverage annotation
        // 
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2011 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
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
        // $File:     src/reg/sequences/uvm_mem_walk_seq.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Memory Walking-Ones Test Sequences
        //
        // This section defines sequences for applying a "walking-ones"
        // algorithm on one or more memories.
        //------------------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_mem_single_walk_seq
        //
        // Runs the walking-ones algorithm on the memory given by the <mem> property,
        // which must be assigned prior to starting this sequence.
        //
        // If bit-type resource named
        // "NO_REG_TESTS", "NO_MEM_TESTS", or "NO_MEM_WALK_TEST"
        // in the "REG::" namespace
        // matches the full name of the memory,
        // the memory is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.mem0.get_full_name()},
        //|                            "NO_MEM_TESTS", 1, this);
        //
        // The walking ones algorithm is performed for each map in which the memory
        // is defined.
        //
        //| for (k = 0 thru memsize-1)
        //|   write addr=k data=~k
        //|   if (k > 0) {
        //|     read addr=k-1, expect data=~(k-1)
        //|     write addr=k-1 data=k-1
        //|   if (k == last addr)
        //|     read addr=k, expect data=~k
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto E.6.1.1
        class uvm_mem_single_walk_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
%000000    `uvm_object_utils(uvm_mem_single_walk_seq)
        
        
           // Variable -- NODOCS -- mem
           //
           // The memory to test; must be assigned prior to starting sequence.
        
           uvm_mem mem;
        
        
           // Function -- NODOCS -- new
           //
           // Creates a new instance of the class with the given name.
        
           // @uvm-ieee 1800.2-2020 auto E.6.1.3.1
%000000    function new(string name="uvm_mem_walk_seq");
%000000      super.new(name);
           endfunction
        
        
           // Task -- NODOCS -- body
           //
           // Performs the walking-ones algorithm on each map of the memory
           // specified in <mem>.
        
           // @uvm-ieee 1800.2-2020 auto E.6.1.3.2
%000000    virtual task body();
%000000       uvm_reg_map maps[$];
%000000       int n_bits;
        
%000000       if (mem == null) begin
%000000         `uvm_error("uvm_mem_walk_seq", "No memory specified to run sequence on")
%000000         return;
              end
        
              // Memories with some attributes are not to be tested
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                                     "NO_MEM_TESTS", 0) != null ||
              uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
%000000                                              "NO_MEM_WALK_TEST", 0) != null ) begin
                 
%000000         return;
              end
        
        
%000000       n_bits = mem.get_n_bits();
        
              // Memories may be accessible from multiple physical interfaces (maps)
%000000       mem.get_maps(maps);
              
              // Walk the memory via each map
%000000       foreach (maps[j]) begin
%000000         uvm_status_e status;
%000000         uvm_reg_data_t  val, exp, v;
                 
                // Only deal with RW memories
%000000         if (mem.get_access(maps[j]) != "RW") begin
%000000           continue;
                end
        
        
                `uvm_info("uvm_mem_walk_seq", $sformatf("Walking memory %s in map \"%s\"...",
%000000         mem.get_full_name(), maps[j].get_full_name()), UVM_LOW)
                 
                // The walking process is, for address k:
                // - Write ~k
                // - Read k-1 and expect ~(k-1) if k > 0
                // - Write k-1 at k-1
                // - Read k and expect ~k if k == last address
%000000         for (int k = 0; k < mem.get_size(); k++) begin 
%000000           mem.write(status, k, ~k, UVM_FRONTDOOR, maps[j], this); 
        
%000000           if (status != UVM_IS_OK) begin
                    `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
%000000             status.name(), mem.get_full_name(), k, maps[j].get_full_name()))
                  end
                    
%000000           if (k > 0) begin
%000000             mem.read(status, k-1, val, UVM_FRONTDOOR, maps[j], this);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when reading \"%s[%0d]\" through map \"%s\".",
%000000               status.name(), mem.get_full_name(), k, maps[j].get_full_name()))
                    end
%000000             else begin
%000000               exp = ~(k-1) & ((1'b1<<n_bits)-1);
%000000               if (val !== exp) begin
                        `uvm_error("uvm_mem_walk_seq", $sformatf("\"%s[%0d]\" read back as 'h%h instead of 'h%h.",
%000000                 mem.get_full_name(), k-1, val, exp))
                             
                      end
                    end
                       
%000000             mem.write(status, k-1, k-1, UVM_FRONTDOOR, maps[j], this);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
%000000               status.name(), mem.get_full_name(), k-1, maps[j].get_full_name()))
                    end
                  end
                    
%000000           if (k == mem.get_size() - 1) begin
%000000             mem.read(status, k, val, UVM_FRONTDOOR, maps[j], this);
%000000             if (status != UVM_IS_OK) begin
                      `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when reading \"%s[%0d]\" through map \"%s\".",
%000000               status.name(), mem.get_full_name(), k, maps[j].get_full_name()))
                    end
%000000             else begin
%000000               exp = ~(k) & ((1'b1<<n_bits)-1);
%000000               if (val !== exp) begin
                        `uvm_error("uvm_mem_walk_seq", $sformatf("\"%s[%0d]\" read back as 'h%h instead of 'h%h.",
%000000                 mem.get_full_name(), k, val, exp))
                             
                      end
                    end
                  end
                end
              end
           endtask: body
        
        endclass: uvm_mem_single_walk_seq
        
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_mem_walk_seq
        //
        // Verifies the all memories in a block
        // by executing the <uvm_mem_single_walk_seq> sequence on
        // every memory within it.
        //
        // If bit-type resource named
        // "NO_REG_TESTS", "NO_MEM_TESTS", or "NO_MEM_WALK_TEST"
        // in the "REG::" namespace
        // matches the full name of the block,
        // the block is not tested.
        //
        //| uvm_resource_db#(bit)::set({"REG::",regmodel.blk.get_full_name(),".*"},
        //|                            "NO_MEM_TESTS", 1, this);
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto E.6.2.1
        class uvm_mem_walk_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
        
           // Variable -- NODOCS -- model
           //
           // The block to be tested. Declared in the base class.
           //
           //| uvm_reg_block model; 
        
        
           // Variable -- NODOCS -- mem_seq
           //
           // The sequence used to test one memory
           //
           protected uvm_mem_single_walk_seq mem_seq;
        
%000000    `uvm_object_utils(uvm_mem_walk_seq)
        
           // @uvm-ieee 1800.2-2020 auto E.6.3.1
%000000    function new(string name="uvm_mem_walk_seq");
%000000      super.new(name);
           endfunction
        
        
        
           // @uvm-ieee 1800.2-2020 auto E.6.3.2
%000000    virtual task body();
        
%000000       if (model == null) begin
%000000         `uvm_error("uvm_mem_walk_seq", "No register model specified to run sequence on")
%000000         return;
              end
        
%000000       uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
        
%000000       mem_seq = uvm_mem_single_walk_seq::type_id::create("single_mem_walk_seq");
        
%000000       this.reset_blk(model);
%000000       model.reset();
        
%000000       do_block(model);
           endtask: body
        
        
           // Task -- NODOCS -- do_block
           //
           // Test all of the memories in a given ~block~
           //
%000000    protected virtual task do_block(uvm_reg_block blk);
%000000       uvm_mem mems[$];
              
%000000       if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_REG_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                                     "NO_MEM_TESTS", 0) != null ||
                  uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
%000000                                              "NO_MEM_ACCESS_TEST", 0) != null ) begin
                 
%000000         return;
              end
        
              
              // Iterate over all memories, checking accesses
%000000       blk.get_memories(mems, UVM_NO_HIER);
%000000       foreach (mems[i]) begin
                // Memories with some attributes are not to be tested
%000000         if (uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
                "NO_REG_TESTS", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
                "NO_MEM_TESTS", 0) != null ||
                uvm_resource_db#(bit)::get_by_name({"REG::",mems[i].get_full_name()},
%000000         "NO_MEM_WALK_TEST", 0) != null ) begin
                   
%000000           continue;
                end
        
                 
%000000         mem_seq.mem = mems[i];
%000000         mem_seq.start(null, this);
              end
        
%000000       begin
%000000         uvm_reg_block blks[$];
                 
%000000         blk.get_blocks(blks);
%000000         foreach (blks[i]) begin
%000000           do_block(blks[i]);
                end
              end
           endtask: do_block
        
        
           // Task -- NODOCS -- reset_blk
           //
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
        
        endclass: uvm_mem_walk_seq
        
