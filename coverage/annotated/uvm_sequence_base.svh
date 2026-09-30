//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014 Cisco Systems, Inc.
        // Copyright 2014-2017 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2017 Mentor Graphics Corporation
        // Copyright 2012-2026 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2014 Synopsys, Inc.
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
        // $File:     src/seq/uvm_sequence_base.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_sequence_base
        //
        // The uvm_sequence_base class provides the interfaces needed to create streams
        // of sequence items and/or other sequences.
        //
        // A sequence is executed by calling its <start> method, either directly
        // or invocation of any of the `uvm_do_* macros.
        //
        // Executing sequences via <start>:
        //
        // A sequence's <start> method has a ~parent_sequence~ argument that controls
        // whether <pre_do>, <mid_do>, and <post_do> are called *in the parent*
        // sequence. It also has a ~call_pre_post~ argument that controls whether its
        // <pre_body> and <post_body> methods are called.
        // In all cases, its <pre_start> and <post_start> methods are always called.
        //
        // When <start> is called directly, you can provide the appropriate arguments
        // according to your application.
        //
        // The sequence execution flow looks like this
        //
        // User code
        //
        //| sub_seq.randomize(...); // optional
        //| sub_seq.start(seqr, parent_seq, priority, call_pre_post)
        //|
        //
        // The following methods are called, in order
        //
        //|
        //|   sub_seq.pre_start()        (task)
        //|   sub_seq.pre_body()         (task)  if call_pre_post==1
        //|     parent_seq.pre_do(0)     (task)  if parent_sequence!=null
        //|     parent_seq.mid_do(this)  (func)  if parent_sequence!=null
        //|   sub_seq.body               (task)  YOUR STIMULUS CODE
        //|     parent_seq.post_do(this) (func)  if parent_sequence!=null
        //|   sub_seq.post_body()        (task)  if call_pre_post==1
        //|   sub_seq.post_start()       (task)
        //
        //
        // Executing sub-sequences via `uvm_do macros:
        //
        // A sequence can also be indirectly started as a child in the <body> of a
        // parent sequence. The child sequence's <start> method is called indirectly
        // by invoking any of the `uvm_do macros.
        // In these cases, <start> is called with
        // ~call_pre_post~ set to 0, preventing the started sequence's <pre_body> and
        // <post_body> methods from being called. During execution of the
        // child sequence, the parent's <pre_do>, <mid_do>, and <post_do> methods
        // are called.
        //
        // The sub-sequence execution flow looks like
        //
        // User code
        //
        //|
        //| `uvm_do_with_prior(seq_seq, { constraints }, priority)
        //|
        //
        // The following methods are called, in order
        //
        //|
        //|   sub_seq.pre_start()         (task)
        //|   parent_seq.pre_do(0)        (task)
        //|   parent_req.mid_do(sub_seq)  (func)
        //|     sub_seq.body()            (task)
        //|   parent_seq.post_do(sub_seq) (func)
        //|   sub_seq.post_start()        (task)
        //|
        //
        // Remember, it is the *parent* sequence's pre|mid|post_do that are called, not
        // the sequence being executed.
        //
        //
        // Executing sequence items via <start_item>/<finish_item> or `uvm_do macros:
        //
        // Items are started in the <body> of a parent sequence via calls to
        // <start_item>/<finish_item> or invocations of any of the `uvm_do
        // macros. The <pre_do>, <mid_do>, and <post_do> methods of the parent
        // sequence will be called as the item is executed.
        //
        // The sequence-item execution flow looks like
        //
        // User code
        //
        //| parent_seq.start_item(item, priority);
        //| item.randomize(...) [with {constraints}];
        //| parent_seq.finish_item(item);
        //|
        //| or
        //|
        //| `uvm_do_with_prior(item, constraints, priority)
        //|
        //
        // The following methods are called, in order
        //
        //|
        //|   sequencer.wait_for_grant(prior) (task) \ start_item  \
        //|   parent_seq.pre_do(1)            (task) /              \
        //|                                                      `uvm_do* macros
        //|   parent_seq.mid_do(item)         (func) \              /
        //|   sequencer.send_request(item)    (func)  \finish_item /
        //|   sequencer.wait_for_item_done()  (task)  /
        //|   parent_seq.post_do(item)        (func) /
        //
        // Attempting to execute a sequence via <start_item>/<finish_item>
        // will produce a run-time error.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 14.2.1
%000000 virtual class uvm_sequence_base extends uvm_sequence_item;
%000000   `uvm_object_abstract_utils(uvm_sequence_base)
        
        
          // This semaphore is provided to ensure that a sequence is only being
          // run from a single thread at a time.
          protected semaphore          m_sequence_state_mutex;
          protected uvm_sequence_state m_sequence_state;
%000003             int                m_next_transaction_id = 1;
%000003   local     int                m_priority = -1;
                    uvm_recorder       m_tr_recorder;
                    int                m_wait_for_grant_semaphore;
        
          // Each sequencer will assign a sequence id.  When a sequence is talking to multiple
          // sequencers, each sequence_id is managed separately
          protected int m_sqr_seq_ids[int];
        
          protected bit children_array[uvm_sequence_base];
        
          protected uvm_sequence_item response_queue[$];
%000003   protected int               response_queue_depth = 8;
          protected bit               response_queue_error_report_enabled;
        
          // Variable -- NODOCS -- do_not_randomize
          //
          // If set, prevents the sequence from being randomized before being executed
          // by the `uvm_do*() and `uvm_rand_send*() macros,
          // or as a default sequence.
          //
          // @uvm-compat , provided for compatibility with 1.2
          bit do_not_randomize;
        
          typedef uvm_process_guard#(uvm_sequence_base) m_guard_t;
          protected m_guard_t m_parent_process_guard;
          protected process  m_sequence_process;
          protected process  m_killing_process;
          local bit m_use_response_handler;
        
          // bits to detect if is_relevant()/wait_for_relevant() are implemented
          local bit is_rel_default;
          local bit wait_rel_default;
        
        
        
          // @uvm-ieee 1800.2-2020 auto 14.2.2.1
%000003   function new (string name = "uvm_sequence");
        
%000003     super.new(name);
%000003     m_sequence_state_mutex = new(1);
%000003     m_sequence_state = UVM_CREATED;
%000003     m_wait_for_grant_semaphore = 0;
%000003     m_init_phase_daps(1);
          endfunction
        
%000000   virtual  function bit get_randomize_enabled();
%000000      return (do_not_randomize == 0);
          endfunction : get_randomize_enabled
        
          // @uvm-ieee 1800.2-2020 auto 14.2.2.3
%000000   virtual  function void set_randomize_enabled(bit enable);
%000000      do_not_randomize = !enable;
          endfunction : set_randomize_enabled
          
        
          // Function -- NODOCS -- is_item
          //
          // Returns 1 on items and 0 on sequences. As this object is a sequence,
          // ~is_item~ will always return 0.
          //
%000000   virtual function bit is_item();
%000000     return 0;
          endfunction
        
        
          // Function -- NODOCS -- get_sequence_state
          //
          // Returns the sequence state as an enumerated value. Can use to wait on
          // the sequence reaching or changing from one or more states.
          //
          //| wait(get_sequence_state() & (UVM_STOPPED|UVM_FINISHED));
        
          // @uvm-ieee 1800.2-2020 auto 14.2.2.4
%000000   function uvm_sequence_state_enum get_sequence_state();
%000000     return m_sequence_state;
          endfunction
        
        
          // Task -- NODOCS -- wait_for_sequence_state
          // 
          // Waits until the sequence reaches one of the given ~state~. If the sequence
          // is already in one of the state, this method returns immediately.
          //
          //| wait_for_sequence_state(UVM_STOPPED|UVM_FINISHED);
        
          // @uvm-ieee 1800.2-2020 auto 14.2.2.5
%000000   task wait_for_sequence_state(int unsigned state_mask);
%000000     wait (m_sequence_state & state_mask);
          endtask
        
        
          // Function -- NODOCS -- get_tr_handle
          //
          // Returns the integral recording transaction handle for this sequence.
          // Can be used to associate sub-sequences and sequence items as
          // child transactions when calling <uvm_component::begin_child_tr>.
        
%000000   function int get_tr_handle();
%000000      if (m_tr_recorder != null) begin
               
%000000        return m_tr_recorder.get_handle();
             end
        
%000000      else begin
               
%000000        return 0;
             end
        
          endfunction
        
        
          //--------------------------
          // Group -- NODOCS -- Sequence Execution
          //--------------------------
        
        
          // Task -- NODOCS -- start
          //
          // Executes this sequence, returning when the sequence has completed.
          //
          // The ~sequencer~ argument specifies the sequencer on which to run this
          // sequence. The sequencer must be compatible with the sequence.
          //
          // If ~parent_sequence~ is ~null~, then this sequence is a root parent,
          // otherwise it is a child of ~parent_sequence~. The ~parent_sequence~'s
          // pre_do, mid_do, and post_do methods will be called during the execution
          // of this sequence.
          //
          // By default, the ~priority~ of a sequence
          // is the priority of its parent sequence.
          // If it is a root sequence, its default priority is 100.
          // A different priority may be specified by ~this_priority~.
          // Higher numbers indicate higher priority.
          //
          // If ~call_pre_post~ is set to 1 (default), then the <pre_body> and
          // <post_body> tasks will be called before and after the sequence
          // <body> is called.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.1
%000003   virtual task start (uvm_sequencer_base sequencer,
                              uvm_sequence_base parent_sequence = null,
                              int this_priority = -1,
                              bit call_pre_post = 1);
%000003     bit                  old_automatic_phase_objection;
        
%000003     set_item_context(parent_sequence, sequencer);
        
%000003     if (m_sequence_state_mutex.try_get(1) == 0) begin
%000000       uvm_report_fatal("SEQ_NOT_DONE",
%000000          {"Sequence ", get_full_name(), " already started"},UVM_NONE);
            end
        
%000003     m_parent_process_guard = new("uvm_sequence_base::start_guard", this);
            
%000003     if (m_parent_sequence != null) begin
%000000       m_parent_sequence.children_array[this] = 1;
            end
        
%000003     if (this_priority < -1) begin
%000000       uvm_report_fatal("SEQPRI", $sformatf("Sequence %s start has illegal priority: %0d",
%000000                                            get_full_name(),
%000000                                            this_priority), UVM_NONE);
            end
%000003     if (this_priority < 0) begin
%000003       if (parent_sequence == null) begin
%000003         this_priority = 100;
              end
        
%000000       else begin
%000000         this_priority = parent_sequence.get_priority();
              end
        
            end
        
            // Check that the response queue is empty from earlier runs
%000003     clear_response_queue();
        
%000003     m_priority           = this_priority;
        
%000003     if (m_sequencer != null) begin
%000003       int handle;
%000003       if (m_parent_sequence == null) begin
%000003         handle = m_sequencer.begin_tr(this, get_name());
%000003         m_tr_recorder = uvm_recorder::get_recorder_from_handle(handle);
%000000       end else begin
%000000         handle = m_sequencer.begin_tr(.tr(this), .stream_name(get_root_sequence_name()),
%000000                                         .parent_handle((m_parent_sequence.m_tr_recorder == null) ? 0 : m_parent_sequence.m_tr_recorder.get_handle()));                                          
%000000         m_tr_recorder = uvm_recorder::get_recorder_from_handle(handle);
              end
            end
        
             // Ensure that the sequence_id is intialized in case this sequence has been stopped previously
%000003     set_sequence_id(-1);
        
            // Register the sequence with the sequencer if defined.
%000003     if (m_sequencer != null) begin
%000003       void'(m_sequencer.m_register_sequence(this));
            end
        
            // Change the state to PRE_START, do this before the fork so that
            // the "if (!(m_sequence_state inside {...}" works
%000003     m_sequence_state = UVM_PRE_START;
%000003     fork
%000003       begin
%000003         m_sequence_process = process::self();
        
                // absorb delta to ensure PRE_START was seen
%000003         #0;
        
                // Raise the objection if enabled
                // (This will lock the uvm_get_to_lock_dap)
%000003         if (get_automatic_phase_objection()) begin
%000000           m_safe_raise_starting_phase("automatic phase objection");
                end
        
%000003         pre_start();
        
%000003         if (call_pre_post == 1) begin
%000003           m_sequence_state = UVM_PRE_BODY;
%000003           #0;
%000003           pre_body();
                end
        
%000003         if (parent_sequence != null) begin
%000000           parent_sequence.pre_do(0);    // task
%000000           parent_sequence.mid_do(this); // function
                end
        
%000003         m_sequence_state = UVM_BODY;
%000003         #0;
%000003         body();
        
%000003         m_sequence_state = UVM_ENDED;
%000003         #0;
        
%000003         if (parent_sequence != null) begin
%000000           parent_sequence.post_do(this);
                end
        
%000003         if (call_pre_post == 1) begin
%000003           m_sequence_state = UVM_POST_BODY;
%000003           #0;
%000003           post_body();
                end
        
%000003         m_sequence_state = UVM_POST_START;
%000003         #0;
%000003         post_start();
        
                // Drop the objection if enabled
%000003         if (get_automatic_phase_objection()) begin
%000000           m_safe_drop_starting_phase("automatic phase objection");
                end
        
%000003         m_sequence_state = UVM_FINISHED;
%000003         #0;
        
              end
            join
        
%000003     m_sequence_process = null;
        
            // If we're being killed, wait for that to complete
%000003     if (m_killing_process != null) begin
%000000       fork : kill_guard
%000000         begin
%000000           fork
%000000             begin
%000000               wait (m_killing_process == null); // Kill proceeded without issue
                    end
%000000             begin
%000000               m_killing_process.await(); // Killing process was killed (likely a "this.kill()")
%000000               m_killed(); // We have to finish the kill() in this case
                    end
                  join_any
%000000           disable fork;
                end
              join : kill_guard
            end
        
        
%000003     if ((m_sequence_state != UVM_FINISHED) &&
%000000         (m_sequence_state != UVM_STOPPED)) begin
              `uvm_warning("SEQBDYZMB",
%000000                    $sformatf("The child process forked by start() on sequence '%s' was terminated without killing the sequence, perhaps by an errant \"disable fork.\"  The kill() method is being automatically triggered.", get_full_name()))
%000000       this.kill();
            end
        
%000003     if (m_sequencer != null) begin
%000003       m_sequencer.end_tr(this);
            end
        
            // Clean up any sequencer queues after exiting; if we
            // were forcibly stopped, this step has already taken place
%000003     if (m_sequence_state != UVM_STOPPED) begin
%000003       clean_exit_sequence();
            end
        
%000003     #0; // allow stopped and finish waiters to resume
        
%000003     if ((m_parent_sequence != null) && (m_parent_sequence.children_array.exists(this))) begin
%000000       m_parent_sequence.children_array.delete(this);
            end
        
%000003     old_automatic_phase_objection = get_automatic_phase_objection();
%000003     m_init_phase_daps(1);
%000003     set_automatic_phase_objection(old_automatic_phase_objection);
          endtask
        
          // Function -- NODOCS -- clean_exit_sequence
          // This function is for Clean up any sequencer queues after exiting; if we
          // were forcibly stopped, this step has already taken place
        
%000003    function void clean_exit_sequence();
%000003      if (m_sequencer != null) begin
%000003        m_sequencer.m_sequence_exiting(this);     
             end
             // remove any routing for this sequence even when virtual sequencers (or a null sequencer is involved)
             // once we pass this point nothing can be routed to this sequence(id)
%000003      foreach(m_sqr_seq_ids[seqrID]) begin
%000003        uvm_sequencer_base s = uvm_sequencer_base::all_sequencer_insts[seqrID];
%000003        s.m_sequence_exiting(this);
             end    
%000003      m_sqr_seq_ids.delete();
            // Release the state mutex to allow for re-use (not recommended)
%000003     m_sequence_state_mutex.put(1);
            // This can be null if start_item/finish_item is called manually without
            // causing the sequence to be removed from the sequencer (e.g. RAL)
%000003     if (m_parent_process_guard != null) begin
%000003       void'(m_parent_process_guard.clear());
            end
         endfunction
         
        
          // Task -- NODOCS -- pre_start
          //
          // This task is a user-definable callback that is called before the
          // optional execution of <pre_body>.
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.2
%000003   virtual task pre_start();
%000003     return;
          endtask
        
        
          // Task -- NODOCS -- pre_body
          //
          // This task is a user-definable callback that is called before the
          // execution of <body> ~only~ when the sequence is started with <start>.
          // If <start> is called with ~call_pre_post~ set to 0, ~pre_body~ is not
          // called.
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.3
%000003   virtual task pre_body();
%000003     return;
          endtask
        
        
          // Task -- NODOCS -- pre_do
          //
          // This task is a user-definable callback task that is called ~on the
          // parent sequence~, if any
          // sequence has issued a wait_for_grant() call and after the sequencer has
          // selected this sequence, and before the item is randomized.
          //
          // Although pre_do is a task, consuming simulation cycles may result in
          // unexpected behavior on the driver.
          //
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.4
 000257   virtual task pre_do(bit is_item);
 000257     return;
          endtask
        
        
          // Function -- NODOCS -- mid_do
          //
          // This function is a user-definable callback function that is called after
          // the sequence item has been randomized, and just before the item is sent
          // to the driver.  This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.5
 000257   virtual function void mid_do(uvm_sequence_item this_item);
 000257     return;
          endfunction
          
          
          // Task -- NODOCS -- body
          //
          // This is the user-defined task where the main sequence code resides.
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.6
%000000   virtual task body();
%000000     uvm_report_warning("uvm_sequence_base", "Body definition undefined");
%000000     return;
          endtask
        
        
          // Function -- NODOCS -- post_do
          //
          // This function is a user-definable callback function that is called after
          // the driver has indicated that it has completed the item, using either
          // this item_done or put methods. This method should not be called directly
          // by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.7
 000257   virtual function void post_do(uvm_sequence_item this_item);
 000257     return;
          endfunction
        
        
          // Task -- NODOCS -- post_body
          //
          // This task is a user-definable callback task that is called after the
          // execution of <body> ~only~ when the sequence is started with <start>.
          // If <start> is called with ~call_pre_post~ set to 0, ~post_body~ is not
          // called.
          // This task is a user-definable callback task that is called after the
          // execution of the body, unless the sequence is started with call_pre_post=0.
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.8
%000003   virtual task post_body();
%000003     return;
          endtask
        
        
          // Task -- NODOCS -- post_start
          //
          // This task is a user-definable callback that is called after the
          // optional execution of <post_body>.
          // This method should not be called directly by the user.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.3.9
%000003   virtual task post_start();
%000003     return;
          endtask
        
        
          // Group -- NODOCS -- Run-Time Phasing
          //
        
          // Automatic Phase Objection DAP
          local uvm_get_to_lock_dap#(bit) m_automatic_phase_objection_dap;
          // Starting Phase DAP
          local uvm_get_to_lock_dap#(uvm_phase) m_starting_phase_dap;
        
          // @uvm-compat For compatibility with UVM 1.1d
          uvm_phase starting_phase;
          
          // Function- m_init_phase_daps
          // Either creates or renames DAPS
%000006   function void m_init_phase_daps(bit create);
%000006      string apo_name = $sformatf("%s.automatic_phase_objection", get_full_name());
%000006      string sp_name = $sformatf("%s.starting_phase", get_full_name());
        
%000006      if (create) begin
%000006        m_automatic_phase_objection_dap = uvm_get_to_lock_dap#(bit)::type_id::create(apo_name, get_sequencer());
%000006        m_starting_phase_dap = uvm_get_to_lock_dap#(uvm_phase)::type_id::create(sp_name, get_sequencer());
             end
%000000      else begin
%000000        m_automatic_phase_objection_dap.set_name(apo_name);
%000000        m_starting_phase_dap.set_name(sp_name);
             end
          endfunction : m_init_phase_daps
        
          // Function -- NODOCS -- get_starting_phase
          // Returns the 'starting phase'.
          //
          // If non-~null~, the starting phase specifies the phase in which this
          // sequence was started.  The starting phase is set automatically when
          // this sequence is started as the default sequence on a sequencer.
          // See <uvm_sequencer_base::start_phase_sequence> for more information.
          //
          // Internally, the <uvm_sequence_base> uses an <uvm_get_to_lock_dap> to 
          // protect the starting phase value from being modified 
          // after the reference has been read.  Once the sequence has ended 
          // its execution (either via natural termination, or being killed),
          // then the starting phase value can be modified again.
          //
          // @uvm-ieee 1800.2-2020 auto 14.2.4.1
%000000   function uvm_phase get_starting_phase();
%000000     uvm_phase sp;
            
            // If we're not locked, use the starting_phase variable
%000000     if (!m_starting_phase_dap.is_locked() && starting_phase != null) begin
              
%000000       m_starting_phase_dap.set(starting_phase);
            end
        
        
            // Get the DAP value (and lock it)
%000000     sp = m_starting_phase_dap.get();
        
            // Throw an error if starting_phase != dap.get()
%000000     if (sp!=starting_phase) begin
              `uvm_error("UVM/SEQ/SP/GET",
              $sformatf("The starting_phase variable was set to '%s' after a call to get_starting_phase locked the value '%s'.  The new value is ignored.",
              (starting_phase == null) ? "<null>" : starting_phase.get_name(),
%000000       (sp == null) ? "<null>" : sp.get_name()))
            end
%000000     return sp;
          endfunction : get_starting_phase
        
        
          // @uvm-ieee 1800.2-2020 auto 14.2.4.2
%000000   function void set_starting_phase(uvm_phase phase);
%000000     if (!m_starting_phase_dap.try_set(phase)) begin
              // Too late to update starting phase
%000000       uvm_phase sp;
%000000       sp = m_starting_phase_dap.get();
              `uvm_error("UVM/SEQ/SP/SET",
              $sformatf("The starting_phase variable was set to '%s' after a call to get_starting_phase locked the value at '%s'.  The new value is ignored.",
              (phase == null) ? "<null>" : phase.get_name(),
%000000       (sp == null) ? "<null>" : sp.get_name()))
            end
%000000     else begin
              // Update the starting_phase variable
%000000       starting_phase = phase;
            end
          endfunction : set_starting_phase
           
        
          // @uvm-ieee 1800.2-2020 auto 14.2.4.4
%000003   function void set_automatic_phase_objection(bit value);
%000003      m_automatic_phase_objection_dap.set(value);
          endfunction : set_automatic_phase_objection
        
        
          // @uvm-ieee 1800.2-2020 auto 14.2.4.3
%000009   function bit get_automatic_phase_objection();
%000009      return m_automatic_phase_objection_dap.get();
          endfunction : get_automatic_phase_objection
        
          // m_safe_raise_starting_phase
%000000   function void m_safe_raise_starting_phase(string description = "",
%000000                                             int count = 1);
%000000      uvm_phase starting_phase = get_starting_phase();
%000000      if (starting_phase != null) begin
               
%000000        starting_phase.raise_objection(this, description, count);
             end
        
          endfunction : m_safe_raise_starting_phase
        
          // m_safe_drop_starting_phase
%000000   function void m_safe_drop_starting_phase(string description = "",
%000000                                            int count = 1);
%000000      uvm_phase starting_phase = get_starting_phase();
%000000      if (starting_phase != null) begin
               
%000000        starting_phase.drop_objection(this, description, count);
             end
        
          endfunction : m_safe_drop_starting_phase
        
          //------------------------
          // Group -- NODOCS -- Sequence Control
          //------------------------
        
          // Function -- NODOCS -- set_priority
          //
          // The priority of a sequence may be changed at any point in time.  When the
          // priority of a sequence is changed, the new priority will be used by the
          // sequencer the next time that it arbitrates between sequences.
          //
          // The default priority value for a sequence is 100.  Higher values result
          // in higher priorities.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.2
%000000   function void set_priority (int value);
%000000     m_priority = value;
          endfunction
        
        
          // Function -- NODOCS -- get_priority
          //
          // This function returns the current priority of the sequence.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.1
 000257   function int get_priority();
 000257     return m_priority;
          endfunction
        
        
          // Function -- NODOCS -- is_relevant
          //
          // The default is_relevant implementation returns 1, indicating that the
          // sequence is always relevant.
          //
          // Users may choose to override with their own virtual function to indicate
          // to the sequencer that the sequence is not currently relevant after a
          // request has been made.
          //
          // When the sequencer arbitrates, it will call is_relevant on each requesting,
          // unblocked sequence to see if it is relevant. If a 0 is returned, then the
          // sequence will not be chosen.
          //
          // If all requesting sequences are not relevant, then the sequencer will call
          // wait_for_relevant on all sequences and re-arbitrate upon its return.
          //
          // Any sequence that implements is_relevant must also implement
          // wait_for_relevant so that the sequencer has a way to wait for a
          // sequence to become relevant.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.3
 000257   virtual function bit is_relevant();
 000257     is_rel_default = 1;
 000257     return 1;
          endfunction
        
        
          // Task -- NODOCS -- wait_for_relevant
          //
          // This method is called by the sequencer when all available sequences are
          // not relevant.  When wait_for_relevant returns the sequencer attempt to
          // re-arbitrate.
          //
          // Returning from this call does not guarantee a sequence is relevant,
          // although that would be the ideal. The method provide some delay to
          // prevent an infinite loop.
          //
          // If a sequence defines is_relevant so that it is not always relevant (by
          // default, a sequence is always relevant), then the sequence must also supply
          // a wait_for_relevant method.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.4
%000000   virtual task wait_for_relevant();
            event e;
%000000     wait_rel_default = 1;
%000000     if (is_rel_default != wait_rel_default) begin
              
%000000       uvm_report_fatal("RELMSM",
%000000         "is_relevant() was implemented without defining wait_for_relevant()", UVM_NONE);
            end
        
%000000     @e;  // this is intended to never return
          endtask
        
        
          // Task -- NODOCS -- lock
          //
          // Requests a lock on the specified sequencer. If sequencer is ~null~, the lock
          // will be requested on the current default sequencer.
          //
          // A lock request will be arbitrated the same as any other request.  A lock is
          // granted after all earlier requests are completed and no other locks or
          // grabs are blocking this sequence.
          //
          // The lock call will return when the lock has been granted.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.5
%000000   task lock(uvm_sequencer_base sequencer = null);
%000000     if (sequencer == null) begin
              
%000000       sequencer = m_sequencer;
            end
        
        
%000000     if (sequencer == null) begin
              
%000000       uvm_report_fatal("LOCKSEQR", "Null m_sequencer reference", UVM_NONE);
            end
        
        
%000000     sequencer.lock(this);
          endtask
        
        
          // Task -- NODOCS -- grab
          // 
          // Requests a lock on the specified sequencer.  If no argument is supplied,
          // the lock will be requested on the current default sequencer.
          //
          // A grab request is put in front of the arbitration queue. It will be
          // arbitrated before any other requests. A grab is granted when no other grabs
          // or locks are blocking this sequence.
          //
          // The grab call will return when the grab has been granted.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.6
%000000   task grab(uvm_sequencer_base sequencer = null);
%000000     if (sequencer == null) begin
%000000       if (m_sequencer == null) begin
%000000         uvm_report_fatal("GRAB", "Null m_sequencer reference", UVM_NONE);
              end
%000000       m_sequencer.grab(this);
            end
%000000     else begin
%000000       sequencer.grab(this);
            end
          endtask
        
        
          // Function -- NODOCS -- unlock
          //
          // Removes any locks or grabs obtained by this sequence on the specified
          // sequencer. If sequencer is ~null~, then the unlock will be done on the
          // current default sequencer.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.7
%000000   function void  unlock(uvm_sequencer_base sequencer = null);
%000000     if (sequencer == null) begin
%000000       if (m_sequencer == null) begin
%000000         uvm_report_fatal("UNLOCK", "Null m_sequencer reference", UVM_NONE);
              end
%000000       m_sequencer.unlock(this);
%000000     end else begin
%000000       sequencer.unlock(this);
            end
          endfunction
        
        
          // Function -- NODOCS -- ungrab
          //
          // Removes any locks or grabs obtained by this sequence on the specified
          // sequencer. If sequencer is ~null~, then the unlock will be done on the
          // current default sequencer.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.8
%000000   function void  ungrab(uvm_sequencer_base sequencer = null);
%000000     unlock(sequencer);
          endfunction
        
        
          // Function -- NODOCS -- is_blocked
          //
          // Returns a bit indicating whether this sequence is currently prevented from
          // running due to another lock or grab. A 1 is returned if the sequence is
          // currently blocked. A 0 is returned if no lock or grab prevents this
          // sequence from executing. Note that even if a sequence is not blocked, it
          // is possible for another sequence to issue a lock or grab before this
          // sequence can issue a request.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.9
%000000   function bit is_blocked();
%000000     return m_sequencer.is_blocked(this);
          endfunction
        
        
          // Function -- NODOCS -- has_lock
          //
          // Returns 1 if this sequence has a lock, 0 otherwise.
          //
          // Note that even if this sequence has a lock, a child sequence may also have
          // a lock, in which case the sequence is still blocked from issuing
          // operations on the sequencer.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.10
%000000   function bit has_lock();
%000000     return m_sequencer.has_lock(this);
          endfunction
        
        
          // Function -- NODOCS -- kill
          //
          // This function will kill the sequence, and cause all current locks and
          // requests in the sequence's default sequencer to be removed. The sequence
          // state will change to UVM_STOPPED, and the post_body() and post_start() callback
          // methods will not be executed.
          //
          // If a sequence has issued locks, grabs, or requests on sequencers other than
          // the default sequencer, then care must be taken to unregister the sequence
          // with the other sequencer(s) using the sequencer unregister_sequence()
          // method.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.11
%000000   function void kill();
            // If there's no child process, then the sequence isn't running
%000000     if (m_sequence_process != null) begin
              // If we are not connected to a sequencer, then issue
              // kill locally.
%000000       if (m_sequencer == null) begin
%000000         m_kill();
                // We need to drop the objection if we raised it...
%000000         if (get_automatic_phase_objection()) begin
%000000           m_safe_drop_starting_phase("automatic phase objection");
                end
%000000         return;
              end
              // If we are attached to a sequencer, then the sequencer
              // will clear out queues, and then kill this sequence
%000000       m_sequencer.kill_sequence(this);
              // We need to drop the objection if we raised it...
%000000       if (get_automatic_phase_objection()) begin
%000000         m_safe_drop_starting_phase("automatic phase objection");
              end
%000000       return;
            end
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 14.2.5.12
%000000   virtual function void do_kill();
%000000     return;
          endfunction
        
          // Function: kill_child_sequences
          // Calls <kill> on all children sequences currently registered with this
          // sequence.
          //
          // This method is automatically called by <kill_sequence_activity>.
          //
          // @uvm-contrib: For potential contribution to 1800.2
%000000   function void kill_child_sequences();
%000000     foreach(children_array[i]) begin
%000000       i.kill();
            end
          endfunction : kill_child_sequences
        
          // Function: kill_sequence_activity
          // Kills any processes spawned by <start>, as well as any child sequences currently
          // registered with this sequence.
          //
          // This method is automatically called after the <do_kill> hook
          // completes during a <kill> operation.  The user may manually call this method
          // within a <do_kill> implementation to allow proper cleanup of exclusive resources
          // being accessed by the sequence.
          //
          // Calling <kill_sequence_activity> outside of a <kill> operation shall result in <kill>
          // being called automatically.
          // 
          // @uvm-contrib: For potential contribution to 1800.2
%000000   function void kill_sequence_activity();
%000000     if (m_killing_process == null) begin
%000000       `uvm_warning("UVM/SEQ/KILL_SEQ_PROC", "kill_sequence_activity called outside of kill, kill shall be automatically called.")
%000000       this.kill();
%000000       return;
            end
            // Children sequences need to be killed first to prevent zombies.
%000000     kill_child_sequences();
            // Kill sequence process, at which point the start() method will finish
            // the kill.
%000000     if (m_sequence_process != null) begin
%000000       m_sequence_process.kill();
%000000       m_sequence_process = null;
            end
          endfunction : kill_sequence_activity
        
          // Clears the sequence state after a kill() operation.  Either
          // called by m_kill(), or start().
%000000   function void m_killed();
%000000     m_sequence_state = UVM_STOPPED;
%000000     if ((m_parent_sequence != null) && (m_parent_sequence.children_array.exists(this))) begin
%000000       m_parent_sequence.children_array.delete(this);
            end
        
%000000     clean_exit_sequence();
%000000     m_killing_process = null;
          endfunction
        
%000000   function void m_kill();
%000000     m_killing_process = process::self();
%000000     do_kill();
%000000     kill_sequence_activity();
%000000     m_killed();
          endfunction : m_kill
        
%000000   function void process_guard_triggered(m_guard_t guard);
%000000     if (guard == m_parent_process_guard) begin
%000000       bit skip_warn_on_parent_termination;
%000000       uvm_phase run_phase;
        
%000000       run_phase = uvm_domain::find_common_phase(uvm_run_phase::get());
        `ifndef UVM_SEQPRTZMB_WARN_ON_TEST_END
%000000       if ((run_phase != null) &&
%000000           (run_phase.get_state() inside {UVM_PHASE_CLEANUP, UVM_PHASE_DONE})) begin
%000000         skip_warn_on_parent_termination = 1;
              end
        `endif
        
%000000       if (!skip_warn_on_parent_termination) begin
                `uvm_warning("SEQPRTZMB",
%000000                      $sformatf("The parent process that called start() on sequence '%s' was terminated without killing the sequence.  The kill() method is being automatically triggered.", get_full_name()))
              end
%000000       this.kill();
            end
          endfunction : process_guard_triggered
        
          //-------------------------------
          // Group -- NODOCS -- Sequence Item Execution
          //-------------------------------
        
          // Function -- NODOCS -- create_item
          //
          // Create_item will create and initialize a sequence_item or sequence
          // using the factory.  The sequence_item or sequence will be initialized
          // to communicate with the specified sequencer.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.1
%000000   protected function uvm_sequence_item create_item(uvm_object_wrapper type_var,
                                                           uvm_sequencer_base l_sequencer, string name);
        
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000     uvm_factory factory=cs.get_factory();
%000000     $cast(create_item,  factory.create_object_by_type( type_var, this.get_full_name(), name ));
        
%000000     create_item.set_item_context(this, l_sequencer);
          endfunction
        
        
          // Function -- NODOCS -- start_item
          //
          // ~start_item~ and <finish_item> together will initiate operation of
          // a sequence item.  If the item has not already been
          // initialized using create_item, then it will be initialized here to use
          // the default sequencer specified by m_sequencer.  Randomization
          // may be done between start_item and finish_item to ensure late generation
          //
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.2
 000257   virtual task start_item (uvm_sequence_item item,
                                   int set_priority = -1,
                                   uvm_sequencer_base sequencer=null);
        
~000257     if(item == null) begin
%000000       uvm_report_fatal("NULLITM",
%000000          {"attempting to start a null item from sequence '",
%000000           get_full_name(), "'"}, UVM_NONE);
%000000       return;
            end
        
~000257     if ( ! item.is_item() ) begin
%000000       uvm_report_fatal("SEQNOTITM",
%000000          {"attempting to start a sequence using start_item() from sequence '",
%000000           get_full_name(), "'. Use seq.start() instead."}, UVM_NONE);
%000000       return;
            end
        
~000257     if (sequencer == null) begin
                
 000257       sequencer = item.get_sequencer();
            end
        
        
~000257     if(sequencer == null) begin
                
 000257       sequencer = get_sequencer();
            end
        
        
~000257     if(sequencer == null) begin
%000000       uvm_report_fatal("SEQ",{"neither the item's sequencer nor dedicated sequencer has been supplied to start item in ",get_full_name()},UVM_NONE);
%000000       return;
            end
        
 000257     item.set_item_context(this, sequencer);
        
~000257     if (set_priority < 0) begin
              
 000257       set_priority = get_priority();
            end
        
        
 000257     sequencer.wait_for_grant(this, set_priority);
        
~000257     if (sequencer.is_auto_item_recording_enabled()) begin
 000257       void'(sequencer.begin_tr(.tr(item), .stream_name(item.get_root_sequence_name()), .label("Transactions"),
 000257                                .parent_handle((m_tr_recorder == null) ? 0 : m_tr_recorder.get_handle())));                                     
            end
        
 000257     pre_do(1);
        
          endtask
        
        
          // Function -- NODOCS -- finish_item
          //
          // finish_item, together with start_item together will initiate operation of
          // a sequence_item.  Finish_item must be called
          // after start_item with no delays or delta-cycles.  Randomization, or other
          // functions may be called between the start_item and finish_item calls.
          //
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.3
 000257   virtual task finish_item (uvm_sequence_item item,
                                    int set_priority = -1);
        
 000257     uvm_sequencer_base sequencer;
        
 000257     sequencer = item.get_sequencer();
        
~000257     if (sequencer == null) begin
%000000       uvm_report_fatal("STRITM", "sequence_item has null sequencer", UVM_NONE);
            end
        
 000257     mid_do(item);
 000257     sequencer.send_request(this, item);
 000257     sequencer.wait_for_item_done(this, -1);
        
~000257     if (sequencer.is_auto_item_recording_enabled()) begin
 000257       sequencer.end_tr(item);
            end
        
 000257     post_do(item);
        
          endtask
        
          
          // Task -- NODOCS -- wait_for_grant
          //
          // This task issues a request to the current sequencer.  If item_priority is
          // not specified, then the current sequence priority will be used by the
          // arbiter. If a lock_request is made, then the sequencer will issue a lock
          // immediately before granting the sequence.  (Note that the lock may be
          // granted without the sequence being granted if is_relevant is not asserted).
          //
          // When this method returns, the sequencer has granted the sequence, and the
          // sequence must call send_request without inserting any simulation delay
          // other than delta cycles.  The driver is currently waiting for the next
          // item to be sent via the send_request call.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.4
%000000   virtual task wait_for_grant(int item_priority = -1, bit lock_request = 0);
%000000     if (m_sequencer == null) begin
%000000       uvm_report_fatal("WAITGRANT", "Null m_sequencer reference", UVM_NONE);
            end
%000000     m_sequencer.wait_for_grant(this, item_priority, lock_request);
          endtask
        
        
          // Function -- NODOCS -- send_request
          //
          // The send_request function may only be called after a wait_for_grant call.
          // This call will send the request item to the sequencer, which will forward
          // it to the driver. If the rerandomize bit is set, the item will be
          // randomized before being sent to the driver.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.5
%000000   virtual function void send_request(uvm_sequence_item request, bit rerandomize = 0);
%000000     if (m_sequencer == null) begin
%000000       uvm_report_fatal("SENDREQ", "Null m_sequencer reference", UVM_NONE);
            end
%000000     m_sequencer.send_request(this, request, rerandomize);
          endfunction
        
        
          // Task -- NODOCS -- wait_for_item_done
          //
          // A sequence may optionally call wait_for_item_done.  This task will block
          // until the driver calls item_done or put.  If no transaction_id parameter
          // is specified, then the call will return the next time that the driver calls
          // item_done or put.  If a specific transaction_id is specified, then the call
          // will return when the driver indicates completion of that specific item.
          //
          // Note that if a specific transaction_id has been specified, and the driver
          // has already issued an item_done or put for that transaction, then the call
          // will hang, having missed the earlier notification.
        
        
          // @uvm-ieee 1800.2-2020 auto 14.2.6.6
%000000   virtual task wait_for_item_done(int transaction_id = -1);
%000000     if (m_sequencer == null) begin
%000000       uvm_report_fatal("WAITITEMDONE", "Null m_sequencer reference", UVM_NONE);
            end
%000000     m_sequencer.wait_for_item_done(this, transaction_id);
          endtask
        
        
        
          // Group -- NODOCS -- Response API
          //--------------------
        
          // Function -- NODOCS -- use_response_handler
          //
          // When called with enable set to 1, responses will be sent to the response
          // handler. Otherwise, responses must be retrieved using get_response.
          //
          // By default, responses from the driver are retrieved in the sequence by
          // calling get_response.
          //
          // An alternative method is for the sequencer to call the response_handler
          // function with each response.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.1
%000000   function void use_response_handler(bit enable);
%000000     m_use_response_handler = enable;
          endfunction
        
        
          // Function -- NODOCS -- get_use_response_handler
          //
          // Returns the state of the use_response_handler bit.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.2
%000000   function bit get_use_response_handler();
%000000     return m_use_response_handler;
          endfunction
        
        
          // Function -- NODOCS -- response_handler
          //
          // When the use_response_handler bit is set to 1, this virtual task is called
          // by the sequencer for each response that arrives for this sequence.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.3
%000000   virtual function void response_handler(uvm_sequence_item response);
%000000     return;
          endfunction
        
          // Function -- NODOCS -- set_response_queue_error_report_enabled
          //
          // By default, if the internal response queue overflows, an error is
          // reported.  The response queue will overflow if more responses are
          // sent to this from the driver than ~get_response~ calls are made.
          //
          // Setting the value to '0' disables these errors, while setting it to
          // '1' enables them.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.5
%000000   function void set_response_queue_error_report_enabled(bit value);
%000000     response_queue_error_report_enabled = value;
          endfunction : set_response_queue_error_report_enabled
        
          // @uvm-compat provided for compatibility with 1.2
%000000   function void set_response_queue_error_report_disabled(bit value);
%000000     response_queue_error_report_enabled = ~value;
          endfunction : set_response_queue_error_report_disabled
        
          // Function -- NODOCS -- get_response_queue_error_report_enabled
          //
          // When this bit is '1' (default value), error reports are generated when
          // the response queue overflows.  When this bit is '0', no such error
          // reports are generated.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.4
%000000   function bit get_response_queue_error_report_enabled();
%000000     return response_queue_error_report_enabled;
          endfunction : get_response_queue_error_report_enabled
        
          // @uvm-compat provided for compatibility with 1.2
%000000   function bit get_response_queue_error_report_disabled();
%000000     return ~response_queue_error_report_enabled;
          endfunction : get_response_queue_error_report_disabled
        
          // Function -- NODOCS -- set_response_queue_depth
          //
          // The default maximum depth of the response queue is 8. These method is used
          // to examine or change the maximum depth of the response queue.
          //
          // Setting the response_queue_depth to -1 indicates an arbitrarily deep
          // response queue.  No checking is done.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.7
%000000   function void set_response_queue_depth(int value);
%000000     response_queue_depth = value;
          endfunction
        
        
          // Function -- NODOCS -- get_response_queue_depth
          //
          // Returns the current depth setting for the response queue.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.6
%000000   function int get_response_queue_depth();
%000000     return response_queue_depth;
          endfunction
        
        
          // Function -- NODOCS -- clear_response_queue
          //
          // Empties the response queue for this sequence.
        
          // @uvm-ieee 1800.2-2020 auto 14.2.7.8
%000003   virtual function void clear_response_queue();
%000003     response_queue.delete();
          endfunction
        
        
%000000   virtual function void put_base_response(input uvm_sequence_item response);
%000000     if ((response_queue_depth == -1) ||
%000000         (response_queue.size() < response_queue_depth)) begin
%000000       response_queue.push_back(response);
%000000       return;
            end
%000000     if (response_queue_error_report_enabled) begin
%000000       uvm_report_error(get_full_name(), "Response queue overflow, response was dropped", UVM_NONE);
            end
          endfunction
        
        
          // Function- put_response
          //
          // Internal method.
        
%000000   virtual function void put_response (uvm_sequence_item response_item);
%000000     put_base_response(response_item); // no error-checking
          endfunction
        
        
          // Function- get_base_response
        
%000000   virtual task get_base_response(output uvm_sequence_item response, input int transaction_id = -1);
        
%000000     int queue_size, i;
        
%000000     if (response_queue.size() == 0) begin
              
%000000       wait (response_queue.size() != 0);
            end
        
        
%000000     if (transaction_id == -1) begin
%000000       response = response_queue.pop_front();
%000000       return;
            end
        
%000000     forever begin
%000000       queue_size = response_queue.size();
%000000       for (i = 0; i < queue_size; i++) begin
%000000         if (response_queue[i].get_transaction_id() == transaction_id) begin
                  
%000000           $cast(response,response_queue[i]);
%000000           response_queue.delete(i);
%000000           return;
                end
              end
%000000       wait (response_queue.size() != queue_size);
            end
          endtask
        
          //----------------------
          // Misc Internal methods
          //----------------------
        
        
          // m_get_sqr_sequence_id
          // ---------------------
        
 000786   function int m_get_sqr_sequence_id(int sequencer_id, bit update_sequence_id);
%000003     if (m_sqr_seq_ids.exists(sequencer_id)) begin
~000777       if (update_sequence_id == 1) begin
 000777         set_sequence_id(m_sqr_seq_ids[sequencer_id]);
              end
%000000       return m_sqr_seq_ids[sequencer_id];
            end
        
%000003     if (update_sequence_id == 1) begin
              
%000003       set_sequence_id(-1);
            end
        
        
 000786     return -1;
          endfunction
        
        
          // m_set_sqr_sequence_id
          // ---------------------
        
%000003   function void m_set_sqr_sequence_id(int sequencer_id, int sequence_id);
%000003     m_sqr_seq_ids[sequencer_id] = sequence_id;
%000003     set_sequence_id(sequence_id);
          endfunction
        
        endclass
        
