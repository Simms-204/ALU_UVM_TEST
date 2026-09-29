//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2007-2009 Cadence Design Systems, Inc.
        // Copyright 2007-2009 Mentor Graphics Corporation
        // Copyright 2025-2026 NVIDIA Corporation
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
        // $File:     src/base/uvm_test_runner.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //---------------------------------------------------------------------- 
        
        typedef class uvm_object_registry;
        typedef class uvm_shared;
        typedef class uvm_process_guard_base;
        typedef class uvm_objection;
        
        // Class: uvm_test_runner
        //
        // The UVM test runner is responsible for the execution of the UVM test.
        //
        // The UVM core service is responsible for instantiating the test runner.
        // The test runner is responsible for executing the test.
        //
        // @uvm-contrib For potential contribution to the 1800.2 standard
        class uvm_test_runner extends uvm_object;
        
%000000   `uvm_object_utils(uvm_test_runner)
        
          // Function: new
          // Creates a new uvm_test_runner instance with ~name~.
          //
          // @uvm-contrib For potential contribution to the 1800.2 standard
          extern function new(string name="uvm_test_runner");
          
          
          // Group: Singleton Accessors
          
          // Function: get_global_runner
          // Returns the global test runner.
          //
          // @uvm-contrib For potential contribution to the 1800.2 standard
          extern static function uvm_test_runner get_global_runner();
          
          // Group: Test Execution
          
          // Function: get_uvm_testname
          // Returns the name of the test that was specified, if any.
          //
          // Calling this method before <run_test> has been called will result in a fatal error.
          //
          // @uvm-contrib For potential contribution to the 1800.2 standard
          extern virtual function string get_uvm_testname();
        
          // Task: run_test
          // Executes the test.
          //
          // The following operations are performed in order:
          // a) The UVM core state is set to `UVM_CORE_PRE_RUN` via <set_core_state>.
          // b) If the command-line plusarg `+UVM_TESTNAME=<TEST_NAME>` is found, then the
          //    implementation shall call <create_component_by_name> on the current factory
          //    with ~requested_type_name~ set to the plusarg defined ~<TEST_NAME>~ and ~name~
          //    set to `uvm_test_top`.
          // c) If ~test_name~ is not an ~empty string~ ("") and no name was provided via the 
          //    command-line plusarg, then the implementation shall call <create_component_by_name>
          //    on the current factory with ~requested_type_name~ set to ~test_name~ and ~name~ set
          //    to `uvm_test_top`.
          // d) If no components other than <uvm_root> have been created at this point, either by 
          //    <run_test> or by the user, then the implementation shall generate a fatal message
          //    and <run_test> shall return immediately.
          // e) The UVM core state is set to `UVM_CORE_RUNNING` via <set_core_state>.
          // f) All components are phased through all registered phases (see <uvm_phase_hopper>).
          // g) The UVM core state is set to `UVM_CORE_POST_RUN` via <set_core_state>.
          // h) The <uvm_report_server::report_summarize> method is called on the current report server.
          // i) The UVM core state is set to `UVM_CORE_FINISHED` via <set_core_state>.
          // j) If <uvm_root::get_finish_on_completion> returns `1`, then `$finish` is called; otherwise,
          //    <run_test> shall return.
          // 
          // @uvm-contrib For potential contribution to the 1800.2 standard
          extern virtual task run_test(string test_name="");
        
          // Function: die
          //
          // This method is called by the report server if a report reaches the maximum
          // quit count or has a UVM_EXIT action associated with it, e.g., as with
          // fatal errors.
          //
          // If the UVM core state is already `UVM_CORE_PRE_ABORT` or `UVM_CORE_ABORTED`,
          // then the method shall return immediately.
          //
          // Otherwise, the following operations are performed in order:
          // a) The UVM core state is set to `UVM_CORE_PRE_ABORT` via <set_core_state>.
          // b) The <uvm_component::pre_abort> method is called on the entire <uvm_component>
          //    hierarchy in a bottom-up fashion.
          // c) The <uvm_report_server::report_summarize> method is called on the current report server.
          // d) The UVM core state is set to `UVM_CORE_ABORTED` via <set_core_state>.
          // e) The simulation is terminated with ~$finish~.
          //
          // @uvm-contrib For potential contribution to the 1800.2 standard
          extern virtual function void die();
        
          
          // Implementation Artifacts
          local uvm_shared#(string) m_test_name;
        endclass
        
        // Implementation details
        
%000003 function uvm_test_runner::new(string name="uvm_test_runner");
%000003   super.new(name);
        endfunction
        
%000003 function uvm_test_runner uvm_test_runner::get_global_runner();
%000003   uvm_coreservice_t cs;
%000003   cs = uvm_coreservice_t::get();
%000003   return cs.get_test_runner();
        endfunction
        
 000015 function string uvm_test_runner::get_uvm_testname();
~000015   if (m_test_name == null) begin
%000000     `uvm_fatal("UVM/TEST_NAME/EARLY", "get_uvm_testname called before run_test, test name is not set!")
          end
 000015   return m_test_name.value;
        endfunction
        
%000003 task uvm_test_runner::run_test(string test_name="");
%000003     uvm_coreservice_t cs;
%000003     uvm_report_server rs;
%000003     uvm_root top;
%000003     string child_name;
        
%000003     uvm_factory factory;
%000003     bit testname_plusarg;
%000003     int test_name_count;
%000003     string test_names[$];
%000003     string msg;
%000003     uvm_component uvm_test_top;
%000003     uvm_cmdline_processor clp;
        
%000003     process phase_runner_proc; // store thread forked below for final cleanup
        
            // Advance the core state to UVM_CORE_PRE_RUN
%000003     cs = uvm_coreservice_t::get();
%000003     cs.set_core_state(UVM_CORE_PRE_RUN);
        
%000003     factory=uvm_factory::get();
%000003     testname_plusarg = 0;
        
          // dump cmdline args BEFORE the args are being used
%000003     top = uvm_root::get();
%000003     top.m_do_dump_args();
        
%000003     m_test_name = new();
%000003     m_test_name.value = test_name;
        
        `ifndef UVM_NO_DPI
        
            // Retrieve the test names provided on the command line.  Command line
            // overrides the argument.
            clp = uvm_cmdline_processor::get_inst();
            test_name_count = clp.get_arg_values("+UVM_TESTNAME=", test_names);
        
            // If at least one, use first in queue.
            if (test_name_count > 0) begin
              m_test_name.value = test_names[0];
              testname_plusarg = 1;
            end
        
            // If multiple, provided the warning giving the number, which one will be
            // used and the complete list.
            if (test_name_count > 1) begin
              string test_list;
              string sep;
              for (int i = 0; i < test_names.size(); i++) begin
                if (i != 0) begin
                        
                  sep = ", ";
                end
        
                test_list = {test_list, sep, test_names[i]};
              end
              uvm_report_warning("MULTTST",
                    $sformatf("Multiple (%0d) +UVM_TESTNAME arguments provided on the command line.  '%s' will be used.  Provided list: %s.", test_name_count, m_test_name.value, test_list), UVM_NONE);
            end
        
        `else
        
%000003     `uvm_warning("NO_DPI_USED", "We are thinking of removing support for UVM_NO_DPI.  Please try this test without it and evaluate the impact")
            // plusarg overrides argument
%000003     if ($value$plusargs("UVM_TESTNAME=%s", m_test_name.value)) begin
%000003         `uvm_info("NO_DPI_TSTNAME", "UVM_NO_DPI defined--getting UVM_TESTNAME directly, without DPI", UVM_NONE)
%000003         testname_plusarg = 1;
            end
        
        `endif
        
            // if test now defined, create it using common factory
%000003     if (get_uvm_testname() != "") begin
%000003         if (top.get_first_child(child_name)) begin
%000000             do begin
%000000                 if (child_name == "uvm_test_top") begin
%000000                     uvm_report_fatal("TTINST",
%000000                     "A uvm_test_top already exists via a previous call to run_test", UVM_NONE);
%000000                     #0; // forces shutdown because $finish is forked
                        end
%000000             end while (top.get_next_child(child_name));
                end
        
%000003         $cast(uvm_test_top, factory.create_component_by_name(get_uvm_testname(),
                            "", "uvm_test_top", null));
        
%000003         if (uvm_test_top == null) begin
%000000             msg = testname_plusarg ? {"command line +UVM_TESTNAME=",get_uvm_testname()} :
                        {"call to run_test(",get_uvm_testname(),")"};
%000000             uvm_report_fatal("INVTST",
%000000                     {"Requested test from ",msg, " not found." }, UVM_NONE);
                end
            end
        
%000003     if (!top.get_first_child(child_name)) begin
%000000       uvm_report_fatal("NOCOMP",
%000000             {"No components instantiated. You must either instantiate",
%000000                 " at least one component before calling run_test or use",
%000000                 " run_test to do so. To run a test using run_test,",
%000000                 " use +UVM_TESTNAME or supply the test name in",
%000000                 " the argument to run_test(). Exiting simulation."}, UVM_NONE);
%000000       return;
            end
        
%000003     begin
%000000       if(get_uvm_testname()=="") begin
                    
%000000         uvm_report_info("RNTST", "Running test ...", UVM_LOW);
              end
        
%000003       else if (get_uvm_testname() == uvm_test_top.get_type_name()) begin
                    
%000003         uvm_report_info("RNTST", {"Running test ",get_uvm_testname(),"..."}, UVM_LOW);
              end
        
%000000       else begin
                    
%000000         uvm_report_info("RNTST", {"Running test ",uvm_test_top.get_type_name()," (via factory override for test \"",get_uvm_testname(),"\")..."}, UVM_LOW);
              end
        
            end
        
            // phase runner, isolated from calling process
            // Note: Using a fork here may not be necessary.  If the calling
            // process is disabled, then this process continues,
            // but if the calling process is killed then this
            // process is killed.  
%000003     fork 
%000003       begin
                // spawn the phase runner task
%000003         uvm_phase_hopper hopper;
%000003         hopper = uvm_phase_hopper::get_global_hopper();
%000003         cs.set_core_state(UVM_CORE_RUNNING);
%000003         hopper.run_phases();
              end
            join
        
%000003     cs.set_core_state(UVM_CORE_POST_RUN);
        
%000003     rs = uvm_report_server::get_server();
        
        
            // TODO: Mantis 8579
            // Move this method (and call) to a more appropriate place
%000003     top.m_do_cmdline_checks();
          
%000003     rs.report_summarize();
        
%000003     cs.set_core_state(UVM_CORE_FINISHED);
        
%000003     if (top.get_finish_on_completion()) begin
            
%000003         $finish;
            end
        
        
        endtask
        
%000000 function void uvm_test_runner::die();
%000000   uvm_coreservice_t cs;
%000000   uvm_root top;
%000000   uvm_report_server rs;
        
          // Only die once
%000000   if (get_core_state() inside {UVM_CORE_PRE_ABORT, UVM_CORE_ABORTED}) begin
%000000     return;
          end
        
%000000   cs = uvm_coreservice_t::get();
%000000   top = uvm_root::get();
%000000   rs = uvm_report_server::get_server();
        
%000000   cs.set_core_state(UVM_CORE_PRE_ABORT);
%000000   top.m_do_pre_abort();
%000000   rs.report_summarize();
%000000   cs.set_core_state(UVM_CORE_ABORTED);
        
%000000   $finish;
        endfunction
        
        
