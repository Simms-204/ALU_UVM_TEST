//      // verilator_coverage annotation
        //
        //-----------------------------------------------------------------------------
        // Copyright 2012 AMD
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017-2018 Cisco Systems, Inc.
        // Copyright 2022 Marvell International Ltd.
        // Copyright 2007-2022 Mentor Graphics Corporation
        // Copyright 2013-2026 NVIDIA Corporation
        // Copyright 2025 Qualcomm, Inc.
        // Copyright 2011-2018 Synopsys, Inc.
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
        //-----------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_recorder.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_report_message;
        
        // File -- NODOCS -- UVM Recorders
        //
        // The uvm_recorder class serves two purposes:
        //  - Firstly, it is an abstract representation of a record within a
        //    <uvm_tr_stream>.
        //  - Secondly, it is a policy object for recording fields ~into~ that
        //    record within the ~stream~.
        //
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_recorder
        //
        // Abstract class which defines the ~recorder~ API.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 16.4.1
        virtual class uvm_recorder extends uvm_policy;
        
%000000    `uvm_object_abstract_utils(uvm_recorder)
        
          // Variable- m_stream_dap
          // Data access protected reference to the stream
          local uvm_set_before_get_dap#(uvm_tr_stream) m_stream_dap;
        
          // Variable- m_warn_null_stream
          // Used to limit the number of warnings 
          local bit m_warn_null_stream;
        
          // Variable- m_is_opened
          // Used to indicate recorder is open
          local bit m_is_opened;
           
          // Variable- m_is_closed
          // Used to indicate recorder is closed
          local bit m_is_closed;
        
          // !m_is_opened && !m_is_closed == m_is_freed
        
          // Variable- m_open_time
          // Used to store the open_time
          local time m_open_time;
        
          // Variable- m_close_time
          // Used to store the close_time
          local time m_close_time;
           
          // Variable- recording_depth
          int recording_depth;
        
          // Variable -- NODOCS -- default_radix
          //
          // This is the default radix setting if <record_field> is called without
          // a radix.
        
          // @uvm-compat
%000000   uvm_radix_enum default_radix = UVM_HEX;
        
          // Variable -- NODOCS -- identifier
          //
          // This bit is used to specify whether or not an object's reference should be
          // recorded when the object is recorded.
        
          // @uvm-compat
%000000   bit identifier = 1;
        
          //@uvm-compat
%000000   bit physical = 1;
        
          //@uvm-compat
%000000   bit abstract = 1 ;
          
          //@uvm-compat
          uvm_tr_handle_t tr_handle;
          
           uvm_policy::recursion_state_e m_recur_states[uvm_object][uvm_recursion_policy_enum /*recursion*/] ;
           
        
          // Variable -- NODOCS -- recursion_policy
          //
          // Sets the recursion policy for recording objects. 
          //
          // The default policy is deep (which means to recurse an object).
        
          // @uvm-compat for compatibility with 1.2
%000000   uvm_recursion_policy_enum policy = UVM_DEFAULT_POLICY;
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.1
%000000   virtual function void set_recursion_policy(uvm_recursion_policy_enum policy);
%000000     this.policy  = policy;
          endfunction : set_recursion_policy
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.1
%000000   virtual function uvm_recursion_policy_enum get_recursion_policy();
%000000     return this.policy;
          endfunction : get_recursion_policy
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.2
%000000   virtual function void set_id_enabled(bit enabled);
%000000     this.identifier = enabled;
          endfunction : set_id_enabled
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.2
%000000   virtual function bit get_id_enabled();
%000000     return this.identifier;
          endfunction : get_id_enabled
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.3
%000000   virtual function void set_default_radix(uvm_radix_enum radix);
%000000     this.default_radix = radix;
          endfunction : set_default_radix
        
          // @uvm-ieee 1800.2-2020 auto 16.4.2.3
%000000   virtual function uvm_radix_enum get_default_radix();
%000000     return this.default_radix;
          endfunction : get_default_radix
        
          // @uvm-ieee 1800.2-2020 auto 16.4.4.1
%000000   virtual function void flush();
%000000     policy      = UVM_DEFAULT_POLICY;
%000000     identifier  = 1;
%000000     free();
%000000     m_recur_states.delete();
          endfunction : flush
        
           // Variable- m_ids_by_recorder
           // An associative array of uvm_tr_handle_t, indexed by uvm_recorders.  This
           // provides a unique 'id' or 'handle' for each recorder, which can be
           // used to identify the recorder.
           //
           // By default, neither ~m_ids_by_recorder~ or ~m_recorders_by_id~ are
           // used.  Recorders are only placed in the arrays when the user
           // attempts to determine the id for a recorder.
           local static uvm_tr_handle_t m_ids_by_recorder[uvm_recorder];
        
        
%000000   function new(string name = "uvm_recorder");
%000000      super.new(name);
%000000      m_stream_dap = new("stream_dap");
%000000      m_warn_null_stream = 1;
          endfunction
        
           // Group -- NODOCS -- Configuration API
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.3
%000000    function uvm_tr_stream get_stream();
%000000       if (!m_stream_dap.try_get(get_stream)) begin
%000000         if (m_warn_null_stream == 1) begin
                  `uvm_warning("UVM/REC/NO_CFG",
                  $sformatf("attempt to retrieve STREAM from '%s' before it was set!",
%000000           get_name()))
                end
%000000         m_warn_null_stream = 0;
              end
           endfunction : get_stream
        
           // Group -- NODOCS -- Transaction Recorder API
           //
           // Once a recorder has been opened via <uvm_tr_stream::open_recorder>, the user
           // can ~close~ the recorder.
           //
           // Due to the fact that many database implementations will require crossing
           // a language boundary, an additional step of ~freeing~ the recorder is required.
           //
           // A ~link~ can be established within the database any time between ~open~ and
           // ~free~, however it is illegal to establish a link after ~freeing~ the recorder.
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.2
%000000    function void close(time close_time = 0);
%000000       if (close_time == 0) begin
                
%000000         close_time = $realtime;
              end
        
        
%000000       if (!is_open()) begin
                
%000000         return;
              end
        
        
%000000       do_close(close_time);
              
%000000       m_is_opened = 0;
%000000       m_is_closed = 1;
%000000       m_close_time = close_time;
           endfunction : close
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.3
%000000    function void free(time close_time = 0);
%000000        process p=process::self();
%000000        string s;
            
%000000        uvm_tr_stream stream;
               
%000000       if (!is_open() && !is_closed()) begin
                
%000000         return;
              end
        
        
%000000       if (is_open()) begin
%000000         close(close_time);
              end
        
%000000       do_free();
        
              // Clear out internal state
%000000       stream = get_stream();
              
%000000       m_is_closed = 0;
%000000       if(p != null) begin
                  
%000000         s=p.get_randstate();
              end
        
%000000       m_stream_dap = new("stream_dap");
%000000       if(p != null) begin
                  
%000000         p.set_randstate(s);
              end
        
%000000       m_warn_null_stream = 1;
%000000       if (m_ids_by_recorder.exists(this)) begin
                
%000000         m_free_id(m_ids_by_recorder[this]);
              end
        
        
              // Clear out stream state
%000000       if (stream != null) begin
                
%000000         stream.m_free_recorder(this);
              end
        
           endfunction : free
              
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.4
%000000    function bit is_open();
%000000       return m_is_opened;
           endfunction : is_open
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.5
%000000    function time get_open_time();
%000000       return m_open_time;
           endfunction : get_open_time
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.6
%000000    function bit is_closed();
%000000       return m_is_closed;
           endfunction : is_closed
            
        
           // @uvm-ieee 1800.2-2020 auto 16.4.4.7
%000000    function time get_close_time();
%000000       return m_close_time;
           endfunction : get_close_time
        
          // Function- m_do_open
          // Initializes the internal state of the recorder.
          //
          // Parameters -- NODOCS --
          // stream - The stream which spawned this recorder
          //
          // This method will trigger a <do_open> call.
          //
          // An error will be asserted if:
          // - ~m_do_open~ is called more than once without the
          //  recorder being ~freed~ in between.
          // - ~stream~ is ~null~
%000000   function void m_do_open(uvm_tr_stream stream, time open_time, string type_name);
%000000      uvm_tr_stream m_stream;
%000000      if (stream == null) begin
               `uvm_error("UVM/REC/NULL_STREAM",
               $sformatf("Illegal attempt to set STREAM for '%s' to '<null>'",
%000000        this.get_name()))
%000000        return;
             end
        
%000000      if (m_stream_dap.try_get(m_stream)) begin
               `uvm_error("UVM/REC/RE_INIT",
               $sformatf("Illegal attempt to re-initialize '%s'",
%000000        this.get_name()))
%000000        return;
             end
        
%000000      m_stream_dap.set(stream);
%000000      m_open_time = open_time;
%000000      m_is_opened = 1;
             
%000000      do_open(stream, open_time, type_name);
          endfunction : m_do_open
        
           // Group -- NODOCS -- Handles
        
        
           // Variable- m_recorders_by_id
           // A corollary to ~m_ids_by_recorder~, this indexes the recorders by their
           // unique ids.
           local static uvm_recorder m_recorders_by_id[uvm_tr_handle_t];
        
           // Variable- m_id
           // Static int marking the last assigned id.
           local static int m_id;
        
           // Function- m_free_id
           // Frees the id/recorder link (memory cleanup)
           //
%000000    static function void m_free_id(uvm_tr_handle_t id);
%000000       uvm_recorder recorder;
%000000       if ((!$isunknown(id)) && (m_recorders_by_id.exists(id))) begin
                
%000000         recorder = m_recorders_by_id[id];
              end
        
        
%000000       if (recorder != null) begin
%000000         m_recorders_by_id.delete(id);
%000000         m_ids_by_recorder.delete(recorder);
              end
           endfunction : m_free_id
                    
        
           // @uvm-ieee 1800.2-2020 auto 16.4.5.1
%000000    function uvm_tr_handle_t get_handle();
%000000       if (!is_open() && !is_closed()) begin
%000000         return 0;
              end
%000000       else begin
%000000         uvm_tr_handle_t handle = get_inst_id();
        
                // Check for the weird case where our handle changed.
%000000         if (m_ids_by_recorder.exists(this) && m_ids_by_recorder[this] != handle) begin
                   
%000000           m_recorders_by_id.delete(m_ids_by_recorder[this]);
                end
        
                   
%000000         m_recorders_by_id[handle] = this;
%000000         m_ids_by_recorder[this] = handle;
        
%000000         return handle;
              end
           endfunction : get_handle
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.5.2
%000003    static function uvm_recorder get_recorder_from_handle(uvm_tr_handle_t id);
%000000       if (id == 0) begin
                
%000000         return null;
              end
        
        
%000000       if (($isunknown(id)) || (!m_recorders_by_id.exists(id))) begin
                
%000000         return null;
              end
        
        
%000003       return m_recorders_by_id[id];
           endfunction : get_recorder_from_handle
        
           // Group -- NODOCS -- Attribute Recording
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.1
%000000    function void record_field(string name,
                                      uvm_bitstream_t value,
                                      int size,
                                      uvm_radix_enum radix=UVM_NORADIX);
%000000       if (get_stream() == null) begin
%000000         return;
              end
%000000       do_record_field(name, value, size, radix);
           endfunction : record_field
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.2
%000000    function void record_field_int(string name,
                                          uvm_integral_t value,
                                          int size,
                                          uvm_radix_enum radix=UVM_NORADIX);
%000000         if (get_stream() == null) begin
%000000           return;
                end
%000000       do_record_field_int(name, value, size, radix);
           endfunction : record_field_int
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.3
%000000    function void record_field_real(string name,
                                           real value);
%000000       if (get_stream() == null) begin
%000000         return;
              end
%000000       do_record_field_real(name, value);
           endfunction : record_field_real
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.4
%000000    function void record_object(string name,
                                       uvm_object value);
%000000       if (get_stream() == null) begin
%000000         return;
              end
        
%000000       if (value == null) begin
                
%000000         do_record_object(name, value);
              end
        
%000000       else begin
%000000         push_active_object(value);
%000000         m_recur_states[value][get_recursion_policy()] = uvm_policy::STARTED ;
%000000         do_record_object(name, value);
%000000         m_recur_states[value][get_recursion_policy()] = uvm_policy::FINISHED ;
%000000         void'(pop_active_object());
              end
           endfunction : record_object
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.5
%000000    function void record_string(string name,
                                       string value);
%000000       if (get_stream() == null) begin
%000000         return;
              end
        
%000000       do_record_string(name, value);
           endfunction : record_string
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.6
%000000    function void record_time(string name,
                                     time value);
%000000       if (get_stream() == null) begin
%000000         return;
              end
        
%000000       do_record_time(name, value);
           endfunction : record_time
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.7
%000000    function void record_generic(string name,
                                        string value,
                                        string type_name="");
%000000       if (get_stream() == null) begin
%000000         return;
              end
        
%000000       do_record_generic(name, value, type_name);
           endfunction : record_generic
        
        
          // @uvm-ieee 1800.2-2020 auto 16.4.6.8
%000000   virtual function bit use_record_attribute();
%000000      return 0;
          endfunction : use_record_attribute
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.6.9
%000000    virtual function uvm_tr_handle_t get_record_attribute_handle();
%000000       return get_handle();
           endfunction : get_record_attribute_handle
           
           // Group -- NODOCS -- Implementation Agnostic API
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.1
%000000    protected virtual function void do_open(uvm_tr_stream stream,
                                                     time open_time,
                                                     string type_name);
           endfunction : do_open
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.2
%000000    protected virtual function void do_close(time close_time);
           endfunction : do_close
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.3
%000000    protected virtual function void do_free();
           endfunction : do_free
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.4
%000000    pure virtual protected function void do_record_field(string name,
                                                                uvm_bitstream_t value,
                                                                int size,
                                                                uvm_radix_enum radix);
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.5
%000000    pure virtual protected function void do_record_field_int(string name,
                                                                    uvm_integral_t value,
                                                                    int          size,
                                                                    uvm_radix_enum radix);
           
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.6
%000000    pure virtual protected function void do_record_field_real(string name,
                                                                     real value);
        
        
           // Function : do_record_object
           // The library implements do_record_object as virtual even though the LRM
           // calls for pure virtual. Mantis 6591 calls for the LRM to move to
           // virtual.  The implemented signature is:
           // virtual protected function void do_record_object(string name, uvm_object value);
          
           // @uvm-ieee 1800.2-2020 auto 16.4.7.7
%000000    virtual protected function void do_record_object(string name,
                                                            uvm_object value);
%000000      if ((get_recursion_policy() != UVM_REFERENCE) &&
%000000          (value != null)) begin
%000000        uvm_field_op field_op = uvm_field_op::m_get_available_op();
%000000        field_op.set(UVM_RECORD, this, null);
%000000        value.do_execute_op(field_op);
%000000        if (field_op.user_hook_enabled()) begin
                 
%000000          value.do_record(this);
               end
        
%000000        field_op.m_recycle();
             end
           endfunction : do_record_object
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.8
%000000    virtual function uvm_policy::recursion_state_e object_recorded ( uvm_object value,
                                                                            uvm_recursion_policy_enum recursion);
        
%000000       if (!m_recur_states.exists(value)) begin
%000000         return NEVER ;
              end
        
%000000       if (!m_recur_states[value].exists(recursion)) begin
%000000         return NEVER ;
              end
        
%000000       else begin
%000000         return m_recur_states[value][recursion] ;
              end
        
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.9
%000000    pure virtual protected function void do_record_string(string name,
                                                                 string value);
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.10
%000000    pure virtual protected function void do_record_time(string name,
                                                               time value);
        
        
           // @uvm-ieee 1800.2-2020 auto 16.4.7.11
%000000    pure virtual protected function void do_record_generic(string name,
                                                                  string value,
                                                                  string type_name);
        
        
           // The following code is primarily for backwards compat. purposes.  "Transaction
           // Handles" are useful when connecting to a backend, but when passing the information
           // back and forth within simulation, it is safer to user the ~recorder~ itself
           // as a reference to the transaction within the database.
        
           //------------------------------
           // Group- Vendor-Independent API
           //------------------------------
        
        
          // UVM provides only a text-based default implementation.
          // Vendors provide subtype implementations and overwrite the
          // <uvm_default_recorder> handle.
        
        
          // Function- open_file
          //
          // Opens the file in the <filename> property and assigns to the
          // file descriptor <file>.
          //
%000000   virtual function bit open_file();
%000000      return 0;
          endfunction
        
          // Function- create_stream
          //
          //
%000000   virtual function integer create_stream (string name,
                                                  string t,
                                                  string scope);
%000000      return -1;
          endfunction
        
           
          // Function- m_set_attribute
          //
          //
%000000   virtual function void m_set_attribute (int txh,
                                         string nm,
                                         string value);
          endfunction
          
          
          // Function- set_attribute
          //
%000000   virtual function void set_attribute (int txh,
                                       string nm,
                                       logic [1023:0] value,
                                       uvm_radix_enum radix,
                                       int numbits=1024);
          endfunction
          
          
          // Function- check_handle_kind
          //
          //
%000000   virtual function int check_handle_kind (string htype, uvm_tr_handle_t handle);
%000000      return 0;
          endfunction
          
          
          // Function- begin_tr
          //
          //
%000000   virtual function uvm_tr_handle_t begin_tr(string txtype,
                                                    int stream,
                                                    string nm,
                                                    string label="",
                                                    string desc="",
                                                    time begin_time=0);
%000000     return -1;
          endfunction
          
          
          // Function- end_tr
          //
          //
%000000   virtual function void end_tr (uvm_tr_handle_t handle, time end_time=0);
          endfunction
          
          
          // Function- link_tr
          //
          //
%000000   virtual function void link_tr(int h1,
                                         int h2,
                                         string relation="");
          endfunction
          
          
          
          // Function- free_tr
          //
          //
%000000   virtual function void free_tr(uvm_tr_handle_t handle);
          endfunction
          
        endclass // uvm_recorder
        
        //------------------------------------------------------------------------------
        //
        // CLASS: uvm_text_recorder
        //
        // The ~uvm_text_recorder~ is the default recorder implementation for the
        // <uvm_text_tr_database>.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
          
        class uvm_text_recorder extends uvm_recorder;
        
%000000    `uvm_object_utils(uvm_text_recorder)
        
           // Variable- m_text_db
           //
           // Reference to the text database backend
           uvm_text_tr_database m_text_db;
        
           // Function --NODOCS-- new
           // Constructor
           //
           // Parameters --NODOCS--
           // name - Instance name
%000000    function new(string name="unnamed-uvm_text_recorder");
%000000       super.new(name);
           endfunction : new
        
           // Group --NODOCS-- Implementation Agnostic API
        
           // Function --NODOCS-- do_open
           // Callback triggered via <uvm_tr_stream::open_recorder>.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_open(uvm_tr_stream stream,
                                                     time open_time,
                                                     string type_name);
%000000       $cast(m_text_db, stream.get_db());
%000000       if (m_text_db.open_db()) begin
                
%000000         $fdisplay(m_text_db.m_file, 
                          "    OPEN_RECORDER @%0t {TXH:%0d STREAM:%0d NAME:%s TIME:%0t TYPE=\"%0s\"}",
%000000                   $realtime,
%000000                   this.get_handle(),
%000000                   stream.get_handle(),
%000000                   this.get_name(),
%000000                   open_time,
%000000                   type_name);
              end
        
           endfunction : do_open
        
           // Function --NODOCS-- do_close
           // Callback triggered via <uvm_recorder::close>.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_close(time close_time);
%000000       if (m_text_db.open_db()) begin
%000000         $fdisplay(m_text_db.m_file, 
                           "    CLOSE_RECORDER @%0t {TXH:%0d TIME=%0t}",
%000000                    $realtime,
%000000                    this.get_handle(),
%000000                    close_time);
                 
              end
           endfunction : do_close
        
           // Function --NODOCS-- do_free
           // Callback triggered via <uvm_recorder::free>.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_free();
%000000       if (m_text_db.open_db()) begin
%000000         $fdisplay(m_text_db.m_file, 
                           "    FREE_RECORDER @%0t {TXH:%0d}",
%000000                    $realtime,
%000000                    this.get_handle());
              end
%000000       m_text_db = null;
           endfunction : do_free
           
           // Function --NODOCS-- do_record_field
           // Records an integral field (less than or equal to 4096 bits).
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_record_field(string name,
                                                           uvm_bitstream_t value,
                                                           int size,
                                                           uvm_radix_enum radix);
%000000       if(radix == UVM_NORADIX) begin
                
%000000         radix = get_default_radix();
              end
        
        
%000000       write_attribute(m_current_context(name),
%000000                       value,
%000000                       radix,
%000000                       size);
        
           endfunction : do_record_field
          
           
           // Function --NODOCS-- do_record_field_int
           // Records an integral field (less than or equal to 64 bits).
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_record_field_int(string name,
                                                               uvm_integral_t value,
                                                               int          size,
                                                               uvm_radix_enum radix);
%000000       if(radix == UVM_NORADIX) begin
                
%000000         radix = get_default_radix();
              end
        
        
%000000       write_attribute_int(m_current_context(name),
%000000                           value,
%000000                           radix,
%000000                           size);
        
           endfunction : do_record_field_int
        
        
           // Function --NODOCS-- do_record_field_real
           // Record a real field.
           //
           // Text-backened specific implementation.
%000000    protected virtual function void do_record_field_real(string name,
                                                                real value);
%000000       bit [63:0] ival = $realtobits(value);
        
%000000       write_attribute_int(m_current_context(name),
%000000                           ival,
%000000                           UVM_REAL,
%000000                           64);
           endfunction : do_record_field_real
        
          // Stores the passed-in names of the objects in the hierarchy
          local string m_object_names[$];
%000000   local function string m_current_context(string name="");
%000000     if (m_object_names.size()  == 0) begin
              
%000000       return name;
            end
         //??
%000000     else if ((m_object_names.size() == 1) && (name=="")) begin
              
%000000       return m_object_names[0];
            end
        
%000000     else begin
%000000       string     full_name;
%000000       foreach(m_object_names[i]) begin
%000000         if (i == m_object_names.size() - 1) begin
                  
%000000           full_name = {full_name, m_object_names[i]};
                end
        
%000000         else begin
                  
%000000           full_name  = {full_name, m_object_names[i], "."};
                end
        
              end
%000000       if (name != "") begin
                
%000000         return {full_name, ".", name};
              end
        
%000000       else begin
                
%000000         return full_name;
              end
        
            end
          endfunction : m_current_context
        
          
           // Function --NODOCS-- do_record_object
           // Record an object field.
           //
           // Text-backend specific implementation.
           //
           // The method uses ~identifier~ to determine whether or not to
           // record the object instance id, and ~recursion_policy~ to
           // determine whether or not to recurse into the object.
%000000    protected virtual function void do_record_object(string name,
                                                            uvm_object value);
%000000       int            v;
%000000       string         str;
        
%000000       if(get_id_enabled()) begin
%000000         if(value != null) begin
%000000           v = value.get_inst_id();
                end
%000000         write_attribute_int("inst_id", 
%000000                              v, 
%000000                              UVM_DEC, 
%000000                              32);
              end
        
%000000       if (get_active_object_depth() > 1) begin
                
%000000         m_object_names.push_back(name);
              end
        
%000000       super.do_record_object(name, value);
%000000       if (get_active_object_depth() > 1) begin
                
%000000         void'(m_object_names.pop_back());
              end
        
           endfunction : do_record_object
        
           // Function --NODOCS-- do_record_string
           // Records a string field.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_record_string(string name,
                                                            string value);
%000000       if (m_text_db.open_db()) begin
%000000         $fdisplay(m_text_db.m_file, 
                           "      SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s   RADIX:%s BITS=%0d}",
%000000                    $realtime,
%000000                    this.get_handle(),
%000000                    m_current_context(name),
%000000                    value,
%000000                    "UVM_STRING",
%000000                    8+value.len());
              end
           endfunction : do_record_string
        
           // Function --NODOCS-- do_record_time
           // Records a time field.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_record_time(string name,
                                                            time value);
%000000       write_attribute_int(m_current_context(name), 
%000000                           value,
%000000                           UVM_TIME, 
%000000                           64);
           endfunction : do_record_time
        
           // Function --NODOCS-- do_record_generic
           // Records a name/value pair, where ~value~ has been converted to a string.
           //
           // Text-backend specific implementation.
%000000    protected virtual function void do_record_generic(string name,
                                                             string value,
                                                             string type_name);
%000000       write_attribute(m_current_context(name), 
%000000                       uvm_string_to_bits(value), 
%000000                       UVM_STRING, 
%000000                       8+value.len());
           endfunction : do_record_generic
        
           // Group: Implementation Specific API
           
           // Function: write_attribute
           // Outputs a <uvm_bitstream_t> attribute to the textual log.
           //
           // Parameters:
           // nm - Name of the attribute
           // value - Value 
           // radix - Radix of the output
           // numbits - number of valid bits
           //
           // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
%000000    function void write_attribute(string nm,
                                         uvm_bitstream_t value,
                                         uvm_radix_enum radix,
                                         int numbits=$bits(uvm_bitstream_t));
%000000       if (m_text_db.open_db()) begin
%000000         $fdisplay(m_text_db.m_file, 
                           "      SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s   RADIX:%s BITS=%0d}",
%000000                    $realtime,
%000000                    this.get_handle(),
%000000                    nm,
%000000                    uvm_bit_vector_utils#(uvm_bitstream_t)::to_string(value, numbits, radix),
%000000                    radix.name(),
%000000                    numbits);
              end
           endfunction : write_attribute
        
           // Function: write_attribute_int
           // Outputs an <uvm_integral_t> attribute to the textual log
           //
           // Parameters:
           // nm - Name of the attribute
           // value - Value
           // radix - Radix of the output
           // numbits - number of valid bits
           //
           // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
%000000    function void write_attribute_int(string  nm,
                                             uvm_integral_t value,
                                             uvm_radix_enum radix,
                                             int numbits=$bits(uvm_bitstream_t));
%000000       if (m_text_db.open_db()) begin
%000000         $fdisplay(m_text_db.m_file, 
                           "      SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s   RADIX:%s BITS=%0d}",
%000000                    $realtime,
%000000                    this.get_handle(),
%000000                    nm,
%000000                    uvm_bit_vector_utils#(uvm_integral_t)::to_string(value, numbits, radix),
%000000                    radix.name(),
%000000                    numbits);
              end
           endfunction : write_attribute_int
        
           /// LEFT FOR BACKWARDS COMPAT ONLY!!!!!!!!
        
           //------------------------------
           // Group- Vendor-Independent API
           //------------------------------
        
        
          // UVM provides only a text-based default implementation.
          // Vendors provide subtype implementations and overwrite the
          // <uvm_default_recorder> handle.
        
           string                                                   filename;
           bit                                                      filename_set;
        
          // Function- open_file
          //
          // Opens the file in the <filename> property and assigns to the
          // file descriptor <file>.
          //
%000000   virtual function bit open_file();
%000000      if (!filename_set) begin
%000000        m_text_db.set_file_name(filename);
             end
%000000      return m_text_db.open_db();
          endfunction
        
        
          // Function- create_stream
          //
          //
%000000   virtual function integer create_stream (string name,
                                                  string t,
                                                  string scope);
%000000      uvm_text_tr_stream stream;
%000000      if (open_file()) begin
%000000        $cast(stream,m_text_db.open_stream(name, scope, t));
%000000        return stream.get_handle();
             end
%000000      return 0;
          endfunction
        
           
          // Function- m_set_attribute
          //
          //
%000000   virtual function void m_set_attribute (int txh,
                                         string nm,
                                         string value);
%000000      if (open_file()) begin
%000000        UVM_FILE file = m_text_db.m_file;
%000000        $fdisplay(file,"      SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s}", $realtime,txh,nm,value);
             end
          endfunction
          
          
          // Function- set_attribute
          //
          //
%000000   virtual function void set_attribute (int txh,
                                       string nm,
                                       logic [1023:0] value,
                                       uvm_radix_enum radix,
                                       int numbits=1024);
%000000      if (open_file()) begin
%000000        UVM_FILE file = m_text_db.m_file;
%000000        $fdisplay(file, 
                           "      SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s   RADIX:%s BITS=%0d}",
%000000                    $realtime,
%000000                    txh,
%000000                    nm,
%000000                    uvm_bit_vector_utils#(uvm_bitstream_t)::to_string(value, numbits, radix),
%000000                    radix.name(),
%000000                    numbits);
                
             end
          endfunction
          
          
          // Function- check_handle_kind
          //
          //
%000000   virtual function int check_handle_kind (string htype, uvm_tr_handle_t handle);
%000000      return ((uvm_recorder::get_recorder_from_handle(handle) != null) ||
%000000              (uvm_tr_stream::get_stream_from_handle(handle) != null));
          endfunction
          
          
          // Function- begin_tr
          //
          //
%000000   virtual function uvm_tr_handle_t begin_tr(string txtype,
                                                    int stream,
                                                    string nm,
                                                    string label="",
                                                    string desc="",
                                                    time begin_time=0);
%000000      if (open_file()) begin
%000000        uvm_tr_stream stream_obj = uvm_tr_stream::get_stream_from_handle(stream);
%000000        uvm_recorder recorder;
          
%000000        if (stream_obj == null) begin
                  
%000000          return -1;
               end
        
        
%000000        recorder = stream_obj.open_recorder(nm, begin_time, txtype);
        
%000000        return recorder.get_handle();
             end
%000000      return -1;
          endfunction
          
          
          // Function- end_tr
          //
          //
%000000   virtual function void end_tr (uvm_tr_handle_t handle, time end_time=0);
%000000      if (open_file()) begin
%000000        uvm_recorder record = uvm_recorder::get_recorder_from_handle(handle);
%000000        if (record != null) begin
%000000          record.close(end_time);
               end
             end
          endfunction
          
          
          // Function- link_tr
          //
          //
%000000   virtual function void link_tr(int h1,
                                         int h2,
                                         string relation="");
%000000     if (open_file()) begin
              
%000000       $fdisplay(m_text_db.m_file,"  LINK @%0t {TXH1:%0d TXH2:%0d RELATION=%0s}", $realtime,h1,h2,relation);
            end
        
          endfunction
          
          
          
          // Function- free_tr
          //
          //
%000000   virtual function void free_tr(uvm_tr_handle_t handle);
%000000      if (open_file()) begin
%000000        uvm_recorder record = uvm_recorder::get_recorder_from_handle(handle);
%000000        if (record != null) begin
%000000          record.free();
               end
             end
          endfunction // free_tr
        
        endclass : uvm_text_recorder
        
