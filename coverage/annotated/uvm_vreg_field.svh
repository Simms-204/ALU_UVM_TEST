//      // verilator_coverage annotation
        //
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2011 Mentor Graphics Corporation
        // Copyright 2026 Microsoft
        // Copyright 2014-2026 NVIDIA Corporation
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
        // $File:     src/reg/uvm_vreg_field.svh $
        // $Rev:      2026-06-10 09:59:36 -0700 $
        // $Hash:     d69bd29b12f83a7fb6866ad5fd1247d0968f1bca $
        //
        //----------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Virtual Register Field Classes
        //
        // This section defines the virtual field and callback classes.
        //
        // A virtual field is set of contiguous bits in one or more memory locations.
        // The semantics and layout of virtual fields comes from
        // an agreement between the software and the hardware,
        // not any physical structures in the DUT.
        //
        //------------------------------------------------------------------------------
        
        
        typedef class uvm_vreg_field_cbs;
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_vreg_field
        //
        // Virtual field abstraction class
        //
        // A virtual field represents a set of adjacent bits that are
        // logically implemented in consecutive memory locations.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.10.1
        class uvm_vreg_field extends uvm_object;
        
%000000    `uvm_object_utils(uvm_vreg_field)
%000003    `uvm_register_cb(uvm_vreg_field, uvm_vreg_field_cbs)
        
           local uvm_vreg parent;
           local int unsigned lsb;
           local int unsigned size;
           local string fname;
           local int lineno;
           local bit read_in_progress;
           local bit write_in_progress;
        
        
           //
           // Group -- NODOCS -- initialization
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.2.1
           extern function new(string name = "uvm_vreg_field");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.2.2
           extern function void configure(uvm_vreg parent,
                                          int unsigned size,
                                          int unsigned lsb_pos);
        
        
           //
           // Group -- NODOCS -- Introspection
           //
        
           //
           // Function -- NODOCS -- get_name
           // Get the simple name
           //
           // Return the simple object name of this virtual field
           //
        
           //
           // Function -- NODOCS -- get_full_name
           // Get the hierarchical name
           //
           // Return the hierarchal name of this virtual field
           // The base of the hierarchical name is the root block.
           //
           extern virtual function string        get_full_name();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.3.1
           extern virtual function uvm_vreg get_parent();
           extern virtual function uvm_vreg get_register();
        
           //
           // FUNCTION -- NODOCS -- get_lsb_pos_in_register
           // Return the position of the virtual field
           ///
           // Returns the index of the least significant bit of the virtual field
           // in the virtual register that instantiates it.
           // An offset of 0 indicates a field that is aligned with the
           // least-significant bit of the register.
           //
           extern virtual function int unsigned get_lsb_pos_in_register();
        
           //
           // FUNCTION -- NODOCS -- get_n_bits
           // Returns the width, in bits, of the virtual field.
           //
           extern virtual function int unsigned get_n_bits();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.3.4
           extern virtual function string get_access(uvm_reg_map map = null);
        
        
           //
           // Group -- NODOCS -- HDL Access
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.4.1
           extern virtual task write(input  longint unsigned   idx,
                                     output uvm_status_e  status,
                                     input  uvm_reg_data_t     value,
                                     input  uvm_door_e    path = UVM_DEFAULT_DOOR,
                                     input  uvm_reg_map        map = null,
                                     input  uvm_sequence_base  parent = null,
                                     input  uvm_object         extension = null,
                                     input  string             fname = "",
                                     input  int                lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.4.2
           extern virtual task read(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    output uvm_reg_data_t      value,
                                    input  uvm_door_e     path = UVM_DEFAULT_DOOR,
                                    input  uvm_reg_map         map = null,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.4.3
           extern virtual task poke(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    input  uvm_reg_data_t      value,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.4.4
           extern virtual task peek(input  longint unsigned    idx,
                                    output uvm_status_e   status,
                                    output uvm_reg_data_t      value,
                                    input  uvm_sequence_base   parent = null,
                                    input  uvm_object          extension = null,
                                    input  string              fname = "",
                                    input  int                 lineno = 0);
        
           //
           // Group -- NODOCS -- Callbacks
           //
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.5.1
%000000    virtual task pre_write(longint unsigned     idx,
                                  ref uvm_reg_data_t   wdat,
                                  ref uvm_door_e  path,
                                  ref uvm_reg_map   map);
           endtask: pre_write
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.5.2
%000000    virtual task post_write(longint unsigned       idx,
                                   uvm_reg_data_t         wdat,
                                   uvm_door_e        path,
                                   uvm_reg_map         map,
                                   ref uvm_status_e  status);
           endtask: post_write
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.5.3
%000000    virtual task pre_read(longint unsigned      idx,
                                 ref uvm_door_e   path,
                                 ref uvm_reg_map    map);
           endtask: pre_read
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.5.4
%000000    virtual task post_read(longint unsigned       idx,
                                  ref uvm_reg_data_t     rdat,
                                  uvm_door_e        path,
                                  uvm_reg_map         map,
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
        
        endclass: uvm_vreg_field
        
        
        //------------------------------------------------------------------------------
        // Class -- NODOCS -- uvm_vreg_field_cbs
        //
        // Pre/post read/write callback facade class
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.10.6.1
        virtual class uvm_vreg_field_cbs extends uvm_callback;
           string fname;
           int    lineno;
        
        
%000000    `uvm_object_abstract_utils(uvm_vreg_field_cbs)
        
%000000    function new(string name = "uvm_vreg_field_cbs");
%000000       super.new(name);
           endfunction
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.6.2.1
%000000    virtual task pre_write(uvm_vreg_field       field,
                                  longint unsigned     idx,
                                  ref uvm_reg_data_t   wdat,
                                  ref uvm_door_e  path,
                                  ref uvm_reg_map   map);
           endtask: pre_write
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.6.2.2
%000000    virtual task post_write(uvm_vreg_field        field,
                                   longint unsigned      idx,
                                   uvm_reg_data_t        wdat,
                                   uvm_door_e       path,
                                   uvm_reg_map        map,
                                   ref uvm_status_e status);
           endtask: post_write
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.6.2.3
%000000    virtual task pre_read(uvm_vreg_field        field,
                                 longint unsigned      idx,
                                 ref uvm_door_e   path,
                                 ref uvm_reg_map    map);
           endtask: pre_read
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.10.6.2.4
%000000    virtual task post_read(uvm_vreg_field         field,
                                  longint unsigned       idx,
                                  ref uvm_reg_data_t     rdat,
                                  uvm_door_e        path,
                                  uvm_reg_map         map,
                                  ref uvm_status_e  status);
           endtask: post_read
        endclass: uvm_vreg_field_cbs
        
        
        //
        // Type -- NODOCS -- uvm_vreg_field_cb
        // Convenience callback type declaration
        //
        // Use this declaration to register virtual field callbacks rather than
        // the more verbose parameterized class
        //
        typedef uvm_callbacks#(uvm_vreg_field, uvm_vreg_field_cbs) uvm_vreg_field_cb /* @uvm-ieee 1800.2-2020 auto D.4.5.11*/ ;
        
        //
        // Type -- NODOCS -- uvm_vreg_field_cb_iter
        // Convenience callback iterator type declaration
        //
        // Use this declaration to iterate over registered virtual field callbacks
        // rather than the more verbose parameterized class
        //
        typedef uvm_callback_iter#(uvm_vreg_field, uvm_vreg_field_cbs) uvm_vreg_field_cb_iter /* @uvm-ieee 1800.2-2020 auto D.4.5.12*/ ;
        
        
        
        
%000000 function uvm_vreg_field::new(string name="uvm_vreg_field");
%000000    super.new(name);
        endfunction: new
        
%000000 function void uvm_vreg_field::configure(uvm_vreg  parent,
                                           int unsigned  size,
                                           int unsigned  lsb_pos);
%000000    this.parent = parent;
%000000    if (size == 0) begin
%000000      `uvm_error("RegModel", $sformatf("Virtual field \"%s\" cannot have 0 bits", this.get_full_name()))
%000000      size = 1;
           end
%000000    if (size > `UVM_REG_DATA_WIDTH) begin
             `uvm_error("RegModel", $sformatf("Virtual field \"%s\" cannot have more than %0d bits",
             this.get_full_name(),
%000000      `UVM_REG_DATA_WIDTH))
%000000      size = `UVM_REG_DATA_WIDTH;
           end
        
%000000    this.size   = size;
%000000    this.lsb    = lsb_pos;
        
%000000    this.parent.add_field(this);
        endfunction: configure
        
        
        
%000000 function string uvm_vreg_field::get_full_name();
%000000    get_full_name = {this.parent.get_full_name(), ".", this.get_name()};
        endfunction: get_full_name
        
        
%000000 function uvm_vreg uvm_vreg_field::get_register();
%000000    get_register = this.parent;
        endfunction: get_register
        
        
%000000 function uvm_vreg uvm_vreg_field::get_parent();
%000000    get_parent = this.parent;
        endfunction: get_parent
        
        
        
%000000 function int unsigned uvm_vreg_field::get_lsb_pos_in_register();
%000000    get_lsb_pos_in_register = this.lsb;
        endfunction: get_lsb_pos_in_register
        
        
%000000 function int unsigned uvm_vreg_field::get_n_bits();
%000000    get_n_bits = this.size;
        endfunction: get_n_bits
        
        
%000000 function string uvm_vreg_field::get_access(uvm_reg_map map = null);
%000000    if (this.parent.get_memory() == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg_field::get_rights() on unimplemented virtual field \"%s\"",
%000000      this.get_full_name()))
%000000      return "RW";
           end
        
%000000    return this.parent.get_access(map);
        endfunction: get_access
        
        
%000000 task uvm_vreg_field::write(input  longint unsigned    idx,
%000000                            output uvm_status_e   status,
                                   input  uvm_reg_data_t      value,
                                   input  uvm_door_e     path = UVM_DEFAULT_DOOR,
                                   input  uvm_reg_map      map = null,
                                   input  uvm_sequence_base   parent = null,
                                   input  uvm_object          extension = null,
                                   input  string              fname = "",
                                   input  int                 lineno = 0);
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  segval;
%000000    uvm_reg_addr_t  segoff;
%000000    uvm_status_e st;
        
%000000    int flsb, fmsb, rmwbits;
%000000    int segsiz, segn;
%000000    uvm_mem    mem;
%000000    uvm_door_e rm_path;
        
%000000    uvm_vreg_field_cb_iter cbs = new(this);
        
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    write_in_progress = 1'b1;
%000000    mem = this.parent.get_memory();
%000000    if (mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg_field::write() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if (path == UVM_DEFAULT_DOOR) begin
%000000      uvm_reg_block blk = this.parent.get_block();
%000000      path = blk.get_default_door();
           end
        
%000000    status = UVM_IS_OK;
        
%000000    this.parent.XatomicX(1);
        
%000000    if (value >> this.size) begin
%000000      `uvm_warning("RegModel", $sformatf("Writing value 'h%h that is greater than field \"%s\" size (%0d bits)", value, this.get_full_name(), this.get_n_bits()))
%000000      value &= value & ((1<<this.size)-1);
           end
%000000    tmp = 0;
        
%000000    this.pre_write(idx, value, path, map);
%000000    for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.pre_write(this, idx, value, path, map);
           end
        
%000000    segsiz = mem.get_n_bytes() * 8;
%000000    flsb    = this.get_lsb_pos_in_register();
%000000    segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
        
           // Favor backdoor read to frontdoor read for the RMW operation
%000000    rm_path = UVM_DEFAULT_DOOR;
%000000    if (mem.get_backdoor() != null) begin
%000000      rm_path = UVM_BACKDOOR;
           end
        
        
           // Any bits on the LSB side we need to RMW?
%000000    rmwbits = flsb % segsiz;
        
           // Total number of memory segment in this field
%000000    segn = (rmwbits + this.get_n_bits() - 1) / segsiz + 1;
        
%000000    if (rmwbits > 0) begin
%000000      uvm_reg_addr_t  segn;
        
%000000      mem.read(st, segoff, tmp, rm_path, map, parent, , extension, fname, lineno);
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
               `uvm_error("RegModel",
               $sformatf("Unable to read LSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
%000000        mem.get_full_name(), segoff, this.get_full_name()))
%000000        status = UVM_NOT_OK;
%000000        this.parent.XatomicX(0);
%000000        return;
             end
        
%000000      value = (value << rmwbits) | (tmp & ((1<<rmwbits)-1));
           end
        
           // Any bits on the MSB side we need to RMW?
%000000    fmsb = rmwbits + this.get_n_bits() - 1;
%000000    rmwbits = (fmsb+1) % segsiz;
%000000    if (rmwbits > 0) begin
%000000      if (segn > 0) begin
%000000        mem.read(st, segoff + segn - 1, tmp, rm_path, map, parent,, extension, fname, lineno);
%000000        if (st != UVM_IS_OK && st != UVM_HAS_X) begin
                 `uvm_error("RegModel",
                 $sformatf("Unable to read MSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                 mem.get_full_name(), segoff+segn-1,
%000000          this.get_full_name()))
%000000          status = UVM_NOT_OK;
%000000          this.parent.XatomicX(0);
%000000          return;
               end
             end
%000000      value |= (tmp & ~((1<<rmwbits)-1)) << ((segn-1)*segsiz);
           end
        
           // Now write each of the segments
%000000    tmp = value;
%000000    repeat (segn) begin
%000000      mem.write(st, segoff, tmp, path, map, parent,, extension, fname, lineno);
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
%000000        status = UVM_NOT_OK;
             end
        
        
%000000      segoff++;
%000000      tmp = tmp >> segsiz;
           end
        
%000000    this.post_write(idx, value, path, map, status);
%000000    for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.post_write(this, idx, value, path, map, status);
           end
        
%000000    this.parent.XatomicX(0);
        
        
           `uvm_info("RegModel", $sformatf("Wrote virtual field \"%s\"[%0d] via %s with: 'h%h",
                                      this.get_full_name(), idx,
                                      (path == UVM_FRONTDOOR) ? "frontdoor" : "backdoor",
%000000                               value),UVM_MEDIUM)
        
%000000    write_in_progress = 1'b0;
%000000    this.fname = "";
%000000    this.lineno = 0;
        endtask: write
        
        
%000000 task uvm_vreg_field::read(input longint unsigned     idx,
%000000                           output uvm_status_e   status,
%000000                           output uvm_reg_data_t      value,
                                  input  uvm_door_e     path = UVM_DEFAULT_DOOR,
                                  input  uvm_reg_map      map = null,
                                  input  uvm_sequence_base   parent = null,
                                  input  uvm_object          extension = null,
                                  input  string              fname = "",
                                  input  int                 lineno = 0);
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  segval;
%000000    uvm_reg_addr_t  segoff;
%000000    uvm_status_e st;
        
%000000    int flsb, lsb;
%000000    int segsiz, segn;
%000000    uvm_mem    mem;
        
%000000    uvm_vreg_field_cb_iter cbs = new(this);
        
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    read_in_progress = 1'b1;
%000000    mem = this.parent.get_memory();
%000000    if (mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg_field::read() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if (path == UVM_DEFAULT_DOOR) begin
%000000      uvm_reg_block blk = this.parent.get_block();
%000000      path = blk.get_default_door();
           end
        
%000000    status = UVM_IS_OK;
        
%000000    this.parent.XatomicX(1);
        
%000000    value = 0;
        
%000000    this.pre_read(idx, path, map);
%000000    for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.pre_read(this, idx, path, map);
           end
        
%000000    segsiz = mem.get_n_bytes() * 8;
%000000    flsb    = this.get_lsb_pos_in_register();
%000000    segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
%000000    lsb = flsb % segsiz;
        
           // Total number of memory segment in this field
%000000    segn = (lsb + this.get_n_bits() - 1) / segsiz + 1;
        
           // Read each of the segments, MSB first
%000000    segoff += segn - 1;
%000000    repeat (segn) begin
%000000      value = value << segsiz;
        
%000000      mem.read(st, segoff, tmp, path, map, parent, , extension, fname, lineno);
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
%000000        status = UVM_NOT_OK;
             end
        
        
%000000      segoff--;
%000000      value |= tmp;
           end
        
           // Any bits on the LSB side we need to get rid of?
%000000    value = value >> lsb;
        
           // Any bits on the MSB side we need to get rid of?
%000000    value &= (1<<this.get_n_bits()) - 1;
        
%000000    this.post_read(idx, value, path, map, status);
%000000    for (uvm_vreg_field_cbs cb = cbs.first(); cb != null;
%000000      cb = cbs.next()) begin
%000000      cb.fname = this.fname;
%000000      cb.lineno = this.lineno;
%000000      cb.post_read(this, idx, value, path, map, status);
           end
        
%000000    this.parent.XatomicX(0);
        
           `uvm_info("RegModel", $sformatf("Read virtual field \"%s\"[%0d] via %s: 'h%h",
                                      this.get_full_name(), idx,
                                      (path == UVM_FRONTDOOR) ? "frontdoor" : "backdoor",
%000000                               value),UVM_MEDIUM)
        
        
%000000    read_in_progress = 1'b0;
%000000    this.fname = "";
%000000    this.lineno = 0;
        endtask: read
        
        
%000000 task uvm_vreg_field::poke(input  longint unsigned  idx,
%000000                           output uvm_status_e status,
                                  input  uvm_reg_data_t    value,
                                  input  uvm_sequence_base parent = null,
                                  input  uvm_object        extension = null,
                                  input  string            fname = "",
                                  input  int               lineno = 0);
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  segval;
%000000    uvm_reg_addr_t  segoff;
%000000    uvm_status_e st;
        
%000000    int flsb, fmsb, rmwbits;
%000000    int segsiz, segn;
%000000    uvm_mem    mem;
%000000    uvm_door_e rm_path;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    mem = this.parent.get_memory();
%000000    if (mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg_field::poke() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    status = UVM_IS_OK;
        
%000000    this.parent.XatomicX(1);
%000000    if ($isunknown(value >> this.size)) begin
%000000      `uvm_warning("RegModel", $sformatf("Writing value 'h%h that has unknown bits that can allow for a value greater than field \"%s\" size (%0d bits)", value, this.get_full_name(), this.get_n_bits()))
%000000      value &= ((1<<this.size)-1);
           end
%000000    else if (value >> this.size) begin
%000000      `uvm_warning("RegModel", $sformatf("Writing value 'h%h that is greater than field \"%s\" size (%0d bits)", value, this.get_full_name(), this.get_n_bits()))
%000000      value &= ((1<<this.size)-1);
           end
%000000    tmp = 0;
        
%000000    segsiz = mem.get_n_bytes() * 8;
%000000    flsb    = this.get_lsb_pos_in_register();
%000000    segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
        
           // Any bits on the LSB side we need to RMW?
%000000    rmwbits = flsb % segsiz;
        
           // Total number of memory segment in this field
%000000    segn = (rmwbits + this.get_n_bits() - 1) / segsiz + 1;
        
%000000    if (rmwbits > 0) begin
%000000      uvm_reg_addr_t  segn;
        
%000000      mem.peek(st, segoff, tmp, "", parent, extension, fname, lineno);
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
               `uvm_error("RegModel",
               $sformatf("Unable to read LSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
%000000        mem.get_full_name(), segoff, this.get_full_name()))
%000000        status = UVM_NOT_OK;
%000000        this.parent.XatomicX(0);
%000000        return;
             end
        
%000000      value = (value << rmwbits) | (tmp & ((1<<rmwbits)-1));
           end
        
           // Any bits on the MSB side we need to RMW?
%000000    fmsb = rmwbits + this.get_n_bits() - 1;
%000000    rmwbits = (fmsb+1) % segsiz;
%000000    if (rmwbits > 0) begin
%000000      if (segn > 0) begin
%000000        mem.peek(st, segoff + segn - 1, tmp, "", parent, extension, fname, lineno);
%000000        if (st != UVM_IS_OK && st != UVM_HAS_X) begin
                 `uvm_error("RegModel",
                 $sformatf("Unable to read MSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                 mem.get_full_name(), segoff+segn-1,
%000000          this.get_full_name()))
%000000          status = UVM_NOT_OK;
%000000          this.parent.XatomicX(0);
%000000          return;
               end
             end
%000000      value |= (tmp & ~((1<<rmwbits)-1)) << ((segn-1)*segsiz);
           end
        
           // Now write each of the segments
%000000    tmp = value;
%000000    repeat (segn) begin
%000000      mem.poke(st, segoff, tmp, "", parent, extension, fname, lineno);
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
%000000        status = UVM_NOT_OK;
             end
        
        
%000000      segoff++;
%000000      tmp = tmp >> segsiz;
           end
        
%000000    this.parent.XatomicX(0);
        
           `uvm_info("RegModel", $sformatf("Wrote virtual field \"%s\"[%0d] with: 'h%h",
%000000                               this.get_full_name(), idx, value),UVM_MEDIUM)
        
%000000    this.fname = "";
%000000    this.lineno = 0;
        endtask: poke
        
        
%000000 task uvm_vreg_field::peek(input  longint unsigned  idx,
%000000                           output uvm_status_e status,
%000000                           output uvm_reg_data_t    value,
                                  input  uvm_sequence_base parent = null,
                                  input  uvm_object        extension = null,
                                  input  string            fname = "",
                                  input  int               lineno = 0);
%000000    uvm_reg_data_t  tmp;
%000000    uvm_reg_data_t  segval;
%000000    uvm_reg_addr_t  segoff;
%000000    uvm_status_e st;
        
%000000    int flsb, lsb;
%000000    int segsiz, segn;
%000000    uvm_mem    mem;
%000000    this.fname = fname;
%000000    this.lineno = lineno;
        
%000000    mem = this.parent.get_memory();
%000000    if (mem == null) begin
             `uvm_error("RegModel", $sformatf("Cannot call uvm_vreg_field::peek() on unimplemented virtual register \"%s\"",
%000000      this.get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    status = UVM_IS_OK;
        
%000000    this.parent.XatomicX(1);
        
%000000    value = 0;
        
%000000    segsiz = mem.get_n_bytes() * 8;
%000000    flsb    = this.get_lsb_pos_in_register();
%000000    segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
%000000    lsb = flsb % segsiz;
        
           // Total number of memory segment in this field
%000000    segn = (lsb + this.get_n_bits() - 1) / segsiz + 1;
        
           // Read each of the segments, MSB first
%000000    segoff += segn - 1;
%000000    repeat (segn) begin
%000000      value = value << segsiz;
        
%000000      mem.peek(st, segoff, tmp, "", parent, extension, fname, lineno);
        
%000000      if (st != UVM_IS_OK && st != UVM_HAS_X) begin
%000000        status = UVM_NOT_OK;
             end
        
        
%000000      segoff--;
%000000      value |= tmp;
           end
        
           // Any bits on the LSB side we need to get rid of?
%000000    value = value >> lsb;
        
           // Any bits on the MSB side we need to get rid of?
%000000    value &= (1<<this.get_n_bits()) - 1;
        
%000000    this.parent.XatomicX(0);
        
%000000    `uvm_info("RegModel", $sformatf("Peeked virtual field \"%s\"[%0d]: 'h%h", this.get_full_name(), idx, value),UVM_MEDIUM)
        
%000000    this.fname = "";
%000000    this.lineno = 0;
        endtask: peek
        
        
%000000 function void uvm_vreg_field::do_print (uvm_printer printer);
%000000   super.do_print(printer);
%000000   printer.print_generic("initiator", parent.get_type_name(), -1, convert2string());
        endfunction
        
%000000 function string uvm_vreg_field::convert2string();
%000000    string res_str;
%000000    string t_str;
%000000    bit with_debug_info = 1'b0;
%000000    $sformat(convert2string, {"%s[%0d-%0d]"},
%000000             this.get_name(),
%000000             this.get_lsb_pos_in_register() + this.get_n_bits() - 1,
%000000             this.get_lsb_pos_in_register());
%000000    if (read_in_progress == 1'b1) begin
%000000      if (fname != "" && lineno != 0) begin
        
%000000        $sformat(res_str, "%s:%0d ",fname, lineno);
             end
        
%000000      convert2string = {convert2string, "\n", res_str, "currently executing read method"};
           end
%000000    if ( write_in_progress == 1'b1) begin
%000000      if (fname != "" && lineno != 0) begin
        
%000000        $sformat(res_str, "%s:%0d ",fname, lineno);
             end
        
%000000      convert2string = {convert2string, "\n", res_str, "currently executing write method"};
           end
        
        endfunction
        
        //TODO - add fatal messages
        
%000000 function uvm_object uvm_vreg_field::clone();
%000000   return null;
        endfunction
        
%000000 function void uvm_vreg_field::do_copy   (uvm_object rhs);
        endfunction
        
%000000 function bit uvm_vreg_field::do_compare (uvm_object  rhs,
                                                uvm_comparer comparer);
%000000   return 0;
        endfunction
        
%000000 function void uvm_vreg_field::do_pack (uvm_packer packer);
        endfunction
        
%000000 function void uvm_vreg_field::do_unpack (uvm_packer packer);
        endfunction
        
