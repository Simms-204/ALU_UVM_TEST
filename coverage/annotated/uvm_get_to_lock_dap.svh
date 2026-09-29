//      // verilator_coverage annotation
        // 
        //------------------------------------------------------------------------------
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        //   All Rights Reserved Worldwide
        //
        //   Licensed under the Apache License, Version 2.0 (the
        //   "License"); you may not use this file except in
        //   compliance with the License.  You may obtain a copy of
        //   the License at
        //
        //       http://www.apache.org/licenses/LICENSE-2.0
        //
        //   Unless required by applicable law or agreed to in
        //   writing, software distributed under the License is
        //   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
        //   CONDITIONS OF ANY KIND, either express or implied.  See
        //   the License for the specific language governing
        //   permissions and limitations under the License.
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/dap/uvm_get_to_lock_dap.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        // Class -- NODOCS -- uvm_get_to_lock_dap
        // Provides a 'Get-To-Lock' Data Access Policy.
        //
        // The 'Get-To-Lock' Data Access Policy allows for any number of 'sets',
        // until the value is retrieved via a 'get'.  Once 'get' has been called, 
        // it is illegal to 'set' a new value.
        //
        // The UVM uses this policy to protect the ~starting phase~ and ~automatic objection~
        // values in <uvm_sequence_base>.
        //
        
        class uvm_get_to_lock_dap#(type T=int) extends uvm_set_get_dap_base#(T);
        
           // Used for self-references
           typedef uvm_get_to_lock_dap#(T) this_type;
           
           // Parameterized Utils
%000000    `uvm_object_param_utils(uvm_get_to_lock_dap#(T))
           
           // Stored data
           local T m_value;
        
           // Lock state
           local bit m_locked;
        
           // Function -- NODOCS -- new
           // Constructor
%000006    function new(string name="unnamed-uvm_get_to_lock_dap#(T)");
%000006       super.new(name);
%000006       m_locked = 0;
           endfunction : new
        
           // Group -- NODOCS -- Set/Get Interface
           
           // Function -- NODOCS -- set
           // Updates the value stored within the DAP.
           //
           // ~set~ will result in an error if the value has
           // already been retrieved via a call to ~get~.
%000003    virtual function void set(T value);
%000003       if (m_locked) begin
                `uvm_error("UVM/GET_TO_LOCK_DAP/SAG",
                $sformatf("Attempt to set new value on '%s', but the data access policy forbids setting after a get!",
%000000         get_full_name()))
              end
%000003       else begin
%000003         m_value = value;
              end
           endfunction : set
        
           // Function -- NODOCS -- try_set
           // Attempts to update the value stored within the DAP.
           //
           // ~try_set~ will return a 1 if the value was successfully
           // updated, or a '0' if the value cannot be updated due
           // to ~get~ having been called.  No errors will be reported
           // if ~try_set~ fails.
%000000    virtual function bit try_set(T value);
%000000       if (m_locked) begin
                
%000000         return 0;
              end
        
%000000       else begin
%000000         m_value = value;
%000000         return 1;
              end
           endfunction : try_set
           
           // Function -- NODOCS -- get
           // Returns the current value stored within the DAP, and 'locks' the DAP.
           //
           // After a 'get', the value contained within the DAP cannot
           // be changed.
%000009    virtual  function T get();
%000009       m_locked = 1;
%000009       return m_value;
           endfunction : get
        
           // Function -- NODOCS -- try_get
           // Retrieves the current value stored within the DAP, and 'locks' the DAP.
           //
           // ~try_get~ will always return 1.
%000000    virtual function bit try_get(output T value);
%000000       value = get();
%000000       return 1;
           endfunction : try_get
        
           // Function -- NODOCS -- is_locked
           // Returns the state of the lock.
           //
           // Returns:
           // 1 - The value is locked
           // 0 - The value is unlocked
%000000    function bit is_locked();
%000000       return m_locked;
           endfunction : is_locked
           
           // Group -- NODOCS -- Introspection
           //
           // The ~uvm_get_to_lock_dap~ cannot support the standard UVM
           // instrumentation methods (~copy~, ~clone~, ~pack~ and
           // ~unpack~), due to the fact that they would potentially 
           // violate the access policy.
           //  
           // A call to any of these methods will result in an error.
        
%000000    virtual function void do_copy(uvm_object rhs);
              `uvm_error("UVM/GET_TO_LOCK_DAP/CPY",
%000000                  "'copy()' is not supported for 'uvm_get_to_lock_dap#(T)'")
           endfunction : do_copy
        
%000000    virtual function void do_pack(uvm_packer packer);
              `uvm_error("UVM/GET_TO_LOCK_DAP/PCK",
%000000                  "'pack()' is not supported for 'uvm_get_to_lock_dap#(T)'")
           endfunction : do_pack
        
%000000    virtual function void do_unpack(uvm_packer packer);
              `uvm_error("UVM/GET_TO_LOCK_DAP/UPK",
%000000                  "'unpack()' is not supported for 'uvm_get_to_lock_dap#(T)'")
           endfunction : do_unpack
        
           // Group- Reporting
           
           // Function- convert2string
%000000    virtual function string convert2string();
%000000       if (m_locked) begin
                
%000000         return $sformatf("(%s) %0p [LOCKED]", `uvm_typename(m_value), m_value);
              end
        
%000000       else begin
                
%000000         return $sformatf("(%s) %0p [UNLOCKED]", `uvm_typename(m_value), m_value);
              end
        
           endfunction : convert2string
           
           // Function- do_print
%000000    virtual function void do_print(uvm_printer printer);
%000000       super.do_print(printer);
%000000       printer.print_field_int("lock_state", m_locked, $bits(m_locked));
%000000       printer.print_generic("value", 
%000000                             `uvm_typename(m_value), 
%000000                             0, 
%000000                             $sformatf("%0p", m_value));
              
           endfunction : do_print
        
        endclass // uvm_get_to_lock_dap
        
