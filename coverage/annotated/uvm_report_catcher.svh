//      // verilator_coverage annotation
        // $Id: uvm_report_catcher.svh,v 1.1.2.10 2010/04/09 15:03:25 janick Exp $
        //------------------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2007-2024 Cadence Design Systems, Inc.
        // Copyright 2014 Cisco Systems, Inc.
        // Copyright 2018 Intel Corporation
        // Copyright 2022 Marvell International Ltd.
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
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_report_catcher.svh $
        // $Rev:      2024-07-18 12:43:22 -0700 $
        // $Hash:     c114e948eeee0286b84392c4185deb679aac54b3 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_REPORT_CATCHER_SVH
        `define UVM_REPORT_CATCHER_SVH
        
        typedef class uvm_report_object;
        typedef class uvm_report_handler;
        typedef class uvm_report_server;
        typedef class uvm_report_catcher;
        
        typedef uvm_callbacks    #(uvm_report_object, uvm_report_catcher) uvm_report_cb;
        typedef uvm_callback_iter#(uvm_report_object, uvm_report_catcher) uvm_report_cb_iter /* @uvm-ieee 1800.2-2020 auto D.4.4*/ ;
        
%000000 class sev_id_struct;
          bit sev_specified ;
          bit id_specified ;
          uvm_severity sev ;
          string  id ;
          bit is_on ;
        endclass
        
        // TITLE: Report Catcher
        //
        // Contains debug methods in the Accellera UVM implementation not documented
        // in the IEEE 1800.2-2020 LRM
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS: uvm_report_catcher
        //
        
        // @uvm-ieee 1800.2-2020 auto 6.6.1
        virtual class uvm_report_catcher extends uvm_callback;
        
%000003   `uvm_register_cb(uvm_report_object,uvm_report_catcher)
        
          typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;
        
          local static uvm_report_message m_modified_report_message;
          local static uvm_report_message m_orig_report_message;
        
          local static bit m_set_action_called;
        
          // Counts for the demoteds and caughts
          local static int m_demoted_fatal;
          local static int m_demoted_error;
          local static int m_demoted_warning;
          local static int m_caught_fatal;
          local static int m_caught_error;
          local static int m_caught_warning;
        
          // Flag counts
          localparam   int DO_NOT_CATCH      = 1; 
          localparam   int DO_NOT_MODIFY     = 2; 
          local static int m_debug_flags;
        
          local static  bit do_report;
        
          
          // Function -- NODOCS -- new
          //
          // Create a new report catcher. The name argument is optional, but
          // should generally be provided to aid in debugging.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.2
%000000   function new(string name = "uvm_report_catcher");
%000000     super.new(name);
%000000     do_report = 1;
          endfunction    
        
          // Group -- NODOCS -- Current Message State
        
          // Function -- NODOCS -- get_client
          //
          // Returns the <uvm_report_object> that has generated the message that
          // is currently being processed.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.3.1
%000000   function uvm_report_object get_client();
%000000     return m_modified_report_message.get_report_object(); 
          endfunction
        
          // Function -- NODOCS -- get_severity
          //
          // Returns the <uvm_severity> of the message that is currently being
          // processed. If the severity was modified by a previously executed
          // catcher object (which re-threw the message), then the returned 
          // severity is the modified value.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.3.2
%000000   function uvm_severity get_severity();
%000000     return this.m_modified_report_message.get_severity();
          endfunction
          
          // Function -- NODOCS -- get_context
          //
          // Returns the context name of the message that is currently being
          // processed. This is typically the full hierarchical name of the component
          // that issued the message. However, if user-defined context is set from
          // a uvm_report_message, the user-defined context will be returned.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.3.3
%000000   function string get_context();
%000000     string context_str;
            
%000000     context_str = this.m_modified_report_message.get_context();
%000000     if (context_str == "") begin
%000000       uvm_report_handler rh = this.m_modified_report_message.get_report_handler();
%000000       context_str = rh.get_full_name();
            end
        
%000000     return context_str;
          endfunction
          
          // Function -- NODOCS -- get_verbosity
          //
          // Returns the verbosity of the message that is currently being
          // processed. If the verbosity was modified by a previously executed
          // catcher (which re-threw the message), then the returned 
          // verbosity is the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.3.4
%000000   function int get_verbosity();
%000000     return this.m_modified_report_message.get_verbosity();
          endfunction
          
          // Function -- NODOCS -- get_id
          //
          // Returns the string id of the message that is currently being
          // processed. If the id was modified by a previously executed
          // catcher (which re-threw the message), then the returned 
          // id is the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.3.5
%000000   function string get_id();
%000000     return this.m_modified_report_message.get_id();
          endfunction
          
          // Function -- NODOCS -- get_message
          //
          // Returns the string message of the message that is currently being
          // processed. If the message was modified by a previously executed
          // catcher (which re-threw the message), then the returned 
          // message is the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.3.6
%000000   function string get_message();
%000000      return this.m_modified_report_message.get_message();
          endfunction
          
          // Function -- NODOCS -- get_action
          //
          // Returns the <uvm_action> of the message that is currently being
          // processed. If the action was modified by a previously executed
          // catcher (which re-threw the message), then the returned 
          // action is the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.3.7
%000000   function uvm_action get_action();
%000000     return this.m_modified_report_message.get_action();
          endfunction
          
          // Function -- NODOCS -- get_fname
          //
          // Returns the file name of the message.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.3.8
%000000   function string get_fname();
%000000     return this.m_modified_report_message.get_filename();
          endfunction             
        
          // Function -- NODOCS -- get_line
          //
          // Returns the line number of the message.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.3.9
%000000   function int get_line();
%000000     return this.m_modified_report_message.get_line();
          endfunction
        
          // Function -- NODOCS -- get_element_container
          //
          // Returns the element container of the message.
        
%000000   function uvm_report_message_element_container get_element_container();
%000000     return this.m_modified_report_message.get_element_container();
          endfunction
        
          
          // Group -- NODOCS -- Change Message State
        
          // Function -- NODOCS -- set_severity
          //
          // Change the severity of the message to ~severity~. Any other
          // report catchers will see the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.4.1
%000000   protected function void set_severity(uvm_severity severity);
%000000     this.m_modified_report_message.set_severity(severity);
          endfunction
          
          // Function -- NODOCS -- set_verbosity
          //
          // Change the verbosity of the message to ~verbosity~. Any other
          // report catchers will see the modified value.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.4.2
%000000   protected function void set_verbosity(int verbosity);
%000000     this.m_modified_report_message.set_verbosity(verbosity);
          endfunction      
        
          // Function -- NODOCS -- set_id
          //
          // Change the id of the message to ~id~. Any other
          // report catchers will see the modified value.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.4.3
%000000   protected function void set_id(string id);
%000000     this.m_modified_report_message.set_id(id);
          endfunction
          
          // Function -- NODOCS -- set_message
          //
          // Change the text of the message to ~message~. Any other
          // report catchers will see the modified value.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.4.4
%000000   protected function void set_message(string message);
%000000     this.m_modified_report_message.set_message(message);
          endfunction
          
          // Function -- NODOCS -- set_action
          //
          // Change the action of the message to ~action~. Any other
          // report catchers will see the modified value.
          
          // @uvm-ieee 1800.2-2020 auto 6.6.4.5
%000000   protected function void set_action(uvm_action action);
%000000     this.m_modified_report_message.set_action(action);
%000000     this.m_set_action_called = 1;
          endfunction
        
          // Function -- NODOCS -- set_context
          //
          // Change the context of the message to ~context_str~. Any other
          // report catchers will see the modified value.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.4.6
%000000   protected function void set_context(string context_str);
%000000     this.m_modified_report_message.set_context(context_str);
          endfunction
        
          // Function -- NODOCS -- add_int
          //
          // Add an integral type of the name ~name~ and value ~value~ to
          // the message.  The required ~size~ field indicates the size of ~value~.
          // The required ~radix~ field determines how to display and
          // record the field. Any other report catchers will see the newly
          // added element.
          //
        
%000000   protected function void add_int(string name,
                          uvm_bitstream_t value,
                          int size,
                          uvm_radix_enum radix,
                          uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     this.m_modified_report_message.add_int(name, value, size, radix, action);
          endfunction
        
        
          // Function -- NODOCS -- add_string
          //
          // Adds a string of the name ~name~ and value ~value~ to the
          // message. Any other report catchers will see the newly
          // added element.
          //
        
%000000   protected function void add_string(string name,
                             string value,
                                             uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     this.m_modified_report_message.add_string(name, value, action);
          endfunction
        
        
          // Function -- NODOCS -- add_object
          //
          // Adds a uvm_object of the name ~name~ and reference ~obj~ to
          // the message. Any other report catchers will see the newly
          // added element.
          //
        
%000000   protected function void add_object(string name,
                             uvm_object obj,
                                             uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     this.m_modified_report_message.add_object(name, obj, action);
          endfunction
        
          // Function: print_catcher
          //
          // Prints debug information about all of the typewide report catchers that are 
          // registered.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
          
%000000   static function void print_catcher(UVM_FILE file = 0);
%000000       string msg;
%000000       string enabled;
%000000       uvm_report_catcher catcher;
%000000       static uvm_report_cb_iter iter = new(null);
%000000       string q[$];
        
%000000       q.push_back("-------------UVM REPORT CATCHERS----------------------------\n");
        
%000000       catcher = iter.first();
%000000       while(catcher != null) begin
%000000         if(catcher.callback_mode()) begin
                      
%000000           enabled = "ON";
                end
                
%000000         else begin
                      
%000000           enabled = "OFF";
                end
                
        
%000000         q.push_back($sformatf("%20s : %s\n", catcher.get_name(),enabled));
%000000         catcher = iter.next();
              end
%000000       q.push_back("--------------------------------------------------------------\n");
        
%000000       `uvm_info_context("UVM/REPORT/CATCHER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_LOW,uvm_root::get())
          endfunction
          
          // Function: debug_report_catcher
          //
          // Turn on report catching debug information. bits[1:0] of ~what~ enable debug features
          // * bit 0 - when set to 1 -- forces catch to be ignored so that all catchers see the
          //   the reports.
          // * bit 1 - when set to 1 -- forces the message to remain unchanged
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
          
%000000   static function void debug_report_catcher(int what= 0);
%000000     m_debug_flags = what;
          endfunction        
          
          // Group -- NODOCS -- Callback Interface
         
          // Function -- NODOCS -- catch
          //
          // This is the method that is called for each registered report catcher.
          // There are no arguments to this function. The <Current Message State>
          // interface methods can be used to access information about the 
          // current message being processed.
        
          // @uvm-ieee 1800.2-2020 auto 6.6.5
%000000   pure virtual function action_e catch();
             
        
          // Group -- NODOCS -- Reporting
        
           // Function -- NODOCS -- uvm_report_fatal
           //
           // Issues a fatal message using the current message's report object.
           // This message will bypass any message catching callbacks.
           
%000000    protected function void uvm_report_fatal(string id,
                                string message, 
                                int verbosity,
                                string fname = "",
                                int line = 0,
                                string context_name = "",
                                bit report_enabled_checked = 0);
        
%000000      this.uvm_report(UVM_FATAL, id, message, UVM_NONE, fname, line,
%000000                      context_name, report_enabled_checked);
           endfunction  
        
        
           // Function -- NODOCS -- uvm_report_error
           //
           // Issues an error message using the current message's report object.
           // This message will bypass any message catching callbacks.
           
%000000    protected function void uvm_report_error(string id,
                                string message, 
                                int verbosity,
                                string fname = "",
                                int line = 0,
%000000                         string context_name = "",
%000000                         bit report_enabled_checked = 0);
        
%000000      this.uvm_report(UVM_ERROR, id, message, UVM_NONE, fname, line,
%000000                      context_name, report_enabled_checked);
           endfunction  
             
        
           // Function -- NODOCS -- uvm_report_warning
           //
           // Issues a warning message using the current message's report object.
           // This message will bypass any message catching callbacks.
           
%000000    protected function void uvm_report_warning(string id,
                                  string message,
                                  int verbosity,
                                  string fname = "",
                                  int line = 0, 
                                  string context_name = "",
                                  bit report_enabled_checked = 0);
        
%000000      this.uvm_report(UVM_WARNING, id, message, UVM_NONE, fname, line,
%000000                      context_name, report_enabled_checked);
           endfunction  
        
        
           // Function -- NODOCS -- uvm_report_info
           //
           // Issues a info message using the current message's report object.
           // This message will bypass any message catching callbacks.
           
%000000    protected function void uvm_report_info(string id,
                               string message, 
                               int verbosity,
                               string fname = "",
                               int line = 0,
                               string context_name = "",
                               bit report_enabled_checked = 0);
        
%000000      this.uvm_report(UVM_INFO, id, message, verbosity, fname, line,
%000000                      context_name, report_enabled_checked);
           endfunction  
        
           // Function -- NODOCS -- uvm_report
           //
           // Issues a message using the current message's report object.
           // This message will bypass any message catching callbacks.
        
%000000    protected function void uvm_report(uvm_severity severity,
                              string id,
                              string message,
                              int verbosity,
                              string fname = "",
                              int line = 0,
                              string context_name = "",
                              bit report_enabled_checked = 0);
        
%000000      uvm_report_message l_report_message;
%000000      if (report_enabled_checked == 0) begin
%000000        if (!uvm_report_enabled(verbosity, severity, id)) begin
                 
%000000          return;
               end
        
             end
        
%000000      l_report_message = uvm_report_message::new_report_message();
%000000      l_report_message.set_report_message(severity, id, message, 
%000000                      verbosity, fname, line, context_name);
%000000      this.uvm_process_report_message(l_report_message);
           endfunction
        
%000000    protected function void uvm_process_report_message(uvm_report_message msg);
%000000      uvm_report_object ro = m_modified_report_message.get_report_object();
%000000      uvm_action a = ro.get_report_action(msg.get_severity(), msg.get_id());
        
%000000      if(a) begin
%000000        string composed_message;
%000000        uvm_report_server rs = m_modified_report_message.get_report_server();
        
%000000        msg.set_report_object(ro);
%000000        msg.set_report_handler(m_modified_report_message.get_report_handler());
%000000        msg.set_report_server(rs);
%000000        msg.set_file(ro.get_report_file_handle(msg.get_severity(), msg.get_id()));
%000000        msg.set_action(a);
        
               // no need to compose when neither UVM_DISPLAY nor UVM_LOG is set
%000000        if (a & (UVM_LOG|UVM_DISPLAY)) begin
                 
%000000          composed_message = rs.compose_report_message(msg);
               end
        
%000000        rs.execute_report_message(msg, composed_message);
             end
           endfunction
        
        
          // Function -- NODOCS -- issue
          // Immediately issues the message which is currently being processed. This
          // is useful if the message is being ~CAUGHT~ but should still be emitted.
          //
          // Issuing a message will update the report_server stats, possibly multiple 
          // times if the message is not ~CAUGHT~.
        
%000000   protected function void issue();
%000000      string composed_message;
%000000      uvm_report_server rs = m_modified_report_message.get_report_server();
        
%000000      if(uvm_action_type'(m_modified_report_message.get_action()) != UVM_NO_ACTION) begin
             
               // no need to compose when neither UVM_DISPLAY nor UVM_LOG is set
%000000        if (m_modified_report_message.get_action() & (UVM_LOG|UVM_DISPLAY)) begin
                 
%000000          composed_message = rs.compose_report_message(m_modified_report_message);
               end
        
%000000        rs.execute_report_message(m_modified_report_message, composed_message);
             end
          endfunction
        
        
          //process_all_report_catchers
          //method called by report_server.report to process catchers
          //
        
 013520   static function int process_all_report_catchers(uvm_report_message rm);
 013520     int iter;
 013520     uvm_report_catcher catcher;
 013520     int thrown = 1;
 013520     uvm_severity orig_severity;
 013520     static bit in_catcher;
 013520     uvm_report_object l_report_object = rm.get_report_object();
        
~013520     if(in_catcher == 1) begin
%000000       return 1;
            end
 013520     in_catcher = 1;    
 013520     uvm_callbacks_base::m_tracing = 0;  //turn off cb tracing so catcher stuff doesn't print
        
 013520     orig_severity = uvm_severity'(rm.get_severity());
 013520     m_modified_report_message = rm;
        
 013520     catcher = uvm_report_cb::get_first(iter,l_report_object);
~013520     if (catcher != null) begin
%000000       if(m_debug_flags & DO_NOT_MODIFY) begin
%000000         process p = process::self(); // Keep random stability
%000000         string randstate;
%000000         if (p != null) begin
                  
%000000           randstate = p.get_randstate();
                end
        
%000000         $cast(m_orig_report_message, rm.clone()); //have to clone, rm can be extended type
%000000         if (p != null) begin
                  
%000000           p.set_randstate(randstate);
                end
        
              end
            end
~013520     while(catcher != null) begin
%000000       uvm_severity prev_sev;
        
%000000       if (!catcher.callback_mode()) begin
%000000         catcher = uvm_report_cb::get_next(iter,l_report_object);
%000000         continue;
              end
        
%000000       prev_sev = m_modified_report_message.get_severity();
%000000       m_set_action_called = 0;
%000000       thrown = catcher.process_report_catcher();
        
              // Set the action to the default action for the new severity
              // if it is still at the default for the previous severity,
              // unless it was explicitly set.
%000000       if (!m_set_action_called && 
              m_modified_report_message.get_severity() != prev_sev && 
              m_modified_report_message.get_action() == 
%000000       l_report_object.get_report_action(prev_sev, "*@&*^*^*#")) begin
        
%000000         m_modified_report_message.set_action(
%000000            l_report_object.get_report_action(m_modified_report_message.get_severity(), "*@&*^*^*#"));
              end
        
%000000       if(thrown == 0) begin 
%000000         case(orig_severity)
%000000           UVM_FATAL:   begin
%000000             m_caught_fatal++;
                  end
        
%000000           UVM_ERROR:   begin
%000000             m_caught_error++;
                  end
        
%000000           UVM_WARNING: begin
%000000             m_caught_warning++;
                  end
        
                endcase   
%000000         break;
              end 
%000000       catcher = uvm_report_cb::get_next(iter,l_report_object);
            end //while
        
            //update counters if message was returned with demoted severity
 013520     case(orig_severity)
%000000       UVM_FATAL: begin    
                
%000000         if(m_modified_report_message.get_severity() < orig_severity) begin
                  
%000000           m_demoted_fatal++;
                end
        
              end
        
%000000       UVM_ERROR: begin
                
%000000         if(m_modified_report_message.get_severity() < orig_severity) begin
                  
%000000           m_demoted_error++;
                end
        
              end
        
%000006       UVM_WARNING: begin
                
%000006         if(m_modified_report_message.get_severity() < orig_severity) begin
                  
%000000           m_demoted_warning++;
                end
        
              end
        
            endcase
        
 013520     in_catcher = 0;
 013520     uvm_callbacks_base::m_tracing = 1;  //turn tracing stuff back on
        
 013520     return thrown; 
          endfunction
        
        
          //process_report_catcher
          //internal method to call user <catch()> method
          //
        
%000000   local function int process_report_catcher();
        
%000000     action_e act;
        
%000000     act = this.catch();
        
%000000     if(act == UNKNOWN_ACTION) begin
              
%000000       this.uvm_report_error("RPTCTHR", {"uvm_report_this.catch() in catcher instance ",
%000000         this.get_name(), " must return THROW or CAUGHT"}, UVM_NONE, `uvm_file, `uvm_line);
            end
        
        
%000000     if(m_debug_flags & DO_NOT_MODIFY) begin
%000000       m_modified_report_message.copy(m_orig_report_message);
            end     
        
%000000     if(act == CAUGHT  && !(m_debug_flags & DO_NOT_CATCH)) begin
%000000       return 0;
            end  
        
%000000     return 1;
        
          endfunction
        
        
          // Function -- NODOCS -- summarize
          //
          // This function is called automatically by <uvm_report_server::report_summarize()>.
          // It prints the statistics for the active catchers.
        
        
%000003   static function void summarize(UVM_FILE file = UVM_STDOUT);
%000003     string s;
%000003     uvm_root root = uvm_root::get();
%000003     uvm_action action;
%000003     string q[$];
%000003     if(do_report) begin
%000000       q.push_back("\n--- UVM Report catcher Summary ---\n\n\n");
%000000       q.push_back($sformatf("Number of demoted UVM_FATAL reports  :%5d\n", m_demoted_fatal));
%000000       q.push_back($sformatf("Number of demoted UVM_ERROR reports  :%5d\n", m_demoted_error));
%000000       q.push_back($sformatf("Number of demoted UVM_WARNING reports:%5d\n", m_demoted_warning));
%000000       q.push_back($sformatf("Number of caught UVM_FATAL reports   :%5d\n", m_caught_fatal));
%000000       q.push_back($sformatf("Number of caught UVM_ERROR reports   :%5d\n", m_caught_error));
%000000       q.push_back($sformatf("Number of caught UVM_WARNING reports :%5d\n", m_caught_warning));
%000000       if(file == UVM_STDOUT) begin
%000000         `uvm_info_context("UVM/REPORT/CATCHER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_LOW,root)
              end
%000000       else begin
                // Re-route the output for the message to the file by changing the action, restoring to original setting after message reported
%000000         action = root.get_report_action(UVM_INFO, "UVM/REPORT/CATCHER");
%000000         root.set_report_id_action("UVM/REPORT/CATCHER", UVM_LOG);
%000000         root.set_report_id_file("UVM/REPORT/CATCHER", file);
%000000         `uvm_info_context("UVM/REPORT/CATCHER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_LOW,root)
%000000         root.set_report_id_action("UVM/REPORT/CATCHER", action);
              end  
            end
          endfunction
        
          //@uvm-compat for compatibility with 1.2
%000000   static function uvm_report_catcher get_report_catcher(string name);
%000000     static uvm_report_cb_iter iter = new(null);
%000000     get_report_catcher = iter.first();
%000000     while(get_report_catcher != null) begin
%000000       if(get_report_catcher.get_name() == name) begin
                
%000000         return get_report_catcher;
              end
        
%000000       get_report_catcher = iter.next();
            end
%000000     return null;
          endfunction
        
        
        endclass
        
        `endif // UVM_REPORT_CATCHER_SVH
        
