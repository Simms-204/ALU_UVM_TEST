//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2013-2018 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2020-2023 Marvell International Ltd.
        // Copyright 2007-2020 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2017 Synopsys, Inc.
        // Copyright 2020 Verific
        // Copyright 2013 Verilab
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
        // $File:     src/seq/uvm_sequencer_base.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        typedef uvm_config_db#(uvm_sequence_base) uvm_config_seq;
        typedef class uvm_sequence_request;
        
        // Utility class for tracking default_sequences
%000000 class uvm_sequence_process_wrapper;
            process pid;
            uvm_sequence_base seq;
        endclass : uvm_sequence_process_wrapper
        
        //------------------------------------------------------------------------------
        //
        // CLASS: uvm_sequencer_base
        //
        // The library implements some public API beyond what is documented
        // in 1800.2.  
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 15.3.1
        virtual class uvm_sequencer_base extends uvm_component;
        
%000000   typedef enum {SEQ_TYPE_REQ,
                        SEQ_TYPE_LOCK} seq_req_t; 
        
        // queue of sequences waiting for arbitration
          protected uvm_sequence_request arb_sequence_q[$];
        
          protected bit                 arb_completed[int];
        
          protected uvm_sequence_base   lock_list[$];
          protected uvm_sequence_base   reg_sequences[int];
          protected int                 m_sequencer_id;
          protected int                 m_lock_arb_size;  // used for waiting processes
          protected int                 m_arb_size;       // used for waiting processes
          protected int                 m_wait_for_item_sequence_id,
                                        m_wait_for_item_transaction_id;
%000003   protected int                 m_wait_relevant_count = 0 ;
%000003   protected int                 m_max_zero_time_wait_relevant_count = 10;
%000003   protected time                m_last_wait_relevant_time = 0 ;
        
%000003   local uvm_sequencer_arb_mode  m_arbitration = UVM_SEQ_ARB_FIFO;
          local static int              g_request_id;
%000003   local static int              g_sequence_id = 1;
%000003   local static int              g_sequencer_id = 1;
        
          protected int                 m_wait_for_sequences_count;  // specifies the # of times the sequencer
                                                                     // should call wait_for_sequences().  A
                                                                     // value > 1 allows sequencer stacking.
          // Function -- NODOCS -- new
          //
          // Creates and initializes an instance of this class using the normal
          // constructor arguments for uvm_component: name is the name of the
          // instance, and parent is the handle to the hierarchical parent.
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.1
          extern function new (string name, uvm_component parent);
        
          // Variable: wait_for_sequences_count
          // Controls the number of wait_for_sequences calls when selecting next sequence.
          //
          // By default, the sequencers will wait for 1 ~wait_for_sequences~ call
          // when selecting a new sequence.  When stacking sequencers, this will
          // cause a problem as the single call in a low level sequencer is absorbed
          // by the next call in the higher level sequencer(s).  This problem can be avoided
          // by setting the value of "wait_for_sequences_count" to a value higher than
          // 1 for the lower level sequencer(s) using the config database, e.g.:
          //
          //| uvm_config_db#(int)::set(this, "path.to.sequencer", "wait_for_sequences_count", 4);
          //
          // Setting wait_for_sequences_count less than 1 will be ignored.  
          //
          // Note: Each successively lower sequencer in a stack will require a higher wait_for_sequences_count
          // value in order to absorb all potential wait_for_sequences() counts in each higher level
          // of the stack.
          //
          // Note: Increasing this value will decrease the efficiency of the sequencer
          // in the event of a get/get_next_item/peek/try_next_item call when no items
          // are actually available.  As such, care should be taken to avoid unnecessarily
          // increasing the value.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
          extern virtual function void build_phase(uvm_phase phase);
          
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.2
          extern function bit is_child (uvm_sequence_base parent, uvm_sequence_base child);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.3
          extern virtual function int user_priority_arbitration(int avail_sequences[$]);
        
        
          // Task -- NODOCS -- execute_item
          //
          // Executes the given transaction ~item~ directly on this sequencer. A temporary
          // parent sequence is automatically created for the ~item~.  There is no capability to
          // retrieve responses. If the driver returns responses, they will accumulate in the
          // sequencer, eventually causing response overflow unless
          // <uvm_sequence_base::set_response_queue_error_report_enabled> is called.
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.5
          extern virtual task execute_item(uvm_sequence_item item);
        
          // Hidden array, keeps track of running default sequences
          protected uvm_sequence_process_wrapper m_default_sequences[uvm_phase];
        
          // Function -- NODOCS -- start_phase_sequence
          //
          // Start the default sequence for this phase, if any.
          // The default sequence is configured via resources using
          // either a sequence instance or sequence type (object wrapper).
          // If both are used,
          // the sequence instance takes precedence. When attempting to override
          // a previous default sequence setting, you must override both
          // the instance and type (wrapper) resources, else your override may not
          // take effect.
          //
          // When setting the resource using ~set~, the 1st argument specifies the
          // context pointer, usually ~this~ for components or ~null~ when executed from
          // outside the component hierarchy (i.e. in module).
          // The 2nd argument is the instance string, which is a path name to the
          // target sequencer, relative to the context pointer.  The path must include
          // the name of the phase with a "_phase" suffix. The 3rd argument is the
          // resource name, which is "default_sequence". The 4th argument is either
          // an object wrapper for the sequence type, or an instance of a sequence.
          //
          // Configuration by instances
          // allows pre-initialization, setting rand_mode, use of inline
          // constraints, etc.
          //
          //| myseq_t myseq = new("myseq");
          //| myseq.randomize() with { ... };
          //| uvm_config_db #(uvm_sequence_base)::set(null, "top.agent.myseqr.main_phase",
          //|                                         "default_sequence",
          //|                                         myseq);
          //
          // Configuration by type is shorter and can be substituted via
          // the factory.
          //
          //| uvm_config_db #(uvm_object_wrapper)::set(null, "top.agent.myseqr.main_phase",
          //|                                          "default_sequence",
          //|                                          myseq_type::type_id::get());
          //
          // The uvm_resource_db can similarly be used.
          //
          //| myseq_t myseq = new("myseq");
          //| myseq.randomize() with { ... };
          //| uvm_resource_db #(uvm_sequence_base)::set({get_full_name(), ".myseqr.main_phase",
          //|                                           "default_sequence",
          //|                                           myseq, this);
          //
          //| uvm_resource_db #(uvm_object_wrapper)::set({get_full_name(), ".myseqr.main_phase",
          //|                                            "default_sequence",
          //|                                            myseq_t::type_id::get(),
          //|                                            this );
          //
          //
        
        
        
          extern virtual function void start_phase_sequence(uvm_phase phase);
        
          // Function -- NODOCS -- stop_phase_sequence
          //
          // Stop the default sequence for this phase, if any exists, and it
          // is still executing.
        
          extern virtual function void stop_phase_sequence(uvm_phase phase);
        
        
        
          // Task -- NODOCS -- wait_for_grant
          //
          // This task issues a request for the specified sequence.  If item_priority
          // is not specified, then the current sequence priority will be used by the
          // arbiter.  If a lock_request is made, then the  sequencer will issue a lock
          // immediately before granting the sequence.  (Note that the lock may be
          // granted without the sequence being granted if is_relevant is not asserted).
          //
          // When this method returns, the sequencer has granted the sequence, and the
          // sequence must call send_request without inserting any simulation delay
          // other than delta cycles.  The driver is currently waiting for the next
          // item to be sent via the send_request call.
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.6
          extern virtual task wait_for_grant(uvm_sequence_base sequence_ptr,
                                             int item_priority = -1,
                                             bit lock_request = 0);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.7
          extern virtual task wait_for_item_done(uvm_sequence_base sequence_ptr,
                                                 int transaction_id);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.8
          extern function bit is_blocked(uvm_sequence_base sequence_ptr);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.9
          extern function bit has_lock(uvm_sequence_base sequence_ptr);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.10
          extern virtual task lock(uvm_sequence_base sequence_ptr);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.11
          extern virtual task grab(uvm_sequence_base sequence_ptr);
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.12
          extern virtual function void unlock(uvm_sequence_base sequence_ptr);
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.13
          extern virtual function void  ungrab(uvm_sequence_base sequence_ptr);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.14
          extern virtual function void stop_sequences();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.15
          extern virtual function bit is_grabbed();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.16
          extern virtual function uvm_sequence_base current_grabber();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.17
          extern virtual function bit has_do_available();
        
         
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.19
          extern function void set_arbitration(uvm_sequencer_arb_mode val);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.18
          extern function uvm_sequencer_arb_mode get_arbitration();
        
        
          // Task -- NODOCS -- wait_for_sequences
          //
          // Waits for a sequence to have a new item available. Uses
          // <uvm_wait_for_nba_region> to give a sequence as much time as
          // possible to deliver an item before advancing time.
        
          extern virtual task wait_for_sequences();
        
        
          // Function -- NODOCS -- send_request
          //
          // Derived classes implement this function to send a request item to the
          // sequencer, which will forward it to the driver.  If the rerandomize bit
          // is set, the item will be randomized before being sent to the driver.
          //
          // This function may only be called after a <wait_for_grant> call.
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.20
          extern virtual function void send_request(uvm_sequence_base sequence_ptr,
                                                    uvm_sequence_item t,
                                                    bit rerandomize = 0);
        
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.21
          extern virtual function void set_max_zero_time_wait_relevant_count(int new_val) ;
        
          // Added in IEEE. Not in UVM 1.2
          // @uvm-ieee 1800.2-2020 auto 15.3.2.4
          extern virtual function uvm_sequence_base get_arbitration_sequence( int index );
        
          //----------------------------------------------------------------------------
          // INTERNAL METHODS - DO NOT CALL DIRECTLY, ONLY OVERLOAD IF VIRTUAL
          //----------------------------------------------------------------------------
        
          extern protected function void grant_queued_locks();
        
        
          extern protected task          m_select_sequence(output uvm_sequence_request selected_sequence_request);
          extern protected function int  m_choose_next_request();
          extern           task          m_wait_for_arbitration_completed(int request_id);
          extern           function void m_set_arbitration_completed(int request_id);
        
        
          extern local task m_lock_req(uvm_sequence_base sequence_ptr, bit lock);
        
        
          // Task- m_unlock_req
          //
          // Called by a sequence to request an unlock.  This
          // will remove a lock for this sequence if it exists
        
          extern function void m_unlock_req(uvm_sequence_base sequence_ptr);
        
        
          extern local function void remove_sequence_from_queues(uvm_sequence_base sequence_ptr);
          extern function void m_sequence_exiting(uvm_sequence_base sequence_ptr);
          extern function void kill_sequence(uvm_sequence_base sequence_ptr);
        
          extern virtual function void analysis_write(uvm_sequence_item t);
        
        
          extern           function void   do_print (uvm_printer printer);
        
        
          extern virtual   function int    m_register_sequence(uvm_sequence_base sequence_ptr);
          extern protected
                   virtual function void   m_unregister_sequence(int sequence_id);
          extern protected function
                         uvm_sequence_base m_find_sequence(int sequence_id);
        
          extern protected function void   m_update_lists();
          extern           function string convert2string();
          extern protected
                   virtual function int    m_find_number_driver_connections();
          extern protected task            m_wait_arb_not_equal();
          extern protected task            m_wait_for_available_sequence();
          extern protected function int    m_get_seq_item_priority(uvm_sequence_request seq_q_entry);
        
          int m_is_relevant_completed;
        
        `ifdef UVM_DISABLE_RECORDING
           `define UVM_DISABLE_AUTO_ITEM_RECORDING
        `endif
        
        // Macro: UVM_DISABLE_AUTO_ITEM_RECORDING
        // Performs the same function as the deprecated 1800.2 define UVM_DISABLE_RECORDING,
        // globally turning off automatic item recording when defined by the user.  
        //
        // @uvm-accellera
        
        `ifdef UVM_DISABLE_AUTO_ITEM_RECORDING
          local bit m_auto_item_recording = 0;
        `else
%000003   local bit m_auto_item_recording = 1;
        `endif
        
        
          // Access to following internal methods provided via seq_item_export
        
          // Function -- NODOCS -- disable_auto_item_recording
          //
          // Disables auto_item_recording
          // 
          // This function is the implementation of the 
          // uvm_sqr_if_base::disable_auto_item_recording() method detailed in
          // IEEE1800.2 section 15.2.1.2.10
          // 
          // This function is implemented here to allow <uvm_push_sequencer#(REQ,RSP)>
          // and <uvm_push_driver#(REQ,RSP)> access to the call.
          //
        
          // @uvm-ieee 1800.2-2020 auto 15.3.2.22
%000000   virtual function void disable_auto_item_recording();
%000000     m_auto_item_recording = 0;
          endfunction
        
          // Function -- NODOCS -- is_auto_item_recording_enabled
          //
          // Returns 1 is auto_item_recording is enabled,
          // otherwise 0
          // 
          // This function is the implementation of the 
          // uvm_sqr_if_base::is_auto_item_recording_enabled() method detailed in
          // IEEE1800.2 section 15.2.1.2.11
          // 
          // This function is implemented here to allow <uvm_push_sequencer#(REQ,RSP)>
          // and <uvm_push_driver#(REQ,RSP)> access to the call.
          //
 002494   virtual function bit is_auto_item_recording_enabled();
 002494     return m_auto_item_recording;
          endfunction
        
          static uvm_sequencer_base all_sequencer_insts[int unsigned];
        endclass
        
        
        
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
        
        
        // new
        // ---
        
%000003 function uvm_sequencer_base::new (string name, uvm_component parent);
%000003   super.new(name, parent);
%000003   m_sequencer_id = g_sequencer_id++;
%000003   m_lock_arb_size = -1;
%000003   all_sequencer_insts[m_sequencer_id]=this;
%000003   m_wait_for_sequences_count = 1; // default
        endfunction
        
        // build_phase
        // -----------
%000003 function void uvm_sequencer_base::build_phase(uvm_phase phase);
%000003   super.build_phase(phase);
%000003   if (!uvm_config_db#(uvm_bitstream_t)::get(this, "", "wait_for_sequences_count", m_wait_for_sequences_count)) begin
            
%000003     void'(uvm_config_db#(int)::get(this, "", "wait_for_sequences_count", m_wait_for_sequences_count));
          end
        
          
%000003   if (m_wait_for_sequences_count < 1) begin
%000000     `uvm_warning("UVM/SQR/WFSC", $sformatf("attempt to set wait_for_sequences_count to '%0d' will be ignored, values must be 1 or greater!", m_wait_for_sequences_count))
%000000     m_wait_for_sequences_count = 1;
          end
        endfunction : build_phase
        
        // do_print
        // --------
        
%000003 function void uvm_sequencer_base::do_print (uvm_printer printer);
%000003   super.do_print(printer);
%000003   printer.print_array_header("arbitration_queue", arb_sequence_q.size());
%000003   foreach (arb_sequence_q[i]) begin
            
%000000     printer.print_string($sformatf("[%0d]", i),
%000000        $sformatf("%s@seqid%0d",arb_sequence_q[i].request.name(),arb_sequence_q[i].sequence_id), "[");
          end
        
%000003   printer.print_array_footer(arb_sequence_q.size());
        
%000003   printer.print_array_header("lock_queue", lock_list.size());
%000003   foreach(lock_list[i]) begin
            
%000000     printer.print_string($sformatf("[%0d]", i),
%000000        $sformatf("%s@seqid%0d",lock_list[i].get_full_name(),lock_list[i].get_sequence_id()), "[");
          end
        
%000003   printer.print_array_footer(lock_list.size());
        endfunction
        
        
        // m_update_lists
        // --------------
        
 002494 function void uvm_sequencer_base::m_update_lists();
 002494   m_lock_arb_size++;
        endfunction
        
        
        // convert2string
        // ----------------
        
%000000 function string uvm_sequencer_base::convert2string();
%000000   string s;
        
%000000   $sformat(s, "  -- arb i/id/type: ");
%000000   foreach (arb_sequence_q[i]) begin
%000000     $sformat(s, "%s %0d/%0d/%s ", s, i, arb_sequence_q[i].sequence_id, arb_sequence_q[i].request.name());
          end
%000000   $sformat(s, "%s\n -- lock_list i/id: ", s);
%000000   foreach (lock_list[i]) begin
%000000     $sformat(s, "%s %0d/%0d",s, i, lock_list[i].get_sequence_id());
          end
%000000   return(s);
        endfunction
        
        
        
        // m_find_number_driver_connections
        // --------------------------------
        
%000000 function int  uvm_sequencer_base::m_find_number_driver_connections();
%000000   return 0;
        endfunction
        
        
        // m_register_sequence
        // -------------------
        
 001250 function int uvm_sequencer_base::m_register_sequence(uvm_sequence_base sequence_ptr);
        
%000003   if (sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 1) > 0) begin
            
%000000     return sequence_ptr.get_sequence_id();
          end
        
        
 001250   sequence_ptr.m_set_sqr_sequence_id(m_sequencer_id, g_sequence_id++);
 001250   reg_sequences[sequence_ptr.get_sequence_id()] = sequence_ptr;
 001250   return sequence_ptr.get_sequence_id();
        endfunction
        
        
        // m_find_sequence
        // ---------------
        
%000000 function uvm_sequence_base uvm_sequencer_base::m_find_sequence(int sequence_id);
%000000   uvm_sequence_base seq_ptr;
%000000   int           i;
        
          // When sequence_id is -1, return the first available sequence.  This is used
          // when deleting all sequences
%000000   if (sequence_id == -1) begin
%000000     if (reg_sequences.first(i)) begin
%000000       return(reg_sequences[i]);
            end
%000000     return(null);
          end
        
%000000   if (!reg_sequences.exists(sequence_id)) begin
            
%000000     return null;
          end
        
%000000   return reg_sequences[sequence_id];
        endfunction
        
        
        // m_unregister_sequence
        // ---------------------
        
%000006 function void uvm_sequencer_base::m_unregister_sequence(int sequence_id);
%000003   if (!reg_sequences.exists(sequence_id)) begin
            
%000000     return;
          end
        
%000006   reg_sequences.delete(sequence_id);
        endfunction
        
        
        // user_priority_arbitration
        // -------------------------
        
%000000 function int uvm_sequencer_base::user_priority_arbitration(int avail_sequences[$]);
%000000   return avail_sequences[0];
        endfunction
        
        
        // grant_queued_locks
        // ------------------
        // Any lock or grab requests that are at the front of the queue will be
        // granted at the earliest possible time.  This function grants any queues
        // at the front that are not locked out
        
 003744 function void uvm_sequencer_base::grant_queued_locks();
            // remove and report any zombies
 003744     begin
 003744       uvm_sequence_request zombies[$];
 003744       zombies = arb_sequence_q.find(item) with (item.request==SEQ_TYPE_LOCK && item.process_id.status inside {process::KILLED,process::FINISHED});
~003744       foreach(zombies[idx]) begin
%000000         `uvm_error("SEQLCKZMB", $sformatf("The task responsible for requesting a lock on sequencer '%s' for sequence '%s' has been killed, to avoid a deadlock the sequence will be removed from the arbitration queues", this.get_full_name(), zombies[idx].sequence_ptr.get_full_name()))
%000000         remove_sequence_from_queues(zombies[idx].sequence_ptr);
              end
            end
         
            // grant the first lock request that is not blocked, if any
 003744     begin
 003744       int lock_req_indices[$];
 003744       lock_req_indices = arb_sequence_q.find_first_index(item) with (item.request==SEQ_TYPE_LOCK && is_blocked(item.sequence_ptr) == 0);
~003744       if(lock_req_indices.size()) begin
%000000         uvm_sequence_request lock_req = arb_sequence_q[lock_req_indices[0]];
%000000         lock_list.push_back(lock_req.sequence_ptr);
%000000         m_set_arbitration_completed(lock_req.request_id);
%000000         arb_sequence_q.delete(lock_req_indices[0]);
%000000         m_update_lists();
              end
            end
        endfunction
        
        
        // m_select_sequence
        // -----------------
        
 001247 task uvm_sequencer_base::m_select_sequence(output uvm_sequence_request selected_sequence_request);
 001247    int selected_sequence;
        
            // Select a sequence
~001247     do begin
~001247       repeat(m_wait_for_sequences_count) begin
%000003         wait_for_sequences();
%000003         selected_sequence = m_choose_next_request();
%000003         if (selected_sequence != -1) begin
                  
%000000           break;
                end
        
              end
~001247       if (selected_sequence == -1) begin
%000000         m_wait_for_available_sequence();
              end
~001247     end while (selected_sequence == -1);
            // issue grant
~001247     if (selected_sequence >= 0) begin
 001247       selected_sequence_request = arb_sequence_q[selected_sequence];
 001247       m_set_arbitration_completed(selected_sequence_request.request_id);
 001247       arb_sequence_q.delete(selected_sequence);
 001247       m_update_lists();
            end
        endtask
        
        
        // m_choose_next_request
        // ---------------------
        // When a driver requests an operation, this function must find the next
        // available, unlocked, relevant sequence.
        //
        // This function returns -1 if no sequences are available or the entry into
        // arb_sequence_q for the chosen sequence
        
 001250 function int uvm_sequencer_base::m_choose_next_request();
 001250   int i, temp;
 001250   int avail_sequence_count;
 001250   int sum_priority_val;
 001250   int avail_sequences[$];
 001250   int highest_sequences[$];
 001250   int highest_pri;
 001250   string  s;
        
 001250   avail_sequence_count = 0;
        
 001250   grant_queued_locks();
        
 001250   i = 0;
%000000   while (i < arb_sequence_q.size()) begin
~001247     if ((arb_sequence_q[i].process_id.status == process::KILLED) ||
%000000     (arb_sequence_q[i].process_id.status == process::FINISHED)) begin
%000000       `uvm_error("SEQREQZMB", $sformatf("The task responsible for requesting a wait_for_grant on sequencer '%s' for sequence '%s' has been killed, to avoid a deadlock the sequence will be removed from the arbitration queues", this.get_full_name(), arb_sequence_q[i].sequence_ptr.get_full_name()))
%000000       remove_sequence_from_queues(arb_sequence_q[i].sequence_ptr);
%000000       continue;
            end
        
%000000     if (i < arb_sequence_q.size()) begin
              
%000000       if (arb_sequence_q[i].request == SEQ_TYPE_REQ) begin
                
%000000         if (is_blocked(arb_sequence_q[i].sequence_ptr) == 0) begin
                  
%000000           if (arb_sequence_q[i].sequence_ptr.is_relevant() == 1) begin
%000000             if (m_arbitration == UVM_SEQ_ARB_FIFO) begin
%000000               return i;
                    end
%000000             else begin
%000000               avail_sequences.push_back(i);
                    end
        
                  end
                end
        
              end
        
            end
        
        
%000000     i++;
          end
        
          // Return immediately if there are 0 or 1 available sequences
%000000   if (m_arbitration == UVM_SEQ_ARB_FIFO) begin
%000000     return -1;
          end
%000000   if (avail_sequences.size() < 1)  begin
%000000     return -1;
          end
        
%000000   if (avail_sequences.size() == 1) begin
%000000     return avail_sequences[0];
          end
        
          // If any locks are in place, then the available queue must
          // be checked to see if a lock prevents any sequence from proceeding
%000000   if (lock_list.size() > 0) begin
%000000     for (i = 0; i < avail_sequences.size(); i++) begin
%000000       if (is_blocked(arb_sequence_q[avail_sequences[i]].sequence_ptr) != 0) begin
%000000         avail_sequences.delete(i);
%000000         i--;
              end
            end
%000000     if (avail_sequences.size() < 1) begin
              
%000000       return -1;
            end
        
%000000     if (avail_sequences.size() == 1) begin
              
%000000       return avail_sequences[0];
            end
        
          end
        
          //  Weighted Priority Distribution
          // Pick an available sequence based on weighted priorities of available sequences
%000000   if (m_arbitration == UVM_SEQ_ARB_WEIGHTED) begin
%000000     sum_priority_val = 0;
%000000     for (i = 0; i < avail_sequences.size(); i++) begin
%000000       sum_priority_val += m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]);
            end
        
%000000     temp = $urandom_range(sum_priority_val-1, 0);
        
%000000     sum_priority_val = 0;
%000000     for (i = 0; i < avail_sequences.size(); i++) begin
%000000       if ((m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]) +
%000000       sum_priority_val) > temp) begin
%000000         return avail_sequences[i];
              end
%000000       sum_priority_val += m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]);
            end
%000000     uvm_report_fatal("Sequencer", "UVM Internal error in weighted arbitration code", UVM_NONE);
          end
        
          //  Random Distribution
%000000   if (m_arbitration == UVM_SEQ_ARB_RANDOM) begin
%000000     i = $urandom_range(avail_sequences.size()-1, 0);
%000000     return avail_sequences[i];
          end
        
          //  Strict Fifo
~001250   if ((m_arbitration == UVM_SEQ_ARB_STRICT_FIFO) || m_arbitration == UVM_SEQ_ARB_STRICT_RANDOM) begin
%000000     highest_pri = 0;
            // Build a list of sequences at the highest priority
%000000     for (i = 0; i < avail_sequences.size(); i++) begin
%000000       if (m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]) > highest_pri) begin
                // New highest priority, so start new list
%000000         highest_sequences.delete();
%000000         highest_sequences.push_back(avail_sequences[i]);
%000000         highest_pri = m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]);
              end
%000000       else if (m_get_seq_item_priority(arb_sequence_q[avail_sequences[i]]) == highest_pri) begin
%000000         highest_sequences.push_back(avail_sequences[i]);
              end
            end
        
            // Now choose one based on arbitration type
%000000     if (m_arbitration == UVM_SEQ_ARB_STRICT_FIFO) begin
%000000       return(highest_sequences[0]);
            end
        
%000000     i = $urandom_range(highest_sequences.size()-1, 0);
%000000     return highest_sequences[i];
          end
        
%000000   if (m_arbitration == UVM_SEQ_ARB_USER) begin
%000000     i = user_priority_arbitration( avail_sequences);
        
            // Check that the returned sequence is in the list of available sequences.  Failure to
            // use an available sequence will cause highly unpredictable results.
%000000     highest_sequences = avail_sequences.find with (item == i);
%000000     if (highest_sequences.size() == 0) begin
%000000       uvm_report_fatal("Sequencer",
%000000           $sformatf("Error in User arbitration, sequence %0d not available\n%s",
%000000                     i, convert2string()), UVM_NONE);
            end
%000000     return(i);
          end
        
 001250   uvm_report_fatal("Sequencer", "Internal error: Failed to choose sequence", UVM_NONE);
        
        endfunction
        
        
        // m_wait_arb_not_equal
        // --------------------
        
%000000 task uvm_sequencer_base::m_wait_arb_not_equal();
%000000   wait (m_arb_size != m_lock_arb_size);
        endtask
        
        
        // m_wait_for_available_sequence
        // -----------------------------
        
%000000 task uvm_sequencer_base::m_wait_for_available_sequence();
%000000   int i;
%000000   int is_relevant_entries[$];
        
          // This routine will wait for a change in the request list, or for
          // wait_for_relevant to return on any non-relevant, non-blocked sequence
%000000   m_arb_size = m_lock_arb_size;
        
%000000   for (i = 0; i < arb_sequence_q.size(); i++) begin
%000000     if (arb_sequence_q[i].request == SEQ_TYPE_REQ) begin
%000000       if (is_blocked(arb_sequence_q[i].sequence_ptr) == 0) begin
%000000         if (arb_sequence_q[i].sequence_ptr.is_relevant() == 0) begin
%000000           is_relevant_entries.push_back(i);
                end
              end
            end
          end
        
          // Typical path - don't need fork if all queued entries are relevant
%000000   if (is_relevant_entries.size() == 0) begin
%000000     m_wait_arb_not_equal();
%000000     return;
          end
        
%000000   fork  // isolate inner fork block for disabling
%000000     begin
%000000       fork
%000000         begin
%000000           fork
%000000             begin
                      // One path in fork is for any wait_for_relevant to return
%000000               m_is_relevant_completed = 0;
        
%000000               for(i = 0; i < is_relevant_entries.size(); i++) begin
%000000                 fork
%000000                   automatic int k = i;
        
%000000                   begin
%000000                     arb_sequence_q[is_relevant_entries[k]].sequence_ptr.wait_for_relevant();
%000000                     if ($realtime != m_last_wait_relevant_time) begin
%000000                       m_last_wait_relevant_time = $realtime ;
%000000                       m_wait_relevant_count = 0 ;
                            end
%000000                     else begin
%000000                       m_wait_relevant_count++ ;
%000000                       if (m_wait_relevant_count > m_max_zero_time_wait_relevant_count) begin
%000000                         `uvm_fatal("SEQRELEVANTLOOP",$sformatf("Zero time loop detected, passed wait_for_relevant %0d times without time advancing",m_wait_relevant_count))
                              end
                            end
%000000                     m_is_relevant_completed = 1;
                          end
                        join_none
        
                      end
%000000               wait (m_is_relevant_completed > 0);
                    end
        
                    // The other path in the fork is for any queue entry to change
%000000             begin
%000000               m_wait_arb_not_equal();
                    end
                  join_any
                end
              join_any
%000000       disable fork;
            end
          join
        endtask
        
        
        // m_get_seq_item_priority
        // -----------------------
        
%000000 function int uvm_sequencer_base::m_get_seq_item_priority(uvm_sequence_request seq_q_entry);
          // If the priority was set on the item, then that is used
%000000   if (seq_q_entry.item_priority != -1) begin
%000000     if (seq_q_entry.item_priority <= 0) begin
%000000       uvm_report_fatal("SEQITEMPRI",
%000000                     $sformatf("Sequence item from %s has illegal priority: %0d",
%000000                             seq_q_entry.sequence_ptr.get_full_name(),
%000000                             seq_q_entry.item_priority), UVM_NONE);
            end
%000000     return seq_q_entry.item_priority;
          end
          // Otherwise, use the priority of the calling sequence
%000000   if (seq_q_entry.sequence_ptr.get_priority() < 0) begin
%000000     uvm_report_fatal("SEQDEFPRI",
%000000                     $sformatf("Sequence %s has illegal priority: %0d",
%000000                             seq_q_entry.sequence_ptr.get_full_name(),
%000000                             seq_q_entry.sequence_ptr.get_priority()), UVM_NONE);
          end
%000000   return seq_q_entry.sequence_ptr.get_priority();
        endfunction
        
        
        // m_wait_for_arbitration_completed
        // --------------------------------
        
 001247 task uvm_sequencer_base::m_wait_for_arbitration_completed(int request_id);
 001247   int lock_arb_size;
        
          // Search the list of arb_wait_q, see if this item is done
 001247   forever begin
            
 001247     lock_arb_size  = m_lock_arb_size;
        
~001247     if (arb_completed.exists(request_id)) begin
%000000       arb_completed.delete(request_id);
%000000       return;
            end
 001247     wait (lock_arb_size != m_lock_arb_size);
          end
        endtask
        
        
        // m_set_arbitration_completed
        // ---------------------------
        
 001247 function void uvm_sequencer_base::m_set_arbitration_completed(int request_id);
 001247   arb_completed[request_id] = 1;
        endfunction
        
        
        // is_child
        // --------
        
%000000 function bit uvm_sequencer_base::is_child (uvm_sequence_base parent,
                                                   uvm_sequence_base child);
%000000   uvm_sequence_base child_parent;
        
%000000   if (child == null) begin
%000000     uvm_report_fatal("uvm_sequencer", "is_child passed null child", UVM_NONE);
          end
        
%000000   if (parent == null) begin
%000000     uvm_report_fatal("uvm_sequencer", "is_child passed null parent", UVM_NONE);
          end
        
%000000   child_parent = child.get_parent_sequence();
%000000   while (child_parent != null) begin
%000000     if (child_parent.get_inst_id() == parent.get_inst_id()) begin
%000000       return 1;
            end
%000000     child_parent = child_parent.get_parent_sequence();
          end
%000000   return 0;
        endfunction
        
        
        // execute_item
        // ------------
        
        // Implementation artifact, extends virtual class uvm_sequence_base
        // so that it can be constructed for execute_item
        class m_uvm_sqr_seq_base extends uvm_sequence_base;
%000000    function new(string name="unnamed-m_uvm_sqr_seq_base");
%000000       super.new(name);
           endfunction : new
        endclass : m_uvm_sqr_seq_base
           
%000000 task uvm_sequencer_base::execute_item(uvm_sequence_item item);
%000000   m_uvm_sqr_seq_base seq;
        
%000000   seq = new("execute_item_seq");
%000000   item.set_sequencer(this);
%000000   item.set_parent_sequence(seq);
%000000   seq.set_sequencer(this);
%000000   seq.start_item(item);
%000000   seq.finish_item(item);
%000000   remove_sequence_from_queues(seq);
        
        endtask
        
        
        // wait_for_grant
        // --------------
        
 001247 task uvm_sequencer_base::wait_for_grant(uvm_sequence_base sequence_ptr,
                                                int item_priority = -1,
                                                bit lock_request = 0);
 001247   uvm_sequence_request req_s;
 001247   int my_seq_id;
        
~001247   if (sequence_ptr == null) begin
            
%000000     uvm_report_fatal("uvm_sequencer",
%000000        "wait_for_grant passed null sequence_ptr", UVM_NONE);
          end
        
        
 001247   my_seq_id = m_register_sequence(sequence_ptr);
        
          // If lock_request is asserted, then issue a lock.  Don't wait for the response, since
          // there is a request immediately following the lock request
~001247   if (lock_request == 1) begin
%000000     req_s = new();
%000000     req_s.grant = 0;
%000000     req_s.sequence_id = my_seq_id;
%000000     req_s.request = SEQ_TYPE_LOCK;
%000000     req_s.sequence_ptr = sequence_ptr;
%000000     req_s.request_id = g_request_id++;
%000000     req_s.process_id = process::self();
%000000     arb_sequence_q.push_back(req_s);
          end
        
          // Push the request onto the queue
 001247   req_s = new();
 001247   req_s.grant = 0;
 001247   req_s.request = SEQ_TYPE_REQ;
 001247   req_s.sequence_id = my_seq_id;
 001247   req_s.item_priority = item_priority;
 001247   req_s.sequence_ptr = sequence_ptr;
 001247   req_s.request_id = g_request_id++;
 001247   req_s.process_id = process::self();
 001247   arb_sequence_q.push_back(req_s);
 001247   m_update_lists();
        
          // Wait until this entry is granted
          // Continue to point to the element, since location in queue will change
 001247   m_wait_for_arbitration_completed(req_s.request_id);
        
          // The wait_for_grant_semaphore is used only to check that send_request
          // is only called after wait_for_grant.  This is not a complete check, since
          // requests might be done in parallel, but it will catch basic errors
 001247   req_s.sequence_ptr.m_wait_for_grant_semaphore++;
        
        endtask
        
        
        // wait_for_item_done
        // ------------------
        
 001247 task uvm_sequencer_base::wait_for_item_done(uvm_sequence_base sequence_ptr,
                                                    int transaction_id);
 001247   int sequence_id;
        
 001247   sequence_id = sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 1);
 001247   m_wait_for_item_sequence_id = -1;
 001247   m_wait_for_item_transaction_id = -1;
        
~001247   if (transaction_id == -1) begin
            
 001247     wait (m_wait_for_item_sequence_id == sequence_id);
          end
        
%000000   else begin
            
%000000     wait ((m_wait_for_item_sequence_id == sequence_id &&
%000000            m_wait_for_item_transaction_id == transaction_id));
          end
        
        endtask
        
        
        // is_blocked
        // ----------
        
 001247 function bit uvm_sequencer_base::is_blocked(uvm_sequence_base sequence_ptr);
        
~001247   if (sequence_ptr == null) begin
            
%000000     uvm_report_fatal("uvm_sequence_controller",
%000000                      "is_blocked passed null sequence_ptr", UVM_NONE);
          end
        
        
~001247   foreach (lock_list[i]) begin
%000000     if ((lock_list[i].get_inst_id() !=
            sequence_ptr.get_inst_id()) &&
%000000     (is_child(lock_list[i], sequence_ptr) == 0)) begin
%000000       return 1;
            end
          end
 001247   return 0;
        endfunction
        
        
        // has_lock
        // --------
        
%000000 function bit uvm_sequencer_base::has_lock(uvm_sequence_base sequence_ptr);
%000000   int my_seq_id;
        
%000000   if (sequence_ptr == null) begin
            
%000000     uvm_report_fatal("uvm_sequence_controller",
%000000                      "has_lock passed null sequence_ptr", UVM_NONE);
          end
        
%000000   my_seq_id = m_register_sequence(sequence_ptr);
%000000     foreach (lock_list[i]) begin
%000000       if (lock_list[i].get_inst_id() == sequence_ptr.get_inst_id()) begin
%000000         return 1;
              end
            end
%000000   return 0;
        endfunction
        
        
        // m_lock_req
        // ----------
        // Internal method. Called by a sequence to request a lock.
        // Puts the lock request onto the arbitration queue.
        
%000000 task uvm_sequencer_base::m_lock_req(uvm_sequence_base sequence_ptr, bit lock);
%000000   int my_seq_id;
%000000   uvm_sequence_request new_req;
        
%000000   if (sequence_ptr == null) begin
            
%000000     uvm_report_fatal("uvm_sequence_controller",
%000000                      "lock_req passed null sequence_ptr", UVM_NONE);
          end
        
        
%000000   my_seq_id = m_register_sequence(sequence_ptr);
%000000   new_req = new();
%000000   new_req.grant = 0;
%000000   new_req.sequence_id = sequence_ptr.get_sequence_id();
%000000   new_req.request = SEQ_TYPE_LOCK;
%000000   new_req.sequence_ptr = sequence_ptr;
%000000   new_req.request_id = g_request_id++;
%000000   new_req.process_id = process::self();
        
%000000   if (lock == 1) begin
            // Locks are arbitrated just like all other requests
%000000     arb_sequence_q.push_back(new_req);
%000000   end else begin
            // Grabs are not arbitrated - they go to the front
            // TODO:
            // Missing: grabs get arbitrated behind other grabs
%000000     arb_sequence_q.push_front(new_req);
%000000     m_update_lists();
          end
        
          // If this lock can be granted immediately, then do so.
%000000   grant_queued_locks();
        
%000000   m_wait_for_arbitration_completed(new_req.request_id);
        endtask
        
        
        // m_unlock_req
        // ------------
        // Called by a sequence to request an unlock.  This
        // will remove a lock for this sequence if it exists
        
%000000 function void uvm_sequencer_base::m_unlock_req(uvm_sequence_base sequence_ptr);
%000000   if (sequence_ptr == null) begin
%000000     uvm_report_fatal("uvm_sequencer",
%000000                      "m_unlock_req passed null sequence_ptr", UVM_NONE);
          end
        
%000000   begin
%000000     int q[$];
%000000     int seqid=sequence_ptr.get_inst_id();
%000000     q=lock_list.find_first_index(item) with (item.get_inst_id() == seqid);
%000000     if(q.size()==1) begin
%000000       lock_list.delete(q[0]);
%000000       grant_queued_locks(); // grant lock requests
%000000       m_update_lists();
            end
%000000     else begin
                  
%000000       uvm_report_warning("SQRUNL",
%000000            {"Sequence '", sequence_ptr.get_full_name(),
%000000             "' called ungrab / unlock, but didn't have lock"}, UVM_NONE);
            end
        
        
          end
        endfunction
        
        
        // lock
        // ----
        
%000000 task uvm_sequencer_base::lock(uvm_sequence_base sequence_ptr);
%000000   m_lock_req(sequence_ptr, 1);
        endtask
        
        
        // grab
        // ----
        
%000000 task uvm_sequencer_base::grab(uvm_sequence_base sequence_ptr);
%000000   m_lock_req(sequence_ptr, 0);
        endtask
        
        
        // unlock
        // ------
        
%000000 function void uvm_sequencer_base::unlock(uvm_sequence_base sequence_ptr);
%000000   m_unlock_req(sequence_ptr);
        endfunction
        
        
        // ungrab
        // ------
        
%000000 function void  uvm_sequencer_base::ungrab(uvm_sequence_base sequence_ptr);
%000000   m_unlock_req(sequence_ptr);
        endfunction
        
        
        // remove_sequence_from_queues
        // ---------------------------
        
%000006 function void uvm_sequencer_base::remove_sequence_from_queues(
                                               uvm_sequence_base sequence_ptr);
%000006   int i;
%000006   int seq_id;
        
%000006   seq_id = sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 0);
        
          // Remove all queued items for this sequence and any child sequences
%000006   i = 0;
%000006   do begin
            
%000006     if (arb_sequence_q.size() > i) begin
%000000       if ((arb_sequence_q[i].sequence_id == seq_id) ||
%000000       (is_child(sequence_ptr, arb_sequence_q[i].sequence_ptr))) begin
%000000         if (sequence_ptr.get_sequence_state() == UVM_FINISHED) begin
%000000           `uvm_error("SEQFINERR", $sformatf("Parent sequence '%s' should not finish before all items from itself and items from descendent sequences are processed.  The item request from the sequence '%s' is being removed.", sequence_ptr.get_full_name(), arb_sequence_q[i].sequence_ptr.get_full_name()))
                end
%000000         arb_sequence_q.delete(i);
%000000         m_update_lists();
              end
%000000       else begin
%000000         i++;
              end
            end
          end
%000006   while (i < arb_sequence_q.size());
        
          // remove locks for this sequence, and any child sequences
%000006   i = 0;
%000006   do begin
            
%000006     if (lock_list.size() > i) begin
%000000       if ((lock_list[i].get_inst_id() == sequence_ptr.get_inst_id()) ||
%000000       (is_child(sequence_ptr, lock_list[i]))) begin
%000000         if (sequence_ptr.get_sequence_state() == UVM_FINISHED) begin
%000000           `uvm_error("SEQFINERR", $sformatf("Parent sequence '%s' should not finish before locks from itself and descedent sequences are removed.  The lock held by the child sequence '%s' is being removed.",sequence_ptr.get_full_name(), lock_list[i].get_full_name()))
                end
%000000         lock_list.delete(i);
%000000         m_update_lists();
              end
%000000       else begin
%000000         i++;
              end
            end
          end
%000006   while (i < lock_list.size());
        
          // Unregister the sequence_id, so that any returning data is dropped
%000006   m_unregister_sequence(sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 1));
        endfunction
        
        
        // stop_sequences
        // --------------
        
%000000 function void uvm_sequencer_base::stop_sequences();
%000000   uvm_sequence_base seq_ptr;
        
%000000   seq_ptr = m_find_sequence(-1);
%000000   while (seq_ptr != null) begin
            
%000000     kill_sequence(seq_ptr);
%000000     seq_ptr = m_find_sequence(-1);
          end
        endfunction
        
        
        // m_sequence_exiting
        // ------------------
        
%000006 function void uvm_sequencer_base::m_sequence_exiting(uvm_sequence_base sequence_ptr);
%000006   remove_sequence_from_queues(sequence_ptr);
        endfunction
        
        
        // kill_sequence
        // -------------
        
%000000 function void uvm_sequencer_base::kill_sequence(uvm_sequence_base sequence_ptr);
%000000   remove_sequence_from_queues(sequence_ptr);
%000000   sequence_ptr.m_kill();
        endfunction
        
        
        // is_grabbed
        // ----------
        
%000000 function bit uvm_sequencer_base::is_grabbed();
%000000   return (lock_list.size() != 0);
        endfunction
        
        
        // current_grabber
        // ---------------
        
%000000 function uvm_sequence_base uvm_sequencer_base::current_grabber();
%000000   if (lock_list.size() == 0) begin
%000000     return null;
          end
%000000   return lock_list[lock_list.size()-1];
        endfunction
        
        
        // has_do_available
        // ----------------
        
%000000 function bit uvm_sequencer_base::has_do_available();
        
%000000   foreach (arb_sequence_q[i]) begin
%000000     if ((arb_sequence_q[i].sequence_ptr.is_relevant() == 1) &&
%000000     (is_blocked(arb_sequence_q[i].sequence_ptr) == 0)) begin
%000000       return 1;
            end
          end
%000000   return 0;
        endfunction
        
        
        // set_arbitration
        // ---------------
        
%000000 function void uvm_sequencer_base::set_arbitration(uvm_sequencer_arb_mode val);
%000000   m_arbitration = val;
        endfunction
        
        
        // get_arbitration
        // ---------------
        
%000000 function uvm_sequencer_arb_mode uvm_sequencer_base::get_arbitration();
%000000   return m_arbitration;
        endfunction
        
        // get_arbitration_sequence
        // ---------------
%000000 function uvm_sequence_base uvm_sequencer_base::get_arbitration_sequence( int index);
%000000   return arb_sequence_q[index].sequence_ptr;
        endfunction
        
        
        // analysis_write
        // --------------
        
%000000 function void uvm_sequencer_base::analysis_write(uvm_sequence_item t);
%000000   return;
        endfunction
        
        
        // wait_for_sequences
        // ------------------
        
 001250 task uvm_sequencer_base::wait_for_sequences();
 001250   uvm_wait_for_nba_region();
        endtask
        
        
        
        // send_request
        // ------------
        
%000000 function void uvm_sequencer_base::send_request(uvm_sequence_base sequence_ptr,
                                                       uvm_sequence_item t,
                                                       bit rerandomize = 0);
%000000   return;
        endfunction
        
        
        // set_max_zero_time_wait_relevant_count
        // ------------
        
%000000 function void uvm_sequencer_base::set_max_zero_time_wait_relevant_count(int new_val) ;
%000000    m_max_zero_time_wait_relevant_count = new_val ;
        endfunction
        
        
        // start_phase_sequence
        // --------------------
        
 000039 function void uvm_sequencer_base::start_phase_sequence(uvm_phase phase);
 000039   uvm_resource_pool            rp = uvm_resource_pool::get();
 000039   uvm_resource_types::rsrc_q_t rq;
 000039   uvm_sequence_base            seq;
 000039   uvm_coreservice_t cs = uvm_coreservice_t::get();
 000039   uvm_factory                  f = cs.get_factory();
        
          // Has a default sequence been specified?
 000039   rq = rp.lookup_name({get_full_name(), ".", phase.get_name(), "_phase"},
 000039                       "default_sequence", null, 0);
 000039   uvm_resource_pool::sort_by_precedence(rq);
        
          // Look for the first one if the appropriate type
~000039   for (int i = 0; seq == null && i < rq.size(); i++) begin
%000000     uvm_resource_base rsrc = rq.get(i);
        
%000000     uvm_resource#(uvm_sequence_base)  sbr;
%000000     uvm_resource#(uvm_object_wrapper) owr;
        
            // uvm_config_db#(uvm_sequence_base)?
            // Priority is given to uvm_sequence_base because it is a specific sequence instance
            // and thus more specific than one that is dynamically created via the
            // factory and the object wrapper.
%000000     if ($cast(sbr, rsrc) && sbr != null) begin
%000000       seq = sbr.read(this);
%000000       if (seq == null) begin
                `uvm_info("UVM/SQR/PH/DEF/SB/NULL", {"Default phase sequence for phase '",
%000000         phase.get_name(),"' explicitly disabled"}, UVM_FULL)
%000000         return;
              end
            end
        
            // uvm_config_db#(uvm_object_wrapper)?
%000000     else if ($cast(owr, rsrc) && owr != null) begin
%000000       uvm_object_wrapper wrapper;
        
%000000       wrapper = owr.read(this);
%000000       if (wrapper == null) begin
                `uvm_info("UVM/SQR/PH/DEF/OW/NULL", {"Default phase sequence for phase '",
%000000         phase.get_name(),"' explicitly disabled"}, UVM_FULL)
%000000         return;
              end
        
%000000       if (!$cast(seq, f.create_object_by_type(wrapper, get_full_name(),
              wrapper.get_type_name()))
%000000       || seq == null) begin
                `uvm_warning("PHASESEQ", {"Default sequence for phase '",
%000000         phase.get_name(),"' %s is not a sequence type"})
%000000         return;
              end
            end
          end
        
%000000   if (seq == null) begin
            `uvm_info("PHASESEQ", {"No default phase sequence for phase '",
~000039     phase.get_name(),"'"}, UVM_FULL)
%000000     return;
          end
        
          `uvm_info("PHASESEQ", {"Starting default sequence '",
~000039                          seq.get_type_name(),"' for phase '", phase.get_name(),"'"}, UVM_FULL)
        
 000039   seq.print_sequence_info = 1;
 000039   seq.set_sequencer(this);
 000039   seq.reseed();
 000039   seq.set_starting_phase(phase);
        
%000000   if (seq.get_randomize_enabled() && !seq.randomize()) begin
            `uvm_warning("STRDEFSEQ", {"Randomization failed for default sequence '",
%000000     seq.get_type_name(),"' for phase '", phase.get_name(),"'"})
%000000     return;
          end
        
 000039   fork begin
 000039       uvm_sequence_process_wrapper w = new();
              // reseed this process for random stability
 000039       w.pid = process::self();
 000039       w.seq = seq;
 000039       w.pid.srandom(uvm_create_random_seed(seq.get_type_name(), this.get_full_name()));
 000039       m_default_sequences[phase] = w;
              // this will either complete naturally, or be killed later
 000039       seq.start(this);
 000039       m_default_sequences.delete(phase);
            end
          join_none
        
        endfunction
        
        // stop_phase_sequence
        // --------------------
        
 000039 function void uvm_sequencer_base::stop_phase_sequence(uvm_phase phase);
~000039     if (m_default_sequences.exists(phase)) begin
              `uvm_info("PHASESEQ",
              {"Killing default sequence '", m_default_sequences[phase].seq.get_type_name(),
%000000       "' for phase '", phase.get_name(), "'"}, UVM_FULL)
%000000       m_default_sequences[phase].seq.kill();
            end
 000039     else begin
              `uvm_info("PHASESEQ",
              {"No default sequence to kill for phase '", phase.get_name(), "'"},
~000039       UVM_FULL)
            end
        endfunction : stop_phase_sequence
        
        //------------------------------------------------------------------------------
        //
        // Class- uvm_sequence_request
        //
        //------------------------------------------------------------------------------
        
 001247 class uvm_sequence_request;
          bit        grant;
          int        sequence_id;
          int        request_id;
          int        item_priority;
          process    process_id;
          uvm_sequencer_base::seq_req_t  request;
          uvm_sequence_base sequence_ptr;
        endclass
        
