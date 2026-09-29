//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2011-2022 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2012-2018 Cisco Systems, Inc.
        // Copyright 2018 Intel Corporation
        // Copyright 2020-2022 Marvell International Ltd.
        // Copyright 2007-2021 Mentor Graphics Corporation
        // Copyright 2013-2026 NVIDIA Corporation
        // Copyright 2010 Paradigm Works
        // Copyright 2025 Qualcomm, Inc.
        // Copyright 2014 Semifore
        // Copyright 2010-2014 Synopsys, Inc.
        // Copyright 2017-2018 Verific
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
        // $File:     src/base/uvm_component.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_objection;
        typedef class uvm_sequence_base;
        typedef class uvm_sequence_item;
        
        // Command line classes (undocumented)
        typedef class uvm_cmdline_set_verbosity;
        typedef class uvm_cmdline_set_action;
        typedef class uvm_cmdline_set_severity;
          
        //----------------------------------------------------------------------
        // Class: uvm_component
        //
        // The library implements the following public API beyond what is 
        // documented in 1800.2.
        ///------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 13.1.1
        virtual class uvm_component extends uvm_report_object;
        
          // Function -- NODOCS -- new
          //
          // Creates a new component with the given leaf instance ~name~ and handle
          // to its ~parent~.  If the component is a top-level component (i.e. it is
          // created in a static module or interface), ~parent~ should be ~null~.
          //
          // The component will be inserted as a child of the ~parent~ object, if any.
          // If ~parent~ already has a child by the given ~name~, an error is produced.
          //
          // If ~parent~ is ~null~, then the component will become a child of the
          // implicit top-level component, ~uvm_top~.
          //
          // All classes derived from uvm_component must call super.new(name,parent).
        
          // @uvm-ieee 1800.2-2020 auto 13.1.2.1
          extern function new (string name, uvm_component parent);
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Hierarchy Interface
          //----------------------------------------------------------------------------
          //
          // These methods provide user access to information about the component
          // hierarchy, i.e., topology.
          // 
          //----------------------------------------------------------------------------
        
          // Function -- NODOCS -- get_parent
          //
          // Returns a handle to this component's parent, or ~null~ if it has no parent.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.1
          extern virtual function uvm_component get_parent ();
        
        
          // Function -- NODOCS -- get_full_name
          //
          // Returns the full hierarchical name of this object. The default
          // implementation concatenates the hierarchical name of the parent, if any,
          // with the leaf name of this object, as given by <uvm_object::get_name>. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.2
          extern virtual function string get_full_name ();
        
        
          // Function -- NODOCS -- get_children
          //
          // This function populates the end of the ~children~ array with the 
          // list of this component's children. 
          //
          //|   uvm_component array[$];
          //|   my_comp.get_children(array);
          //|   foreach(array[i]) 
          //|     do_something(array[i]);
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.3
          extern function void get_children(ref uvm_component children[$]);
        
        
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.4
          extern function uvm_component get_child (string name);
        
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.4
          extern function int get_next_child (ref string name);
        
          // Function -- NODOCS -- get_first_child
          //
          // These methods are used to iterate through this component's children, if
          // any. For example, given a component with an object handle, ~comp~, the
          // following code calls <uvm_object::print> for each child:
          //
          //|    string name;
          //|    uvm_component child;
          //|    if (comp.get_first_child(name))
          //|      do begin
          //|        child = comp.get_child(name);
          //|        child.print();
          //|      end while (comp.get_next_child(name));
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.4
          extern function int get_first_child (ref string name);
        
        
          // Function -- NODOCS -- get_num_children
          //
          // Returns the number of this component's children. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.5
          extern function int get_num_children ();
        
        
          // Function -- NODOCS -- has_child
          //
          // Returns 1 if this component has a child with the given ~name~, 0 otherwise.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.6
          extern function int has_child (string name);
        
        
          // Function - set_name
          //
          // Renames this component to ~name~ and recalculates all descendants'
          // full names. This is an internal function for now.
        
          extern virtual function void set_name (string name);
        
          
          // Function -- NODOCS -- lookup
          //
          // Looks for a component with the given hierarchical ~name~ relative to this
          // component. If the given ~name~ is preceded with a '.' (dot), then the search
          // begins relative to the top level (absolute lookup). The handle of the
          // matching component is returned, else ~null~. The name must not contain
          // wildcards.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.3.7
          extern function uvm_component lookup (string name);
        
        
          // Function -- NODOCS -- get_depth
          //
          // Returns the component's depth from the root level. uvm_top has a
          // depth of 0. The test and any other top level components have a depth
          // of 1, and so on.
        
          extern function int unsigned get_depth();
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Phasing Interface
          //----------------------------------------------------------------------------
          //
          // These methods implement an interface which allows all components to step
          // through a standard schedule of phases, or a customized schedule, and
          // also an API to allow independent phase domains which can jump like state
          // machines to reflect behavior e.g. power domains on the DUT in different
          // portions of the testbench. The phase tasks and functions are the phase
          // name with the _phase suffix. For example, the build phase function is
          // <build_phase>.
          //
          // All processes associated with a task-based phase are killed when the phase
          // ends. See <uvm_task_phase> for more details.
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- build_phase
          //
          // The <uvm_build_phase> phase implementation method.
          //
          // Any override should call super.build_phase(phase) to execute the automatic
          // configuration of fields registered in the component by calling 
          // <apply_config_settings>.
          // To turn off automatic configuration for a component, 
          // do not call super.build_phase(phase).
          //
          // This method should never be called directly. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.1
          extern virtual function void build_phase(uvm_phase phase);
        
          // Function -- NODOCS -- connect_phase
          //
          // The <uvm_connect_phase> phase implementation method.
          //
          // This method should never be called directly. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.2
          extern virtual function void connect_phase(uvm_phase phase);
        
          // Function -- NODOCS -- end_of_elaboration_phase
          //
          // The <uvm_end_of_elaboration_phase> phase implementation method.
          //
          // This method should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.3
          extern virtual function void end_of_elaboration_phase(uvm_phase phase);
        
          // Function -- NODOCS -- start_of_simulation_phase
          //
          // The <uvm_start_of_simulation_phase> phase implementation method.
          //
          // This method should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.4
          extern virtual function void start_of_simulation_phase(uvm_phase phase);
        
          // Task -- NODOCS -- run_phase
          //
          // The <uvm_run_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // Thus the phase will automatically
          // end once all objections are dropped using ~phase.drop_objection()~.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // The run_phase task should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.5
          extern virtual task run_phase(uvm_phase phase);
        
          // Task -- NODOCS -- pre_reset_phase
          //
          // The <uvm_pre_reset_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.1
          extern virtual task pre_reset_phase(uvm_phase phase);
        
          // Task -- NODOCS -- reset_phase
          //
          // The <uvm_reset_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.2
          extern virtual task reset_phase(uvm_phase phase);
        
          // Task -- NODOCS -- post_reset_phase
          //
          // The <uvm_post_reset_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.3
          extern virtual task post_reset_phase(uvm_phase phase);
        
          // Task -- NODOCS -- pre_configure_phase
          //
          // The <uvm_pre_configure_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.4
          extern virtual task pre_configure_phase(uvm_phase phase);
        
          // Task -- NODOCS -- configure_phase
          //
          // The <uvm_configure_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.5
          extern virtual task configure_phase(uvm_phase phase);
        
          // Task -- NODOCS -- post_configure_phase
          //
          // The <uvm_post_configure_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.6
          extern virtual task post_configure_phase(uvm_phase phase);
        
          // Task -- NODOCS -- pre_main_phase
          //
          // The <uvm_pre_main_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.7
          extern virtual task pre_main_phase(uvm_phase phase);
        
          // Task -- NODOCS -- main_phase
          //
          // The <uvm_main_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.8
          extern virtual task main_phase(uvm_phase phase);
        
          // Task -- NODOCS -- post_main_phase
          //
          // The <uvm_post_main_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.9
          extern virtual task post_main_phase(uvm_phase phase);
        
          // Task -- NODOCS -- pre_shutdown_phase
          //
          // The <uvm_pre_shutdown_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.10
          extern virtual task pre_shutdown_phase(uvm_phase phase);
        
          // Task -- NODOCS -- shutdown_phase
          //
          // The <uvm_shutdown_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.11
          extern virtual task shutdown_phase(uvm_phase phase);
        
          // Task -- NODOCS -- post_shutdown_phase
          //
          // The <uvm_post_shutdown_phase> phase implementation method.
          //
          // This task returning or not does not indicate the end
          // or persistence of this phase.
          // It is necessary to raise an objection
          // using ~phase.raise_objection()~ to cause the phase to persist.
          // Once all components have dropped their respective objection
          // using ~phase.drop_objection()~, or if no components raises an
          // objection, the phase is ended.
          // 
          // Any processes forked by this task continue to run
          // after the task returns,
          // but they will be killed once the phase ends.
          //
          // This method should not be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.2.12
          extern virtual task post_shutdown_phase(uvm_phase phase);
        
          // Function -- NODOCS -- extract_phase
          //
          // The <uvm_extract_phase> phase implementation method.
          //
          // This method should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.6
          extern virtual function void extract_phase(uvm_phase phase);
        
        
        
          // Function -- NODOCS -- check_phase
          //
          // The <uvm_check_phase> phase implementation method.
          //
          // This method should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.7
          extern virtual function void check_phase(uvm_phase phase);
        
          // Function -- NODOCS -- report_phase
          //
          // The <uvm_report_phase> phase implementation method.
          //
          // This method should never be called directly.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.8
          extern virtual function void report_phase(uvm_phase phase);
        
          // Function -- NODOCS -- final_phase
          //
          // The <uvm_final_phase> phase implementation method.
          //
          // This method should never be called directly.
          
          // @uvm-ieee 1800.2-2020 auto 13.1.4.1.9
          extern virtual function void final_phase(uvm_phase phase);
        
          // Function -- NODOCS -- phase_started
          //
          // Invoked at the start of each phase. The ~phase~ argument specifies
          // the phase being started. Any threads spawned in this callback are
          // not affected when the phase ends.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.3.1
          extern virtual function void phase_started (uvm_phase phase);
        
          // Function -- NODOCS -- phase_ready_to_end
          //
          // Invoked when all objections to ending the given ~phase~ and all
          // sibling phases have been dropped, thus indicating that ~phase~ is 
          // ready to begin a clean exit. Sibling phases are any phases that 
          // have a common successor phase in the schedule plus any phases that
          // sync'd to the current phase. Components needing to consume delta
          // cycles or advance time to perform a clean exit from the phase
          // may raise the phase's objection. 
          //
          // |phase.raise_objection(this,"Reason");
          //
          // It is the responsibility of this component to drop the objection 
          // once it is ready for this phase to end (and processes killed).
          // If no objection to the given ~phase~ or sibling phases are raised,
          // then phase_ended() is called after a delta cycle.  If any objection
          // is raised, then when all objections to ending the given ~phase~
          // and siblings are dropped, another iteration of phase_ready_to_end
          // is called.  To prevent endless iterations due to coding error,
          // after 20 iterations, phase_ended() is called regardless of whether
          // previous iteration had any objections raised.
          
          // @uvm-ieee 1800.2-2020 auto 13.1.4.3.2
          extern virtual function void phase_ready_to_end (uvm_phase phase);
        
        
          // Function -- NODOCS -- phase_ended
          //
          // Invoked at the end of each phase. The ~phase~ argument specifies
          // the phase that is ending.  Any threads spawned in this callback are
          // not affected when the phase ends.
          
          // @uvm-ieee 1800.2-2020 auto 13.1.4.3.3
          extern virtual function void phase_ended (uvm_phase phase);
        
          
          //--------------------------------------------------------------------
          // phase / schedule / domain API
          //--------------------------------------------------------------------
        
          
          // Function -- NODOCS -- set_domain
          //
          // Apply a phase domain to this component and, if ~hier~ is set, 
          // recursively to all its children. 
          //
          // Calls the virtual <define_domain> method, which derived components can
          // override to augment or replace the domain definition of its base class.
          //
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.4.1
          extern function void set_domain(uvm_domain domain, int hier=1);
        
        
          // Function -- NODOCS -- get_domain
          //
          // Return handle to the phase domain set on this component
          
          // @uvm-ieee 1800.2-2020 auto 13.1.4.4.2
          extern function uvm_domain get_domain();
        
        
          // Function -- NODOCS -- define_domain
          //
          // Builds custom phase schedules into the provided ~domain~ handle.
          //
          // This method is called by <set_domain>, which integrators use to specify
          // this component belongs in a domain apart from the default 'uvm' domain.
          //
          // Custom component base classes requiring a custom phasing schedule can
          // augment or replace the domain definition they inherit by overriding
          // their ~defined_domain~. To augment, overrides would call super.define_domain().
          // To replace, overrides would not call super.define_domain().
          // 
          // The default implementation adds a copy of the ~uvm~ phasing schedule to
          // the given ~domain~, if one doesn't already exist, and only if the domain
          // is currently empty.
          //
          // Calling <set_domain>
          // with the default ~uvm~ domain (i.e. <uvm_domain::get_uvm_domain> ) on
          // a component with no ~define_domain~ override effectively reverts the
          // that component to using the default ~uvm~ domain. This may be useful
          // if a branch of the testbench hierarchy defines a custom domain, but
          // some child sub-branch should remain in the default ~uvm~ domain,
          // call <set_domain> with a new domain instance handle with ~hier~ set.
          // Then, in the sub-branch, call <set_domain> with the default ~uvm~ domain handle,
          // obtained via <uvm_domain::get_uvm_domain>.
          //
          // Alternatively, the integrator may define the graph in a new domain externally,
          // then call <set_domain> to apply it to a component.
        
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.4.3
          extern virtual protected function void define_domain(uvm_domain domain);
        
          // @uvm-compat for compatibility with 1.2
          extern function void set_phase_imp(uvm_phase phase, uvm_phase imp, int hier=1);
        
          // @uvm-compat for compatibility with OVM
          extern virtual function void build();
          // @uvm-compat for compatibility with OVM
          extern virtual function void connect();
          // @uvm-compat for compatibility with OVM
          extern virtual function void end_of_elaboration();
          // @uvm-compat for compatibility with OVM
          extern virtual function void start_of_simulation();
          // @uvm-compat for compatibility with OVM
          extern virtual task run();
          // @uvm-compat for compatibility with OVM
          extern virtual function void extract();
          // @uvm-compat for compatibility with OVM
          extern virtual function void check();
          // @uvm-compat for compatibility with OVM
          extern virtual function void report();
        
        
          // Task -- NODOCS -- suspend
          //
          // Suspend this component.
          //
          // This method must be implemented by the user to suspend the
          // component according to the protocol and functionality it implements.
          // A suspended component can be subsequently resumed using <resume()>. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.5.1
          extern virtual task suspend ();
        
        
          // Task -- NODOCS -- resume
          //
          // Resume this component.
          //
          // This method must be implemented by the user to resume a component
          // that was previously suspended using <suspend()>.
          // Some component may start in the suspended state and
          // may need to be explicitly resumed.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.5.2
          extern virtual task resume ();
        
        
          // Function -- NODOCS -- resolve_bindings
          //
          // Processes all port, export, and imp connections. Checks whether each port's
          // min and max connection requirements are met.
          //
          // It is called just before the end_of_elaboration phase.
          //
          // Users should not call directly.
        
          extern virtual function void resolve_bindings ();
        
          extern function string massage_scope(string scope);
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Configuration Interface
          //----------------------------------------------------------------------------
          //
          // Components can be designed to be user-configurable in terms of its
          // topology (the type and number of children it has), mode of operation, and
          // run-time parameters (knobs). The configuration interface accommodates
          // this common need, allowing component composition and state to be modified
          // without having to derive new classes or new class hierarchies for
          // every configuration scenario. 
          //
          //----------------------------------------------------------------------------
        
          // Function -- NODOCS -- check_config_usage
          // @uvm-compat  , for compatibility with 1.2
          // 
          // Check all configuration settings in a components configuration table
          // to determine if the setting has been used, overridden or not used.
          // When ~recurse~ is 1 (default), configuration for this and all child
          // components are recursively checked. This function is automatically
          // called in the check phase, but can be manually called at any time.
          //
          // To get all configuration information prior to the run phase, do something 
          // like this in your top object:
          //|  function void start_of_simulation_phase(uvm_phase phase);
          //|    check_config_usage();
          //|  endfunction
        
          extern function void check_config_usage (bit recurse=1);
        
          // Function -- NODOCS -- set_config_int
          //@uvm-compat
          extern virtual function void set_config_int (string inst_name,  
                                                       string field_name,
                                                       uvm_bitstream_t value);
        
          // Function -- NODOCS -- set_config_string
          //@uvm-compat
          extern virtual function void set_config_string (string inst_name,  
                                                          string field_name,
                                                          string value);
        
          // Function -- NODOCS -- set_config_object
          //
          // Calling set_config_* causes configuration settings to be created and
          // placed in a table internal to this component. There are similar global
          // methods that store settings in a global table. Each setting stores the
          // supplied ~inst_name~, ~field_name~, and ~value~ for later use by descendent
          // components during their construction. (The global table applies to
          // all components and takes precedence over the component tables.)
          //
          // When a descendant component calls a get_config_* method, the ~inst_name~
          // and ~field_name~ provided in the get call are matched against all the
          // configuration settings stored in the global table and then in each
          // component in the parent hierarchy, top-down. Upon the first match, the
          // value stored in the configuration setting is returned. Thus, precedence is
          // global, following by the top-level component, and so on down to the
          // descendent component's parent.
          //
          // These methods work in conjunction with the get_config_* methods to
          // provide a configuration setting mechanism for integral, string, and
          // uvm_object-based types. Settings of other types, such as virtual interfaces
          // and arrays, can be indirectly supported by defining a class that contains
          // them.
          //
          // Both ~inst_name~ and ~field_name~ may contain wildcards.
          //
          // - For set_config_int, ~value~ is an integral value that can be anything
          //   from 1 bit to 4096 bits.
          //
          // - For set_config_string, ~value~ is a string.
          //
          // - For set_config_object, ~value~ must be an <uvm_object>-based object or
          //   null.  Its clone argument specifies whether the object should be cloned.
          //   If set, the object is cloned both going into the table (during the set)
          //   and coming out of the table (during the get), so that multiple components
          //   matched to the same setting (by way of wildcards) do not end up sharing
          //   the same object.
          //
          //
          // See <get_config_int>, <get_config_string>, and <get_config_object> for
          // information on getting the configurations set by these methods.
        
          //@uvm-compat
          extern virtual function void set_config_object (string inst_name,  
                                                          string field_name,
                                                          uvm_object value,  
                                                          bit clone=1);
        
        
          // Function -- NODOCS -- get_config_int
          //@uvm-compat
          extern virtual function bit get_config_int (string field_name,
                                                      inout uvm_bitstream_t value);
        
          // Function -- NODOCS -- get_config_string
          //@uvm-compat
          extern virtual function bit get_config_string (string field_name,
                                                         inout string value);
        
          // Function -- NODOCS -- get_config_object
          //
          // These methods retrieve configuration settings made by previous calls to
          // their set_config_* counterparts. As the methods' names suggest, there is
          // direct support for integral types, strings, and objects.  Settings of other
          // types can be indirectly supported by defining an object to contain them.
          //
          // Configuration settings are stored in a global table and in each component
          // instance. With each call to a get_config_* method, a top-down search is
          // made for a setting that matches this component's full name and the given
          // ~field_name~. For example, say this component's full instance name is
          // top.u1.u2. First, the global configuration table is searched. If that
          // fails, then it searches the configuration table in component 'top',
          // followed by top.u1. 
          //
          // The first instance/field that matches causes ~value~ to be written with the
          // value of the configuration setting and 1 is returned. If no match
          // is found, then ~value~ is unchanged and the 0 returned.
          //
          // Calling the get_config_object method requires special handling. Because
          // ~value~ is an output of type <uvm_object>, you must provide an uvm_object
          // handle to assign to (_not_ a derived class handle). After the call, you can
          // then $cast to the actual type.
          //
          // For example, the following code illustrates how a component designer might
          // call upon the configuration mechanism to assign its ~data~ object property,
          // whose type myobj_t derives from uvm_object.
          //
          //|  class mycomponent extends uvm_component;
          //|
          //|    local myobj_t data;
          //|
          //|    function void build_phase(uvm_phase phase);
          //|      uvm_object tmp;
          //|      super.build_phase(phase);
          //|      if(get_config_object("data", tmp))
          //|        if (!$cast(data, tmp))
          //|          $display("error! config setting for 'data' not of type myobj_t");
          //|        endfunction
          //|      ...
          //
          // The above example overrides the <build_phase> method. If you want to retain
          // any base functionality, you must call super.build_phase(uvm_phase phase).
          //
          // The ~clone~ bit clones the data inbound. The get_config_object method can
          // also clone the data outbound.
          //
          // See Members for information on setting the global configuration table.
          //@uvm-compat
          extern virtual function bit get_config_object (string field_name,
                                                         inout uvm_object value,  
                                                         input bit clone=1);
        
        
        
          // Function: apply_config_settings
          //
          // The apply_config_settings method diverges from the 1800.2
          // standard definition, using <apply_config_settings_mode> to determine
          // how the resource pool shall be queried.
          //
        
          // @uvm-ieee 1800.2-2020 auto 13.1.5.1
          extern virtual function void apply_config_settings (bit verbose = 0);
        
          // Function -- NODOCS -- use_automatic_config
          //
          // Returns 1 if the component should call <apply_config_settings> in the <build_phase>;
          // otherwise, returns 0.
          //
          // @uvm-ieee 1800.2-2020 auto 13.1.5.2
          extern virtual function bit use_automatic_config();
        
          // Function: print_config
          //
          // Print_config prints all configuration information for this
          // component, as set by previous calls to <uvm_config_db::set()> and exports to
          // the resources pool.  The settings are printed in the order of
          // their precedence.
          //
          // If ~recurse~ is set, then configuration information for all
          // children and below are printed as well.
          //
          // if ~audit~ is set then the audit trail for each resource is printed
          // along with the resource name and value
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
          extern function void print_config(bit recurse = 0, bit audit = 0);
        
          //@uvm-compat provided for compatibility with 1.1d
          extern function void print_config_settings(string field="",
                                                     uvm_component comp=null,
                                                     bit recurse=0);
        
        
          // Function -- NODOCS -- print_config_with_audit
          //
          // Operates the same as print_config except that the audit bit is
          // forced to 1.  This interface makes user code a bit more readable as
          // it avoids multiple arbitrary bit settings in the argument list.
          //
          // If ~recurse~ is set, then configuration information for all
          // children and below are printed as well.
        
          extern function void print_config_with_audit(bit recurse = 0);
        
          //@uvm-compat for compatibility with 1800.2-2017
          static bit print_config_matches;
        
          // Function: get_print_config_matches
          //
          //  static function bit get_print_config_matches() 
          // 
          // Returns the value of the internal static variable print_config_matches
          // which is the value of the verbose argument for apply_config_settings() 
          // if it is called in build_phase().  The variable has a default value of
          // 0 which may be overwritten by set_print_config_matches()
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
 000030   static function bit get_print_config_matches() ;
 000030      return print_config_matches;
          endfunction
        
          // Function: set_print_config_matches
          //
          // static function void set_print_config_matches(bit val)
          //
          // Sets the value of the internal static variable print_config_matches to val
          // (see get_print_config_matches)
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
%000000    static function void set_print_config_matches(bit val) ;
%000000      print_config_matches = val;
          endfunction
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Objection Interface
          //----------------------------------------------------------------------------
          //
          // These methods provide object level hooks into the <uvm_objection> 
          // mechanism.
          // 
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- raised
          //
          // The ~raised~ callback is called when this or a descendant of this component
          // instance raises the specified ~objection~. The ~source_obj~ is the object
          // that originally raised the objection. 
          // The ~description~ is optionally provided by the ~source_obj~ to give a
          // reason for raising the objection. The ~count~ indicates the number of
          // objections raised by the ~source_obj~.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.6.1
 000087   virtual function void raised (uvm_objection objection, uvm_object source_obj, 
              string description, int count);
          endfunction
        
        
          // Function -- NODOCS -- dropped
          //
          // The ~dropped~ callback is called when this or a descendant of this component
          // instance drops the specified ~objection~. The ~source_obj~ is the object
          // that originally dropped the objection. 
          // The ~description~ is optionally provided by the ~source_obj~ to give a
          // reason for dropping the objection. The ~count~ indicates the number of
          // objections dropped by the ~source_obj~.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.6.2
 000087   virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
              string description, int count);
          endfunction
        
        
          // Task -- NODOCS -- all_dropped
          //
          // The ~all_droppped~ callback is called when all objections have been 
          // dropped by this component and all its descendants.  The ~source_obj~ is the
          // object that dropped the last objection.
          // The ~description~ is optionally provided by the ~source_obj~ to give a
          // reason for raising the objection. The ~count~ indicates the number of
          // objections dropped by the ~source_obj~.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.6.3
%000009   virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
              string description, int count);
          endtask
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Factory Interface
          //----------------------------------------------------------------------------
          //
          // The factory interface provides convenient access to a portion of UVM's
          // <uvm_factory> interface. For creating new objects and components, the
          // preferred method of accessing the factory is via the object or component
          // wrapper (see <uvm_component_registry #(T,Tname)> and
          // <uvm_object_registry #(T,Tname)>). The wrapper also provides functions
          // for setting type and instance overrides.
          //
          //----------------------------------------------------------------------------
        
          // Function -- NODOCS -- create_component
          //
          // A convenience function for <uvm_factory::create_component_by_name>,
          // this method calls upon the factory to create a new child component
          // whose type corresponds to the preregistered type name, ~requested_type_name~,
          // and instance name, ~name~. This method is equivalent to:
          //
          //|  factory.create_component_by_name(requested_type_name,
          //|                                   get_full_name(), name, this);
          //
          // If the factory determines that a type or instance override exists, the type
          // of the component created may be different than the requested type. See
          // <set_type_override> and <set_inst_override>. See also <uvm_factory> for
          // details on factory operation.
        
          extern function uvm_component create_component (string requested_type_name, 
                                                          string name);
        
        
          // Function -- NODOCS -- create_object
          //
          // A convenience function for <uvm_factory::create_object_by_name>,
          // this method calls upon the factory to create a new object
          // whose type corresponds to the preregistered type name,
          // ~requested_type_name~, and instance name, ~name~. This method is
          // equivalent to:
          //
          //|  factory.create_object_by_name(requested_type_name,
          //|                                get_full_name(), name);
          //
          // If the factory determines that a type or instance override exists, the
          // type of the object created may be different than the requested type.  See
          // <uvm_factory> for details on factory operation.
        
          extern function uvm_object create_object (string requested_type_name,
                                                    string name="");
        
        
          // Function -- NODOCS -- set_type_override_by_type
          //
          // A convenience function for <uvm_factory::set_type_override_by_type>, this
          // method registers a factory override for components and objects created at
          // this level of hierarchy or below. This method is equivalent to:
          //
          //|  factory.set_type_override_by_type(original_type, override_type,replace);
          //
          // The ~relative_inst_path~ is relative to this component and may include
          // wildcards. The ~original_type~ represents the type that is being overridden.
          // In subsequent calls to <uvm_factory::create_object_by_type> or
          // <uvm_factory::create_component_by_type>, if the requested_type matches the
          // ~original_type~ and the instance paths match, the factory will produce
          // the ~override_type~. 
          //
          // The original and override type arguments are lightweight proxies to the
          // types they represent. See <set_inst_override_by_type> for information
          // on usage.
        
          extern static function void set_type_override_by_type
                                                     (uvm_object_wrapper original_type, 
                                                      uvm_object_wrapper override_type,
                                                      bit replace=1);
        
        
          // Function -- NODOCS -- set_inst_override_by_type
          //
          // A convenience function for <uvm_factory::set_inst_override_by_type>, this
          // method registers a factory override for components and objects created at
          // this level of hierarchy or below. In typical usage, this method is
          // equivalent to:
          //
          //|  factory.set_inst_override_by_type( original_type,
          //|                                     override_type,
          //|                                     {get_full_name(),".",
          //|                                      relative_inst_path});
          //
          // The ~relative_inst_path~ is relative to this component and may include
          // wildcards. The ~original_type~ represents the type that is being overridden.
          // In subsequent calls to <uvm_factory::create_object_by_type> or
          // <uvm_factory::create_component_by_type>, if the requested_type matches the
          // ~original_type~ and the instance paths match, the factory will produce the
          // ~override_type~. 
          //
          // The original and override types are lightweight proxies to the types they
          // represent. They can be obtained by calling ~type::get_type()~, if
          // implemented by ~type~, or by directly calling ~type::type_id::get()~, where 
          // ~type~ is the user type and ~type_id~ is the name of the typedef to
          // <uvm_object_registry #(T,Tname)> or <uvm_component_registry #(T,Tname)>.
          //
          // If you are employing the `uvm_*_utils macros, the typedef and the get_type
          // method will be implemented for you. For details on the utils macros
          // refer to <Utility and Field Macros for Components and Objects>.
          //
          // The following example shows `uvm_*_utils usage:
          //
          //|  class comp extends uvm_component;
          //|    `uvm_component_utils(comp)
          //|    ...
          //|  endclass
          //|
          //|  class mycomp extends uvm_component;
          //|    `uvm_component_utils(mycomp)
          //|    ...
          //|  endclass
          //|
          //|  class block extends uvm_component;
          //|    `uvm_component_utils(block)
          //|    comp c_inst;
          //|    virtual function void build_phase(uvm_phase phase);
          //|      set_inst_override_by_type("c_inst",comp::get_type(),
          //|                                         mycomp::get_type());
          //|    endfunction
          //|    ...
          //|  endclass
        
          extern function void set_inst_override_by_type(string relative_inst_path,  
                                                         uvm_object_wrapper original_type,
                                                         uvm_object_wrapper override_type);
        
        
          // Function -- NODOCS -- set_type_override
          //
          // A convenience function for <uvm_factory::set_type_override_by_name>,
          // this method configures the factory to create an object of type
          // ~override_type_name~ whenever the factory is asked to produce a type
          // represented by ~original_type_name~.  This method is equivalent to:
          //
          //|  factory.set_type_override_by_name(original_type_name,
          //|                                    override_type_name, replace);
          //
          // The ~original_type_name~ typically refers to a preregistered type in the
          // factory. It may, however, be any arbitrary string. Subsequent calls to
          // create_component or create_object with the same string and matching
          // instance path will produce the type represented by override_type_name.
          // The ~override_type_name~ must refer to a preregistered type in the factory. 
        
          extern static function void set_type_override(string original_type_name, 
                                                        string override_type_name,
                                                        bit    replace=1);
        
        
          // Function -- NODOCS -- set_inst_override
          //
          // A convenience function for <uvm_factory::set_inst_override_by_name>, this
          // method registers a factory override for components created at this level
          // of hierarchy or below. In typical usage, this method is equivalent to:
          //
          //|  factory.set_inst_override_by_name(original_type_name,
          //|                                    override_type_name,
          //|                                    {get_full_name(),".",
          //|                                     relative_inst_path}
          //|                                     );
          //
          // The ~relative_inst_path~ is relative to this component and may include
          // wildcards. The ~original_type_name~ typically refers to a preregistered type
          // in the factory. It may, however, be any arbitrary string. Subsequent calls
          // to create_component or create_object with the same string and matching
          // instance path will produce the type represented by ~override_type_name~.
          // The ~override_type_name~ must refer to a preregistered type in the factory. 
        
          extern function void set_inst_override(string relative_inst_path,  
                                                 string original_type_name,
                                                 string override_type_name);
        
        
          // Function -- NODOCS -- print_override_info
          //
          // This factory debug method performs the same lookup process as create_object
          // and create_component, but instead of creating an object, it prints
          // information about what type of object would be created given the
          // provided arguments.
        
          extern function void print_override_info(string requested_type_name,
                                                   string name="");
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Hierarchical Reporting Interface
          //----------------------------------------------------------------------------
          //
          // This interface provides versions of the set_report_* methods in the
          // <uvm_report_object> base class that are applied recursively to this
          // component and all its children.
          //
          // When a report is issued and its associated action has the LOG bit set, the
          // report will be sent to its associated FILE descriptor.
          //----------------------------------------------------------------------------
        
          // Function -- NODOCS -- set_report_id_verbosity_hier
        
          extern function void set_report_id_verbosity_hier (string id,
                                                          int verbosity);
        
          // Function -- NODOCS -- set_report_severity_id_verbosity_hier
          //
          // These methods recursively associate the specified verbosity with reports of
          // the given ~severity~, ~id~, or ~severity-id~ pair. A verbosity associated
          // with a particular severity-id pair takes precedence over a verbosity
          // associated with id, which takes precedence over a verbosity associated
          // with a severity.
          //
          // For a list of severities and their default verbosities, refer to
          // <uvm_report_handler>.
        
          extern function void set_report_severity_id_verbosity_hier(uvm_severity severity,
                                                                  string id,
                                                                  int verbosity);
        
        
          // Function -- NODOCS -- set_report_severity_action_hier
        
          extern function void set_report_severity_action_hier (uvm_severity severity,
                                                                uvm_action action);
        
        
          // Function -- NODOCS -- set_report_id_action_hier
        
          extern function void set_report_id_action_hier (string id,
                                                          uvm_action action);
        
          // Function -- NODOCS -- set_report_severity_id_action_hier
          //
          // These methods recursively associate the specified action with reports of
          // the given ~severity~, ~id~, or ~severity-id~ pair. An action associated
          // with a particular severity-id pair takes precedence over an action
          // associated with id, which takes precedence over an action associated
          // with a severity.
          //
          // For a list of severities and their default actions, refer to
          // <uvm_report_handler>.
        
          extern function void set_report_severity_id_action_hier(uvm_severity severity,
                                                                  string id,
                                                                  uvm_action action);
        
        
        
          // Function -- NODOCS -- set_report_default_file_hier
        
          extern function void set_report_default_file_hier (UVM_FILE file);
        
          // Function -- NODOCS -- set_report_severity_file_hier
        
          extern function void set_report_severity_file_hier (uvm_severity severity,
                                                              UVM_FILE file);
        
          // Function -- NODOCS -- set_report_id_file_hier
        
          extern function void set_report_id_file_hier (string id,
                                                        UVM_FILE file);
        
          // Function -- NODOCS -- set_report_severity_id_file_hier
          //
          // These methods recursively associate the specified FILE descriptor with
          // reports of the given ~severity~, ~id~, or ~severity-id~ pair. A FILE
          // associated with a particular severity-id pair takes precedence over a FILE
          // associated with id, which take precedence over an a FILE associated with a
          // severity, which takes precedence over the default FILE descriptor.
          //
          // For a list of severities and other information related to the report
          // mechanism, refer to <uvm_report_handler>.
        
          extern function void set_report_severity_id_file_hier(uvm_severity severity,
                                                                string id,
                                                                UVM_FILE file);
        
        
          // Function -- NODOCS -- set_report_verbosity_level_hier
          //
          // This method recursively sets the maximum verbosity level for reports for
          // this component and all those below it. Any report from this component
          // subtree whose verbosity exceeds this maximum will be ignored.
          // 
          // See <uvm_report_handler> for a list of predefined message verbosity levels
          // and their meaning.
        
            extern function void set_report_verbosity_level_hier (int verbosity);
         
        
          // Function -- NODOCS -- pre_abort
          //
          // This callback is executed when the message system is executing a
          // <UVM_EXIT> action. The exit action causes an immediate termination of
          // the simulation, but the pre_abort callback hook gives components an 
          // opportunity to provide additional information to the user before
          // the termination happens. For example, a test may want to executed
          // the report function of a particular component even when an error
          // condition has happened to force a premature termination you would
          // write a function like:
          //
          //| function void mycomponent::pre_abort();
          //|   report();
          //| endfunction
          //
          // The pre_abort() callback hooks are called in a bottom-up fashion.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.4.6
%000000   virtual function void pre_abort;
          endfunction
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Recording Interface
          //----------------------------------------------------------------------------
          // These methods comprise the component-based transaction recording
          // interface. The methods can be used to record the transactions that
          // this component "sees", i.e. produces or consumes.
          //
          // The API and implementation are subject to change once a vendor-independent
          // use-model is determined.
          //----------------------------------------------------------------------------
        
          // Function -- NODOCS -- accept_tr
          //
          // This function marks the acceptance of a transaction, ~tr~, by this
          // component. Specifically, it performs the following actions:
          //
          // - Calls the ~tr~'s <uvm_transaction::accept_tr> method, passing to it the
          //   ~accept_time~ argument.
          //
          // - Calls this component's <do_accept_tr> method to allow for any post-begin
          //   action in derived classes.
          //
          // - Triggers the component's internal accept_tr event. Any processes waiting
          //   on this event will resume in the next delta cycle. 
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.1
          extern function void accept_tr (uvm_transaction tr, time accept_time = 0);
        
        
          // Function -- NODOCS -- do_accept_tr
          //
          // The <accept_tr> method calls this function to accommodate any user-defined
          // post-accept action. Implementations should call super.do_accept_tr to
          // ensure correct operation.
            
          // @uvm-ieee 1800.2-2020 auto 13.1.7.2
          extern virtual protected function void do_accept_tr (uvm_transaction tr);
        
        
          // Function: begin_tr
          // Implementation of uvm_component::begin_tr as described in IEEE 1800.2-2020.
          //
          //| function uvm_tr_handle_t begin_tr(uvm_transaction tr,
          //|                                   string stream_name="main",
          //|                                   string label="",
          //|                                   string desc="",
          //|                                   time begin_time=0,
          //|                                   uvm_tr_handle_t parent_handle=0);
          // 
          // As an added feature, this implementation will attempt to get a non-0 
          // parent_handle from the parent sequence of the transaction tr if the 
          // parent_handle argument is 0 and the transaction can be cast to a 
          // uvm_sequence_item.
         
           // @uvm-ieee 1800.2-2020 auto 13.1.7.3
           extern function uvm_tr_handle_t begin_tr (uvm_transaction tr,
                                                     string stream_name="main",
                                                     string label="",
                                                     string desc="",
                                                     time begin_time=0,
                                                     uvm_tr_handle_t parent_handle=0);
        
          // Function -- NODOCS -- do_begin_tr
          //
          // The <begin_tr> and <begin_child_tr> methods call this function to
          // accommodate any user-defined post-begin action. Implementations should call
          // super.do_begin_tr to ensure correct operation.
        
          extern virtual protected 
            // @uvm-ieee 1800.2-2020 auto 13.1.7.4
            function void do_begin_tr (uvm_transaction tr,
                                       string stream_name,
                                       uvm_tr_handle_t tr_handle);
        
        
          // Function -- NODOCS -- end_tr
          //
          // This function marks the end of a transaction, ~tr~, by this component.
          // Specifically, it performs the following actions:
          //
          // - Calls ~tr~'s <uvm_transaction::end_tr> method, passing to it the
          //   ~end_time~ argument. The ~end_time~ must at least be greater than the
          //   begin time. By default, when ~end_time~ = 0, the current simulation time
          //   is used.
          //
          //   The transaction's properties are recorded to the database-transaction on
          //   which it was started, and then the transaction is ended. Only those
          //   properties handled by the transaction's do_record method (and optional
          //   `uvm_*_field macros) are recorded.
          //
          // - Calls the component's <do_end_tr> method to accommodate any post-end
          //   action in derived classes.
          //
          // - Triggers the component's internal end_tr event. Any processes waiting on
          //   this event will resume in the next delta cycle. 
          //
          // The ~free_handle~ bit indicates that this transaction is no longer needed.
          // The implementation of free_handle is vendor-specific.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.5
          extern function void end_tr (uvm_transaction tr,
                                       time end_time=0,
                                       bit free_handle=1);
        
        
          // Function -- NODOCS -- do_end_tr
          //
          // The <end_tr> method calls this function to accommodate any user-defined
          // post-end action. Implementations should call super.do_end_tr to ensure
          // correct operation.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.6
          extern virtual protected function void do_end_tr (uvm_transaction tr,
                                                            uvm_tr_handle_t tr_handle);
        
        
          // Function -- NODOCS -- record_error_tr
          //
          // This function marks an error transaction by a component. Properties of the
          // given uvm_object, ~info~, as implemented in its <uvm_object::do_record> method,
          // are recorded to the transaction database.
          //
          // An ~error_time~ of 0 indicates to use the current simulation time. The
          // ~keep_active~ bit determines if the handle should remain active. If 0,
          // then a zero-length error transaction is recorded. A handle to the
          // database-transaction is returned. 
          //
          // Interpretation of this handle, as well as the strings ~stream_name~,
          // ~label~, and ~desc~, are vendor-specific.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.7
          extern function int record_error_tr (string stream_name="main",
                                                   uvm_object info=null,
                                                   string label="error_tr",
                                                   string desc="",
                                                   time   error_time=0,
                                                   bit    keep_active=0);
        
        
          // Function -- NODOCS -- record_event_tr
          //
          // This function marks an event transaction by a component. 
          //
          // An ~event_time~ of 0 indicates to use the current simulation time. 
          //
          // A handle to the transaction is returned. The ~keep_active~ bit determines
          // if the handle may be used for other vendor-specific purposes. 
          //
          // The strings for ~stream_name~, ~label~, and ~desc~ are vendor-specific
          // identifiers for the transaction.
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.8
          extern function int record_event_tr (string stream_name="main",
                                                   uvm_object info=null,
                                                   string label="event_tr",
                                                   string desc="",
                                                   time   event_time=0,
                                                   bit    keep_active=0);
        
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.9
          extern virtual function uvm_tr_stream get_tr_stream(string name,
                                                              string stream_type_name="");
        
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.10
          extern virtual function void free_tr_stream(uvm_tr_stream stream);
        
          // Variable -- NODOCS -- print_enabled
          //
          // This bit determines if this component should automatically be printed as a
          // child of its parent object. 
          // 
          // By default, all children are printed. However, this bit allows a parent
          // component to disable the printing of specific children.
        
 000123   bit print_enabled = 1;
        
          // @uvm-ieee 1800.2-2020 auto 13.1.2.3
          extern virtual function void do_execute_op( uvm_field_op op );
        
          // Type: config_mode_t
          // Value type for storing config_mode_e values
          //
          // |  typedef bit [1:0] config_mode_t;
          //
          // @uvm-contrib
          typedef bit [1:0] config_mode_t;
        
          // Type: config_mode_e
          // Enumeration for controlling component config settings.
          //
          // CONFIG_STRICT - Strictly adhere to the LRM
          // CONFIG_HIGHEST_PRECEDENCE - Only apply resources with highest precedence for each 
          //                             field name / type handle pair
          // CONFIG_CHECK_NAMES - Only apply settings for fields names responding to UVM_CHECK_FIELDS op
          //
          // @uvm-contrib
          typedef enum config_mode_t {CONFIG_STRICT=2'b00,
                                      CONFIG_HIGHEST_PRECEDENCE=2'b01,
                                      CONFIG_CHECK_NAMES=2'b10} config_mode_e;
        
          // Variable: CONFIG_DEFAULT
          // Default configuration mode used by apply_config_settings_mode.
          //
          // @uvm-contrib
          localparam config_mode_t CONFIG_DEFAULT = `UVM_COMPONENT_CONFIG_MODE_DEFAULT;
        
          // Function: apply_config_settings_mode
          // Controls the configuration mode for <uvm_component::apply_config_settings>.
          //
          // Extensions may override this method to return a different config settings
          // mode.
          //
          // @uvm-contrib
          extern virtual function config_mode_t apply_config_settings_mode();
          
          
          // Variable -- NODOCS -- tr_database
          //
          // Specifies the <uvm_tr_database> object to use for <begin_tr>
          // and other methods in the <Recording Interface>.  
          // Default is <uvm_coreservice_t::get_default_tr_database>.
          uvm_tr_database tr_database;
          
          // @uvm-ieee 1800.2-2020 auto 13.1.7.12
          extern virtual function uvm_tr_database get_tr_database();
        
          // @uvm-ieee 1800.2-2020 auto 13.1.7.11
          extern virtual function void set_tr_database(uvm_tr_database db);
        
        
          //----------------------------------------------------------------------------
          //                     PRIVATE or PSUEDO-PRIVATE members
          //                      *** Do not call directly ***
          //         Implementation and even existence are subject to change. 
          //----------------------------------------------------------------------------
          // Most local methods are prefixed with m_, indicating they are not
          // user-level methods. SystemVerilog does not support friend classes,
          // which forces some otherwise internal methods to be exposed (i.e. not
          // be protected via 'local' keyword). These methods are also prefixed
          // with m_ to indicate they are not intended for public use.
          //
          // Internal methods will not be documented, although their implementa-
          // tions are freely available via the open-source license.
          //----------------------------------------------------------------------------
        
          protected uvm_domain m_domain;    // set_domain stores our domain handle
        
          /*protected*/ uvm_phase  m_phase_imps[uvm_phase];    // functors to override ovm_root defaults
        
          //TND review protected, provide read-only accessor.
          uvm_phase            m_current_phase;            // the most recently executed phase
          protected process    m_phase_process;
        
          /*protected*/ bit  m_build_done;
          /*protected*/ int  m_phasing_active;
        
          extern                   function void set_local(uvm_resource_base rsrc) ;
        
          /*protected*/ uvm_component m_parent;
          protected     uvm_component m_children[string];
          protected     uvm_component m_children_by_handle[uvm_component];
          extern protected virtual function bit  m_add_child(uvm_component child);
          extern local     virtual function void m_set_full_name();
        
          extern                   function void do_resolve_bindings();
          extern                   function void do_flush();
        
          extern virtual           function void flush ();
        
          extern local             function void m_extract_name(string name ,
                                                                output string leaf ,
                                                                output string remainder );
        
          // overridden to disable
          extern virtual function uvm_object create (string name=""); 
          extern virtual function uvm_object clone  ();
        
          local uvm_tr_stream m_streams[string][string];
          local uvm_recorder m_tr_h[uvm_transaction];
          extern protected function uvm_tr_handle_t m_begin_tr (uvm_transaction tr,
                                                                uvm_tr_handle_t parent_handle=0,
                                                                string stream_name="main", string label="",
                                                                string desc="", time begin_time=0);
        
          string m_name;
        
          typedef uvm_abstract_component_registry#(uvm_component, "uvm_component") type_id;
%000000   `uvm_type_name_decl("uvm_component")
        
          protected uvm_event_pool event_pool;
        
 000123   int unsigned recording_detail = UVM_NONE;
        
          // @uvm-ieee 1800.2-2020 auto 13.1.6.14
          extern virtual function bit get_recording_enabled();
          
          // Function: set_recording_enabled 
          //
          // | function void set_recording_enabled(bit enabled)
          //
          // In addition to the functionality described in IEEE 1800.2, this
          // library implements a call to set_recording_enabled in build_phase
          // when a config_db access of the form 
          // uvm_config_db #(uvm_bitstream_t)::get(this, "", "recording_detail", x)
          // or 
          // uvm_config_db #(int)::get(this, "", "recording_detail", x)
          // returns a non-zero value for x
        
          // @uvm-ieee 1800.2-2020 auto 13.1.6.13
          extern virtual function void set_recording_enabled(bit enabled);
        
          // @uvm-ieee 1800.2-2020 auto D.2.3
          extern virtual function void set_recording_enabled_hier (bit enabled);
        
          extern         function void   do_print(uvm_printer printer);
        
          // Internal methods for setting up command line messaging stuff
          extern function void m_set_cl_msg_args;
          extern function void m_set_cl_verb;
          extern function void m_set_cl_action;
          extern function void m_set_cl_sev;
          extern function void m_apply_verbosity_settings(uvm_phase phase);
        
        
          uvm_cmdline_set_verbosity m_verbosity_settings[$];
        
          // does the pre abort callback hierarchically
          extern /*local*/ function void m_do_pre_abort;
        
          // produce message for unsupported types from apply_config_settings
 000123   uvm_resource_base m_unsupported_resource_base = null;
          extern function void m_unsupported_set_local(uvm_resource_base rsrc);
        
          // Compat API
        
          //@uvm-compat for compatibility with 1.2
          extern function  uvm_tr_handle_t begin_child_tr (uvm_transaction tr,
                                                           uvm_tr_handle_t parent_handle=0,
                                                           string stream_name="main",
                                                           string label="",
                                                           string desc="",
                                                           time begin_time=0);
          
        
        endclass : uvm_component
          
        `include "base/uvm_root.svh"
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
          
          
        //------------------------------------------------------------------------------
        //
        // CLASS- uvm_component
        //
        //------------------------------------------------------------------------------
        
        
        // new
        // ---
        
 000123 function uvm_component::new (string name, uvm_component parent);
 000123   string error_str;
 000123   uvm_root top;
 000123   uvm_coreservice_t cs;
 000123   uvm_resource_pool rp;
 000123   uvm_resource_types::rsrc_q_t rq;
        
 000123   super.new(name);
        
          // If uvm_top, reset name to "" so it doesn't show in full paths then return
~000120   if (parent==null && name == "__top__") begin
%000000     set_name(""); // *** VIRTUAL
%000000     event_pool = new("event_pool");
%000000     return;
          end
        
 000123   cs = uvm_coreservice_t::get();
 000123   top = cs.get_root();  
        
          // Check that we're not in or past end_of_elaboration
 000123   begin
 000123     uvm_phase bld;
 000123     uvm_domain common;
 000123     common = uvm_domain::get_common_domain();
 000123     bld = common.find(uvm_build_phase::get());
~000120     if (bld == null) begin
              
%000000       uvm_report_fatal("COMP/INTERNAL",
%000000                        "attempt to find build phase object failed",UVM_NONE);
            end
        
~000120     if (bld.get_state() == UVM_PHASE_DONE) begin
%000000       uvm_report_fatal("ILLCRT", {"It is illegal to create a component ('",
%000000                 name,"' under '",
%000000                 (parent == null ? top.get_full_name() : parent.get_full_name()),
%000000                "') after the build phase has ended."},
%000000                        UVM_NONE);
            end
          end
        
~000120   if (name == "") begin
%000000     name.itoa(m_inst_count);
%000000     name = {"COMP_", name};
          end
        
~000120   if(parent == this) begin
%000000     `uvm_fatal("THISPARENT", "cannot set the parent of a component to itself")
          end
        
~000117   if (parent == null) begin
            
%000003     parent = top;
          end
        
        
~000120   if(uvm_report_enabled(UVM_MEDIUM+1, UVM_INFO, "NEWCOMP")) begin
            `uvm_info("NEWCOMP", {"Creating ",
%000000     (parent==top?"uvm_top":parent.get_full_name()),".",name},UVM_MEDIUM+1)
          end
        
~000120   if (parent.has_child(name) && this != parent.get_child(name)) begin
%000000     if (parent == top) begin
%000000       error_str = {"Name '",name,"' is not unique to other top-level ",
%000000       "instances. If parent is a module, build a unique name by combining the ",
%000000       "the module name and component name: $sformatf(\"\%m.\%s\",\"",name,"\")."};
%000000       `uvm_fatal("CLDEXT",error_str)
            end
%000000     else begin
              `uvm_fatal("CLDEXT",
              $sformatf("Cannot set '%s' as a child of '%s', %s",
              name, parent.get_full_name(),
%000000       "which already has a child by that name."))
            end
%000000     return;
          end
        
 000123   m_parent = parent;
        
 000123   set_name(name); // *** VIRTUAL
        
~000120   if (!m_parent.m_add_child(this)) begin
            
%000000     m_parent = null;
          end
        
        
 000123   event_pool = new("event_pool");
        
 000123   m_domain = parent.m_domain;     // by default, inherit domains from parents
          
          // Now that inst name is established, reseed (if use_uvm_seeding is set)
 000123   reseed();
        
          // Do local configuration settings
 000123   rp = cs.get_resource_pool();
 000123   rq = rp.lookup_name(.scope(get_full_name()),
 000123                       .name("recording_detail"),
 000123                       .type_handle(null),
 000123                       .rpterr(0));
~000120   if (rq.size() > 0) begin
%000000     uvm_resource_base rsrc;
%000000     bit found;
%000000     rp.sort_by_precedence(rq);
%000000     do begin
              // Apply in highest precedence order, exit on first match
%000000       rsrc = rq.pop_front();
%000000       `uvm_resource_builtin_int_read(found, rsrc, recording_detail, this);
            end
%000000     while (!found && (rq.size() > 0));
          end
              
 000123   m_rh.set_name(get_full_name());
 000123   set_report_verbosity_level(parent.get_report_verbosity_level());
        
 000123   m_set_cl_msg_args();
        
        endfunction
        
        
        // m_add_child
        // -----------
        
 000120 function bit uvm_component::m_add_child(uvm_component child);
        
~000120   if (m_children.exists(child.get_name()) &&
%000000       m_children[child.get_name()] != child) begin
            `uvm_warning("BDCLD",
            $sformatf("A child with the name '%0s' (type=%0s) already exists.",
%000000     child.get_name(), m_children[child.get_name()].get_type_name()))
%000000     return 0;
          end
        
~000120   if (m_children_by_handle.exists(child)) begin
            `uvm_warning("BDCHLD",
            $sformatf("A child with the name '%0s' %0s %0s'",
            child.get_name(),
            "already exists in parent under name '",
%000000     m_children_by_handle[child].get_name()))
%000000     return 0;
          end
        
 000120   m_children[child.get_name()] = child;
 000120   m_children_by_handle[child] = child;
 000120   return 1;
        endfunction
        
        
        
        //------------------------------------------------------------------------------
        //
        // Hierarchy Methods
        // 
        //------------------------------------------------------------------------------
        
        
        // get_children
        // ------------
        
 000123 function void uvm_component::get_children(ref uvm_component children[$]);
 000123   foreach(m_children[i]) begin 
            
 000120     children.push_back(m_children[i]);
          end
        
        endfunction
        
        
        // get_first_child
        // ---------------
        
 009327 function int uvm_component::get_first_child(ref string name);
 009327   return m_children.first(name);
        endfunction
        
        
        // get_next_child
        // --------------
        
 009096 function int uvm_component::get_next_child(ref string name);
 009096   return m_children.next(name);
        endfunction
        
        
        // get_child
        // ---------
        
 009096 function uvm_component uvm_component::get_child(string name);
%000000   if (m_children.exists(name)) begin
            
%000000     return m_children[name];
          end
        
          `uvm_warning("NOCHILD",{"Component with name '",name,
~009096        "' is not a child of component '",get_full_name(),"'"})
 009096   return null;
        endfunction
        
        
        // has_child
        // ---------
        
 000120 function int uvm_component::has_child(string name);
 000120   return m_children.exists(name);
        endfunction
        
        
        // get_num_children
        // ----------------
        
%000000 function int uvm_component::get_num_children();
%000000   return m_children.num();
        endfunction
        
        
        // get_full_name
        // -------------
        
 009227 function string uvm_component::get_full_name ();
          // Note- Implementation choice to construct full name once since the
          // full name may be used often for lookups.
%000000   if(m_name == "") begin
            
%000000     return get_name();
          end
        
%000000   else begin
            
%000000     return m_name;
          end
        
        endfunction
        
        
        // get_parent
        // ----------
        
 000030 function uvm_component uvm_component::get_parent ();
 000030   return  m_parent;
        endfunction
        
        
        // set_name
        // --------
        
 000123 function void uvm_component::set_name (string name);
~000123   if(m_name != "") begin
%000000     `uvm_error("INVSTNM", $sformatf("It is illegal to change the name of a component. The component name will not be changed to \"%s\"", name))
%000000     return;
          end
 000123   super.set_name(name);
 000123   m_set_full_name();
        
        endfunction
        
        
        // m_set_full_name
        // ---------------
        
 000123 function void uvm_component::m_set_full_name();
 000123   uvm_root top;
~000117   if ($cast(top, m_parent) || m_parent==null) begin
            
%000006     m_name = get_name();
          end
        
 000117   else begin 
            
 000117     m_name = {m_parent.get_full_name(), ".", get_name()};
          end
        
        
~000123   foreach (m_children[c]) begin
%000000     uvm_component tmp;
%000000     tmp = m_children[c];
%000000     tmp.m_set_full_name(); 
          end
        
        endfunction
        
        
        // lookup
        // ------
        
%000000 function uvm_component uvm_component::lookup( string name );
        
%000000   string leaf , remainder;
%000000   uvm_component comp;
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   int name_length;
          
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
           
%000000   comp = this;
          
%000000   name_length = name.len();
          
%000000   for(int i = 0; i < name_length; i++) begin
%000000     if((name.substr(i, (i+1)) == "..") || (name[i] == "*") || (name[i] == "?")) begin
%000000       `uvm_warning("Lookup String Error", $sformatf("Malformed look up string: %s", name))
%000000       return null;
            end
          end    
          
%000000   m_extract_name(name, leaf, remainder);
          
%000000   if (leaf == "") begin
%000000     comp = top; // absolute lookup
%000000     m_extract_name(remainder, leaf, remainder);
          end
          
%000000   if (!comp.has_child(leaf)) begin
            `uvm_warning("Lookup Error", 
%000000     $sformatf("Cannot find child %0s",leaf))
%000000     return null;
          end
        
%000000   if( remainder != "" ) begin
            
%000000     return comp.m_children[leaf].lookup(remainder);
          end
        
        
%000000   return comp.m_children[leaf];
        
        endfunction
        
        
        // get_depth
        // ---------
        
 000021 function int unsigned uvm_component::get_depth();
~000018   if(m_name == "") begin
%000000     return 0;
          end
        
 000021   get_depth = 1;
 000372   foreach(m_name[i]) begin 
            
 000354     if(m_name[i] == ".") begin
 000018       ++get_depth;
            end
        
          end
        
        endfunction
        
        
        // m_extract_name
        // --------------
        
%000000 function void uvm_component::m_extract_name(input string name ,
%000000                                             output string leaf ,
%000000                                             output string remainder );
%000000   int i , len;
%000000   len = name.len();
          
%000000   for( i = 0; i < name.len(); i++ ) begin  
%000000     if( name[i] == "." ) begin
%000000       break;
            end
          end
        
%000000   if( i == len ) begin
%000000     leaf = name;
%000000     remainder = "";
%000000     return;
          end
        
%000000   leaf = name.substr( 0 , i - 1 );
%000000   remainder = name.substr( i + 1 , len - 1 );
        
%000000   return;
        endfunction
          
        
        // flush
        // -----
        
%000000 function void uvm_component::flush();
%000000   return;
        endfunction
        
        
        // do_flush  (flush_hier?)
        // --------
        
%000000 function void uvm_component::do_flush();
%000000   foreach( m_children[s] ) begin
            
%000000     m_children[s].do_flush();
          end
        
%000000   flush();
        endfunction
          
        
        
        //------------------------------------------------------------------------------
        //
        // Factory Methods
        // 
        //------------------------------------------------------------------------------
        
        
        // create
        // ------
        
%000000 function uvm_object  uvm_component::create (string name =""); 
          `uvm_error("ILLCRT",
%000000     "create cannot be called on a uvm_component. Use create_component instead.")
%000000   return null;
        endfunction
        
        
        // clone
        // ------
        
%000000 function uvm_object  uvm_component::clone ();
%000000   `uvm_error("ILLCLN", $sformatf("Attempting to clone '%s'.  Clone cannot be called on a uvm_component.  The clone target variable will be set to null.", get_full_name()))
%000000   return null;
        endfunction
        
        
        // print_override_info
        // -------------------
        
%000000 function void  uvm_component::print_override_info (string requested_type_name, 
                                                           string name="");
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
%000000   factory.debug_create_by_name(requested_type_name, get_full_name(), name);
        endfunction
        
        
        // create_component
        // ----------------
        
%000000 function uvm_component uvm_component::create_component (string requested_type_name,
                                                                string name);
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
%000000   return factory.create_component_by_name(requested_type_name, get_full_name(),
%000000                                           name, this);
        endfunction
        
        
        // create_object
        // -------------
        
%000000 function uvm_object uvm_component::create_object (string requested_type_name,
                                                          string name="");
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
%000000   return factory.create_object_by_name(requested_type_name,
%000000                                        get_full_name(), name);
        endfunction
        
        
        // set_type_override (static)
        // -----------------
        
%000000 function void uvm_component::set_type_override (string original_type_name,
                                                        string override_type_name,
                                                        bit    replace=1);
%000000    uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000    uvm_factory factory=cs.get_factory();
%000000    factory.set_type_override_by_name(original_type_name,override_type_name, replace);
        endfunction 
        
        
        // set_type_override_by_type (static)
        // -------------------------
        
%000000 function void uvm_component::set_type_override_by_type (uvm_object_wrapper original_type,
                                                                uvm_object_wrapper override_type,
                                                                bit    replace=1);
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
%000000    factory.set_type_override_by_type(original_type, override_type, replace);
        endfunction 
        
        
        // set_inst_override
        // -----------------
        
%000000 function void  uvm_component::set_inst_override (string relative_inst_path,  
                                                         string original_type_name,
                                                         string override_type_name);
%000000   string full_inst_path;
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
        
%000000   if (relative_inst_path == "") begin
            
%000000     full_inst_path = get_full_name();
          end
        
%000000   else begin
            
%000000     full_inst_path = {get_full_name(), ".", relative_inst_path};
          end
        
        
%000000   factory.set_inst_override_by_name(
%000000                             original_type_name,
%000000                             override_type_name,
%000000                             full_inst_path);
        endfunction 
        
        
        // set_inst_override_by_type
        // -------------------------
        
%000000 function void uvm_component::set_inst_override_by_type (string relative_inst_path,  
                                                                uvm_object_wrapper original_type,
                                                                uvm_object_wrapper override_type);
%000000   string full_inst_path;
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
%000000   uvm_factory factory=cs.get_factory();
        
%000000   if (relative_inst_path == "") begin
            
%000000     full_inst_path = get_full_name();
          end
        
%000000   else begin
            
%000000     full_inst_path = {get_full_name(), ".", relative_inst_path};
          end
        
        
%000000   factory.set_inst_override_by_type(original_type, override_type, full_inst_path);
        
        endfunction
        
        
        
        //------------------------------------------------------------------------------
        //
        // Hierarchical report configuration interface
        //
        //------------------------------------------------------------------------------
        
        // set_report_id_verbosity_hier
        // -------------------------
        
%000000 function void uvm_component::set_report_id_verbosity_hier( string id, int verbosity);
%000000   set_report_id_verbosity(id, verbosity);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_id_verbosity_hier(id, verbosity);
          end
        
        endfunction
        
        
        // set_report_severity_id_verbosity_hier
        // ----------------------------------
        
%000000 function void uvm_component::set_report_severity_id_verbosity_hier( uvm_severity severity,
                                                                         string id,
                                                                         int verbosity);
%000000   set_report_severity_id_verbosity(severity, id, verbosity);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_severity_id_verbosity_hier(severity, id, verbosity);
          end
        
        endfunction
        
        
        // set_report_severity_action_hier
        // -------------------------
        
%000000 function void uvm_component::set_report_severity_action_hier( uvm_severity severity, 
                                                                   uvm_action action);
%000000   set_report_severity_action(severity, action);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_severity_action_hier(severity, action);
          end
        
        endfunction
        
        
        // set_report_id_action_hier
        // -------------------------
        
%000000 function void uvm_component::set_report_id_action_hier( string id, uvm_action action);
%000000   set_report_id_action(id, action);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_id_action_hier(id, action);
          end
        
        endfunction
        
        
        // set_report_severity_id_action_hier
        // ----------------------------------
        
%000000 function void uvm_component::set_report_severity_id_action_hier( uvm_severity severity,
                                                                         string id,
                                                                         uvm_action action);
%000000   set_report_severity_id_action(severity, id, action);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_severity_id_action_hier(severity, id, action);
          end
        
        endfunction
        
        
        // set_report_severity_file_hier
        // -----------------------------
        
%000000 function void uvm_component::set_report_severity_file_hier( uvm_severity severity,
                                                                    UVM_FILE file);
%000000   set_report_severity_file(severity, file);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_severity_file_hier(severity, file);
          end
        
        endfunction
        
        
        // set_report_default_file_hier
        // ----------------------------
        
%000000 function void uvm_component::set_report_default_file_hier( UVM_FILE file);
%000000   set_report_default_file(file);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_default_file_hier(file);
          end
        
        endfunction
        
        
        // set_report_id_file_hier
        // -----------------------
          
%000000 function void uvm_component::set_report_id_file_hier( string id, UVM_FILE file);
%000000   set_report_id_file(id, file);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_id_file_hier(id, file);
          end
        
        endfunction
        
        
        // set_report_severity_id_file_hier
        // --------------------------------
        
%000000 function void uvm_component::set_report_severity_id_file_hier ( uvm_severity severity,
                                                                        string id,
                                                                        UVM_FILE file);
%000000   set_report_severity_id_file(severity, id, file);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_severity_id_file_hier(severity, id, file);
          end
        
        endfunction
        
        
        // set_report_verbosity_level_hier
        // -------------------------------
        
%000003 function void uvm_component::set_report_verbosity_level_hier(int verbosity);
%000003   set_report_verbosity_level(verbosity);
%000003   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_report_verbosity_level_hier(verbosity);
          end
        
        endfunction  
        
        
        
        //------------------------------------------------------------------------------
        //
        // Phase interface 
        //
        //------------------------------------------------------------------------------
        
        
        // phase methods
        //--------------
        // these are prototypes for the methods to be implemented in user components
        // build_phase() has a default implementation, the others have an empty default
        
 000123 function void uvm_component::build_phase(uvm_phase phase);
 000123   build();
        endfunction
        
        
 000108 function void uvm_component::connect_phase(uvm_phase phase);
 000108   connect();
 000108   return; 
        endfunction
        
 000123 function void uvm_component::start_of_simulation_phase(uvm_phase phase);
 000123   start_of_simulation();
 000123   return; 
        endfunction
        
 000114 function void uvm_component::end_of_elaboration_phase(uvm_phase phase);
 000114   end_of_elaboration();
 000114   return; 
        endfunction
        
 000105 task          uvm_component::run_phase(uvm_phase phase);
 000105   run();
 000105   return; 
        endtask
        
 000123 function void uvm_component::extract_phase(uvm_phase phase);
 000123   extract();
 000123   return; 
        endfunction
        
 000123 function void uvm_component::check_phase(uvm_phase phase);
 000123   check();
 000123   return; 
        endfunction
        
 000120 function void uvm_component::report_phase(uvm_phase phase);
 000120   report();
 000120   return; 
        endfunction
        
 000123 function void uvm_component::final_phase(uvm_phase phase);         return; endfunction
        
        // these runtime phase methods are only called if a set_domain() is done
        
 000123 task uvm_component::pre_reset_phase(uvm_phase phase);      return; endtask
 000123 task uvm_component::reset_phase(uvm_phase phase);          return; endtask
 000123 task uvm_component::post_reset_phase(uvm_phase phase);     return; endtask
 000123 task uvm_component::pre_configure_phase(uvm_phase phase);  return; endtask
 000123 task uvm_component::configure_phase(uvm_phase phase);      return; endtask
 000123 task uvm_component::post_configure_phase(uvm_phase phase); return; endtask
 000123 task uvm_component::pre_main_phase(uvm_phase phase);       return; endtask
 000123 task uvm_component::main_phase(uvm_phase phase);           return; endtask
 000123 task uvm_component::post_main_phase(uvm_phase phase);      return; endtask
 000123 task uvm_component::pre_shutdown_phase(uvm_phase phase);   return; endtask
 000123 task uvm_component::shutdown_phase(uvm_phase phase);       return; endtask
 000123 task uvm_component::post_shutdown_phase(uvm_phase phase);  return; endtask
        
        
        //------------------------------
        // current phase convenience API
        //------------------------------
        
        
        // phase_started
        // -------------
        // phase_started() and phase_ended() are extra callbacks called at the
        // beginning and end of each phase, respectively.  Since they are
        // called for all phases the phase is passed in as an argument so the
        // extender can decide what to do, if anything, for each phase.
        
 002403 function void uvm_component::phase_started(uvm_phase phase);
        endfunction
        
        // phase_ended
        // -----------
        
 002583 function void uvm_component::phase_ended(uvm_phase phase);
        endfunction
        
        
        // phase_ready_to_end
        // ------------------
        
 001599 function void uvm_component::phase_ready_to_end (uvm_phase phase);
        endfunction
        
        //------------------------------
        // phase / schedule / domain API
        //------------------------------
        // methods for VIP creators and integrators to use to set up schedule domains
        // - a schedule is a named, organized group of phases for a component base type
        // - a domain is a named instance of a schedule in the master phasing schedule
        
        
        // define_domain
        // -------------
        
%000000 function void uvm_component::define_domain(uvm_domain domain);
%000000   int num_children;
%000000   uvm_phase succ[];
          // An empty domain will only have no successor, or a successor
          // which it isn't a parent to.
%000000   domain.get_adjacent_successor_nodes(succ);
%000000   num_children = succ.size(); // Potential children
%000000   foreach(succ[iter]) begin
%000000     if (succ[iter].get_parent() != domain) begin
              
%000000       num_children--;
            end
            // Successor, but not a child
          end
%000000   if (num_children == 0) begin
%000000     uvm_phase schedule;
%000000     schedule = domain.find_by_name("uvm_sched");
%000000     if (schedule == null) begin
%000000       uvm_domain common;
%000000       schedule = new("uvm_sched", UVM_PHASE_SCHEDULE);
%000000       uvm_domain::add_uvm_phases(schedule);
%000000       domain.add(schedule);
%000000       common = uvm_domain::get_common_domain();
%000000       if (common.find(domain,0) == null) begin
              
%000000         common.add(domain,.with_phase(uvm_run_phase::get()));
              end
        
            end
          end 
        
        endfunction
        
        
        // set_domain
        // ----------
        // assigns this component [tree] to a domain. adds required schedules into graph
        // If called from build, ~hier~ won't recurse into all chilren (which don't exist yet)
        // If we have components inherit their parent's domain by default, then ~hier~
        // isn't needed and we need a way to prevent children from inheriting this component's domain
        
%000000 function void uvm_component::set_domain(uvm_domain domain, int hier=1);
        
          // build and store the custom domain
%000000   m_domain = domain;
%000000   define_domain(domain);
%000000   if (hier) begin
            
%000000     foreach (m_children[c]) begin
              
%000000       m_children[c].set_domain(domain);
            end
        
          end
        
        endfunction
        
        // get_domain
        // ----------
        //
 009231 function uvm_domain uvm_component::get_domain();
 009231   return m_domain;
        endfunction
        
        // set_phase_imp
        // -------------
%000000 function void uvm_component::set_phase_imp(uvm_phase phase, uvm_phase imp, int hier=1);
%000000   m_phase_imps[phase] = imp;
%000000   if (hier) begin
            
%000000     foreach (m_children[c]) begin
              
%000000       m_children[c].set_phase_imp(phase,imp,hier);
            end
        
          end
        
        endfunction
        
        //--------------------------
        // phase runtime control API
        //--------------------------
        
        // suspend
        // -------
        
%000000 task uvm_component::suspend();
%000000    `uvm_warning("COMP/SPND/UNIMP", "suspend() not implemented")
        endtask
        
        
        // resume
        // ------
        
%000000 task uvm_component::resume();
%000000    `uvm_warning("COMP/RSUM/UNIMP", "resume() not implemented")
        endtask
        
        
        // resolve_bindings
        // ----------------
        
 000042 function void uvm_component::resolve_bindings();
 000042   return;
        endfunction
        
        
        // do_resolve_bindings
        // -------------------
        
 000123 function void uvm_component::do_resolve_bindings();
 000123   foreach( m_children[s] ) begin
            
 000120     m_children[s].do_resolve_bindings();
          end
        
 000123   resolve_bindings();
        endfunction
        
        //
        // set_config_int
        //
        // Undocumented struct for storing clone bit along w/
        // object on set_config_object(...) calls
%000000 class uvm_config_object_wrapper;
           uvm_object obj;
           bit clone;
        endclass : uvm_config_object_wrapper
        
%000000 function void uvm_component::set_config_int(string inst_name,
                                                   string field_name,
                                                   uvm_bitstream_t value);
        
%000000   uvm_config_int::set(this, inst_name, field_name, value);
        endfunction
        
        //
        // set_config_string
        //
%000000 function void uvm_component::set_config_string(string inst_name,
                                                       string field_name,
                                                       string value);
        
%000000   uvm_config_string::set(this, inst_name, field_name, value);
        endfunction
        
        //
        // set_config_object
        //
%000000 function void uvm_component::set_config_object(string inst_name,
                                                       string field_name,
                                                       uvm_object value,
                                                       bit clone = 1);
%000000   uvm_object tmp;
%000000   uvm_config_object_wrapper wrapper;
        
%000000   if(value == null) begin
            `uvm_warning("NULLCFG", {"A null object was provided as a ",
            $sformatf("configuration object for set_config_object(\"%s\",\"%s\")",
%000000     inst_name, field_name), ". Verify that this is intended."})
          end
          
%000000   if(clone && (value != null)) begin
%000000     tmp = value.clone();
%000000     if(tmp == null) begin
%000000       uvm_component comp;
%000000       if ($cast(comp,value)) begin
                `uvm_error("INVCLNC", {"Clone failed during set_config_object ",
%000000         "with an object that is an uvm_component. Components cannot be cloned."})
%000000         return;
              end
%000000       else begin
                `uvm_warning("INVCLN", {"Clone failed during set_config_object, ",
                "the original reference will be used for configuration. Check that ",
%000000         "the create method for the object type is defined properly."})
              end
            end
%000000     else begin
              
%000000       value = tmp;
            end
        
          end
        
        
%000000   uvm_config_object::set(this, inst_name, field_name, value);
        
%000000   wrapper = new;
%000000   wrapper.obj = value;
%000000   wrapper.clone = clone;
%000000   uvm_config_db#(uvm_config_object_wrapper)::set(this, inst_name, field_name, wrapper);
        endfunction
        
        //
        // get_config_int
        //
%000000 function bit uvm_component::get_config_int (string field_name,
                                                    inout uvm_bitstream_t value);
        
%000000   return uvm_config_int::get(this, "", field_name, value);
        endfunction
        
        //
        // get_config_string
        //
%000000 function bit uvm_component::get_config_string(string field_name,
                                                      inout string value);
        
%000000   return uvm_config_string::get(this, "", field_name, value);
        endfunction
        
        //
        // get_config_object
        //
        //
        // Note that this does not honor the set_config_object clone bit
%000000 function bit uvm_component::get_config_object (string field_name,
                                                       inout uvm_object value,
                                                       input bit clone=1);
        
%000000   if(!uvm_config_object::get(this, "", field_name, value)) begin
%000000     return 0;
          end
        
%000000   if(clone && value != null) begin
%000000     value = value.clone();
          end
        
%000000   return 1;
        endfunction
        
        
        //------------------------------------------------------------------------------
        //
        // Recording interface
        //
        //------------------------------------------------------------------------------
        
        // accept_tr
        // ---------
        
%000000 function void uvm_component::accept_tr (uvm_transaction tr,
                                                time accept_time=0);
%000000   uvm_event#(uvm_object) e;
          
%000000   if(tr == null) begin
            
%000000     return;
          end
        
          
%000000   tr.accept_tr(accept_time);
%000000   do_accept_tr(tr);
%000000   e = event_pool.get("accept_tr");
%000000   if(e!=null) begin 
            
%000000     e.trigger();
          end
        
        endfunction
        
        // begin_tr
        // --------
        
 001250 function uvm_tr_handle_t uvm_component::begin_tr (uvm_transaction tr,
                                                          string stream_name="main",
                                                          string label="",
                                                          string desc="",
                                                          time begin_time=0,
                                                          uvm_tr_handle_t parent_handle=0);
 001250    return m_begin_tr(tr, parent_handle, stream_name, label, desc, begin_time);
        endfunction
        
        // get_tr_database
        // ---------------------
 001250    function uvm_tr_database uvm_component::get_tr_database();
~001247      if (tr_database == null) begin
%000003        uvm_coreservice_t cs = uvm_coreservice_t::get();
%000003        tr_database = cs.get_default_tr_database();
             end
 001250      return tr_database;
           endfunction : get_tr_database
        
        // set_tr_database
        // ---------------------
%000000    function void uvm_component::set_tr_database(uvm_tr_database db);
%000000       tr_database = db;
           endfunction : set_tr_database
         
           
        // get_tr_stream
        // ------------
%000000 function uvm_tr_stream uvm_component::get_tr_stream( string name,
                                                              string stream_type_name="" );
%000000    uvm_tr_database db = get_tr_database();
%000000    if (!m_streams.exists(name) || !m_streams[name].exists(stream_type_name)) begin
             
%000000      m_streams[name][stream_type_name] = db.open_stream(name, this.get_full_name(), stream_type_name);
           end
        
%000000    return m_streams[name][stream_type_name];
        endfunction : get_tr_stream
        
        // free_tr_stream
        // --------------
%000000 function void uvm_component::free_tr_stream(uvm_tr_stream stream);
           // Check the null case...
%000000    if (stream == null) begin
             
%000000      return;
           end
        
        
           // Then make sure this name/type_name combo exists
%000000    if (!m_streams.exists(stream.get_name()) ||
%000000        !m_streams[stream.get_name()].exists(stream.get_stream_type_name())) begin
             
%000000      return;
           end
        
        
           // Then make sure this name/type_name combo is THIS stream
%000000    if (m_streams[stream.get_name()][stream.get_stream_type_name()] != stream) begin
             
%000000      return;
           end
        
        
           // Then delete it from the arrays
%000000    m_streams[stream.get_name()].delete(stream.get_type_name());
%000000    if (m_streams[stream.get_name()].size() == 0) begin
             
%000000      m_streams.delete(stream.get_name());
           end
        
        
           // Finally, free the stream if necessary
%000000    if (stream.is_open() || stream.is_closed()) begin
%000000      stream.free();
           end
        endfunction : free_tr_stream
           
        // m_begin_tr
        // ----------
        
 001250 function uvm_tr_handle_t uvm_component::m_begin_tr (uvm_transaction tr,
                                                            uvm_tr_handle_t parent_handle=0,
                                                            string stream_name="main",
                                                            string label="",
                                                            string desc="",
                                                            time begin_time=0);
 001250    uvm_event#(uvm_object) e;
 001250    string    name;
 001250    string    kind;
 001250    uvm_tr_database db;
 001250    uvm_tr_handle_t handle, link_handle;
 001250    uvm_tr_stream stream;
 001250    uvm_recorder recorder, parent_recorder, link_recorder;
        
~001250    if (tr == null) begin
             
%000000      return 0;
           end
        
        
 001250    db = get_tr_database();
           
~001250    if (parent_handle != 0) begin
%000000      parent_recorder = uvm_recorder::get_recorder_from_handle(parent_handle);
%000000      if (parent_recorder == null) begin
%000000        `uvm_error("ILLHNDL","begin_tr was passed a non-0 parent handle that corresponds to a null recorder")
             end
           end
           
 001250    else begin 
 001250      uvm_sequence_item seq;
~001250      if ($cast(seq,tr)) begin
 001250        uvm_sequence_base parent_seq = seq.get_parent_sequence();
~001247        if (parent_seq != null) begin
 001247          parent_recorder = parent_seq.m_tr_recorder;
               end
             end
           end
        
 001250    link_handle = 0;
~001250    if(parent_recorder != null) begin
%000000      link_handle = tr.begin_tr(begin_time, parent_recorder.get_handle());
           end
 001250    else begin
 001250      link_handle = tr.begin_tr(begin_time);
           end
        
~001250    if (link_handle != 0) begin
             
%000000      link_recorder = uvm_recorder::get_recorder_from_handle(link_handle);
           end
        
        
           
~001250    if (tr.get_name() != "") begin
             
 001250      name = tr.get_name();
           end
        
%000000    else begin
             
%000000      name = tr.get_type_name();
           end
        
        
 001250    handle = 0;
~001250    if (get_recording_enabled()) begin
%000000      if (stream_name == "") begin
%000000        stream_name = "main";
             end
        
        
%000000      stream = get_tr_stream(stream_name, "TVM");
        
%000000      if (stream != null ) begin
%000000        kind = (parent_recorder == null) ? "Begin_No_Parent, Link" : "Begin_End, Link";
                 
%000000        recorder = stream.open_recorder(name, begin_time, kind);
        
%000000        if (recorder != null) begin
%000000          if (label != "") begin 
                      
%000000            recorder.record_string("label", label);
                 end
        
%000000          if (desc != "") begin
                      
%000000            recorder.record_string("desc", desc);
                 end
        
                 
%000000          if (parent_recorder != null) begin
%000000            tr_database.establish_link(uvm_parent_child_link::get_link(parent_recorder,
%000000                                                                           recorder));
                 end
                    
%000000          if (link_recorder != null) begin
%000000            tr_database.establish_link(uvm_related_link::get_link(recorder,
%000000                                                                      link_recorder));
                 end
%000000          m_tr_h[tr] = recorder;
               end
             end
              
%000000      handle = (recorder == null) ? 0 : recorder.get_handle();
              
           end
 001250    do_begin_tr(tr, stream_name, handle); 
           
 001250    e = event_pool.get("begin_tr");
~001250    if (e!=null) begin 
             
 001250      e.trigger(tr);
           end
        
           
 001250    return handle;
           
        endfunction
        
        
        // end_tr
        // ------
        
 001250 function void uvm_component::end_tr (uvm_transaction tr,
                                             time end_time=0,
                                             bit free_handle=1);
 001250    uvm_event#(uvm_object) e;
 001250    uvm_recorder recorder;
        
~001250    if (tr == null) begin
             
%000000      return;
           end
        
        
 001250    tr.end_tr(end_time,free_handle);
        
~001250    if (get_recording_enabled()) begin
%000000      if (m_tr_h.exists(tr)) begin
%000000        recorder = m_tr_h[tr];
             end
           end
        
 001250    do_end_tr(tr, (recorder == null) ? 0: recorder.get_handle()); // callback
        
~001250    if (recorder != null) begin
%000000      m_tr_h.delete(tr);
        
%000000      tr.record(recorder);
        
%000000      recorder.close(end_time);
        
%000000      if (free_handle) begin
               
%000000        recorder.free();
             end
              
           end
        
 001250    e = event_pool.get("end_tr");
~001250    if(e!=null) begin 
             
 001250      e.trigger();
           end
        
        
        endfunction
        
        
        // record_error_tr
        // ---------------
        
%000000 function uvm_tr_handle_t uvm_component::record_error_tr (string stream_name="main",
                                                                 uvm_object info=null,
                                                                 string label="error_tr",
                                                                 string desc="",
                                                                 time   error_time=0,
                                                                 bit    keep_active=0);
%000000    uvm_recorder recorder;
%000000    string etype;
%000000    uvm_tr_stream stream;
%000000    uvm_tr_handle_t handle;
           
%000000    if(keep_active) begin
%000000      etype = "Error, Link";
           end
        
%000000    else begin
%000000      etype = "Error";
           end
        
           
%000000    if(error_time == 0) begin
%000000      error_time = $realtime;
           end
        
        
%000000    if (stream_name == "") begin
             
%000000      stream_name = "main";
           end
        
        
%000000    stream = get_tr_stream(stream_name, "TVM");
           
%000000    handle = 0;
%000000    if (stream != null) begin
        
%000000      recorder = stream.open_recorder(label,
%000000                                     error_time,
%000000                                     etype);
        
%000000      if (recorder != null) begin
%000000        if (label != "") begin
                   
%000000          recorder.record_string("label", label);
               end
        
%000000        if (desc != "") begin
                   
%000000          recorder.record_string("desc", desc);
               end
        
%000000        if (info!=null) begin
                   
%000000          info.record(recorder);
               end
        
        
%000000        recorder.close(error_time);
        
%000000        if (keep_active == 0) begin
%000000          recorder.free();
               end
%000000        else begin
%000000          handle = recorder.get_handle();
               end
             end // if (recorder != null)
           end // if (stream != null)
           
%000000    return handle;
        endfunction
        
        
        // record_event_tr
        // ---------------
        
%000000 function uvm_tr_handle_t uvm_component::record_event_tr (string stream_name="main",
                                                                 uvm_object info=null,
                                                                 string label="event_tr",
                                                                 string desc="",
                                                                 time event_time=0,
                                                                 bit keep_active=0);
%000000    uvm_recorder recorder;
%000000    string etype;
%000000    uvm_tr_handle_t handle;
%000000    uvm_tr_stream stream;
           
%000000   if(keep_active) begin
%000000     etype = "Event, Link";
          end
        
%000000   else begin
%000000     etype = "Event";
          end
        
           
%000000    if(event_time == 0) begin
%000000      event_time = $realtime;
           end
        
           
%000000    if (stream_name == "") begin
             
%000000      stream_name = "main";
           end
        
           
%000000    stream = get_tr_stream(stream_name, "TVM");
        
%000000    handle = 0;
%000000    if (stream != null) begin
%000000      recorder = stream.open_recorder(label,
%000000                                     event_time,
%000000                                     etype);
        
%000000      if (recorder != null) begin
%000000        if (label != "") begin
                   
%000000          recorder.record_string("label", label);
               end
        
%000000        if (desc != "") begin
                   
%000000          recorder.record_string("desc", desc);
               end
        
%000000        if (info!=null) begin
                   
%000000          info.record(recorder);
               end
        
                                
%000000        recorder.close(event_time);
        
%000000        if (keep_active == 0) begin
%000000          recorder.free();
               end
%000000        else begin
%000000          handle = recorder.get_handle();
               end
             end // if (recorder != null)
           end // if (stream != null)
        
%000000    return handle;
        endfunction
        
        // do_accept_tr
        // ------------
        
%000000 function void uvm_component::do_accept_tr (uvm_transaction tr);
%000000   return;
        endfunction
        
        
        // do_begin_tr
        // -----------
        
 001250 function void uvm_component::do_begin_tr (uvm_transaction tr,
                                                  string stream_name,
                                                  uvm_tr_handle_t tr_handle);
 001250   return;
        endfunction
        
        
        // do_end_tr
        // ---------
        
 001250 function void uvm_component::do_end_tr (uvm_transaction tr,
                                                uvm_tr_handle_t tr_handle);
 001250   return;
        endfunction
        
        
        //------------------------------------------------------------------------------
        //
        // Configuration interface
        //
        //------------------------------------------------------------------------------
        
        
%000000 function string uvm_component::massage_scope(string scope);
        
          // uvm_top
%000000   if(scope == "") begin
            
%000000     return "^$";
          end
        
        
%000000   if(scope == "*") begin
            
%000000     return {get_full_name(), ".*"};
          end
        
        
          // absolute path to the top-level test
%000000   if(scope == "uvm_test_top") begin
            
%000000     return "uvm_test_top";
          end
        
        
          // absolute path to uvm_root
%000000   if(scope[0] == ".") begin
            
%000000     return {get_full_name(), scope};
          end
        
        
%000000   return {get_full_name(), ".", scope};
        
        endfunction
        
        // apply_config_settings_mode
        // ---------------
 000030 function uvm_component::config_mode_t uvm_component::apply_config_settings_mode();
 000030   return CONFIG_DEFAULT;
        endfunction : apply_config_settings_mode
        
        // use_automatic_config
        // --------------------
 000030 function bit uvm_component::use_automatic_config();
 000030   return 1;
        endfunction 
        
        // check_config_usage
        // ------------------
        
%000000 function void uvm_component::check_config_usage ( bit recurse=1 );
%000000   uvm_resource_pool rp = uvm_resource_pool::get();
%000000   uvm_queue#(uvm_resource_base) rq;
        
%000000   rq = rp.find_unused_resources();
        
%000000   if(rq.size() == 0) begin
            
%000000     return;
          end
        
        
%000000   uvm_report_info("CFGNRD"," ::: The following resources have at least one write and no reads :::",UVM_INFO);
%000000   rp.print_resources(rq, 1);
        endfunction     
           
        // apply_config_settings
        // ---------------------
        
 000030 function void uvm_component::apply_config_settings (bit verbose=0);
 000030   uvm_resource_types::rsrc_q_t all[string];
 000030   string name_order[$];
 000030   uvm_resource_pool rp = uvm_resource_pool::get();
 000030   uvm_queue#(uvm_resource_base) rq;
 000030   uvm_resource_base r;
 000030   config_mode_t mode;
 000030   mode = apply_config_settings_mode();
        
~000030   if (mode & CONFIG_CHECK_NAMES) begin
 000030     uvm_queue#(uvm_acs_name_struct) names;
 000030     uvm_field_op op;
 000030     names = new("names");
 000030     op = uvm_field_op::m_get_available_op();
 000030     op.set(UVM_CHECK_FIELDS, null, names);
 000030     this.do_execute_op(op);
 000030     op.m_recycle();
        
%000000     while (names.size()) begin
%000000       uvm_acs_name_struct s;
%000000       s = names.pop_front();
              // We could push this into the macros themselves, ie. have the
              // macro do the config_db lookup, but it's not clear that there's
              // a strong perf win there.  If a field name is reused by many
              // different types of resources (e.g. object, string, int, bitstream), then
              // only a subset are going to be valid for a single field (e.g. int
              // and bitstream).  Filtering on type is cheap though compared to
              // matching scope, and if a field is declared multiple times in a single
              // inheritance hierarchy then we could double-tap the scope match.
%000000       if (s.name != "") begin
%000000         name_order.push_back(s.name);
%000000         all[s.name] = rp.lookup_name(.scope(get_full_name()),
%000000                                      .name(s.name), 
%000000                                      .type_handle(null), 
%000000                                      .rpterr(0));
%000000         if(verbose) begin
                  
%000000           uvm_report_info("CFGAPL",$sformatf("looking up configuration for field %s (%0d resources)", s.name, all[s.name].size()),UVM_NONE);
                end
        
              end
%000000       if (s.regex != "") begin
                // Regexes are more painful, but are required for arrays/queues/etc
%000000         rq = rp.lookup_regex(.re(s.regex),
%000000                              .scope(get_full_name()));
%000000         if(verbose) begin
                  
%000000           uvm_report_info("CFGAPL",$sformatf("looking up configuration for regex field %s (%0d resources)", s.regex, rq.size()),UVM_NONE);
                end
        
        
                // The regex match (ie. resource name) is the name used, so push into
                // the appropriate all-array location.
%000000         for (int iter = 0; iter < rq.size(); iter++) begin
%000000           string r_name;
%000000           r = rq.get(iter);
%000000           r_name = r.get_name();
%000000           if (!all.exists(r_name)) begin
%000000             all[r_name] = new(r_name);
%000000             name_order.push_back(r_name);
                  end
%000000           all[r_name].push_back(r);
                end
              end
            end
          end
%000000   else begin
            // The following is VERY expensive. CONFIG_CHECK_NAMES is much better. 
%000000     rq = rp.lookup_scope(get_full_name());
%000000     while (rq.size()) begin
%000000       string name;
%000000       r = rq.pop_front();
%000000       name = r.get_name();
%000000       if (!all.exists(name)) begin
%000000         name_order.push_back(name);
%000000         all[name] = new(name);
              end
%000000       all[name].push_back(r);
            end
          end // else: !if(mode & CONFIG_CHECK_NAMES)
        
          // At this point the all-array is loaded with queues of resources by-name.
          // Next we iterate through every field and sort by precedence, because 
          // regardless of CONFIG_HIGHEST_PRECEDENCE, we still need the queues sorted.
          //
          // We can't just grab the single highest precedence per-field, because
          // duplicate field names can exist with different resource types.  While
          // this is ugly, it's perfectly legal.
          //
          // Instead, we sort by precedence, and then drop the duplicate resource types.
~000030   foreach (name_order[iter]) begin
%000000     rq = all[name_order[iter]];
            // TODO: Update this to use sort_by_precedence_q (Mantis 7354)
%000000     rp.sort_by_precedence(rq);
        
%000000     if (mode & CONFIG_HIGHEST_PRECEDENCE) begin
%000000       int unsigned precedence_by_handle[uvm_resource_base];
%000000       uvm_resource_base type_handle;
%000000       int idx;
%000000       while (idx < rq.size()) begin
%000000         r = rq.get(idx);
%000000         type_handle = r.get_type_handle();
%000000         if (type_handle == null) begin
                  // null type handles are always applied
%000000           idx++;
                end
%000000         else if (!precedence_by_handle.exists(type_handle)) begin
                  // first we enounter is highest precedence
%000000           if(verbose) begin
                    
%000000             uvm_report_info("CFGAPL",$sformatf("found high precedence (%0d) configuration to field %s", rp.get_precedence(r), r.get_name()),UVM_NONE);
                  end
        
%000000           precedence_by_handle[type_handle] = rp.get_precedence(r);
%000000           idx++;
                end
%000000         else begin
%000000           if (rp.get_precedence(r) < precedence_by_handle[type_handle]) begin
%000000             if(verbose) begin
                      
%000000               uvm_report_info("CFGAPL",$sformatf("skipping low precedence (%0d<%0d) configuration to field %s", rp.get_precedence(r), precedence_by_handle[type_handle], r.get_name()),UVM_NONE);
                    end
        
%000000             rq.delete(idx);
                  end
%000000           else begin
%000000             if(verbose) begin
                      
%000000               uvm_report_info("CFGAPL",$sformatf("found matching high precedence (%0d) configuration to field %s", rp.get_precedence(r), r.get_name()),UVM_NONE);
                    end
        
%000000             idx++;
                  end
                end // else: !if(!precedence_by_handle.exists(type_handle))
              end // while (idx < rq.size())
            end // if (mode & CONFIG_HIGHEST_PRECEDENCE)
            
            // Apply all resources for this name
%000000     for (int i=rq.size()-1; i>=0; --i) begin
%000000       r = rq.get(i);
                
%000000       if(verbose) begin
                
%000000         uvm_report_info("CFGAPL",$sformatf("applying configuration to field %s", r.get_name()),UVM_NONE);
              end
        
%000000       set_local(r);
            end
          end
        
        endfunction
        
        
        // print_config
        // ------------
        
%000000 function void uvm_component::print_config(bit recurse = 0, audit = 0);
        
%000000   uvm_resource_pool rp = uvm_resource_pool::get();
        
%000000   uvm_report_info("CFGPRT","visible resources:",UVM_INFO);
%000000   rp.print_resources(rp.lookup_scope(get_full_name()), audit);
        
%000000   if(recurse) begin
%000000     uvm_component c;
%000000     foreach(m_children[name]) begin
%000000       c = m_children[name];
%000000       c.print_config(recurse, audit);
            end
          end
        
        endfunction
        
        // print_config_with_audit
        // -----------------------
        
%000000 function void uvm_component::print_config_with_audit(bit recurse = 0);
%000000   print_config(recurse, 1);
        endfunction
        
 002500 function bit uvm_component::get_recording_enabled();
 002500    return (uvm_verbosity'(recording_detail) != UVM_NONE);
        endfunction
        
%000000 function void uvm_component::print_config_settings (string field="",
                                                            uvm_component comp=null,
                                                            bit recurse=0);
%000000   print_config(recurse, 1);
        endfunction
        
%000000 function void uvm_component::set_recording_enabled(bit enabled);
%000000    if (get_recording_enabled() != enabled) begin
%000000      recording_detail = enabled ? UVM_LOW : UVM_NONE;
           end
           // else don't change another recording_detail value that maps to enabled
        endfunction
        
%000000 function void uvm_component::set_recording_enabled_hier(bit enabled);
%000000   set_recording_enabled(enabled);
%000000   foreach( m_children[c] ) begin
            
%000000     m_children[c].set_recording_enabled_hier(enabled);
          end
        
        endfunction
        
        
        // do_print (override)
        // --------
        
 000090 function void uvm_component::do_print(uvm_printer printer);
 000090   super.do_print(printer);
        
          // It is printed only if its value is other than the default (UVM_NONE)
~000090   if(uvm_verbosity'(recording_detail) != UVM_NONE) begin
            
%000000     case (recording_detail)
%000000       UVM_LOW : begin
%000000         printer.print_generic("recording_detail", "uvm_verbosity", 
%000000         $bits(recording_detail), "UVM_LOW");
              end
        
%000000       UVM_MEDIUM : begin
%000000         printer.print_generic("recording_detail", "uvm_verbosity", 
%000000         $bits(recording_detail), "UVM_MEDIUM");
              end
        
%000000       UVM_HIGH : begin
%000000         printer.print_generic("recording_detail", "uvm_verbosity", 
%000000         $bits(recording_detail), "UVM_HIGH");
              end
        
%000000       UVM_FULL : begin
%000000         printer.print_generic("recording_detail", "uvm_verbosity", 
%000000         $bits(recording_detail), "UVM_FULL");
              end
        
%000000       default : begin
%000000         printer.print_field_int("recording_detail", recording_detail, 
%000000         $bits(recording_detail), UVM_DEC, , "integral");
              end
        
            endcase
          end
        
        
        endfunction
        
 000120 function void uvm_component::do_execute_op( uvm_field_op op );
 000090     if (op.get_op_type == UVM_PRINT) begin
              // Handle children of the comp
 000090       uvm_component child_comp;
 000090       string name;
 000090       uvm_printer printer;
%000000       if (!$cast(printer,op.get_policy())) begin
%000000         `uvm_error("INVPRINTOP","do_execute_op() called with a field_op that has op_type UVM_PRINT but a policy that does not derive from uvm_printer")
              end
 000054       else if (get_first_child(name)) begin
                
 000093         do begin
 000093           child_comp = get_child(name);
~000087           if(child_comp.print_enabled) begin
                    
 000087             printer.print_object(name,child_comp);
                  end
        
 000093         end while (get_next_child(name));
              end
        
            end
 000120     super.do_execute_op(op);  
        endfunction
        
        // set_local (override)
        // ---------
        
%000000 function void uvm_component::set_local(uvm_resource_base rsrc) ;
        
%000000   bit success;
        
          //set the local properties
%000000   if((rsrc != null) && (rsrc.get_name() == "recording_detail")) begin
            `uvm_resource_builtin_int_read(success,
            rsrc,
            recording_detail,
%000000     this)
          end
        
%000000   if (!success) begin
            
%000000     super.set_local(rsrc);
          end
        
          
        endfunction
        
        
        // m_unsupported_set_local (override)
        // ----------------------
        
%000000 function void uvm_component::m_unsupported_set_local(uvm_resource_base rsrc);
        
%000000   m_unsupported_resource_base = rsrc;
        endfunction
        
        
        // Internal methods for setting messagin parameters from command line switches
        
        typedef class uvm_cmdline_processor;
        
        
        // m_set_cl_msg_args
        // -----------------
        
 000123 function void uvm_component::m_set_cl_msg_args;
 000123   string s_;
 000123   process p_;
            
 000123   p_=process::self();
~000123   if(p_!=null) begin 
            
 000123     s_=p_.get_randstate();
          end
%000000   else begin
            
%000000     `uvm_warning("UVM","run_test() invoked from a non process context")
          end
        
 000123   m_set_cl_verb();
 000123   m_set_cl_action();
 000123   m_set_cl_sev();
          
~000123   if(p_!=null) begin 
              
 000123     p_.set_randstate(s_);
          end
        
        endfunction
        
        
        // m_set_cl_verb
        // -------------
 000123 function void uvm_component::m_set_cl_verb;
          // _ALL_ can be used for ids
          // +uvm_set_verbosity=<comp>,<id>,<verbosity>,<phase|time>,<offset>
          // +uvm_set_verbosity=uvm_test_top.env0.agent1.*,_ALL_,UVM_FULL,time,800
         
 000123   string args[$];
            
~000123   foreach(uvm_cmdline_set_verbosity::settings[i]) begin
%000000     uvm_cmdline_set_verbosity setting;
%000000     setting = uvm_cmdline_set_verbosity::settings[i];
        
%000000     if (uvm_is_match(setting.comp, get_full_name()) ) begin
%000000       if((setting.phase == "" || setting.phase == "build" ) || 
%000000       (setting.phase == "time" && setting.offset == 0) ) begin 
                
%000000         setting.used[this] = 1;
%000000         if(setting.id == "_ALL_") begin 
                    
%000000           set_report_verbosity_level(setting.verbosity);
                end
        
%000000         else begin
                    
%000000           set_report_id_verbosity(setting.id, setting.verbosity);
                end
        
              end
%000000       else begin
%000000         setting.used[this] = 0;
%000000         if(setting.phase != "time") begin
%000000           m_verbosity_settings.push_back(setting);
                end
              end
            end
          end
        endfunction
        
        // m_set_cl_action
        // ---------------
        
 000123 function void uvm_component::m_set_cl_action;
          // _ALL_ can be used for ids or severities
          // +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>
          // +uvm_set_action=uvm_test_top.env0.*,_ALL_,UVM_ERROR,UVM_NO_ACTION
            
 000123   uvm_cmdline_set_action setting;
        
~000123   foreach(uvm_cmdline_set_action::settings[i]) begin
%000000     setting = uvm_cmdline_set_action::settings[i];
        
%000000     if (!uvm_is_match(setting.comp, get_full_name()) ) begin
%000000       continue;
            end
         
            
%000000     setting.used[this] = 1;
%000000     if(setting.id == "_ALL_") begin
%000000       if(setting.all_sev) begin
%000000         set_report_severity_action(UVM_INFO, setting.action);
%000000         set_report_severity_action(UVM_WARNING, setting.action);
%000000         set_report_severity_action(UVM_ERROR, setting.action);
%000000         set_report_severity_action(UVM_FATAL, setting.action);
              end
%000000       else begin
%000000         set_report_severity_action(setting.sev, setting.action);
              end
            end
%000000     else begin
%000000       if(setting.all_sev) begin
%000000         set_report_id_action(setting.id, setting.action);
              end
%000000       else begin
%000000         set_report_severity_id_action(setting.sev, setting.id, setting.action);
              end
            end
          end
        
        endfunction
        
        
        // m_set_cl_sev
        // ------------
        
 000123 function void uvm_component::m_set_cl_sev;
          // _ALL_ can be used for ids or severities
          //  +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>
          //  +uvm_set_severity=uvm_test_top.env0.*,BAD_CRC,UVM_ERROR,UVM_WARNING
        
 000123   uvm_cmdline_set_severity setting;
        
~000123   foreach(uvm_cmdline_set_severity::settings[i]) begin
%000000     setting = uvm_cmdline_set_severity::settings[i];
            
%000000     if (!uvm_is_match(setting.comp, get_full_name()) ) begin
%000000       continue;
            end
         
        
%000000     setting.used[this] = 1;
            
%000000     if(setting.id == "_ALL_" && setting.all_sev) begin
%000000       set_report_severity_override(UVM_INFO,setting.sev);
%000000       set_report_severity_override(UVM_WARNING,setting.sev);
%000000       set_report_severity_override(UVM_ERROR,setting.sev);
%000000       set_report_severity_override(UVM_FATAL,setting.sev);
            end
%000000     else if(setting.id == "_ALL_") begin
%000000       set_report_severity_override(setting.orig_sev,setting.sev);
            end
%000000     else if(setting.all_sev) begin
%000000       set_report_severity_id_override(UVM_INFO,setting.id,setting.sev);
%000000       set_report_severity_id_override(UVM_WARNING,setting.id,setting.sev);
%000000       set_report_severity_id_override(UVM_ERROR,setting.id,setting.sev);
%000000       set_report_severity_id_override(UVM_FATAL,setting.id,setting.sev);
            end
%000000     else begin
%000000       set_report_severity_id_override(setting.orig_sev,setting.id,setting.sev);
            end
          end
        endfunction
        
        
        // m_apply_verbosity_settings
        // --------------------------
        
 002466 function void uvm_component::m_apply_verbosity_settings(uvm_phase phase);
 002466   uvm_cmdline_set_verbosity setting;
 002466   uvm_cmdline_set_verbosity remaining_settings[$];
          
~002466   foreach (m_verbosity_settings[i]) begin
%000000     setting = m_verbosity_settings[i];
%000000     if(phase.get_name() == setting.phase) begin
%000000       setting.used[this] = 1;
%000000       if(m_verbosity_settings[i].id == "_ALL_") begin 
                
%000000         set_report_verbosity_level(m_verbosity_settings[i].verbosity);
              end
        
%000000       else begin 
                
%000000         set_report_id_verbosity(m_verbosity_settings[i].id, m_verbosity_settings[i].verbosity);
              end
        
            end // if (phase.get_name() == setting.phase)
%000000     else begin
%000000       remaining_settings.push_back(setting);
            end
          end // while (i < m_verbosity_settings.size())
 002466   m_verbosity_settings = remaining_settings;
        endfunction
        
        
        // m_do_pre_abort
        // --------------
        
%000000 function void uvm_component::m_do_pre_abort;
%000000   foreach(m_children[i]) begin
            
%000000     m_children[i].m_do_pre_abort();
          end
         
%000000   pre_abort(); 
        endfunction
        
%000000 function  uvm_tr_handle_t uvm_component::begin_child_tr (uvm_transaction tr,
                                                                 uvm_tr_handle_t parent_handle=0,
                                                                 string stream_name="main",
                                                                 string label="",
                                                                 string desc="",
                                                                 time begin_time=0);
%000000   return begin_tr(tr, stream_name, label, desc, begin_time, parent_handle);
        endfunction
        
        // contains default behavior for build_phase()
 000123 function void uvm_component::build();
 000123   m_build_done = 1;
 000093   if (use_automatic_config()) begin
            
 000030     apply_config_settings(get_print_config_matches());
          end
        
        endfunction
        
        // These are the old style phase names for backward compatibility. 
 000108 function void uvm_component::connect();             return; endfunction
 000123 function void uvm_component::start_of_simulation(); return; endfunction
 000114 function void uvm_component::end_of_elaboration();  return; endfunction
 000105 task          uvm_component::run();                 return; endtask
 000123 function void uvm_component::extract();             return; endfunction
 000123 function void uvm_component::check();               return; endfunction
 000120 function void uvm_component::report();              return; endfunction
        
        
        
        
