//      // verilator_coverage annotation
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
        // Copyright 2014-2017 Intel Corporation
        // Copyright 2021-2023 Marvell International Ltd.
        // Copyright 2010-2020 Mentor Graphics Corporation
        // Copyright 2026 Microsoft
        // Copyright 2014-2026 NVIDIA Corporation
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
        // $File:     src/reg/uvm_reg_map.svh $
        // $Rev:      2026-06-10 09:59:36 -0700 $
        // $Hash:     d69bd29b12f83a7fb6866ad5fd1247d0968f1bca $
        //
        //----------------------------------------------------------------------
        
        // Class -- NODOCS -- uvm_reg_transaction_order_policy
        // Not in LRM.
%000000 class uvm_reg_map_info;
          uvm_reg_addr_t         offset;
          string                 rights;
          bit                    unmapped;
          uvm_reg_addr_t         addr[];
          uvm_reg_frontdoor      frontdoor;
          uvm_reg_map_addr_range mem_range;
        
          // if set marks the uvm_reg_map_info as initialized, prevents using an uninitialized map (for instance if the model
          // has not been locked accidently and the maps have not been computed before)
          bit                    is_initialized;
        endclass
        
        
        // Class -- NODOCS -- uvm_reg_transaction_order_policy
        virtual class uvm_reg_transaction_order_policy extends uvm_object;
%000000   function new(string name = "policy");
%000000     super.new(name);
          endfunction
        
          // Function -- NODOCS -- order
          // the order() function may reorder the sequence of bus transactions
          // produced by a single uvm_reg transaction (read/write).
          // This can be used in scenarios when the register width differs from
          // the bus width and one register access results in a series of bus transactions.
          // the first item (0) of the queue will be the first bus transaction (the last($)
          // will be the final transaction
%000000   pure virtual function void order(ref uvm_reg_bus_op q[$]);
        endclass
        
        // Extends virtual class uvm_sequence_base so that it can be constructed:
        class uvm_reg_seq_base extends uvm_sequence_base;
        
%000000   `uvm_object_utils(uvm_reg_seq_base)
        
        
%000000   function new(string name = "uvm_reg_seq_base");
%000000     super.new(name);
          endfunction
        
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_reg_map
        //
        // :Address map abstraction class
        //
        // This class represents an address map.
        // An address map is a collection of registers and memories
        // accessible via a specific physical interface.
        // Address maps can be composed into higher-level address maps.
        //
        // Address maps are created using the <uvm_reg_block::create_map()>
        // method.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.2.1
        class uvm_reg_map extends uvm_object;
        
%000000   `uvm_object_utils(uvm_reg_map)
        
          // info that is valid only if top-level map
          local uvm_reg_addr_t     m_base_addr;
          local int unsigned       m_n_bytes;
          local uvm_endianness_e   m_endian;
          local bit m_byte_addressing;
          local uvm_object_wrapper m_sequence_wrapper;
          local uvm_reg_adapter    m_adapter;
          local uvm_sequencer_base m_sequencer;
          local bit m_auto_predict;
          local bit m_check_on_read;
        
          local uvm_reg_block      m_parent;
        
          local int unsigned       m_system_n_bytes;
        
          local uvm_reg_map        m_parent_map;
          local uvm_reg_addr_t     m_submaps[uvm_reg_map];       // value=offset of submap at this level
          local string m_submap_rights[uvm_reg_map]; // value=rights of submap at this level
        
          local uvm_reg_map_info   m_regs_info[uvm_reg];
          local uvm_reg_map_info   m_mems_info[uvm_mem];
        
          local uvm_reg            m_regs_by_offset[uvm_reg_addr_t];
          // Use only in addition to above if a RO and a WO
          // register share the same address.
          local uvm_reg            m_regs_by_offset_wo[uvm_reg_addr_t];
          local uvm_mem            m_mems_by_offset[uvm_reg_map_addr_range];
        
          local uvm_reg_transaction_order_policy policy;
        
          extern /*local*/ function void Xinit_address_mapX();
        
            static local uvm_reg_map   m_backdoor;
        
        
            // @uvm-ieee 1800.2-2020 auto 18.2.2
%000000     static function uvm_reg_map backdoor();
%000000       if (m_backdoor == null) begin
        
%000000         m_backdoor = new("Backdoor");
              end
        
%000000       return m_backdoor;
            endfunction
        
        
            //----------------------
            // Group -- NODOCS -- Initialization
            //----------------------
        
        
        
            // @uvm-ieee 1800.2-2020 auto 18.2.3.1
            extern function new(string name="uvm_reg_map");
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.2
          extern function void configure(uvm_reg_block     parent,
                                         uvm_reg_addr_t    base_addr,
                                         int unsigned      n_bytes,
                                         uvm_endianness_e  endian,
                                         bit byte_addressing = 1);
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.3
          extern virtual function void add_reg (uvm_reg           rg,
                                                uvm_reg_addr_t    offset,
                                                string            rights = "RW",
                                                bit               unmapped=0,
                                                uvm_reg_frontdoor frontdoor=null);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.4
          extern virtual function void add_mem (uvm_mem        mem,
                                                uvm_reg_addr_t offset,
                                                string         rights = "RW",
                                                bit            unmapped=0,
                                                uvm_reg_frontdoor frontdoor=null);
        
        
        
          // NOTE THIS isnt really true because one can add a map only to another map if the
          // map parent blocks are either the same or the maps parent is an ancestor of the submaps parent
          // also AddressUnitBits needs to match which means essentially that within a block there can only be one
          // AddressUnitBits
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.5
          extern virtual function void add_submap (uvm_reg_map    child_map,
                                                   uvm_reg_addr_t offset);
        
        
          // Function -- NODOCS -- set_sequencer
          //
          // Set the sequencer and adapter associated with this map. This method
          // ~must~ be called before starting any sequences based on uvm_reg_sequence.
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.6
          extern virtual function void set_sequencer (uvm_sequencer_base sequencer,
                                                      uvm_reg_adapter    adapter=null);
        
        
        
          // Function -- NODOCS -- set_submap_offset
          //
          // Set the offset of the given ~submap~ to ~offset~.
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.8
          extern virtual function void set_submap_offset (uvm_reg_map submap,
                                                          uvm_reg_addr_t offset);
        
        
          // Function -- NODOCS -- get_submap_offset
          //
          // Return the offset of the given ~submap~.
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.7
          extern virtual function uvm_reg_addr_t get_submap_offset (uvm_reg_map submap);
        
        
          // Function -- NODOCS -- set_base_addr
          //
          // Set the base address of this map.
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.9
          extern virtual function void   set_base_addr (uvm_reg_addr_t  offset);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.3.10
          extern virtual function void reset(string kind = "SOFT");
        
        
          /*local*/ extern virtual function void add_parent_map(uvm_reg_map  parent_map,
                                                                uvm_reg_addr_t offset);
        
          /*local*/ extern virtual function void Xverify_map_configX();
        
          /*local*/ extern virtual function void m_set_reg_offset(uvm_reg   rg,
                                                                  uvm_reg_addr_t offset,
                                                                  bit unmapped);
        
          /*local*/ extern virtual function void m_set_mem_offset(uvm_mem mem,
                                                                  uvm_reg_addr_t offset,
                                                                  bit unmapped);
        
        
          //---------------------
          // Group -- NODOCS -- Introspection
          //---------------------
        
          // Function -- NODOCS -- get_name
          //
          // Get the simple name
          //
          // Return the simple object name of this address map.
          //
        
          // Function -- NODOCS -- get_full_name
          //
          // Get the hierarchical name
          //
          // Return the hierarchal name of this address map.
          // The base of the hierarchical name is the root block.
          //
          extern virtual function string get_full_name();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.1
          extern virtual function uvm_reg_map get_root_map();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.2
          extern virtual function uvm_reg_block get_parent();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.3
          extern virtual function uvm_reg_map           get_parent_map();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.4
          extern virtual function uvm_reg_addr_t get_base_addr (uvm_hier_e hier=UVM_HIER);
        
        
          // Function -- NODOCS -- get_n_bytes
          //
          // Get the width in bytes of the bus associated with this map. If ~hier~
          // is ~UVM_HIER~, then gets the effective bus width relative to the system
          // level. The effective bus width is the narrowest bus width from this
          // map to the top-level root map. Each bus access will be limited to this
          // bus width.
          //
          extern virtual function int unsigned get_n_bytes (uvm_hier_e hier=UVM_HIER);
        
        
          // Function -- NODOCS -- get_addr_unit_bytes
          //
          // Get the number of bytes in the smallest addressable unit in the map.
          // Returns 1 if the address map was configured using byte-level addressing.
          // Returns <get_n_bytes()> otherwise.
          //
          extern virtual function int unsigned get_addr_unit_bytes();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.7
          extern virtual function uvm_endianness_e get_endian (uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.8
          extern virtual function uvm_sequencer_base get_sequencer (uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.9
          extern virtual function uvm_reg_adapter get_adapter (uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.10
          extern virtual function void  get_submaps (ref uvm_reg_map maps[$],
                                                     input uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.11
          extern virtual function void  get_registers (ref uvm_reg regs[$],
                                                       input uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.12
          extern virtual function void  get_fields (ref uvm_reg_field fields[$],
                                                    input uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.13
          extern virtual function void  get_memories (ref uvm_mem mems[$],
                                                      input uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.14
          extern virtual function void  get_virtual_registers (ref uvm_vreg regs[$],
                                                               input uvm_hier_e hier=UVM_HIER);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.15
          extern virtual function void  get_virtual_fields (ref uvm_vreg_field fields[$],
                                                            input uvm_hier_e hier=UVM_HIER);
        
        
          extern virtual function uvm_reg_map_info get_reg_map_info(uvm_reg rg,  bit error=1);
          extern virtual function uvm_reg_map_info get_mem_map_info(uvm_mem mem, bit error=1);
          extern virtual function int unsigned get_size();
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.16
          extern virtual function int get_physical_addresses(uvm_reg_addr_t        base_addr,
                                                             uvm_reg_addr_t        mem_offset,
                                                             int unsigned          n_bytes,
                                                             ref uvm_reg_addr_t    addr[]);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.17
          extern virtual function uvm_reg get_reg_by_offset(uvm_reg_addr_t offset,
                                                            bit            read = 1);
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.4.18
          extern virtual function uvm_mem    get_mem_by_offset(uvm_reg_addr_t offset);
        
        
          //------------------
          // Group -- NODOCS -- Bus Access
          //------------------
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.5.2
%000000   function void set_auto_predict(bit on=1); m_auto_predict = on; endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.5.1
%000000   function bit  get_auto_predict(); return m_auto_predict; endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.5.3
%000000   function void set_check_on_read(bit on=1);
%000000     m_check_on_read = on;
%000000     foreach (m_submaps[submap]) begin
%000000       submap.set_check_on_read(on);
            end
          endfunction
        
        
          // Function -- NODOCS -- get_check_on_read
          //
          // Gets the check-on-read mode setting for this map.
          //
%000000   function bit  get_check_on_read(); return m_check_on_read; endfunction
        
        
        
          // Task -- NODOCS -- do_bus_write
          //
          // Perform a bus write operation.
          //
          extern virtual task do_bus_write (uvm_reg_item rw,
                                            uvm_sequencer_base sequencer,
                                            uvm_reg_adapter adapter);
        
        
          // Task -- NODOCS -- do_bus_read
          //
          // Perform a bus read operation.
          //
          extern virtual task do_bus_read (uvm_reg_item rw,
                                           uvm_sequencer_base sequencer,
                                           uvm_reg_adapter adapter);
        
        
          // Task -- NODOCS -- do_write
          //
          // Perform a write operation.
          //
          extern virtual task do_write(uvm_reg_item rw);
        
        
          // Task -- NODOCS -- do_read
          //
          // Perform a read operation.
          //
          extern virtual task do_read(uvm_reg_item rw);
        
          extern function void Xget_bus_infoX (uvm_reg_item rw,
                                               output uvm_reg_map_info map_info,
                                               output int size,
                                               output int lsb,
                                               output int addr_skip);
        
          extern virtual function string      convert2string();
          extern virtual function uvm_object  clone();
          extern virtual function void        do_print (uvm_printer printer);
          extern virtual function void        do_copy   (uvm_object rhs);
          //extern virtual function bit       do_compare (uvm_object rhs, uvm_comparer comparer);
          //extern virtual function void      do_pack (uvm_packer packer);
          //extern virtual function void      do_unpack (uvm_packer packer);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.5.5
%000000   function void set_transaction_order_policy(uvm_reg_transaction_order_policy pol);
%000000     policy = pol;
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 18.2.5.4
%000000   function uvm_reg_transaction_order_policy get_transaction_order_policy();
%000000     return policy;
          endfunction
        
          // ceil() function
%000000   local function automatic int unsigned ceil(int unsigned a, int unsigned b);
%000000     int                                           r = a / b;
%000000     int                                           r0 = a % b;
%000000     return r0 ? (r+1): r;
          endfunction
        
          /*
           * translates an access from the current map ~this~ to an address ~base_addr~ (within the current map) with a
           * length of ~n_bytes~ into an access from map ~parent_map~.
           * if ~mem~ and ~mem_offset~ are supplied then a memory access is assumed
           * results: ~addr~ contains the set of addresses and ~byte_offset~ holds the number of bytes the data stream needs to be shifted
           *
           * this implementation assumes a packed data access
           */
          extern virtual function int get_physical_addresses_to_map(uvm_reg_addr_t     base_addr,
                                                            uvm_reg_addr_t     mem_offset,
                                                            int unsigned       n_bytes,  // number of bytes
                                                            ref uvm_reg_addr_t addr[], // array of addresses
                                                            input uvm_reg_map parent_map, // translate till parent_map is the parent of the actual map or NULL if this is a root_map
                                                            ref int unsigned byte_offset,
                                                            input uvm_mem mem =null
                                                                );
        
          // performs all bus operations ~accesses~ generated from ~rw~ via adapter ~adapter~ on sequencer ~sequencer~
          extern task perform_accesses(ref uvm_reg_bus_op    accesses[$],
                               input uvm_reg_item rw,
                               input uvm_reg_adapter adapter,
                               input  uvm_sequencer_base sequencer);
        
          // performs all necessary bus accesses defined by ~rw~ on the sequencer ~sequencer~ utilizing the adapter ~adapter~
          extern task do_bus_access (uvm_reg_item rw,
                                     uvm_sequencer_base sequencer,
                                     uvm_reg_adapter adapter);
        
          // unregisters all content from this map recursively
          // it is NOT expected that this leads to a fresh new map
          // it rather removes all knowledge of this map from other objects
          // so that they can be reused with a fresh map instance
          // @uvm-ieee 1800.2-2020 auto 18.2.3.11
%000000   virtual function void unregister();
%000000     uvm_reg_block q[$];
%000000     uvm_reg_block::get_root_blocks(q);
        
%000000     foreach(q[idx]) begin
        
%000000       q[idx].set_lock(0);
            end
        
        
%000000     foreach(q[idx]) begin
        
%000000       q[idx].unregister(this);
            end
        
        
%000000     foreach (m_submaps[map_]) begin
        
%000000       map_.unregister();
            end
        
        
%000000     m_submaps.delete();
%000000     m_submap_rights.delete();
        
        
%000000     foreach(m_regs_by_offset[i]) begin
        
%000000       m_regs_by_offset[i].unregister(this);
            end
        
        
%000000     m_regs_by_offset.delete();
%000000     m_regs_by_offset_wo.delete();
%000000     m_mems_by_offset.delete();
        
%000000     m_regs_info.delete();
%000000     m_mems_info.delete();
        
%000000     m_parent_map =null;
          endfunction
        
%000000   virtual function uvm_reg_map clone_and_update(string rights);
%000000     if(m_parent_map!=null) begin
%000000       `uvm_error("UVM/REG/CLONEMAPWITHPARENT","cannot clone a map which already has a parent")
            end
%000000     if(m_submaps.size() != 0) begin
%000000       `uvm_error("UVM/REG/CLONEMAPWITHCHILDREN","cannot clone a map which already has children")
            end
        
%000000     begin
%000000       uvm_reg_map m;
%000000       uvm_reg_block b = get_parent();
%000000       uvm_reg qr[$];
%000000       uvm_mem qm[$];
        
%000000       m = b.create_map(get_name(),0,m_n_bytes,m_endian,m_byte_addressing);
        
%000000       foreach(m_regs_by_offset[i]) begin
%000000         uvm_reg rg=m_regs_by_offset[i];
%000000         uvm_reg_map_info info = get_reg_map_info(rg);
%000000         m.add_reg(rg,info.offset,rights, info.unmapped, info.frontdoor);
              end
%000000       foreach(m_mems_by_offset[i]) begin
%000000         uvm_mem rg=m_mems_by_offset[i];
%000000         uvm_reg_map_info info = get_mem_map_info(rg);
%000000         m.add_mem(rg,info.offset,rights, info.unmapped, info.frontdoor);
              end
%000000       return m;
            end
          endfunction
        endclass: uvm_reg_map
        
        
        
        //---------------
        // Initialization
        //---------------
        
        // new
        
%000000 function uvm_reg_map::new(string name = "uvm_reg_map");
%000000   super.new((name == "") ? "default_map" : name);
%000000   m_auto_predict = 0;
%000000   m_check_on_read = 0;
        endfunction
        
        
        // configure
        
%000000 function void uvm_reg_map::configure(uvm_reg_block    parent,
                                             uvm_reg_addr_t   base_addr,
                                             int unsigned     n_bytes,
                                             uvm_endianness_e endian,
                                             bit              byte_addressing=1);
%000000   m_parent     = parent;
%000000   m_n_bytes    = n_bytes;
%000000   m_endian     = endian;
%000000   m_base_addr  = base_addr;
%000000   m_byte_addressing = byte_addressing;
        endfunction: configure
        
        
        // add_reg
        
%000000 function void uvm_reg_map::add_reg(uvm_reg rg,
                                           uvm_reg_addr_t offset,
                                           string rights = "RW",
                                           bit unmapped=0,
                                           uvm_reg_frontdoor frontdoor=null);
        
%000000   if (m_regs_info.exists(rg)) begin
            `uvm_error("RegModel", {"Register '",rg.get_name(),
%000000     "' has already been added to map '",get_full_name(),"'"})
%000000     return;
          end
        
%000000   if (rg.get_parent() != get_parent()) begin
            `uvm_error("RegModel",
            {"Register '",rg.get_full_name(),"' may not be added to address map '",
%000000     get_full_name(),"' : they are not in the same block"})
%000000     return;
          end
        
%000000   rg.add_map(this);
        
%000000   begin
%000000     uvm_reg_map_info info = new;
%000000     info.offset   = offset;
%000000     info.rights   = rights;
%000000     info.unmapped = unmapped;
%000000     info.frontdoor = frontdoor;
%000000     info.is_initialized=0;
%000000     m_regs_info[rg]=info;
          end
        endfunction
        
        
        // m_set_reg_offset
        
%000000 function void uvm_reg_map::m_set_reg_offset(uvm_reg rg,
                                                    uvm_reg_addr_t offset,
                                                    bit unmapped);
        
%000000   if (!m_regs_info.exists(rg)) begin
            `uvm_error("RegModel",
            {"Cannot modify offset of register '",rg.get_full_name(),
            "' in address map '",get_full_name(),
%000000     "' : register not mapped in that address map"})
%000000     return;
          end
        
%000000   begin
%000000     uvm_reg_map_info info    = m_regs_info[rg];
%000000     uvm_reg_block    blk     = get_parent();
%000000     uvm_reg_map      top_map = get_root_map();
%000000     uvm_reg_addr_t   addrs[];
        
            // if block is not locked, Xinit_address_mapX will resolve map when block is locked
%000000     if (blk.is_locked()) begin
        
              // remove any existing cached addresses
%000000       if (!info.unmapped) begin
%000000         foreach (info.addr[i]) begin
        
%000000           if (!top_map.m_regs_by_offset_wo.exists(info.addr[i])) begin
%000000             top_map.m_regs_by_offset.delete(info.addr[i]);
                  end
%000000           else begin
%000000             if (top_map.m_regs_by_offset[info.addr[i]] == rg) begin
%000000               top_map.m_regs_by_offset[info.addr[i]] =
%000000                                                        top_map.m_regs_by_offset_wo[info.addr[i]];
%000000               uvm_reg_read_only_cbs::remove(rg);
%000000               uvm_reg_write_only_cbs::remove(top_map.m_regs_by_offset[info.addr[i]]);
                    end
%000000             else begin
%000000               uvm_reg_write_only_cbs::remove(rg);
%000000               uvm_reg_read_only_cbs::remove(top_map.m_regs_by_offset[info.addr[i]]);
                    end
%000000             top_map.m_regs_by_offset_wo.delete(info.addr[i]);
                  end
                end
              end
        
              // if we are remapping...
%000000       if (!unmapped) begin
%000000         string rg_acc = rg.Xget_fields_accessX(this);
        
                // get new addresses
%000000         void'(get_physical_addresses(offset,0,rg.get_n_bytes(),addrs));
        
                // make sure they do not conflict with others
%000000         foreach (addrs[i]) begin
%000000           uvm_reg_addr_t addr = addrs[i];
%000000           if (top_map.m_regs_by_offset.exists(addr)) begin
        
%000000             uvm_reg rg2 = top_map.m_regs_by_offset[addr];
%000000             string rg2_acc = rg2.Xget_fields_accessX(this);
        
                    // If the register at the same address is RO or WO
                    // and this register is WO or RO, this is OK
%000000             if (rg_acc == "RO" && rg2_acc == "WO") begin
%000000               top_map.m_regs_by_offset[addr]    = rg;
%000000               uvm_reg_read_only_cbs::add(rg);
%000000               top_map.m_regs_by_offset_wo[addr] = rg2;
%000000               uvm_reg_write_only_cbs::add(rg2);
                    end
%000000             else if (rg_acc == "WO" && rg2_acc == "RO") begin
%000000               top_map.m_regs_by_offset_wo[addr] = rg;
%000000               uvm_reg_write_only_cbs::add(rg);
%000000               uvm_reg_read_only_cbs::add(rg2);
                    end
%000000             else begin
%000000               string a;
%000000               a = $sformatf("%0h",addr);
                      `uvm_warning("RegModel", {"In map '",get_full_name(),"' register '",
                      rg.get_full_name(), "' maps to same address as register '",
%000000               top_map.m_regs_by_offset[addr].get_full_name(),"': 'h",a})
                    end
                  end
%000000           else begin
        
%000000             top_map.m_regs_by_offset[addr] = rg;
                  end
        
        
%000000           foreach (top_map.m_mems_by_offset[range]) begin
%000000             if (addrs[i] >= range.min && addrs[i] <= range.max) begin
%000000               string a;
%000000               a = $sformatf("%0h",addrs[i]);
                      `uvm_warning("RegModel", {"In map '",get_full_name(),"' register '",
                      rg.get_full_name(), "' overlaps with address range of memory '",
%000000               top_map.m_mems_by_offset[range].get_full_name(),"': 'h",a})
                    end
                  end
                end
%000000         info.addr = addrs; // cache it
              end
            end
        
%000000     if (unmapped) begin
%000000       info.offset   = -1;
%000000       info.unmapped = 1;
            end
%000000     else begin
%000000       info.offset   = offset;
%000000       info.unmapped = 0;
            end
        
          end
        endfunction
        
        
        // add_mem
        
%000000 function void uvm_reg_map::add_mem(uvm_mem mem,
                                           uvm_reg_addr_t offset,
                                           string rights = "RW",
                                           bit unmapped=0,
                                           uvm_reg_frontdoor frontdoor=null);
%000000   if (m_mems_info.exists(mem)) begin
            `uvm_error("RegModel", {"Memory '",mem.get_name(),
%000000     "' has already been added to map '",get_full_name(),"'"})
%000000     return;
          end
        
%000000   if (mem.get_parent() != get_parent()) begin
            `uvm_error("RegModel",
            {"Memory '",mem.get_full_name(),"' may not be added to address map '",
%000000     get_full_name(),"' : they are not in the same block"})
%000000     return;
          end
        
%000000   mem.add_map(this);
        
%000000   begin
%000000     uvm_reg_map_info info = new;
%000000     info.offset   = offset;
%000000     info.rights   = rights;
%000000     info.unmapped = unmapped;
%000000     info.frontdoor = frontdoor;
%000000     m_mems_info[mem] = info;
          end
        endfunction: add_mem
        
        
        
        // m_set_mem_offset
        
%000000 function void uvm_reg_map::m_set_mem_offset(uvm_mem mem,
                                                    uvm_reg_addr_t offset,
                                                    bit unmapped);
        
%000000   if (!m_mems_info.exists(mem)) begin
            `uvm_error("RegModel",
            {"Cannot modify offset of memory '",mem.get_full_name(),
            "' in address map '",get_full_name(),
%000000     "' : memory not mapped in that address map"})
%000000     return;
          end
        
%000000   begin
%000000     uvm_reg_map_info info    = m_mems_info[mem];
%000000     uvm_reg_block    blk     = get_parent();
%000000     uvm_reg_map      top_map = get_root_map();
%000000     uvm_reg_addr_t   addrs[];
        
            // if block is not locked, Xinit_address_mapX will resolve map when block is locked
%000000     if (blk.is_locked()) begin
        
              // remove any existing cached addresses
%000000       if (!info.unmapped) begin
%000000         foreach (top_map.m_mems_by_offset[range]) begin
%000000           if (top_map.m_mems_by_offset[range] == mem) begin
        
%000000             top_map.m_mems_by_offset.delete(range);
                  end
        
                end
              end
        
              // if we are remapping...
%000000       if (!unmapped) begin
%000000         uvm_reg_addr_t addrs[],addrs_max[];
%000000         uvm_reg_addr_t min, max, min2, max2;
%000000         int unsigned stride;
        
%000000         void'(get_physical_addresses(offset,0,mem.get_n_bytes(),addrs));
%000000         min = (addrs[0] < addrs[addrs.size()-1]) ? addrs[0] : addrs[addrs.size()-1];
%000000         min2 = addrs[0];
        
%000000         void'(get_physical_addresses(offset,(mem.get_size()-1),
%000000                                      mem.get_n_bytes(),addrs_max));
%000000         max = (addrs_max[0] > addrs_max[addrs_max.size()-1]) ?
                      addrs_max[0] : addrs_max[addrs_max.size()-1];
%000000         max2 = addrs_max[0];
                // address interval between consecutive mem locations
%000000         stride = mem.get_n_bytes()/get_addr_unit_bytes();
        
                // make sure new offset does not conflict with others
%000000         foreach (top_map.m_regs_by_offset[reg_addr]) begin
%000000           if (reg_addr >= min && reg_addr <= max) begin
%000000             string a,b;
%000000             a = $sformatf("[%0h:%0h]",min,max);
%000000             b = $sformatf("%0h",reg_addr);
                    `uvm_warning("RegModel", {"In map '",get_full_name(),"' memory '",
                    mem.get_full_name(), "' with range ",a,
                    " overlaps with address of existing register '",
%000000             top_map.m_regs_by_offset[reg_addr].get_full_name(),"': 'h",b})
                  end
                end
        
%000000         foreach (top_map.m_mems_by_offset[range]) begin
%000000           if (min <= range.max && max >= range.max ||
%000000           min <= range.min && max >= range.min ||
%000000           min >= range.min && max <= range.max) begin
%000000             string a,b;
%000000             a = $sformatf("[%0h:%0h]",min,max);
%000000             b = $sformatf("[%0h:%0h]",range.min,range.max);
                    `uvm_warning("RegModel", {"In map '",get_full_name(),"' memory '",
                    mem.get_full_name(), "' with range ",a,
                    " overlaps existing memory with range '",
%000000             top_map.m_mems_by_offset[range].get_full_name(),"': ",b})
                  end
                end
        
%000000         begin
%000000           uvm_reg_map_addr_range range = '{ min, max, stride};
%000000           top_map.m_mems_by_offset[range] = mem;
%000000           info.addr  = addrs;
%000000           info.mem_range = range;
                end
        
              end
            end
        
%000000     if (unmapped) begin
%000000       info.offset   = -1;
%000000       info.unmapped = 1;
            end
%000000     else begin
%000000       info.offset   = offset;
%000000       info.unmapped = 0;
            end
        
          end
        endfunction
        
        
        // add_submap
        
%000000 function void uvm_reg_map::add_submap (uvm_reg_map child_map,
                                               uvm_reg_addr_t offset);
%000000   uvm_reg_map parent_map;
        
%000000   if (child_map == null) begin
%000000     `uvm_error("RegModel", {"Attempting to add NULL map to map '",get_full_name(),"'"})
%000000     return;
          end
        
%000000   parent_map = child_map.get_parent_map();
        
          // Cannot have more than one parent (currently)
%000000   if (parent_map != null) begin
            `uvm_error("RegModel", {"Map '", child_map.get_full_name(),
            "' is already a child of map '",
            parent_map.get_full_name(),
            "'. Cannot also be a child of map '",
            get_full_name(),
%000000     "'"})
%000000     return;
          end
        
          // this check means that n_bytes cannot change in a map hierarchy, that should work with 5446
%000000   begin : n_bytes_match_check
%000000     if (m_n_bytes > child_map.get_n_bytes(UVM_NO_HIER)) begin
              `uvm_warning("RegModel",
              $sformatf("Adding %0d-byte submap '%s' to %0d-byte parent map '%s'",
              child_map.get_n_bytes(UVM_NO_HIER), child_map.get_full_name(),
%000000       m_n_bytes, get_full_name()))
            end
          end
        
%000000   child_map.add_parent_map(this,offset);
        
%000000   set_submap_offset(child_map, offset);
        
        endfunction: add_submap
        
        
        // reset
        
%000000 function void uvm_reg_map::reset(string kind = "SOFT");
%000000   uvm_reg regs[$];
        
%000000   get_registers(regs);
        
%000000   foreach (regs[i]) begin
%000000     regs[i].reset(kind);
          end
        endfunction
        
        
        // add_parent_map
        
%000000 function void uvm_reg_map::add_parent_map(uvm_reg_map parent_map, uvm_reg_addr_t offset);
        
%000000   if (parent_map == null) begin
            `uvm_error("RegModel",
%000000     {"Attempting to add NULL parent map to map '",get_full_name(),"'"})
%000000     return;
          end
        
%000000   if (m_parent_map != null) begin
            `uvm_error("RegModel",
            $sformatf("Map \"%s\" already a submap of map \"%s\" at offset 'h%h",
            get_full_name(), m_parent_map.get_full_name(),
%000000     m_parent_map.get_submap_offset(this)))
%000000     return;
          end
        
%000000   m_parent_map = parent_map;
%000000   parent_map.m_submaps[this] = offset;
        
        endfunction: add_parent_map
        
        
        // set_sequencer
        
%000000 function void uvm_reg_map::set_sequencer(uvm_sequencer_base sequencer,
                                                 uvm_reg_adapter adapter=null);
        
%000000   if (sequencer == null) begin
%000000     `uvm_error("REG_NULL_SQR", "Null reference specified for bus sequencer")
%000000     return;
          end
        
%000000   if (adapter == null) begin
            `uvm_info("REG_NO_ADAPT", {"Adapter not specified for map '",get_full_name(),
            "'. Accesses via this map will send abstract 'uvm_reg_item' items to sequencer '",
%000000     sequencer.get_full_name(),"'"},UVM_MEDIUM)
          end
        
%000000   m_sequencer = sequencer;
%000000   m_adapter = adapter;
        endfunction
        
        
        
        //------------
        // get methods
        //------------
        
        // get_parent
        
%000000 function uvm_reg_block uvm_reg_map::get_parent();
%000000   return m_parent;
        endfunction
        
        
        // get_parent_map
        
%000000 function uvm_reg_map uvm_reg_map::get_parent_map();
%000000   return m_parent_map;
        endfunction
        
        
        // get_root_map
        
%000000 function uvm_reg_map uvm_reg_map::get_root_map();
%000000   return (m_parent_map == null) ? this : m_parent_map.get_root_map();
        endfunction: get_root_map
        
        
        // get_base_addr
        
%000000 function uvm_reg_addr_t  uvm_reg_map::get_base_addr(uvm_hier_e hier=UVM_HIER);
%000000   uvm_reg_map child = this;
%000000   if (hier == UVM_NO_HIER || m_parent_map == null) begin
        
%000000     return m_base_addr;
          end
        
%000000   get_base_addr = m_parent_map.get_submap_offset(this);
%000000   get_base_addr += m_parent_map.get_base_addr(UVM_HIER);
        endfunction
        
        
        // get_n_bytes
        
%000000 function int unsigned uvm_reg_map::get_n_bytes(uvm_hier_e hier=UVM_HIER);
%000000   if (hier == UVM_NO_HIER) begin
        
%000000     return m_n_bytes;
          end
        
%000000   return m_system_n_bytes;
        endfunction
        
        
        // get_addr_unit_bytes
        
%000000 function int unsigned uvm_reg_map::get_addr_unit_bytes();
%000000   return (m_byte_addressing) ? 1 : m_n_bytes;
        endfunction
        
        
        // get_endian
        
%000000 function uvm_endianness_e uvm_reg_map::get_endian(uvm_hier_e hier=UVM_HIER);
%000000   if (hier == UVM_NO_HIER || m_parent_map == null) begin
        
%000000     return m_endian;
          end
        
%000000   return m_parent_map.get_endian(hier);
        endfunction
        
        
        // get_sequencer
        
%000000 function uvm_sequencer_base uvm_reg_map::get_sequencer(uvm_hier_e hier=UVM_HIER);
%000000   if (hier == UVM_NO_HIER || m_parent_map == null) begin
        
%000000     return m_sequencer;
          end
        
%000000   return m_parent_map.get_sequencer(hier);
        endfunction
        
        
        // get_adapter
        
%000000 function uvm_reg_adapter uvm_reg_map::get_adapter(uvm_hier_e hier=UVM_HIER);
%000000   if (hier == UVM_NO_HIER || m_parent_map == null) begin
        
%000000     return m_adapter;
          end
        
%000000   return m_parent_map.get_adapter(hier);
        endfunction
        
        
        // get_submaps
        
%000000 function void uvm_reg_map::get_submaps(ref uvm_reg_map maps[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   foreach (m_submaps[submap]) begin
        
%000000     maps.push_back(submap);
          end
        
        
        
%000000   if (hier == UVM_HIER) begin
        
%000000     foreach (m_submaps[submap_]) begin
%000000       uvm_reg_map submap=submap_;
%000000       submap.get_submaps(maps);
            end
          end
        
        endfunction
        
        
        // get_registers
        
%000000 function void uvm_reg_map::get_registers(ref uvm_reg regs[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   foreach (m_regs_info[rg]) begin
        
%000000     regs.push_back(rg);
          end
        
        
%000000   if (hier == UVM_HIER) begin
        
%000000     foreach (m_submaps[submap_]) begin
%000000       uvm_reg_map submap=submap_;
%000000       submap.get_registers(regs);
            end
          end
        
        
        endfunction
        
        
        // get_fields
        
%000000 function void uvm_reg_map::get_fields(ref uvm_reg_field fields[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   foreach (m_regs_info[rg_]) begin
%000000     uvm_reg rg = rg_;
%000000     rg.get_fields(fields);
          end
        
%000000   if (hier == UVM_HIER) begin
        
%000000     foreach (this.m_submaps[submap_]) begin
%000000       uvm_reg_map submap=submap_;
%000000       submap.get_fields(fields);
            end
          end
        
        
        endfunction
        
        
        // get_memories
        
%000000 function void uvm_reg_map::get_memories(ref uvm_mem mems[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   foreach (m_mems_info[mem]) begin
        
%000000     mems.push_back(mem);
          end
        
        
%000000   if (hier == UVM_HIER) begin
        
%000000     foreach (m_submaps[submap_]) begin
%000000       uvm_reg_map submap=submap_;
%000000       submap.get_memories(mems);
            end
          end
        
        
        endfunction
        
        
        // get_virtual_registers
        
%000000 function void uvm_reg_map::get_virtual_registers(ref uvm_vreg regs[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   uvm_mem mems[$];
%000000   get_memories(mems,hier);
        
%000000   foreach (mems[i]) begin
        
%000000     mems[i].get_virtual_registers(regs);
          end
        
        
        endfunction
        
        
        // get_virtual_fields
        
%000000 function void uvm_reg_map::get_virtual_fields(ref uvm_vreg_field fields[$], input uvm_hier_e hier=UVM_HIER);
        
%000000   uvm_vreg regs[$];
%000000   get_virtual_registers(regs,hier);
        
%000000   foreach (regs[i]) begin
        
%000000     regs[i].get_fields(fields);
          end
        
        
        endfunction
        
        
        
        // get_full_name
        
%000000 function string uvm_reg_map::get_full_name();
%000000   if (m_parent == null) begin
        
%000000     return get_name();
          end
        
%000000   else begin
        
%000000     return {m_parent.get_full_name(), ".", get_name()};
          end
        
        endfunction
        
        
        // get_mem_map_info
        
%000000 function uvm_reg_map_info uvm_reg_map::get_mem_map_info(uvm_mem mem, bit error=1);
%000000   if (!m_mems_info.exists(mem)) begin
%000000     if (error) begin
%000000       `uvm_error("REG_NO_MAP",{"Memory '",mem.get_name(),"' not in map '",get_full_name(),"'"})
            end
%000000     return null;
          end
%000000   return m_mems_info[mem];
        endfunction
        
        
        // get_reg_map_info
        
%000000 function uvm_reg_map_info uvm_reg_map::get_reg_map_info(uvm_reg rg, bit error=1);
%000000   uvm_reg_map_info result;
%000000   if (!m_regs_info.exists(rg)) begin
%000000     if (error) begin
%000000       `uvm_error("REG_NO_MAP",{"Register '",rg.get_name(),"' not in map '",get_full_name(),"'"})
            end
%000000     return null;
          end
%000000   result = m_regs_info[rg];
%000000   if(!result.is_initialized) begin
%000000     `uvm_warning("RegModel",{"map '",get_full_name(),"' does not seem to be initialized correctly, check that the top register model is locked()"})
          end
        
%000000   return result;
        endfunction
        
        
        //----------
        // Size and Overlap Detection
        //---------
        
        // set_base_addr
        
%000000 function void uvm_reg_map::set_base_addr(uvm_reg_addr_t offset);
%000000   if (m_parent_map != null) begin
%000000     m_parent_map.set_submap_offset(this, offset);
          end
%000000   else begin
%000000     m_base_addr = offset;
%000000     if (m_parent.is_locked()) begin
%000000       uvm_reg_map top_map = get_root_map();
%000000       top_map.Xinit_address_mapX();
            end
          end
        endfunction
        
        
        // get_size
        
%000000 function int unsigned uvm_reg_map::get_size();
        
%000000   int unsigned max_addr;
%000000   int unsigned addr;
        
          // get max offset from registers
%000000   foreach (m_regs_info[rg_]) begin
%000000     uvm_reg rg = rg_;
%000000     addr = m_regs_info[rg].offset + ((rg.get_n_bytes()-1)/m_n_bytes);
%000000     if (addr > max_addr) begin
%000000       max_addr = addr;
            end
        
          end
        
          // get max offset from memories
%000000   foreach (m_mems_info[mem_]) begin
%000000     uvm_mem mem = mem_;
%000000     addr = m_mems_info[mem].offset + (mem.get_size() * (((mem.get_n_bytes()-1)/m_n_bytes)+1)) -1;
%000000     if (addr > max_addr) begin
%000000       max_addr = addr;
            end
        
          end
        
          // get max offset from submaps
%000000   foreach (m_submaps[submap_]) begin
%000000     uvm_reg_map submap=submap_;
%000000     addr = m_submaps[submap] + submap.get_size();
%000000     if (addr > max_addr) begin
%000000       max_addr = addr;
            end
        
          end
        
%000000   return max_addr + 1;
        
        endfunction
        
        
        
%000000 function void uvm_reg_map::Xverify_map_configX();
          // Make sure there is a generic payload sequence for each map
          // in the model and vice-versa if this is a root sequencer
%000000   bit error;
%000000   uvm_reg_map root_map = get_root_map();
        
%000000   if (root_map.get_adapter() == null) begin
            `uvm_error("RegModel", {"Map '",root_map.get_full_name(),
%000000     "' does not have an adapter registered"})
%000000     error++;
          end
%000000   if (root_map.get_sequencer() == null) begin
            `uvm_error("RegModel", {"Map '",root_map.get_full_name(),
%000000     "' does not have a sequencer registered"})
%000000     error++;
          end
%000000   if (error) begin
            `uvm_fatal("RegModel", {"Must register an adapter and sequencer ",
%000000     "for each top-level map in RegModel model"})
%000000     return;
          end
        
        endfunction
        
        // NOTE: if multiple memory addresses would fall into one bus word then the memory is addressed 'unpacked'
        // ie. every memory location will get an own bus address (and bits on the bus larger than the memory width are discarded
        // otherwise the memory access is 'packed'
        //
        // same as get_physical_addresses() but stops at the specified map
%000000 function int uvm_reg_map::get_physical_addresses_to_map(
                                                        uvm_reg_addr_t     base_addr, // in terms of the local map aub
                                                        uvm_reg_addr_t     mem_offset, // in terms of memory words
                                                        int unsigned       n_bytes,  // number of bytes for the memory stream
                                                        ref uvm_reg_addr_t addr[], // out: set of addresses required for memory stream in local map aub
                                                        input uvm_reg_map parent_map, // desired target map
                                                        ref int unsigned byte_offset, // leading byte offset (due to shifting within address words)
%000000                                                 input uvm_mem mem=null
                                                        );
        
%000000   int                                                         bus_width = get_n_bytes(UVM_NO_HIER);
%000000   uvm_reg_map  up_map;
%000000   uvm_reg_addr_t  local_addr[];
%000000   uvm_reg_addr_t lbase_addr;
        
          //    `uvm_info("RegModel",$sformatf("this=%p enter base=0x%0x mem_offset=0x%0d request=%0dbytes byte_enable=%0d byte-offset=%0d",
          //        this,base_addr,mem_offset,n_bytes,m_byte_addressing,byte_offset),UVM_HIGH)
        
          //    `uvm_info("RegModel",$sformatf("addressUnitBits=%0d busWidthBits=%0d",get_addr_unit_bytes()*8,bus_width*8),UVM_HIGH)
        
%000000   up_map = get_parent_map();
%000000   lbase_addr = up_map==null ?  get_base_addr(UVM_NO_HIER): up_map.get_submap_offset(this);
          //    `uvm_info("RegModel",$sformatf("lbase =0x%0x",lbase_addr),UVM_HIGH)
        
%000000   if(up_map!=parent_map) begin
%000000     uvm_reg_addr_t lb;
            // now just translate first address and request same number of bytes
            // may need to adjust addr,n_bytes if base_addr*AUB is not a multiple of upmap.AUB
            // addr=5,aub=8 and up.aub=16 and n_bytes=1 which is translated addr=2,n_bytes=2
%000000     uvm_reg_addr_t laddr;
%000000     begin
              // adjust base_addr to find the base of memword(mem_offset)
%000000       if(mem_offset) begin
%000000         base_addr+=mem_offset*mem.get_n_bytes()/get_addr_unit_bytes();
              end
%000000       laddr=lbase_addr + base_addr*get_addr_unit_bytes()/up_map.get_addr_unit_bytes(); // start address in terms of the upper map
%000000       lb = (base_addr*get_addr_unit_bytes()) % up_map.get_addr_unit_bytes(); // potential byte offset on top of the start address in the upper map
%000000       byte_offset += lb; // accumulate!
            end
%000000     return up_map.get_physical_addresses_to_map(laddr, 0, n_bytes+lb, addr,parent_map,byte_offset);
%000000   end else begin
%000000     uvm_reg_addr_t lbase_addr2;
            // first need to compute set of addresses
            // each address is for one full bus width (the last beat may have less bytes to transfer)
%000000     local_addr= new[ceil(n_bytes,bus_width)];
        
%000000     lbase_addr2 = base_addr;
%000000     if(mem_offset) begin
        
%000000       if(mem!=null && (mem.get_n_bytes() >= get_addr_unit_bytes())) begin // packed model
%000000         lbase_addr2 = base_addr + mem_offset*mem.get_n_bytes()/get_addr_unit_bytes();
%000000         byte_offset += (mem_offset*mem.get_n_bytes() % get_addr_unit_bytes());
%000000       end     else begin
%000000         lbase_addr2 = base_addr + mem_offset;
              end
            end
        
        
            //            `uvm_info("UVM/REG/ADDR",$sformatf("gen addrs map-aub(bytes)=%0d addrs=%0d map-bus-width(bytes)=%0d lbase_addr2=%0x",
            //                get_addr_unit_bytes(),local_addr.size(),bus_width,lbase_addr2),UVM_DEBUG)
        
%000000     case (get_endian(UVM_NO_HIER))
%000000       UVM_LITTLE_ENDIAN: begin
%000000         foreach (local_addr[i]) begin
%000000           local_addr[i] = lbase_addr2 + i*bus_width/get_addr_unit_bytes();
                end
              end
%000000       UVM_BIG_ENDIAN: begin
%000000         foreach (local_addr[i]) begin
%000000           local_addr[i] = lbase_addr2 + (local_addr.size()-1-i)*bus_width/get_addr_unit_bytes() ;
                end
              end
%000000       UVM_LITTLE_FIFO: begin
%000000         foreach (local_addr[i]) begin
%000000           local_addr[i] = lbase_addr2;
                end
              end
%000000       UVM_BIG_FIFO: begin
%000000         foreach (local_addr[i]) begin
%000000           local_addr[i] = lbase_addr2;
                end
              end
%000000       default: begin
                `uvm_error("UVM/REG/MAPNOENDIANESS",
                {"Map has no specified endianness. ",
                $sformatf("Cannot access %0d bytes register via its %0d byte \"%s\" interface",
%000000         n_bytes, bus_width, get_full_name())})
              end
            endcase
        
            //            foreach(local_addr[idx])
            //                `uvm_info("UVM/REG/ADDR",$sformatf("local_addr idx=%0d addr=%0x",idx,local_addr[idx]),UVM_DEBUG)
        
            // now need to scale in terms of upper map
        
%000000     addr = new [local_addr.size()] (local_addr);
%000000     foreach(addr[idx]) begin
        
%000000       addr[idx] += lbase_addr;
            end
        
        
            //            foreach(addr[idx])
            //                `uvm_info("UVM/REG/ADDR",$sformatf("top %0x:",addr[idx]),UVM_DEBUG)
        
          end
        endfunction
        
        // NOTE the map argument could be made an arg with a default value. didnt do that to present the function signature
%000000 function int uvm_reg_map::get_physical_addresses(uvm_reg_addr_t     base_addr,
                                                 uvm_reg_addr_t     mem_offset,
                                                 int unsigned       n_bytes,  // number of bytes
                                                 ref uvm_reg_addr_t addr[]);
%000000   int                                                unsigned skip;
%000000   return get_physical_addresses_to_map(base_addr, mem_offset, n_bytes, addr,null,skip);
        endfunction
        
        
        //--------------
        // Get-By-Offset
        //--------------
        
        
        // set_submap_offset
        
%000000 function void uvm_reg_map::set_submap_offset(uvm_reg_map submap, uvm_reg_addr_t offset);
%000000   if (submap == null) begin
%000000     `uvm_error("REG/NULL","set_submap_offset: submap handle is null")
%000000     return;
          end
%000000   m_submaps[submap] = offset;
%000000   if (m_parent.is_locked()) begin
%000000     uvm_reg_map root_map = get_root_map();
%000000     root_map.Xinit_address_mapX();
          end
        endfunction
        
        
        // get_submap_offset
        
%000000 function uvm_reg_addr_t uvm_reg_map::get_submap_offset(uvm_reg_map submap);
%000000   if (submap == null) begin
%000000     `uvm_error("REG/NULL","set_submap_offset: submap handle is null")
%000000     return -1;
          end
%000000   if (!m_submaps.exists(submap)) begin
            `uvm_error("RegModel",{"Map '",submap.get_full_name(),
%000000     "' is not a submap of '",get_full_name(),"'"})
%000000     return -1;
          end
%000000   return m_submaps[submap];
        endfunction
        
        
        // get_reg_by_offset
        
%000000 function uvm_reg uvm_reg_map::get_reg_by_offset(uvm_reg_addr_t offset,
                                                        bit            read = 1);
%000000   if (!m_parent.is_locked()) begin
%000000     `uvm_error("RegModel", $sformatf("Cannot get register by offset: Block %s is not locked.", m_parent.get_full_name()))
%000000     return null;
          end
        
%000000   if (!read && m_regs_by_offset_wo.exists(offset)) begin
        
%000000     return m_regs_by_offset_wo[offset];
          end
        
        
%000000   if (m_regs_by_offset.exists(offset)) begin
        
%000000     return m_regs_by_offset[offset];
          end
        
        
%000000   return null;
        endfunction
        
        
        // get_mem_by_offset
        
%000000 function uvm_mem uvm_reg_map::get_mem_by_offset(uvm_reg_addr_t offset);
%000000   if (!m_parent.is_locked()) begin
%000000     `uvm_error("RegModel", $sformatf("Cannot memory register by offset: Block %s is not locked.", m_parent.get_full_name()))
%000000     return null;
          end
        
%000000   foreach (m_mems_by_offset[range]) begin
%000000     if (range.min <= offset && offset <= range.max) begin
%000000       return m_mems_by_offset[range];
            end
          end
        
%000000   return null;
        endfunction
        
        
        // Xinit_address_mapX
        
%000000 function void uvm_reg_map::Xinit_address_mapX();
        
%000000   int unsigned bus_width;
        
%000000   uvm_reg_map top_map = get_root_map();
        
%000000   if (this == top_map) begin
%000000     top_map.m_regs_by_offset.delete();
%000000     top_map.m_regs_by_offset_wo.delete();
%000000     top_map.m_mems_by_offset.delete();
          end
        
%000000   foreach (m_submaps[l]) begin
%000000     uvm_reg_map map=l;
%000000     map.Xinit_address_mapX();
          end
        
%000000   foreach (m_regs_info[rg_]) begin
%000000     uvm_reg rg = rg_;
%000000     m_regs_info[rg].is_initialized=1;
%000000     if (!m_regs_info[rg].unmapped) begin
%000000       string rg_acc = rg.Xget_fields_accessX(this);
%000000       uvm_reg_addr_t addrs[];
        
%000000       bus_width = get_physical_addresses(m_regs_info[rg].offset,0,rg.get_n_bytes(),addrs);
        
%000000       foreach (addrs[i]) begin
%000000         uvm_reg_addr_t addr = addrs[i];
        
%000000         if (top_map.m_regs_by_offset.exists(addr) && (top_map.m_regs_by_offset[addr] != rg)) begin
        
%000000           uvm_reg rg2 = top_map.m_regs_by_offset[addr];
%000000           string rg2_acc = rg2.Xget_fields_accessX(this);
        
                  // If the register at the same address is RO or WO
                  // and this register is WO or RO, this is OK
%000000           if (rg_acc == "RO" && rg2_acc == "WO") begin
%000000             top_map.m_regs_by_offset[addr]    = rg;
%000000             uvm_reg_read_only_cbs::add(rg);
%000000             top_map.m_regs_by_offset_wo[addr] = rg2;
%000000             uvm_reg_write_only_cbs::add(rg2);
                  end
%000000           else if (rg_acc == "WO" && rg2_acc == "RO") begin
%000000             top_map.m_regs_by_offset_wo[addr] = rg;
%000000             uvm_reg_write_only_cbs::add(rg);
%000000             uvm_reg_read_only_cbs::add(rg2);
                  end
%000000           else begin
%000000             string a;
%000000             a = $sformatf("%0h",addr);
                    `uvm_warning("RegModel", {"In map '",get_full_name(),"' register '",
                    rg.get_full_name(), "' maps to same address as register '",
%000000             top_map.m_regs_by_offset[addr].get_full_name(),"': 'h",a})
                  end
                end
%000000         else begin
        
%000000           top_map.m_regs_by_offset[addr] = rg;
                end
        
        
%000000         foreach (top_map.m_mems_by_offset[range]) begin
%000000           if (addr >= range.min && addr <= range.max) begin
%000000             string a,b;
%000000             a = $sformatf("%0h",addr);
%000000             b = $sformatf("[%0h:%0h]",range.min,range.max);
                    `uvm_warning("RegModel", {"In map '",get_full_name(),"' register '",
                    rg.get_full_name(), "' with address ",a,
                    "maps to same address as memory '",
%000000             top_map.m_mems_by_offset[range].get_full_name(),"': ",b})
                  end
                end
              end
%000000       m_regs_info[rg].addr = addrs;
            end
          end
        
%000000   foreach (m_mems_info[mem_]) begin
%000000     uvm_mem mem = mem_;
%000000     if (!m_mems_info[mem].unmapped) begin
        
%000000       uvm_reg_addr_t addrs[],addrs_max[];
%000000       uvm_reg_addr_t min, max, min2, max2;
%000000       int unsigned stride;
%000000       int unsigned bo;
        
%000000       bus_width = get_physical_addresses_to_map(m_mems_info[mem].offset,0,mem.get_n_bytes(),addrs,null,bo,mem);
%000000       min = (addrs[0] < addrs[addrs.size()-1]) ? addrs[0] : addrs[addrs.size()-1];
        
              //    foreach(addrs[idx])
              //           `uvm_info("UVM/REG/ADDR",$sformatf("idx%0d addr=%0x",idx,addrs[idx]),UVM_DEBUG)
        
%000000       void'(get_physical_addresses_to_map(m_mems_info[mem].offset,(mem.get_size()-1),mem.get_n_bytes(),addrs_max,null,bo,mem));
%000000       max = (addrs_max[0] > addrs_max[addrs_max.size()-1]) ? addrs_max[0] : addrs_max[addrs_max.size()-1];
%000000       stride = mem.get_n_bytes()/get_addr_unit_bytes();
        
              //       foreach(addrs_max[idx])
              //           `uvm_info("UVM/REG/ADDR",$sformatf("idx%0d addr=%0x",idx,addrs_max[idx]),UVM_DEBUG)
        
              //       `uvm_info("UVM/REG/ADDR",$sformatf("mem %0d x %0d in map aub(bytes)=%0d n_bytes=%0d",mem.get_size(),mem.get_n_bits(),
              //           get_addr_unit_bytes(),get_n_bytes(UVM_NO_HIER)),UVM_DEBUG)
        
              /*
              if (uvm_report_enabled(UVM_DEBUG, UVM_INFO,"UVM/REG/ADDR")) begin
              uvm_reg_addr_t ad[];
              for(int idx=0;idx<mem.get_size();idx++) begin
              void'(get_physical_addresses_to_map(m_mems_info[mem].offset,idx,1,ad,null,bo,mem));
        
              `uvm_info("UVM/REG/ADDR",$sformatf("idx%d addr=%x",idx,ad[0]),UVM_DEBUG)
              end
              end
              */
        
%000000       if(mem.get_n_bytes()<get_addr_unit_bytes()) begin
                `uvm_warning("UVM/REG/ADDR",$sformatf("this version of UVM does not properly support memories with a smaller word width than the enclosing map. map %s has n_bytes=%0d aub=%0d while the mem has get_n_bytes %0d. multiple memory words fall into one bus address. if that happens memory addressing will be unpacked.",
%000000         get_full_name(),get_n_bytes(UVM_NO_HIER),get_addr_unit_bytes(),mem.get_n_bytes()))
              end
        
%000000       if(mem.get_n_bytes() > get_addr_unit_bytes()) begin
        
%000000         if(mem.get_n_bytes() % get_addr_unit_bytes())  begin
                  `uvm_warning("UVM/REG/ADDR",$sformatf("memory %s is not matching the word width of the enclosing map %s  (one memory word not fitting into k map addresses)",
%000000           mem.get_full_name(),get_full_name()))
                end
              end
        
        
%000000       if(mem.get_n_bytes() < get_addr_unit_bytes()) begin
%000000         if(get_addr_unit_bytes() % mem.get_n_bytes()) begin
                  `uvm_warning("UVM/REG/ADDR",$sformatf("the memory %s is not matching the word width of the enclosing map %s  (one map address doesnt cover k memory words)",
%000000           mem.get_full_name(),get_full_name()))
                end
              end
        
%000000       if(mem.get_n_bits() % 8) begin
%000000         `uvm_warning("UVM/REG/ADDR",$sformatf("this implementation of UVM requires memory words to be k*8 bits (mem %s has %0d bit words)",mem.get_full_name(),mem.get_n_bits()))
              end
        
%000000       foreach (top_map.m_regs_by_offset[reg_addr]) begin
%000000         if (reg_addr >= min && reg_addr <= max) begin
%000000           string a;
%000000           a = $sformatf("%0h",reg_addr);
                  `uvm_warning("RegModel", {"In map '",get_full_name(),"' memory '",
                  mem.get_full_name(), "' maps to same address as register '",
%000000           top_map.m_regs_by_offset[reg_addr].get_full_name(),"': 'h",a})
                end
              end
        
%000000       foreach (top_map.m_mems_by_offset[range]) begin
%000000         if (min <= range.max && max >= range.max ||
%000000         min <= range.min && max >= range.min ||
%000000         min >= range.min && max <= range.max) begin
        
%000000           if(top_map.m_mems_by_offset[range]!=mem) begin // do not warn if the same mem is located at the same address via different paths
        
%000000             string a;
%000000             a = $sformatf("[%0h:%0h]",min,max);
                    `uvm_warning("RegModel", {"In map '",get_full_name(),"' memory '",
                    mem.get_full_name(), "' overlaps with address range of memory '",
%000000             top_map.m_mems_by_offset[range].get_full_name(),"': 'h",a})
                  end
                end
        
              end
        
%000000       begin
%000000         uvm_reg_map_addr_range range = '{ min, max, stride};
%000000         top_map.m_mems_by_offset[ range ] = mem;
%000000         m_mems_info[mem].addr  = addrs;
%000000         m_mems_info[mem].mem_range = range;
              end
            end
          end
        
           // If the block has no registers or memories,
           // bus_width won't be set
%000000    if (bus_width == 0) begin
%000000      bus_width = m_n_bytes;
           end
        
        
%000000    m_system_n_bytes = bus_width;
        endfunction
        
        
        //-----------
        // Bus Access
        //-----------
        
%000000 function void uvm_reg_map::Xget_bus_infoX(uvm_reg_item rw,
%000000                                           output uvm_reg_map_info map_info,
%000000                                           output int size,
%000000                                           output int lsb,
%000000                                           output int addr_skip);
        
%000000   if (rw.get_element_kind() == UVM_MEM) begin
%000000     uvm_mem mem;
%000000     if(rw.get_element() == null || !$cast(mem,rw.get_element())) begin
              `uvm_fatal("REG/CAST", {"uvm_reg_item 'element_kind' is UVM_MEM, ",
%000000       "but 'element' does not point to a memory: ",rw.get_name()})
            end
%000000     map_info = get_mem_map_info(mem);
%000000     size = mem.get_n_bits();
          end
%000000   else if (rw.get_element_kind() == UVM_REG) begin
%000000     uvm_reg rg;
%000000     if(rw.get_element() == null || !$cast(rg,rw.get_element())) begin
              `uvm_fatal("REG/CAST", {"uvm_reg_item 'element_kind' is UVM_REG, ",
%000000       "but 'element' does not point to a register: ",rw.get_name()})
            end
%000000     map_info = get_reg_map_info(rg);
%000000     size = rg.get_n_bits();
          end
%000000   else if (rw.get_element_kind() == UVM_FIELD) begin
%000000     uvm_reg_field field;
%000000     if(rw.get_element() == null || !$cast(field,rw.get_element())) begin
              `uvm_fatal("REG/CAST", {"uvm_reg_item 'element_kind' is UVM_FIELD, ",
%000000       "but 'element' does not point to a field: ",rw.get_name()})
            end
%000000     map_info = get_reg_map_info(field.get_parent());
%000000     size = field.get_n_bits();
%000000     lsb = field.get_lsb_pos();
%000000     addr_skip = lsb/(get_n_bytes()*8);
          end
        endfunction
        
        
        
        
        // do_write(uvm_reg_item rw)
        
%000000 task uvm_reg_map::do_write(uvm_reg_item rw);
        
%000000   uvm_sequence_base tmp_parent_seq;
%000000   uvm_reg_map system_map = get_root_map();
%000000   uvm_reg_adapter adapter = system_map.get_adapter();
%000000   uvm_sequencer_base sequencer = system_map.get_sequencer();
%000000   uvm_reg_seq_base parent_proxy;
        
%000000   if (adapter != null && adapter.parent_sequence != null) begin
%000000     uvm_object o;
%000000     uvm_sequence_base seq;
%000000     o = adapter.parent_sequence.clone();
%000000     if (o == null) begin
              `uvm_fatal("REG/CLONE",
              {"failed to clone adapter's parent sequence: '",
              adapter.parent_sequence.get_full_name(),
              "' (of type '",
              adapter.parent_sequence.get_type_name(),
%000000       "')"})
            end
%000000     if (!$cast(seq, o)) begin
              `uvm_fatal("REG/CAST",
              {"failed to cast: '",
              o.get_full_name(),
              "' (of type '",
              o.get_type_name(),
%000000       "') to uvm_sequence_base!"})
            end
%000000     seq.set_parent_sequence(rw.get_parent_sequence());
%000000     rw.set_parent_sequence(seq);
%000000     tmp_parent_seq = seq;
          end
        
%000000   if (rw.get_parent_sequence() == null) begin
%000000     parent_proxy = new("default_parent_seq");
%000000     rw.set_parent_sequence(parent_proxy);
%000000     tmp_parent_seq = parent_proxy;
          end
        
%000000   if (adapter == null) begin
%000000     uvm_event#(uvm_object) end_event ;
%000000     uvm_event_pool ep;
%000000     ep = rw.get_event_pool();
%000000     end_event = ep.get("end") ;
%000000     rw.set_sequencer(sequencer);
%000000     tmp_parent_seq = rw.get_parent_sequence();
%000000     tmp_parent_seq.start_item(rw,rw.get_priority());
%000000     tmp_parent_seq.finish_item(rw);
%000000     end_event.wait_on();
          end
%000000   else begin
%000000     do_bus_write(rw, sequencer, adapter);
          end
        
%000000   if (tmp_parent_seq != null) begin
        
%000000     sequencer.m_sequence_exiting(tmp_parent_seq);
          end
        
        
        endtask
        
        
        // do_read(uvm_reg_item rw)
        
%000000 task uvm_reg_map::do_read(uvm_reg_item rw);
        
%000000   uvm_sequence_base tmp_parent_seq;
%000000   uvm_reg_map system_map = get_root_map();
%000000   uvm_reg_adapter adapter = system_map.get_adapter();
%000000   uvm_sequencer_base sequencer = system_map.get_sequencer();
%000000   uvm_reg_seq_base parent_proxy;
        
%000000   if (adapter != null && adapter.parent_sequence != null) begin
%000000     uvm_object o;
%000000     uvm_sequence_base seq;
%000000     o = adapter.parent_sequence.clone();
%000000     if (o == null) begin
              `uvm_fatal("REG/CLONE",
              {"failed to clone adapter's parent sequence: '",
              adapter.parent_sequence.get_full_name(),
              "' (of type '",
              adapter.parent_sequence.get_type_name(),
%000000       "')"})
            end
%000000     if (!$cast(seq, o)) begin
              `uvm_fatal("REG/CAST",
              {"failed to cast: '",
              o.get_full_name(),
              "' (of type '",
              o.get_type_name(),
%000000       "') to uvm_sequence_base!"})
            end
%000000     seq.set_parent_sequence(rw.get_parent_sequence());
%000000     rw.set_parent_sequence(seq);
%000000     tmp_parent_seq = seq;
          end
        
%000000   if (rw.get_parent_sequence() == null) begin
%000000     parent_proxy = new("default_parent_seq");
%000000     rw.set_parent_sequence(parent_proxy);
%000000     tmp_parent_seq = parent_proxy;
          end
        
%000000   if (adapter == null) begin
%000000     uvm_event#(uvm_object) end_event ;
%000000     uvm_event_pool ep;
%000000     ep = rw.get_event_pool();
%000000     end_event = ep.get("end") ;
%000000     rw.set_sequencer(sequencer);
%000000     tmp_parent_seq = rw.get_parent_sequence();
%000000     tmp_parent_seq.start_item(rw,rw.get_priority());
%000000     tmp_parent_seq.finish_item(rw);
%000000     end_event.wait_on();
          end
%000000   else begin
%000000     do_bus_read(rw, sequencer, adapter);
          end
        
%000000   if (tmp_parent_seq != null) begin
        
%000000     sequencer.m_sequence_exiting(tmp_parent_seq);
          end
        
        
        endtask
        
        
        // do_bus_write
        
%000000 task uvm_reg_map::do_bus_write (uvm_reg_item rw,
                                        uvm_sequencer_base sequencer,
                                        uvm_reg_adapter adapter);
        
%000000     do_bus_access(rw, sequencer, adapter);
        endtask
        
%000000 task uvm_reg_map::perform_accesses(ref uvm_reg_bus_op    accesses[$],
                input uvm_reg_item rw,
                input uvm_reg_adapter adapter,
                input  uvm_sequencer_base sequencer);
        
%000000     string op;
%000000     uvm_reg_data_logic_t data;
%000000         uvm_endianness_e endian;
        
%000000     op=(rw.get_kind() inside {UVM_READ,UVM_BURST_READ}) ? "Read" : "Wrote";
%000000         endian=get_endian(UVM_NO_HIER);
        
                // if set utilize the order policy
%000000     if(policy!=null) begin
        
%000000       policy.order(accesses);
            end
        
        
            // perform accesses
%000000     foreach(accesses[i]) begin
%000000       uvm_reg_bus_op rw_access=accesses[i];
%000000       uvm_sequence_item bus_req;
%000000       uvm_sequence_base rw_parent_seq;
%000000       uvm_reg_map rw_map;
%000000       uvm_status_e rw_status;
        
%000000       if ((rw_access.kind == UVM_WRITE) && (endian == UVM_BIG_ENDIAN)) begin
%000000         { >> { rw_access.data }} = { << byte { rw_access.data}};
              end
        
%000000       adapter.m_set_item(rw);
%000000       bus_req = adapter.reg2bus(rw_access);
%000000       adapter.m_set_item(null);
        
%000000       if (bus_req == null) begin
%000000         `uvm_fatal("RegMem",{"adapter [",adapter.get_name(),"] didnt return a bus transaction"})
              end
        
%000000       bus_req.set_sequencer(sequencer);
%000000       rw_parent_seq = rw.get_parent_sequence();
%000000       rw_parent_seq.start_item(bus_req,rw.get_priority());
        
%000000       if (rw_parent_seq != null && i == 0) begin
        
%000000         rw_parent_seq.mid_do(rw);
              end
        
        
%000000       rw_parent_seq.finish_item(bus_req);
%000000       begin
%000000         uvm_event#(uvm_object) end_event ;
%000000         uvm_event_pool ep;
%000000         ep = bus_req.get_event_pool();
%000000         end_event = ep.get("end") ;
%000000         end_event.wait_on();
              end
        
%000000       if (adapter.provides_responses) begin
%000000         uvm_sequence_item bus_rsp;
%000000         uvm_access_e op;
                // TODO: need to test for right trans type, if not put back in q
%000000         rw_parent_seq.get_base_response(bus_rsp,bus_req.get_transaction_id());
%000000         adapter.bus2reg(bus_rsp,rw_access);
              end
%000000       else begin
%000000         adapter.bus2reg(bus_req,rw_access);
              end
        
%000000       if ((rw_access.kind == UVM_READ) && (endian == UVM_BIG_ENDIAN)) begin
%000000         { >> { rw_access.data }} = { << byte { rw_access.data}};
              end
        
%000000       rw.set_status(rw_access.status);
        
%000000       begin
%000000         data = rw_access.data & ((1<<get_n_bytes()*8)-1); // mask the upper bits
        
%000000         if (rw.get_kind() inside {UVM_READ,UVM_BURST_READ}) begin
        
%000000           if (rw.get_status() == UVM_IS_OK && (^data) === 1'bx) begin
        
%000000             rw.set_status(UVM_HAS_X);
                  end
        
                end
        
        
%000000         rw_access.data=data;
              end
        
%000000       rw_map = rw.get_map();
%000000       rw_status = rw.get_status();
        
              `uvm_info("UVM/REG/ADDR",
              $sformatf("%s 'h%0h at 'h%0h via map \"%s\": %s...",op,
%000000       rw_access.data, rw_access.addr, rw_map.get_full_name(), rw_status.name()), UVM_FULL)
        
%000000       if (rw.get_status() == UVM_NOT_OK) begin
        
%000000         break;
              end
        
%000000       rw_parent_seq = rw.get_parent_sequence();
        
%000000       if (rw_parent_seq != null && i == accesses.size()-1) begin
        
%000000         rw_parent_seq.post_do(rw);
              end
        
        
%000000       accesses[i]=rw_access;
            end
        endtask
        
        // do_bus_read
        
%000000 task uvm_reg_map::do_bus_access (uvm_reg_item rw,
                                       uvm_sequencer_base sequencer,
                                       uvm_reg_adapter adapter);
        
%000000     uvm_reg_addr_t     addrs[$];
%000000     uvm_reg_map        system_map = get_root_map();
%000000     int unsigned       bus_width  = get_n_bytes();
%000000     uvm_reg_byte_en_t  byte_en    = -1;
%000000     uvm_reg_map_info   map_info;
%000000     int                n_bits;
%000000     int                lsb;
%000000     int                skip;
%000000     int unsigned       curr_byte;
%000000     int                n_access_extra, n_access;
%000000     uvm_reg_bus_op    accesses[$];
        //    int n_bits_init;
%000000     string op;
%000000     uvm_reg_addr_t adr[];
%000000     int unsigned byte_offset;
%000000     int unsigned num_stream_bytes;
%000000     int unsigned n_bytes;
%000000     int unsigned bytes_per_value;
%000000     int unsigned bit_shift;
%000000     int unsigned extra_byte;
        
%000000     uvm_reg_data_t rw_value;
%000000     int rw_value_size;
        
%000000     Xget_bus_infoX(rw, map_info, n_bits, lsb, skip);
%000000     addrs=map_info.addr;
%000000     op = (rw.get_kind() inside {UVM_READ,UVM_BURST_READ} ? "Reading" : "Writing");
        
%000000     case(rw.get_element_kind())
%000000       UVM_MEM: begin
%000000         uvm_mem mem;
%000000         $cast(mem,rw.get_element());
%000000         void'(get_physical_addresses_to_map(m_mems_info[mem].offset,rw.get_offset(),rw.get_value_size()*mem.get_n_bytes(),adr,null,byte_offset,mem));
%000000         num_stream_bytes =rw.get_value_size()*mem.get_n_bytes();
%000000         n_bytes=mem.get_n_bytes();
%000000         bytes_per_value=mem.get_n_bytes();
              end
%000000       UVM_FIELD: begin
%000000         uvm_reg_field f;
%000000         uvm_reg_addr_t ad;
%000000         $cast(f,rw.get_element());
        
                // adjust adr bit skipped bytes; still need to shift data by byte fractions (lsb)
%000000         void'(get_physical_addresses_to_map(m_regs_info[f.get_parent()].offset+skip,0,ceil(f.get_n_bits(),8),adr,null,byte_offset));
%000000         num_stream_bytes =ceil(f.get_n_bits(),8);
%000000         n_bytes=get_n_bytes(UVM_NO_HIER);
%000000         bytes_per_value=ceil(f.get_n_bits(),8);
%000000         bit_shift=lsb % (get_n_bytes()*8);
%000000         if(((bit_shift+f.get_n_bits()) /8) !=  ((f.get_n_bits()) /8)) begin
        
%000000           extra_byte=1;
                end
        
                //            `uvm_info("UVM/REG/ADDR",$sformatf("need to byte skip %0d and bit shift %0d",skip,bit_shift),UVM_DEBUG)
              end
%000000       UVM_REG: begin
%000000         uvm_reg r;
%000000         uvm_reg_addr_t ad;
%000000         $cast(r,rw.get_element());
        
%000000         void'(get_physical_addresses_to_map(m_regs_info[r].offset,0,r.get_n_bytes(),adr,null,byte_offset));
%000000         num_stream_bytes =r.get_n_bytes();
%000000         n_bytes=get_n_bytes(UVM_NO_HIER);
%000000         bytes_per_value=r.get_n_bytes();
              end
            endcase
        
%000000     begin
%000000       bit be[$];
%000000       byte unsigned p[$];
%000000       uvm_reg_data_t values[];
%000000       typedef bit bit_q_t[$];
        
              // adjust bytes if there is a leading bit shift
%000000       num_stream_bytes+=extra_byte;
        
%000000       repeat(byte_offset) begin
%000000         be.push_back(1'b0);
              end
              // TODO rewrite
%000000       repeat(num_stream_bytes) begin
%000000         be.push_back(1'b1);
              end
        
%000000       repeat(bus_width) begin
%000000         be.push_back(1'b0);
              end
        
        
              // now shift data to match the alignment
%000000       repeat(byte_offset) begin
%000000         p.push_back(8'b0);
              end
        
%000000       rw.get_value_array(values);
%000000       foreach(values[idx]) begin
%000000         for(int i=0;i<bytes_per_value;i++) begin
%000000           p.push_back(values[idx][8*i+:8]);
                end
              end
        
        
%000000       if(bit_shift) begin
%000000         bit bits[$];
                // The streaming operator is very useful for converting
                // a byte stream to a bit stream, but the below line
                // may be a little confusing.
                // {<<{p}} -> This converts our byte stream (p) into a bit stream,
                //            but it makes '{'hC7,'h3F} into 'b1100_0111__0011_1111.
                //            Note that the endianness of the bytes has changed, ie.
                //            the high order byte ('h3F) is now the low order byte.
                // {<<8{ ... } -> This takes the bit stream and corrects the endianness
                //                8 bits at a time.
%000000         bits = {<< 8 {bit_q_t'({<< {p}}) }};
%000000         repeat(bit_shift) begin
        
%000000           bits.push_front(1'b0);
                end
        
                // This operation is the exact opposite of above, converting the
                // bitstream into a byte stream, and then reversing the endianness of
                // the byte stream.
%000000         p = {<< 8 {bit_q_t'({<< {bits}}) }};
              end
        
              /*
              if (uvm_report_enabled(UVM_NONE, UVM_INFO, "UVM/REG/ADDR")) begin
              `uvm_info("UVM/REG/ADDR", $sformatf("bit_shift = %0d", bit_shift), UVM_NONE)
              foreach(be[idx])
              `uvm_info("UVM/REG/ADDR",$sformatf("idx %0d en=%0d",idx,be[idx]),UVM_NONE)
        
              foreach(adr[idx])
              `uvm_info("UVM/REG/ADDR",$sformatf("mem-adr %0x byte-offset=%0d",adr[idx],byte_offset),UVM_NONE)
              foreach(values[idx])
              `uvm_info("UVM/REG/ADDR", $sformatf("idx %0d mem-val=%0x", idx, values[idx]), UVM_NONE)
        
              foreach(p[idx])
              `uvm_info("UVM/REG/ADDR",$sformatf("idx %0d data=%x enable=%0d",idx,p[idx],be[idx]),UVM_NONE)
        
              foreach(rw.value[idx])
              `uvm_info("UVM/REG/ADDR",$sformatf("original idx=%0d %0x",idx,rw.value[idx]),UVM_NONE)
        
              end
              */
        
              // transform into accesses per address
%000000       accesses.delete();
%000000       foreach(adr[i]) begin
%000000         uvm_reg_bus_op rw_access;
%000000         uvm_reg_data_t data='0;
%000000         uvm_reg_map tmp_map = rw.get_map();
        
%000000         for(int i0=0;i0<bus_width;i0++) begin
        
%000000           data[i0*8+:8]=p[i*bus_width+i0];
                end
        
                `uvm_info("UVM/REG/ADDR",
                $sformatf("%s 'h%0h at 'h%0h via map \"%s\"...",op,
%000000         data, adr[i], tmp_map.get_full_name()), UVM_FULL)
        
%000000         for (int z=0;z<bus_width;z++) begin
        
%000000           rw_access.byte_en[z] = be[bus_width*i+z];
                end
        
        
%000000         rw_access.kind    = rw.get_kind();
%000000         rw_access.addr    = adr[i];
%000000         rw_access.data    = data;
        
%000000         rw_access.n_bits=8*bus_width;
%000000         for(int i=bus_width-1;i>=0;i--) begin
%000000           if(rw_access.byte_en[i]==0) begin
        
%000000             rw_access.n_bits-=8;
                  end
        
%000000           else begin
        
%000000             break;
                  end
        
                end
        
%000000         accesses.push_back(rw_access);
              end
        
%000000       perform_accesses(accesses, rw, adapter, sequencer);
        
              // for reads copy back to rw.value
%000000       if(rw.get_kind() inside {UVM_READ,UVM_BURST_READ}) begin
%000000         int rw_value_size;
%000000         p.delete();
%000000         foreach(accesses[i0]) begin
        
%000000           for(int i1=0;i1<bus_width;i1++) begin
        
%000000             p.push_back(accesses[i0].data[i1*8+:8]);
                  end
        
                end
        
        
%000000         repeat(byte_offset) begin
%000000           void'(p.pop_front());
                end
        
%000000         rw_value_size = rw.get_value_size();
%000000         for(int i = 0; i < rw_value_size; i++) begin
%000000           rw.set_value(0,i);
                end
        
%000000         if(bit_shift) begin
%000000           uvm_reg_data_t ac;
%000000           ac='0;
%000000           for(int i=0;i<p.size();i++) begin
%000000             byte nv;
%000000             nv=(p[i] >> bit_shift);
%000000             if(i!=p.size()-1) begin
        
%000000               nv |= (p[i+1]<<bit_shift);
                    end
        
        
%000000             p[i] = nv;
                  end
%000000           if(extra_byte) begin
        
%000000             void'(p.pop_back());
                  end
        
                end
        
%000000         rw_value_size = rw.get_value_size();
%000000         for(int idx = 0; idx < rw_value_size; idx++) begin
%000000           rw_value = rw.get_value(idx);
%000000           for(int i0=0;i0<bytes_per_value;i0++) begin
        
%000000             rw_value[i0*8+:8]= p[idx*bytes_per_value+i0];
                  end
        
%000000           rw.set_value(rw_value, idx);
                end
        
%000000         if(rw.get_element_kind() == UVM_FIELD) begin
%000000           uvm_reg_field f;
%000000           uvm_reg_data_t m;
        
%000000           $cast(f,rw.get_element());
        
%000000           m = (1 << f.get_n_bits())-1;
%000000           rw_value_size = rw.get_value_size();
%000000           for(int idx = 0; idx < rw_value_size; idx++) begin
%000000             rw_value = rw.get_value(idx);
%000000             rw_value &= m;
%000000             rw.set_value(rw_value, idx);
                  end
                end
        
                /*
                if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "UVM/REG/ADDR"))
                foreach(rw.value[idx])
                `    uvm_info("UVM/REG/ADDR",$sformatf("read return idx=%0d %0x",idx,rw.value[idx]),UVM_DEBUG)
                */
        
              end
            end
        endtask
        
%000000 task uvm_reg_map::do_bus_read (uvm_reg_item rw,
                                       uvm_sequencer_base sequencer,
                                       uvm_reg_adapter adapter);
        
%000000 do_bus_access(rw, sequencer, adapter);
        
        endtask: do_bus_read
        
        
        
        //-------------
        // Standard Ops
        //-------------
        
        // do_print
        
%000000 function void uvm_reg_map::do_print (uvm_printer printer);
%000000    uvm_reg  regs[$];
%000000    uvm_vreg vregs[$];
%000000    uvm_mem  mems[$];
%000000    uvm_endianness_e endian;
%000000    uvm_reg_map maps[$];
%000000    string prefix;
%000000    uvm_sequencer_base sqr=get_sequencer();
        
%000000    super.do_print(printer);
        
%000000    endian = get_endian(UVM_NO_HIER);
        
%000000    printer.print_generic("endian","",-2,endian.name());
%000000    printer.print_field_int("n_bytes", get_n_bytes(UVM_NO_HIER), 64, UVM_DEC);
%000000    printer.print_field_int("byte addressing",get_addr_unit_bytes()==1,64,UVM_DEC);
        
%000000    if(sqr!=null) begin
        
%000000      printer.print_generic("effective sequencer",sqr.get_type_name(),-2,sqr.get_full_name());
           end
        
        
%000000    get_registers(regs,UVM_NO_HIER);
%000000    foreach (regs[j]) begin
        
%000000      printer.print_generic(regs[j].get_name(), regs[j].get_type_name(),-2,$sformatf("@%0d +'h%0x",regs[j].get_inst_id(),regs[j].get_address(this)));
           end
        
        
        
%000000    get_memories(mems);
%000000    foreach (mems[j]) begin
        
%000000      printer.print_generic(mems[j].get_name(), mems[j].get_type_name(),-2,$sformatf("@%0d +'h%0x",mems[j].get_inst_id(),mems[j].get_address(0,this)));
           end
        
        
%000000    get_virtual_registers(vregs);
%000000    foreach (vregs[j]) begin
        
%000000      printer.print_generic(vregs[j].get_name(), vregs[j].get_type_name(),-2,$sformatf("@%0d +'h%0x",vregs[j].get_inst_id(),vregs[j].get_address(0,this)));
           end
        
        
%000000    get_submaps(maps);
%000000    foreach (maps[j]) begin
        
%000000      printer.print_object(maps[j].get_name(),maps[j]);
           end
        
        endfunction
        
        // convert2string
        
%000000 function string uvm_reg_map::convert2string();
%000000    uvm_reg  regs[$];
%000000    uvm_vreg vregs[$];
%000000    uvm_mem  mems[$];
%000000    uvm_endianness_e endian;
%000000    string prefix;
        
%000000    $sformat(convert2string, "%sMap %s", prefix, get_full_name());
%000000    endian = get_endian(UVM_NO_HIER);
%000000    $sformat(convert2string, "%s -- %0d bytes (%s)", convert2string,
%000000             get_n_bytes(UVM_NO_HIER), endian.name());
%000000    get_registers(regs);
%000000    foreach (regs[j]) begin
%000000      $sformat(convert2string, "%s\n%s", convert2string,
%000000                regs[j].convert2string());//{prefix, "   "}, this));
           end
%000000    get_memories(mems);
%000000    foreach (mems[j]) begin
%000000      $sformat(convert2string, "%s\n%s", convert2string,
%000000                mems[j].convert2string());//{prefix, "   "}, this));
           end
%000000    get_virtual_registers(vregs);
%000000    foreach (vregs[j]) begin
%000000      $sformat(convert2string, "%s\n%s", convert2string,
%000000                vregs[j].convert2string());//{prefix, "   "}, this));
           end
        endfunction
        
        
        // clone
        
%000000 function uvm_object uvm_reg_map::clone();
%000000    `uvm_fatal("UVM/REGMAP/NOCLONE","uvm_reg_map doesnt support clone()")
%000000    return null;
        endfunction
        
        
        // do_copy
        
%000000 function void uvm_reg_map::do_copy (uvm_object rhs);
          //uvm_reg_map rhs_;
          //if (!$cast(seq, o))
          //  `uvm_fatal(...)
        
          //rhs_.regs = regs;
          //rhs_.mems = mems;
          //rhs_.vregs = vregs;
          //rhs_.blks = blks;
          //... and so on
        endfunction
        
