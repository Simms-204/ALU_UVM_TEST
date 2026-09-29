//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2011-2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2012-2017 Cisco Systems, Inc.
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2014 Synopsys, Inc.
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
        // $File:     src/base/uvm_phase.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_sequencer_base;
        
        typedef class uvm_domain;
        typedef class uvm_task_phase;
        
        typedef class uvm_phase_cb;
        typedef class uvm_phase_state_change;
        
           
        //------------------------------------------------------------------------------
        //
        // Section -- NODOCS -- Phasing Definition classes
        //
        //------------------------------------------------------------------------------
        //
        // The following class are used to specify a phase and its implied functionality.
        //
          
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_phase
        //
        //------------------------------------------------------------------------------
        //
        // This base class defines everything about a phase: behavior, state, and context.
        //
        // To define behavior, it is extended by UVM or the user to create singleton
        // objects which capture the definition of what the phase does and how it does it.
        // These are then cloned to produce multiple nodes which are hooked up in a graph
        // structure to provide context: which phases follow which, and to hold the state
        // of the phase throughout its lifetime.
        // UVM provides default extensions of this class for the standard runtime phases.
        // VIP Providers can likewise extend this class to define the phase functor for a
        // particular component context as required.
        //
        // This base class defines everything about a phase: behavior, state, and context.
        //
        // To define behavior, it is extended by UVM or the user to create singleton
        // objects which capture the definition of what the phase does and how it does it.
        // These are then cloned to produce multiple nodes which are hooked up in a graph
        // structure to provide context: which phases follow which, and to hold the state
        // of the phase throughout its lifetime.
        // UVM provides default extensions of this class for the standard runtime phases.
        // VIP Providers can likewise extend this class to define the phase functor for a
        // particular component context as required.
        //
        // *Phase Definition*
        //
        // Singleton instances of those extensions are provided as package variables.
        // These instances define the attributes of the phase (not what state it is in)
        // They are then cloned into schedule nodes which point back to one of these
        // implementations, and calls its virtual task or function methods on each
        // participating component.
        // It is the base class for phase functors, for both predefined and
        // user-defined phases. Per-component overrides can use a customized imp.
        //
        // To create custom phases, do not extend uvm_phase directly: see the
        // three predefined extended classes below which encapsulate behavior for
        // different phase types: task, bottom-up function and top-down function.
        //
        // Extend the appropriate one of these to create a uvm_YOURNAME_phase class
        // (or YOURPREFIX_NAME_phase class) for each phase, containing the default
        // implementation of the new phase, which must be a uvm_component-compatible
        // delegate, and which may be a ~null~ implementation. Instantiate a singleton
        // instance of that class for your code to use when a phase handle is required.
        // If your custom phase depends on methods that are not in uvm_component, but
        // are within an extended class, then extend the base YOURPREFIX_NAME_phase
        // class with parameterized component class context as required, to create a
        // specialized functor which calls your extended component class methods.
        // This scheme ensures compile-safety for your extended component classes while
        // providing homogeneous base types for APIs and underlying data structures.
        //
        // *Phase Context*
        //
        // A schedule is a coherent group of one or mode phase/state nodes linked
        // together by a graph structure, allowing arbitrary linear/parallel
        // relationships to be specified, and executed by stepping through them in
        // the graph order.
        // Each schedule node points to a phase and holds the execution state of that
        // phase, and has optional links to other nodes for synchronization.
        //
        // The main operations are: construct, add phases, and instantiate
        // hierarchically within another schedule.
        //
        // Structure is a DAG (Directed Acyclic Graph). Each instance is a node
        // connected to others to form the graph. Hierarchy is overlaid with m_parent.
        // Each node in the graph has zero or more successors, and zero or more
        // predecessors. No nodes are completely isolated from others. Exactly
        // one node has zero predecessors. This is the root node. Also the graph
        // is acyclic, meaning for all nodes in the graph, by following the forward
        // arrows you will never end up back where you started but you will eventually
        // reach a node that has no successors.
        //
        // *Phase State*
        //
        // A given phase may appear multiple times in the complete phase graph, due
        // to the multiple independent domain feature, and the ability for different
        // VIP to customize their own phase schedules perhaps reusing existing phases.
        // Each node instance in the graph maintains its own state of execution.
        //
        // *Phase Handle*
        //
        // Handles of this type uvm_phase are used frequently in the API, both by
        // the user, to access phasing-specific API, and also as a parameter to some
        // APIs. In many cases, the singleton phase handles can be
        // used (eg. <uvm_run_phase::get()>) in APIs. For those APIs that need to look
        // up that phase in the graph, this is done automatically.
        
        // @uvm-ieee 1800.2-2020 auto 9.3.1.2
        class uvm_phase extends uvm_object;
        
          //`uvm_object_utils(uvm_phase)
        
%000003   `uvm_register_cb(uvm_phase, uvm_phase_cb)
        
        
          //--------------------
          // Group -- NODOCS -- Construction
          //--------------------
          
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.1
          extern function new(string name="uvm_phase",
                              uvm_phase_type phase_type=UVM_PHASE_SCHEDULE,
                              uvm_phase parent=null);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.2
          extern function uvm_phase_type get_phase_type();
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.3
          extern virtual function void set_max_ready_to_end_iterations(int max);
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.4
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.6
          extern virtual function int get_max_ready_to_end_iterations();
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.3.5
          extern static function void set_default_max_ready_to_end_iterations(int max);
        
          extern static function int get_default_max_ready_to_end_iterations();
        
          //-------------
          // Group -- NODOCS -- State
          //-------------
        
        
          // @uvm-contrib For potential contribution to 1800.2
          extern function void set_state(uvm_phase_state state);
          
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.1
          extern function uvm_phase_state get_state();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.2
          extern function int get_run_count();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.3
          extern function uvm_phase find_by_name(string name, bit stay_in_scope=1);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.4
          extern function uvm_phase find(uvm_phase phase, bit stay_in_scope=1);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.5
          extern function bit is(uvm_phase phase);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.6
          extern function bit is_before(uvm_phase phase);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.4.7
          extern function bit is_after(uvm_phase phase);
        
        
          //-----------------
          // Group -- NODOCS -- Callbacks
          //-----------------
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.5.1
%000000   virtual function void exec_func(uvm_component comp, uvm_phase phase); endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.5.2
%000000   virtual task exec_task(uvm_component comp, uvm_phase phase); endtask
        
        
        
          //----------------
          // Group -- NODOCS -- Schedule
          //----------------
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.1
          extern function void add(uvm_phase phase,
                                   uvm_phase with_phase=null,
                                   uvm_phase after_phase=null,
                                   uvm_phase before_phase=null,
                                   uvm_phase start_with_phase=null,
                                   uvm_phase end_with_phase=null
                                );
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.2
          extern function uvm_phase get_parent();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.3
          extern virtual function string get_full_name();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.4
          extern function uvm_phase get_schedule(bit hier = 0);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.5
          extern function string get_schedule_name(bit hier = 0);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.6
          extern function uvm_domain get_domain();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.7
          extern function uvm_phase get_imp();
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.8
          extern function string get_domain_name();
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.9
          extern function void get_adjacent_predecessor_nodes(ref uvm_phase pred[]);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.6.10
          extern function void get_adjacent_successor_nodes(ref uvm_phase succ[]);
        
          //-----------------------
          // Group -- NODOCS -- Phase Done Objection
          //-----------------------
          //
          // Task-based phase nodes within the phasing graph provide a <uvm_objection>
          // based interface for prolonging the execution of the phase.  All other
          // phase types do not contain an objection, and will report a fatal error
          // if the user attempts to ~raise~, ~drop~, or ~get_objection_count~.
           
          // Function- m_report_null_objection
          // Simplifies the reporting of ~null~ objection errors
          extern function void m_report_null_objection(uvm_object obj,
                                                       string description,
                                                       int count,
                                                       string action);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.7.2
          extern virtual function void raise_objection (uvm_object obj, 
                                                        string description="",
                                                        int count=1);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.7.3
          extern virtual function void drop_objection (uvm_object obj, 
                                                       string description="",
                                                       int count=1);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.7.4
          extern virtual function int get_objection_count( uvm_object obj=null );
        
          // @uvm-contrib For potential contribution to 1800.2
          extern virtual function int get_objection_total( uvm_object obj=null );
           
          //-----------------------
          // Group -- NODOCS -- Synchronization
          //-----------------------
          // The functions 'sync' and 'unsync' add soft sync relationships between nodes
          //
          // Summary of usage:
          //| my_phase.sync(.target(domain)
          //|              [,.phase(phase)[,.with_phase(phase)]]);
          //| my_phase.unsync(.target(domain)
          //|                [,.phase(phase)[,.with_phase(phase)]]);
          //
          // Components in different schedule domains can be phased independently or in sync
          // with each other. An API is provided to specify synchronization rules between any
          // two domains. Synchronization can be done at any of three levels:
          //
          // - the domain's whole phase schedule can be synchronized
          // - a phase can be specified, to sync that phase with a matching counterpart
          // - or a more detailed arbitrary synchronization between any two phases
          //
          // Each kind of synchronization causes the same underlying data structures to
          // be managed. Like other APIs, we use the parameter dot-notation to set
          // optional parameters.
          //
          // When a domain is synced with another domain, all of the matching phases in
          // the two domains get a 'with' relationship between them. Likewise, if a domain
          // is unsynched, all of the matching phases that have a 'with' relationship have
          // the dependency removed. It is possible to sync two domains and then just
          // remove a single phase from the dependency relationship by unsyncing just
          // the one phase.
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.8.1
          extern function void sync(uvm_domain target,
                                    uvm_phase phase=null,
                                    uvm_phase with_phase=null);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.8.2
          extern function void unsync(uvm_domain target,
                                      uvm_phase phase=null,
                                      uvm_phase with_phase=null);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.8.3
          extern task wait_for_state(uvm_phase_state state, uvm_wait_op op=UVM_EQ);
        
           
          //---------------
          // Group -- NODOCS -- Jumping
          //---------------
          
          // Force phases to jump forward or backward in a schedule
          //
          // A phasing domain can execute a jump from its current phase to any other.
          // A jump passes phasing control in the current domain from the current phase
          // to a target phase. There are two kinds of jump scope:
          //
          // - local jump to another phase within the current schedule, back- or forwards
          // - global jump of all domains together, either to a point in the master
          //   schedule outwith the current schedule, or by calling jump_all()
          //
          // A jump preserves the existing soft synchronization, so the domain that is
          // ahead of schedule relative to another synchronized domain, as a result of
          // a jump in either domain, will await the domain that is behind schedule.
          //
          // *Note*: A jump out of the local schedule causes other schedules that have
          // the jump node in their schedule to jump as well. In some cases, it is
          // desirable to jump to a local phase in the schedule but to have all
          // schedules that share that phase to jump as well. In that situation, the
          // jump_all static function should be used. This function causes all schedules
          // that share a phase to jump to that phase.
         
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.9.1
          extern function void jump(uvm_phase phase);
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.9.2
          extern function void set_jump_phase(uvm_phase phase) ;
        
          // @uvm-contrib For potential contribution to 1800.2
          extern function bit is_jumping_forward();
        
          // @uvm-contrib For potential contribution to 1800.2
          extern function bit is_jumping_backward();
          
          // @uvm-ieee 1800.2-2020 auto 9.3.1.9.3
          extern function void end_prematurely() ;
        
          // @uvm-contrib For potential contribution to 1800.2
          extern function bit is_ending_prematurely();
        
          // Function- jump_all
          //
          // Make all schedules jump to a specified ~phase~, even if the jump target is local.
          // The jump happens to all phase schedules that contain the jump-to ~phase~,
          // i.e. a global jump. 
          //
          extern static function void jump_all(uvm_phase phase);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.1.9.4
          extern function uvm_phase get_jump_target();
        
        
        
          //--------------------------
          // Internal - Implementation
          //--------------------------
        
          typedef bit edges_t[uvm_phase]; // Associative array type for storing predecessor/successor lists
          
          // Implementation - Construction
          //------------------------------
          protected uvm_phase_type m_phase_type;
          protected uvm_phase      m_parent;     // our 'schedule' node [or points 'up' one level]
          uvm_phase                m_imp;        // phase imp to call when we execute this node
        
          // Implementation - State
          //-----------------------
          // Could move this to hopper
          // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          local uvm_phase_state    m_state;
          local int                m_run_count; // num times this phase has executed
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          protected uvm_phase_state_change m_state_chg;
          /*local*/ process            m_phase_proc;
%000003   local static int         m_default_max_ready_to_end_iters = 20;    // 20 is the initial value defined by 1800.2-2020 9.3.1.3.5
 000144   local int                      max_ready_to_end_iters = get_default_max_ready_to_end_iterations();
          int                      m_num_procs_not_yet_returned;
          extern function uvm_phase m_find_predecessor(uvm_phase phase, bit stay_in_scope=1, uvm_phase orig_phase=null);
          extern function uvm_phase m_find_successor(uvm_phase phase, bit stay_in_scope=1, uvm_phase orig_phase=null);
          extern function uvm_phase m_find_predecessor_by_name(string name, bit stay_in_scope=1, uvm_phase orig_phase=null);
          extern function uvm_phase m_find_successor_by_name(string name, bit stay_in_scope=1, uvm_phase orig_phase=null);
          extern function void m_print_successors();
        
          // Implementation - Callbacks
          //---------------------------
          // Provide the required component traversal behavior. Called by execute()
%000000   virtual function void traverse(uvm_component comp,
                                         uvm_phase phase,
                                         uvm_phase_state state);
          endfunction
          // Provide the required per-component execution flow. Called by traverse()
%000000   virtual function void execute(uvm_component comp,
                                         uvm_phase phase);
          endfunction
        
          // Implementation - Schedule
          //--------------------------
          protected edges_t m_predecessors;
          protected edges_t m_successors;
          protected uvm_phase m_end_node;
          // Track the currently executing real task phases (used for debug)
          static protected edges_t m_executing_phases;
%000000   function uvm_phase get_begin_node(); if (m_imp != null) begin
%000000     return this;
          end
%000000  return null; endfunction
%000000   function uvm_phase get_end_node();   return m_end_node; endfunction
        
          // Implementation - Synchronization
          //---------------------------------
          local uvm_phase m_sync[$];  // schedule instance to which we are synced
        
          //@uvm-compat provided for compatability with 1.2
          uvm_objection phase_done;
           
          extern function void get_predecessors(ref edges_t predecessors);
          extern function void get_successors(ref edges_t successors);
          extern function void get_sync_relationships(ref edges_t relationships);
          extern local function void get_predecessors_for_successors(output edges_t pred_of_succ);
          // Could move this to hopper
          // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          extern /*local*/ task m_wait_for_pred();
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
          // Implementation - Jumping
          //-------------------------
          local bit                m_jump_bkwd;
          local bit                m_jump_fwd;
          local uvm_phase          m_jump_phase;
          // Could move this to hopper
          // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          /*local*/ bit                m_premature_end;
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          extern function void clear(uvm_phase_state state = UVM_PHASE_DORMANT);
          extern function void clear_successors(
                                     uvm_phase_state state = UVM_PHASE_DORMANT,
                                     uvm_phase end_state=null);
        
          // Implementation - Overall Control
          //---------------------------------
%000003   local static mailbox #(uvm_phase) m_phase_hopper = new();
        
          extern local function void m_terminate_phase();
          extern local function void m_print_termination_state();
          // Could move this to hopper
          // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
          extern /*local*/ task wait_for_self_and_siblings_to_drop();
          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          extern function void kill();
          extern function void kill_successors();
        
          // TBD add more useful debug
          //---------------------------------
          /*protected*/ static bit m_phase_trace;
          /*local*/ static bit m_use_ovm_run_semantic;
        
        
%000000   function string convert2string();
          //return $sformatf("PHASE %s = %p",get_name(),this);
%000000   string s;
%000000     s = $sformatf("phase: %s parent=%s  pred=%s  succ=%s",get_name(),
%000000                      (m_parent==null) ? "null" : get_schedule_name(),
%000000                      m_aa2string(m_predecessors),
%000000                      m_aa2string(m_successors));
%000000     return s;
          endfunction
        
%000000   local function string m_aa2string(edges_t aa); // TBD tidy
%000000     string s;
%000000     int i;
%000000     s = "'{ ";
%000000     foreach (aa[ph]) begin
%000000       uvm_phase n = ph;
%000000       s = {s, (n == null) ? "null" : n.get_name(),
%000000         (i == aa.num()-1) ? "" : ", "};
%000000       i++;
            end
%000000     s = {s, " }"};
%000000     return s;
          endfunction
        
%000000   function bit is_domain();
%000000     return (m_phase_type == UVM_PHASE_DOMAIN);
          endfunction
        
%000000   virtual function void m_get_transitive_children(ref uvm_phase phases[$]);
%000000     foreach (m_successors[succ]) begin
            
%000000       phases.push_back(succ);
%000000       succ.m_get_transitive_children(phases);
            end
          endfunction
          
          
          // @uvm-ieee 1800.2-2020 auto 9.3.1.7.1
 000366   function uvm_objection get_objection();
 000366      uvm_phase imp;
 000366      uvm_task_phase tp;
 000366      imp = get_imp();
             // Only nodes with a non-null uvm_task_phase imp have objections
~000300      if ((get_phase_type() != UVM_PHASE_NODE) || (imp == null) || !$cast(tp, imp)) begin
%000000        return null;
             end
 000261      if (phase_done == null) begin
 000039        phase_done = uvm_objection::type_id::create({get_name(), "_objection"});
             end
             
 000366      return phase_done;
          endfunction // get_objection
        
          
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_phase_state_change
        //
        //------------------------------------------------------------------------------
        //
        // Phase state transition descriptor.
        // Used to describe the phase transition that caused a
        // <uvm_phase_cb::phase_state_changed()> callback to be invoked.
        //
        
        // @uvm-ieee 1800.2-2020 auto 9.3.2.1
        class uvm_phase_state_change extends uvm_object;
        
%000000   `uvm_object_utils(uvm_phase_state_change)
        
          // Implementation -- do not use directly
          /* local */ uvm_phase       m_phase;
          /* local */ uvm_phase_state m_prev_state;
          /* local */ uvm_phase       m_jump_to;
          
~000213   function new(string name = "uvm_phase_state_change");
 000213     super.new(name);
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.2.2.1
%000000   virtual function uvm_phase_state get_state();
%000000     return m_phase.get_state();
          endfunction
          
        
          // @uvm-ieee 1800.2-2020 auto 9.3.2.2.2
%000000   virtual function uvm_phase_state get_prev_state();
%000000     return m_prev_state;
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.2.2.3
%000000   function uvm_phase jump_to();
%000000     return m_jump_to;
          endfunction
        
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_phase_cb
        //
        //------------------------------------------------------------------------------
        //
        // This class defines a callback method that is invoked by the phaser
        // during the execution of a specific node in the phase graph or all phase nodes.
        // User-defined callback extensions can be used to integrate data types that
        // are not natively phase-aware with the UVM phasing.
        //
        
        // @uvm-ieee 1800.2-2020 auto 9.3.3.1
        class uvm_phase_cb extends uvm_callback;
        
        
          // @uvm-ieee 1800.2-2020 auto 9.3.3.2.1
%000000   function new(string name="unnamed-uvm_phase_cb");
%000000      super.new(name);
          endfunction : new
           
        
          // @uvm-ieee 1800.2-2020 auto 9.3.3.2.2
%000000   virtual function void phase_state_change(uvm_phase phase,
                                                   uvm_phase_state_change change);
          endfunction
        endclass
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_phase_cb_pool
        //
        //------------------------------------------------------------------------------
        //
        // Convenience type for the uvm_callbacks#(uvm_phase, uvm_phase_cb) class.
        //
        typedef uvm_callbacks#(uvm_phase, uvm_phase_cb) uvm_phase_cb_pool /* @uvm-ieee 1800.2-2020 auto D.4.1*/ ;
        
        
        //------------------------------------------------------------------------------
        //                               IMPLEMENTATION
        //------------------------------------------------------------------------------
        
        typedef class uvm_cmdline_processor;
        
        `define UVM_PH_TRACE(ID,MSG,PH,VERB) \
          if (uvm_phase::m_phase_trace) \
           `uvm_info(ID, {$sformatf("Phase '%0s' (id=%0d) ", \
               PH.get_full_name(), PH.get_inst_id()),MSG}, VERB)
        
        //-----------------------------
        // Implementation - Construction
        //-----------------------------
        
        // new
        
 000144 function uvm_phase::new(string name="uvm_phase",
                                uvm_phase_type phase_type=UVM_PHASE_SCHEDULE,
                                uvm_phase parent=null);
 000144   super.new(name);
 000144   m_state_chg = uvm_phase_state_change::type_id::create(name);
 000144   m_state_chg.m_phase = this;
 000144   m_phase_type = phase_type;
        
          // The common domain is the only thing that initializes m_state.  All
          // other states are initialized by being 'added' to a schedule.
~000141   if ((name == "common") &&
%000003       (phase_type == UVM_PHASE_DOMAIN)) begin
            
%000003     m_state = UVM_PHASE_DORMANT;
          end
        
           
 000144   m_run_count = 0;
 000144   m_parent = parent;
        
 000144   begin
 000144     uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
 000144     string val;
~000144     if (clp.get_arg_value("+UVM_PHASE_TRACE", val)) begin
              
%000000       m_phase_trace = 1;
            end
        
 000144     else begin
              
 000144       m_phase_trace = 0;
            end
        
~000144     if (clp.get_arg_value("+UVM_USE_OVM_RUN_SEMANTIC", val)) begin
              
%000000       m_use_ovm_run_semantic = 1;
            end
        
 000144     else begin
              
 000144       m_use_ovm_run_semantic = 0;
            end
        
          end
        
           
~000135   if (parent == null && (phase_type == UVM_PHASE_SCHEDULE ||
%000009                          phase_type == UVM_PHASE_DOMAIN )) begin
            //m_parent = this;
%000009     m_end_node = new({name,"_end"}, UVM_PHASE_TERMINAL, this);
%000009     this.m_successors[m_end_node] = 1;
%000009     m_end_node.m_predecessors[this] = 1;
          end
        
        endfunction
        
        
        // add
        // ---
        // TBD error checks if param nodes are actually in this schedule or not
        
 000069 function void uvm_phase::add(uvm_phase phase,
                                     uvm_phase with_phase=null,
                                     uvm_phase after_phase=null,
                                     uvm_phase before_phase=null,
                                     uvm_phase start_with_phase=null,
                                     uvm_phase end_with_phase=null
                                  );
 000069   uvm_phase new_node, begin_node, end_node, tmp_node;
 000069   uvm_phase_state_change state_chg;
        
~000069   if (phase == null) begin
%000000     `uvm_fatal("PH/NULL", "add: phase argument is null")
          end
        
~000069   if (with_phase != null && with_phase.get_phase_type() == UVM_PHASE_IMP) begin
%000000     string nm = with_phase.get_name();
%000000     with_phase = find(with_phase);
%000000     if (with_phase == null) begin
              `uvm_fatal("PH_BAD_ADD",
%000000       {"cannot find with_phase '",nm,"' within node '",get_name(),"'"})
            end
          end
        
~000069   if (before_phase != null && before_phase.get_phase_type() == UVM_PHASE_IMP) begin
%000000     string nm = before_phase.get_name();
%000000     before_phase = find(before_phase);
%000000     if (before_phase == null) begin
              `uvm_fatal("PH_BAD_ADD",
%000000       {"cannot find before_phase '",nm,"' within node '",get_name(),"'"})
            end
          end
        
~000069   if (after_phase != null && after_phase.get_phase_type() == UVM_PHASE_IMP) begin
%000000     string nm = after_phase.get_name();
%000000     after_phase = find(after_phase);
%000000     if (after_phase == null) begin
              `uvm_fatal("PH_BAD_ADD",
%000000       {"cannot find after_phase '",nm,"' within node '",get_name(),"'"})
            end
          end
        
~000069   if (start_with_phase != null && start_with_phase.get_phase_type() == UVM_PHASE_IMP) begin
%000000     string nm = start_with_phase.get_name();
%000000     start_with_phase = find(start_with_phase);
%000000     if (start_with_phase == null) begin
              `uvm_fatal("PH_BAD_ADD",
%000000       {"cannot find start_with_phase '",nm,"' within node '",get_name(),"'"})
            end
          end
        
~000069   if (end_with_phase != null && end_with_phase.get_phase_type() == UVM_PHASE_IMP) begin
%000000     string nm = end_with_phase.get_name();
%000000     end_with_phase = find(end_with_phase);
%000000     if (end_with_phase == null) begin
              `uvm_fatal("PH_BAD_ADD",
%000000       {"cannot find end_with_phase '",nm,"' within node '",get_name(),"'"})
            end
          end
        
~000069   if (((with_phase != null) + (after_phase != null) + (start_with_phase != null)) > 1) begin
            `uvm_fatal("PH_BAD_ADD",
%000000     "only one of with_phase/after_phase/start_with_phase may be specified as they all specify predecessor")
          end
        
~000069   if (((with_phase != null) + (before_phase != null) + (end_with_phase != null)) > 1) begin
            `uvm_fatal("PH_BAD_ADD",
%000000     "only one of with_phase/before_phase/end_with_phase may be specified as they all specify successor")
          end
        
~000069   if (before_phase == this || 
             after_phase == m_end_node || 
             with_phase == m_end_node ||
             start_with_phase == m_end_node ||
%000000      end_with_phase == m_end_node) begin
            `uvm_fatal("PH_BAD_ADD",
%000000     "cannot add before begin node, after end node, or with end nodes")
          end
        
~000069   if (before_phase != null && after_phase != null) begin
%000000     if (!after_phase.is_before(before_phase)) begin
              `uvm_fatal("PH_BAD_ADD",{"Phase '",before_phase.get_name(),
%000000       "' is not before phase '",after_phase.get_name(),"'"})
            end
          end
        
~000069   if (before_phase != null && start_with_phase != null) begin
%000000     if (!start_with_phase.is_before(before_phase)) begin
              `uvm_fatal("PH_BAD_ADD",{"Phase '",before_phase.get_name(),
%000000       "' is not before phase '",start_with_phase.get_name(),"'"})
            end
          end
        
~000069   if (end_with_phase != null && after_phase != null) begin
%000000     if (!after_phase.is_before(end_with_phase)) begin
              `uvm_fatal("PH_BAD_ADD",{"Phase '",end_with_phase.get_name(),
%000000       "' is not before phase '",after_phase.get_name(),"'"})
            end
          end
        
          // If we are inserting a new "leaf node"
~000063   if (phase.get_phase_type() == UVM_PHASE_IMP) begin
 000063     uvm_task_phase tp;
 000063     new_node = new(phase.get_name(),UVM_PHASE_NODE,this);
 000063     new_node.m_imp = phase;
 000063     begin_node = new_node;
 000063     end_node = new_node;
        
          end
          // We are inserting an existing schedule
%000006   else begin
%000006     begin_node = phase;
%000006     end_node   = phase.m_end_node;
%000006     phase.m_parent = this;
          end
        
          // If 'with_phase' is us, then insert node in parallel
          /*
          if (with_phase == this) begin
            after_phase = this;
            before_phase = m_end_node;
          end
          */
        
          // If no before/after/with specified, insert at end of this schedule
~000066   if (with_phase==null && after_phase==null && before_phase==null && 
 000066      start_with_phase==null && end_with_phase==null) begin
 000066     before_phase = m_end_node;
          end
        
        
~000069   if (m_phase_trace) begin
%000000     uvm_phase_type typ = phase.get_phase_type();
            `uvm_info("PH/TRC/ADD_PH",
            {get_name()," (",m_phase_type.name(),") ADD_PHASE: phase=",phase.get_full_name()," (",
            typ.name(),", inst_id=",$sformatf("%0d",phase.get_inst_id()),")",
            " with_phase=",   (with_phase == null)   ? "null" : with_phase.get_name(), 
            " start_with_phase=",   (start_with_phase == null)   ? "null" : start_with_phase.get_name(), 
            " end_with_phase=",   (end_with_phase == null)   ? "null" : end_with_phase.get_name(), 
            " after_phase=",  (after_phase == null)  ? "null" : after_phase.get_name(),
            " before_phase=", (before_phase == null) ? "null" : before_phase.get_name(), 
            " new_node=",     (new_node == null)     ? "null" : {new_node.get_name(),
            " inst_id=",
            $sformatf("%0d",new_node.get_inst_id())},
            " begin_node=",   (begin_node == null)   ? "null" : begin_node.get_name(),
%000000     " end_node=",     (end_node == null)     ? "null" : end_node.get_name()},UVM_DEBUG)
          end
        
        
          // 
          // INSERT IN PARALLEL WITH 'WITH' PHASE
~000066   if (with_phase != null) begin
            // all pre-existing predecessors to with_phase are predecessors to the new phase
%000003     begin_node.m_predecessors = with_phase.m_predecessors;
%000003     foreach (with_phase.m_predecessors[pred]) begin
%000003       pred.m_successors[begin_node] = 1;
            end
        
            // all pre-existing successors to with_phase are successors to this phase
%000003     end_node.m_successors = with_phase.m_successors;
%000003     foreach (with_phase.m_successors[succ]) begin
%000003       succ.m_predecessors[end_node] = 1;
            end
        
          end
          
~000069   if (start_with_phase != null) begin
            // all pre-existing predecessors to start_with_phase are predecessors to the new phase
%000000     begin_node.m_predecessors = start_with_phase.m_predecessors;
%000000     foreach (start_with_phase.m_predecessors[pred]) begin
%000000       pred.m_successors[begin_node] = 1;
            end
            // if not otherwise specified, successors for the new phase are the successors to the end of this schedule
%000000     if (before_phase == null && end_with_phase == null) begin
%000000       end_node.m_successors = m_end_node.m_successors ;
%000000       foreach (m_end_node.m_successors[succ]) begin
%000000         succ.m_predecessors[end_node] = 1;
              end
            end
          end
          
~000069   if (end_with_phase != null) begin
            // all pre-existing successors to end_with_phase are successors to the new phase
%000000     end_node.m_successors = end_with_phase.m_successors;
%000000     foreach (end_with_phase.m_successors[succ]) begin
%000000       succ.m_predecessors[end_node] = 1;
            end
            // if not otherwise specified, predecessors for the new phase are the predecessors to the start of this schedule
%000000     if (after_phase == null && start_with_phase == null) begin
%000000       begin_node.m_predecessors = this.m_predecessors ;
%000000       foreach (this.m_predecessors[pred]) begin
%000000         pred.m_successors[begin_node] = 1;
              end
            end
          end
        
          // INSERT BEFORE PHASE
~000066   if (before_phase != null) begin
            // unless predecessors to this phase are otherwise specified, 
            // pre-existing predecessors to before_phase move to be predecessors to the new phase
 000066     if (after_phase == null && start_with_phase == null) begin
 000066       foreach (before_phase.m_predecessors[pred]) begin
 000066         pred.m_successors.delete(before_phase);
 000066         pred.m_successors[begin_node] = 1;
              end
 000066       begin_node.m_predecessors = before_phase.m_predecessors;
 000066       before_phase.m_predecessors.delete();
            end
            // there is a special case if before and after used to be adjacent;
            // the new phase goes in-between them
%000000     else if (before_phase.m_predecessors.exists(after_phase)) begin
%000000       before_phase.m_predecessors.delete(after_phase);
            end
        
            // before_phase is now the sole successor of this phase
 000066     before_phase.m_predecessors[end_node] = 1;
 000066     end_node.m_successors.delete() ;
 000066     end_node.m_successors[before_phase] = 1;
        
          end
        
        
          // INSERT AFTER PHASE
~000069   if (after_phase != null) begin
            // unless successors to this phase are otherwise specified, 
            // pre-existing successors to after_phase are now successors to this phase
%000000     if (before_phase == null && end_with_phase == null) begin
%000000       foreach (after_phase.m_successors[succ]) begin
%000000         succ.m_predecessors.delete(after_phase);
%000000         succ.m_predecessors[end_node] = 1;
              end
%000000       end_node.m_successors = after_phase.m_successors;
%000000       after_phase.m_successors.delete();
            end
            // there is a special case if before and after used to be adjacent;
            // the new phase goes in-between them
%000000     else if (after_phase.m_successors.exists(before_phase)) begin
%000000       after_phase.m_successors.delete(before_phase);
            end
        
            // after_phase is the sole predecessor of this phase 
%000000     after_phase.m_successors[begin_node] = 1;
%000000     begin_node.m_predecessors.delete();
%000000     begin_node.m_predecessors[after_phase] = 1;
          end
          
        
        
          // Transition nodes to DORMANT state
~000063   if (new_node == null) begin
            
%000006     tmp_node = phase;
          end
        
 000063   else begin
            
 000063     tmp_node = new_node;
          end
        
        
 000069   state_chg = uvm_phase_state_change::type_id::create(tmp_node.get_name());
 000069   state_chg.m_phase = tmp_node;
 000069   state_chg.m_jump_to = null;
 000069   state_chg.m_prev_state = tmp_node.m_state;
 000069   tmp_node.m_state = UVM_PHASE_DORMANT;
~000069   `uvm_do_callbacks(uvm_phase, uvm_phase_cb, phase_state_change(tmp_node, state_chg)) 
        endfunction
        
        
        // get_parent
        // ----------
        
%000000 function uvm_phase uvm_phase::get_parent();
%000000   return m_parent;
        endfunction
        
        
        // get_imp
        // -------
        
 000618 function uvm_phase uvm_phase::get_imp();
 000618   return m_imp;
        endfunction
        
        
        // get_schedule
        // ------------
        
 000492 function uvm_phase uvm_phase::get_schedule(bit hier=0);
 000492   uvm_phase sched;
 000492   sched = this;
~000492   if (hier) begin
            
%000000     while (sched.m_parent != null && (sched.m_parent.get_phase_type() == UVM_PHASE_SCHEDULE)) begin
              
%000000       sched = sched.m_parent;
            end
        
          end
        
~000492   if (sched.m_phase_type == UVM_PHASE_SCHEDULE) begin
            
%000000     return sched;
          end
        
 000246   if (sched.m_phase_type == UVM_PHASE_NODE) begin
            
~000246     if (m_parent != null && m_parent.m_phase_type != UVM_PHASE_DOMAIN) begin
              
%000000       return m_parent;
            end
        
          end
        
 000492   return null;
        endfunction
        
        
        // get_domain
        // ----------
        
 009237 function uvm_domain uvm_phase::get_domain();
 009237   uvm_phase phase;
 009237   phase = this;
 015138   while (phase != null && phase.m_phase_type != UVM_PHASE_DOMAIN) begin
            
 015138     phase = phase.m_parent;
          end
        
~009237   if (phase == null) begin // no parent domain 
            
%000000     return null;
          end
        
~009237   if(!$cast(get_domain,phase)) begin
%000000     `uvm_fatal("PH/INTERNAL", "get_domain: m_phase_type is DOMAIN but $cast to uvm_domain fails")
          end
        endfunction
        
        
        // get_domain_name
        // ---------------
          
%000006 function string uvm_phase::get_domain_name();
%000006   uvm_domain domain;
%000006   domain = get_domain();
%000006   if (domain == null) begin
            
%000000     return "unknown";
          end
        
%000006   return domain.get_name();
        endfunction
        
        
        // get_schedule_name
        // -----------------
          
%000006 function string uvm_phase::get_schedule_name(bit hier=0);
%000006   uvm_phase sched;
%000006   string s;
%000006   sched = get_schedule(hier);
%000000   if (sched == null) begin
            
%000000     return "";
          end
        
%000006   s = sched.get_name();
%000000   while (sched.m_parent != null && sched.m_parent != sched &&
%000000           (sched.m_parent.get_phase_type() == UVM_PHASE_SCHEDULE)) begin
%000000     sched = sched.m_parent;
%000000     s = {sched.get_name(),(s.len()>0?".":""),s};
          end
%000006   return s;
        endfunction
        
        
        // get_full_name
        // -------------
        
%000006 function string uvm_phase::get_full_name();
%000006   string dom, sch;
%000006   if (m_phase_type == UVM_PHASE_IMP) begin
            
%000000     return get_name();
          end
        
%000006   get_full_name = get_domain_name();
%000006   sch = get_schedule_name();
%000006   if (sch != "") begin
            
%000000     get_full_name = {get_full_name, ".", sch};
          end
        
%000003   if (m_phase_type != UVM_PHASE_DOMAIN && m_phase_type != UVM_PHASE_SCHEDULE) begin
            
%000003     get_full_name = {get_full_name, ".", get_name()};
          end
        
        endfunction
        
        
        // get_phase_type
        // --------------
        
 001062 function uvm_phase_type uvm_phase::get_phase_type();
 001062   return m_phase_type;
        endfunction
        
        // set_max_ready_to_end_iterations
        // -------------------------------
        
%000000 function void uvm_phase::set_max_ready_to_end_iterations(int max);
%000000   max_ready_to_end_iters = max;
        endfunction
        
        // get_max_ready_to_end_iterations
        // -------------------------------
        
%000000 function int uvm_phase::get_max_ready_to_end_iterations();
%000000   return max_ready_to_end_iters;
        endfunction
        
        // set_default_max_ready_to_end_iterations
        // ---------------------------------------
        
%000000 function void uvm_phase::set_default_max_ready_to_end_iterations(int max);
%000000   m_default_max_ready_to_end_iters = max;
        endfunction
        
        // get_default_max_ready_to_end_iterations
        // ---------------------------------------
        
 000144 function int uvm_phase::get_default_max_ready_to_end_iterations();
 000144   return m_default_max_ready_to_end_iters;
        endfunction
        
        
        //-----------------------
        // Implementation - State
        //-----------------------
        
        // set_state
        // ---------
 000570 function void uvm_phase::set_state(uvm_phase_state state);
~000570   if (m_state == state) begin
            
%000000     return;
          end
        
 000489   if (state == UVM_PHASE_STARTED) begin
            
 000081     m_run_count++;
          end
        
          // TODO: Seems like there should be an official way to set these values...
 000570   m_state_chg.m_jump_to = m_jump_phase;
 000570   m_state_chg.m_prev_state = m_state;
 000570   m_state = state;
~000570   `uvm_do_callbacks(uvm_phase, uvm_phase_cb, phase_state_change(this, m_state_chg))
        endfunction : set_state
        
        // get_state
        // ---------
        
 000723 function uvm_phase_state uvm_phase::get_state();
 000723   return m_state;
        endfunction
        
        // get_run_count
        // -------------
        
%000000 function int uvm_phase::get_run_count();
%000000   return m_run_count;
        endfunction
        
        
        // m_print_successors
        // ------------------
        
%000000 function void uvm_phase::m_print_successors();
%000000   uvm_phase found;
%000000   static string spaces = "                                                 ";
%000000   static int level;
%000000   if (m_phase_type == UVM_PHASE_DOMAIN) begin
            
%000000     level = 0;
          end
        
%000000   `uvm_info("UVM/PHASE/SUCC",$sformatf("%s%s (%s) id=%0d",spaces.substr(0,level*2),get_name(), m_phase_type.name(),get_inst_id()),UVM_NONE)
%000000   level++;
%000000   foreach (m_successors[succ]) begin
%000000     succ.m_print_successors();
          end
%000000   level--;
        endfunction
        
        
        // m_find_predecessor
        // ------------------
        
~000147 function uvm_phase uvm_phase::m_find_predecessor(uvm_phase phase, bit stay_in_scope=1, uvm_phase orig_phase=null);
 000147   uvm_phase found;
          //$display("  FIND PRED node '",phase.get_name(),"' (id=",$sformatf("%0d",phase.get_inst_id()),") - checking against ",get_name()," (",m_phase_type.name()," id=",$sformatf("%0d",get_inst_id()),(m_imp==null)?"":{"/",$sformatf("%0d",m_imp.get_inst_id())},")");
~000147   if (phase == null) begin
%000000     return null ;
          end
~000147   if (phase == m_imp || phase == this) begin
            
%000000     return this;
          end
        
~000147   foreach (m_predecessors[pred]) begin
%000000     uvm_phase orig;
%000000     orig = (orig_phase==null) ? this : orig_phase;
%000000     if (!stay_in_scope || 
            (pred.get_schedule() == orig.get_schedule()) ||
%000000     (pred.get_domain() == orig.get_domain())) begin
%000000       found = pred.m_find_predecessor(phase,stay_in_scope,orig);
%000000       if (found != null) begin
                
%000000         return found;
              end
        
            end
          end
 000147   return null;
        endfunction
        
        
        // m_find_predecessor_by_name
        // --------------------------
        
%000000 function uvm_phase uvm_phase::m_find_predecessor_by_name(string name, bit stay_in_scope=1, uvm_phase orig_phase=null);
%000000   uvm_phase found;
          //$display("  FIND PRED node '",name,"' - checking against ",get_name()," (",m_phase_type.name()," id=",$sformatf("%0d",get_inst_id()),(m_imp==null)?"":{"/",$sformatf("%0d",m_imp.get_inst_id())},")");
%000000   if (get_name() == name) begin
            
%000000     return this;
          end
        
%000000   foreach (m_predecessors[pred]) begin
%000000     uvm_phase orig;
%000000     orig = (orig_phase==null) ? this : orig_phase;
%000000     if (!stay_in_scope || 
            (pred.get_schedule() == orig.get_schedule()) ||
%000000     (pred.get_domain() == orig.get_domain())) begin
%000000       found = pred.m_find_predecessor_by_name(name,stay_in_scope,orig);
%000000       if (found != null) begin
                
%000000         return found;
              end
        
            end
          end
%000000   return null;
        endfunction
        
        
        // m_find_successor
        // ----------------
        
~000390 function uvm_phase uvm_phase::m_find_successor(uvm_phase phase, bit stay_in_scope=1, uvm_phase orig_phase=null);
 000390   uvm_phase found;
          //$display("  FIND SUCC node '",phase.get_name(),"' (id=",$sformatf("%0d",phase.get_inst_id()),") - checking against ",get_name()," (",m_phase_type.name()," id=",$sformatf("%0d",get_inst_id()),(m_imp==null)?"":{"/",$sformatf("%0d",m_imp.get_inst_id())},")");
~000390   if (phase == null) begin
%000000     return null ;
          end
~000243   if (phase == m_imp || phase == this) begin
%000000     return this;
          end
~000390   foreach (m_successors[succ]) begin
%000000     uvm_phase orig;
%000000     orig = (orig_phase==null) ? this : orig_phase;
%000000     if (!stay_in_scope || 
            (succ.get_schedule() == orig.get_schedule()) ||
%000000     (succ.get_domain() == orig.get_domain())) begin
%000000       found = succ.m_find_successor(phase,stay_in_scope,orig);
%000000       if (found != null) begin
%000000         return found;
              end
            end
          end
 000390   return null;
        endfunction
        
        
        // m_find_successor_by_name
        // ------------------------
        
%000000 function uvm_phase uvm_phase::m_find_successor_by_name(string name, bit stay_in_scope=1, uvm_phase orig_phase=null);
%000000   uvm_phase found;
          //$display("  FIND SUCC node '",name,"' - checking against ",get_name()," (",m_phase_type.name()," id=",$sformatf("%0d",get_inst_id()),(m_imp==null)?"":{"/",$sformatf("%0d",m_imp.get_inst_id())},")");
%000000   if (get_name() == name) begin
            
%000000     return this;
          end
        
%000000   foreach (m_successors[succ]) begin
%000000     uvm_phase orig;
%000000     orig = (orig_phase==null) ? this : orig_phase;
%000000     if (!stay_in_scope || 
            (succ.get_schedule() == orig.get_schedule()) ||
%000000     (succ.get_domain() == orig.get_domain())) begin
%000000       found = succ.m_find_successor_by_name(name,stay_in_scope,orig);
%000000       if (found != null) begin
                
%000000         return found;
              end
        
            end
          end
%000000   return null;
        endfunction
        
        
        // find
        // ----
        
~000147 function uvm_phase uvm_phase::find(uvm_phase phase, bit stay_in_scope=1);
          // TBD full search
          //$display({"\nFIND node '",phase.get_name(),"' within ",get_name()," (scope ",m_phase_type.name(),")", (stay_in_scope) ? " staying within scope" : ""});
~000147   if (phase == m_imp || phase == this) begin
            
%000000     return phase;
          end
        
 000147   find = m_find_predecessor(phase,stay_in_scope,this);
~000147   if (find == null) begin
            
 000147     find = m_find_successor(phase,stay_in_scope,this);
          end
        
        endfunction
        
        
        // find_by_name
        // ------------
        
%000000 function uvm_phase uvm_phase::find_by_name(string name, bit stay_in_scope=1);
          // TBD full search
          //$display({"\nFIND node named '",name,"' within ",get_name()," (scope ",m_phase_type.name(),")", (stay_in_scope) ? " staying within scope" : ""});
%000000   if (get_name() == name) begin
            
%000000     return this;
          end
        
%000000   find_by_name = m_find_predecessor_by_name(name,stay_in_scope,this);
%000000   if (find_by_name == null) begin
            
%000000     find_by_name = m_find_successor_by_name(name,stay_in_scope,this);
          end
        
        endfunction
        
        
        // is
        // --
          
%000000 function bit uvm_phase::is(uvm_phase phase);
%000000   return (m_imp == phase || this == phase); 
        endfunction
        
          
        // is_before
        // ---------
        
%000000 function bit uvm_phase::is_before(uvm_phase phase);
          //$display("this=%s is before phase=%s?",get_name(),phase.get_name());
          // TODO: add support for 'stay_in_scope=1' functionality
%000000   return (!is(phase) && m_find_successor(phase,0,this) != null);
        endfunction
        
        
        // is_after
        // --------
          
%000000 function bit uvm_phase::is_after(uvm_phase phase);
          //$display("this=%s is after phase=%s?",get_name(),phase.get_name());
          // TODO: add support for 'stay_in_scope=1' functionality
%000000   return (!is(phase) && m_find_predecessor(phase,0,this) != null);
        endfunction
        
%000000 function void uvm_phase::get_adjacent_predecessor_nodes(ref uvm_phase pred[]);
%000000    bit done;
%000000    edges_t predecessors;
%000000    int idx;
        
           // Get all predecessors (including TERMINALS, SCHEDULES, etc.)
%000000    foreach (m_predecessors[p]) begin
             
%000000      predecessors[p] = 1;
           end
        
        
           // Replace any terminal / schedule nodes with their predecessors,
           // recursively.
%000000    do begin
%000000      done = 1;
%000000      foreach (predecessors[p]) begin
%000000        if (p.get_phase_type() != UVM_PHASE_NODE) begin
%000000          predecessors.delete(p);
%000000          foreach (p.m_predecessors[next_p]) begin
                      
%000000            predecessors[next_p] = 1;
                 end
        
%000000          done = 0;
               end
             end
%000000    end while (!done); 
        
%000000    pred = new [predecessors.size()];
%000000    foreach (predecessors[p]) begin
%000000      pred[idx++] = p;
           end
        endfunction : get_adjacent_predecessor_nodes
        
 000102 function void uvm_phase::get_adjacent_successor_nodes(ref uvm_phase succ[]);
 000102    bit done;
 000102    edges_t successors;
 000102    int idx;
        
           // Get all successors (including TERMINALS, SCHEDULES, etc.)
 000105    foreach (m_successors[s]) begin
             
 000105      successors[s] = 1;
           end
        
        
           // Replace any terminal / schedule nodes with their successors,
           // recursively.
 000123    do begin
 000123      done = 1;
 000129      foreach (successors[s]) begin
 000108        if (s.get_phase_type() != UVM_PHASE_NODE) begin
 000021          successors.delete(s);
 000021          foreach (s.m_successors[next_s]) begin
                      
 000018            successors[next_s] = 1;
                 end
        
 000021          done = 0;
               end
             end
~000123    end while (!done); 
        
 000102    succ = new [successors.size()];
 000102    foreach (successors[s]) begin
 000102      succ[idx++] = s;
           end
        endfunction : get_adjacent_successor_nodes
        
 000081 function void uvm_phase::get_predecessors(ref edges_t predecessors);
 000081   foreach (m_predecessors[p]) begin
            
 000081     predecessors[p] = 1;
          end
        
        endfunction : get_predecessors
        
 000081 function void uvm_phase::get_successors(ref edges_t successors);
 000081   foreach (m_successors[p]) begin
            
 000081     successors[p] = 1;
          end
        
        endfunction : get_successors
        
 000081 function void uvm_phase::get_sync_relationships(ref edges_t relationships);
~000081   foreach (m_sync[i]) begin
            
%000000     relationships[m_sync[i]] = 1;
          end
        
        endfunction : get_sync_relationships
        
        // Internal implementation, more efficient than calling get_predessor_nodes on all
        // of the successors returned by get_adjacent_successor_nodes
 000102 function void uvm_phase::get_predecessors_for_successors(output edges_t pred_of_succ);
 000102     bit done;
 000102     uvm_phase successors[];
        
 000102     get_adjacent_successor_nodes(successors);
                  
            // get all predecessors to these successors
 000102     foreach (successors[s]) begin
              
 000114       foreach (successors[s].m_predecessors[pred]) begin
                
 000114         pred_of_succ[pred] = 1;
              end
        
            end
        
            
            // replace any terminal nodes with their predecessors, recursively.
            // we are only interested in "real" phase nodes
 000132     do begin
 000132       done=1;
 000171       foreach (pred_of_succ[pred]) begin
 000141         if (pred.get_phase_type() != UVM_PHASE_NODE) begin
 000030           pred_of_succ.delete(pred); 
 000030           foreach (pred.m_predecessors[next_pred]) begin
                    
 000030             pred_of_succ[next_pred] = 1;
                  end
        
 000030           done =0;
                end
              end
~000132     end while (!done);
        
        
            // remove ourselves from the list
 000102     pred_of_succ.delete(this);
        endfunction
        
        
        // m_wait_for_pred
        // ---------------
        
 000024 task uvm_phase::m_wait_for_pred();
 000024     edges_t pred_of_succ;
 000024     get_predecessors_for_successors(pred_of_succ);
        
            // wait for predecessors to successors (real phase nodes, not terminals)
            // mostly debug msgs
~000024     foreach (pred_of_succ[sibling]) begin
        
%000000       if (m_phase_trace) begin
%000000         string s;
%000000         s = $sformatf("Waiting for phase '%s' (%0d) to be READY_TO_END. Current state is %s",
%000000             sibling.get_name(),sibling.get_inst_id(),sibling.m_state.name());
%000000         `UVM_PH_TRACE("PH/TRC/WAIT_PRED_OF_SUCC",s,this,UVM_HIGH)
              end
        
%000000       sibling.wait_for_state(UVM_PHASE_READY_TO_END, UVM_GTE);
        
%000000       if (m_phase_trace) begin
%000000         string s;
%000000         s = $sformatf("Phase '%s' (%0d) is now READY_TO_END. Releasing phase",
%000000             sibling.get_name(),sibling.get_inst_id());
%000000         `UVM_PH_TRACE("PH/TRC/WAIT_PRED_OF_SUCC",s,this,UVM_HIGH)
              end
        
            end
        
~000024     if (m_phase_trace) begin
%000000       if (pred_of_succ.num()) begin
%000000         string s = "( ";
%000000         foreach (pred_of_succ[pred]) begin
                  
%000000           s = {s, pred.get_full_name()," "};
                end
        
%000000         s = {s, ")"};
                `UVM_PH_TRACE("PH/TRC/WAIT_PRED_OF_SUCC",
%000000         {"*** All pred to succ ",s," in READY_TO_END state, so ending phase ***"},this,UVM_HIGH)
              end
%000000       else begin
                `UVM_PH_TRACE("PH/TRC/WAIT_PRED_OF_SUCC",
%000000         "*** No pred to succ other than myself, so ending phase ***",this,UVM_HIGH)
              end
            end
        
 000024   #0; // LET ANY WAITERS WAKE UP
        
        endtask
        
        
        //---------------------------------
        // Implementation - Synchronization
        //---------------------------------
        
%000000 function void uvm_phase::m_report_null_objection(uvm_object obj,
                                                       string description,
                                                       int count,
                                                       string action);
%000000    string m_action;
%000000    string m_addon;
%000000    string m_obj_name = (obj == null) ? "uvm_top" : obj.get_full_name();
           
%000000    if ((action == "raise") || (action == "drop")) begin
%000000      if (count != 1) begin
                
%000000        m_action = $sformatf("%s %0d objections", action, count);
             end
        
%000000      else begin
                
%000000        m_action = $sformatf("%s an objection", action);
             end
         
           end
%000000    else if (action == "get_objection_count") begin
%000000      m_action = "call get_objection_count";
           end
        
%000000    if (this.get_phase_type() == UVM_PHASE_IMP) begin
%000000      m_addon = " (This is a UVM_PHASE_IMP, you have to query the schedule to find the UVM_PHASE_NODE)";
           end
           
           `uvm_error("UVM/PH/NULL_OBJECTION",
                      $sformatf("'%s' attempted to %s on '%s', however '%s' is not a task-based phase node! %s",
                                m_obj_name,
                                m_action,
                                get_name(),
                                get_name(),
%000000                         m_addon))
        endfunction : m_report_null_objection
                                
           
        // raise_objection
        // ---------------
        
%000003 function void uvm_phase::raise_objection (uvm_object obj, 
                                                           string description="",
                                                           int count=1);
%000003   uvm_objection phase_done;
%000003   phase_done = get_objection();
%000003   if (phase_done != null) begin
            
%000003     phase_done.raise_objection(obj,description,count);
          end
        
%000000   else begin
            
%000000     m_report_null_objection(obj, description, count, "raise");
          end
        
        endfunction
        
        
        // drop_objection
        // --------------
        
%000003 function void uvm_phase::drop_objection (uvm_object obj, 
                                                          string description="",
                                                          int count=1);
%000003   uvm_objection phase_done;
%000003   phase_done = get_objection();
%000003   if (phase_done != null) begin
            
%000003     phase_done.drop_objection(obj,description,count);
          end
        
%000000   else begin
            
%000000     m_report_null_objection(obj, description, count, "drop");
          end
        
        endfunction
        
        // get_objection_count
        // -------------------
        
%000000 function int uvm_phase::get_objection_count (uvm_object obj=null);
%000000   uvm_objection phase_done;
%000000   phase_done = get_objection();
%000000   if (phase_done != null) begin
            
%000000     return phase_done.get_objection_count(obj);
          end
        
%000000   else begin
%000000     m_report_null_objection(obj, "" , 0, "get_objection_count");
%000000     return 0;
          end
        endfunction : get_objection_count
        
        // get_objection_total
        // -------------------
        
%000000 function int uvm_phase::get_objection_total (uvm_object obj=null);
%000000   uvm_objection phase_done;
%000000   phase_done = get_objection();
%000000   if (phase_done != null) begin
            
%000000     return phase_done.get_objection_total(obj);
          end
        
%000000   else begin
%000000     m_report_null_objection(obj, "" , 0, "get_objection_total");
%000000     return 0;
          end
        endfunction : get_objection_total
        
        // sync
        // ----
        
%000000 function void uvm_phase::sync(uvm_domain target,
                                      uvm_phase phase=null,
%000000                               uvm_phase with_phase=null);
%000000   if (!this.is_domain()) begin
%000000     `uvm_fatal("PH_BADSYNC","sync() called from a non-domain phase schedule node")
          end
%000000   else if (target == null) begin
%000000     `uvm_fatal("PH_BADSYNC","sync() called with a null target domain")
          end
%000000   else if (!target.is_domain()) begin
%000000     `uvm_fatal("PH_BADSYNC","sync() called with a non-domain phase schedule node as target")
          end
%000000   else if (phase == null && with_phase != null) begin
%000000     `uvm_fatal("PH_BADSYNC","sync() called with null phase and non-null with phase")
          end
%000000   else if (phase == null) begin
            // whole domain sync - traverse this domain schedule from begin to end node and sync each node
%000000     edges_t visited;
%000000     uvm_phase queue[$];
%000000     queue.push_back(this);
%000000     visited[this] = 1;
%000000     while (queue.size()) begin
%000000       uvm_phase node;
%000000       node = queue.pop_front();
%000000       if (node.m_imp != null) begin
%000000         sync(target, node.m_imp);
              end
%000000       foreach (node.m_successors[succ]) begin
%000000         if (!visited.exists(succ)) begin
%000000           queue.push_back(succ);
%000000           visited[succ] = 1;
                end
              end
            end
%000000   end else begin
            // single phase sync
            // this is a 2-way ('with') sync and we check first in case it is already there
%000000     uvm_phase from_node, to_node;
%000000     int found_to[$], found_from[$];
%000000     if(with_phase == null) begin
%000000       with_phase = phase;
            end
        
%000000     from_node = find(phase);
%000000     to_node = target.find(with_phase);
%000000     if(from_node == null || to_node == null) begin
%000000       return;
            end
        
%000000     found_to = from_node.m_sync.find_index(node) with (node == to_node);
%000000     found_from = to_node.m_sync.find_index(node) with (node == from_node);
%000000     if (found_to.size() == 0) begin
%000000       from_node.m_sync.push_back(to_node);
            end
        
%000000     if (found_from.size() == 0) begin
%000000       to_node.m_sync.push_back(from_node);
            end
        
          end
        endfunction
        
        
        // unsync
        // ------
        
%000000 function void uvm_phase::unsync(uvm_domain target,
                                        uvm_phase phase=null,
%000000                                 uvm_phase with_phase=null);
%000000   if (!this.is_domain()) begin
%000000     `uvm_fatal("PH_BADSYNC","unsync() called from a non-domain phase schedule node")
%000000   end else if (target == null) begin
%000000     `uvm_fatal("PH_BADSYNC","unsync() called with a null target domain")
%000000   end else if (!target.is_domain()) begin
%000000     `uvm_fatal("PH_BADSYNC","unsync() called with a non-domain phase schedule node as target")
%000000   end else if (phase == null && with_phase != null) begin
%000000     `uvm_fatal("PH_BADSYNC","unsync() called with null phase and non-null with phase")
%000000   end else if (phase == null) begin
            // whole domain unsync - traverse this domain schedule from begin to end node and unsync each node
%000000     edges_t visited;
%000000     uvm_phase queue[$];
%000000     queue.push_back(this);
%000000     visited[this] = 1;
%000000     while (queue.size()) begin
%000000       uvm_phase node;
%000000       node = queue.pop_front();
%000000       if (node.m_imp != null) begin
%000000         unsync(target,node.m_imp);
              end
        
%000000       foreach (node.m_successors[succ]) begin
%000000         if (!visited.exists(succ)) begin
%000000           queue.push_back(succ);
%000000           visited[succ] = 1;
                end
              end
            end
%000000   end else begin
            // single phase unsync
            // this is a 2-way ('with') sync and we check first in case it is already there
%000000     uvm_phase from_node, to_node;
%000000     int found_to[$], found_from[$];
%000000     if(with_phase == null) begin
%000000       with_phase = phase;
            end
        
%000000     from_node = find(phase);
%000000     to_node = target.find(with_phase);
%000000     if(from_node == null || to_node == null) begin
%000000       return;
            end
        
%000000     found_to = from_node.m_sync.find_index(node) with (node == to_node);
%000000     found_from = to_node.m_sync.find_index(node) with (node == from_node);
%000000     if (found_to.size()) begin
%000000       from_node.m_sync.delete(found_to[0]);
            end
        
%000000     if (found_from.size()) begin
%000000       to_node.m_sync.delete(found_from[0]);
            end
        
          end
        endfunction
        
        
        // wait_for_state
        //---------------
          
 000258 task uvm_phase::wait_for_state(uvm_phase_state state, uvm_wait_op op=UVM_EQ);
 000258   case (op)
 000081     UVM_EQ:  begin
 000081       wait((state&m_state) != 0);
            end
        
%000000     UVM_NE:  begin
%000000       wait((state&m_state) == 0);
            end
        
%000000     UVM_LT:  begin
%000000       wait(m_state <  state);
            end
        
%000000     UVM_LTE: begin
%000000       wait(m_state <= state);
            end
        
%000000     UVM_GT:  begin
%000000       wait(m_state >  state);
            end
        
 000177     UVM_GTE: begin
 000177       wait(m_state >= state);
            end
        
          endcase
        endtask
        
        
        //-------------------------
        // Implementation - Jumping
        //-------------------------
        
        // set_jump_phase
        // ----
        //
        // Specify a phase to transition to when phase is complete.
        
%000000 function void uvm_phase::set_jump_phase(uvm_phase phase) ;
%000000   uvm_phase d;
%000000   bit active;
%000000   uvm_phase_state state;
%000000   state = get_state();
%000000   active = (state >= UVM_PHASE_STARTED) && (state <= UVM_PHASE_ENDED);
        
%000000   if (!active) begin
%000000     if (phase == null) begin
              // Clear out jump information
%000000       m_jump_phase = null;
%000000       m_jump_fwd = 0;
%000000       m_jump_bkwd = 0;
%000000       m_premature_end = 0;
%000000       return;
            end
%000000     else begin
              `uvm_error("JMPPHIDL", { "Attempting to jump from phase \"",
              get_name(), "\" which is not currently active (current state is ",
              state.name(), "). The jump will not happen until the phase becomes ",
%000000       "active."})
            end
          end
          
          // A jump can be either forward or backwards in the phase graph.
          // If the specified phase (name) is found in the set of predecessors
          // then we are jumping backwards.  If, on the other hand, the phase is in the set
          // of successors then we are jumping forwards.  If neither, then we
          // have an error.
          //
          // If the phase is non-existant and thus we don't know where to jump
          // we have a situation where the only thing to do is to uvm_report_fatal
          // and terminate_phase.  By calling this function the intent was to
          // jump to some other phase. So, continuing in the current phase doesn't
          // make any sense.  And we don't have a valid phase to jump to.  So we're done.
        
%000000   d = m_find_predecessor(phase,0);
%000000   if (d == null) begin
%000000     d = m_find_successor(phase,0);
%000000     if (d == null) begin
%000000       string msg;
%000000       $sformat(msg,{"phase %s is neither a predecessor or successor of ",
%000000                     "phase %s or is non-existant, so we cannot jump to it.  ",
%000000                     "Phase control flow is now undefined so the simulation ",
%000000                     "must terminate"}, phase.get_name(), get_name());
%000000       `uvm_fatal("PH_BADJUMP", msg)
            end
%000000     else begin
%000000       m_jump_fwd = 1;
              `uvm_info("PH_JUMPF",$sformatf("jumping forward to phase %s", phase.get_name()),
%000000       UVM_DEBUG)
            end
          end
%000000   else begin
%000000     m_jump_bkwd = 1;
            `uvm_info("PH_JUMPB",$sformatf("jumping backward to phase %s", phase.get_name()),
%000000     UVM_DEBUG)
          end
          
%000000   m_jump_phase = d;
        endfunction
        
        // is_jumping_forward
%000000 function bit uvm_phase::is_jumping_forward();
%000000   return m_jump_fwd;
        endfunction : is_jumping_forward
        
        // is_jumping_backward
%000000 function bit uvm_phase::is_jumping_backward();
%000000   return m_jump_bkwd;
        endfunction : is_jumping_backward
        
        // end_prematurely
        // ----
        //
        // Set a flag to cause the phase to end prematurely.  
        
%000000 function void uvm_phase::end_prematurely() ;
%000000    m_premature_end = 1 ;
        endfunction
        
        // is_ending_permaturely
%000000 function bit uvm_phase::is_ending_prematurely();
%000000   return m_premature_end;
        endfunction : is_ending_prematurely
        
        
        // jump
        // ----
        //
        // Note that this function does not directly alter flow of control.
        // That is, the new phase is not initiated in this function.
        // Rather, flags are set which execute_phase() uses to determine
        // that a jump has been requested and performs the jump.
        
%000000 function void uvm_phase::jump(uvm_phase phase);
%000000    set_jump_phase(phase) ;
%000000    end_prematurely() ;
        endfunction
        
        
        // jump_all
        // --------
%000000 function void uvm_phase::jump_all(uvm_phase phase);
%000000     `uvm_warning("NOTIMPL","uvm_phase::jump_all is not implemented and has been replaced by uvm_domain::jump_all")
        endfunction
        
        
        // get_jump_target
        // ---------------
          
 000081 function uvm_phase uvm_phase::get_jump_target();
 000081   return m_jump_phase;
        endfunction
        
        
        // clear
        // -----
        // for internal graph maintenance after a forward jump
%000000 function void uvm_phase::clear(uvm_phase_state state = UVM_PHASE_DORMANT);
%000000   uvm_objection phase_done;
%000000   phase_done = get_objection();
%000000   set_state(state);
%000000   m_phase_proc = null;
%000000   if (phase_done != null) begin
            
%000000     phase_done.clear(this);
          end
        
        endfunction
        
        
        // clear_successors
        // ----------------
        // for internal graph maintenance after a forward jump
        // - called only by execute_phase()
        // - depth-first traversal of the DAG, calliing clear() on each node
        // - do not clear the end phase or beyond 
%000000 function void uvm_phase::clear_successors(uvm_phase_state state = UVM_PHASE_DORMANT, 
            uvm_phase end_state=null);
%000000   if(this == end_state) begin 
            
%000000     return;
          end
        
%000000   clear(state);
%000000   foreach(m_successors[succ]) begin
%000000     succ.clear_successors(state, end_state);
          end
        endfunction
        
        
        //---------------------------------
        // Implementation - Overall Control
        //---------------------------------
        // wait_for_self_and_siblings_to_drop
        // -----------------------------
        // This task loops until this phase instance and all its siblings, either
        // sync'd or sharing a common successor, have all objections dropped.
 000078 task uvm_phase::wait_for_self_and_siblings_to_drop() ;
 000078   bit need_to_check_all = 1 ;
 000078   uvm_root top;
 000078   uvm_coreservice_t cs;
 000078   edges_t siblings;
          
~000078   `UVM_PH_TRACE("PH/TRC/WAIT_SELF_AND_SIBLINGS","WAITING FOR SELF AND SIBLINGS TO DROP",this,UVM_HIGH)
          
 000078   cs = uvm_coreservice_t::get();
 000078   top = cs.get_root();
          
 000078   get_predecessors_for_successors(siblings);
~000078   foreach (m_sync[i]) begin
%000000     siblings[m_sync[i]] = 1;
          end
        
          // Put ourselves in the list of siblings
 000078   siblings[this] = 1;
          
 000081   while (need_to_check_all) begin
 000081     uvm_objection phase_done;
 000081     string msg;
 000081     phase_done = get_objection();
 000081     need_to_check_all = 0 ; //if all are dropped, we won't need to do this again
        
            // now wait for siblings to drop
 000096     foreach(siblings[sib]) begin
 000096       phase_done = sib.get_objection();
 000096       sib.wait_for_state(UVM_PHASE_EXECUTING, UVM_GTE); // sibling must be at least executing 
~000093       if ((phase_done != null) && (phase_done.get_objection_total(top) != 0)) begin
%000003         if (m_phase_trace) begin
%000000           msg = $sformatf("Waiting for phase '%s' (%0d) to be READY_TO_END. Current state is %s",
%000000                           sib.get_name(),sib.get_inst_id(),sib.m_state.name());
%000000           `UVM_PH_TRACE("PH/TRC/WAIT_SELF_AND_SIBLINGS",msg,this,UVM_HIGH)
                end
%000003         m_state = UVM_PHASE_EXECUTING ;
%000003         phase_done.wait_for(UVM_ALL_DROPPED, top); // sibling must drop any objection
%000003         if (m_phase_trace) begin
%000000           msg = $sformatf("Phase '%s' (%0d) is now READY_TO_END. Releasing phase",
%000000                           sib.get_name(),sib.get_inst_id());
%000000           `UVM_PH_TRACE("PH/TRC/WAIT_SELF_AND_SIBLINGS",msg,this,UVM_HIGH)
                end
%000003         need_to_check_all = 1 ;
              end
            end
          end
        endtask
        
        // kill
        // ----
        
%000000 function void uvm_phase::kill();
        
%000000   `uvm_info("PH_KILL", {"killing phase '", get_name(),"'"}, UVM_DEBUG)
        
%000000   if (m_phase_proc != null) begin
%000000     m_phase_proc.kill();
%000000     m_phase_proc = null;
          end
        
        endfunction
        
        
        // kill_successors
        // ---------------
        
        // Using a depth-first traversal, kill all the successor phases of the
        // current phase.
%000000 function void uvm_phase::kill_successors();
%000000   foreach (m_successors[succ]) begin
            
%000000     succ.kill_successors();
          end
        
%000000   kill();
        endfunction
        
        
        // terminate_phase
        // ---------------
        
%000000 function void uvm_phase::m_terminate_phase();
%000000   uvm_objection phase_done;
%000000   phase_done = get_objection();
%000000   if (phase_done != null) begin
            
%000000     phase_done.clear(this);
          end
        
        endfunction
        
        
        // print_termination_state
        // -----------------------
        
%000000 function void uvm_phase::m_print_termination_state();
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   uvm_objection phase_done;
%000000   phase_done = get_objection();
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   if (phase_done != null) begin
            `uvm_info("PH_TERMSTATE",
            $sformatf("phase %s outstanding objections = %0d",
            get_name(), phase_done.get_objection_total(top)),
%000000     UVM_DEBUG)
          end
%000000   else begin
            `uvm_info("PH_TERMSTATE",
            $sformatf("phase %s has no outstanding objections",
            get_name()),
%000000     UVM_DEBUG)
          end
        endfunction
        
           
        
