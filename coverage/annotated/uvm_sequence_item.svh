//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014 Cisco Systems, Inc.
        // Copyright 2007-2020 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2013 Synopsys, Inc.
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
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/seq/uvm_sequence_item.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_sequence_base;
        typedef class uvm_sequencer_base;
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_sequence_item
        //
        // The base class for user-defined sequence items and also the base class for
        // the uvm_sequence class. The uvm_sequence_item class provides the basic
        // functionality for objects, both sequence items and sequences, to operate in
        // the sequence mechanism.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 14.1.1
%000000 class uvm_sequence_item extends uvm_transaction;
        
 000783   local      int                m_sequence_id = -1;
          protected  bit                m_use_sequence_info;
 000783   protected  int                m_depth = -1;
          protected  uvm_sequencer_base m_sequencer;
          protected  uvm_sequence_base  m_parent_sequence;
          static     bit issued1,issued2;
          bit        print_sequence_info;
        
        
          // Function -- NODOCS -- new
          //
          // The constructor method for uvm_sequence_item. 
          
          // @uvm-ieee 1800.2-2020 auto 14.1.2.1
 000783   function new (string name = "uvm_sequence_item");
 000783     super.new(name);
          endfunction
        
%000000   function string get_type_name();
%000000     return "uvm_sequence_item";
          endfunction 
        
          // Macro for factory creation
%000000   `uvm_object_registry(uvm_sequence_item, "uvm_sequence_item")
        
        
          // Function- set_sequence_id
        
 001043   function void set_sequence_id(int id);
 001043     m_sequence_id = id;
          endfunction
        
        
          // Function -- NODOCS -- get_sequence_id
          //
          // private
          //
          // Get_sequence_id is an internal method that is not intended for user code.
          // The sequence_id is not a simple integer.  The get_transaction_id is meant
          // for users to identify specific transactions.
          // 
          // These methods allow access to the sequence_item sequence and transaction
          // IDs. get_transaction_id and set_transaction_id are methods on the
          // uvm_transaction base_class. These IDs are used to identify sequences to
          // the sequencer, to route responses back to the sequence that issued a
          // request, and to uniquely identify transactions.
          //
          // The sequence_id is assigned automatically by a sequencer when a sequence
          // initiates communication through any sequencer calls (i.e. `uvm_do_*,
          // wait_for_grant).  A sequence_id will remain unique for this sequence
          // until it ends or it is killed.  However, a single sequence may have
          // multiple valid sequence ids at any point in time.  Should a sequence 
          // start again after it has ended, it will be given a new unique sequence_id.
          //
          // The transaction_id is assigned automatically by the sequence each time a
          // transaction is sent to the sequencer with the transaction_id in its
          // default (-1) value.  If the user sets the transaction_id to any non-default
          // value, that value will be maintained.
          //
          // Responses are routed back to this sequences based on sequence_id. The
          // sequence may use the transaction_id to correlate responses with their
          // requests.
        
 000520   function int get_sequence_id();
 000520     return (m_sequence_id);
          endfunction
        
        
          // Function -- NODOCS -- set_item_context
          //
          // Set the sequence and sequencer execution context for a sequence item
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.2
 000260   function void set_item_context(uvm_sequence_base  parent_seq,
                                         uvm_sequencer_base sequencer = null);
 000260      set_use_sequence_info(1);
~000257      if (parent_seq != null) begin
 000257        set_parent_sequence(parent_seq);
             end
        
~000260      if (sequencer == null && m_parent_sequence != null) begin
%000000        sequencer = m_parent_sequence.get_sequencer();
             end
        
 000260      set_sequencer(sequencer); 
~000257      if (m_parent_sequence != null) begin
 000257        set_depth(m_parent_sequence.get_depth() + 1);
             end
         
 000260      reseed();      
          endfunction
        
        
          // Function -- NODOCS -- set_use_sequence_info
          //
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.3
 000260   function void set_use_sequence_info(bit value);
 000260     m_use_sequence_info = value;
          endfunction
        
        
          // Function -- NODOCS -- get_use_sequence_info
          //
          // These methods are used to set and get the status of the use_sequence_info
          // bit. Use_sequence_info controls whether the sequence information
          // (sequencer, parent_sequence, sequence_id, etc.) is printed, copied, or
          // recorded. When use_sequence_info is the default value of 0, then the
          // sequence information is not used. When use_sequence_info is set to 1,
          // the sequence information will be used in printing and copying.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.3
%000000   function bit get_use_sequence_info();
%000000     return (m_use_sequence_info);
          endfunction
        
        
          // Function -- NODOCS -- set_id_info
          //
          // Copies the sequence_id and transaction_id from the referenced item into
          // the calling item.  This routine should always be used by drivers to
          // initialize responses for future compatibility.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.4
%000000   function void set_id_info(uvm_sequence_item item);
%000000     if (item == null) begin
%000000       uvm_report_fatal(get_full_name(), "set_id_info called with null parameter", UVM_NONE);
            end
%000000     this.set_transaction_id(item.get_transaction_id());
%000000     this.set_sequence_id(item.get_sequence_id());
          endfunction
        
        
          // Function -- NODOCS -- set_sequencer
          //
          // Sets the default sequencer for the sequence to sequencer.  It will take
          // effect immediately, so it should not be called while the sequence is
          // actively communicating with the sequencer.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.6
 000517   virtual function void set_sequencer(uvm_sequencer_base sequencer);
 000517     m_sequencer = sequencer;
 000517     m_set_p_sequencer();
          endfunction
        
        
          // Function -- NODOCS -- get_sequencer
          //
          // Returns a reference to the default sequencer used by this sequence.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.5
 000783   function uvm_sequencer_base get_sequencer();
 000783     return m_sequencer;
          endfunction
        
        
          // Function -- NODOCS -- set_parent_sequence
          //
          // Sets the parent sequence of this sequence_item.  This is used to identify
          // the source sequence of a sequence_item.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.8
 000257   function void set_parent_sequence(uvm_sequence_base parent);
 000257     m_parent_sequence = parent;
          endfunction
        
        
          // Function -- NODOCS -- get_parent_sequence
          //
          // Returns a reference to the parent sequence of any sequence on which this
          // method was called. If this is a parent sequence, the method returns ~null~.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.7
 000807   function uvm_sequence_base get_parent_sequence();
 000807     return (m_parent_sequence);
          endfunction 
        
        
          // Function -- NODOCS -- set_depth
          //
          // The depth of any sequence is calculated automatically.  However, the user
          // may use  set_depth to specify the depth of a particular sequence. This
          // method will override the automatically calculated depth, even if it is
          // incorrect.  
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.10
 000257   function void set_depth(int value);
 000257     m_depth = value;
          endfunction
        
        
          // Function -- NODOCS -- get_depth
          //
          // Returns the depth of a sequence from its parent.  A  parent sequence will
          // have a depth of 1, its child will have a depth  of 2, and its grandchild
          // will have a depth of 3.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.9
 001552   function int get_depth();
        
            // If depth has been set or calculated, then use that
~000520     if (m_depth != -1) begin
%000000       return (m_depth);
            end
        
            // Calculate the depth, store it, and return the value
~000520     if (m_parent_sequence == null) begin
 000520       m_depth = 1;
%000000     end else begin
%000000       m_depth = m_parent_sequence.get_depth() + 1;
            end
        
 001552     return (m_depth);
          endfunction 
        
        
          // Function -- NODOCS -- is_item
          //
          // This function may be called on any sequence_item or sequence. It will
          // return 1 for items and 0 for sequences (which derive from this class).
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.11
 000257   virtual function bit is_item();
 000257     return(1);
          endfunction
        
        
          // Function- get_full_name
          //
          // Internal method; overrides must follow same naming convention
        
 000796   function string get_full_name();
 000257     if(m_parent_sequence != null) begin 
              
 000257       get_full_name = {m_parent_sequence.get_full_name(), "."};
            end
        
~000533     else if(m_sequencer!=null) begin
              
 000533       get_full_name = {m_sequencer.get_full_name(), "."};
            end
        
~000796     if(get_name() != "") begin 
              
 000796       get_full_name = {get_full_name, get_name()};
            end
        
%000000     else begin
%000000       get_full_name = {get_full_name, "_item"};
            end
          endfunction
        
        
          // Function -- NODOCS -- get_root_sequence_name
          //
          // Provides the name of the root sequence (the top-most parent sequence).
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.12
 000257   function string get_root_sequence_name();
 000257     uvm_sequence_base root_seq;
 000257     root_seq = get_root_sequence();
%000000     if (root_seq == null) begin
              
%000000       return "";
            end
        
%000000     else begin
              
%000000       return root_seq.get_name();
            end
        
          endfunction
        
        
          // Function- m_set_p_sequencer
          //
          // Internal method
        
 000517   virtual function void m_set_p_sequencer();
 000517     return;
          endfunction  
        
        
          // Function -- NODOCS -- get_root_sequence
          //
          // Provides a reference to the root sequence (the top-most parent sequence).
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.13
 000257   function uvm_sequence_base get_root_sequence();
 000257 	uvm_sequence_base curr_seq, next_seq;
        	// Note that curr_seq defaults to null
 000257 	next_seq = this.get_parent_sequence();
 000257 	while (next_seq != null) begin
 000257       curr_seq = next_seq;
 000257       next_seq = curr_seq.get_parent_sequence();
        	end
 000257 	return curr_seq;
        
          endfunction
        
        
          // Function -- NODOCS -- get_sequence_path
          //
          // Provides a string of names of each sequence in the full hierarchical
          // path. A "." is used as the separator between each sequence.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.2.14
 000033   function string get_sequence_path();
 000033     uvm_sequence_item this_item;
 000033     string seq_path;
 000033     this_item = this;
 000033     seq_path = this.get_name();
%000000     while (this_item.get_parent_sequence()!=null) begin
%000000         this_item = this_item.get_parent_sequence();
%000000         seq_path = {this_item.get_name(), ".", seq_path};
            end
                
 000033     return seq_path;
          endfunction
        
        
          //---------------------------
          // Group -- NODOCS -- Reporting Interface
          //---------------------------
          //
          // Sequence items and sequences will use the sequencer which they are
          // associated with for reporting messages. If no sequencer has been set
          // for the item/sequence using <set_sequencer> or indirectly via 
          // <uvm_sequence_base::start_item> or <uvm_sequence_base::start>),
          // then the global reporter will be used.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.1
 000066   virtual function uvm_report_object uvm_get_report_object();
%000000     if(m_sequencer == null) begin
%000000       uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000       return cs.get_root();
%000000     end else begin 
              
%000000       return m_sequencer;
            end
        
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.2
%000000   function int uvm_report_enabled(int verbosity, 
                              uvm_severity severity=UVM_INFO, string id="");
%000000     uvm_report_object l_report_object = uvm_get_report_object();
%000000     if (l_report_object.get_report_verbosity_level(severity, id) < verbosity) begin
              
%000000       return 0;
            end
        
%000000     return 1;
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.3
 000033   virtual function void uvm_report( uvm_severity severity,
                                            string id,
                                            string message,
                                            int verbosity = (severity == uvm_severity'(UVM_ERROR)) ? UVM_NONE :
                                                            (severity == uvm_severity'(UVM_FATAL)) ? UVM_NONE : 
                                                            (severity == uvm_severity'(UVM_WARNING)) ? UVM_NONE : UVM_MEDIUM,
                                            string filename = "",
                                            int line = 0,
                                            string context_name = "",
                                            bit report_enabled_checked = 0);
 000033     uvm_report_message l_report_message;
~000033     if ((severity == UVM_INFO) && (report_enabled_checked == 0)) begin
%000000       if (!uvm_report_enabled(verbosity, severity, id)) begin
                
%000000         return;
              end
        
            end
 000033     l_report_message = uvm_report_message::new_report_message();
 000033     l_report_message.set_report_message(severity, id, message, 
 000033                     verbosity, filename, line, context_name);
 000033     uvm_process_report_message(l_report_message);
        
          endfunction
            
          // Function -- NODOCS -- uvm_report_info
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.3
 000033   virtual function void uvm_report_info( string id,
                             string message,
                                int verbosity = UVM_MEDIUM,
                             string filename = "",
                             int line = 0,
                                string context_name = "",
                             bit report_enabled_checked = 0);
        
 000033     this.uvm_report(UVM_INFO, id, message, verbosity, filename, line,
 000033                     context_name, report_enabled_checked);
          endfunction
        
          // Function -- NODOCS -- uvm_report_warning
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.3
%000000   virtual function void uvm_report_warning( string id,
                                string message,
                                   int verbosity = UVM_NONE,                        
                                string filename = "",
                                int line = 0,
                                   string context_name = "",
                                bit report_enabled_checked = 0);
        
%000000     this.uvm_report(UVM_WARNING, id, message, verbosity, filename, line,
%000000                     context_name, report_enabled_checked);
          endfunction
        
          // Function -- NODOCS -- uvm_report_error
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.3
%000000   virtual function void uvm_report_error( string id,
                              string message,
                                 int verbosity = UVM_NONE,
                              string filename = "",
                              int line = 0,
                                 string context_name = "",
                              bit report_enabled_checked = 0);
        
%000000     this.uvm_report(UVM_ERROR, id, message, verbosity, filename, line,
%000000                     context_name, report_enabled_checked);
          endfunction
        
          // Function -- NODOCS -- uvm_report_fatal
          //
          // These are the primary reporting methods in the UVM. uvm_sequence_item
          // derived types delegate these functions to their associated sequencer
          // if they have one, or to the global reporter. See <uvm_report_object::Reporting>
          // for details on the messaging functions.
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.3
%000000   virtual function void uvm_report_fatal( string id,
                              string message,
                                 int verbosity = UVM_NONE,
%000000                       string filename = "",
%000000                       int line = 0,
%000000                          string context_name = "",
%000000                       bit report_enabled_checked = 0);
        
%000000     this.uvm_report(UVM_FATAL, id, message, verbosity, filename, line,
%000000                     context_name, report_enabled_checked);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 14.1.3.4
 000033   virtual function void uvm_process_report_message (uvm_report_message report_message);
 000033     uvm_report_object l_report_object = uvm_get_report_object();
 000033     report_message.set_report_object(l_report_object);
~000033     if (report_message.get_context() == "") begin
              
 000033       report_message.set_context(get_sequence_path());
            end
        
 000033     l_report_object.m_rh.process_report_message(report_message);
          endfunction
        
        
          // Function- do_print
          //
          // Internal method
        
 001295   function void do_print (uvm_printer printer);
 001295     string temp_str0, temp_str1;
 001295     int depth = get_depth();
 001295     super.do_print(printer);
~001028     if(print_sequence_info || m_use_sequence_info) begin
 000267       printer.print_field_int("depth", depth, $bits(depth), UVM_DEC, ".", "int");
~000267       if(m_parent_sequence != null) begin
 000267         temp_str0 = m_parent_sequence.get_name();
 000267         temp_str1 = m_parent_sequence.get_full_name();
              end
 000267       printer.print_string("parent sequence (name)", temp_str0);
 000267       printer.print_string("parent sequence (full name)", temp_str1);
 000267       temp_str1 = "";
~000267       if(m_sequencer != null) begin
 000267         temp_str1 = m_sequencer.get_full_name();
              end
 000267       printer.print_string("sequencer", temp_str1);
            end
          endfunction
        
          /*
          virtual task pre_do(bit is_item);
            return;
          endtask
        
          virtual task body();
            return;
          endtask  
        
          virtual function void mid_do(uvm_sequence_item this_item);
            return;
          endfunction
          
          virtual function void post_do(uvm_sequence_item this_item);
            return;
          endfunction
        
          virtual task wait_for_grant(int item_priority = -1, bit  lock_request = 0);
            return;
          endtask
        
          virtual function void send_request(uvm_sequence_item request, bit rerandomize = 0);
            return;
          endfunction
        
          virtual task wait_for_item_done(int transaction_id = -1);
            return;
          endtask
          */
        
        endclass
        
