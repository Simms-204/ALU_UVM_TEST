//      // verilator_coverage annotation
        //
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2018-2022 Intel Corporation
        // Copyright 2020-2022 Marvell International Ltd.
        // Copyright 2010-2020 Mentor Graphics Corporation
        // Copyright 2026 Microsoft
        // Copyright 2014-2026 NVIDIA Corporation
        // Copyright 2011-2022 Semifore
        // Copyright 2004-2018 Synopsys, Inc.
        // Copyright 2020 Verific
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
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/reg/uvm_reg.svh $
        // $Rev:      2026-06-10 09:59:36 -0700 $
        // $Hash:     d69bd29b12f83a7fb6866ad5fd1247d0968f1bca $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_reg_cbs;
        typedef class uvm_reg_frontdoor;
        typedef class uvm_reg;
        
        // Class: uvm_reg_err_service
        // This class contains virtual functions implementing error messages from uvm_reg.
        // The user may factory-replace this class to produce messages with a different
        // format.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        class uvm_reg_err_service extends uvm_object ;
        
%000000    `uvm_object_utils(uvm_reg_err_service)
        
           static uvm_reg_err_service inst ;
        
           // Function : get()
           // Called by the library when a supported uvm_reg error occurs.  Returns an
           // instance of the standard UVM library class if set() has not been called or
           // has been called with a null instance; otherwise, returns the instance
           // passed to set().
           //
           // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
%000000    static function uvm_reg_err_service get() ;
%000000       if (inst == null) begin
%000000         inst = uvm_reg_err_service::type_id::create("uvm_inst");
              end
        
%000000       return inst ;
           endfunction
        
           // Function : set()
           // May be called to pass a new instance of a derived class, to be returned
           // by a subsequent call to get().
           //
           // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
%000000    static function void set(uvm_reg_err_service es) ;
%000000       inst = es ;
           endfunction
        
%000000    function new (string name="");
%000000       super.new(name);
           endfunction
        
           // Function: do_check_error
           //
           // Called when do_check finds a mismatch to create the error message
           // and any other supporting information.  Users may customize the look
           // of this error message by overriding this function.
           //
           extern virtual function void do_check_error(uvm_reg        this_reg,
                                                uvm_reg_data_t       expected,
                                                uvm_reg_data_t       actual,
                                                uvm_reg_map          map,
                                                uvm_reg_data_t       valid_bits_mask);
        endclass
        
        // Class: uvm_reg
        // This is an implementation of uvm_reg as described in 1800.2 with
        // the addition of API described below.
        
        // @uvm-ieee 1800.2-2020 auto 18.4.1
        class uvm_reg extends uvm_object;
        
           local bit               m_locked;
           local uvm_reg_block     m_parent;
           local uvm_reg_file      m_regfile_parent;
           local int unsigned      m_n_bits;
           local int unsigned      m_n_used_bits;
           protected bit           m_maps[uvm_reg_map];
           protected uvm_reg_field m_fields[$];   // Fields in LSB to MSB order
           local int               m_has_cover;
           local int               m_cover_on;
           local semaphore         m_atomic;
           local process           m_process;
           local string            m_fname;
           local int               m_lineno;
           local bit               m_read_in_progress;
           local bit               m_write_in_progress;
           protected bit           m_update_in_progress;
           /*local*/ bit           m_is_busy;
           /*local*/ bit           m_is_locked_by_field;
           local int               m_atomic_cnt;
           local uvm_reg_backdoor  m_backdoor;
        
           local static int unsigned m_max_size;
        
           local static uvm_reg_err_service  m_err_service ;
        
           local uvm_object_string_pool
               #(uvm_queue #(uvm_hdl_path_concat)) m_hdl_paths_pool;
        
           /*local*/ static uvm_reg m_reg_registry[string];
           //----------------------
           // Group -- NODOCS -- Initialization
           //----------------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.2.1
           extern function new (string name="",
                                int unsigned n_bits,
                                int has_coverage);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.2.2
           extern function void configure (uvm_reg_block blk_parent,
                                           uvm_reg_file regfile_parent = null,
                                           string hdl_path = "");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.2.3
           extern virtual function void set_offset (uvm_reg_map    map,
                                                    uvm_reg_addr_t offset,
                                                    bit            unmapped = 0);
        
           /*local*/ extern virtual function void set_parent (uvm_reg_block blk_parent,
                                                              uvm_reg_file regfile_parent);
           /*local*/ extern virtual function void add_field  (uvm_reg_field field);
           /*local*/ extern virtual function void add_map    (uvm_reg_map map);
        
           /*local*/ extern function void   Xlock_modelX;
        
           /*local*/ extern function void   Xunlock_modelX;
        
            // remove the knowledge that the register resides in the map from the register instance
            // @uvm-ieee 1800.2-2020 auto 18.4.2.5
%000000     virtual function void unregister(uvm_reg_map map);
%000000         m_maps.delete(map);
            endfunction
        
        
           //---------------------
           // Group -- NODOCS -- Introspection
           //---------------------
        
           // Function -- NODOCS -- get_name
           //
           // Get the simple name
           //
           // Return the simple object name of this register.
           //
        
           // Function -- NODOCS -- get_full_name
           //
           // Get the hierarchical name
           //
           // Return the hierarchal name of this register.
           // The base of the hierarchical name is the root block.
           //
           extern virtual function string get_full_name();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.1
           extern virtual function uvm_reg_block get_parent ();
           extern virtual function uvm_reg_block get_block  ();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.2
           extern virtual function uvm_reg_file get_regfile ();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.3
           extern virtual function int get_n_maps ();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.4
           extern function bit is_in_map (uvm_reg_map map);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.5
           extern virtual function void get_maps (ref uvm_reg_map maps[$]);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.6
           extern virtual function uvm_reg_map get_local_map (uvm_reg_map map);
        
           // Function: get_default_map
           //
           // Returns default map for the register as follows:
           //
           // If the register is not associated with any map - returns null
           // Else If the register is associated with only one map - return a handle to that map
           // Else try to find the first default map in its parent blocks and return its handle
           // If there are no default maps in the registers parent blocks return a handle to the first map in its map array
           //
           // @uvm-contrib
           extern virtual function uvm_reg_map get_default_map ();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.7
           extern virtual function string get_rights (uvm_reg_map map = null);
        
        
           // Function -- NODOCS -- get_n_bits
           //
           // Returns the width, in bits, of this register.
           //
           extern virtual function int unsigned get_n_bits ();
        
        
           // Function -- NODOCS -- get_n_bytes
           //
           // Returns the width, in bytes, of this register. Rounds up to
           // next whole byte if register is not a multiple of 8.
           //
           extern virtual function int unsigned get_n_bytes();
        
        
           // Function -- NODOCS -- get_max_size
           //
           // Returns the maximum width, in bits, of all registers.
           //
           extern static function int unsigned get_max_size();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.11
           extern virtual function void get_fields (ref uvm_reg_field fields[$]);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.12
           extern virtual function uvm_reg_field get_field_by_name(string name);
        
        
           /*local*/ extern function string Xget_fields_accessX(uvm_reg_map map);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.13
           extern virtual function uvm_reg_addr_t get_offset (uvm_reg_map map = null);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.14
           extern virtual function uvm_reg_addr_t get_address (uvm_reg_map map = null);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.3.15
           extern virtual function int get_addresses (uvm_reg_map map = null,
                                                      ref uvm_reg_addr_t addr[]);
        
           // Function -- NODOCS -- get_reg_by_full_name
           //
           // Finds a register with the specified full hierarchical name.
           //
           // The name is the full name of the register, starting with the root block.
           // The function looks up the cached registry built after register model is locked
           //
           // If no register is found, returns ~null~.
        
%000000    static function uvm_reg get_reg_by_full_name(string name);
%000000       return m_reg_registry[name];
           endfunction
        
           //--------------
           // Group -- NODOCS -- Access
           //--------------
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.2
           extern virtual function void set (uvm_reg_data_t  value,
                                             string          fname = "",
                                             int             lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.1
           extern virtual function uvm_reg_data_t  get(string  fname = "",
                                                       int     lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.3
           extern virtual function uvm_reg_data_t  get_mirrored_value(string  fname = "",
                                                       int     lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.4
           extern virtual function bit needs_update();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.5
           extern virtual function void reset(string kind = "HARD");
        
        
           // Function -- NODOCS -- get_reset
           //
           // Get the specified reset value for this register
           //
           // Return the reset value for this register
           // for the specified reset ~kind~.
           //
           extern virtual function uvm_reg_data_t
                                     // @uvm-ieee 1800.2-2020 auto 18.4.4.6
                                     get_reset(string kind = "HARD");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.7
           extern virtual function bit has_reset(string kind = "HARD",
                                                 bit    delete = 0);
        
        
           // Function -- NODOCS -- set_reset
           //
           // Specify or modify the reset value for this register
           //
           // Specify or modify the reset value for all the fields in the register
           // corresponding to the cause specified by ~kind~.
           //
           extern virtual function void
                               // @uvm-ieee 1800.2-2020 auto 18.4.4.8
                               set_reset(uvm_reg_data_t value,
                                         string         kind = "HARD");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.9
           // @uvm-ieee 1800.2-2020 auto 18.8.5.3
           extern virtual task write(output uvm_status_e      status,
                                     input  uvm_reg_data_t    value,
                                     input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                                     input  uvm_reg_map       map = null,
                                     input  uvm_sequence_base parent = null,
                                     input  int               prior = -1,
                                     input  uvm_object        extension = null,
                                     input  string            fname = "",
                                     input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.10
           // @uvm-ieee 1800.2-2020 auto 18.8.5.4
           extern virtual task read(output uvm_status_e      status,
                                    output uvm_reg_data_t    value,
                                    input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                                    input  uvm_reg_map       map = null,
                                    input  uvm_sequence_base parent = null,
                                    input  int               prior = -1,
                                    input  uvm_object        extension = null,
                                    input  string            fname = "",
                                    input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.11
           extern virtual task poke(output uvm_status_e      status,
                                    input  uvm_reg_data_t    value,
                                    input  string            kind = "",
                                    input  uvm_sequence_base parent = null,
                                    input  uvm_object        extension = null,
                                    input  string            fname = "",
                                    input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.12
           extern virtual task peek(output uvm_status_e      status,
                                    output uvm_reg_data_t    value,
                                    input  string            kind = "",
                                    input  uvm_sequence_base parent = null,
                                    input  uvm_object        extension = null,
                                    input  string            fname = "",
                                    input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.13
           extern virtual task update(output uvm_status_e      status,
                                      input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                                      input  uvm_reg_map       map = null,
                                      input  uvm_sequence_base parent = null,
                                      input  int               prior = -1,
                                      input  uvm_object        extension = null,
                                      input  string            fname = "",
                                      input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.14
           // @uvm-ieee 1800.2-2020 auto 18.8.5.6
           extern virtual task mirror(output uvm_status_e      status,
                                      input uvm_check_e        check  = UVM_NO_CHECK,
                                      input uvm_door_e         path = UVM_DEFAULT_DOOR,
                                      input uvm_reg_map        map = null,
                                      input uvm_sequence_base  parent = null,
                                      input int                prior = -1,
                                      input  uvm_object        extension = null,
                                      input string             fname = "",
                                      input int                lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.15
           // @uvm-ieee 1800.2-2020 auto 18.8.5.7
           extern virtual function bit predict (uvm_reg_data_t    value,
                                                uvm_reg_byte_en_t be = -1,
                                                uvm_predict_e     kind = UVM_PREDICT_DIRECT,
                                                uvm_door_e        path = UVM_FRONTDOOR,
                                                uvm_reg_map       map = null,
                                                string            fname = "",
                                                int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.4.16
           extern function bit is_busy();
        
        
        
           /*local*/ extern function void Xset_busyX(bit busy);
        
           /*local*/ extern task XreadX (output uvm_status_e      status,
                                         output uvm_reg_data_t    value,
                                         input  uvm_door_e        path,
                                         input  uvm_reg_map       map,
                                         input  uvm_sequence_base parent = null,
                                         input  int               prior = -1,
                                         input  uvm_object        extension = null,
                                         input  string            fname = "",
                                         input  int               lineno = 0);
        
           /*local*/ extern task XatomicX(bit on);
        
           /*local*/ extern virtual function bit Xcheck_accessX
                                        (input uvm_reg_item rw,
                                         output uvm_reg_map_info map_info);
        
           /*local*/ extern function bit Xis_locked_by_fieldX();
        
        
           extern virtual function bit do_check(uvm_reg_data_t expected,
                                                uvm_reg_data_t actual,
                                                uvm_reg_map    map);
        
        
           extern virtual task do_write(uvm_reg_item rw);
        
           extern virtual task do_read(uvm_reg_item rw);
        
           extern virtual function void do_predict
                                        (uvm_reg_item      rw,
                                         uvm_predict_e     kind = UVM_PREDICT_DIRECT,
                                         uvm_reg_byte_en_t be = -1);
           //-----------------
           // Group -- NODOCS -- Frontdoor
           //-----------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.5.2
           extern function void set_frontdoor(uvm_reg_frontdoor ftdr,
                                              uvm_reg_map       map = null,
                                              string            fname = "",
                                              int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.5.1
           extern function uvm_reg_frontdoor get_frontdoor(uvm_reg_map map = null);
        
        
           //----------------
           // Group -- NODOCS -- Backdoor
           //----------------
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.2
           extern function void set_backdoor(uvm_reg_backdoor bkdr,
                                             string          fname = "",
                                             int             lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.1
           extern function uvm_reg_backdoor get_backdoor(bit inherited = 1);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.3
           extern function void clear_hdl_path (string kind = "RTL");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.4
           extern function void add_hdl_path (uvm_hdl_path_slice slices[],
                                              string kind = "RTL");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.5
           extern function void add_hdl_path_slice(string name,
                                                   int offset,
                                                   int size,
                                                   bit first = 0,
                                                   string kind = "RTL");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.6
           extern function bit has_hdl_path (string kind = "");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.7
           extern function void get_hdl_path (ref uvm_hdl_path_concat paths[$],
                                              input string kind = "");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.8
           extern function void get_hdl_path_kinds (ref string kinds[$]);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.9
           extern function void get_full_hdl_path (ref uvm_hdl_path_concat paths[$],
                                                   input string kind = "",
                                                   input string separator = ".");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.10
           extern virtual task backdoor_read(uvm_reg_item rw);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.11
           extern virtual task backdoor_write(uvm_reg_item rw);
        
        
        
           extern virtual function uvm_status_e backdoor_read_func(uvm_reg_item rw);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.6.12
%000000    virtual task  backdoor_watch(); endtask
        
        
           //----------------
           // Group -- NODOCS -- Coverage
           //----------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.1
           extern static function void include_coverage(string scope,
                                                        uvm_reg_cvr_t models,
                                                        uvm_object accessor = null);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.2
           extern protected function uvm_reg_cvr_t build_coverage(uvm_reg_cvr_t models);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.3
           extern virtual protected function void add_coverage(uvm_reg_cvr_t models);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.4
           extern virtual function bit has_coverage(uvm_reg_cvr_t models);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.6
           extern virtual function uvm_reg_cvr_t set_coverage(uvm_reg_cvr_t is_on);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.5
           extern virtual function bit get_coverage(uvm_reg_cvr_t is_on);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.7
%000000    protected virtual function void sample(uvm_reg_data_t  data,
                                                  uvm_reg_data_t  byte_en,
                                                  bit             is_read,
                                                  uvm_reg_map     map);
           endfunction
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.7.8
%000000    virtual function void sample_values();
           endfunction
        
%000000    /*local*/ function void XsampleX(uvm_reg_data_t  data,
                                            uvm_reg_data_t  byte_en,
                                            bit             is_read,
                                            uvm_reg_map     map);
%000000       sample(data, byte_en, is_read, map);
           endfunction
        
        
           //-----------------
           // Group -- NODOCS -- Callbacks
           //-----------------
%000003    `uvm_register_cb(uvm_reg, uvm_reg_cbs)
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.8.1
%000000    virtual task pre_write(uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.8.2
%000000    virtual task post_write(uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.8.3
%000000    virtual task pre_read(uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.4.8.4
%000000    virtual task post_read(uvm_reg_item rw); endtask
        
        
           extern virtual function void            do_print (uvm_printer printer);
           extern virtual function string          convert2string();
           extern virtual function uvm_object      clone      ();
           extern virtual function void            do_copy    (uvm_object rhs);
           extern virtual function bit             do_compare (uvm_object  rhs,
                                                               uvm_comparer comparer);
           extern virtual function void            do_pack    (uvm_packer packer);
           extern virtual function void            do_unpack  (uvm_packer packer);
        
        endclass: uvm_reg
        
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
        
        
        // new
        
%000000 function uvm_reg::new(string name="", int unsigned n_bits, int has_coverage);
%000000    super.new(name);
%000000    if (n_bits == 0) begin
%000000      `uvm_error("RegModel", $sformatf("Register \"%s\" cannot have 0 bits", get_name()))
%000000      n_bits = 1;
           end
%000000    m_n_bits      = n_bits;
%000000    m_has_cover   = has_coverage;
%000000    m_atomic      = new(1);
%000000    m_n_used_bits = 0;
%000000    m_locked      = 0;
%000000    m_is_busy     = 0;
%000000    m_is_locked_by_field = 1'b0;
%000000    m_atomic_cnt  = 0;
%000000    m_process     = null;
%000000    m_hdl_paths_pool = new("hdl_paths");
        
%000000    if (n_bits > m_max_size) begin
        
%000000      m_max_size = n_bits;
           end
        
        
        endfunction: new
        
        
        // configure
        
%000000 function void uvm_reg::configure (uvm_reg_block blk_parent,
                                          uvm_reg_file regfile_parent=null,
                                          string hdl_path = "");
%000000    if (blk_parent == null) begin
%000000      `uvm_error("UVM/REG/CFG/NOBLK", {"uvm_reg::configure() called without a parent block for instance \"", get_name(), "\" of register type \"", get_type_name(), "\"."})
%000000      return;
           end
        
%000000    m_parent = blk_parent;
%000000    m_parent.add_reg(this);
%000000    m_regfile_parent = regfile_parent;
%000000    if (hdl_path != "") begin
        
%000000      add_hdl_path_slice(hdl_path, -1, -1);
           end
        
        
        endfunction: configure
        
        
        // add_field
        
%000000 function void uvm_reg::add_field(uvm_reg_field field);
%000000    int offset;
%000000    int idx;
        
%000000    if (m_locked) begin
%000000      `uvm_error("RegModel", "Cannot add field to locked register model")
%000000      return;
           end
        
%000000    if (field == null) begin
%000000      `uvm_fatal("RegModel", "Attempting to register NULL field")
           end
        
           // Store fields in LSB to MSB order
%000000    offset = field.get_lsb_pos();
        
%000000    idx = -1;
%000000    foreach (m_fields[i]) begin
%000000      if (offset < m_fields[i].get_lsb_pos()) begin
%000000        int j = i;
%000000        m_fields.insert(j, field);
%000000        idx = i;
%000000        break;
             end
           end
%000000    if (idx < 0) begin
%000000      m_fields.push_back(field);
%000000      idx = m_fields.size()-1;
%000000      m_n_used_bits = offset + field.get_n_bits();
           end
        
           // Check if there are too many fields in the register
%000000    if (m_n_used_bits > m_n_bits) begin
             `uvm_error("RegModel",
             $sformatf("Fields use more bits (%0d) than available in register \"%s\" (%0d)",
%000000      m_n_used_bits, get_name(), m_n_bits))
           end
        
           // Check if there are overlapping fields
%000000    if (idx > 0) begin
%000000      if (m_fields[idx-1].get_lsb_pos() +
%000000      m_fields[idx-1].get_n_bits() > offset) begin
               `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in register \"%s\"",
               m_fields[idx-1].get_name(),
%000000        field.get_name(), get_name()))
             end
           end
%000000    if (idx < m_fields.size()-1) begin
%000000      if (offset + field.get_n_bits() >
%000000      m_fields[idx+1].get_lsb_pos()) begin
               `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in register \"%s\"",
               field.get_name(),
               m_fields[idx+1].get_name(),
%000000        get_name()))
             end
           end
        endfunction: add_field
        
        
        // Xlock_modelX
        
%000000 function void uvm_reg::Xlock_modelX();
%000000    if (m_locked) begin
        
%000000      return;
           end
        
        
%000000    m_reg_registry[get_full_name()] = this;
%000000    foreach (m_fields[f]) begin
        
%000000      uvm_reg_field::m_reg_field_registry[m_fields[f].get_full_name()]=m_fields[f];
           end
        
        
%000000    m_locked = 1;
        endfunction
        
        // Xunlock_modelX
        
%000000 function void uvm_reg::Xunlock_modelX();
%000000    uvm_reg::m_reg_registry.delete(this.get_full_name());
%000000    foreach (m_fields[f]) begin
        
%000000      uvm_reg_field::m_reg_field_registry.delete(m_fields[f].get_full_name());
           end
        
%000000    m_locked = 0;
        endfunction
        
        
        //----------------------
        // Group- User Frontdoor
        //----------------------
        
        // set_frontdoor
        
%000000 function void uvm_reg::set_frontdoor(uvm_reg_frontdoor ftdr,
                                             uvm_reg_map       map = null,
                                             string            fname = "",
                                             int               lineno = 0);
%000000    uvm_reg_map_info map_info;
%000000    ftdr.fname = m_fname;
%000000    ftdr.lineno = m_lineno;
%000000    map = get_local_map(map);
%000000    if (map == null) begin
        
%000000      return;
           end
        
%000000    map_info = map.get_reg_map_info(this);
%000000    if (map_info == null) begin
        
%000000      map.add_reg(this, -1, "RW", 1, ftdr);
           end
        
%000000    else begin
%000000      map_info.frontdoor = ftdr;
           end
        endfunction: set_frontdoor
        
        
        // get_frontdoor
        
%000000 function uvm_reg_frontdoor uvm_reg::get_frontdoor(uvm_reg_map map = null);
%000000    uvm_reg_map_info map_info;
%000000    map = get_local_map(map);
%000000    if (map == null) begin
        
%000000      return null;
           end
        
%000000    map_info = map.get_reg_map_info(this);
%000000    return map_info.frontdoor;
        endfunction: get_frontdoor
        
        
        // set_backdoor
        
%000000 function void uvm_reg::set_backdoor(uvm_reg_backdoor bkdr,
                                            string           fname = "",
                                            int              lineno = 0);
%000000    bkdr.fname = fname;
%000000    bkdr.lineno = lineno;
%000000    if (m_backdoor != null &&
%000000        m_backdoor.has_update_threads()) begin
%000000      `uvm_warning("RegModel", "Previous register backdoor still has update threads running. Backdoors with active mirroring should only be set before simulation starts.")
           end
%000000    m_backdoor = bkdr;
        endfunction: set_backdoor
        
        
        // get_backdoor
        
%000000 function uvm_reg_backdoor uvm_reg::get_backdoor(bit inherited = 1);
        
%000000    if (m_backdoor == null && inherited) begin
%000000      uvm_reg_block blk = get_parent();
%000000      uvm_reg_backdoor bkdr;
%000000      while (blk != null) begin
%000000        bkdr = blk.get_backdoor();
%000000        if (bkdr != null) begin
%000000          m_backdoor = bkdr;
%000000          break;
               end
%000000        blk = blk.get_parent();
             end
           end
%000000    return m_backdoor;
        endfunction: get_backdoor
        
        
        
        // clear_hdl_path
        
%000000 function void uvm_reg::clear_hdl_path(string kind = "RTL");
%000000   if (kind == "ALL") begin
%000000     m_hdl_paths_pool = new("hdl_paths");
%000000     return;
          end
        
%000000   if (kind == "") begin
%000000     if (m_regfile_parent != null) begin
        
%000000       kind = m_regfile_parent.get_default_hdl_path();
            end
        
%000000     else begin
        
%000000       kind = m_parent.get_default_hdl_path();
            end
        
          end
        
%000000   if (!m_hdl_paths_pool.exists(kind)) begin
%000000     `uvm_warning("RegModel",{"Unknown HDL Abstraction '",kind,"'"})
%000000     return;
          end
        
%000000   m_hdl_paths_pool.delete(kind);
        endfunction
        
        
        // add_hdl_path
        
%000000 function void uvm_reg::add_hdl_path(uvm_hdl_path_slice slices[],
                                            string kind = "RTL");
%000000     uvm_queue #(uvm_hdl_path_concat) paths = m_hdl_paths_pool.get(kind);
%000000     uvm_hdl_path_concat concat = new();
        
%000000     concat.set(slices);
%000000     paths.push_back(concat);
        endfunction
        
        
        // add_hdl_path_slice
        
%000000 function void uvm_reg::add_hdl_path_slice(string name,
                                                  int offset,
                                                  int size,
%000000                                           bit first = 0,
%000000                                           string kind = "RTL");
%000000     uvm_queue #(uvm_hdl_path_concat) paths = m_hdl_paths_pool.get(kind);
%000000     uvm_hdl_path_concat concat;
        
%000000     if (first || paths.size() == 0) begin
%000000       concat = new();
%000000       paths.push_back(concat);
            end
%000000     else begin
        
%000000       concat = paths.get(paths.size()-1);
            end
        
        
%000000    concat.add_path(name, offset, size);
        endfunction
        
        
        // has_hdl_path
        
%000000 function bit  uvm_reg::has_hdl_path(string kind = "");
%000000   if (kind == "") begin
%000000     if (m_regfile_parent != null) begin
        
%000000       kind = m_regfile_parent.get_default_hdl_path();
            end
        
%000000     else begin
        
%000000       kind = m_parent.get_default_hdl_path();
            end
        
          end
        
%000000   return m_hdl_paths_pool.exists(kind);
        endfunction
        
        
        // get_hdl_path_kinds
        
%000000 function void uvm_reg::get_hdl_path_kinds (ref string kinds[$]);
%000000   string kind;
%000000   kinds.delete();
%000000   if (!m_hdl_paths_pool.first(kind)) begin
        
%000000     return;
          end
        
%000000   do begin
        
%000000     kinds.push_back(kind);
          end
        
%000000   while (m_hdl_paths_pool.next(kind));
        endfunction
        
        
        // get_hdl_path
        
%000000 function void uvm_reg::get_hdl_path(ref uvm_hdl_path_concat paths[$],
                                                input string kind = "");
        
%000000   uvm_queue #(uvm_hdl_path_concat) hdl_paths;
        
%000000   if (kind == "") begin
%000000     if (m_regfile_parent != null) begin
        
%000000       kind = m_regfile_parent.get_default_hdl_path();
            end
        
%000000     else begin
        
%000000       kind = m_parent.get_default_hdl_path();
            end
        
          end
        
%000000   if (!has_hdl_path(kind)) begin
            `uvm_error("RegModel",
%000000     {"Register does not have hdl path defined for abstraction '",kind,"'"})
%000000     return;
          end
        
%000000   hdl_paths = m_hdl_paths_pool.get(kind);
        
%000000   for (int i=0; i<hdl_paths.size();i++) begin
%000000     paths.push_back(hdl_paths.get(i));
          end
        
        endfunction
        
        
        // get_full_hdl_path
        
%000000 function void uvm_reg::get_full_hdl_path(ref uvm_hdl_path_concat paths[$],
                                                 input string kind = "",
%000000                                          input string separator = ".");
        
%000000    if (kind == "") begin
%000000      if (m_regfile_parent != null) begin
        
%000000        kind = m_regfile_parent.get_default_hdl_path();
             end
        
%000000      else begin
        
%000000        kind = m_parent.get_default_hdl_path();
             end
        
           end
        
%000000    if (!has_hdl_path(kind)) begin
             `uvm_error("RegModel",
%000000      {"Register ",get_full_name()," does not have hdl path defined for abstraction '",kind,"'"})
%000000      return;
           end
        
%000000    begin
%000000      uvm_queue #(uvm_hdl_path_concat) hdl_paths = m_hdl_paths_pool.get(kind);
%000000      string parent_paths[$];
        
%000000      if (m_regfile_parent != null) begin
        
%000000        m_regfile_parent.get_full_hdl_path(parent_paths, kind, separator);
             end
        
%000000      else begin
        
%000000        m_parent.get_full_hdl_path(parent_paths, kind, separator);
             end
        
        
%000000      for (int i=0; i<hdl_paths.size();i++) begin
%000000        uvm_hdl_path_concat hdl_concat = hdl_paths.get(i);
        
%000000        foreach (parent_paths[j])  begin
%000000          uvm_hdl_path_concat t = new;
        
%000000          foreach (hdl_concat.slices[k]) begin
%000000            if (hdl_concat.slices[k].path == "") begin
        
%000000              t.add_path(parent_paths[j]);
                   end
        
%000000            else begin
        
%000000              t.add_path({ parent_paths[j], separator, hdl_concat.slices[k].path },
%000000                              hdl_concat.slices[k].offset,
%000000                              hdl_concat.slices[k].size);
                   end
        
                 end
%000000          paths.push_back(t);
               end
             end
           end
        endfunction
        
        
        // set_offset
        
%000000 function void uvm_reg::set_offset (uvm_reg_map    map,
                                           uvm_reg_addr_t offset,
                                           bit unmapped = 0);
        
%000000    uvm_reg_map orig_map = map;
        
%000000    if (m_maps.num() > 1 && map == null) begin
             `uvm_error("RegModel",{"set_offset requires a non-null map when register '",
%000000      get_full_name(),"' belongs to more than one map."})
%000000      return;
           end
        
%000000    map = get_local_map(map);
        
%000000    if (map == null) begin
        
%000000      return;
           end
        
        
%000000    map.m_set_reg_offset(this, offset, unmapped);
        endfunction
        
        
        // set_parent
        
%000000 function void uvm_reg::set_parent(uvm_reg_block blk_parent,
                                              uvm_reg_file regfile_parent);
          /* ToDo: remove register from previous parent
          if (m_parent != null) begin
          end
          */
%000000   m_parent = blk_parent;
%000000   m_regfile_parent = regfile_parent;
        endfunction
        
        
        // get_parent
        
%000000 function uvm_reg_block uvm_reg::get_parent();
%000000   return get_block();
        endfunction
        
        
        // get_regfile
        
%000000 function uvm_reg_file uvm_reg::get_regfile();
%000000    return m_regfile_parent;
        endfunction
        
        
        // get_full_name
        
%000000 function string uvm_reg::get_full_name();
        
%000000    if (m_regfile_parent != null) begin
        
%000000      return {m_regfile_parent.get_full_name(), ".", get_name()};
           end
        
        
%000000    if (m_parent != null) begin
        
%000000      return {m_parent.get_full_name(), ".", get_name()};
           end
        
        
%000000    return get_name();
        endfunction: get_full_name
        
        
        // add_map
        
%000000 function void uvm_reg::add_map(uvm_reg_map map);
%000000   m_maps[map] = 1;
        endfunction
        
        
        // get_maps
        
%000000 function void uvm_reg::get_maps(ref uvm_reg_map maps[$]);
%000000    foreach (m_maps[map]) begin
        
%000000      maps.push_back(map);
           end
        
        endfunction
        
        
        // get_n_maps
        
%000000 function int uvm_reg::get_n_maps();
%000000    return m_maps.num();
        endfunction
        
        
        // is_in_map
        
%000000 function bit uvm_reg::is_in_map(uvm_reg_map map);
%000000    if (m_maps.exists(map)) begin
        
%000000      return 1;
           end
        
%000000    foreach (m_maps[l]) begin
%000000      uvm_reg_map local_map = l;
%000000      uvm_reg_map parent_map = local_map.get_parent_map();
        
%000000      while (parent_map != null) begin
%000000        if (parent_map == map) begin
        
%000000          return 1;
               end
        
%000000        parent_map = parent_map.get_parent_map();
             end
           end
%000000    return 0;
        endfunction
        
        
        
        // get_local_map
        
%000000 function uvm_reg_map uvm_reg::get_local_map(uvm_reg_map map);
%000000    if (map == null) begin
        
%000000      return get_default_map();
           end
        
%000000    if (m_maps.exists(map)) begin
        
%000000      return map;
           end
        
%000000    foreach (m_maps[l]) begin
%000000      uvm_reg_map local_map=l;
%000000      uvm_reg_map parent_map = local_map.get_parent_map();
        
%000000      while (parent_map != null) begin
%000000        if (parent_map == map) begin
        
%000000          return local_map;
               end
        
%000000        parent_map = parent_map.get_parent_map();
             end
           end
           `uvm_warning("RegModel",
%000000        {"Register '",get_full_name(),"' is not contained within map '",map.get_full_name(),"'"})
%000000    return null;
        endfunction
        
        
        
        // get_default_map
        
%000000 function uvm_reg_map uvm_reg::get_default_map();
        
           // if reg is not associated with any map, return ~null~
%000000    if (m_maps.num() == 0) begin
             `uvm_warning("RegModel",
%000000      {"Register '",get_full_name(),"' is not registered with any map"})
%000000      return null;
           end
        
           // if only one map, choose that
%000000    if (m_maps.num() == 1) begin
%000000      uvm_reg_map map;
%000000      void'(m_maps.first(map));
%000000      return map;
           end
        
           // try to choose one based on default_map in parent blocks.
%000000    foreach (m_maps[l]) begin
%000000      uvm_reg_map map = l;
%000000      uvm_reg_block blk = map.get_parent();
%000000      uvm_reg_map default_map = blk.get_default_map();
%000000      if (default_map != null) begin
%000000        uvm_reg_map local_map = get_local_map(default_map);
%000000        if (local_map != null) begin
        
%000000          return local_map;
               end
        
             end
           end
        
           // if that fails, choose the first in this reg's maps
        
%000000    begin
%000000      uvm_reg_map map;
%000000      void'(m_maps.first(map));
%000000      return map;
           end
        
        endfunction
        
        
        // get_rights
        
%000000 function string uvm_reg::get_rights(uvm_reg_map map = null);
        
%000000    uvm_reg_map_info info;
        
%000000    map = get_local_map(map);
        
%000000    if (map == null) begin
        
%000000      return "RW";
           end
        
        
%000000    info = map.get_reg_map_info(this);
%000000    return info.rights;
        
        endfunction
        
        
        
        // get_block
        
%000000 function uvm_reg_block uvm_reg::get_block();
%000000    get_block = m_parent;
        endfunction
        
        
        // get_offset
        
%000000 function uvm_reg_addr_t uvm_reg::get_offset(uvm_reg_map map = null);
        
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_map orig_map = map;
        
%000000    map = get_local_map(map);
        
%000000    if (map == null) begin
        
%000000      return -1;
           end
        
        
%000000    map_info = map.get_reg_map_info(this);
        
%000000    if (map_info.unmapped) begin
             `uvm_warning("RegModel", {"Register '",get_name(),
             "' is unmapped in map '",
%000000      ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
%000000      return -1;
           end
        
%000000    return map_info.offset;
        
        endfunction
        
        
        // get_addresses
        
%000000 function int uvm_reg::get_addresses(uvm_reg_map map=null, ref uvm_reg_addr_t addr[]);
        
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_map orig_map = map;
        
%000000    map = get_local_map(map);
        
%000000    if (map == null) begin
        
%000000      return -1;
           end
        
        
%000000    map_info = map.get_reg_map_info(this);
        
%000000    if (map_info.unmapped) begin
             `uvm_warning("RegModel", {"Register '",get_name(),
             "' is unmapped in map '",
%000000      ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
%000000      return -1;
           end
        
%000000    addr = map_info.addr;
%000000    return map.get_n_bytes();
        
        endfunction
        
        
        // get_address
        
%000000 function uvm_reg_addr_t uvm_reg::get_address(uvm_reg_map map = null);
%000000    uvm_reg_addr_t  addr[];
%000000    void'(get_addresses(map,addr));
%000000    return addr[0];
        endfunction
        
        
        // get_n_bits
        
%000000 function int unsigned uvm_reg::get_n_bits();
%000000    return m_n_bits;
        endfunction
        
        
        // get_n_bytes
        
%000000 function int unsigned uvm_reg::get_n_bytes();
%000000    return ((m_n_bits-1) / 8) + 1;
        endfunction
        
        
        // get_max_size
        
%000000 function int unsigned uvm_reg::get_max_size();
%000000    return m_max_size;
        endfunction: get_max_size
        
        
        // get_fields
        
%000000 function void uvm_reg::get_fields(ref uvm_reg_field fields[$]);
%000000    foreach(m_fields[i]) begin
        
%000000      fields.push_back(m_fields[i]);
           end
        
        endfunction
        
        
        // get_field_by_name
        
%000000 function uvm_reg_field uvm_reg::get_field_by_name(string name);
%000000    get_field_by_name = uvm_reg_field::get_field_by_full_name({this.get_full_name(),".",name});
%000000    if(get_field_by_name!=null) begin
        
%000000      return get_field_by_name;
           end
        
        
           `uvm_warning("RegModel", {"Unable to locate field '",name,
%000000                             "' in register '",get_name(),"'"})
%000000    return null;
        endfunction
        
        
        // Xget_field_accessX
        //
        // Returns "WO" if all of the fields in the registers are write-only
        // Returns "RO" if all of the fields in the registers are read-only
        // Returns "RW" otherwise.
        
%000000 function string uvm_reg::Xget_fields_accessX(uvm_reg_map map);
%000000    bit is_R;
%000000    bit is_W;
        
%000000    foreach(m_fields[i]) begin
%000000      case (m_fields[i].get_access(map))
               "RO",
               "RC",
%000000        "RS": begin
        
%000000          is_R = 1;
               end
        
        
               "WO",
               "WOC",
               "WOS",
%000000        "WO1": begin
        
%000000          is_W = 1;
               end
        
        
%000000        default: begin
        
%000000          return "RW";
               end
        
             endcase
        
%000000      if (is_R && is_W) begin
%000000        return "RW";
             end
        
           end
        
%000000    case ({is_R, is_W})
%000000      2'b01: begin
%000000        return "WO";
             end
        
%000000      2'b10: begin
%000000        return "RO";
             end
        
           endcase
%000000    return "RW";
        endfunction
        
        
        //---------
        // COVERAGE
        //---------
        
        
        // include_coverage
        
%000000 function void uvm_reg::include_coverage(string scope,
                                                uvm_reg_cvr_t models,
                                                uvm_object accessor = null);
%000000    uvm_reg_cvr_rsrc_db::set({"uvm_reg::", scope},
%000000                             "include_coverage",
%000000                             models, accessor);
        endfunction
        
        
        // build_coverage
        
%000000 function uvm_reg_cvr_t uvm_reg::build_coverage(uvm_reg_cvr_t models);
%000000    build_coverage = UVM_NO_COVERAGE;
%000000    void'(uvm_reg_cvr_rsrc_db::read_by_name({"uvm_reg::", get_full_name()},
%000000                                            "include_coverage",
%000000                                            build_coverage, this));
%000000    return build_coverage & models;
        endfunction: build_coverage
        
        
        // add_coverage
        
%000000 function void uvm_reg::add_coverage(uvm_reg_cvr_t models);
%000000    m_has_cover |= models;
        endfunction: add_coverage
        
        
        // has_coverage
        
%000000 function bit uvm_reg::has_coverage(uvm_reg_cvr_t models);
%000000    return ((m_has_cover & models) == models);
        endfunction: has_coverage
        
        
        // set_coverage
        
%000000 function uvm_reg_cvr_t uvm_reg::set_coverage(uvm_reg_cvr_t is_on);
%000000    if (is_on == uvm_reg_cvr_t'(UVM_NO_COVERAGE)) begin
%000000      m_cover_on = is_on;
%000000      return m_cover_on;
           end
        
%000000    m_cover_on = m_has_cover & is_on;
        
%000000    return m_cover_on;
        endfunction: set_coverage
        
        
        // get_coverage
        
%000000 function bit uvm_reg::get_coverage(uvm_reg_cvr_t is_on);
%000000    if (has_coverage(is_on) == 0) begin
        
%000000      return 0;
           end
        
%000000    return ((m_cover_on & is_on) == is_on);
        endfunction: get_coverage
        
        
        
        //---------
        // ACCESS
        //---------
        
        
        // set
        
%000000 function void uvm_reg::set(uvm_reg_data_t  value,
%000000                            string          fname = "",
%000000                            int             lineno = 0);
           // Split the value into the individual fields
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
%000000    foreach (m_fields[i]) begin
        
%000000      m_fields[i].set((value >> m_fields[i].get_lsb_pos()) &
                               ((1 << m_fields[i].get_n_bits()) - 1));
           end
        
        endfunction: set
        
        
        // predict
        
%000000 function bit uvm_reg::predict (uvm_reg_data_t    value,
                                       uvm_reg_byte_en_t be = -1,
                                       uvm_predict_e     kind = UVM_PREDICT_DIRECT,
                                       uvm_door_e        path = UVM_FRONTDOOR,
                                       uvm_reg_map       map = null,
                                       string            fname = "",
                                       int               lineno = 0);
%000000   uvm_reg_item rw = new;
%000000   rw.set_value(value,0);
%000000   rw.set_door(path);
%000000   rw.set_map(map);
%000000   rw.set_fname(fname);
%000000   rw.set_line(lineno);
%000000   do_predict(rw, kind, be);
%000000   predict = (rw.get_status() == UVM_NOT_OK) ? 0 : 1;
        endfunction: predict
        
        
        // do_predict
        
%000000 function void uvm_reg::do_predict(uvm_reg_item      rw,
                                          uvm_predict_e     kind = UVM_PREDICT_DIRECT,
%000000                                   uvm_reg_byte_en_t be = -1);
        
%000000    uvm_reg_data_t reg_value = rw.get_value(0);
%000000    m_fname = rw.get_fname();
%000000    m_lineno = rw.get_line();
        
%000000    if (rw.get_status() == UVM_IS_OK ) begin
        
%000000      if (m_is_busy && kind == UVM_PREDICT_DIRECT) begin
               `uvm_warning("RegModel", {"Trying to predict value of register '",
%000000        get_full_name(),"' while it is being accessed"})
%000000        rw.set_status(UVM_NOT_OK);
%000000        return;
             end
        
%000000      foreach (m_fields[i]) begin
%000000        rw.set_value((reg_value >> m_fields[i].get_lsb_pos()) &
                                           ((1 << m_fields[i].get_n_bits())-1));
%000000        m_fields[i].do_predict(rw, kind, be>>(m_fields[i].get_lsb_pos()/8));
             end
        
%000000      rw.set_value(reg_value, 0);
           end
%000000    else begin
%000000      `uvm_warning("PREDICT_NOK", "status UVM_NOT_OK; skip prediction.");
           end
        endfunction: do_predict
        
        
        // get
        
%000000 function uvm_reg_data_t  uvm_reg::get(string  fname = "",
%000000                                       int     lineno = 0);
           // Concatenate the value of the individual fields
           // to form the register value
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
%000000    get = 0;
        
%000000    foreach (m_fields[i]) begin
        
%000000      get |= m_fields[i].get() << m_fields[i].get_lsb_pos();
           end
        
        endfunction: get
        
        
        // get_mirrored_value
        
%000000 function uvm_reg_data_t  uvm_reg::get_mirrored_value(string  fname = "",
%000000                                       int     lineno = 0);
           // Concatenate the value of the individual fields
           // to form the register value
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
%000000    get_mirrored_value = 0;
        
%000000    foreach (m_fields[i]) begin
        
%000000      get_mirrored_value |= m_fields[i].get_mirrored_value() << m_fields[i].get_lsb_pos();
           end
        
        endfunction: get_mirrored_value
        
        
        // reset
        
%000000 function void uvm_reg::reset(string kind = "HARD");
%000000    foreach (m_fields[i]) begin
        
%000000      m_fields[i].reset(kind);
           end
        
           // Put back a key in the semaphore if it is checked out
           // in case a thread was killed during an operation
%000000    void'(m_atomic.try_get(1));
%000000    m_atomic.put(1);
%000000    m_process = null;
%000000    Xset_busyX(0);
        endfunction: reset
        
        
        // get_reset
        
%000000 function uvm_reg_data_t uvm_reg::get_reset(string kind = "HARD");
           // Concatenate the value of the individual fields
           // to form the register value
%000000    get_reset = 0;
        
%000000    foreach (m_fields[i]) begin
        
%000000      get_reset |= m_fields[i].get_reset(kind) << m_fields[i].get_lsb_pos();
           end
        
        endfunction: get_reset
        
        
        // has_reset
        
%000000 function bit uvm_reg::has_reset(string kind = "HARD",
                                        bit    delete = 0);
        
%000000    has_reset = 0;
%000000    foreach (m_fields[i]) begin
%000000      has_reset |= m_fields[i].has_reset(kind, delete);
%000000      if (!delete && has_reset) begin
        
%000000        return 1;
             end
        
           end
        endfunction: has_reset
        
        
        // set_reset
        
%000000 function void uvm_reg::set_reset(uvm_reg_data_t value,
                                         string         kind = "HARD");
%000000    foreach (m_fields[i]) begin
%000000      m_fields[i].set_reset(value >> m_fields[i].get_lsb_pos(), kind);
           end
        endfunction: set_reset
        
        
        //-----------
        // BUS ACCESS
        //-----------
        
        // needs_update
        
%000000 function bit uvm_reg::needs_update();
%000000    needs_update = 0;
%000000    foreach (m_fields[i]) begin
%000000      if (m_fields[i].needs_update()) begin
%000000        return 1;
             end
           end
        endfunction: needs_update
        
        
        // update
        
%000000 task uvm_reg::update(output uvm_status_e      status,
                             input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                             input  uvm_reg_map       map = null,
                             input  uvm_sequence_base parent = null,
                             input  int               prior = -1,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);
%000000    uvm_reg_data_t upd;
        
%000000    status = UVM_IS_OK;
        
%000000    if (!needs_update()) begin
%000000      return;
           end
        
        
           // Concatenate the write-to-update values from each field
           // Fields are stored in LSB or MSB order
%000000    upd = 0;
%000000    foreach (m_fields[i]) begin
        
%000000      upd |= m_fields[i].XupdateX() << m_fields[i].get_lsb_pos();
           end
        
        
%000000    write(status, upd, path, map, parent, prior, extension, fname, lineno);
        endtask: update
        
        
        
        // write
        
%000000 task uvm_reg::write(output uvm_status_e      status,
                            input  uvm_reg_data_t    value,
                            input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                            input  uvm_reg_map       map = null,
                            input  uvm_sequence_base parent = null,
                            input  int               prior = -1,
                            input  uvm_object        extension = null,
                            input  string            fname = "",
                            input  int               lineno = 0);
        
           // create an abstract transaction for this operation
%000000    uvm_reg_item rw;
        
%000000    XatomicX(1);
        
%000000    set(value);
        
%000000    rw = uvm_reg_item::type_id::create("write_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
%000000    rw.set_kind(UVM_WRITE);
%000000    rw.set_value(value, 0);
%000000    rw.set_door(path);
%000000    rw.set_map(map);
%000000    rw.set_parent_sequence(parent);
%000000    rw.set_priority(prior);
%000000    rw.set_extension(extension);
%000000    rw.set_fname(fname);
%000000    rw.set_line(lineno);
        
%000000    do_write(rw);
        
%000000    status = rw.get_status();
        
%000000    XatomicX(0);
        
        endtask
        
        
        // do_write
        
%000000 task uvm_reg::do_write (uvm_reg_item rw);
        
%000000    uvm_reg_cb_iter  cbs = new(this);
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_data_t   value;
%000000    uvm_reg_map      tmp_local_map;
        
%000000    m_fname  = rw.get_fname();
%000000    m_lineno = rw.get_line();
        
%000000    if (!Xcheck_accessX(rw,map_info)) begin
        
%000000      return;
           end
        
        
%000000    XatomicX(1);
        
%000000    m_write_in_progress = 1'b1;
        
%000000    value = rw.get_value(0);
%000000    value &= ((1 << m_n_bits)-1);
%000000    rw.set_value(value, 0);
        
%000000    rw.set_status(UVM_IS_OK);
        
           // PRE-WRITE CBS - FIELDS
%000000    begin : pre_write_callbacks
%000000      uvm_reg_data_t  msk;
%000000      int lsb;
        
%000000      foreach (m_fields[i]) begin
%000000        uvm_reg_field_cb_iter cbs = new(m_fields[i]);
%000000        uvm_reg_field f = m_fields[i];
%000000        lsb = f.get_lsb_pos();
%000000        msk = ((1<<f.get_n_bits())-1) << lsb;
%000000        rw.set_value(((value & msk) >> lsb), 0);
%000000        f.pre_write(rw);
%000000        for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
%000000          rw.set_element(f);
%000000          rw.set_element_kind(UVM_FIELD);
%000000          cb.pre_write(rw);
               end
        
%000000        value = (value & ~msk) | (rw.get_value(0) << lsb);
             end
           end
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
%000000    rw.set_value(value,0);
        
           // PRE-WRITE CBS - REG
%000000    pre_write(rw);
%000000    for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000      cb.pre_write(rw);
           end
        
        
%000000    if (rw.get_status() != UVM_IS_OK) begin
%000000      m_write_in_progress = 1'b0;
        
%000000      XatomicX(0);
        
%000000      return;
           end
        
           // EXECUTE WRITE...
%000000    case (rw.get_door())
        
              // ...VIA USER BACKDOOR
%000000       UVM_BACKDOOR: begin
%000000          uvm_reg_data_t final_val = 0;
%000000          uvm_reg_backdoor bkdr = get_backdoor();
        
%000000        if (rw.get_map() != null) begin
        
%000000          rw.set_local_map(rw.get_map());
               end
        
%000000        else begin
        
%000000          rw.set_local_map(get_default_map());
               end
        
        
%000000        value = rw.get_value(0);
        
               // Mimick the final value after a physical read
%000000        rw.set_kind(UVM_READ);
%000000        if (bkdr != null) begin
        
%000000          bkdr.read(rw);
               end
        
%000000        else begin
        
%000000          backdoor_read(rw);
               end
        
        
%000000        if (rw.get_status() == UVM_NOT_OK) begin
%000000          m_write_in_progress = 1'b0;
%000000          XatomicX(0);
%000000          return;
               end
        
%000000        begin
%000000          foreach (m_fields[i]) begin
%000000            uvm_reg_data_t field_val;
%000000            int lsb = m_fields[i].get_lsb_pos();
%000000            int sz  = m_fields[i].get_n_bits();
%000000            field_val = m_fields[i].XpredictX((rw.get_value(0) >> lsb) & ((1<<sz)-1),
%000000                                                  (value >> lsb) & ((1<<sz)-1),
%000000                                                  rw.get_local_map());
%000000            final_val |= field_val << lsb;
                 end
               end
%000000        rw.set_kind(UVM_WRITE);
%000000        rw.set_value(final_val, 0);
        
%000000        if (get_rights(rw.get_local_map()) inside {"RW", "WO"}) begin
%000000          if (bkdr != null) begin
        
%000000            bkdr.write(rw);
                 end
        
%000000          else begin
        
%000000            backdoor_write(rw);
                 end
        
        
%000000          do_predict(rw, UVM_PREDICT_WRITE);
               end
%000000        else begin
%000000          rw.set_status(UVM_NOT_OK);
               end
        
        
             end
        
%000000      UVM_FRONTDOOR: begin
        
%000000        uvm_reg_map system_map;
%000000        tmp_local_map = rw.get_local_map();
%000000        system_map = tmp_local_map.get_root_map();
        
%000000        m_is_busy = 1;
        
               // ...VIA USER FRONTDOOR
%000000        if (map_info.frontdoor != null) begin
%000000          uvm_reg_frontdoor fd = map_info.frontdoor;
                 // Lock for atomic access
%000000          fd.atomic_lock();
%000000          fd.rw_info = rw;
%000000          if (fd.sequencer == null) begin
        
%000000            fd.sequencer = system_map.get_sequencer();
                 end
        
%000000          fd.start(fd.sequencer, rw.get_parent_sequence());
                 // Unlock to allow other processes to proceed
%000000          fd.atomic_unlock();
               end
        
               // ...VIA BUILT-IN FRONTDOOR
%000000        else begin : built_in_frontdoor
        
%000000          tmp_local_map.do_write(rw);
        
               end
        
%000000        m_is_busy = 0;
        
%000000        if (system_map.get_auto_predict()) begin
%000000          uvm_status_e status;
%000000          if (rw.get_status() != UVM_NOT_OK) begin
%000000            sample(value, -1, 0, rw.get_map());
%000000            m_parent.XsampleX(map_info.offset, 0, rw.get_map());
                 end
        
%000000          status = rw.get_status(); // do_predict will override rw.status, so we save it here
%000000          do_predict(rw, UVM_PREDICT_WRITE);
%000000          rw.set_status(status);
               end
             end
        
           endcase
        
%000000    value = rw.get_value(0);
        
           // POST-WRITE CBS - REG
%000000    for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000      cb.post_write(rw);
           end
        
%000000    post_write(rw);
        
           // POST-WRITE CBS - FIELDS
%000000    foreach (m_fields[i]) begin
%000000      uvm_reg_field_cb_iter cbs = new(m_fields[i]);
%000000      uvm_reg_field f = m_fields[i];
        
%000000      rw.set_element(f);
%000000      rw.set_element_kind(UVM_FIELD);
%000000      rw.set_value((value >> f.get_lsb_pos()) & ((1<<f.get_n_bits())-1), 0);
        
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.post_write(rw);
             end
        
%000000      f.post_write(rw);
           end
        
%000000    rw.set_value(value, 0);
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
        
           // REPORT
%000000    if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "RegModel")) begin
%000000      string path_s,value_s;
%000000      uvm_reg_map tmp_map;
%000000      if (rw.get_door() == UVM_FRONTDOOR) begin
%000000        tmp_map = rw.get_map();
%000000        path_s = (map_info.frontdoor != null) ? "user frontdoor" :
                                                       {"map ",tmp_map.get_full_name()};
             end
%000000      else begin
        
%000000        path_s = (get_backdoor() != null) ? "user backdoor" : "DPI backdoor";
             end
        
        
%000000      value_s = $sformatf("=0x%0h",rw.get_value(0));
        
%000000      uvm_report_info("RegModel", {"Wrote register via ",path_s,": ",
%000000                                    get_full_name(),value_s}, UVM_HIGH);
           end
        
%000000    m_write_in_progress = 1'b0;
        
%000000    XatomicX(0);
        
        endtask: do_write
        
        // read
        
%000000 task uvm_reg::read(output uvm_status_e      status,
%000000                    output uvm_reg_data_t    value,
                           input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                           input  uvm_reg_map       map = null,
                           input  uvm_sequence_base parent = null,
                           input  int               prior = -1,
                           input  uvm_object        extension = null,
                           input  string            fname = "",
                           input  int               lineno = 0);
%000000    XatomicX(1);
%000000    XreadX(status, value, path, map, parent, prior, extension, fname, lineno);
%000000    XatomicX(0);
        endtask: read
        
        
        // XreadX
        
%000000 task uvm_reg::XreadX(output uvm_status_e      status,
%000000                      output uvm_reg_data_t    value,
                             input  uvm_door_e        path,
                             input  uvm_reg_map       map,
                             input  uvm_sequence_base parent = null,
                             input  int               prior = -1,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);
        
           // create an abstract transaction for this operation
%000000    uvm_reg_item rw;
%000000    rw = uvm_reg_item::type_id::create("read_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
%000000    rw.set_kind(UVM_READ);
%000000    rw.set_value(0,0);
%000000    rw.set_door(path);
%000000    rw.set_map(map);
%000000    rw.set_parent_sequence(parent);
%000000    rw.set_priority(prior);
%000000    rw.set_extension(extension);
%000000    rw.set_fname(fname);
%000000    rw.set_line(lineno);
        
%000000    do_read(rw);
        
%000000    status = rw.get_status();
%000000    value = rw.get_value(0);
        
        endtask: XreadX
        
        
        // do_read
        
%000000 task uvm_reg::do_read(uvm_reg_item rw);
        
%000000    uvm_reg_cb_iter  cbs = new(this);
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_data_t   value;
%000000    uvm_reg_data_t   value_field_filter;
%000000    uvm_reg_data_t   exp;
        
%000000    m_fname   = rw.get_fname();
%000000    m_lineno  = rw.get_line();
        
%000000    if (!Xcheck_accessX(rw,map_info)) begin
        
%000000      return;
           end
        
        
%000000    m_read_in_progress = 1'b1;
        
%000000    rw.set_status(UVM_IS_OK);
        
           // PRE-READ CBS - FIELDS
%000000    foreach (m_fields[i]) begin
%000000      uvm_reg_field_cb_iter cbs = new(m_fields[i]);
%000000      uvm_reg_field f = m_fields[i];
%000000      rw.set_element(f);
%000000      rw.set_element_kind(UVM_FIELD);
%000000      m_fields[i].pre_read(rw);
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.pre_read(rw);
             end
        
           end
        
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
        
           // PRE-READ CBS - REG
%000000    pre_read(rw);
%000000    for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000      cb.pre_read(rw);
           end
        
        
%000000    if (rw.get_status() != UVM_IS_OK) begin
%000000      m_read_in_progress = 1'b0;
        
%000000      return;
           end
        
           // EXECUTE READ...
%000000    case (rw.get_door())
        
             // ...VIA USER BACKDOOR
%000000      UVM_BACKDOOR: begin
%000000        uvm_reg_backdoor bkdr = get_backdoor();
        
%000000        uvm_reg_map map;  // = uvm_reg_map::backdoor();
%000000        if (rw.get_map() != null) begin
        
%000000          rw.set_local_map(rw.get_map());
               end
        
%000000        else begin
        
%000000          rw.set_local_map(get_default_map());
               end
        
        
%000000        map = rw.get_local_map();
        
%000000        if (map.get_check_on_read()) begin
%000000          exp = get_mirrored_value();
               end
        
        
%000000        if (get_rights(rw.get_local_map()) inside {"RW", "RO"}) begin
%000000          if (bkdr != null) begin
        
%000000            bkdr.read(rw);
                 end
        
%000000          else begin
        
%000000            backdoor_read(rw);
                 end
        
               end
%000000        else begin
%000000          rw.set_status(UVM_NOT_OK);
               end
        
%000000        value = rw.get_value(0);
        
               // Need to clear RC fields, set RS fields and mask WO fields
%000000        if (rw.get_status() != UVM_NOT_OK) begin
        
%000000          uvm_reg_data_t wo_mask=0;
        
%000000          foreach (m_fields[i]) begin
                   // string acc = m_fields[i].get_access(uvm_reg_map::backdoor());
%000000            string acc = m_fields[i].get_access(rw.get_local_map());
%000000            if (acc == "RC" ||
                   acc == "WRC" ||
                   acc == "WSRC" ||
%000000            acc == "W1SRC" ||
%000000            acc == "W0SRC") begin
%000000              value &= ~(((1<<m_fields[i].get_n_bits())-1)
                                                  << m_fields[i].get_lsb_pos());
                   end
%000000            else if (acc == "RS" ||
                   acc == "WRS" ||
                   acc == "WCRS" ||
%000000            acc == "W1CRS" ||
%000000            acc == "W0CRS") begin
%000000              value |= (((1<<m_fields[i].get_n_bits())-1)
                                                  << m_fields[i].get_lsb_pos());
                   end
%000000            else if (acc == "WO" ||
                   acc == "WOC" ||
%000000            acc == "WOS" ||
%000000            acc == "WO1") begin
%000000              wo_mask |= ((1<<m_fields[i].get_n_bits())-1)
                                                  << m_fields[i].get_lsb_pos();
                   end
                 end
        
%000000          if (get_rights(rw.get_local_map()) inside {"RW", "RO"}) begin
%000000            uvm_reg_data_t saved;
%000000            if (value !== rw.get_value(0)) begin
        
%000000              saved = rw.get_value(0);
%000000              rw.set_value(value, 0);
%000000              if (bkdr != null) begin
        
%000000                bkdr.write(rw);
                     end
        
%000000              else begin
        
%000000                backdoor_write(rw);
                     end
        
%000000              rw.set_value(saved, 0);
                   end
        
%000000            saved = rw.get_value(0);
%000000            saved &= ~wo_mask;
%000000            rw.set_value(saved, 0);
        
%000000            if (map.get_check_on_read() &&
%000000            rw.get_status() != UVM_NOT_OK) begin
%000000              void'(do_check(exp, rw.get_value(0), map));
                   end
        
%000000            do_predict(rw, UVM_PREDICT_READ);
                 end
%000000          else begin
%000000            rw.set_status(UVM_NOT_OK);
                 end
        
               end
             end
        
        
%000000      UVM_FRONTDOOR: begin
%000000        uvm_reg_map local_map = rw.get_local_map();
%000000        uvm_reg_map system_map = local_map.get_root_map();
        
%000000        m_is_busy = 1;
        
%000000        if (local_map.get_check_on_read()) begin
%000000          exp = get_mirrored_value();
               end
        
        
               // ...VIA USER FRONTDOOR
%000000        if (map_info.frontdoor != null) begin
%000000          uvm_reg_frontdoor fd = map_info.frontdoor;
                 // Lock for atomic access
%000000          fd.atomic_lock();
%000000          fd.rw_info = rw;
%000000          if (fd.sequencer == null) begin
        
%000000            fd.sequencer = system_map.get_sequencer();
                 end
        
%000000          fd.start(fd.sequencer, rw.get_parent_sequence());
                 // Unlock to allow other processes to proceed
%000000          fd.atomic_unlock();
               end
        
               // ...VIA BUILT-IN FRONTDOOR
%000000        else begin
%000000          local_map.do_read(rw);
               end
        
%000000        m_is_busy = 0;
        
%000000        if (system_map.get_auto_predict()) begin
%000000          uvm_status_e status;
%000000          if (local_map.get_check_on_read() &&
%000000          rw.get_status() != UVM_NOT_OK) begin
%000000            void'(do_check(exp, rw.get_value(0), system_map));
                 end
        
%000000          if (rw.get_status() != UVM_NOT_OK) begin
%000000            sample(rw.get_value(0), -1, 1, rw.get_map());
%000000            m_parent.XsampleX(map_info.offset, 1, rw.get_map());
                 end
        
%000000          status = rw.get_status(); // do_predict will override rw.status, so we save it here
%000000          do_predict(rw, UVM_PREDICT_READ);
%000000          rw.set_status(status);
               end
             end
        
           endcase
        
           // POST-READ CBS - REG
%000000    for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next()) begin
        
%000000      cb.post_read(rw);
           end
        
%000000    post_read(rw);
        
%000000    value = rw.get_value(0);
        
           // POST-READ CBS - FIELDS
%000000    foreach (m_fields[i]) begin
%000000      int top;
%000000      uvm_reg_field_cb_iter cbs = new(m_fields[i]);
%000000      uvm_reg_field f = m_fields[i];
%000000      rw.set_element(f);
%000000      rw.set_element_kind(UVM_FIELD);
%000000      rw.set_value((value >> f.get_lsb_pos()) & ((1<<f.get_n_bits())-1));
%000000      top = (f.get_n_bits()+f.get_lsb_pos());
        
             // Filter to remove field from value before ORing result of field CB/post_read back in
%000000      value_field_filter = '1;
%000000      for(int i = f.get_lsb_pos(); i < top; i++) begin
%000000        value_field_filter[i] = 0;
             end
        
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.post_read(rw);
             end
        
%000000      f.post_read(rw);
        
             // Recreate value based on field value and field filtered version of value
%000000      value = (value & value_field_filter) | (~value_field_filter & (rw.get_value(0) << f.get_lsb_pos()));
        
           end
        
%000000    rw.set_value(value,0);
        
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_REG);
        
           // REPORT
%000000    if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "RegModel")) begin
%000000      string path_s,value_s;
%000000      if (rw.get_door() == UVM_FRONTDOOR) begin
%000000        uvm_reg_map map = rw.get_map();
%000000        path_s = (map_info.frontdoor != null) ? "user frontdoor" :
                                                       {"map ",map.get_full_name()};
             end
%000000      else begin
        
%000000        path_s = (get_backdoor() != null) ? "user backdoor" : "DPI backdoor";
             end
        
        
%000000      value_s = $sformatf("=0x%0h",rw.get_value(0));
        
%000000      uvm_report_info("RegModel", {"Read  register via ",path_s,": ",
%000000                                    get_full_name(),value_s}, UVM_HIGH);
           end
        
%000000    m_read_in_progress = 1'b0;
        
        endtask: do_read
        
        
        // Xcheck_accessX
        
%000000 function bit uvm_reg::Xcheck_accessX (input uvm_reg_item rw,
%000000                                       output uvm_reg_map_info map_info);
%000000    uvm_reg_map tmp_map;
%000000    uvm_reg_map tmp_local_map;
        
%000000    if (rw.get_door() == UVM_DEFAULT_DOOR) begin
        
%000000      rw.set_door(m_parent.get_default_door());
           end
        
        
%000000    if (rw.get_door() == UVM_BACKDOOR) begin
%000000      if (get_backdoor() == null && !has_hdl_path()) begin
               `uvm_warning("RegModel",
               {"No backdoor access available for register '",get_full_name(),
%000000        "' . Using frontdoor instead."})
%000000        rw.set_door(UVM_FRONTDOOR);
             end
%000000      else if (rw.get_map() == null) begin
%000000        uvm_reg_map  bkdr_map = get_default_map();
%000000        if (bkdr_map != null) begin
        
%000000          rw.set_map(bkdr_map);
               end
        
%000000        else begin
        
%000000          rw.set_map(uvm_reg_map::backdoor());
               end
        
             end
        
           end
        
        
%000000    if (rw.get_door() != UVM_BACKDOOR) begin
%000000      tmp_map = rw.get_map();
%000000      rw.set_local_map(get_local_map(tmp_map));
        
%000000      if (rw.get_local_map() == null) begin
        
%000000        if (tmp_map == null) begin
%000000          `uvm_error(get_type_name(), "Unable to physically access register with null map")
               end
%000000        else begin
                 `uvm_error(get_type_name(),
                 {"No transactor available to physically access register on map '",
%000000          tmp_map.get_full_name(),"'"})
               end
%000000        rw.set_status(UVM_NOT_OK);
%000000        return 0;
             end
        
%000000      tmp_local_map = rw.get_local_map();
%000000      map_info = tmp_local_map.get_reg_map_info(this);
        
%000000      if (map_info.frontdoor == null && map_info.unmapped) begin
               `uvm_error("RegModel", {"Register '",get_full_name(),
               "' unmapped in map '",
               (rw.get_map()==null)? tmp_local_map.get_full_name():tmp_map.get_full_name(),
%000000        "' and does not have a user-defined frontdoor"})
%000000        rw.set_status(UVM_NOT_OK);
%000000        return 0;
             end
        
%000000      if (tmp_map == null) begin
        
%000000        rw.set_map(tmp_local_map);
             end
        
           end
%000000    return 1;
        endfunction
        
        
        // is_busy
        
%000000 function bit uvm_reg::is_busy();
%000000    return m_is_busy;
        endfunction
        
        
        // Xset_busyX
        
%000000 function void uvm_reg::Xset_busyX(bit busy);
%000000    m_is_busy = busy;
        endfunction
        
        
        // Xis_loacked_by_fieldX
        
%000000 function bit uvm_reg::Xis_locked_by_fieldX();
%000000   return m_is_locked_by_field;
        endfunction
        
        
        // backdoor_write
        
%000000 task  uvm_reg::backdoor_write(uvm_reg_item rw);
%000000   uvm_hdl_path_concat paths[$];
%000000   bit ok=1;
%000000   get_full_hdl_path(paths,rw.get_bd_kind());
%000000   foreach (paths[i]) begin
%000000     uvm_hdl_path_concat hdl_concat = paths[i];
%000000     foreach (hdl_concat.slices[j]) begin
              `uvm_info("RegMem", $sformatf("backdoor_write to %s",
%000000       hdl_concat.slices[j].path),UVM_DEBUG)
        
%000000       if (hdl_concat.slices[j].offset < 0) begin
%000000         ok &= uvm_hdl_deposit(hdl_concat.slices[j].path,rw.get_value(0));
%000000         continue;
              end
%000000       begin
%000000         uvm_reg_data_t slice;
%000000         slice = rw.get_value(0) >> hdl_concat.slices[j].offset;
%000000         slice &= (1 << hdl_concat.slices[j].size)-1;
%000000         ok &= uvm_hdl_deposit(hdl_concat.slices[j].path, slice);
              end
            end
          end
%000000   rw.set_status(ok ? UVM_IS_OK : UVM_NOT_OK);
        endtask
        
        
        // backdoor_read
        
%000000 task  uvm_reg::backdoor_read (uvm_reg_item rw);
%000000   rw.set_status(backdoor_read_func(rw));
        endtask
        
        
        // backdoor_read_func
        
%000000 function uvm_status_e uvm_reg::backdoor_read_func(uvm_reg_item rw);
%000000   uvm_hdl_path_concat paths[$];
%000000   uvm_reg_data_t val;
%000000   bit ok=1;
%000000   get_full_hdl_path(paths,rw.get_bd_kind());
%000000   foreach (paths[i]) begin
%000000     uvm_hdl_path_concat hdl_concat = paths[i];
%000000     val = 0;
%000000     foreach (hdl_concat.slices[j]) begin
              `uvm_info("RegMem", $sformatf("backdoor_read from %s ",
%000000       hdl_concat.slices[j].path),UVM_DEBUG)
        
%000000       if (hdl_concat.slices[j].offset < 0) begin
%000000         ok &= uvm_hdl_read(hdl_concat.slices[j].path,val);
%000000         continue;
              end
%000000       begin
%000000         uvm_reg_data_t slice;
%000000         int k = hdl_concat.slices[j].offset;
        
%000000         ok &= uvm_hdl_read(hdl_concat.slices[j].path, slice);
        
%000000         repeat (hdl_concat.slices[j].size) begin
%000000           val[k++] = slice[0];
%000000           slice >>= 1;
                end
              end
            end
        
%000000     val &= (1 << m_n_bits)-1;
        
%000000     if (i == 0) begin
        
%000000       rw.set_value(val, 0);
            end
        
        
%000000     if (val !== rw.get_value(0)) begin
              `uvm_error("RegModel", $sformatf("Backdoor read of register %s with multiple HDL copies: values are not the same: %0h at path '%s', and %0h at path '%s'. Returning first value.",
              get_full_name(),
              rw.get_value(0), uvm_hdl_concat2string(paths[0]),
%000000       val, uvm_hdl_concat2string(paths[i])))
%000000       return UVM_NOT_OK;
            end
            `uvm_info("RegMem",
%000000     $sformatf("returned backdoor value 0x%0x",rw.get_value(0)),UVM_DEBUG)
        
          end
        
%000000   rw.set_status((ok) ? UVM_IS_OK : UVM_NOT_OK);
%000000   return rw.get_status();
        endfunction
        
        
        // poke
        
%000000 task uvm_reg::poke(output uvm_status_e      status,
                           input  uvm_reg_data_t    value,
                           input  string            kind = "",
                           input  uvm_sequence_base parent = null,
                           input  uvm_object        extension = null,
                           input  string            fname = "",
                           input  int               lineno = 0);
        
%000000    uvm_reg_backdoor bkdr = get_backdoor();
%000000    uvm_reg_item rw;
        
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
        
%000000    if (bkdr == null && !has_hdl_path(kind)) begin
             `uvm_error("RegModel",
%000000      {"No backdoor access available to poke register '",get_full_name(),"'"})
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if (!m_is_locked_by_field) begin
        
%000000      XatomicX(1);
           end
        
        
           // create an abstract transaction for this operation
%000000    rw = uvm_reg_item::type_id::create("reg_poke_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_door(UVM_BACKDOOR);
%000000    rw.set_element_kind(UVM_REG);
%000000    rw.set_kind(UVM_WRITE);
%000000    rw.set_bd_kind(kind);
%000000    rw.set_value((value & ((1 << m_n_bits)-1)),0);
%000000    rw.set_parent_sequence(parent);
%000000    rw.set_extension(extension);
%000000    rw.set_fname(fname);
%000000    rw.set_line(lineno);
        
%000000    if (bkdr != null) begin
        
%000000      bkdr.write(rw);
           end
        
%000000    else begin
        
%000000      backdoor_write(rw);
           end
        
        
%000000    status = rw.get_status();
        
           `uvm_info("RegModel", $sformatf("Poked register \"%s\": 'h%h",
%000000                               get_full_name(), value),UVM_HIGH)
        
%000000    do_predict(rw, UVM_PREDICT_WRITE);
        
%000000    if (!m_is_locked_by_field) begin
        
%000000      XatomicX(0);
           end
        
        endtask: poke
        
        
        // peek
        
%000000 task uvm_reg::peek(output uvm_status_e      status,
%000000                    output uvm_reg_data_t    value,
                           input  string            kind = "",
                           input  uvm_sequence_base parent = null,
                           input  uvm_object        extension = null,
                           input  string            fname = "",
                           input  int               lineno = 0);
        
%000000    uvm_reg_backdoor bkdr = get_backdoor();
%000000    uvm_reg_item rw;
        
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
%000000    if (bkdr == null && !has_hdl_path(kind)) begin
             `uvm_error("RegModel",
             $sformatf("No backdoor access available to peek register \"%s\"",
%000000      get_full_name()))
%000000      status = UVM_NOT_OK;
%000000      return;
           end
        
%000000    if(!m_is_locked_by_field) begin
        
%000000      XatomicX(1);
           end
        
        
           // create an abstract transaction for this operation
%000000    rw = uvm_reg_item::type_id::create("mem_peek_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_door(UVM_BACKDOOR);
%000000    rw.set_element_kind(UVM_REG);
%000000    rw.set_kind(UVM_READ);
%000000    rw.set_bd_kind(kind);
%000000    rw.set_parent_sequence(parent);
%000000    rw.set_extension(extension);
%000000    rw.set_fname(fname);
%000000    rw.set_line(lineno);
        
%000000    if (bkdr != null) begin
        
%000000      bkdr.read(rw);
           end
        
%000000    else begin
        
%000000      backdoor_read(rw);
           end
        
        
%000000    status = rw.get_status();
%000000    value = rw.get_value(0);
        
           `uvm_info("RegModel", $sformatf("Peeked register \"%s\": 'h%h",
%000000                           get_full_name(), value),UVM_HIGH)
        
%000000    do_predict(rw, UVM_PREDICT_READ);
        
%000000    if (!m_is_locked_by_field) begin
        
%000000      XatomicX(0);
           end
        
        endtask: peek
        
        
        // do_check
%000000 function bit uvm_reg::do_check(input uvm_reg_data_t expected,
                                       input uvm_reg_data_t actual,
                                       uvm_reg_map          map);
        
%000000    uvm_reg_data_t  valid_bits_mask = 0; // elements 1 indicating bit we care about
        
%000000    foreach(m_fields[i]) begin
%000000      string acc = m_fields[i].get_access(map);
%000000      acc = acc.substr(0, 1);
%000000      if (!(m_fields[i].get_compare() == UVM_NO_CHECK ||acc == "WO")) begin
%000000        valid_bits_mask |= ((1 << m_fields[i].get_n_bits())-1)<< m_fields[i].get_lsb_pos();
             end
           end
        
%000000    if ((actual&valid_bits_mask) === (expected&valid_bits_mask)) begin
%000000      return 1;
           end
        
%000000    else begin
%000000      uvm_reg_err_service err_service ;
%000000      err_service = uvm_reg_err_service::get();
%000000      err_service.do_check_error(this, expected, actual, map, valid_bits_mask);
%000000      return 0;
           end
        endfunction
        
%000000 function void uvm_reg_err_service::do_check_error(
                                       uvm_reg              this_reg,
                                       uvm_reg_data_t       expected,
                                       uvm_reg_data_t       actual,
                                       uvm_reg_map          map,
                                       uvm_reg_data_t       valid_bits_mask);
        
%000000    uvm_reg_field fields[$] ;
           `uvm_error("RegModel", $sformatf("Register \"%s\" value read from DUT (0x%h) does not match mirrored value (0x%h) (valid bit mask = 0x%h)",
%000000                                     this_reg.get_full_name(), actual, expected,valid_bits_mask))
        
%000000    this_reg.get_fields(fields);
%000000    foreach(fields[i]) begin
%000000      string acc = fields[i].get_access(map);
%000000      acc = acc.substr(0, 1);
%000000      if (!(fields[i].get_compare() == UVM_NO_CHECK ||
%000000      acc == "WO")) begin
%000000        uvm_reg_data_t mask  = ((1 << fields[i].get_n_bits())-1);
%000000        uvm_reg_data_t val   = actual   >> fields[i].get_lsb_pos() & mask;
%000000        uvm_reg_data_t exp   = expected >> fields[i].get_lsb_pos() & mask;
        
%000000        if (val !== exp) begin
                 `uvm_info("RegModel",
                 $sformatf("Field %s (%s[%0d:%0d]) mismatch read=%0d'h%0h mirrored=%0d'h%0h ",
                 fields[i].get_name(),
                 this_reg.get_full_name(),
                 fields[i].get_lsb_pos() + fields[i].get_n_bits() - 1,
                 fields[i].get_lsb_pos(),
                 fields[i].get_n_bits(), val,
                 fields[i].get_n_bits(), exp),
%000000          UVM_NONE)
               end
             end
           end
        
        endfunction
        
        
        // mirror
        
%000000 task uvm_reg::mirror(output uvm_status_e       status,
                             input  uvm_check_e        check = UVM_NO_CHECK,
                             input  uvm_door_e         path = UVM_DEFAULT_DOOR,
                             input  uvm_reg_map        map = null,
                             input  uvm_sequence_base  parent = null,
                             input  int                prior = -1,
                             input  uvm_object         extension = null,
                             input  string             fname = "",
                             input  int                lineno = 0);
%000000    uvm_reg_data_t  v;
%000000    uvm_reg_data_t  exp;
%000000    uvm_reg_backdoor bkdr = get_backdoor();
        
%000000    XatomicX(1);
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
        
%000000    if (path == UVM_DEFAULT_DOOR) begin
        
%000000      path = m_parent.get_default_door();
           end
        
        
%000000    if (path == UVM_BACKDOOR && (bkdr != null || has_hdl_path())) begin
%000000      map = get_default_map();
%000000      if (map == null) begin
        
%000000        map = uvm_reg_map::backdoor();
             end
        
           end
%000000    else begin
        
%000000      map = get_local_map(map);
           end
        
        
%000000    if (map == null) begin
%000000      XatomicX(0);
%000000      return;
           end
        
           // Remember what we think the value is before it gets updated
%000000    if (check == UVM_CHECK) begin
        
%000000      exp = get_mirrored_value();
           end
        
        
%000000    XreadX(status, v, path, map, parent, prior, extension, fname, lineno);
        
%000000    if (status == UVM_NOT_OK) begin
%000000      XatomicX(0);
%000000      return;
           end
        
%000000    if (check == UVM_CHECK) begin
%000000      void'(do_check(exp, v, map));
           end
        
        
%000000    XatomicX(0);
        endtask: mirror
        
        
        // XatomicX
        
%000000 task uvm_reg::XatomicX(bit on);
%000000    process m_reg_process;
%000000    m_reg_process=process::self();
        
%000000    if (on) begin
%000000      if (m_reg_process == m_process) begin
%000000        m_atomic_cnt++;
%000000        return;
             end
%000000      else begin
%000000        if ((m_process != null) && (m_process.status() == process::KILLED)) begin
%000000          `uvm_error("UVM/REG/ZOMBIE", $sformatf("Register %s access permanently locked by killed process", get_full_name()));
               end
%000000        m_atomic.get(1);
%000000        m_process = m_reg_process;
             end
           end
%000000    else begin
%000000      if (m_atomic_cnt) begin
%000000        m_atomic_cnt--;
%000000        return;
             end
             // Maybe a key was put back in by a spurious call to reset()
%000000      void'(m_atomic.try_get(1));
%000000      m_atomic.put(1);
%000000      m_process = null;
           end
        endtask: XatomicX
        
        
        //-------------
        // STANDARD OPS
        //-------------
        
        // convert2string
        
%000000 function string uvm_reg::convert2string();
%000000    string res_str;
%000000    string t_str;
%000000    bit with_debug_info;
        
%000000    string prefix;
        
%000000    $sformat(convert2string, "Register %s -- %0d bytes, mirror value:'h%h",
%000000             get_full_name(), get_n_bytes(),get());
        
%000000    if (m_maps.num()==0) begin
        
%000000      convert2string = {convert2string, "  (unmapped)\n"};
           end
        
%000000    else begin
        
%000000      convert2string = {convert2string, "\n"};
           end
        
%000000    foreach (m_maps[map]) begin
%000000      uvm_reg_map parent_map = map;
%000000      int unsigned offset;
%000000      while (parent_map != null) begin
%000000        uvm_reg_map this_map = parent_map;
%000000        parent_map = this_map.get_parent_map();
%000000        offset = parent_map == null ? this_map.get_base_addr(UVM_NO_HIER) :
                                             parent_map.get_submap_offset(this_map);
%000000        prefix = {prefix, "  "};
%000000        begin
%000000          uvm_endianness_e e = this_map.get_endian();
%000000          $sformat(convert2string,
                        "%s%sMapped in '%s' -- %d bytes, %s, offset 'h%0h\n",
%000000                 convert2string, prefix, this_map.get_full_name(), this_map.get_n_bytes(),
%000000                 e.name(), offset);
               end
             end
           end
%000000    prefix = "  ";
%000000    foreach(m_fields[i]) begin
%000000      $sformat(convert2string, "%s\n%s", convert2string,
%000000                m_fields[i].convert2string());
           end
        
%000000    if (m_read_in_progress == 1'b1) begin
%000000      if (m_fname != "" && m_lineno != 0) begin
        
%000000        $sformat(res_str, "%s:%0d ",m_fname, m_lineno);
             end
        
%000000      convert2string = {convert2string, "\n", res_str,
%000000                         "currently executing read method"};
           end
%000000    if ( m_write_in_progress == 1'b1) begin
%000000      if (m_fname != "" && m_lineno != 0) begin
        
%000000        $sformat(res_str, "%s:%0d ",m_fname, m_lineno);
             end
        
%000000      convert2string = {convert2string, "\n", res_str,
%000000                         "currently executing write method"};
           end
        
        endfunction: convert2string
        
        
        // do_print
        
%000000 function void uvm_reg::do_print (uvm_printer printer);
%000000   uvm_reg_field f[$];
%000000   super.do_print(printer);
%000000   get_fields(f);
%000000   foreach(f[i]) begin
%000000     printer.print_generic(f[i].get_name(),f[i].get_type_name(),-2,f[i].convert2string());
          end
        
        endfunction
        
        
        
        // clone
        
%000000 function uvm_object uvm_reg::clone();
%000000   `uvm_fatal("RegModel","RegModel registers cannot be cloned")
%000000   return null;
        endfunction
        
        // do_copy
        
%000000 function void uvm_reg::do_copy(uvm_object rhs);
%000000   `uvm_fatal("RegModel","RegModel registers cannot be copied")
        endfunction
        
        
        // do_compare
        
%000000 function bit uvm_reg::do_compare (uvm_object  rhs,
                                                uvm_comparer comparer);
%000000   `uvm_warning("RegModel","RegModel registers cannot be compared")
%000000   return 0;
        endfunction
        
        
        // do_pack
        
%000000 function void uvm_reg::do_pack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel registers cannot be packed")
        endfunction
        
        
        // do_unpack
        
%000000 function void uvm_reg::do_unpack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel registers cannot be unpacked")
        endfunction
        
