//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2010-2024 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2012-2018 Cisco Systems, Inc.
        // Copyright 2022 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2026 Microsoft
        // Copyright 2012-2026 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2018 Synopsys, Inc.
        // Copyright 2017-2021 Verific
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
        // $File:     src/base/uvm_root.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_root
        //
        // The ~uvm_root~ class serves as the implicit top-level and phase controller for
        // all UVM components. Users do not directly instantiate ~uvm_root~. The UVM
        // automatically creates a single instance of <uvm_root> that users can
        // access via the global (uvm_pkg-scope) variable, ~uvm_top~.
        //
        // (see uvm_ref_root.gif)
        //
        // The ~uvm_top~ instance of ~uvm_root~ plays several key roles in the UVM.
        //
        // Implicit top-level - The ~uvm_top~ serves as an implicit top-level component.
        // Any component whose parent is specified as ~null~ becomes a child of ~uvm_top~.
        // Thus, all UVM components in simulation are descendants of ~uvm_top~.
        //
        // Phase control - ~uvm_top~ manages the phasing for all components.
        //
        // Search - Use ~uvm_top~ to search for components based on their
        // hierarchical name. See <find> and <find_all>.
        //
        // Report configuration - Use ~uvm_top~ to globally configure
        // report verbosity, log files, and actions. For example,
        // ~uvm_top.set_report_verbosity_level_hier(UVM_FULL)~ would set
        // full verbosity for all components in simulation.
        //
        // Global reporter - Because ~uvm_top~ is globally accessible (in uvm_pkg
        // scope), UVM's reporting mechanism is accessible from anywhere
        // outside ~uvm_component~, such as in modules and sequences.
        // See <uvm_report_error>, <uvm_report_warning>, and other global
        // methods.
        //
        //
        // The ~uvm_top~ instance checks during the end_of_elaboration phase if any errors have
        // been generated so far. If errors are found a UVM_FATAL error is being generated as result
        // so that the simulation will not continue to the start_of_simulation_phase.
        //
        
        //------------------------------------------------------------------------------
        
        typedef class uvm_cmdline_processor;
        typedef class uvm_component_proxy;
        typedef class uvm_top_down_visitor_adapter;
        typedef class uvm_process_guard_base;
        typedef class uvm_report_message;
        typedef class uvm_report_object;
        typedef class uvm_report_handler;
        typedef class uvm_default_report_server;
        typedef class uvm_cmdline_verbosity;
        
        // Class: uvm_root
        //
        // Implementation of the uvm_root class, as defined in
        // 1800.2-2020 Section F.7 with the following additional API
        
        class uvm_root extends uvm_component;
        
            // Function -- NODOCS -- get()
            // Static accessor for <uvm_root>.
            //
            // The static accessor is provided as a convenience wrapper
            // around retrieving the root via the <uvm_coreservice_t::get_root>
            // method.
            //
            // | // Using the uvm_coreservice_t:
            // | uvm_coreservice_t cs;
            // | uvm_root r;
            // | cs = uvm_coreservice_t::get();
            // | r = cs.get_root();
            // |
            // | // Not using the uvm_coreservice_t:
            // | uvm_root r;
            // | r = uvm_root::get();
            //
        
            extern static function uvm_root get();
        
            uvm_cmdline_processor clp;
        
%000003     virtual function string get_type_name();
%000003         return "uvm_root";
            endfunction
        
        
            //----------------------------------------------------------------------------
            // Group -- NODOCS -- Simulation Control
            //----------------------------------------------------------------------------
        
        
            // Task -- NODOCS -- run_test
            //
            // Phases all components through all registered phases. If the optional
            // test_name argument is provided, or if a command-line plusarg,
            // +UVM_TESTNAME=TEST_NAME, is found, then the specified component is created
            // just prior to phasing. The test may contain new verification components or
            // the entire testbench, in which case the test and testbench can be chosen from
            // the command line without forcing recompilation. If the global (package)
            // variable, finish_on_completion, is set, then $finish is called after
            // phasing completes.
        
            extern virtual task run_test (string test_name="");
        
        
            // Function -- NODOCS -- die
            //
            // This method is called by the report server if a report reaches the maximum
            // quit count or has a UVM_EXIT action associated with it, e.g., as with
            // fatal errors.
            //
            // Calls the <uvm_component::pre_abort()> method
            // on the entire <uvm_component> hierarchy in a bottom-up fashion.
            // It then calls <uvm_report_server::report_summarize> and terminates the simulation
            // with ~$finish~.
        
%000000     virtual function void die();
%000000       uvm_test_runner runner;
%000000       runner = uvm_test_runner::get_global_runner();
%000000       runner.die();
            endfunction
        
        
            // Function -- NODOCS -- set_timeout
            //
            // Specifies the timeout for the simulation. Default is <`UVM_DEFAULT_TIMEOUT>
            //
            // The timeout is simply the maximum absolute simulation time allowed before a
            // ~FATAL~ occurs.  If the timeout is set to 20ns, then the simulation must end
            // before 20ns, or a ~FATAL~ timeout will occur.
            //
            // This is provided so that the user can prevent the simulation from potentially
            // consuming too many resources (Disk, Memory, CPU, etc) when the testbench is
            // essentially hung.
            //
            //
        
            extern function void set_timeout(time timeout, bit overridable=1);
        
            // Variable -- NODOCS -- finish_on_completion
            //
            // If set, then run_test will call $finish after all phases are executed.
          //@uvm-compat , for compatibility with 1.2
%000003   bit finish_on_completion = 1;
        
          // Function -- NODOCS -- get_finish_on_completion
        
%000003   virtual  function bit get_finish_on_completion();
%000003      return finish_on_completion;
          endfunction : get_finish_on_completion
        
          // Function -- NODOCS -- set_finish_on_completion
        
%000000   virtual  function void set_finish_on_completion(bit f);
%000000      finish_on_completion = f;
          endfunction : set_finish_on_completion
        
        //----------------------------------------------------------------------------
        // Group -- NODOCS -- Topology
        //----------------------------------------------------------------------------
        
                // Variable -- NODOCS -- top_levels
                //
                // This variable is a list of all of the top level components in UVM. It
                // includes the uvm_test_top component that is created by <run_test> as
                // well as any other top level components that have been instantiated
                // anywhere in the hierarchy.
        
                // @uvm-compat Added for compatibility with uvm-1.2
                uvm_component top_levels[$];
        
            // Function -- NODOCS -- find
        
            extern function uvm_component find (string comp_match);
        
            // Function -- NODOCS -- find_all
            //
            // Returns the component handle (find) or list of components handles
            // (find_all) matching a given string. The string may contain the wildcards,
            // * and ?. Strings beginning with '.' are absolute path names. If the optional
            // argument comp is provided, then search begins from that component down
            // (default=all components).
        
            extern function void find_all (string comp_match,
                ref uvm_component comps[$],
                input uvm_component comp=null);
        
        
            // Function -- NODOCS -- print_topology
            //
            // Print the verification environment's component topology. The
            // ~printer~ is a <uvm_printer> object that controls the format
            // of the topology printout; a ~null~ printer prints with the
            // default output.
        
            extern function void print_topology  (uvm_printer printer=null);
        
        
            // Variable -- NODOCS -- enable_print_topology
            //
            // If set, then the entire testbench topology is printed just after completion
            // of the end_of_elaboration phase.
        
%000003     bit  enable_print_topology = 0;
        
        
            // Function: set_enable_print_topology
            //
            // Sets the variable to enable printing the entire testbench topology just after completion
            // of the end_of_elaboration phase.
                //
                // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
            extern function void set_enable_print_topology  (bit enable);
        
            // Function: get_enable_print_topology
            //
            // Gets the variable to enable printing the entire testbench topology just after completion of the end_of_elaboration phase..
                //
                // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
            extern function bit get_enable_print_topology  ();
        
        
            // Variable- phase_timeout
            //
            // Specifies the timeout for the run phase. Default is `UVM_DEFAULT_TIMEOUT
        
        
%000003     time phase_timeout = `UVM_DEFAULT_TIMEOUT;
        
        
            // PRIVATE members
            extern function void m_find_all_recurse(string comp_match,
                ref uvm_component comps[$],
                input uvm_component comp=null);
        
            extern protected function new ();
            extern protected virtual function bit m_add_child (uvm_component child);
            extern function void build_phase(uvm_phase phase);
                extern local function void m_do_cl_init();
            extern local function void m_do_verbosity_settings();
                extern /* local */ function void m_do_cmdline_checks();
            extern local function void m_do_timeout_settings();
            extern local function void m_do_factory_settings();
            extern local function void m_process_inst_override(string ovr);
            extern local function void m_process_type_override(string ovr);
            extern local function void m_do_config_settings();
            extern local function void m_do_max_quit_settings();
            extern /* local */ function void m_do_dump_args();
            extern local function void m_process_config(string cfg, bit is_int, is_bitstream);
            extern local function void m_process_default_sequence(string cfg);
                local string m_uvm_verbosity_settings[$];
                local uvm_cmdline_set_verbosity m_time_settings[$];
            extern function void m_check_verbosity();
            extern function void m_check_uvm_field_flag_size();
            extern virtual function void report_header(UVM_FILE file = 0);
            // singleton handle
            static local uvm_root m_inst;
        
            // For error checking
            extern virtual task run_phase (uvm_phase phase);
        
        
            // phase_started
            // -------------
            // At end of elab phase we need to do tlm binding resolution.
 000063     function void phase_started(uvm_phase phase);
~000060         if (phase == end_of_elaboration_ph) begin
%000003           do_resolve_bindings();
%000003           if (enable_print_topology) begin
%000000             print_topology();
                  end
        
%000003           begin
%000003             uvm_report_server srvr;
%000003             srvr = uvm_report_server::get_server();
%000003             if(srvr.get_severity_count(UVM_ERROR) > 0) begin
%000000               uvm_report_fatal("BUILDERR", "stopping due to build errors", UVM_NONE);
                    end
                  end
                end
            endfunction
        
            bit m_phase_all_done;
        
                extern static function uvm_root m_uvm_get_root();
        
        
%000003     static local bit m_relnotes_done=0;
        
%000003     function void end_of_elaboration_phase(uvm_phase phase);
%000003         uvm_component_proxy p = new("proxy");
%000003         uvm_top_down_visitor_adapter#(uvm_component) adapter = new("adapter");
%000003         uvm_coreservice_t cs = uvm_coreservice_t::get();
%000003         uvm_visitor#(uvm_component) v = cs.get_component_visitor();
%000003         adapter.accept(this, v, p);
            endfunction
        
        endclass
        
        // Note that uvm_top is provided for backwards compatibility, but to avoid
        // complications caused by static initialization it can no longer be a
        // const value.
        
        //@uvm-compat Provided for compatibility with 1.2
        /* const */ uvm_root uvm_top;
        
        
        //-----------------------------------------------------------------------------
        // IMPLEMENTATION
        //-----------------------------------------------------------------------------
        
        // get
        // ---
        
 000300 function uvm_root uvm_root::get();
 000300     uvm_coreservice_t cs = uvm_coreservice_t::get();
 000300     return cs.get_root();
        endfunction
        
        // new
        // ---
        
%000003 function uvm_root::new();
%000003   uvm_report_handler rh;
%000003   super.new("__top__", null);
        
          // For error reporting purposes, we need to construct this first.
%000003   rh = new("reporter");
%000003   set_report_handler(rh);
        
          // Checking/Setting this here makes it much harder to
          // trick uvm_init into infinite recursions
%000003   if (m_inst != null) begin
            `uvm_fatal_context("UVM/ROOT/MULTI",
            "Attempting to construct multiple roots",
%000000     m_inst)
%000000     return;
          end
%000003   m_inst = this;
%000003   clp = uvm_cmdline_processor::get_inst();
        
%000003   m_do_cl_init();
%000003   m_set_cl_msg_args();
        
        endfunction
        
        // m_uvm_get_root
        // internal function not to be used
        // get the initialized singleton instance of uvm_root
 000609 function uvm_root uvm_root::m_uvm_get_root();
~000606   if (m_inst == null) begin
%000003     uvm_root top;
%000003     top = new();
%000003     uvm_top = top; // backwards compat
        
%000003     if (top != m_inst) begin
              // Something very, very bad has happened and
              // we already fatal'd.  Throw out the garbage
              // root.
        
%000000       return null;
            end
        
        
%000003     top.m_domain = uvm_domain::get_uvm_domain();
          end // if (m_inst == null)
~000609   if (m_inst != uvm_top) begin
%000000     `uvm_fatal_context("UVM/BAD_TOP", "The uvm_top variable has been overwritten outside of uvm_root!",m_inst)
          end
 000609   return m_inst;
        endfunction
        
        
%000003 function void uvm_root::report_header(UVM_FILE file = 0);
%000003     string q[$];
%000003     uvm_report_server srvr;
%000003     uvm_cmdline_processor clp;
%000003     string args[$];
        
%000003     srvr = uvm_report_server::get_server();
%000003     clp = uvm_cmdline_processor::get_inst();
        
%000003     if (clp.get_arg_matches("+UVM_NO_RELNOTES", args)) begin
%000000       return;
            end
        
        
%000003     if (!m_relnotes_done) begin
%000003       q.push_back("\n  ***********       IMPORTANT RELEASE NOTES         ************\n");
%000003       m_relnotes_done = 1;
        
%000003       q.push_back("\n  This implementation of the UVM Library deviates from the 1800.2-2020\n");
%000003       q.push_back("  standard.  See the DEVIATIONS.md file contained in the release\n");
%000003       q.push_back("  for more details.\n");
        
            end // !m_relnotes_done
        
%000003     q.push_back("\n----------------------------------------------------------------\n");
%000003     q.push_back({uvm_revision_string(),"\n"});
%000003     q.push_back("\n");
%000003         q.push_back("All copyright owners for this kit are listed in NOTICE.txt\n");
%000003         q.push_back("All Rights Reserved Worldwide\n");
%000003     q.push_back("----------------------------------------------------------------\n");
        
%000003     if(m_relnotes_done) begin
        
%000003       q.push_back("\n      (Specify +UVM_NO_RELNOTES to turn off this notice)\n");
            end
        `ifdef UVM_REG_4STATE_DATA_TYPE
              q.push_back("\n      (UVM_REG_4STATE_DATA_TYPE is defined enabling the 4-State Register Data Type Feature.)");
              q.push_back("\n      (This feature is non-standard, see the README for details.)\n");
        `endif
        
%000003     `uvm_info("UVM/RELNOTES",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_LOW)
        endfunction
        
        
        
        // run_test
        // --------
        
%000003 task uvm_root::run_test(string test_name="");
%000003     uvm_test_runner runner;
%000003     runner = uvm_test_runner::get_global_runner();
%000003     runner.run_test(test_name);
        endtask
        
        
        // find_all
        // --------
        
%000000 function void uvm_root::find_all(string comp_match, ref uvm_component comps[$],
%000000         input uvm_component comp=null);
        
%000000     if (comp==null) begin
        
%000000       comp = this;
            end
        
%000000     m_find_all_recurse(comp_match, comps, comp);
        
        endfunction
        
        
        // find
        // ----
        
%000000 function uvm_component uvm_root::find (string comp_match);
%000000     uvm_component comp_list[$];
        
%000000     find_all(comp_match,comp_list);
        
%000000     if (comp_list.size() > 1) begin
        
%000000       uvm_report_warning("MMATCH",
%000000             $sformatf("Found %0d components matching '%s'. Returning first match, %0s.",
%000000                 comp_list.size(),comp_match,comp_list[0].get_full_name()), UVM_NONE);
            end
        
        
%000000     if (comp_list.size() == 0) begin
%000000       uvm_report_warning("CMPNFD",
%000000             {"Component matching '",comp_match,
%000000                 "' was not found in the list of uvm_components"}, UVM_NONE);
%000000       return null;
            end
        
%000000     return comp_list[0];
        endfunction
        
        
        // print_topology
        // --------------
        
%000003 function void uvm_root::print_topology(uvm_printer printer=null);
        
%000003     if (m_children.num()==0) begin
%000000       uvm_report_warning("EMTCOMP", "print_topology - No UVM components to print.", UVM_NONE);
%000000       return;
            end
        
%000003     if (printer==null) begin
        
%000003       printer = uvm_printer::get_default();
            end
        
        
%000003     `uvm_info("UVMTOP","UVM testbench topology:",UVM_NONE)
%000003    print(printer) ;
        
        endfunction
        
        
        // set_timeout
        // -----------
        
%000000 function void uvm_root::set_timeout(time timeout, bit overridable=1);
%000000     static bit m_uvm_timeout_overridable = 1;
%000000     if (m_uvm_timeout_overridable == 0) begin
%000000       uvm_report_info("NOTIMOUTOVR",
%000000             $sformatf("The global timeout setting of %0d is not overridable to %0d due to a previous setting.",
%000000                 phase_timeout, timeout), UVM_NONE);
%000000       return;
            end
%000000     m_uvm_timeout_overridable = overridable;
%000000     phase_timeout = timeout;
        endfunction
        
        
        
        // m_find_all_recurse
        // ------------------
        
%000000 function void uvm_root::m_find_all_recurse(string comp_match, ref uvm_component comps[$],
                input uvm_component comp=null);
%000000     string name;
        
%000000     if (comp.get_first_child(name)) begin
        
%000000       do begin
%000000         this.m_find_all_recurse(comp_match, comps, comp.get_child(name));
              end
%000000       while (comp.get_next_child(name));
            end
        
%000000     if (uvm_is_match(comp_match, comp.get_full_name()) &&
%000000             comp.get_name() != "") begin /* uvm_top */
        
%000000       comps.push_back(comp);
            end
        
        
        endfunction
        
        
        // m_add_child
        // -----------
        
        // Add to the top levels array
%000003 function bit uvm_root::m_add_child (uvm_component child);
%000000     if(super.m_add_child(child)) begin
%000003       if(child.get_name() == "uvm_test_top") begin
        
%000003         top_levels.push_front(child);
              end
        
%000000       else begin
        
%000000         top_levels.push_back(child);
              end
        
%000000       return 1;
            end
%000000     else begin
        
%000000       return 0;
            end
        
        endfunction
        
        
        // build_phase
        // -----
        
%000003 function void uvm_root::build_phase(uvm_phase phase);
        
%000003   super.build_phase(phase);
        
%000003   m_do_verbosity_settings();
%000003   m_do_timeout_settings();
%000003   m_do_factory_settings();
%000003   m_do_config_settings();
%000003   m_do_max_quit_settings();
        
        endfunction
        
        // m_do_cl_init
        // ---------------------
%000003 function void uvm_root::m_do_cl_init();
%000003   string values[$];
%000003   string args[$];
%000003   string message;
        
%000003   uvm_cmdline_set_verbosity::init(this);
%000003   foreach(uvm_cmdline_set_verbosity::settings[i]) begin
        
%000000     if (uvm_cmdline_set_verbosity::settings[i].phase == "time" && uvm_cmdline_set_verbosity::settings[i].offset != 0) begin
        
%000000       m_time_settings.push_back(uvm_cmdline_set_verbosity::settings[i]);
            end
        
          end
        
        
%000003   uvm_cmdline_set_action::init(this);
        
%000003   uvm_cmdline_set_severity::init(this);
        
        endfunction : m_do_cl_init
        
        
        // m_do_verbosity_settings
        // -----------------------
        
%000003 function void uvm_root::m_do_verbosity_settings();
%000003   string set_verbosity_settings[$];
%000003   string split_vals[$];
%000003   uvm_verbosity tmp_verb;
        
          // do time based command line verbosity settings
%000003   fork
%000003     begin
%000003       time last_time = 0;
%000003       if (m_time_settings.size() > 0) begin
        
%000000         m_time_settings.sort() with ( item.offset );
              end
        
%000003       foreach(m_time_settings[i]) begin
%000000         uvm_component comps[$];
%000000         #(m_time_settings[i].offset - last_time);
%000000         find_all(m_time_settings[i].comp,comps);
%000000         last_time = m_time_settings[i].offset;
%000000         if(m_time_settings[i].id == "_ALL_") begin
%000000           foreach(comps[j]) begin
%000000             m_time_settings[i].used[comps[j]] = 1;
%000000             comps[j].set_report_verbosity_level(m_time_settings[i].verbosity);
                  end
                end
%000000         else begin
%000000           foreach(comps[j]) begin
%000000             m_time_settings[i].used[comps[j]] = 1;
%000000             comps[j].set_report_id_verbosity(m_time_settings[i].id, m_time_settings[i].verbosity);
                  end
                end
              end
            end
          join_none // fork begin
        
        endfunction
        
        
        // m_do_cmdline_checks
        // ---------------------
%000003 function void uvm_root::m_do_cmdline_checks();
%000003   string dump_args[$];
        
%000003   uvm_cmdline_set_verbosity::check(this);
        
%000003   if(clp.get_arg_matches("+UVM_DUMP_REPORT_ARGS", dump_args)) begin
%000000     string msgs[$];
        
        `ifdef UVM_CMDLINE_NO_DPI
%000000     msgs.push_back("\n!!! UVM_CMDLINE_NO_DPI IS DEFINED !!!");
        `endif
        
%000000     msgs.push_back(uvm_cmdline_verbosity::dump());
%000000     msgs.push_back(uvm_cmdline_set_verbosity::dump());
%000000     msgs.push_back(uvm_cmdline_set_action::dump());
%000000     msgs.push_back(uvm_cmdline_set_severity::dump());
        
%000000     uvm_report_info("REPORTARGS",
%000000                     $sformatf("\n--- UVM Reporting Argument Summary ---\n%s\n",
%000000                               `UVM_STRING_QUEUE_STREAMING_PACK(msgs)),
%000000                     UVM_NONE);
          end
        
        endfunction // m_do_cmdline_checks
        
        // m_do_timeout_settings
        // ---------------------
        
%000003 function void uvm_root::m_do_timeout_settings();
%000003     string timeout_settings[$];
%000003     string timeout;
%000003     string split_timeout[$];
%000003     int timeout_count;
%000003     time timeout_int;
%000003     string override_spec;
%000003     timeout_count = clp.get_arg_values("+UVM_TIMEOUT=", timeout_settings);
%000000     if (timeout_count ==  0) begin
        
%000000       return;
            end
        
%000000     else begin
%000000       timeout = timeout_settings[0];
%000000       if (timeout_count > 1) begin
%000000         string timeout_list;
%000000         string sep;
%000000         for (int i = 0; i < timeout_settings.size(); i++) begin
%000000           if (i != 0) begin
        
%000000             sep = "; ";
                  end
        
%000000           timeout_list = {timeout_list, sep, timeout_settings[i]};
                end
%000000         uvm_report_warning("MULTTIMOUT",
%000000                 $sformatf("Multiple (%0d) +UVM_TIMEOUT arguments provided on the command line.  '%s' will be used.  Provided list: %s.",
%000000                     timeout_count, timeout, timeout_list), UVM_NONE);
              end
%000000       uvm_report_info("TIMOUTSET",
%000000             $sformatf("'+UVM_TIMEOUT=%s' provided on the command line is being applied.", timeout), UVM_NONE);
%000000       void'($sscanf(timeout,"%d,%s",timeout_int,override_spec));
%000000       case(override_spec)
%000000         "YES"   : begin
%000000           set_timeout(timeout_int, 1);
                end
        
%000000         "NO"    : begin
%000000           set_timeout(timeout_int, 0);
                end
        
%000000         default : begin
%000000           set_timeout(timeout_int, 1);
                end
        
                endcase
            end
        endfunction
        
        
        // m_do_factory_settings
        // ---------------------
        
%000003 function void uvm_root::m_do_factory_settings();
%000003     string args[$];
        
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_INST_OVERRIDE|uvm_set_inst_override)=/",args));
%000003     foreach(args[i]) begin
%000000       m_process_inst_override(args[i].substr(23, args[i].len()-1));
            end
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_TYPE_OVERRIDE|uvm_set_type_override)=/",args));
%000003     foreach(args[i]) begin
%000000       m_process_type_override(args[i].substr(23, args[i].len()-1));
            end
        endfunction
        
        
        // m_process_inst_override
        // -----------------------
        
%000000 function void uvm_root::m_process_inst_override(string ovr);
%000000     string split_val[$];
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000     uvm_factory factory=cs.get_factory();
        
%000000     uvm_string_split(ovr, ",", split_val);
        
%000000     if(split_val.size() != 3 ) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_inst_override=", ovr,
%000000                 ", setting must specify <requested_type>,<override_type>,<instance_path>"}, UVM_NONE);
%000000       return;
            end
        
%000000     uvm_report_info("INSTOVR", {"Applying instance override from the command line: +uvm_set_inst_override=", ovr}, UVM_NONE);
%000000     factory.set_inst_override_by_name(split_val[0], split_val[1], split_val[2]);
        endfunction
        
        
        // m_process_type_override
        // -----------------------
        
%000000 function void uvm_root::m_process_type_override(string ovr);
%000000     string split_val[$];
%000000     int replace=1;
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000     uvm_factory factory=cs.get_factory();
        
%000000     uvm_string_split(ovr, ",", split_val);
        
%000000     if(split_val.size() > 3 || split_val.size() < 2) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_type_override=", ovr,
%000000                 ", setting must specify <requested_type>,<override_type>[,<replace>]"}, UVM_NONE);
%000000       return;
            end
        
            // Replace arg is optional. If set, must be 0 or 1
%000000     if(split_val.size() == 3) begin
%000000       if(split_val[2]=="0") begin
%000000         replace =  0;
              end
        
%000000       else if (split_val[2] == "1") begin
%000000         replace = 1;
              end
        
%000000       else begin
%000000         uvm_report_error("UVM_CMDLINE_PROC", {"Invalid replace arg for +uvm_set_type_override=", ovr ," value must be 0 or 1"}, UVM_NONE);
%000000         return;
              end
            end
        
%000000     uvm_report_info("UVM_CMDLINE_PROC", {"Applying type override from the command line: +uvm_set_type_override=", ovr}, UVM_NONE);
%000000     factory.set_type_override_by_name(split_val[0], split_val[1], replace);
        endfunction
        
        
        // m_process_config
        // ----------------
        
%000000 function void uvm_root::m_process_config(string cfg, bit is_int, is_bitstream);
%000000     uvm_bitstream_t v;
%000000     string split_val[$];
%000000     uvm_root m_uvm_top;
%000000     uvm_coreservice_t cs;
%000000     cs = uvm_coreservice_t::get();
%000000     m_uvm_top = cs.get_root();
        
        
%000000     uvm_string_split(cfg, ",", split_val);
        
%000000     if(split_val.size() == 1) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg,
%000000                 "\" missing field and value: component is \"", split_val[0], "\""}, UVM_NONE);
%000000       return;
            end
        
%000000     if(split_val.size() == 2) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg,
%000000                 "\" missing value: component is \"", split_val[0], "\"  field is \"", split_val[1], "\""}, UVM_NONE);
%000000       return;
            end
        
%000000     if(split_val.size() > 3) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC",
%000000             $sformatf("Invalid +uvm_set_config command\"%s\" : expected only 3 fields (component, field and value).", cfg), UVM_NONE);
%000000       return;
            end
        
%000000     if(is_int) begin
%000000       if(split_val[2].len() > 2) begin
%000000         string base, extval;
%000000         base = split_val[2].substr(0,1);
%000000         extval = split_val[2].substr(2,split_val[2].len()-1);
%000000         case(base)
%000000           "'b" : begin
%000000             v = extval.atobin();
                  end
        
%000000           "0b" : begin
%000000             v = extval.atobin();
                  end
        
%000000           "'o" : begin
%000000             v = extval.atooct();
                  end
        
%000000           "'d" : begin
%000000             v = extval.atoi();
                  end
        
%000000           "'h" : begin
%000000             v = extval.atohex();
                  end
        
%000000           "'x" : begin
%000000             v = extval.atohex();
                  end
        
%000000           "0x" : begin
%000000             v = extval.atohex();
                  end
        
%000000           default : begin
%000000             v = split_val[2].atoi();
                  end
        
                endcase
              end
%000000       else begin
%000000         v = split_val[2].atoi();
              end
%000000       uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_int=", cfg}, UVM_NONE);
%000000       uvm_config_int::set(m_uvm_top, split_val[0], split_val[1], v);
            end // if (is_int)
%000000         else if(is_bitstream) begin
%000000           int    success ;
%000000           success = uvm_bit_vector_utils#(uvm_bitstream_t)::from_string(split_val[2], v);
        
%000000           if (success == 1) begin
%000000             uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_bitstream=", cfg}, UVM_NONE);
%000000             uvm_config_int::set(m_uvm_top, split_val[0], split_val[1], v);
                  end
                end // if (is_bitstream)
%000000     else begin
%000000       uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_string=", cfg}, UVM_NONE);
%000000       uvm_config_string::set(m_uvm_top, split_val[0], split_val[1], split_val[2]);
            end
        
        endfunction
        
        // m_process_default_sequence
        // ----------------
        
%000000 function void uvm_root::m_process_default_sequence(string cfg);
%000000     string split_val[$];
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000     uvm_root m_uvm_top = cs.get_root();
%000000     uvm_factory f = cs.get_factory();
%000000     uvm_object_wrapper w;
        
%000000     uvm_string_split(cfg, ",", split_val);
%000000     if(split_val.size() == 1) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_default_sequence command\"", cfg,
%000000                 "\" missing phase and type: sequencer is \"", split_val[0], "\""}, UVM_NONE);
%000000       return;
            end
        
%000000     if(split_val.size() == 2) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_default_sequence command\"", cfg,
%000000                 "\" missing type: sequencer is \"", split_val[0], "\"  phase is \"", split_val[1], "\""}, UVM_NONE);
%000000       return;
            end
        
%000000     if(split_val.size() > 3) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC",
%000000             $sformatf("Invalid +uvm_set_default_sequence command\"%s\" : expected only 3 fields (sequencer, phase and type).", cfg), UVM_NONE);
%000000       return;
            end
        
%000000     w = f.find_wrapper_by_name(split_val[2]);
%000000     if (w == null) begin
%000000       uvm_report_error("UVM_CMDLINE_PROC",
%000000             $sformatf("Invalid type '%s' provided to +uvm_set_default_sequence", split_val[2]),
%000000             UVM_NONE);
%000000       return;
            end
%000000     else begin
%000000       uvm_report_info("UVM_CMDLINE_PROC", {"Setting default sequence from the command line: +uvm_set_default_sequence=", cfg}, UVM_NONE);
%000000       uvm_config_db#(uvm_object_wrapper)::set(this, {split_val[0], ".", split_val[1]}, "default_sequence", w);
            end
        
        endfunction : m_process_default_sequence
        
        
        // m_do_config_settings
        // --------------------
        
%000003 function void uvm_root::m_do_config_settings();
%000003     string args[$];
        
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_CONFIG_INT|uvm_set_config_int)=/",args));
%000003     foreach(args[i]) begin
%000000       m_process_config(args[i].substr(20, args[i].len()-1), 1, 0);
            end
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_CONFIG_BITSTREAM|uvm_set_config_bitstream)=/",args));
%000003     foreach(args[i]) begin
%000000       m_process_config(args[i].substr(26, args[i].len()-1), 0, 1);
            end
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_CONFIG_STRING|uvm_set_config_string)=/",args));
%000003     foreach(args[i]) begin
%000000       m_process_config(args[i].substr(23, args[i].len()-1), 0, 0);
            end
%000003     void'(clp.get_arg_matches("/^\\+(UVM_SET_DEFAULT_SEQUENCE|uvm_set_default_sequence)=/", args));
%000003     foreach(args[i]) begin
%000000       m_process_default_sequence(args[i].substr(26, args[i].len()-1));
            end
        endfunction
        
        
        // m_do_max_quit_settings
        // ----------------------
        
%000003 function void uvm_root::m_do_max_quit_settings();
%000003     uvm_report_server srvr;
%000003     string max_quit_settings[$];
%000003     int max_quit_count;
%000003     string max_quit;
%000003     string split_max_quit[$];
%000003     int max_quit_int;
%000003         int i;
%000003         string tmp;
%000003     srvr = uvm_report_server::get_server();
%000003     max_quit_count = clp.get_arg_values("+UVM_MAX_QUIT_COUNT=", max_quit_settings);
%000000     if (max_quit_count ==  0) begin
        
%000000       return;
            end
        
%000000     else begin
%000000       max_quit = max_quit_settings[0];
%000000       if (max_quit_count > 1) begin
%000000         string max_quit_list;
%000000         string sep;
%000000         for (int i = 0; i < max_quit_settings.size(); i++) begin
%000000           if (i != 0) begin
        
%000000             sep = "; ";
                  end
        
%000000           max_quit_list = {max_quit_list, sep, max_quit_settings[i]};
                end
%000000         uvm_report_warning("MULTMAXQUIT",
%000000                 $sformatf("Multiple (%0d) +UVM_MAX_QUIT_COUNT arguments provided on the command line.  '%s' will be used.  Provided list: %s.",
%000000                     max_quit_count, max_quit, max_quit_list), UVM_NONE);
              end
%000000       uvm_report_info("MAXQUITSET",
%000000             $sformatf("'+UVM_MAX_QUIT_COUNT=%s' provided on the command line is being applied.", max_quit), UVM_NONE);
%000000       uvm_string_split(max_quit, ",", split_max_quit);
%000000       tmp = split_max_quit[0];
%000000       i = $sscanf(tmp,"%d", max_quit_int);
%000000       case(split_max_quit[1])
%000000         "YES"   : begin
%000000           srvr.set_max_quit_count(max_quit_int, 1);
                end
        
%000000         "NO"    : begin
%000000           srvr.set_max_quit_count(max_quit_int, 0);
                end
        
%000000         default : begin
%000000           srvr.set_max_quit_count(max_quit_int, 1);
                end
        
                endcase
            end
        endfunction
        
        // m_do_dump_args
        // --------------
        
%000003 function void uvm_root::m_do_dump_args();
%000003     string dump_args[$];
%000003     string all_args[$];
%000003     string out_string;
%000003     if(clp.get_arg_matches("+UVM_DUMP_CMDLINE_ARGS", dump_args)) begin
%000000       clp.get_args(all_args);
%000000       foreach (all_args[idx]) begin
%000000         uvm_report_info("DUMPARGS", $sformatf("idx=%0d arg=[%s]",idx,all_args[idx]), UVM_NONE);
              end
            end
        endfunction
        
        
        // m_check_verbosity
        // ----------------
        
%000003 function void uvm_root::m_check_verbosity();
        
%000003   int    verbosity = UVM_MEDIUM;
        
%000003   uvm_cmdline_verbosity::init(this);
%000003   uvm_cmdline_verbosity::check(this);
        
%000003   if (uvm_cmdline_verbosity::settings.size() > 0) begin
        
%000000     verbosity = uvm_cmdline_verbosity::settings[0].verbosity;
          end
        
        
%000003   set_report_verbosity_level_hier(verbosity);
        
        endfunction
        
%000003 function void uvm_root::m_check_uvm_field_flag_size();
%000003     if ( (`UVM_FIELD_FLAG_SIZE) < UVM_FIELD_FLAG_RESERVED_BITS ) begin
%000000       uvm_report_fatal( "BAD_FIELD_FLAG_SZ",
%000000             $sformatf(
                        "Macro UVM_FIELD_FLAG_SIZE is set to %0d which is less than the required minimum of UVM_FIELD_FLAG_RESERVED_BITS (%0d).",
%000000                 `UVM_FIELD_FLAG_SIZE, UVM_FIELD_FLAG_RESERVED_BITS
                    )
                );
            end
        endfunction
        
        // It is required that the run phase start at simulation time 0
        // TBD this looks wrong - taking advantage of uvm_root not doing anything else?
        // TBD move to phase_started callback?
%000003 task uvm_root::run_phase (uvm_phase phase);
          // check that the commandline are took effect
%000003   uvm_cmdline_set_action::check(this);
%000003   uvm_cmdline_set_severity::check(this);
        
%000003   if($time > 0) begin
            `uvm_fatal("RUNPHSTIME", {"The run phase must start at time 0, current time is ",
            $sformatf("%0t", $realtime), ". No non-zero delays are allowed before ",
            "run_test(), and pre-run user defined phases may not consume ",
%000000     "simulation time before the start of the run phase."})
          end
        endtask
        
        
        // Debug accessor methods to access enable_print_topology
%000000 function void uvm_root::set_enable_print_topology  (bit enable);
%000000     enable_print_topology = enable;
        
        endfunction
        
        // Debug accessor methods to access enable_print_topology
%000000 function bit uvm_root::get_enable_print_topology();
%000000     return enable_print_topology;
        endfunction
        
