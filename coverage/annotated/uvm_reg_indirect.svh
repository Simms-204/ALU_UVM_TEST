//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2020 Mentor Graphics Corporation
        // Copyright 2015-2024 NVIDIA Corporation
        // Copyright 2010-2012 Synopsys, Inc.
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
        // $File:     src/reg/uvm_reg_indirect.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        typedef class uvm_reg_indirect_ftdr_seq;
        
        //-----------------------------------------------------------------
        // CLASS -- NODOCS -- uvm_reg_indirect_data
        // Indirect data access abstraction class
        //
        // Models the behavior of a register used to indirectly access
        // a register array, indexed by a second ~address~ register.
        //
        // This class should not be instantiated directly.
        // A type-specific class extension should be used to
        // provide a factory-enabled constructor and specify the
        // ~n_bits~ and coverage models.
        //-----------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.7.1
        class uvm_reg_indirect_data extends uvm_reg;
        
           protected uvm_reg m_idx;
           protected uvm_reg m_tbl[];
        
        
           // @uvm-ieee 1800.2-2020 auto 18.7.2.1
%000000    function new(string name = "uvm_reg_indirect",
                        int unsigned n_bits,
                        int has_cover);
%000000       super.new(name,n_bits,has_cover);
           endfunction: new
        
%000000    virtual function void build();
           endfunction: build
        
        
           // @uvm-ieee 1800.2-2020 auto 18.7.2.2
%000000    function void configure (uvm_reg idx,
                                    uvm_reg reg_a[],
                                    uvm_reg_block blk_parent,
                                    uvm_reg_file regfile_parent = null);
%000000       super.configure(blk_parent, regfile_parent, "");
%000000       m_idx = idx;
%000000       m_tbl = reg_a;
        
              // Not testable using pre-defined sequences
%000000       uvm_resource_db#(bit)::set({"REG::", get_full_name()},
%000000                                  "NO_REG_TESTS", 1);
        
              // Add a frontdoor to each indirectly-accessed register
              // for every address map this register is in.
%000000       foreach (m_maps[map]) begin
%000000         add_frontdoors(map);
              end
           endfunction
           
%000000    /*local*/ virtual function void add_map(uvm_reg_map map);
%000000       super.add_map(map);
%000000       add_frontdoors(map);
           endfunction
           
           
%000000    local function void add_frontdoors(uvm_reg_map map);
%000000       foreach (m_tbl[i]) begin
%000000         uvm_reg_indirect_ftdr_seq fd;
%000000         if (m_tbl[i] == null) begin
                  `uvm_error(get_full_name(),
%000000           $sformatf("Indirect register #%0d is NULL", i))
%000000           continue;
                end
%000000         fd = new(m_idx, i, this);
%000000         if (m_tbl[i].is_in_map(map)) begin
                    
%000000           m_tbl[i].set_frontdoor(fd, map);
                end
        
%000000         else begin
                    
%000000           map.add_reg(m_tbl[i], -1, "RW", 1, fd);
                end
        
              end
           endfunction
           
%000000    virtual function void do_predict (uvm_reg_item      rw,
                                             uvm_predict_e     kind = UVM_PREDICT_DIRECT,
                                             uvm_reg_byte_en_t be = -1);
%000000       if (m_idx.get() >= m_tbl.size()) begin
%000000         `uvm_error(get_full_name(), $sformatf("Address register %s has a value (%0d) greater than the maximum indirect register array size (%0d)", m_idx.get_full_name(), m_idx.get(), m_tbl.size()))
%000000         rw.set_status(UVM_NOT_OK);
%000000         return;
              end
        
              //NOTE limit to 2**32 registers
%000000       begin
%000000         int unsigned idx = m_idx.get();
%000000         m_tbl[idx].do_predict(rw, kind, be);
              end
           endfunction
        
        
%000000    virtual function uvm_reg_map get_local_map(uvm_reg_map map);
%000000       return  m_idx.get_local_map(map);
           endfunction
        
           //
           // Just for good measure, to catch and short-circuit non-sensical uses
           //
%000000    virtual function void add_field  (uvm_reg_field field);
%000000       `uvm_error(get_full_name(), "Cannot add field to an indirect data access register")
           endfunction
        
%000000    virtual function void set (uvm_reg_data_t  value,
                                      string          fname = "",
                                      int             lineno = 0);
%000000       `uvm_error(get_full_name(), "Cannot set() an indirect data access register")
           endfunction
           
%000000    virtual function uvm_reg_data_t  get(string  fname = "",
                                                int     lineno = 0);
%000000       `uvm_error(get_full_name(), "Cannot get() an indirect data access register")
%000000       return 0;
           endfunction
           
%000000    virtual function uvm_reg get_indirect_reg(string  fname = "",
                                                int     lineno = 0);
%000000       int unsigned idx = m_idx.get_mirrored_value();
%000000       return(m_tbl[idx]);
           endfunction
        
%000000    virtual function bit needs_update();
%000000       return 0;
           endfunction
        
%000000    virtual task write(output uvm_status_e      status,
                              input  uvm_reg_data_t    value,
                              input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                              input  uvm_reg_map       map = null,
                              input  uvm_sequence_base parent = null,
                              input  int               prior = -1,
                              input  uvm_object        extension = null,
                              input  string            fname = "",
                              input  int               lineno = 0);
        
%000000       if (path == UVM_DEFAULT_DOOR) begin
%000000         uvm_reg_block blk = get_parent();
%000000         path = blk.get_default_door();
              end
              
%000000       if (path == UVM_BACKDOOR) begin
%000000         `uvm_warning(get_full_name(), "Cannot backdoor-write an indirect data access register. Switching to frontdoor.")
%000000         path = UVM_FRONTDOOR;
              end
        
              // Can't simply call super.write() because it'll call set()
%000000       begin
%000000         uvm_reg_item rw;
        
%000000         XatomicX(1);
        
%000000         rw = uvm_reg_item::type_id::create("write_item",,get_full_name());
%000000         rw.set_element(this);
%000000         rw.set_element_kind(UVM_REG);
%000000         rw.set_kind(UVM_WRITE);
%000000         rw.set_value(value,0);
%000000         rw.set_door(path);
%000000         rw.set_map(map);
%000000         rw.set_parent_sequence(parent);
%000000         rw.set_priority(prior);
%000000         rw.set_extension(extension);
%000000         rw.set_fname(fname);
%000000         rw.set_line(lineno);
                 
%000000         do_write(rw);
        
%000000         status = rw.get_status();
        
%000000         XatomicX(0);
              end
           endtask
        
%000000    virtual task read(output uvm_status_e      status,
%000000                      output uvm_reg_data_t    value,
                             input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                             input  uvm_reg_map       map = null,
                             input  uvm_sequence_base parent = null,
                             input  int               prior = -1,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);
        
%000000       if (path == UVM_DEFAULT_DOOR) begin
%000000         uvm_reg_block blk = get_parent();
%000000         path = blk.get_default_door();
              end
              
%000000       if (path == UVM_BACKDOOR) begin
%000000         `uvm_warning(get_full_name(), "Cannot backdoor-read an indirect data access register. Switching to frontdoor.")
%000000         path = UVM_FRONTDOOR;
              end
              
%000000       super.read(status, value, path, map, parent, prior, extension, fname, lineno);
           endtask
        
%000000    virtual task poke(output uvm_status_e      status,
                             input  uvm_reg_data_t    value,
                             input  string            kind = "",
                             input  uvm_sequence_base parent = null,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);
%000000       `uvm_error(get_full_name(), "Cannot poke() an indirect data access register")
%000000       status = UVM_NOT_OK;
           endtask
        
%000000    virtual task peek(output uvm_status_e      status,
%000000                      output uvm_reg_data_t    value,
                             input  string            kind = "",
                             input  uvm_sequence_base parent = null,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);
%000000       `uvm_error(get_full_name(), "Cannot peek() an indirect data access register")
%000000       status = UVM_NOT_OK;
           endtask
        
%000000    virtual task update(output uvm_status_e      status,
                               input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                               input  uvm_reg_map       map = null,
                               input  uvm_sequence_base parent = null,
                               input  int               prior = -1,
                               input  uvm_object        extension = null,
                               input  string            fname = "",
                               input  int               lineno = 0);
%000000       status = UVM_IS_OK;
           endtask
           
%000000    virtual task mirror(output uvm_status_e      status,
                               input uvm_check_e        check  = UVM_NO_CHECK,
                               input uvm_door_e         path = UVM_DEFAULT_DOOR,
                               input uvm_reg_map        map = null,
                               input uvm_sequence_base  parent = null,
                               input int                prior = -1,
                               input  uvm_object        extension = null,
                               input string             fname = "",
                               input int                lineno = 0);
%000000       status = UVM_IS_OK;
           endtask
           
        endclass : uvm_reg_indirect_data
        
        
        class uvm_reg_indirect_ftdr_seq extends uvm_reg_frontdoor;
           local uvm_reg m_addr_reg;
           local uvm_reg m_data_reg;
           local int     m_idx;
           
%000000    function new(uvm_reg addr_reg,
                        int idx,
                        uvm_reg data_reg);
%000000       super.new("uvm_reg_indirect_ftdr_seq");
%000000       m_addr_reg = addr_reg;
%000000       m_idx      = idx;
%000000       m_data_reg = data_reg;
           endfunction: new
        
%000000    virtual task body();
        
%000000       uvm_reg_item rw;
              
%000000       $cast(rw,rw_info.clone());
%000000       rw.element = m_addr_reg;
%000000       rw.kind    = UVM_WRITE;
%000000       rw.value[0]= m_idx;
        
%000000       m_addr_reg.XatomicX(1);
%000000       m_data_reg.XatomicX(1);
              
%000000       m_addr_reg.do_write(rw);
        
%000000       if (rw.status == UVM_NOT_OK) begin
                
%000000         return;
              end
        
        
%000000       $cast(rw,rw_info.clone());
%000000       rw.element = m_data_reg;
        
%000000       if (rw_info.get_kind() == UVM_WRITE) begin
                
%000000         m_data_reg.do_write(rw);
              end
        
%000000       else begin
%000000         m_data_reg.do_read(rw);
%000000         rw_info.set_value(rw.get_value(0), 0);
              end
        
%000000       m_addr_reg.XatomicX(0);
%000000       m_data_reg.XatomicX(0);
              
%000000       rw_info.set_status(rw.get_status());
           endtask
        
        endclass
        
