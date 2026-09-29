//      // verilator_coverage annotation
        // 
        //------------------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2026 NVIDIA Corporation
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
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_globals.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_root;
        typedef class uvm_report_object;
        typedef class uvm_report_message;
        typedef class uvm_sequence_library_adder_base;
           
        // Title: Globals
        
        //------------------------------------------------------------------------------
        //
        // Group -- NODOCS -- Simulation Control
        //
        //------------------------------------------------------------------------------
        
        // Task -- NODOCS -- run_test
        //
        // Convenience function for uvm_top.run_test(). See <uvm_root> for more
        // information.
        
        // @uvm-ieee 1800.2-2020 auto F.3.1.2
%000003 task run_test (string test_name="");
%000003   uvm_root top;
%000003   uvm_coreservice_t cs;
%000003   cs = uvm_coreservice_t::get();
%000003   top = cs.get_root();
%000003   top.run_test(test_name);
        endtask
        
        //----------------------------------------------------------------------------
        //
        // Group -- NODOCS -- Reporting
        //
        //----------------------------------------------------------------------------
        
        
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.1
 000015 function uvm_report_object uvm_get_report_object();
 000015   uvm_root top;
 000015   uvm_coreservice_t cs;
 000015   cs = uvm_coreservice_t::get();
 000015   top = cs.get_root();
 000015   return top;
        endfunction
        
        
        // Function -- NODOCS -- uvm_report_enabled
        //
        // Returns 1 if the configured verbosity in ~uvm_top~ for this 
        // severity/id is greater than or equal to ~verbosity~ else returns 0.
        // 
        // See also <uvm_report_object::uvm_report_enabled>.
        //
        // Static methods of an extension of uvm_report_object, e.g. uvm_component-based
        // objects, cannot call ~uvm_report_enabled~ because the call will resolve to
        // the <uvm_report_object::uvm_report_enabled>, which is non-static.
        // Static methods cannot call non-static methods of the same class. 
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.2
%000000 function int uvm_report_enabled (int verbosity,
                                         uvm_severity severity=UVM_INFO, string id="");
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   return top.uvm_report_enabled(verbosity,severity,id);
        endfunction
        
        // Function -- NODOCS -- uvm_report
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
%000000 function void uvm_report( uvm_severity severity,
                                  string id,
                                  string message,
                                  int verbosity = (severity == uvm_severity'(UVM_ERROR)) ? UVM_LOW :
                                                  (severity == uvm_severity'(UVM_FATAL)) ? UVM_NONE : UVM_MEDIUM,
                                  string filename = "",
                                  int line = 0,
%000000                           string context_name = "",
%000000                           bit report_enabled_checked = 0);
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   top.uvm_report(severity, id, message, verbosity, filename, line, context_name, report_enabled_checked);
        endfunction 
        
        // Undocumented DPI available version of uvm_report
        export "DPI-C" function m__uvm_report_dpi;
%000000 function void m__uvm_report_dpi(int severity,
                                        string id,
                                        string message,
                                        int    verbosity,
                                        string filename,
                                        int    line);
%000000    uvm_report(uvm_severity'(severity), id, message, verbosity, filename, line);
        endfunction : m__uvm_report_dpi
        
        // Function -- NODOCS -- uvm_report_info
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
 000012 function void uvm_report_info(string id,
                          string message,
                                      int verbosity = UVM_MEDIUM,
                          string filename = "",
                          int line = 0,
                                      string context_name = "",
                                      bit report_enabled_checked = 0);
 000012   uvm_root top;
 000012   uvm_coreservice_t cs;
 000012   cs = uvm_coreservice_t::get();
 000012   top = cs.get_root();
 000012   top.uvm_report_info(id, message, verbosity, filename, line, context_name,
 000012     report_enabled_checked);
        endfunction
        
        
        // Function -- NODOCS -- uvm_report_warning
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
%000006 function void uvm_report_warning(string id,
                                         string message,
                                         int verbosity = UVM_MEDIUM,
                         string filename = "",
                         int line = 0,
                                         string context_name = "",
                                         bit report_enabled_checked = 0);
%000006   uvm_root top;
%000006   uvm_coreservice_t cs;
%000006   cs = uvm_coreservice_t::get();
%000006   top = cs.get_root();
%000006   top.uvm_report_warning(id, message, verbosity, filename, line, context_name,
%000006     report_enabled_checked);
        endfunction
        
        
        // Function -- NODOCS -- uvm_report_error
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
%000000 function void uvm_report_error(string id,
                                       string message,
                                       int verbosity = UVM_NONE,
                           string filename = "",
                           int line = 0,
                                       string context_name = "",
                                       bit report_enabled_checked = 0);
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   top.uvm_report_error(id, message, verbosity, filename, line, context_name,
%000000     report_enabled_checked);
        endfunction
        
        
        // Function -- NODOCS -- uvm_report_fatal
        //
        // These methods, defined in package scope, are convenience functions that
        // delegate to the corresponding component methods in ~uvm_top~. They can be
        // used in module-based code to use the same reporting mechanism as class-based
        // components. See <uvm_report_object> for details on the reporting mechanism. 
        //
        // *Note:* Verbosity is ignored for warnings, errors, and fatals to ensure users
        // do not inadvertently filter them out. It remains in the methods for backward
        // compatibility.
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
%000000 function void uvm_report_fatal(string id,
                                   string message,
                                       int verbosity = UVM_NONE,
                           string filename = "",
                           int line = 0,
                                       string context_name = "",
                                       bit report_enabled_checked = 0);
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   top.uvm_report_fatal(id, message, verbosity, filename, line, context_name,
%000000     report_enabled_checked);
        endfunction
        
        
        // Function -- NODOCS -- uvm_process_report_message
        //
        // This method, defined in package scope, is a convenience function that
        // delegate to the corresponding component method in ~uvm_top~. It can be
        // used in module-based code to use the same reporting mechanism as class-based
        // components. See <uvm_report_object> for details on the reporting mechanism.
        
        // @uvm-ieee 1800.2-2020 auto F.3.2.3
%000000 function void uvm_process_report_message(uvm_report_message report_message);
%000000   uvm_root top;
%000000   uvm_coreservice_t cs;
%000000   process p;
%000000   p = process::self();
%000000   cs = uvm_coreservice_t::get();
%000000   top = cs.get_root();
%000000   top.uvm_process_report_message(report_message);
        endfunction
        
        
        // TODO merge with uvm_enum_wrapper#(uvm_severity)
%000000 function bit uvm_string_to_severity (string sev_str, output uvm_severity sev);
%000000   case (sev_str)
%000000     "UVM_INFO": begin
%000000       sev = UVM_INFO;
            end
        
%000000     "UVM_WARNING": begin
%000000       sev = UVM_WARNING;
            end
        
%000000     "UVM_ERROR": begin
%000000       sev = UVM_ERROR;
            end
        
%000000     "UVM_FATAL": begin
%000000       sev = UVM_FATAL;
            end
        
%000000     default: begin
%000000       return 0;
            end
        
          endcase
%000000   return 1;
        endfunction
        
        
%000000 function automatic bit uvm_string_to_action (string action_str, output uvm_action action);
%000000   string actions[$];
%000000   uvm_string_split(action_str,"|",actions);
%000000   uvm_string_to_action = 1;
%000000   action = 0;
%000000   foreach(actions[i]) begin
%000000     case (actions[i])
%000000       "UVM_NO_ACTION": begin
%000000         action |= UVM_NO_ACTION;
              end
        
%000000       "UVM_DISPLAY":   begin
%000000         action |= UVM_DISPLAY;
              end
        
%000000       "UVM_LOG":       begin
%000000         action |= UVM_LOG;
              end
        
%000000       "UVM_COUNT":     begin
%000000         action |= UVM_COUNT;
              end
        
%000000       "UVM_EXIT":      begin
%000000         action |= UVM_EXIT;
              end
        
%000000       "UVM_CALL_HOOK": begin
%000000         action |= UVM_CALL_HOOK;
              end
        
%000000       "UVM_STOP":      begin
%000000         action |= UVM_STOP;
              end
        
%000000       "UVM_RM_RECORD": begin
%000000         action |= UVM_RM_RECORD;
              end
        
%000000       default: begin
%000000         uvm_string_to_action = 0;
              end
        
            endcase
          end
        endfunction
          
%000000 function automatic bit uvm_string_to_verbosity(string verb_str, output uvm_verbosity verb_enum);
%000000     case (verb_str)
%000000       "NONE"       : begin verb_enum = UVM_NONE;   return 1; end
%000000       "UVM_NONE"   : begin verb_enum = UVM_NONE;   return 1; end
%000000       "LOW"        : begin verb_enum = UVM_LOW;    return 1; end
%000000       "UVM_LOW"    : begin verb_enum = UVM_LOW;    return 1; end
%000000       "MEDIUM"     : begin verb_enum = UVM_MEDIUM; return 1; end
%000000       "UVM_MEDIUM" : begin verb_enum = UVM_MEDIUM; return 1; end
%000000       "HIGH"       : begin verb_enum = UVM_HIGH;   return 1; end
%000000       "UVM_HIGH"   : begin verb_enum = UVM_HIGH;   return 1; end
%000000       "FULL"       : begin verb_enum = UVM_FULL;   return 1; end
%000000       "UVM_FULL"   : begin verb_enum = UVM_FULL;   return 1; end
%000000       "DEBUG"      : begin verb_enum = UVM_DEBUG;  return 1; end
%000000       "UVM_DEBUG"  : begin verb_enum = UVM_DEBUG;  return 1; end
%000000       default      : begin                         return 0; end
            endcase
        endfunction
          
          
        //----------------------------------------------------------------------------
        //
        // Group: Miscellaneous
        //
        // The library implements the following public API at the package level beyond
        // what is documented in IEEE 1800.2.
        //----------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto F.3.3.1
 000039 function bit uvm_is_match (string expr, string str);
 000039   return (uvm_re_match(.re(expr), .str(str), .deglob(1)) == 0);
        endfunction
        
        
        parameter UVM_LINE_WIDTH = `UVM_LINE_WIDTH;
        parameter UVM_NUM_LINES = `UVM_NUM_LINES;
        parameter UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1;
        parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;
        
        
        //----------------------------------------------------------------------------
        //
        // Function -- NODOCS -- uvm_string_to_bits
        //
        // Converts an input string to its bit-vector equivalent. Max bit-vector
        // length is approximately 14000 characters.
        //----------------------------------------------------------------------------
        
%000000 function logic[UVM_LARGE_STRING:0] uvm_string_to_bits(string str);
%000000   $swrite(uvm_string_to_bits, "%0s", str);
        endfunction
        
        // @uvm-ieee 1800.2-2020 auto F.3.1.1
 000597 function uvm_core_state get_core_state();
%000000    if (m_uvm_core_state.size() == 0) begin
%000000      return UVM_CORE_UNINITIALIZED;
           end
        
%000000    else begin
%000000      return m_uvm_core_state[0];
           end
        
        endfunction
        
        // Function: uvm_init
        // Implementation of uvm_init, as defined in section
        // F.3.1.3 in 1800.2-2020.
        //
        // *Note:* The LRM states that subsequent calls to <uvm_init> after
        // the first are silently ignored, however there are scenarios wherein
        // the implementation breaks this requirement.
        //
        // If the core state (see <get_core_state>) is ~UVM_CORE_PRE_INIT~ when <uvm_init>,
        // is called, then the library can not determine the appropriate core service.  As
        // such, the default core service will be constructed and a fatal message
        // shall be generated.
        //
        // If the core state is past ~UVM_CORE_PRE_INIT~, and ~cs~ is a non-null core 
        // service instance different than the value passed to the first <uvm_init> call, 
        // then the library will generate a warning message to alert the user that this 
        // call to <uvm_init> is being ignored.
        //
        // @uvm-contrib This API represents a potential contribution to IEEE 1800.2
          
        // @uvm-ieee 1800.2-2020 auto F.3.1.3
%000003 function void uvm_init(uvm_coreservice_t cs=null);
%000003   uvm_default_coreservice_t dcs;
        
%000003   if(get_core_state()!=UVM_CORE_UNINITIALIZED) begin
%000000     if (get_core_state() == UVM_CORE_PRE_INIT) begin
              // If we're in this state, something very strange has happened.
              // We've called uvm_init, and it is actively assigning the
              // core service, but the core service isn't actually set yet.
              // This means that either the library messed something up, or
              // we have a race occurring between two threads.  Either way, 
              // this is non-recoverable.  We're going to setup using the default
              // core service, and immediately fatal out.
%000000       dcs = new();
%000000       uvm_coreservice_t::set(dcs);
%000000       `uvm_fatal("UVM/INIT/MULTI", "Non-recoverable race during uvm_init")
            end
%000000     else begin
              // After PRE_INIT, we can check to see if this is worth reporting
              // as a warning.  We only report it if the value for ~cs~ is _not_
              // the current core service, and ~cs~ is not null.
%000000       uvm_coreservice_t actual;
%000000       actual = uvm_coreservice_t::get();
%000000       if ((cs != actual) && (cs != null)) begin
%000000         `uvm_warning("UVM/INIT/MULTI", "uvm_init() called after library has already completed initialization, subsequent calls are ignored!")
              end
            end
%000000     return;
          end
%000003   m_uvm_core_state.push_front(UVM_CORE_PRE_INIT);
        
          // We control the implementation of uvm_default_coreservice_t::new
          // and uvm_coreservice_t::set (which is undocumented).  As such,
          // we guarantee that they will not trigger any calls to uvm_init.
%000003   if(cs == null) begin
%000003     dcs = new();
%000003     cs = dcs;
          end
%000003   uvm_coreservice_t::set(cs);
        
%000003   cs.set_core_state(UVM_CORE_INITIALIZING);
        
%000003   cs.initialize();
        
%000003   cs.set_core_state(UVM_CORE_INITIALIZED);
        endfunction
        
        //----------------------------------------------------------------------------
        //
        // Function -- NODOCS -- uvm_bits_to_string
        //
        // Converts an input bit-vector to its string equivalent. Max bit-vector
        // length is approximately 14000 characters.
        //----------------------------------------------------------------------------
        
%000000 function string uvm_bits_to_string(logic [UVM_LARGE_STRING:0] str);
%000000   $swrite(uvm_bits_to_string, "%0s", str);
        endfunction
        
        
        //----------------------------------------------------------------------------
        //
        // Task: uvm_wait_for_nba_region
        //
        // This task will block until SystemVerilog's NBA region (or Re-NBA region if 
        // called from a program context).  The purpose is to continue the calling 
        // process only after allowing other processes any number of delta cycles (#0) 
        // to settle out.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        //----------------------------------------------------------------------------
        
 001367 task uvm_wait_for_nba_region;
        
          // Nonblocking assignment requires static
 001367   static int nba;
 001367   static int next_nba;
        
          //If `included directly in a program block, can't use a non-blocking assign,
          //but it isn't needed since program blocks are in a separate region.
        `ifndef UVM_NO_WAIT_FOR_NBA
 001367   next_nba++;
 001367   nba <= next_nba;
 001367   @(nba);
        `else
          repeat(`UVM_POUND_ZERO_COUNT) #0;
        `endif
        
        
        endtask
        
          
        //----------------------------------------------------------------------------
        //
        // Function -- NODOCS -- uvm_split_string
        //
        // Returns a queue of strings, ~values~, that is the result of the ~str~ split
        // based on the ~sep~.  For example:
        //
        //| uvm_split_string("1,on,false", ",", splits);
        //
        // Results in the 'splits' queue containing the three elements: 1, on and 
        // false.
        //----------------------------------------------------------------------------
        //@uvm-compat provided for backward compatibility with 1800.2-2017
%000000 function automatic void uvm_split_string (string str, byte sep, ref string values[$]);
%000000   int s = 0, e = 0;
%000000   values.delete();
%000000   while(e < str.len()) begin
%000000     for(s=e; e<str.len(); ++e) begin
              
%000000       if(str[e] == sep) begin
%000000         break;
              end
        
            end
        
%000000     if(s != e) begin
              
%000000       values.push_back(str.substr(s,e-1));
            end
        
%000000     e++;
          end
        endfunction
        
        
        //----------------------------------------------------------------------------
        //
        // Function -- NODOCS -- uvm_string_split
        // Returns a queue of strings, values, that is the result of the str split based 
        // on the sep. values shall be a queue.
        //----------------------------------------------------------------------------
        
%000000 function automatic void uvm_string_split (string str, byte sep, ref string values[$]);
%000000   int s = 0, e = 0, limit;
%000000   values.delete();
%000000   limit = str.len() + 1;
%000000   do begin 
            
%000000     for(s=e; e<str.len(); ++e) begin
                
%000000       if(str[e] == sep) begin
%000000         break;
              end
        
            end
        
%000000     values.push_back(str.substr(s,e-1));
%000000     e++;
          end
%000000   while(e < limit);
        endfunction
        
          
        // Class -- NODOCS -- uvm_enum_wrapper#(T)
        //
        // The ~uvm_enum_wrapper#(T)~ class is a utility mechanism provided
        // as a convenience to the end user.  It provides a <from_name>
        // method which is the logical inverse of the System Verilog ~name~ 
        // method which is built into all enumerations.
        
        // @uvm-ieee 1800.2-2020 auto F.3.4.1
        class uvm_enum_wrapper#(type T=uvm_active_passive_enum) extends uvm_void;
        
            protected static T map[string];
        
        
            // @uvm-ieee 1800.2-2020 auto F.3.4.2
%000000     static function bit from_name(string name, ref T value);
%000000         if (map.size() == 0) begin
                  
%000000           m_init_map();
                end
        
        
%000000         if (map.exists(name)) begin
%000000           value = map[name];
%000000           return 1;
                end
%000000         else begin
%000000           return 0;
                end
            endfunction : from_name
        
            // Function- m_init_map
            // Initializes the name map, only needs to be performed once
%000000     protected static function void m_init_map();
%000000         T e = e.first();
%000000         do begin 
                  
%000000           map[e.name()] = e;
%000000           e = e.next();
                end
%000000         while (e != e.first());
            endfunction : m_init_map
        
            // Function- new
            // Prevents accidental instantiations
%000000     protected function new();
            endfunction : new
        
        endclass : uvm_enum_wrapper
        
        // Class -- NODOCS -- uvm_shared#(T)
        //
        // The ~uvm_shared#(T)~ class is a utility mechanism provided as
        // a convenience method for passing potentially large values
        // such as arrays, queues, or bitstreams by reference instead
        // of by value.  The data itself is contained in a single
        // ~value~ variable.
        //
        // Unlike ref ports, the uvm_shared#(T) can be saved and used
        // after a function/task scope has been exited.
        //
        // @uvm-contrib - For potential contribution to 1800.2 standard
~000012 class uvm_shared#(type T=int) extends uvm_void;
          // Variable- value
          // The value contained within the ref.
          T value;
        endclass : uvm_shared
        
