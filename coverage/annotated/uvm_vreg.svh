//      // verilator_coverage annotation
        //
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2011 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2004-2018 Synopsys, Inc.
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
        // $File:     src/reg/uvm_vreg.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Virtual Registers
        //------------------------------------------------------------------------------
        
        //
        // A virtual register is a collection of fields,
        // overlaid on top of a memory, usually in an array.
        // The semantics and layout of virtual registers comes from
        // an agreement between the software and the hardware,
        // not any physical structures in the DUT.
        //
        //------------------------------------------------------------------------------
        
        typedef class uvm_mem_region;
        typedef class uvm_mem_mam;
        
        typedef class uvm_vreg_cbs;
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_vreg
        //
        // Virtual register abstraction base class
        //
        // A virtual register represents a set of fields that are
        // logically implemented in consecutive memory locations.
        //
        // All virtual register accesses eventually turn into memory accesses.
        //
        // A virtual register array may be implemented on top of
        // any memory abstraction class and possibly dynamically
        // resized and/or relocated.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.9.1
        class uvm_vreg extends uvm_object;
        
%000003    `uvm_register_cb(uvm_vreg, uvm_vreg_cbs)
        
           local bit locked;
           local uvm_reg_block parent;
           local int unsigned  n_bits;
           local int unsigned  n_used_bits;
        
           local uvm_vreg_field fields[$];   // Fields in LSB to MSB order
        
           local uvm_mem          mem;     // Where is it implemented?
           local uvm_reg_addr_t   offset;  // Start of vreg[0]
           local int unsigned     incr;    // From start to start of next
           local longint unsigned size;    //number of vregs
           local bit              is_static;
        
           local uvm_mem_region   region;    // Not NULL if implemented via MAM
          
           local semaphore atomic;   // Field RMW operations must be atomic
           local string fname;
           local int lineno;
           local bit read_in_progress;
           local bit write_in_progress;
        
           //
           // Group -- NODOCS -- Initialization
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.1
           extern function new(string       name,
                               int unsigned n_bits);
                               
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.2
           extern function void configure(uvm_reg_block     parent,
                                          uvm_mem       mem    = null,
                                          longint unsigned  size   = 0,
                                          uvm_reg_addr_t    offset = 0,
                                          int unsigned      incr   = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.3
           extern virtual function bit implement(longint unsigned  n,
                                                 uvm_mem       mem    = null,
                                                 uvm_reg_addr_t    offset = 0,
                                                 int unsigned      incr   = 0);
        
         
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.4
           extern virtual function uvm_mem_region allocate(longint unsigned   n,
                                                           uvm_mem_mam        mam,
                                                           uvm_mem_mam_policy alloc = null);
        
         
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.5
           extern virtual function uvm_mem_region get_region();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.1.6
           extern virtual function void release_region();
        
        
           /*local*/ extern virtual function void set_parent(uvm_reg_block parent);
           /*local*/ extern function void Xlock_modelX();
           
           /*local*/ extern function void add_field(uvm_vreg_field field);
           /*local*/ extern task XatomicX(bit on);
        
           //
           // Group -- NODOCS -- Introspection
           //
        
           //
           // Function -- NODOCS -- get_name
           // Get the simple name
           //
           // Return the simple object name of this register.
           //
        
           //
           // Function -- NODOCS -- get_full_name
           // Get the hierarchical name
           //
           // Return the hierarchal name of this register.
           // The base of the hierarchical name is the root block.
           //
           extern virtual function string        get_full_name();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.1
           extern virtual function uvm_reg_block get_parent();
           extern virtual function uvm_reg_block get_block();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.2
           extern virtual function uvm_mem get_memory();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.3
           extern virtual function int             get_n_maps      ();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.4
           extern function         bit             is_in_map       (uvm_reg_map map);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.5
           extern virtual function void            get_maps        (ref uvm_reg_map maps[$]);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.6
           extern virtual function string get_rights(uvm_reg_map map = null);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.7
           extern virtual function string get_access(uvm_reg_map map = null);
        
           //
           // FUNCTION -- NODOCS -- get_size
           // Returns the size of the virtual register array. 
           //
           extern virtual function int unsigned get_size();
        
           //
           // FUNCTION -- NODOCS -- get_n_bytes
           // Returns the width, in bytes, of a virtual register.
           //
           // The width of a virtual register is always a multiple of the width
           // of the memory locations used to implement it.
           // For example, a virtual register containing two 1-byte fields
           // implemented in a memory with 4-bytes memory locations is 4-byte wide. 
           //
           extern virtual function int unsigned get_n_bytes();
        
           //
           // FUNCTION -- NODOCS -- get_n_memlocs
           // Returns the number of memory locations used
           // by a single virtual register. 
           //
           extern virtual function int unsigned get_n_memlocs();
        
           //
           // FUNCTION -- NODOCS -- get_incr
           // Returns the number of memory locations
           // between two individual virtual registers in the same array. 
           //
           extern virtual function int unsigned get_incr();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.12
           extern virtual function void get_fields(ref uvm_vreg_field fields[$]);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.13
           extern virtual function uvm_vreg_field get_field_by_name(string name);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.14
           extern virtual function uvm_reg_addr_t  get_offset_in_memory(longint unsigned idx);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.2.15
           extern virtual function uvm_reg_addr_t  get_address(longint unsigned idx,
                                                               uvm_reg_map map = null);
        
           //
           // Group -- NODOCS -- HDL Access
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.3.1
           extern virtual task write(input  longint unsigned   idx,
                                     output uvm_status_e  status,
                                     input  uvm_reg_data_t     value,
                                     input  uvm_door_e    path = UVM_DEFAULT_DOOR,
                                     input  uvm_reg_map     map = null,
                                     input  uvm_sequence_base  parent = null,
                                     input  uvm_object         extension = null,
                                     input  string             fname = "",
                                     input  int                lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.3.2
           extern virtual task read(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    output uvm_reg_data_t      value,
                                    input  uvm_door_e     path = UVM_DEFAULT_DOOR,
                                    input  uvm_reg_map      map = null,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.3.3
           extern virtual task poke(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    input  uvm_reg_data_t      value,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.3.4
           extern virtual task peek(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    output uvm_reg_data_t      value,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
          
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.3.5
           extern function void reset(string kind = "HARD");
        
        
           //
           // Group -- NODOCS -- Callbacks
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.4.1
%000000    virtual task pre_write(longint unsigned     idx,
                                  ref uvm_reg_data_t   wdat,
                                  ref uvm_door_e  path,
                                  ref uvm_reg_map      map);
           endtask: pre_write
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.4.2
%000000    virtual task post_write(longint unsigned       idx,
                                   uvm_reg_data_t         wdat,
                                   uvm_door_e        path,
                                   uvm_reg_map            map,
                                   ref uvm_status_e  status);
           endtask: post_write
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.4.3
%000000    virtual task pre_read(longint unsigned     idx,
                                 ref uvm_door_e  path,
                                 ref uvm_reg_map      map);
           endtask: pre_read
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.1.4.4
%000000    virtual task post_read(longint unsigned       idx,
                                  ref uvm_reg_data_t     rdat,
                                  input uvm_door_e  path,
                                  input uvm_reg_map      map,
                                  ref uvm_status_e  status);
           endtask: post_read
        
           extern virtual function void do_print (uvm_printer printer);
           extern virtual function string convert2string;
           extern virtual function uvm_object clone();
           extern virtual function void do_copy   (uvm_object rhs);
           extern virtual function bit do_compare (uvm_object  rhs,
                                                  uvm_comparer comparer);
           extern virtual function void do_pack (uvm_packer packer);
           extern virtual function void do_unpack (uvm_packer packer);
        
        endclass: uvm_vreg
        
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_vreg_cbs
        //
        // Pre/post read/write callback facade class
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.9.2.1
        virtual class uvm_vreg_cbs extends uvm_callback;
        
%000000    `uvm_object_abstract_utils(uvm_vreg_cbs)
        
           string fname;
           int    lineno;
        
%000000    function new(string name = "uvm_reg_cbs");
%000000       super.new(name);
           endfunction
           
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.2.2.1
%000000    virtual task pre_write(uvm_vreg         rg,
                                  longint unsigned     idx,
                                  ref uvm_reg_data_t   wdat,
                                  ref uvm_door_e  path,
                                  ref uvm_reg_map   map);
           endtask: pre_write
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.2.2.2
%000000    virtual task post_write(uvm_vreg           rg,
                                   longint unsigned       idx,
                                   uvm_reg_data_t         wdat,
                                   uvm_door_e        path,
                                   uvm_reg_map         map,
                                   ref uvm_status_e  status);
           endtask: post_write
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.2.2.3
%000000    virtual task pre_read(uvm_vreg         rg,
                                 longint unsigned     idx,
                                 ref uvm_door_e  path,
                                 ref uvm_reg_map   map);
           endtask: pre_read
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.9.2.2.4
%000000    virtual task post_read(uvm_vreg           rg,
                                  longint unsigned       idx,
                                  ref uvm_reg_data_t     rdat,
                                  input uvm_door_e  path,
                                  input uvm_reg_map   map,
                                  ref uvm_status_e  status);
           endtask: post_read
        endclass: uvm_vreg_cbs
        
        
        //
        // Type -- NODOCS -- uvm_vreg_cb
        // Convenience callback type declaration
        //
        // Use this declaration to register virtual register callbacks rather than
        // the more verbose parameterized class
        //
        typedef uvm_callbacks#(uvm_vreg, uvm_vreg_cbs) uvm_vreg_cb /* @uvm-ieee 1800.2-2020 auto D.4.5.9*/ ;
        
        //
        // Type -- NODOCS -- uvm_vreg_cb_iter
        // Convenience callback iterator type declaration
        //
        // Use this declaration to iterate over registered virtual register callbacks
        // rather than the more verbose parameterized class
        //
        typedef uvm_callback_iter#(uvm_vreg, uvm_vreg_cbs) uvm_vreg_cb_iter /* @uvm-ieee 1800.2-2020 auto D.4.5.10*/ ;
        
        
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
        
%000000 function uvm_vreg::new(string       name,
                                   int unsigned n_bits);
%000000    super.new(name);
        
%000000    if (n_bits == 0) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual register \"%s\" cannot have 0 bits", this.get_full_name()))
%000000      n_bits = 1;
           end
%000000    if (n_bits > `UVM_REG_DATA_WIDTH) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual register \"%s\" cannot have more than %0d bits (%0d)", this.get_full_name(), `UVM_REG_DATA_WIDTH, n_bits))
%000000      n_bits = `UVM_REG_DATA_WIDTH;
           end
%000000    this.n_bits = n_bits;
        
%000000    this.locked    = 0;
        endfunction: new
        
%000000 function void uvm_vreg::configure(uvm_reg_block      parent,
                                              uvm_mem        mem = null,
                                              longint unsigned   size = 0,
                                              uvm_reg_addr_t     offset = 0,
                                              int unsigned       incr = 0);
%000000    this.parent = parent;
        
%000000    this.n_used_bits = 0;
        
%000000    if (mem != null) begin
%000000      void'(this.implement(size, mem, offset, incr));
%000000      this.is_static = 1;
           end
%000000    else begin
%000000      this.mem = null;
%000000      this.is_static = 0;
           end
%000000    this.parent.add_vreg(this);
        
%000000    this.atomic = new(1);
        endfunction: configure
        
        
        
%000000 function void uvm_vreg::Xlock_modelX();
%000000    if (this.locked) begin
%000000      return;
           end
        
        
%000000    this.locked = 1;
        endfunction: Xlock_modelX
        
        
%000000 function void uvm_vreg::add_field(uvm_vreg_field field);
%000000    int offset;
%000000    int idx;
           
%000000    if (this.locked) begin
%000000      `uvm_error("RegModel", "Cannot add virtual field to locked virtual register model")
%000000      return;
           end
        
%000000    if (field == null) begin
%000000      `uvm_fatal("RegModel", "Attempting to register NULL virtual field")
           end
        
           // Store fields in LSB to MSB order
%000000    offset = field.get_lsb_pos_in_register();
        
%000000    idx = -1;
%000000    foreach (this.fields[i]) begin
%000000      if (offset < this.fields[i].get_lsb_pos_in_register()) begin
%000000        int j = i;
%000000        this.fields.insert(j, field);
%000000        idx = i;
%000000        break;
             end
           end
%000000    if (idx < 0) begin
%000000      this.fields.push_back(field);
%000000      idx = this.fields.size()-1;
           end
        
%000000    this.n_used_bits += field.get_n_bits();
           
           // Check if there are too many fields in the register
%000000    if (this.n_used_bits > this.n_bits) begin
             `uvm_error("RegModel", $sformatf("Virtual fields use more bits (%0d) than available in virtual register \"%s\" (%0d)",
%000000      this.n_used_bits, this.get_full_name(), this.n_bits))
           end
        
           // Check if there are overlapping fields
%000000    if (idx > 0) begin
%000000      if (this.fields[idx-1].get_lsb_pos_in_register() +
%000000      this.fields[idx-1].get_n_bits() > offset) begin
               `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in virtual register \"%s\"",
               this.fields[idx-1].get_name(),
               field.get_name(),
%000000        this.get_full_name()))
             end
           end
%000000    if (idx < this.fields.size()-1) begin
%000000      if (offset + field.get_n_bits() >
%000000      this.fields[idx+1].get_lsb_pos_in_register()) begin
               `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in virtual register \"%s\"",
               field.get_name(),
               this.fields[idx+1].get_name(),
%000000        this.get_full_name()))
             end
           end
        endfunction: add_field
        
        
%000000 task uvm_vreg::XatomicX(bit on);
%000000    if (on) begin
%000000      this.atomic.get(1);
           end
        
%000000    else begin
             // Maybe a key was put back in by a spurious call to reset()
%000000      void'(this.atomic.try_get(1));
%000000      this.atomic.put(1);
           end
        endtask: XatomicX
        
        
%000000 function void uvm_vreg::reset(string kind = "HARD");
           // Put back a key in the semaphore if it is checked out
           // in case a thread was killed during an operation
%000000    void'(this.atomic.try_get(1));
%000000    this.atomic.put(1);
        endfunction: reset
        
        
%000000 function string uvm_vreg::get_full_name();
%000000    uvm_reg_block blk;
        
%000000    get_full_name = this.get_name();
        
           // Do not include top-level name in full name
%000000    blk = this.get_block();
%000000    if (blk == null) begin
%000000      return get_full_name;
           end
        
%000000    if (blk.get_parent() == null) begin
%000000      return get_full_name;
           end
        
        
%000000    get_full_name = {this.parent.get_full_name(), ".", get_full_name};
        endfunction: get_full_name
        
%000000 function void uvm_vreg::set_parent(uvm_reg_block parent);
%000000    this.parent = parent;
        endfunction: set_parent
        
%000000 function uvm_reg_block uvm_vreg::get_parent();
%000000    get_parent = this.parent;
        endfunction: get_parent
        
%000000 function uvm_reg_block uvm_vreg::get_block();
%000000    get_block = this.parent;
        endfunction: get_block
        
        
%000000 function bit uvm_vreg::implement(longint unsigned n,
                                             uvm_mem      mem = null,
                                             uvm_reg_addr_t   offset = 0,
                                             int unsigned     incr = 0);
        
%000000    uvm_mem_region region;
        
%000000    if(n < 1) begin
           
%000000      `uvm_error("RegModel", $sformatf("Attempting to implement virtual register \"%s\" with a subscript less than one doesn't make sense",this.get_full_name()))
%000000      return 0;
           end
        
%000000    if (mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Attempting to implement virtual register \"%s\" using a NULL uvm_mem reference", this.get_full_name()))
%000000      return 0;
           end
        
%000000    if (this.is_static) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual register \"%s\" is static and cannot be dynamically implemented", this.get_full_name()))
%000000      return 0;
           end
        
%000000    if (mem.get_block() != this.parent) begin
             `uvm_error("RegModel", $sformatf("Attempting to implement virtual register \"%s\" on memory \"%s\" in a different block",
             this.get_full_name(),
%000000      mem.get_full_name()))
%000000      return 0;
           end
        
%000000    begin
%000000      int min_incr = (this.get_n_bytes()-1) / mem.get_n_bytes() + 1;
%000000      if (incr == 0) begin
%000000        incr = min_incr;
             end
        
%000000      if (min_incr > incr) begin
               `uvm_error("RegModel", $sformatf("Virtual register \"%s\" increment is too small (%0d): Each virtual register requires at least %0d locations in memory \"%s\".",
               this.get_full_name(), incr,
%000000        min_incr, mem.get_full_name()))
%000000        return 0;
             end
           end
        
           // Is the memory big enough for ya?
%000000    if (offset + (n * incr) > mem.get_size()) begin
%000000      `uvm_error("RegModel", $sformatf("Given Offset for Virtual register \"%s[%0d]\" is too big for memory %s@'h%0h", this.get_full_name(), n, mem.get_full_name(), offset))
%000000      return 0;
           end
        
%000000    region = mem.mam.reserve_region(offset,n*incr*mem.get_n_bytes());
        
%000000    if (region == null) begin
%000000      `uvm_error("RegModel", $sformatf("Could not allocate a memory region for virtual register \"%s\"", this.get_full_name()))
%000000      return 0;
           end
        
%000000    if (this.mem != null) begin
             `uvm_info("RegModel", $sformatf("Virtual register \"%s\" is being moved re-implemented from %s@'h%0h to %s@'h%0h",
             this.get_full_name(),
             this.mem.get_full_name(),
             this.offset,
%000000      mem.get_full_name(), offset),UVM_MEDIUM)
%000000      this.release_region();
           end
        
%000000    this.region = region;
%000000    this.mem    = mem;
%000000    this.size   = n;
%000000    this.offset = offset;
%000000    this.incr   = incr;
%000000    this.mem.Xadd_vregX(this);
        
%000000    return 1;
        endfunction: implement
        
        
%000000 function uvm_mem_region uvm_vreg::allocate(longint unsigned   n,
                                                   uvm_mem_mam        mam,
                                                   uvm_mem_mam_policy alloc=null);
        
%000000    uvm_mem mem;
        
%000000    if(n < 1) begin
           
%000000      `uvm_error("RegModel", $sformatf("Attempting to implement virtual register \"%s\" with a subscript less than one doesn't make sense",this.get_full_name()))
%000000      return null;
           end
        
%000000    if (mam == null) begin
%000000      `uvm_error("RegModel", $sformatf("Attempting to implement virtual register \"%s\" using a NULL uvm_mem_mam reference", this.get_full_name()))
%000000      return null;
           end
        
%000000    if (this.is_static) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual register \"%s\" is static and cannot be dynamically allocated", this.get_full_name()))
%000000      return null;
           end
        
%000000    mem = mam.get_memory();
%000000    if (mem.get_block() != this.parent) begin
             `uvm_error("RegModel", $sformatf("Attempting to allocate virtual register \"%s\" on memory \"%s\" in a different block",
             this.get_full_name(),
%000000      mem.get_full_name()))
%000000      return null;
           end
        
%000000    begin
%000000      int min_incr = (this.get_n_bytes()-1) / mem.get_n_bytes() + 1;
%000000      if (incr == 0) begin
%000000        incr = min_incr;
             end
        
%000000      if (min_incr < incr) begin
               `uvm_error("RegModel", $sformatf("Virtual register \"%s\" increment is too small (%0d): Each virtual register requires at least %0d locations in memory \"%s\".",
               this.get_full_name(), incr,
%000000        min_incr, mem.get_full_name()))
%000000        return null;
             end
           end
        
           // Need memory at least of size num_vregs*sizeof(vreg) in bytes.
%000000    allocate = mam.request_region(n*incr*mem.get_n_bytes(), alloc);
%000000    if (allocate == null) begin
%000000      `uvm_error("RegModel", $sformatf("Could not allocate a memory region for virtual register \"%s\"", this.get_full_name()))
%000000      return null;
           end
        
%000000    if (this.mem != null) begin
             `uvm_info("RegModel", $sformatf("Virtual register \"%s\" is being moved from %s@'h%0h to %s@'h%0h",
             this.get_full_name(),
             this.mem.get_full_name(),
             this.offset,
             mem.get_full_name(),
%000000      allocate.get_start_offset()),UVM_MEDIUM)
        
%000000      this.release_region();
           end
        
%000000    this.region = allocate;
        
%000000    this.mem    = mam.get_memory();
%000000    this.offset = allocate.get_start_offset();
%000000    this.size   = n;
%000000    this.incr   = incr;
        
%000000    this.mem.Xadd_vregX(this);
        endfunction: allocate
        
        
%000000 function uvm_mem_region uvm_vreg::get_region();
%000000    return this.region;
        endfunction: get_region
        
        
%000000 function void uvm_vreg::release_region();
%000000    if (this.is_static) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual register \"%s\" is static and cannot be dynamically released", this.get_full_name()))
%000000      return;
           end
        
%000000    if (this.mem != null) begin
              
%000000      this.mem.Xdelete_vregX(this);
           end
        
        
%000000    if (this.region != null) begin
%000000      this.region.release_region();
           end
        
%000000    this.region = null;
%000000    this.mem    = null;
%000000    this.size   = 0;
%000000    this.offset = 0;
        
%000000    this.reset();
        endfunction: release_region
        
        
%000000 function uvm_mem uvm_vreg::get_memory();
%000000    return this.mem;
        endfunction: get_memory
        
        
%000000 function uvm_reg_addr_t  uvm_vreg::get_offset_in_memory(longint unsigned idx);
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_offset_in_memory() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.offset + idx * this.incr;
        endfunction
        
        
%000000 function uvm_reg_addr_t  uvm_vreg::get_address(longint unsigned idx,
                                                           uvm_reg_map map = null);
%000000    if (this.mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Cannot get address of of unimplemented virtual register \"%s\".", this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.mem.get_address(this.get_offset_in_memory(idx), map);
        endfunction: get_address
        
        
%000000 function int unsigned uvm_vreg::get_size();
%000000    if (this.size == 0) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_size() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.size;
        endfunction: get_size
        
        
%000000 function int unsigned uvm_vreg::get_n_bytes();
%000000    return ((this.n_bits-1) / 8) + 1;
        endfunction: get_n_bytes
        
        
%000000 function int unsigned uvm_vreg::get_n_memlocs();
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_n_memlocs() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return (this.get_n_bytes()-1) / this.mem.get_n_bytes() + 1;
        endfunction: get_n_memlocs
        
        
%000000 function int unsigned uvm_vreg::get_incr();
%000000    if (this.incr == 0) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_incr() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.incr;
        endfunction: get_incr
        
        
%000000 function int uvm_vreg::get_n_maps();
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_n_maps() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.mem.get_n_maps();
        endfunction: get_n_maps
        
        
%000000 function void uvm_vreg::get_maps(ref uvm_reg_map maps[$]);
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_maps() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return;
           end
        
%000000    this.mem.get_maps(maps);
        endfunction: get_maps
        
        
%000000 function bit uvm_vreg::is_in_map(uvm_reg_map map);
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::is_in_map() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return 0;
           end
        
%000000    return this.mem.is_in_map(map);
        endfunction
        
        
%000000 function string uvm_vreg::get_access(uvm_reg_map map = null);
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_rights() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return "RW";
           end
        
%000000    return this.mem.get_access(map);
        endfunction: get_access
        
        
%000000 function string uvm_vreg::get_rights(uvm_reg_map map = null);
%000000    if (this.mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg::get_rights() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      return "RW";
           end
        
%000000    return this.mem.get_rights(map);
        endfunction: get_rights
        
        
%000000 function void uvm_vreg::get_fields(ref uvm_vreg_field fields[$]);
%000000    foreach(this.fields[i]) begin
              
%000000      fields.push_back(this.fields[i]);
           end
        
        endfunction: get_fields
        
        
%000000 function uvm_vreg_field uvm_vreg::get_field_by_name(string name);
%000000    foreach (this.fields[i]) begin
%000000      if (this.fields[i].get_name() == name) begin
%000000        return this.fields[i];
             end
           end
           `uvm_warning("RegModel", $sformatf("Unable to locate field \"%s\" in virtual register \"%s\".",
%000000                                     name, this.get_full_name()))
%000000    get_field_by_name = null;
        endfunction: get_field_by_name
        
        
%000000 task uvm_vreg::write(input  longint unsigned   idx,
%000000                          output uvm_status_e  status,
                                 input  uvm_reg_data_t     value,
                                 input  uvm_door_e    path = UVM_DEFAULT_DOOR,
                                 input  uvm_reg_map     map = null,
                                 input  uvm_sequence_base  parent = null,
                                 input  uvm_object         extension = null,
                                 input  string             fname = "",
                                 input  int                lineno = 0);
%000000    uvm_vreg_cb_iter cbs = new(this);
        
%000000    uvm_reg_addr_t  addr;
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  msk;
%000000    int lsb;
        
%000000    this.write_in_progress = 1'b1;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
%000000    if (this.mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Cannot write to unimplemented virtual register \"%s\".", this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if (path == UVM_DEFAULT_DOOR) begin
             
%000000      path = this.parent.get_default_door();
           end
        
        
%000000    foreach (fields[i]) begin
%000000      uvm_vreg_field_cb_iter cbs = new(fields[i]);
%000000      uvm_vreg_field f = fields[i];
              
%000000      lsb = f.get_lsb_pos_in_register();
%000000      msk = ((1<<f.get_n_bits())-1) << lsb;
%000000      tmp = (value & msk) >> lsb;
        
%000000      f.pre_write(idx, tmp, path, map);
%000000      for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000        cb = cbs.next()) begin
%000000        cb.fname = this.fname;
%000000        cb.lineno = this.lineno;
%000000        cb.pre_write(f, idx, tmp, path, map);
             end
        
%000000      value = (value & ~msk) | (tmp << lsb);
           end
%000000    this.pre_write(idx, value, path, map);
%000000    for (uvm_vreg_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.pre_write(this, idx, value, path, map);
           end
        
%000000    addr = this.offset + (idx * this.incr);
        
%000000    lsb = 0;
%000000    status = UVM_IS_OK;
%000000    for (int i = 0; i < this.get_n_memlocs(); i++) begin
%000000      uvm_status_e s;
        
%000000      msk = ((1<<(this.mem.get_n_bytes()*8))-1) << lsb;
%000000      tmp = (value & msk) >> lsb;
%000000      this.mem.write(s, addr + i, tmp, path, map , parent, , extension, fname, lineno);
%000000      if (s != UVM_IS_OK && s != UVM_HAS_X) begin
%000000        status = s;
             end
        
%000000      lsb += this.mem.get_n_bytes() * 8;
           end
        
%000000    for (uvm_vreg_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.post_write(this, idx, value, path, map, status);
           end
%000000    this.post_write(idx, value, path, map, status);
%000000    foreach (fields[i]) begin
%000000      uvm_vreg_field_cb_iter cbs = new(fields[i]);
%000000      uvm_vreg_field f = fields[i];
              
%000000      lsb = f.get_lsb_pos_in_register();
%000000      msk = ((1<<f.get_n_bits())-1) << lsb;
%000000      tmp = (value & msk) >> lsb;
        
%000000      for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000        cb = cbs.next()) begin
%000000        cb.fname = this.fname;
%000000        cb.lineno = this.lineno;
%000000        cb.post_write(f, idx, tmp, path, map, status);
             end
%000000      f.post_write(idx, tmp, path, map, status);
        
%000000      value = (value & ~msk) | (tmp << lsb);
           end
        
           `uvm_info("RegModel", $sformatf("Wrote virtual register \"%s\"[%0d] via %s with: 'h%h",
                                      this.get_full_name(), idx,
                                      (path == UVM_FRONTDOOR) ? "frontdoor" : "backdoor",
%000000                               value),UVM_MEDIUM)
           
%000000    this.write_in_progress = 1'b0;
%000000    this.fname = "";
%000000    this.lineno = 0;
        
        endtask: write
        
        
%000000 task uvm_vreg::read(input  longint unsigned   idx,
%000000                         output uvm_status_e  status,
%000000                         output uvm_reg_data_t     value,
                                input  uvm_door_e    path = UVM_DEFAULT_DOOR,
                                input  uvm_reg_map     map = null,
                                input  uvm_sequence_base  parent = null,
                                input  uvm_object         extension = null,
                                input  string             fname = "",
                                input  int                lineno = 0);
%000000    uvm_vreg_cb_iter cbs = new(this);
        
%000000    uvm_reg_addr_t  addr;
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  msk;
%000000    int lsb;
%000000    this.read_in_progress = 1'b1;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    if (this.mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Cannot read from unimplemented virtual register \"%s\".", this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if (path == UVM_DEFAULT_DOOR) begin
             
%000000      path = this.parent.get_default_door();
           end
        
        
%000000    foreach (fields[i]) begin
%000000      uvm_vreg_field_cb_iter cbs = new(fields[i]);
%000000      uvm_vreg_field f = fields[i];
        
%000000      f.pre_read(idx, path, map);
%000000      for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000        cb = cbs.next()) begin
%000000        cb.fname = this.fname;
%000000        cb.lineno = this.lineno;
%000000        cb.pre_read(f, idx, path, map);
             end
           end
%000000    this.pre_read(idx, path, map);
%000000    for (uvm_vreg_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.pre_read(this, idx, path, map);
           end
        
%000000    addr = this.offset + (idx * this.incr);
        
%000000    lsb = 0;
%000000    value = 0;
%000000    status = UVM_IS_OK;
%000000    for (int i = 0; i < this.get_n_memlocs(); i++) begin
%000000      uvm_status_e s;
        
%000000      this.mem.read(s, addr + i, tmp, path, map, parent, , extension, fname, lineno);
%000000      if (s != UVM_IS_OK && s != UVM_HAS_X) begin
%000000        status = s;
             end
        
        
%000000      value |= tmp << lsb;
%000000      lsb += this.mem.get_n_bytes() * 8;
           end
        
%000000    for (uvm_vreg_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.post_read(this, idx, value, path, map, status);
           end
%000000    this.post_read(idx, value, path, map, status);
%000000    foreach (fields[i]) begin
%000000      uvm_vreg_field_cb_iter cbs = new(fields[i]);
%000000      uvm_vreg_field f = fields[i];
        
%000000      lsb = f.get_lsb_pos_in_register();
        
%000000      msk = ((1<<f.get_n_bits())-1) << lsb;
%000000      tmp = (value & msk) >> lsb;
        
%000000      for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000        cb = cbs.next()) begin
%000000        cb.fname = this.fname;
%000000        cb.lineno = this.lineno;
%000000        cb.post_read(f, idx, tmp, path, map, status);
             end
%000000      f.post_read(idx, tmp, path, map, status);
        
%000000      value = (value & ~msk) | (tmp << lsb);
           end
        
           `uvm_info("RegModel", $sformatf("Read virtual register \"%s\"[%0d] via %s: 'h%h",
                                      this.get_full_name(), idx,
                                      (path == UVM_FRONTDOOR) ? "frontdoor" : "backdoor",
%000000                               value),UVM_MEDIUM)
           
%000000    this.read_in_progress = 1'b0;
%000000    this.fname = "";
%000000    this.lineno = 0;
        endtask: read
        
        
%000000 task uvm_vreg::poke(input longint unsigned   idx,
%000000                         output uvm_status_e status,
                                input  uvm_reg_data_t    value,
                                input  uvm_sequence_base parent = null,
                                input  uvm_object        extension = null,
                                input  string            fname = "",
                                input  int               lineno = 0);
%000000    uvm_reg_addr_t  addr;
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  msk;
%000000    int lsb;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    if (this.mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Cannot poke in unimplemented virtual register \"%s\".", this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    addr = this.offset + (idx * this.incr);
        
%000000    lsb = 0;
%000000    status = UVM_IS_OK;
%000000    for (int i = 0; i < this.get_n_memlocs(); i++) begin
%000000      uvm_status_e s;
        
%000000      msk = ((1<<(this.mem.get_n_bytes() * 8))-1) << lsb;
%000000      tmp = (value & msk) >> lsb;
        
%000000      this.mem.poke(status, addr + i, tmp, "", parent, extension, fname, lineno);
%000000      if (s != UVM_IS_OK && s != UVM_HAS_X) begin
%000000        status = s;
             end
        
        
%000000      lsb += this.mem.get_n_bytes() * 8;
           end
        
           `uvm_info("RegModel", $sformatf("Poked virtual register \"%s\"[%0d] with: 'h%h",
%000000                               this.get_full_name(), idx, value),UVM_MEDIUM)
%000000    this.fname = "";
%000000    this.lineno = 0;
        
        endtask: poke
        
        
%000000 task uvm_vreg::peek(input longint unsigned   idx,
%000000                         output uvm_status_e status,
%000000                         output uvm_reg_data_t    value,
                                input  uvm_sequence_base parent = null,
                                input  uvm_object        extension = null,
                                input  string            fname = "",
                                input  int               lineno = 0);
%000000    uvm_reg_addr_t  addr;
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  msk;
%000000    int lsb;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    if (this.mem == null) begin
%000000      `uvm_error("RegModel", $sformatf("Cannot peek in from unimplemented virtual register \"%s\".", this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    addr = this.offset + (idx * this.incr);
        
%000000    lsb = 0;
%000000    value = 0;
%000000    status = UVM_IS_OK;
%000000    for (int i = 0; i < this.get_n_memlocs(); i++) begin
%000000      uvm_status_e s;
        
%000000      this.mem.peek(status, addr + i, tmp, "", parent, extension, fname, lineno);
%000000      if (s != UVM_IS_OK && s != UVM_HAS_X) begin
%000000        status = s;
             end
        
        
%000000      value |= tmp << lsb;
%000000      lsb += this.mem.get_n_bytes() * 8;
           end
        
           `uvm_info("RegModel", $sformatf("Peeked virtual register \"%s\"[%0d]: 'h%h",
%000000                               this.get_full_name(), idx, value),UVM_MEDIUM)
           
%000000    this.fname = "";
%000000    this.lineno = 0;
        
        endtask: peek
        
        
%000000 function void uvm_vreg::do_print (uvm_printer printer);
%000000   super.do_print(printer);
%000000   printer.print_generic("initiator", parent.get_type_name(), -1, convert2string());
        endfunction
        
%000000 function string uvm_vreg::convert2string();
%000000    string res_str;
%000000    string t_str;
%000000    bit with_debug_info;
%000000    $sformat(convert2string, "Virtual register %s -- ", 
%000000             this.get_full_name());
        
%000000    if (this.size == 0) begin
             
%000000      $sformat(convert2string, "%sunimplemented", convert2string);
           end
        
%000000    else begin
%000000      uvm_reg_map maps[$];
%000000      mem.get_maps(maps);
        
%000000      $sformat(convert2string, "%s[%0d] in %0s['h%0h+'h%0h]\n", convert2string,
%000000              this.size, this.mem.get_full_name(), this.offset, this.incr); 
%000000      foreach (maps[i]) begin
%000000        uvm_reg_addr_t  addr0 = this.get_address(0, maps[i]);
        
%000000        $sformat(convert2string, "  Address in map '%s' -- @'h%0h+%0h",
%000000         maps[i].get_full_name(), addr0, this.get_address(1, maps[i]) - addr0);
             end
           end
%000000    foreach(this.fields[i]) begin
%000000      $sformat(convert2string, "%s\n%s", convert2string,
%000000                this.fields[i].convert2string());
           end
        
        endfunction: convert2string
        
        
        
        //TODO - add fatal messages
%000000 function uvm_object uvm_vreg::clone();
%000000   return null;
        endfunction
        
%000000 function void uvm_vreg::do_copy   (uvm_object rhs);
        endfunction
        
%000000 function bit uvm_vreg::do_compare (uvm_object  rhs,
                                                uvm_comparer comparer);
%000000   return 0;
        endfunction
        
%000000 function void uvm_vreg::do_pack (uvm_packer packer);
        endfunction
        
%000000 function void uvm_vreg::do_unpack (uvm_packer packer);
        endfunction
        
