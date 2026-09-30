//      // verilator_coverage annotation
        //-----------------------------------------------------------------------------
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017-2018 Cisco Systems, Inc.
        // Copyright 2014-2020 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2018 Qualcomm, Inc.
        // Copyright 2013-2018 Synopsys, Inc.
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
        //-----------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_comparer.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_comparer
        //
        // The uvm_comparer class provides a policy object for doing comparisons. The
        // policies determine how miscompares are treated and counted. Results of a
        // comparison are stored in the comparer object. The <uvm_object::compare>
        // and <uvm_object::do_compare> methods are passed a uvm_comparer policy
        // object.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 16.3.1
        class uvm_comparer extends uvm_policy;
            
           // @uvm-ieee 1800.2-2020 auto 16.3.2.3
%000000    `uvm_object_utils(uvm_comparer)
        
          // @uvm-ieee 1800.2-2020 auto 16.3.2.2
          extern virtual function void flush();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.5
          extern virtual function uvm_policy::recursion_state_e object_compared(
             uvm_object lhs,
             uvm_object rhs,
             uvm_recursion_policy_enum recursion,
             output bit ret_val
          );
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.8
          extern virtual function string get_miscompares();
        
          extern virtual function int unsigned get_result();
        
          extern virtual function void set_result(int unsigned result) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.3.4.1
          extern virtual function void set_recursion_policy( uvm_recursion_policy_enum policy);
        
          // @uvm-ieee 1800.2-2020 auto 16.3.4.1
          extern virtual function uvm_recursion_policy_enum get_recursion_policy();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.4.2
          extern virtual function void set_check_type( bit enabled );
        
          // @uvm-ieee 1800.2-2020 auto 16.3.4.2
          extern virtual function bit get_check_type();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.5.1
          extern virtual function void set_show_max (int unsigned show_max);
        
          extern virtual function int unsigned get_show_max ();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.5.2
          extern virtual function void set_verbosity (int unsigned verbosity);
        
          extern virtual function int unsigned get_verbosity ();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.5.3
          extern virtual function void set_severity (uvm_severity severity);
        
          // @uvm-ieee 1800.2-2020 auto 16.3.5.3
          extern virtual function uvm_severity get_severity ();
        
          // @uvm-ieee 1800.2-2020 auto 16.3.6
          extern virtual function void set_threshold (int unsigned threshold);
        
          extern virtual function int unsigned get_threshold ();
        
          //@uvm-compat
%000003   bit physical = 1;
        
          //@uvm-compat
%000003   bit abstract = 1 ;
        
          typedef struct {
             recursion_state_e state;
             bit ret_val;
          } state_info_t ;
          state_info_t m_recur_states[uvm_object /*LHS*/][uvm_object /*RHS*/][uvm_recursion_policy_enum /*recursion*/];
        
          // Variable -- NODOCS -- policy
          //
          // Determines whether comparison is UVM_DEEP, UVM_REFERENCE, or UVM_SHALLOW.
          // @uvm-compat , for compatibility with 1.2
%000003   uvm_recursion_policy_enum policy = UVM_DEFAULT_POLICY;
        
          // Variable -- NODOCS -- show_max
          //
          // Sets the maximum number of messages to send to the printer for miscompares
          // of an object. 
        
          // @uvm-compat , for compatibility with 1.2
%000003   int unsigned show_max = 1;
        
          // Variable -- NODOCS -- verbosity
          //
          // Sets the verbosity for printed messages. 
          //
          // The verbosity setting is used by the messaging mechanism to determine
          // whether messages should be suppressed or shown.
        
          // @uvm-compat , for compatibility with 1.2
%000003   int unsigned verbosity = UVM_LOW;
        
        
          // Variable -- NODOCS -- sev
          //
          // Sets the severity for printed messages. 
          //
          // The severity setting is used by the messaging mechanism for printing and
          // filtering messages.
        
          // @uvm-compat , for compatibility with 1.2
%000003   uvm_severity sev = UVM_INFO;
        
        
          // Variable -- NODOCS -- miscompares
          //
          // This string is reset to an empty string when a comparison is started. 
          //
          // The string holds the last set of miscompares that occurred during a
          // comparison.
        
          // @uvm-compat , for compatibility with 1.2
%000003   string miscompares = "";
        
          // Variable -- NODOCS -- check_type
          //
          // This bit determines whether the type, given by <uvm_object::get_type_name>,
          // is used to verify that the types of two objects are the same. 
          //
          // This bit is used by the <compare_object> method. In some cases it is useful
          // to set this to 0 when the two operands are related by inheritance but are
          // different types.
        
          // @uvm-compat , for compatibility with 1.2
%000003   bit check_type = 1;
        
          // Variable -- NODOCS -- result
          // 
          // This bit stores the number of miscompares for a given compare operation.
          // You can use the result to determine the number of miscompares that
          // were found.
        
          // @uvm-compat , for compatibility with 1.2
%000003   int unsigned result = 0;
        
          local int unsigned m_threshold;
        
            // @uvm-ieee 1800.2-2020 auto 16.3.2.1
%000003     function new(string name="");
%000003        super.new(name);
%000003        m_threshold = 1;
            endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 16.3.2.4
%000000   static function void set_default (uvm_comparer comparer) ;
%000000      uvm_coreservice_t coreservice ;
%000000      coreservice = uvm_coreservice_t::get() ;
%000000      coreservice.set_default_comparer(comparer) ;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 16.3.2.5
 000257   static function uvm_comparer get_default () ;
 000257      uvm_coreservice_t coreservice ;
 000257      coreservice = uvm_coreservice_t::get() ;
 000257      return coreservice.get_default_comparer() ;
          endfunction
        
           
          // Function -- NODOCS -- compare_field
          //
          // Compares two integral values. 
          //
          // The ~name~ input is used for purposes of storing and printing a miscompare.
          //
          // The left-hand-side ~lhs~ and right-hand-side ~rhs~ objects are the two
          // objects used for comparison. 
          //
          // The size variable indicates the number of bits to compare; size must be
          // less than or equal to 4096. 
          //
          // The radix is used for reporting purposes, the default radix is hex.
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.1
%000000   virtual function bit compare_field (string name, 
                                              uvm_bitstream_t lhs, 
                                              uvm_bitstream_t rhs, 
                                              int size,
                                              uvm_radix_enum radix=UVM_NORADIX); 
%000000     uvm_bitstream_t mask;
%000000     string msg;
          
%000000     if(size <= 64) begin
              
%000000       return compare_field_int(name, lhs, rhs, size, radix);
            end
        
          
%000000     mask = -1;
%000000     mask >>= (UVM_STREAMBITS-size);
%000000     if((lhs & mask) !== (rhs & mask)) begin
%000000       case (radix)
%000000         UVM_BIN: begin
%000000           $swrite(msg, "%s: lhs = 'b%0b : rhs = 'b%0b", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_OCT: begin
%000000           $swrite(msg, "%s: lhs = 'o%0o : rhs = 'o%0o", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_DEC: begin
%000000           $swrite(msg, "%s: lhs = %0d : rhs = %0d", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_TIME: begin
%000000           $swrite(msg, "%s: lhs = %0t : rhs = %0t", 
%000000                name, lhs&mask, rhs&mask);
                end
%000000         UVM_STRING: begin
%000000           $swrite(msg, "%s: lhs = %0s : rhs = %0s", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_ENUM: begin
                  //Printed as decimal, user should cuse compare string for enum val
%000000           $swrite(msg, "%s: lhs = %0d : rhs = %0d", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         default: begin
%000000           $swrite(msg, "%s: lhs = 'h%0x : rhs = 'h%0x", 
%000000                        name, lhs&mask, rhs&mask);
                end
              endcase
%000000       print_msg(msg);
%000000       return 0;
            end
%000000     return 1;
          endfunction
        
          
          
          // Function -- NODOCS -- compare_field_int
          //
          // This method is the same as <compare_field> except that the arguments are
          // small integers, less than or equal to 64 bits. It is automatically called
          // by <compare_field> if the operand size is less than or equal to 64.
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.2
%000000   virtual function bit compare_field_int (string name, 
                                                  uvm_integral_t lhs, 
                                                  uvm_integral_t rhs, 
                                                  int size,
                                                  uvm_radix_enum radix=UVM_NORADIX); 
%000000     logic [63:0] mask;
%000000     string msg;
%000000     if(size > 64) begin
%000000       `uvm_error("UVM/COMPARER/INT/BAD_SIZE",$sformatf("compare_field_int cannot be called with operand size of more than 64 bits. Input argument size=%0d",size))
%000000       return 0;
            end
            
%000000     mask = -1;
%000000     mask >>= (64-size);
%000000     if((lhs & mask) !== (rhs & mask)) begin
%000000       case (radix)
%000000         UVM_BIN: begin
%000000           $swrite(msg, "%s: lhs = 'b%0b : rhs = 'b%0b", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_OCT: begin
%000000           $swrite(msg, "%s: lhs = 'o%0o : rhs = 'o%0o", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_DEC: begin
%000000           $swrite(msg, "%s: lhs = %0d : rhs = %0d", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_TIME: begin
%000000           $swrite(msg, "%s: lhs = %0t : rhs = %0t", 
%000000                name, lhs&mask, rhs&mask);
                end
%000000         UVM_STRING: begin
%000000           $swrite(msg, "%s: lhs = %0s : rhs = %0s", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         UVM_ENUM: begin
                  //Printed as decimal, user should cuse compare string for enum val
%000000           $swrite(msg, "%s: lhs = %0d : rhs = %0d", 
%000000                        name, lhs&mask, rhs&mask);
                end
%000000         default: begin
%000000           $swrite(msg, "%s: lhs = 'h%0x : rhs = 'h%0x", 
%000000                        name, lhs&mask, rhs&mask);
                end
              endcase
%000000       print_msg(msg);
%000000       return 0;
            end
%000000     return 1;
          endfunction
        
        
          // Function -- NODOCS -- compare_field_real
          //
          // This method is the same as <compare_field> except that the arguments are
          // real numbers.
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.3
%000000   virtual function bit compare_field_real (string name, 
                                                  real lhs, 
                                                  real rhs);
%000000     string msg;
          
%000000     if(lhs != rhs) begin
%000000       $swrite(msg, name, ": lhs = ", lhs, " : rhs = ", rhs);
%000000       print_msg(msg);
%000000       return 0;
            end
%000000     return 1;
          endfunction
        
          // Stores the passed-in names of the objects in the hierarchy
          local string m_object_names[$];
%000000   local function string m_current_context(string name="");
%000000     if (m_object_names.size()  == 0) begin
              
%000000       return name;
            end
         //??
%000000     else if ((m_object_names.size() == 1) && (name=="")) begin
              
%000000       return m_object_names[0];
            end
        
%000000     else begin
%000000       string     full_name;
%000000       foreach(m_object_names[i]) begin
%000000         if (i == m_object_names.size() - 1) begin
                  
%000000           full_name = {full_name, m_object_names[i]};
                end
        
%000000         else begin
                  
%000000           full_name  = {full_name, m_object_names[i], "."};
                end
        
              end
%000000       if (name != "") begin
                
%000000         return {full_name, ".", name};
              end
        
%000000       else begin
                
%000000         return full_name;
              end
        
            end
          endfunction : m_current_context
          
          // Function -- NODOCS -- compare_object
          //
          // Compares two class objects using the <policy> knob to determine whether the
          // comparison should be deep, shallow, or reference. 
          //
          // The name input is used for purposes of storing and printing a miscompare. 
          //
          // The ~lhs~ and ~rhs~ objects are the two objects used for comparison. 
          //
          // The ~check_type~ determines whether or not to verify the object
          // types match (the return from ~lhs.get_type_name()~ matches
          // ~rhs.get_type_name()~).
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.4
 000257   virtual function bit compare_object (string name,
                                               uvm_object lhs,
                                               uvm_object rhs);
 000257     int old_result ;
 000257     uvm_field_op field_op ;
 000257     uvm_policy::recursion_state_e prev_state;
 000257     bit ret_val = 1;
        
            // Fast Pass
~000257     if (rhs == lhs) begin
              
%000000       return ret_val;
            end
        
        
            // Push the name on the stack
 000257     m_object_names.push_back(name);
        
            // Reference Fail
~000257     if (policy == UVM_REFERENCE && lhs != rhs) begin
%000000       print_msg_object(lhs, rhs);
%000000       ret_val = 0;
            end
        
            // Fast fail on null
~000257     if (ret_val && (rhs == null || lhs == null)) begin
%000000       print_msg_object(lhs, rhs);
              // if ((get_active_object_depth() == 0) && (lhs != null)) begin
              //   uvm_report_info("MISCMP",
              //                   $sformatf("%0d Miscompare(s) for object %s@%0d vs. null", 
              //                             result, 
              //                             lhs.get_name(),
              //                             lhs.get_inst_id()),
              //                   get_verbosity());
              // end
%000000       ret_val = 0;
            end
        
            // Hierarchical comparison
~000257     if (ret_val) begin
              // Warn on possible infinite loop
 000257       prev_state      = object_compared(lhs,rhs,get_recursion_policy(),ret_val);
~000257       if (prev_state != uvm_policy::NEVER) begin
                
                `uvm_warning("UVM/COPIER/LOOP", {"Possible loop when comparing '", 
%000000         lhs.get_full_name(), "' to '", rhs.get_full_name(), "'"})
              end    
        
 000257       push_active_object(lhs);
 000257       m_recur_states[lhs][rhs][get_recursion_policy()]  = '{uvm_policy::STARTED,0};
 000257       old_result = get_result();
        
              // Check typename
              // Implemented as if Mantis 6602 was accepted
~000257       if (get_check_type() && (lhs.get_object_type() != rhs.get_object_type())) begin
%000000         if(lhs.get_type_name() != rhs.get_type_name()) begin
%000000           print_msg({"type: lhs = \"", lhs.get_type_name(), "\" : rhs = \"", rhs.get_type_name(), "\""});
                end
%000000         else begin
%000000           print_msg({"get_object_type() for ",lhs.get_name()," does not match get_object_type() for ",rhs.get_name()}); 
                end  
              end
        
 000257       field_op = uvm_field_op::m_get_available_op();
 000257       field_op.set(UVM_COMPARE,this,rhs);
 000257       lhs.do_execute_op(field_op);
~000257       if (field_op.user_hook_enabled()) begin
 000257         ret_val = lhs.do_compare(rhs,this);
              end
 000257       field_op.m_recycle();
        
              // If do_compare() returned 1, check for a change
              // in the result count.
~000257       if (ret_val && (get_result() > old_result)) begin
                
%000000         ret_val = 0;
              end
        
        
              // Save off the comparison result
 000257       m_recur_states[lhs][rhs][get_recursion_policy()]  = '{uvm_policy::FINISHED,ret_val};
 000257       void'(pop_active_object());
            end // if (ret_val)
        
            // Pop the name off the stack
 000257     void'(m_object_names.pop_back());
        
            // Only emit a message on a miscompare, and only if
            // we're at the top level
~000257     if (!ret_val && (get_active_object_depth() == 0)) begin
%000000       string msg ;
        
              // If there are stored results
%000000       if(get_result()) begin
                // If there's a display limit that we've hit
%000000         if (get_show_max() && (get_show_max() < get_result())) begin 
                  
%000000           $swrite(msg, "%0d Miscompare(s) (%0d shown) for object ",
%000000                   result, show_max);
                end
        
                // Else there's either no limit, or we didn't hit it
%000000         else begin
                  
%000000           $swrite(msg, "%0d Miscompare(s) for object ", result);
                end
        
              end
        
%000000       uvm_pkg::uvm_report(sev, "MISCMP", $sformatf("%s%s@%0d vs. %s@%0d", msg,
%000000                                                    (lhs == null) ? "<null>" : lhs.get_name(), 
%000000                                                    (lhs == null) ? 0 : lhs.get_inst_id(), 
%000000                                                    (rhs == null) ? "<null>" : rhs.get_name(), 
%000000                                                    (rhs == null) ? 0 : rhs.get_inst_id()),
%000000               get_verbosity(), `uvm_file, `uvm_line);
                
            end // if (!ret_val && (get_active_object_depth() == 1))
            
 000257     return ret_val;
          endfunction
          
          
          // Function -- NODOCS -- compare_string
          //
          // Compares two string variables. 
          //
          // The ~name~ input is used for purposes of storing and printing a miscompare. 
          //
          // The ~lhs~ and ~rhs~ objects are the two objects used for comparison.
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.6
%000000   virtual function bit compare_string (string name,
                                               string lhs,
                                               string rhs);
%000000     string msg;
%000000     if(lhs != rhs) begin
%000000       msg = { name, ": lhs = \"", lhs, "\" : rhs = \"", rhs, "\""};
%000000       print_msg(msg);
%000000       return 0;
            end
%000000     return 1;
          endfunction
        
        
          // Function -- NODOCS -- print_msg
          //
          // Causes the error count to be incremented and the message, ~msg~, to be
          // appended to the <miscompares> string (a newline is used to separate
          // messages). 
          //
          // If the message count is less than the <show_max> setting, then the message
          // is printed to standard-out using the current verbosity and severity
          // settings. See the <verbosity> and <sev> variables for more information.
        
          // @uvm-ieee 1800.2-2020 auto 16.3.3.7
%000000   function void print_msg (string msg);
             
%000000     string tmp = m_current_context(msg);
%000000     result++;
%000000     if((get_show_max() == 0) ||
%000000        (get_result() <= get_show_max())) begin
%000000       msg = {"Miscompare for ", tmp};
%000000       uvm_pkg::uvm_report(sev, "MISCMP", msg, get_verbosity(), `uvm_file, `uvm_line);
            end
%000000     miscompares = { miscompares, tmp, "\n" };
          endfunction
        
        
        
          // Internal methods - do not call directly
        
          // print_msg_object
          // ----------------
        
%000000   function void print_msg_object(uvm_object lhs, uvm_object rhs);
%000000     string tmp = $sformatf("%s: lhs = @%0d : rhs = @%0d",
%000000                            m_current_context(), 
%000000                            (lhs != null ? lhs.get_inst_id() : 0),     
%000000                            (rhs != null ? rhs.get_inst_id() : 0));
%000000     result++;
            
%000000     if((get_show_max() == 0) ||
%000000        (get_result() <= get_show_max())) begin
%000000       uvm_pkg::uvm_report(sev, 
%000000                            "MISCMP", 
%000000                            {"Miscompare for ", tmp}, 
%000000                            get_verbosity(), 
%000000                            `uvm_file, 
%000000                            `uvm_line);
            end
        
%000000     miscompares = { miscompares, tmp, "\n" };
          endfunction
        
          int depth;                      //current depth of objects
          bit compare_map[uvm_object][uvm_object];
        
        endclass
        
 000257 function void uvm_comparer::flush();
 000257   miscompares = "" ;
 000257   check_type = 1 ;
 000257   result = 0 ;
 000257   m_recur_states.delete();
        endfunction
        
 000257 function uvm_policy::recursion_state_e uvm_comparer::object_compared(
          uvm_object lhs,
          uvm_object rhs,
          uvm_recursion_policy_enum recursion,
 000257   output bit ret_val
        );
%000000   if (!m_recur_states.exists(lhs)) begin
%000000     return NEVER ;
          end
        
%000000   else if (!m_recur_states[lhs].exists(rhs)) begin
%000000     return NEVER ;
          end
        
%000000   else if (!m_recur_states[lhs][rhs].exists(recursion)) begin
%000000     return NEVER ;
          end
        
%000000   else begin
%000000     if (m_recur_states[lhs][rhs][recursion].state == FINISHED) begin 
                
%000000       ret_val = m_recur_states[lhs][rhs][recursion].ret_val;
            end
        
%000000     return m_recur_states[lhs][rhs][recursion].state ;
          end
        endfunction
        
%000000 function string uvm_comparer::get_miscompares();
%000000    return miscompares ;
        endfunction
        
 002313 function int unsigned uvm_comparer::get_result();
 002313    return result ;
        endfunction
        
%000000 function void uvm_comparer::set_result(int unsigned result);
%000000    this.result = result ;
        endfunction
        
%000000 function void uvm_comparer::set_recursion_policy( uvm_recursion_policy_enum policy);
%000000    this.policy = policy ;
        endfunction
        
 000771 function uvm_recursion_policy_enum uvm_comparer::get_recursion_policy();
 000771    return policy ;
        endfunction
        
%000000 function void uvm_comparer::set_check_type( bit enabled );
%000000    check_type = enabled ;
        endfunction
        
 000257 function bit uvm_comparer::get_check_type();
 000257    return check_type ;
        endfunction
        
%000000 function void uvm_comparer::set_show_max (int unsigned show_max);
%000000    this.show_max = show_max ;
        endfunction
        
%000000 function int unsigned uvm_comparer::get_show_max();
%000000    return show_max ;
        endfunction
        
%000000 function void uvm_comparer::set_verbosity (int unsigned verbosity);
%000000    this.verbosity = verbosity ;
        endfunction
        
%000000 function int unsigned uvm_comparer::get_verbosity();
%000000    return verbosity ;
        endfunction
        
%000000 function void uvm_comparer::set_severity (uvm_severity severity);
%000000    sev = severity ;
        endfunction
        
%000000 function uvm_severity uvm_comparer::get_severity();
%000000    return sev ;
        endfunction
        
%000000 function void uvm_comparer::set_threshold (int unsigned threshold);
%000000    m_threshold = threshold;
        endfunction
        
 002570 function int unsigned uvm_comparer::get_threshold();
 002570    return m_threshold;
        endfunction
        
        
