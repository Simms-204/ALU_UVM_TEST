//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
        // Copyright 2011 Cypress Semiconductor Corp.
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
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_report_handler.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_REPORT_HANDLER_SVH
        `define UVM_REPORT_HANDLER_SVH
        
        typedef class uvm_report_object;
        typedef class uvm_report_server;
        typedef uvm_pool#(string, uvm_action) uvm_id_actions_array;
        typedef uvm_pool#(string, UVM_FILE) uvm_id_file_array;
        typedef uvm_pool#(string, int) uvm_id_verbosities_array;
        typedef uvm_pool#(uvm_severity, uvm_severity) uvm_sev_override_array;
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_handler
        //
        // The uvm_report_handler is the class to which most methods in
        // <uvm_report_object> delegate. It stores the maximum verbosity, actions,
        // and files that affect the way reports are handled. 
        //
        // The report handler is not intended for direct use. See <uvm_report_object>
        // for information on the UVM reporting mechanism.
        //
        // The relationship between <uvm_report_object> (a base class for uvm_component)
        // and uvm_report_handler is typically one to one, but it can be many to one
        // if several uvm_report_objects are configured to use the same
        // uvm_report_handler_object. See <uvm_report_object::set_report_handler>.
        //
        // The relationship between uvm_report_handler and <uvm_report_server> is many
        // to one. 
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 6.4.1
        class uvm_report_handler extends uvm_object;
        
          // internal variables
        
          int m_max_verbosity_level;
        
          // id verbosity settings : default and severity
          uvm_id_verbosities_array id_verbosities;
          uvm_id_verbosities_array severity_id_verbosities[uvm_severity];
        
          // actions
          uvm_id_actions_array id_actions;
          uvm_action severity_actions[uvm_severity];
          uvm_id_actions_array severity_id_actions[uvm_severity];
        
          // severity overrides
          uvm_sev_override_array sev_overrides;
          uvm_sev_override_array sev_id_overrides [string];
        
          // file handles : default, severity, action, (severity,id)
          UVM_FILE default_file_handle;
          uvm_id_file_array id_file_handles;
          UVM_FILE severity_file_handles[uvm_severity];
          uvm_id_file_array severity_id_file_handles[uvm_severity];
        
        
%000000   `uvm_object_utils(uvm_report_handler)
        
        
          // Function -- NODOCS -- new
          // 
          // Creates and initializes a new uvm_report_handler object.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.2.1
~000165   function new(string name = "uvm_report_handler");
 000165     super.new(name);
 000165     initialize();
          endfunction
        
        
          // Function -- NODOCS -- print
          //
          // The uvm_report_handler implements the <uvm_object::do_print()> such that
          // ~print~ method provides UVM printer formatted output
          // of the current configuration.  A snippet of example output is shown here:
          //
          // |uvm_test_top                uvm_report_handler  -     @555                    
          // |  max_verbosity_level       uvm_verbosity       32    UVM_FULL                
          // |  id_verbosities            uvm_pool            3     -                       
          // |    [ID1]                   uvm_verbosity       32    UVM_LOW                 
          // |  severity_id_verbosities   array               4     -                       
          // |    [UVM_INFO:ID4]          int                 32    501                     
          // |  id_actions                uvm_pool            2     -                       
          // |    [ACT_ID]                uvm_action          32    DISPLAY LOG COUNT       
          // |  severity_actions          array               4     -                       
          // |    [UVM_INFO]              uvm_action          32    DISPLAY                 
          // |    [UVM_WARNING]           uvm_action          32    DISPLAY RM_RECORD COUNT 
          // |    [UVM_ERROR]             uvm_action          32    DISPLAY COUNT           
          // |    [UVM_FATAL]             uvm_action          32    DISPLAY EXIT            
          // |  default_file_handle       int                 32    'h1                     
        
          // @uvm-ieee 1800.2-2020 auto 6.4.2.2
%000000   virtual function void do_print (uvm_printer printer);
        
%000000     uvm_verbosity l_verbosity;
%000000     uvm_severity l_severity;
%000000     string idx;
%000000     int l_int;
        
            // max verb
%000000     if ($cast(l_verbosity, m_max_verbosity_level)) begin
              
%000000       printer.print_generic("max_verbosity_level", "uvm_verbosity", 32, 
%000000         l_verbosity.name());
            end
        
%000000     else begin
              
%000000       printer.print_field("max_verbosity_level", m_max_verbosity_level, 32, UVM_DEC,
%000000         ".", "int");
            end
        
        
            // id verbs
%000000     if(id_verbosities.first(idx)) begin
%000000       printer.print_array_header("id_verbosities",id_verbosities.num(),
%000000         "uvm_pool");
%000000       do begin
%000000         l_int = id_verbosities.get(idx);
%000000         if ($cast(l_verbosity, l_int)) begin
                  
%000000           printer.print_generic($sformatf("[%s]", idx), "uvm_verbosity", 32, 
%000000             l_verbosity.name());
                end
        
%000000         else begin
%000000           string l_str;
%000000           l_str.itoa(l_int);
%000000           printer.print_generic($sformatf("[%s]", idx), "int", 32, 
%000000             l_str);
                end
%000000       end while(id_verbosities.next(idx));
%000000       printer.print_array_footer();
            end
        
            // sev and id verbs
%000000     if(severity_id_verbosities.size() != 0) begin
%000000       int _total_cnt;
%000000       foreach (severity_id_verbosities[l_severity]) begin
                
%000000         _total_cnt += severity_id_verbosities[l_severity].num();
              end
        
%000000       printer.print_array_header("severity_id_verbosities", _total_cnt,
%000000         "array");
%000000       if(severity_id_verbosities.first(l_severity)) begin
%000000         do begin
%000000           uvm_id_verbosities_array id_v_ary = severity_id_verbosities[l_severity];
%000000           if(id_v_ary.first(idx)) begin
                  
%000000             do begin
%000000               l_int = id_v_ary.get(idx);
%000000               if ($cast(l_verbosity, l_int)) begin
                      
%000000                 printer.print_generic($sformatf("[%s:%s]", l_severity.name(), idx), 
%000000                     "uvm_verbosity", 32, l_verbosity.name());
                      end
        
%000000               else begin
%000000                 string l_str;
%000000                 l_str.itoa(l_int);
%000000                 printer.print_generic($sformatf("[%s:%s]", l_severity.name(), idx), 
%000000                     "int", 32, l_str);
                      end
%000000             end while(id_v_ary.next(idx));
                  end
        
%000000         end while(severity_id_verbosities.next(l_severity));
              end
%000000       printer.print_array_footer();
            end
        
            // id actions
%000000     if(id_actions.first(idx)) begin
%000000       printer.print_array_header("id_actions",id_actions.num(),
%000000         "uvm_pool");
%000000       do begin
%000000         l_int = id_actions.get(idx);
%000000         printer.print_generic($sformatf("[%s]", idx), "uvm_action", 32, 
%000000           format_action(l_int));
%000000       end while(id_actions.next(idx));
%000000       printer.print_array_footer();
            end
        
            // severity actions
%000000     if(severity_actions.first(l_severity)) begin
%000000       printer.print_array_header("severity_actions",4,"array");
%000000       do begin
%000000         printer.print_generic($sformatf("[%s]", l_severity.name()), "uvm_action", 32, 
%000000           format_action(severity_actions[l_severity]));
%000000       end while(severity_actions.next(l_severity));
%000000       printer.print_array_footer();
            end
        
            // sev and id actions 
%000000     if(severity_id_actions.size() != 0) begin
%000000       int _total_cnt;
%000000       foreach (severity_id_actions[l_severity]) begin
                
%000000         _total_cnt += severity_id_actions[l_severity].num();
              end
        
%000000       printer.print_array_header("severity_id_actions", _total_cnt,
%000000         "array");
%000000       if(severity_id_actions.first(l_severity)) begin
%000000         do begin
%000000           uvm_id_actions_array id_a_ary = severity_id_actions[l_severity];
%000000           if(id_a_ary.first(idx)) begin
                  
%000000             do begin
%000000               printer.print_generic($sformatf("[%s:%s]", l_severity.name(), idx), 
%000000                   "uvm_action", 32, format_action(id_a_ary.get(idx)));
%000000             end while(id_a_ary.next(idx));
                  end
        
%000000         end while(severity_id_actions.next(l_severity));
              end
%000000       printer.print_array_footer();
            end
        
            // sev overrides
%000000     if(sev_overrides.first(l_severity)) begin
%000000       printer.print_array_header("sev_overrides",sev_overrides.num(),
%000000         "uvm_pool");
%000000       do begin
%000000         uvm_severity l_severity_new = sev_overrides.get(l_severity);
%000000         printer.print_generic($sformatf("[%s]", l_severity.name()),
%000000           "uvm_severity", 32, l_severity_new.name());
%000000       end while(sev_overrides.next(l_severity));
%000000       printer.print_array_footer();
            end
        
            // sev and id overrides
%000000     if(sev_id_overrides.size() != 0) begin
%000000       int _total_cnt;
%000000       foreach (sev_id_overrides[idx]) begin
                
%000000         _total_cnt += sev_id_overrides[idx].num();
              end
        
%000000       printer.print_array_header("sev_id_overrides", _total_cnt,
%000000         "array");
%000000       if(sev_id_overrides.first(idx)) begin
%000000         do begin
%000000           uvm_sev_override_array sev_o_ary = sev_id_overrides[idx];
%000000           if(sev_o_ary.first(l_severity)) begin
                  
%000000             do begin
%000000               uvm_severity new_sev = sev_o_ary.get(l_severity);
%000000               printer.print_generic($sformatf("[%s:%s]", l_severity.name(), idx), 
%000000               "uvm_severity", 32, new_sev.name());
%000000             end while(sev_o_ary.next(l_severity));
                  end
        
%000000         end while(sev_id_overrides.next(idx));
              end
%000000       printer.print_array_footer();
            end
        
            // default file handle
%000000     printer.print_field("default_file_handle", default_file_handle, 32, UVM_HEX,
%000000       ".", "int");
        
            // id files 
%000000     if(id_file_handles.first(idx)) begin
%000000       printer.print_array_header("id_file_handles",id_file_handles.num(),
%000000         "uvm_pool");
%000000       do begin
%000000         printer.print_field($sformatf("[%s]", idx), id_file_handles.get(idx), 32,
%000000           UVM_HEX, ".", "UVM_FILE");
%000000       end while(id_file_handles.next(idx));
%000000       printer.print_array_footer();
            end
        
            // severity files
%000000     if(severity_file_handles.first(l_severity)) begin
%000000       printer.print_array_header("severity_file_handles",4,"array");
%000000       do begin
%000000         printer.print_field($sformatf("[%s]", l_severity.name()), 
%000000           severity_file_handles[l_severity], 32, UVM_HEX, ".", "UVM_FILE");
%000000       end while(severity_file_handles.next(l_severity));
%000000       printer.print_array_footer();
            end
        
            // sev and id files
%000000     if(severity_id_file_handles.size() != 0) begin
%000000       int _total_cnt;
%000000       foreach (severity_id_file_handles[l_severity]) begin
                
%000000         _total_cnt += severity_id_file_handles[l_severity].num();
              end
        
%000000       printer.print_array_header("severity_id_file_handles", _total_cnt,
%000000         "array");
%000000       if(severity_id_file_handles.first(l_severity)) begin
%000000         do begin
%000000           uvm_id_file_array id_f_ary = severity_id_file_handles[l_severity];
%000000           if(id_f_ary.first(idx)) begin
                  
%000000             do begin
%000000               printer.print_field($sformatf("[%s:%s]", l_severity.name(), idx),
%000000               id_f_ary.get(idx), 32, UVM_HEX, ".", "UVM_FILE");
%000000             end while(id_f_ary.next(idx));
                  end
        
%000000         end while(severity_id_file_handles.next(l_severity));
              end
%000000       printer.print_array_footer();
            end
        
          endfunction
        
          
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Message Processing
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- process_report_message
          //
          // This is the common handler method used by the four core reporting methods
          // (e.g. <uvm_report_error>) in <uvm_report_object>.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.7
 002630   virtual function void process_report_message(uvm_report_message report_message);
 002630     uvm_report_server srvr = uvm_report_server::get_server();
 002630     string id = report_message.get_id();
 002630     uvm_severity severity = report_message.get_severity();
        
            // Check for severity overrides and apply them before calling the server.
            // An id specific override has precedence over a generic severity override.
~002630     if(sev_id_overrides.exists(id)) begin
%000000       if(sev_id_overrides[id].exists(uvm_severity'(severity))) begin
%000000         severity = sev_id_overrides[id].get(severity);
%000000         report_message.set_severity(severity);
              end
            end
 002630     else begin
~002630       if(sev_overrides.exists(severity)) begin
%000000         severity = sev_overrides.get(severity);
%000000         report_message.set_severity(severity);
              end
            end
 002630     report_message.set_file(get_file_handle(severity, id));
 002630     report_message.set_report_handler(this);
 002630     report_message.set_action(get_action(severity, id));
 002630     srvr.process_report_message(report_message);
            
          endfunction
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS -- Convenience Methods
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- format_action
          //
          // Returns a string representation of the ~action~, e.g., "DISPLAY".
        
%000000   static function string format_action(uvm_action action);
%000000     string s;
        
%000000     if(uvm_action_type'(action) == UVM_NO_ACTION) begin
%000000       s = "NO ACTION";
            end
%000000     else begin
%000000       s = "";
%000000       if(action & UVM_DISPLAY)   begin
%000000         s = {s, "DISPLAY "};
              end
        
%000000       if(action & UVM_LOG)       begin
%000000         s = {s, "LOG "};
              end
        
%000000       if(action & UVM_RM_RECORD) begin
%000000         s = {s, "RM_RECORD "};
              end
        
%000000       if(action & UVM_COUNT)     begin
%000000         s = {s, "COUNT "};
              end
        
%000000       if(action & UVM_CALL_HOOK) begin
%000000         s = {s, "CALL_HOOK "};
              end
        
%000000       if(action & UVM_EXIT)      begin
%000000         s = {s, "EXIT "};
              end
        
%000000       if(action & UVM_STOP)      begin
%000000         s = {s, "STOP "};
              end
        
            end
        
%000000     return s;
          endfunction
        
        
          // Function- initialize
          //
          // Internal method for initializing report handler.
        
 000165   function void initialize();
        
 000165     set_default_file(0);
 000165     m_max_verbosity_level = UVM_MEDIUM;
        
 000165     id_actions=new();
 000165     id_verbosities=new();
 000165     id_file_handles=new();
 000165     sev_overrides=new();
        
 000165     set_severity_action(UVM_INFO,    UVM_DISPLAY);
 000165     set_severity_action(UVM_WARNING, UVM_DISPLAY);
 000165     set_severity_action(UVM_ERROR,   UVM_DISPLAY | UVM_COUNT);
 000165     set_severity_action(UVM_FATAL,   UVM_DISPLAY | UVM_EXIT);
        
 000165     set_severity_file(UVM_INFO, default_file_handle);
 000165     set_severity_file(UVM_WARNING, default_file_handle);
 000165     set_severity_file(UVM_ERROR,   default_file_handle);
 000165     set_severity_file(UVM_FATAL,   default_file_handle);
        
          endfunction
        
          
          // Function- get_severity_id_file
          //
          // Return the file id based on the severity and the id
        
 002630   local function UVM_FILE get_severity_id_file(uvm_severity severity, string id);
        
 002630     uvm_id_file_array array;
        
~002630     if(severity_id_file_handles.exists(severity)) begin
%000000       array = severity_id_file_handles[severity];      
%000000       if(array.exists(id)) begin
                
%000000         return array.get(id);
              end
        
            end
        
        
~002630     if(id_file_handles.exists(id)) begin
              
%000000       return id_file_handles.get(id);
            end
        
        
%000000     if(severity_file_handles.exists(severity)) begin
              
%000000       return severity_file_handles[severity];
            end
        
        
 002630     return default_file_handle;
        
          endfunction
        
        
          // Function- set_verbosity_level
          //
          // Internal method called by uvm_report_object.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.3.2
 000165   function void set_verbosity_level(int verbosity_level);
 000165     m_max_verbosity_level = verbosity_level;
          endfunction
        
        
          // Function- get_verbosity_level
          //
          // Returns the verbosity associated with the given ~severity~ and ~id~.
          // 
          // First, if there is a verbosity associated with the ~(severity,id)~ pair,
          // return that.  Else, if there is a verbosity associated with the ~id~, return
          // that.  Else, return the max verbosity setting.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.3.1
 002990   function int get_verbosity_level(uvm_severity severity=UVM_INFO, string id="" );
        
 002990     uvm_id_verbosities_array array;
~002990     if(severity_id_verbosities.exists(severity)) begin
%000000       array = severity_id_verbosities[severity];
%000000       if(array.exists(id)) begin
%000000         return array.get(id);
              end
            end
        
~002990     if(id_verbosities.exists(id)) begin
%000000       return id_verbosities.get(id);
            end
        
 002990     return m_max_verbosity_level;
        
          endfunction
        
        
          // Function- get_action
          //
          // Returns the action associated with the given ~severity~ and ~id~.
          // 
          // First, if there is an action associated with the ~(severity,id)~ pair,
          // return that.  Else, if there is an action associated with the ~id~, return
          // that.  Else, if there is an action associated with the ~severity~, return
          // that. Else, return the default action associated with the ~severity~.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.4.1
 005257   function uvm_action get_action(uvm_severity severity, string id);
        
 005257     uvm_id_actions_array array;
~005257     if(severity_id_actions.exists(severity)) begin
%000000       array = severity_id_actions[severity];
%000000       if(array.exists(id)) begin
                
%000000         return array.get(id);
              end
        
            end
        
~005257     if(id_actions.exists(id)) begin
              
%000000       return id_actions.get(id);
            end
        
        
 005257     return severity_actions[severity];
        
          endfunction
        
        
          // Function- get_file_handle
          //
          // Returns the file descriptor associated with the given ~severity~ and ~id~.
          //
          // First, if there is a file handle associated with the ~(severity,id)~ pair,
          // return that. Else, if there is a file handle associated with the ~id~, return
          // that. Else, if there is an file handle associated with the ~severity~, return
          // that. Else, return the default file handle.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.5.1
 002630   function UVM_FILE get_file_handle(uvm_severity severity, string id);
 002630     UVM_FILE file;
          
 002630     file = get_severity_id_file(severity, id);
~002630     if (file != 0) begin
              
%000000       return file;
            end
        
          
~002630     if (id_file_handles.exists(id)) begin
%000000       file = id_file_handles.get(id);
%000000       if (file != 0) begin
                
%000000         return file;
              end
        
            end
        
~002630     if (severity_file_handles.exists(severity)) begin
 002630       file = severity_file_handles[severity];
~002630       if(file != 0) begin
                
%000000         return file;
              end
        
            end
        
 002630     return default_file_handle;
          endfunction
        
        
          // Function- set_severity_action
          // Function- set_id_action
          // Function- set_severity_id_action
          // Function- set_id_verbosity
          // Function- set_severity_id_verbosity
          //
          // Internal methods called by uvm_report_object.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.4.2
 000660   function void set_severity_action(input uvm_severity severity,
                                            input uvm_action action);
 000660     severity_actions[severity] = action;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.4.2
 000081   function void set_id_action(input string id, input uvm_action action);
 000081     id_actions.add(id, action);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.4.2
%000000   function void set_severity_id_action(uvm_severity severity,
                                               string id,
                                               uvm_action action);
%000000     if(!severity_id_actions.exists(severity)) begin
              
%000000       severity_id_actions[severity] = new;
            end
        
%000000     severity_id_actions[severity].add(id,action);
          endfunction
          
          // @uvm-ieee 1800.2-2020 auto 6.4.3.3
%000000   function void set_id_verbosity(input string id, input int verbosity);
%000000     id_verbosities.add(id, verbosity);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.3.3
%000000   function void set_severity_id_verbosity(uvm_severity severity,
                                               string id,
                                               int verbosity);
%000000     if(!severity_id_verbosities.exists(severity)) begin
              
%000000       severity_id_verbosities[severity] = new;
            end
        
%000000     severity_id_verbosities[severity].add(id,verbosity);
          endfunction
        
          // Function- set_default_file
          // Function- set_severity_file
          // Function- set_id_file
          // Function- set_severity_id_file
          //
          // Internal methods called by uvm_report_object.
        
          // @uvm-ieee 1800.2-2020 auto 6.4.5.2
 000165   function void set_default_file (UVM_FILE file);
 000165     default_file_handle = file;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.5.2
 000660   function void set_severity_file (uvm_severity severity, UVM_FILE file);
 000660     severity_file_handles[severity] = file;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.5.2
%000000   function void set_id_file (string id, UVM_FILE file);
%000000     id_file_handles.add(id, file);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.5.2
%000000   function void set_severity_id_file(uvm_severity severity,
                                             string id, UVM_FILE file);
%000000     if(!severity_id_file_handles.exists(severity)) begin
              
%000000       severity_id_file_handles[severity] = new;
            end
        
%000000     severity_id_file_handles[severity].add(id, file);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.6
%000000   function void set_severity_override(uvm_severity cur_severity,
                                              uvm_severity new_severity);
%000000     sev_overrides.add(cur_severity, new_severity);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 6.4.6
%000000   function void set_severity_id_override(uvm_severity cur_severity,
                                                 string id,
                                                 uvm_severity new_severity);
            // has precedence over set_severity_override
            // silently override previous setting
%000000     uvm_sev_override_array arr;
%000000     if(!sev_id_overrides.exists(id)) begin
              
%000000       sev_id_overrides[id] = new;
            end
        
         
%000000     sev_id_overrides[id].add(cur_severity, new_severity);
          endfunction
        
          
        
          // Function- report
          //
          // This is the common handler method used by the four core reporting methods
          // (e.g., uvm_report_error) in <uvm_report_object>.
        
%000000   virtual function void report(
              uvm_severity severity,
              string name,
              string id,
              string message,
              int verbosity_level=UVM_MEDIUM,
              string filename="",
              int line=0,
              uvm_report_object client=null
              );
        
%000000     bit l_report_enabled = 0;
%000000     uvm_report_message l_report_message;
%000000     uvm_coreservice_t cs;
%000000     cs = uvm_coreservice_t::get();
%000000     if (!uvm_report_enabled(verbosity_level, UVM_INFO, id)) begin
              
%000000       return;
            end
        
        
%000000     if (client==null) begin 
              
%000000       client = cs.get_root();
            end
        
        
%000000     l_report_message = uvm_report_message::new_report_message();
%000000     l_report_message.set_report_message(severity, id, message, 
%000000                     verbosity_level, filename, line, name);
%000000     l_report_message.set_report_object(client);
%000000     l_report_message.set_action(get_action(severity,id));
%000000     process_report_message(l_report_message);
        
          endfunction
        
          // @uvm-compat Added for compatibility with 1.1d
%000000   function void dump_state();
        
%000000     string s;
%000000     UVM_FILE file;
%000000     uvm_action a;
%000000     string idx;
%000000     string q[$];
         
%000000     uvm_id_actions_array id_a_ary;
%000000     uvm_id_verbosities_array id_v_ary;
%000000     uvm_id_file_array id_f_ary;
        
%000000     q.push_back("\n----------------------------------------------------------------------\n");
%000000     q.push_back("report handler state dump \n\n");
        
            // verbosities
        
%000000     q.push_back("\n+-----------------+\n");
%000000     q.push_back("|   Verbosities   |\n");
%000000     q.push_back("+-----------------+\n\n"); 
        
%000000     q.push_back($sformatf("max verbosity level = %d\n", m_max_verbosity_level));
%000000     q.push_back("*** verbosities by id\n");
        
%000000     if(id_verbosities.first(idx)) begin
            
%000000       do begin
%000000         uvm_verbosity v = uvm_verbosity'(id_verbosities.get(idx));
%000000         q.push_back($sformatf("[%s] --> %s\n", idx, v.name()));
%000000       end while(id_verbosities.next(idx));
            end
        
        
            // verbosities by id
        
%000000     q.push_back("*** verbosities by id and severity\n");
        
%000000     foreach( severity_id_verbosities[severity] ) begin
%000000       uvm_severity sev = uvm_severity'(severity);
%000000       id_v_ary = severity_id_verbosities[severity];
%000000       if(id_v_ary.first(idx)) begin
              
%000000         do begin
%000000           uvm_verbosity v = uvm_verbosity'(id_v_ary.get(idx));
%000000           q.push_back($sformatf("%s:%s --> %s\n",sev.name(), idx, v.name()));    
%000000         end while(id_v_ary.next(idx));
              end
        
            end
        
            // actions
        
%000000     q.push_back("\n+-------------+\n");
%000000     q.push_back("|   actions   |\n");
%000000     q.push_back("+-------------+\n\n");
            
%000000     q.push_back("*** actions by severity\n");
%000000     foreach( severity_actions[severity] ) begin
%000000       uvm_severity sev = uvm_severity'(severity);
%000000       q.push_back($sformatf("%s = %s\n",sev.name(), format_action(severity_actions[severity])));
            end
        
%000000     q.push_back("\n*** actions by id\n");
        
%000000     if(id_actions.first(idx)) begin
            
%000000       do begin
%000000         q.push_back($sformatf("[%s] --> %s\n", idx, format_action(id_actions.get(idx))));
%000000       end while(id_actions.next(idx));
            end
        
        
            // actions by id
%000000     q.push_back("\n*** actions by id and severity\n");
        
%000000     foreach( severity_id_actions[severity] ) begin
%000000       uvm_severity sev = uvm_severity'(severity);
%000000       id_a_ary = severity_id_actions[severity];
%000000       if(id_a_ary.first(idx)) begin
              
%000000         do begin
%000000           q.push_back($sformatf("%s:%s --> %s\n",sev.name(), idx, format_action(id_a_ary.get(idx))));   
%000000         end while(id_a_ary.next(idx));
              end
        
            end
        
            // Files
        
%000000     q.push_back("\n+-------------+\n");
%000000     q.push_back("|    files    |\n");
%000000     q.push_back("+-------------+\n\n");
        
%000000     q.push_back($sformatf("default file handle = %d\n\n", default_file_handle));
        
%000000     q.push_back("*** files by severity\n");
%000000     foreach( severity_file_handles[severity] ) begin
%000000       uvm_severity sev = uvm_severity'(severity);
%000000       file = severity_file_handles[severity];
%000000       q.push_back($sformatf("%s = %d\n", sev.name(), file));
            end
        
%000000     q.push_back("\n*** files by id\n");
        
%000000     if(id_file_handles.first(idx)) begin
            
%000000       do begin
%000000         file = id_file_handles.get(idx);
%000000         q.push_back($sformatf("id %s --> %d\n", idx, file));
%000000       end while (id_file_handles.next(idx));
            end
        
        
%000000     q.push_back("\n*** files by id and severity\n");
        
%000000     foreach( severity_id_file_handles[severity] ) begin
%000000       uvm_severity sev = uvm_severity'(severity);
%000000       id_f_ary = severity_id_file_handles[severity];
%000000       if(id_f_ary.first(idx)) begin
              
%000000         do begin
%000000           q.push_back($sformatf("%s:%s --> %d\n", sev.name(), idx, id_f_ary.get(idx)));
%000000         end while(id_f_ary.next(idx));
              end
        
            end
%000000     q.push_back("----------------------------------------------------------------------\n");
        
%000000     begin
%000000       uvm_report_server srvr;
%000000       srvr=uvm_report_server::get_server();        
%000000       srvr.report_summarize();
            end
%000000     `uvm_info("UVM/REPORT/HANDLER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_LOW)
        
          endfunction
        
          //@uvm-compat provided for compatibility with 1.1d
%000000   virtual function bit run_hooks(uvm_report_object client,
                                         uvm_severity severity,
                                         string id,
                                         string message,
                                         int verbosity,
                                         string filename,
                                         int line);
        
%000000     bit ok;
        
%000000     ok = client.report_hook(id, message, verbosity, filename, line);
        
%000000     case(severity)
%000000       UVM_INFO: begin
               
%000000         ok &= client.report_info_hook   (id, message, verbosity, filename, line);
              end
        
%000000       UVM_WARNING: begin
               
%000000         ok &= client.report_warning_hook(id, message, verbosity, filename, line);
              end
        
%000000       UVM_ERROR: begin
               
%000000         ok &= client.report_error_hook  (id, message, verbosity, filename, line);
              end
        
%000000       UVM_FATAL: begin
               
%000000         ok &= client.report_fatal_hook  (id, message, verbosity, filename, line);
              end
        
            endcase
        
%000000     return ok;
        
          endfunction
        
        
        endclass : uvm_report_handler
        
        `endif //UVM_REPORT_HANDLER_SVH
        
