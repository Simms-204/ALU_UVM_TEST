//      // verilator_coverage annotation
        //
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2020-2022 Intel Corporation
        // Copyright 2020-2022 Marvell International Ltd.
        // Copyright 2010-2020 Mentor Graphics Corporation
        // Copyright 2026 Microsoft
        // Copyright 2014-2026 NVIDIA Corporation
        // Copyright 2018 Qualcomm, Inc.
        // Copyright 2012-2022 Semifore
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
        // $File:     src/reg/uvm_reg_field.svh $
        // $Rev:      2026-06-10 09:59:36 -0700 $
        // $Hash:     d69bd29b12f83a7fb6866ad5fd1247d0968f1bca $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_reg_cbs;
        
        
        // Class: uvm_reg_field
        // This is an implementation of uvm_reg_field as described in 1800.2 with
        // the addition of API described below.
        
        
        // @uvm-ieee 1800.2-2020 auto 18.5.1
        class uvm_reg_field extends uvm_object;
        
           // Variable -- NODOCS -- value
           // Mirrored field value.
           // This value can be sampled in a functional coverage model
           // or constrained when randomized.
           rand  uvm_reg_data_t  value; // Mirrored after randomize()
        
           local uvm_reg_data_t  m_mirrored; // What we think is in the HW
           local uvm_reg_data_t  m_desired;  // Mirrored after set()
           local string          m_access;
           local uvm_reg         m_parent;
           local int unsigned    m_lsb;
           local int unsigned    m_size;
           local bit             m_volatile;
           local uvm_reg_data_t  m_reset[string];
           local bit             m_written;
           local bit             m_read_in_progress;
           local bit             m_write_in_progress;
           local string          m_fname;
           local int             m_lineno;
           local int             m_cover_on;
           local bit             m_individually_accessible;
           local uvm_check_e     m_check;
        
           local static int m_max_size;
           local static bit m_policy_names[string];
           /*local*/ static uvm_reg_field m_reg_field_registry[string];
        
           constraint uvm_reg_field_valid {
              if (`UVM_REG_DATA_WIDTH > m_size) {
                value < (`UVM_REG_DATA_WIDTH'h1 << m_size);
              }
           }
        
%000000    `uvm_object_utils(uvm_reg_field)
        
           //----------------------
           // Group -- NODOCS -- Initialization
           //----------------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.3.1
           extern function new(string name = "uvm_reg_field");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.3.2
           extern function void configure(uvm_reg        parent,
                                          int unsigned   size,
                                          int unsigned   lsb_pos,
                                          string         access,
                                          bit            volatile,
                                          uvm_reg_data_t reset,
                                          bit            has_reset,
                                          bit            is_rand,
                                          bit            individually_accessible);
        
        
           //---------------------
           // Group -- NODOCS -- Introspection
           //---------------------
        
           // Function -- NODOCS -- get_name
           //
           // Get the simple name
           //
           // Return the simple object name of this field
           //
        
        
           // Function -- NODOCS -- get_full_name
           //
           // Get the hierarchical name
           //
           // Return the hierarchal name of this field
           // The base of the hierarchical name is the root block.
           //
           extern virtual function string get_full_name();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.1
           extern virtual function uvm_reg get_parent();
           extern virtual function uvm_reg get_register();
        
        
           // Function -- NODOCS -- get_lsb_pos
           //
           // Return the position of the field
           //
           // Returns the index of the least significant bit of the field
           // in the register that instantiates it.
           // An offset of 0 indicates a field that is aligned with the
           // least-significant bit of the register.
           //
           extern virtual function int unsigned get_lsb_pos();
        
        
           // Function -- NODOCS -- get_n_bits
           //
           // Returns the width, in number of bits, of the field.
           //
           extern virtual function int unsigned get_n_bits();
        
           //
           // FUNCTION -- NODOCS -- get_max_size
           // Returns the width, in number of bits, of the largest field.
           //
           extern static function int unsigned get_max_size();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.6
           extern virtual function string set_access(string mode);
        
           // Function: set_rand_mode
           // Modifies the ~rand_mode~ for the field instance to the specified one
           //
           // @uvm-contrib This API is being considered for potential contribution to 1800.2
           extern virtual function void set_rand_mode(bit rand_mode);
        
           // Function: get_rand_mode
           // Returns the rand_mode of the field instance
           //
           // @uvm-contrib This API is being considered for potential contribution to 1800.2
           extern virtual function bit get_rand_mode();
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.7
           extern static function bit define_access(string name);
%000003    local static bit m_predefined = m_predefine_policies();
           extern local static function bit m_predefine_policies();
        
           // Function -- NODOCS -- get_access
           //
           // Get the access policy of the field
           //
           // Returns the current access policy of the field
           // when written and read through the specified address ~map~.
           // If the register containing the field is mapped in multiple
           // address map, an address map must be specified.
           // The access policy of a field from a specific
           // address map may be restricted by the register's access policy in that
           // address map.
           // For example, a RW field may only be writable through one of
           // the address maps and read-only through all of the other maps.
           // If the field access contradicts the map's access value
           // (field access of WO, and map access value of RO, etc), the
           // method's return value is NOACCESS.
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.5
           extern virtual function string get_access(uvm_reg_map map = null);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.8
           extern virtual function bit is_known_access(uvm_reg_map map = null);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.9
           extern virtual function void set_volatility(bit volatile);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.4.10
           extern virtual function bit is_volatile();
        
           // Function -- NODOCS -- get_field_by_full_name
           //
           // Finds a field with the specified full hierarchical name.
           //
           // The name is the full name of the field, starting with the root block.
           // The function looks up the cached registry built after register model is locked
           //
           // If no field is found, returns ~null~.
        
%000000    static function uvm_reg_field get_field_by_full_name(string name);
%000000       return m_reg_field_registry[name];
           endfunction
        
           //--------------
           // Group -- NODOCS -- Access
           //--------------
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.2
           extern virtual function void set(uvm_reg_data_t  value,
                                            string          fname = "",
                                            int             lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.1
           extern virtual function uvm_reg_data_t get(string fname = "",
                                                      int    lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.3
           extern virtual function uvm_reg_data_t get_mirrored_value(string fname = "",
                                                      int    lineno = 0);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.4
           extern virtual function void reset(string kind = "HARD");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.6
           extern virtual function uvm_reg_data_t get_reset(string kind = "HARD");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.5
           extern virtual function bit has_reset(string kind = "HARD",
                                                 bit    delete = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.7
           extern virtual function void set_reset(uvm_reg_data_t value,
                                                  string kind = "HARD");
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.8
           extern virtual function bit needs_update();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.9
           extern virtual task write (output uvm_status_e       status,
                                      input  uvm_reg_data_t     value,
                                      input  uvm_door_e         path = UVM_DEFAULT_DOOR,
                                      input  uvm_reg_map        map = null,
                                      input  uvm_sequence_base  parent = null,
                                      input  int                prior = -1,
                                      input  uvm_object         extension = null,
                                      input  string             fname = "",
                                      input  int                lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.10
           extern virtual task read  (output uvm_status_e       status,
                                      output uvm_reg_data_t     value,
                                      input  uvm_door_e         path = UVM_DEFAULT_DOOR,
                                      input  uvm_reg_map        map = null,
                                      input  uvm_sequence_base  parent = null,
                                      input  int                prior = -1,
                                      input  uvm_object         extension = null,
                                      input  string             fname = "",
                                      input  int                lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.11
           extern virtual task poke  (output uvm_status_e       status,
                                      input  uvm_reg_data_t     value,
                                      input  string             kind = "",
                                      input  uvm_sequence_base  parent = null,
                                      input  uvm_object         extension = null,
                                      input  string             fname = "",
                                      input  int                lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.12
           extern virtual task peek  (output uvm_status_e       status,
                                      output uvm_reg_data_t     value,
                                      input  string             kind = "",
                                      input  uvm_sequence_base  parent = null,
                                      input  uvm_object         extension = null,
                                      input  string             fname = "",
                                      input  int                lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.13
           extern virtual task mirror(output uvm_status_e      status,
                                      input  uvm_check_e       check = UVM_NO_CHECK,
                                      input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                                      input  uvm_reg_map       map = null,
                                      input  uvm_sequence_base parent = null,
                                      input  int               prior = -1,
                                      input  uvm_object        extension = null,
                                      input  string            fname = "",
                                      input  int               lineno = 0);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.15
           extern function void set_compare(uvm_check_e check=UVM_CHECK);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.14
           extern function uvm_check_e get_compare();
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.16
           extern function bit is_indv_accessible (uvm_door_e  path,
                                                   uvm_reg_map local_map);
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.5.17
           extern function bit predict (uvm_reg_data_t    value,
                                        uvm_reg_byte_en_t be = -1,
                                        uvm_predict_e     kind = UVM_PREDICT_DIRECT,
                                        uvm_door_e        path = UVM_FRONTDOOR,
                                        uvm_reg_map       map = null,
                                        string            fname = "",
                                        int               lineno = 0);
        
        
        
           /*local*/
           extern virtual function uvm_reg_data_t XpredictX (uvm_reg_data_t cur_val,
                                                             uvm_reg_data_t wr_val,
                                                             uvm_reg_map    map);
        
           /*local*/
           extern virtual function uvm_reg_data_t XupdateX();
        
           /*local*/
           extern function bit Xcheck_accessX (input uvm_reg_item rw,
                                               output uvm_reg_map_info map_info);
        
           extern virtual task do_write(uvm_reg_item rw);
           extern virtual task do_read(uvm_reg_item rw);
           extern virtual function void do_predict
                                          (uvm_reg_item rw,
                                           uvm_predict_e kind=UVM_PREDICT_DIRECT,
                                           uvm_reg_byte_en_t be = -1);
        
        
           extern function void pre_randomize();
           extern function void post_randomize();
        
        
           //-----------------
           // Group -- NODOCS -- Callbacks
           //-----------------
        
%000003    `uvm_register_cb(uvm_reg_field, uvm_reg_cbs)
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.6.1
%000000    virtual task pre_write  (uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.6.2
%000000    virtual task post_write (uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.6.3
%000000    virtual task pre_read (uvm_reg_item rw); endtask
        
        
        
           // @uvm-ieee 1800.2-2020 auto 18.5.6.4
%000000    virtual task post_read  (uvm_reg_item rw); endtask
        
        
           extern virtual function void do_print (uvm_printer printer);
           extern virtual function string convert2string;
           extern virtual function uvm_object clone();
           extern virtual function void do_copy   (uvm_object rhs);
           extern virtual function bit  do_compare (uvm_object  rhs,
                                                    uvm_comparer comparer);
           extern virtual function void do_pack (uvm_packer packer);
           extern virtual function void do_unpack (uvm_packer packer);
        
        endclass: uvm_reg_field
        
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
        
        
        // new
        
%000000 function uvm_reg_field::new(string name = "uvm_reg_field");
%000000    super.new(name);
        endfunction: new
        
        
        // configure
        
%000000 function void uvm_reg_field::configure(uvm_reg        parent,
                                               int unsigned   size,
                                               int unsigned   lsb_pos,
                                               string         access,
                                               bit            volatile,
                                               uvm_reg_data_t reset,
                                               bit            has_reset,
                                               bit            is_rand,
                                               bit            individually_accessible);
%000000    m_parent = parent;
%000000    if (size == 0) begin
             `uvm_error("RegModel",
%000000      $sformatf("Field \"%s\" cannot have 0 bits", get_full_name()))
%000000      size = 1;
           end
        
%000000    m_size      = size;
%000000    m_volatile  = volatile;
%000000    m_access    = access.toupper();
%000000    m_lsb       = lsb_pos;
%000000    m_cover_on  = UVM_NO_COVERAGE;
%000000    m_written   = 0;
%000000    m_check     = volatile ? UVM_NO_CHECK : UVM_CHECK;
%000000    m_individually_accessible = individually_accessible;
        
        
%000000    m_desired &= ((1 << m_size)-1);
%000000    value &= ((1 << m_size)-1);
%000000    m_mirrored &= ((1 << m_size)-1);
        
        
%000000    if (has_reset) begin
        
%000000      set_reset(reset);
           end
        
        
%000000    m_parent.add_field(this);
        
%000000    if (!m_policy_names.exists(m_access)) begin
             `uvm_error("RegModel", {"Access policy '",access,
%000000      "' for field '",get_full_name(),"' is not defined. Setting to RW"})
%000000      m_access = "RW";
           end
        
%000000    if (size > m_max_size) begin
        
%000000      m_max_size = size;
           end
        
        
           // Ignore is_rand if the field is known not to be writeable
           // i.e. not "RW", "WRC", "WRS", "WO", "W1", "WO1"
%000000    case (access)
             "RO", "RC", "RS", "WC", "WS",
             "W1C", "W1S", "W1T", "W0C", "W0S", "W0T",
             "W1SRC", "W1CRS", "W0SRC", "W0CRS", "WSRC", "WCRS",
%000000      "WOC", "WOS": begin
%000000        is_rand = 0;
             end
        
           endcase
        
%000000    if (!is_rand) begin
        
%000000      set_rand_mode(0);
           end
        
        
        endfunction: configure
        
        
        // get_parent
        
%000000 function uvm_reg uvm_reg_field::get_parent();
%000000    return m_parent;
        endfunction: get_parent
        
        
        // get_full_name
        
%000000 function string uvm_reg_field::get_full_name();
%000000    return {m_parent.get_full_name(), ".", get_name()};
        endfunction: get_full_name
        
        
        // get_register
        
%000000 function uvm_reg uvm_reg_field::get_register();
%000000    return m_parent;
        endfunction: get_register
        
        
        // get_lsb_pos
        
%000000 function int unsigned uvm_reg_field::get_lsb_pos();
%000000    return m_lsb;
        endfunction: get_lsb_pos
        
        
        // get_n_bits
        
%000000 function int unsigned uvm_reg_field::get_n_bits();
%000000    return m_size;
        endfunction: get_n_bits
        
        
        // get_max_size
        
%000000 function int unsigned uvm_reg_field::get_max_size();
%000000    return m_max_size;
        endfunction: get_max_size
        
        
        // is_known_access
        
%000000 function bit uvm_reg_field::is_known_access(uvm_reg_map map = null);
%000000    string acc = get_access(map);
%000000    case (acc)
             "RO", "RW", "RC", "RS", "WC", "WS",
             "W1C", "W1S", "W1T", "W0C", "W0S", "W0T",
             "WRC", "WRS", "W1SRC", "W1CRS", "W0SRC", "W0CRS", "WSRC", "WCRS",
%000000      "WO", "WOC", "WOS", "W1", "WO1" : begin
%000000        return 1;
             end
        
           endcase
%000000    return 0;
        endfunction
        
        
        // get_access
        
%000000 function string uvm_reg_field::get_access(uvm_reg_map map = null);
%000000    string field_access = m_access;
        
%000000    if (map == uvm_reg_map::backdoor()) begin
        
%000000      return field_access;
           end
        
        
           // Is the register restricted in this map?
%000000    case (m_parent.get_rights(map))
%000000      "RW": begin
               // No restrictions
        
%000000        return field_access;
             end
        
        
%000000      "RO": begin
        
%000000        case (field_access)
                 "RW", "RO", "WC", "WS",
                 "W1C", "W1S", "W1T", "W0C", "W0S", "W0T",
                 "W1"
%000000          : begin
%000000            field_access = "RO";
                 end
        
        
                 "RC", "WRC", "W1SRC", "W0SRC", "WSRC"
%000000          : begin
%000000            field_access = "RC";
                 end
        
        
                 "RS", "WRS", "W1CRS", "W0CRS", "WCRS"
%000000          : begin
%000000            field_access = "RS";
                 end
        
        
%000000          "WO", "WOC", "WOS", "WO1": begin
%000000            field_access = "NOACCESS";
                 end
        
                 // No change for the other modes
               endcase
             end
        
        
%000000      "WO": begin
        
%000000        case (field_access)
%000000          "RW","WRC","WRS" : begin
%000000            field_access = "WO";
                 end
        
%000000          "W1SRC" : begin
%000000            field_access = "W1S";
                 end
        
%000000          "W0SRC": begin
%000000            field_access = "W0S";
                 end
        
%000000          "W1CRS": begin
%000000            field_access = "W1C";
                 end
        
%000000          "W0CRS": begin
%000000            field_access = "W0C";
                 end
        
%000000          "WCRS": begin
%000000            field_access = "WC";
                 end
        
%000000          "W1" : begin
%000000            field_access = "W1";
                 end
        
%000000          "WO1" : begin
%000000            field_access = "WO1";
                 end
        
%000000          "WSRC" : begin
%000000            field_access = "WS";
                 end
        
%000000          "RO","RC","RS": begin
%000000            field_access = "NOACCESS";
                 end
        
                 // No change for the other modes
                 //         "WO","WC","WS","W1C","W1S","W0C","W0S","W0T","W1" : null;
        
               endcase
             end
        
        
%000000      default: begin
        
%000000        field_access = "NOACCESS";
               `uvm_warning("RegModel", {"Register '",m_parent.get_full_name(),
               "' containing field '",get_name(),"' is mapped in map '",
%000000        map.get_full_name(),"' with unknown access right '", m_parent.get_rights(map), "'"})
             end
           endcase
%000000    return field_access;
        endfunction: get_access
        
        
        // set_access
        
%000000 function string uvm_reg_field::set_access(string mode);
%000000    set_access = m_access;
%000000    m_access = mode.toupper();
%000000    if (!m_policy_names.exists(m_access)) begin
             `uvm_error("RegModel", {"Access policy '",m_access,
%000000      "' is not a defined field access policy"})
%000000      m_access = set_access;
           end
        endfunction: set_access
        
        
        // set_rand_mode
        
%000000 function void uvm_reg_field::set_rand_mode(bit rand_mode);
%000000     value.rand_mode(rand_mode);
%000000     uvm_reg_field_valid.constraint_mode(rand_mode);
        endfunction: set_rand_mode
        
        
        // get_rand_mode
        
%000000 function bit uvm_reg_field::get_rand_mode();
%000000     return bit'(value.rand_mode());
        endfunction: get_rand_mode
        
        
        // define_access
        
 000075 function bit uvm_reg_field::define_access(string name);
~000075    if (!m_predefined) begin
%000000      m_predefined = m_predefine_policies();
           end
        
        
 000075    name = name.toupper();
        
~000075    if (m_policy_names.exists(name)) begin
%000000      return 0;
           end
        
        
 000075    m_policy_names[name] = 1;
 000075    return 1;
        endfunction
        
        
        // m_predefined_policies
        
%000003 function bit uvm_reg_field::m_predefine_policies();
%000003    if (m_predefined) begin
%000000      return 1;
           end
        
        
%000003    m_predefined = 1;
        
%000003    void'(define_access("RO"));
%000003    void'(define_access("RW"));
%000003    void'(define_access("RC"));
%000003    void'(define_access("RS"));
%000003    void'(define_access("WRC"));
%000003    void'(define_access("WRS"));
%000003    void'(define_access("WC"));
%000003    void'(define_access("WS"));
%000003    void'(define_access("WSRC"));
%000003    void'(define_access("WCRS"));
%000003    void'(define_access("W1C"));
%000003    void'(define_access("W1S"));
%000003    void'(define_access("W1T"));
%000003    void'(define_access("W0C"));
%000003    void'(define_access("W0S"));
%000003    void'(define_access("W0T"));
%000003    void'(define_access("W1SRC"));
%000003    void'(define_access("W1CRS"));
%000003    void'(define_access("W0SRC"));
%000003    void'(define_access("W0CRS"));
%000003    void'(define_access("WO"));
%000003    void'(define_access("WOC"));
%000003    void'(define_access("WOS"));
%000003    void'(define_access("W1"));
%000003    void'(define_access("WO1"));
%000003    return 1;
        endfunction
        
        
        // set_volatility
        
%000000 function void uvm_reg_field::set_volatility(bit volatile);
%000000    m_volatile = volatile;
        endfunction
        
        
        // is_volatile
        
%000000 function bit uvm_reg_field::is_volatile();
%000000    return m_volatile;
        endfunction
        
        
        // XpredictX
        
%000000 function uvm_reg_data_t uvm_reg_field::XpredictX (uvm_reg_data_t cur_val,
                                                          uvm_reg_data_t wr_val,
                                                          uvm_reg_map    map);
%000000    uvm_reg_data_t mask = ('b1 << m_size)-1;
%000000    cur_val &= mask;
%000000    wr_val &= mask;
%000000    case (get_access(map))
%000000      "RO":    begin
%000000        return cur_val;
             end
        
%000000      "RW":    begin
%000000        return wr_val;
             end
        
%000000      "RC":    begin
%000000        return cur_val;
             end
        
%000000      "RS":    begin
%000000        return cur_val;
             end
        
%000000      "WC":    begin
%000000        return '0;
             end
        
%000000      "WS":    begin
%000000        return mask;
             end
        
%000000      "WRC":   begin
%000000        return wr_val;
             end
        
%000000      "WRS":   begin
%000000        return wr_val;
             end
        
%000000      "WSRC":  begin
%000000        return mask;
             end
        
%000000      "WCRS":  begin
%000000        return '0;
             end
        
%000000      "W1C":   begin
%000000        return cur_val & (~wr_val);
             end
        
%000000      "W1S":   begin
%000000        return cur_val | wr_val;
             end
        
%000000      "W1T":   begin
%000000        return cur_val ^ wr_val;
             end
        
%000000      "W0C":   begin
%000000        return cur_val & wr_val;
             end
        
%000000      "W0S":   begin
%000000        return cur_val | (~wr_val & mask);
             end
        
%000000      "W0T":   begin
%000000        return cur_val ^ (~wr_val & mask);
             end
        
%000000      "W1SRC": begin
%000000        return cur_val | wr_val;
             end
        
%000000      "W1CRS": begin
%000000        return cur_val & (~wr_val);
             end
        
%000000      "W0SRC": begin
%000000        return cur_val | (~wr_val & mask);
             end
        
%000000      "W0CRS": begin
%000000        return cur_val & wr_val;
             end
        
%000000      "WO":    begin
%000000        return wr_val;
             end
        
%000000      "WOC":   begin
%000000        return '0;
             end
        
%000000      "WOS":   begin
%000000        return mask;
             end
        
%000000      "W1":    begin
%000000        return (m_written) ? cur_val : wr_val;
             end
        
%000000      "WO1":   begin
%000000        return (m_written) ? cur_val : wr_val;
             end
        
%000000      "NOACCESS": begin
%000000        return cur_val;
             end
        
%000000      default: begin
%000000        return wr_val;
             end
        
           endcase
        
%000000    `uvm_fatal("RegModel", "uvm_reg_field::XpredictX(): Internal error")
%000000    return 0;
        endfunction: XpredictX
        
        
        
        // predict
        
%000000 function bit uvm_reg_field::predict (uvm_reg_data_t    value,
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
        
%000000 function void uvm_reg_field::do_predict(uvm_reg_item      rw,
                                                uvm_predict_e     kind = UVM_PREDICT_DIRECT,
%000000                                         uvm_reg_byte_en_t be = -1);
        
%000000    uvm_reg_data_t field_val = rw.get_value(0) & ((1 << m_size)-1);
        
%000000    if (rw.get_status() != UVM_NOT_OK) begin
        
%000000      rw.set_status(UVM_IS_OK);
           end
        
        
           // Assume that the entire field is enabled
%000000    if (!be[0]) begin
        
%000000      return;
           end
        
        
%000000    m_fname = rw.get_fname();
%000000    m_lineno = rw.get_line();
        
%000000    case (kind)
        
%000000      UVM_PREDICT_WRITE: begin
        
%000000        uvm_reg_field_cb_iter cbs = new(this);
        
%000000        if (rw.get_door() == UVM_FRONTDOOR || rw.get_door() == UVM_PREDICT) begin
        
%000000          field_val = XpredictX(m_mirrored, field_val, rw.get_map());
               end
        
        
%000000        m_written = 1;
        
%000000        for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next()) begin
        
%000000          cb.post_predict(this, m_mirrored, field_val,
%000000                             UVM_PREDICT_WRITE, rw.get_door(), rw.get_map());
               end
        
        
%000000        field_val &= ('b1 << m_size)-1;
        
             end
        
%000000      UVM_PREDICT_READ: begin
        
%000000        uvm_reg_field_cb_iter cbs = new(this);
        
%000000        if (rw.get_door() == UVM_FRONTDOOR || rw.get_door() == UVM_PREDICT) begin
        
%000000          string acc = get_access(rw.get_map());
        
%000000          if (acc == "RC" ||
                 acc == "WRC" ||
                 acc == "WSRC" ||
%000000          acc == "W1SRC" ||
%000000          acc == "W0SRC") begin
        
%000000            field_val = 0;
                 end
                 // (clear)
        
%000000          else if (acc == "RS" ||
                 acc == "WRS" ||
                 acc == "WCRS" ||
%000000          acc == "W1CRS" ||
%000000          acc == "W0CRS") begin
        
%000000            field_val = ('b1 << m_size)-1;
                 end
                 // all 1's (set)
        
%000000          else if (acc == "WO" ||
                 acc == "WOC" ||
                 acc == "WOS" ||
%000000          acc == "WO1" ||
%000000          acc == "NOACCESS") begin
        
%000000            return;
                 end
        
               end
        
%000000        for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next()) begin
        
%000000          cb.post_predict(this, m_mirrored, field_val,
%000000                             UVM_PREDICT_READ, rw.get_door(), rw.get_map());
               end
        
        
%000000        field_val &= ('b1 << m_size)-1;
        
             end
        
%000000      UVM_PREDICT_DIRECT: begin
        
%000000        if (m_parent.is_busy()) begin
                 `uvm_warning("RegModel", {"Trying to predict value of field '",
                 get_name(),"' while register '",m_parent.get_full_name(),
%000000          "' is being accessed"})
%000000          rw.set_status(UVM_NOT_OK);
               end
             end
           endcase
        
           // update the mirror with predicted value
%000000    m_mirrored = field_val;
%000000    m_desired  = field_val;
%000000    this.value = field_val;
        
        endfunction: do_predict
        
        
        // XupdateX
        
%000000 function uvm_reg_data_t  uvm_reg_field::XupdateX();
           // Figure out which value must be written to get the desired value
           // given what we think is the current value in the hardware
%000000    XupdateX = 0;
        
%000000    case (m_access)
%000000      "RO":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "RW":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "RC":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "RS":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WRC":   begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WRS":   begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WC":    begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 0
%000000      "WS":    begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 1
%000000      "WSRC":  begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 1
%000000      "WCRS":  begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 0
%000000      "W1C":   begin
%000000        XupdateX = ~m_desired;
             end
        
%000000      "W1S":   begin
%000000        XupdateX = m_desired;
             end
        
%000000      "W1T":   begin
%000000        XupdateX = m_desired ^ m_mirrored;
             end
        
%000000      "W0C":   begin
%000000        XupdateX = m_desired;
             end
        
%000000      "W0S":   begin
%000000        XupdateX = ~m_desired;
             end
        
%000000      "W0T":   begin
%000000        XupdateX = ~(m_desired ^ m_mirrored);
             end
        
%000000      "W1SRC": begin
%000000        XupdateX = m_desired;
             end
        
%000000      "W1CRS": begin
%000000        XupdateX = ~m_desired;
             end
        
%000000      "W0SRC": begin
%000000        XupdateX = ~m_desired;
             end
        
%000000      "W0CRS": begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WO":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WOC":   begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 0
%000000      "WOS":   begin
%000000        XupdateX = m_desired;
             end
             // Warn if != 1
%000000      "W1":    begin
%000000        XupdateX = m_desired;
             end
        
%000000      "WO1":   begin
%000000        XupdateX = m_desired;
             end
        
%000000      default: begin
%000000        XupdateX = m_desired;
             end
        
           endcase
%000000    XupdateX &= (1 << m_size) - 1;
        
        endfunction: XupdateX
        
        
        // set
        
%000000 function void uvm_reg_field::set(uvm_reg_data_t  value,
%000000                                  string          fname = "",
%000000                                  int             lineno = 0);
%000000    uvm_reg_data_t mask = ('b1 << m_size)-1;
        
%000000    m_fname = fname;
%000000    m_lineno = lineno;
           // Check for unknown bits in value greater than field
%000000    if ($isunknown(value >> m_size)) begin
             `uvm_warning("RegModel",
             $sformatf("Specified value (0x%h) has unknown bits that can allow for a value greater than field \"%s\" size (%0d bits)",
%000000      value, get_name(), m_size))
%000000      value &= mask;
           end
%000000    else if (value >> m_size) begin
             `uvm_warning("RegModel",
             $sformatf("Specified value (0x%h) greater than field \"%s\" size (%0d bits)",
%000000      value, get_name(), m_size))
%000000      value &= mask;
           end
        
%000000    if (m_parent.is_busy()) begin
             `uvm_warning("UVM/FLD/SET/BSY",
             $sformatf("Setting the value of field \"%s\" while containing register \"%s\" is being accessed may result in loss of desired field value. A race condition between threads concurrently accessing the register model is the likely cause of the problem.",
%000000      get_name(), m_parent.get_full_name()))
           end
        
%000000    case (m_access)
%000000      "RO":    begin
%000000        m_desired = m_desired;
             end
        
%000000      "RW":    begin
%000000        m_desired = value;
             end
        
%000000      "RC":    begin
%000000        m_desired = m_desired;
             end
        
%000000      "RS":    begin
%000000        m_desired = m_desired;
             end
        
%000000      "WC":    begin
%000000        m_desired = '0;
             end
        
%000000      "WS":    begin
%000000        m_desired = mask;
             end
        
%000000      "WRC":   begin
%000000        m_desired = value;
             end
        
%000000      "WRS":   begin
%000000        m_desired = value;
             end
        
%000000      "WSRC":  begin
%000000        m_desired = mask;
             end
        
%000000      "WCRS":  begin
%000000        m_desired = '0;
             end
        
%000000      "W1C":   begin
%000000        m_desired = m_desired & (~value);
             end
        
%000000      "W1S":   begin
%000000        m_desired = m_desired | value;
             end
        
%000000      "W1T":   begin
%000000        m_desired = m_desired ^ value;
             end
        
%000000      "W0C":   begin
%000000        m_desired = m_desired & value;
             end
        
%000000      "W0S":   begin
%000000        m_desired = m_desired | (~value & mask);
             end
        
%000000      "W0T":   begin
%000000        m_desired = m_desired ^ (~value & mask);
             end
        
%000000      "W1SRC": begin
%000000        m_desired = m_desired | value;
             end
        
%000000      "W1CRS": begin
%000000        m_desired = m_desired & (~value);
             end
        
%000000      "W0SRC": begin
%000000        m_desired = m_desired | (~value & mask);
             end
        
%000000      "W0CRS": begin
%000000        m_desired = m_desired & value;
             end
        
%000000      "WO":    begin
%000000        m_desired = value;
             end
        
%000000      "WOC":   begin
%000000        m_desired = '0;
             end
        
%000000      "WOS":   begin
%000000        m_desired = mask;
             end
        
%000000      "W1":    begin
%000000        m_desired = (m_written) ? m_desired : value;
             end
        
%000000      "WO1":   begin
%000000        m_desired = (m_written) ? m_desired : value;
             end
        
%000000      default: begin
%000000        m_desired = value;
             end
        
           endcase
%000000    m_desired &= ((1 << m_size)-1);
%000000    this.value = m_desired;
        endfunction: set
        
        
        // get
        
%000000 function uvm_reg_data_t  uvm_reg_field::get(string  fname = "",
                                                    int     lineno = 0);
%000000    m_fname = fname;
%000000    m_lineno = lineno;
%000000    get = m_desired & ((1 << m_size)-1);
        endfunction: get
        
        
        // get_mirrored_value
        
%000000 function uvm_reg_data_t  uvm_reg_field::get_mirrored_value(string  fname = "",
                                                    int     lineno = 0);
%000000    if (is_volatile()) begin
%000000      `uvm_warning("UVM/FLD/GET_MIRRORED_VAL/VOL",$sformatf("Mirrored value returned for volatile field \"%s\" may not reflect the actual current value.",this.get_full_name()))
           end
%000000    m_fname = fname;
%000000    m_lineno = lineno;
%000000    get_mirrored_value = m_mirrored & ((1 << m_size)-1);
        endfunction: get_mirrored_value
        
        
        // reset
        
%000000 function void uvm_reg_field::reset(string kind = "HARD");
        
%000000    if (!m_reset.exists(kind)) begin
        
%000000      return;
           end
        
        
%000000    m_mirrored = m_reset[kind];
%000000    m_desired  = m_mirrored;
%000000    value      = m_mirrored;
        
%000000    if (kind == "HARD") begin
        
%000000      m_written  = 0;
           end
        
        
        endfunction: reset
        
        
        // has_reset
        
%000000 function bit uvm_reg_field::has_reset(string kind = "HARD",
                                              bit    delete = 0);
        
%000000    if (!m_reset.exists(kind)) begin
%000000      return 0;
           end
        
        
%000000    if (delete) begin
%000000      m_reset.delete(kind);
           end
        
        
%000000    return 1;
        endfunction: has_reset
        
        
        // get_reset
        
        function uvm_reg_data_t
%000000    uvm_reg_field::get_reset(string kind = "HARD");
        
%000000    if (!m_reset.exists(kind)) begin
        
%000000      return m_desired & ((1 << m_size)-1);
           end
        
        
%000000    return m_reset[kind];
        
        endfunction: get_reset
        
        
        // set_reset
        
%000000 function void uvm_reg_field::set_reset(uvm_reg_data_t value,
%000000                                        string kind = "HARD");
%000000    m_reset[kind] = value & ((1<<m_size) - 1);
        endfunction: set_reset
        
        
        // needs_update
        
%000000 function bit uvm_reg_field::needs_update();
%000000    if (get_access() inside {"RO","RC","RS"}) begin
        
%000000      return 0;
           end
        
%000000    needs_update = (m_mirrored !== m_desired) | m_volatile;
        endfunction: needs_update
        
        
        typedef class uvm_reg_map_info;
        
        
        // Xcheck_accessX
        
%000000 function bit uvm_reg_field::Xcheck_accessX(input uvm_reg_item rw,
%000000                                            output uvm_reg_map_info map_info);
%000000   uvm_reg_map local_tmp_map;
        
%000000    if (rw.get_door() == UVM_DEFAULT_DOOR) begin
%000000      uvm_reg_block blk = m_parent.get_block();
%000000      rw.set_door(blk.get_default_door());
           end
        
%000000    if (rw.get_door() == UVM_BACKDOOR) begin
%000000      if (m_parent.get_backdoor() == null && !m_parent.has_hdl_path()) begin
               `uvm_warning("RegModel",
               {"No backdoor access available for field '",get_full_name(),
%000000        "' . Using frontdoor instead."})
%000000        rw.set_door(UVM_FRONTDOOR);
             end
%000000      else begin
        
%000000        rw.set_map(uvm_reg_map::backdoor());
             end
        
           end
        
%000000    if (rw.get_door() != UVM_BACKDOOR) begin
        
%000000      rw.set_local_map(m_parent.get_local_map(rw.get_map()));
        
%000000      if (rw.get_local_map() == null) begin
%000000        local_tmp_map = rw.get_map();
               `uvm_error(get_type_name(),
               {"No transactor available to physically access memory from map '",
%000000        local_tmp_map.get_full_name(),"'"})
%000000        rw.set_status(UVM_NOT_OK);
%000000        return 0;
             end
        
%000000      local_tmp_map = rw.get_local_map;
%000000      map_info = local_tmp_map.get_reg_map_info(m_parent);
        
%000000      if (map_info.frontdoor == null && map_info.unmapped) begin
               `uvm_error("RegModel", {"Field '",get_full_name(),
               "' in register that is unmapped in map '",
               local_tmp_map.get_full_name(),
%000000        "' and does not have a user-defined frontdoor"})
%000000        rw.set_status(UVM_NOT_OK);
%000000        return 0;
             end
        
%000000      if (rw.get_map() == null) begin
        
%000000        rw.set_map(rw.get_local_map());
             end
        
           end
        
%000000    return 1;
        endfunction
        
        
        // write
        
%000000 task uvm_reg_field::write(output uvm_status_e       status,
                                  input  uvm_reg_data_t     value,
                                  input  uvm_door_e         path = UVM_DEFAULT_DOOR,
                                  input  uvm_reg_map        map = null,
                                  input  uvm_sequence_base  parent = null,
                                  input  int                prior = -1,
                                  input  uvm_object         extension = null,
                                  input  string             fname = "",
                                  input  int                lineno = 0);
        
%000000    uvm_reg_item rw;
        
%000000    set(value);
        
%000000    rw = uvm_reg_item::type_id::create("field_write_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_FIELD);
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
        
        endtask
        
        
        // do_write
        
%000000 task uvm_reg_field::do_write(uvm_reg_item rw);
        
%000000    uvm_reg_data_t   value_adjust=0;
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_field    fields[$];
%000000    bit bad_side_effect;
        
%000000    m_parent.XatomicX(1);
%000000    m_fname  = rw.get_fname();
%000000    m_lineno = rw.get_line();
        
%000000    if (!Xcheck_accessX(rw,map_info)) begin
%000000      m_parent.XatomicX(0);
%000000      return;
           end
        
%000000    m_write_in_progress = 1'b1;
        
           // Check for unknown bits in value greater than field
%000000    if ($isunknown(rw.get_value(0) >> m_size)) begin
%000000      uvm_reg_data_t tmp_value;
             `uvm_warning("RegModel", {"uvm_reg_field::write(): Has unknown bits that can allow for a value greater than field '",
%000000      get_full_name(),"'"})
%000000      tmp_value = rw.get_value(0);
%000000      tmp_value &= ((1<<m_size)-1);
%000000      rw.set_value(tmp_value, 0);
           end
%000000    else if (rw.get_value(0) >> m_size) begin
%000000      uvm_reg_data_t tmp_value;
             `uvm_warning("RegModel", {"uvm_reg_field::write(): Value greater than field '",
%000000      get_full_name(),"'"})
%000000      tmp_value = rw.get_value(0);
%000000      tmp_value &= ((1<<m_size)-1);
%000000      rw.set_value(tmp_value, 0);
           end
        
           // Get values to write to the other fields in register
%000000    m_parent.get_fields(fields);
%000000    foreach (fields[i]) begin
        
%000000      if (fields[i] == this) begin
%000000        value_adjust |= rw.get_value(0) << m_lsb;
%000000        continue;
             end
        
             // It depends on what kind of bits they are made of...
%000000      case (fields[i].get_access(rw.get_local_map()))
               // These...
%000000        "RO", "RC", "RS", "W1C", "W1S", "W1T", "W1SRC", "W1CRC": begin
                 // Use all 0's
        
%000000          value_adjust |= 0;
               end
        
        
               // These...
%000000        "W0C", "W0S", "W0T", "W0SRC", "W0CRS": begin
                 // Use all 1's
        
%000000          value_adjust |= ((1<<fields[i].get_n_bits())-1) << fields[i].get_lsb_pos();
               end
        
        
               // These might have side effects! Bad!
%000000        "WC", "WS", "WCRS", "WSRC", "WOC", "WOS": begin
        
%000000          bad_side_effect = 1;
               end
        
        
%000000        default: begin
        
%000000          value_adjust |= fields[i].m_mirrored << fields[i].get_lsb_pos();
               end
        
        
             endcase
           end
        
        `ifdef UVM_REG_NO_INDIVIDUAL_FIELD_ACCESS
           rw.set_element_kind(UVM_REG);
           rw.set_element(m_parent);
           rw.set_value(value_adjust, 0);
           m_parent.do_write(rw);
        `else
        
%000000    if (!is_indv_accessible(rw.get_door(),rw.get_local_map())) begin
%000000      rw.set_element_kind(UVM_REG);
%000000      rw.set_element(m_parent);
%000000      rw.set_value(value_adjust, 0);
%000000      m_parent.do_write(rw);
        
%000000      if (bad_side_effect) begin
%000000        `uvm_warning("RegModel", $sformatf("Writing field \"%s\" will cause unintended side effects in adjoining Write-to-Clear or Write-to-Set fields in the same register", this.get_full_name()))
             end
           end
%000000    else begin
%000000      uvm_reg_map item_map = rw.get_local_map();
%000000      uvm_reg_map system_map = item_map.get_root_map();
%000000      uvm_reg_field_cb_iter cbs = new(this);
        
%000000      m_parent.Xset_busyX(1);
        
%000000      rw.set_status(UVM_IS_OK);
        
%000000      pre_write(rw);
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.pre_write(rw);
             end
        
        
%000000      if (rw.get_status() != UVM_IS_OK) begin
%000000        m_write_in_progress = 1'b0;
%000000        m_parent.Xset_busyX(0);
%000000        m_parent.XatomicX(0);
        
%000000        return;
             end
        
%000000      item_map.do_write(rw);
        
%000000      if (system_map.get_auto_predict()) begin
               // ToDo: Call parent.XsampleX();
        
%000000        do_predict(rw, UVM_PREDICT_WRITE);
             end
        
        
%000000      post_write(rw);
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.post_write(rw);
             end
        
        
%000000      m_parent.Xset_busyX(0);
        
           end
        
        `endif
        
%000000    m_write_in_progress = 1'b0;
%000000    m_parent.XatomicX(0);
        
        endtask: do_write
        
        
        // read
        
%000000 task uvm_reg_field::read(output uvm_status_e       status,
%000000                          output uvm_reg_data_t     value,
                                 input  uvm_door_e         path = UVM_DEFAULT_DOOR,
                                 input  uvm_reg_map        map = null,
                                 input  uvm_sequence_base  parent = null,
                                 input  int                prior = -1,
                                 input  uvm_object         extension = null,
                                 input  string             fname = "",
                                 input  int                lineno = 0);
        
%000000    uvm_reg_item rw;
%000000    rw = uvm_reg_item::type_id::create("field_read_item",,get_full_name());
%000000    rw.set_element(this);
%000000    rw.set_element_kind(UVM_FIELD);
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
        
%000000    value = rw.get_value(0);
%000000    status = rw.get_status();
        
        endtask: read
        
        
        // do_read
        
%000000 task uvm_reg_field::do_read(uvm_reg_item rw);
        
%000000    uvm_reg_map_info map_info;
%000000    uvm_reg_map rw_local_map;
%000000    bit bad_side_effect;
        
%000000    m_parent.XatomicX(1);
%000000    m_fname  = rw.get_fname();
%000000    m_lineno = rw.get_line();
%000000    m_read_in_progress = 1'b1;
        
%000000    if (!Xcheck_accessX(rw,map_info)) begin
        
%000000      return;
           end
        
        
%000000    rw_local_map = rw.get_local_map();
        
        `ifdef UVM_REG_NO_INDIVIDUAL_FIELD_ACCESS
           rw.set_element_kind(UVM_REG);
           rw.set_element(m_parent);
           m_parent.do_read(rw);
           rw.set_value(((rw.get_value(0) >> m_lsb) & ((1<<m_size))-1), 0);
           bad_side_effect = 1;
        `else
        
%000000    if (!is_indv_accessible(rw.get_door(),rw_local_map)) begin
%000000      uvm_reg_data_t value;
%000000      rw.set_element_kind(UVM_REG);
%000000      rw.set_element(m_parent);
%000000      bad_side_effect = 1;
%000000      m_parent.do_read(rw);
%000000      value = rw.get_value(0);
%000000      rw.set_value(((value >> m_lsb) & ((1<<m_size))-1),0);
           end
%000000    else begin
        
%000000      uvm_reg_map system_map = rw_local_map.get_root_map();
%000000      uvm_reg_field_cb_iter cbs = new(this);
        
%000000      m_parent.Xset_busyX(1);
        
%000000      rw.set_status(UVM_IS_OK);
        
%000000      pre_read(rw);
%000000      for (uvm_reg_cbs cb = cbs.first(); cb != null; cb = cbs.next()) begin
        
%000000        cb.pre_read(rw);
             end
        
        
%000000      if (rw.get_status() != UVM_IS_OK) begin
%000000        m_read_in_progress = 1'b0;
%000000        m_parent.Xset_busyX(0);
%000000        m_parent.XatomicX(0);
        
%000000        return;
             end
        
%000000      rw_local_map.do_read(rw);
        
        
%000000      if (system_map.get_auto_predict()) begin
               // ToDo: Call parent.XsampleX();
        
%000000        do_predict(rw, UVM_PREDICT_READ);
             end
        
        
%000000      post_read(rw);
%000000      for (uvm_reg_cbs cb=cbs.first(); cb!=null; cb=cbs.next()) begin
        
%000000        cb.post_read(rw);
             end
        
        
%000000      m_parent.Xset_busyX(0);
        
           end
        
        `endif
        
%000000    m_read_in_progress = 1'b0;
%000000    m_parent.XatomicX(0);
        
%000000    if (bad_side_effect) begin
%000000      uvm_reg_field fields[$];
%000000      m_parent.get_fields(fields);
%000000      foreach (fields[i]) begin
%000000        string mode;
%000000        if (fields[i] == this) begin
        
%000000          continue;
               end
        
%000000        mode = fields[i].get_access();
%000000        if (mode == "RC" ||
               mode == "RS" ||
               mode == "WRC" ||
               mode == "WRS" ||
               mode == "WSRC" ||
               mode == "WCRS" ||
               mode == "W1SRC" ||
               mode == "W1CRS" ||
%000000        mode == "W0SRC" ||
%000000        mode == "W0CRS") begin
                 `uvm_warning("RegModel", {"Reading field '",get_full_name(),
                 "' will cause unintended side effects in adjoining ",
%000000          "Read-to-Clear or Read-to-Set fields in the same register"})
               end
             end
           end
        
        endtask: do_read
        
        
        // is_indv_accessible
        
%000000 function bit uvm_reg_field::is_indv_accessible(uvm_door_e  path,
                                                       uvm_reg_map local_map);
        
%000000    if (path == UVM_BACKDOOR) begin
             `uvm_warning("RegModel",
             {"Individual BACKDOOR field access not available for field '",
%000000      get_full_name(), "'. Accessing complete register instead."})
%000000      return 0;
           end
        
%000000    if (!m_individually_accessible) begin
             `uvm_warning("RegModel",
             {"Individual field access not available for field '",
%000000      get_full_name(), "'. Accessing complete register instead."})
%000000      return 0;
           end
        
           // Cannot access individual fields if the container register
           // has a user-defined front-door
%000000    if (m_parent.get_frontdoor(local_map) != null) begin
             `uvm_warning("RegModel",
             {"Individual field access not available for field '",
%000000      get_name(), "' because register '", m_parent.get_full_name(), "' has a user-defined front-door. Accessing complete register instead."})
%000000      return 0;
           end
        
%000000    begin
%000000      uvm_reg_map system_map = local_map.get_root_map();
%000000      uvm_reg_adapter adapter = system_map.get_adapter();
%000000      if ((adapter != null) && !adapter.supports_byte_enable) begin
               `uvm_warning("RegModel",
               {"Target bus does not support byte enable, field '", get_full_name(),
%000000        ". Accessing complete register instead."})
%000000        return 0;
             end
           end
        
%000000    begin
%000000      int fld_idx;
%000000      int bus_width = local_map.get_n_bytes();
%000000      uvm_reg_field fields[$];
        
%000000      m_parent.get_fields(fields);
        
%000000      if (fields.size() == 1) begin
%000000        return 1;
             end
%000000      else begin
%000000        int prev_lsb,this_lsb,next_lsb;
%000000        int prev_sz,this_sz,next_sz;
%000000        int bus_sz = bus_width*8;
        
%000000        foreach (fields[i]) begin
%000000          if (fields[i] == this) begin
%000000            fld_idx = i;
%000000            break;
                 end
               end
        
%000000        this_lsb = fields[fld_idx].get_lsb_pos();
%000000        this_sz  = fields[fld_idx].get_n_bits();
        
%000000        if (fld_idx>0) begin
%000000          prev_lsb = fields[fld_idx-1].get_lsb_pos();
%000000          prev_sz  = fields[fld_idx-1].get_n_bits();
               end
        
%000000        if (fld_idx < fields.size()-1) begin
%000000          next_lsb = fields[fld_idx+1].get_lsb_pos();
%000000          next_sz  = fields[fld_idx+1].get_n_bits();
               end
        
               // if first field in register
%000000        if (fld_idx == 0 &&
               ((next_lsb % bus_sz) == 0 ||
%000000        (next_lsb - this_sz) > (next_lsb % bus_sz))) begin
        
%000000          return 1;
               end
        
        
               // if last field in register
%000000        else if (fld_idx == (fields.size()-1) &&
               ((this_lsb % bus_sz) == 0 ||
%000000        (this_lsb - (prev_lsb + prev_sz)) >= (this_lsb % bus_sz))) begin
        
%000000          return 1;
               end
        
        
               // if somewhere in between
%000000        else begin
%000000          if ((this_lsb % bus_sz) == 0) begin
%000000            if ((next_lsb % bus_sz) == 0 ||
%000000            (next_lsb - (this_lsb + this_sz)) >= (next_lsb % bus_sz)) begin
        
%000000              return 1;
                   end
        
                 end
%000000          else begin
%000000            if ( (next_lsb - (this_lsb + this_sz)) >= (next_lsb % bus_sz) &&
%000000            ((this_lsb - (prev_lsb + prev_sz)) >= (this_lsb % bus_sz)) ) begin
        
%000000              return 1;
                   end
        
                 end
               end
             end
           end
        
           `uvm_warning("RegModel",
               {"Field '", get_full_name(),"' is not the only field within the entire bus width. ",
               "Individual field access will not be available. ",
%000000        "Accessing complete register instead."})
        
%000000    return 0;
        
        endfunction
        
        
        // poke
        
%000000 task uvm_reg_field::poke(output uvm_status_e      status,
                                 input  uvm_reg_data_t    value,
                                 input  string            kind = "",
                                 input  uvm_sequence_base parent = null,
                                 input  uvm_object        extension = null,
                                 input  string            fname = "",
                                 input  int               lineno = 0);
%000000    uvm_reg_data_t  tmp;
        
%000000    m_fname = fname;
%000000    m_lineno = lineno;
%000000    if ($isunknown(value >> m_size)) begin
             `uvm_warning("RegModel",
             {"uvm_reg_field::poke(): Has unknown bits that can allow for a value that exceeds size of field '",
%000000      get_name(),"'"})
%000000      value &= value & ((1<<m_size)-1);
           end
%000000    else if (value >> m_size) begin
             `uvm_warning("RegModel",
             {"uvm_reg_field::poke(): Value exceeds size of field '",
%000000      get_name(),"'"})
%000000      value &= value & ((1<<m_size)-1);
           end
        
        
%000000    m_parent.XatomicX(1);
%000000    m_parent.m_is_locked_by_field = 1'b1;
        
%000000    tmp = 0;
        
           // What is the current values of the other fields???
%000000    m_parent.peek(status, tmp, kind, parent, extension, fname, lineno);
        
%000000    if (status == UVM_NOT_OK) begin
             `uvm_error("RegModel", {"uvm_reg_field::poke(): Peek of register '",
%000000      m_parent.get_full_name(),"' returned status ",status.name()})
%000000      m_parent.XatomicX(0);
%000000      m_parent.m_is_locked_by_field = 1'b0;
%000000      return;
           end
        
           // Force the value for this field then poke the resulting value
%000000    tmp &= ~(((1<<m_size)-1) << m_lsb);
%000000    tmp |= value << m_lsb;
%000000    m_parent.poke(status, tmp, kind, parent, extension, fname, lineno);
        
%000000    m_parent.XatomicX(0);
%000000    m_parent.m_is_locked_by_field = 1'b0;
        endtask: poke
        
        
        // peek
        
%000000 task uvm_reg_field::peek(output uvm_status_e      status,
%000000                          output uvm_reg_data_t    value,
                                 input  string            kind = "",
                                 input  uvm_sequence_base parent = null,
                                 input  uvm_object        extension = null,
                                 input  string            fname = "",
                                 input  int               lineno = 0);
%000000    uvm_reg_data_t  reg_value;
        
%000000    m_fname = fname;
%000000    m_lineno = lineno;
        
%000000    m_parent.peek(status, reg_value, kind, parent, extension, fname, lineno);
%000000    value = (reg_value >> m_lsb) & ((1<<m_size))-1;
        
        endtask: peek
        
        
        // mirror
        
%000000 task uvm_reg_field::mirror(output uvm_status_e      status,
                                   input  uvm_check_e       check = UVM_NO_CHECK,
                                   input  uvm_door_e        path = UVM_DEFAULT_DOOR,
                                   input  uvm_reg_map       map = null,
                                   input  uvm_sequence_base parent = null,
                                   input  int               prior = -1,
                                   input  uvm_object        extension = null,
                                   input  string            fname = "",
                                   input  int               lineno = 0);
%000000    m_fname = fname;
%000000    m_lineno = lineno;
%000000    m_parent.mirror(status, check, path, map, parent, prior, extension,
%000000                       fname, lineno);
        endtask: mirror
        
        
        // set_compare
        
%000000 function void uvm_reg_field::set_compare(uvm_check_e check=UVM_CHECK);
%000000   m_check = check;
        endfunction
        
        
        // get_compare
        
%000000 function uvm_check_e uvm_reg_field::get_compare();
%000000   return m_check;
        endfunction
        
        // pre_randomize
        
%000000 function void uvm_reg_field::pre_randomize();
           // Update the only publicly known property with the current
           // desired value so it can be used as a state variable should
           // the rand_mode of the field be turned off.
%000000    value = m_desired;
        endfunction: pre_randomize
        
        
        // post_randomize
        
%000000 function void uvm_reg_field::post_randomize();
%000000    m_desired = value;
        endfunction: post_randomize
        
        
        // do_print
        
%000000 function void uvm_reg_field::do_print (uvm_printer printer);
%000000   printer.print_generic(get_name(), get_type_name(), -1, convert2string());
        endfunction
        
        
        // convert2string
        
%000000 function string uvm_reg_field::convert2string();
%000000    string fmt;
%000000    string res_str;
%000000    string t_str;
%000000    bit with_debug_info;
%000000    string prefix;
%000000    uvm_reg reg_=get_register();
        
%000000    $sformat(fmt, "%0d'h%%%0dh", get_n_bits(),
%000000             (get_n_bits()-1)/4 + 1);
%000000    $sformat(convert2string, {"%s %s %s[%0d:%0d]=",fmt,"%s"}, prefix,
%000000             get_access(),
%000000             reg_.get_name(),
%000000             get_lsb_pos() + get_n_bits() - 1,
%000000             get_lsb_pos(), m_desired,
%000000             (m_desired !== m_mirrored) ? $sformatf({" (Mirror: ",fmt,")"},
                       m_mirrored) : "");
        
%000000    if (m_read_in_progress == 1'b1) begin
%000000      if (m_fname != "" && m_lineno != 0) begin
        
%000000        $sformat(res_str, " from %s:%0d",m_fname, m_lineno);
             end
        
%000000      convert2string = {convert2string, "\n", "currently being read", res_str};
           end
%000000    if (m_write_in_progress == 1'b1) begin
%000000      if (m_fname != "" && m_lineno != 0) begin
        
%000000        $sformat(res_str, " from %s:%0d",m_fname, m_lineno);
             end
        
%000000      convert2string = {convert2string, "\n", res_str, "currently being written"};
           end
        endfunction: convert2string
        
        
        // clone
        
%000000 function uvm_object uvm_reg_field::clone();
%000000   `uvm_fatal("RegModel","RegModel field cannot be cloned")
%000000   return null;
        endfunction
        
        // do_copy
        
%000000 function void uvm_reg_field::do_copy(uvm_object rhs);
%000000   `uvm_warning("RegModel","RegModel field copy not yet implemented")
          // just a set(rhs.get()) ?
        endfunction
        
        
        // do_compare
        
%000000 function bit uvm_reg_field::do_compare (uvm_object  rhs,
                                                uvm_comparer comparer);
%000000   `uvm_warning("RegModel","RegModel field compare not yet implemented")
          // just a return (get() == rhs.get()) ?
%000000   return 0;
        endfunction
        
        
        // do_pack
        
%000000 function void uvm_reg_field::do_pack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel field cannot be packed")
        endfunction
        
        
        // do_unpack
        
%000000 function void uvm_reg_field::do_unpack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel field cannot be unpacked")
        endfunction
        
