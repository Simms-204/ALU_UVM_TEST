//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2010-2018 AMD
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
        // Copyright 2021-2023 Marvell International Ltd.
        // Copyright 2010-2018 Mentor Graphics Corporation
        // Copyright 2013-2026 NVIDIA Corporation
        // Copyright 2011 Synopsys, Inc.
        // Copyright 2020 Verific
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
        // $File:     src/base/uvm_cmdline_processor.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
%000000 class uvm_cmd_line_verb;
          string comp_path;
          string id;
          uvm_verbosity verb;
          int exec_time;
        endclass
        
        // TITLE: Command Line Debug
        //
        // Debug command line plusargs that are available in the Accellera reference implementation
        // but not documented in the IEEE UVM 1800.2-2020 LRM
        //
        
        // Variable: +UVM_DUMP_CMDLINE_ARGS
        //
        // ~+UVM_DUMP_CMDLINE_ARGS~ allows the user to dump all command line arguments to the
        // reporting mechanism.  The output in is tree format.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        
        // Variable: +UVM_PHASE_TRACE
        //
        // ~+UVM_PHASE_TRACE~ turns on tracing of phase executions.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        // Variable: +UVM_OBJECTION_TRACE
        //
        // ~+UVM_OBJECTION_TRACE~ turns on tracing of objection activity.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        // Variable: +UVM_RESOURCE_DB_TRACE
        //
        // ~+UVM_RESOURCE_DB_TRACE~ turns on tracing of resource DB accesses.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        // Variable: +UVM_CONFIG_DB_TRACE
        //
        // ~+UVM_CONFIG_DB_TRACE~ turns on tracing of configuration DB accesses.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        // TITLE: Command line configuration
        //
        // The following argument is provided in addition to those required by IEEE UVM 1800.2-2020.
        //
        
        // Variable: +uvm_set_config_bitstream
        // 
        // ~+uvm_set_config_bitstream=<comp>,<field>,<value>~ works like its
        // procedural counterpart <uvm_config_db#(uvm_bitstream_t)::set()>. The string ~value~
        // is interpreted using the same rules as uvm_bit_vector_utils#(uvm_bitstream_t)::from_string().
        // 
        // Note that unlike <+uvm_set_config_int>, the Accellera implementation of
        // ~+uvm_set_config_bitstream~ is capable storing values that exceed 32 bits in size.
        // This means the two yield different results for 32 bit values when bit 32 is set, 
        // as <+uvm_set_config_int> treats bit 32 as the sign bit.
        //
        // For example:
        //| // +uvm_set_config_int=uvm_test_top.soc_env,valA,'hFFFF_FFFF
        //| // +uvm_set_config_bitstream=uvm_test_top.soc_env,valB,'hFFFF_FFFF
        //|
        //| longint valA, valB;
        //| uvm_config_int::get(uvm_test_top.soc_env, "", "valA", valA); // 64'hFFFF_FFFF_FFFF_FFFF
        //| uvm_config_int::get(uvm_test_top.soc_env, "", "valB", valB); // 64'h0000_0000_FFFF_FFFF
        //
        // Additionally, note that if the ~value~ passed on the command line is larger than 
        // the maximum value that can be stored in a <uvm_bitstream_t> then truncation without 
        // warning may occur.  
        
        // The implementation of this is in uvm_root.
        
        
        typedef class uvm_cmdline_processor;
        
        // @uvm-compat , for compatibility with 1.2
        uvm_cmdline_processor uvm_cmdline_proc;
        
        
        // Class -- NODOCS -- uvm_cmdline_processor
        //
        // This class provides an interface to the command line arguments that 
        // were provided for the given simulation.  The class is intended to be
        // used as a singleton, but that isn't required.  The generation of the
        // data structures which hold the command line argument information 
        // happens during construction of the class object.  A global variable 
        // called ~uvm_cmdline_proc~ is created at initialization time and may 
        // be used to access command line information.
        //
        // The uvm_cmdline_processor class also provides support for setting various UVM
        // variables from the command line such as components' verbosities and configuration
        // settings for integral types and strings.  Each of these capabilities is described 
        // in the Built-in UVM Aware Command Line Arguments section.
        //
        
        // @uvm-ieee 1800.2-2020 auto G.1.1
        class uvm_cmdline_processor extends uvm_report_object;
        
          static local uvm_cmdline_processor m_inst;
        
          // Group -- NODOCS -- Singleton 
        
          // Function -- NODOCS -- get_inst
          //
          // Returns the singleton instance of the UVM command line processor.
        
          // @uvm-ieee 1800.2-2020 auto G.1.2
 000207   static function uvm_cmdline_processor get_inst();
~000204     if(m_inst == null) begin
              
%000003       m_inst = new("uvm_cmdline_proc");
            end
        
 000207     uvm_cmdline_proc = m_inst;
 000207     return m_inst;
          endfunction
        
          protected string m_argv[$]; 
          protected string m_plus_argv[$];
          protected string m_uvm_argv[$];
        
          // Group -- NODOCS -- Basic Arguments
          
          // Function -- NODOCS -- get_args
          //
          // This function returns a queue with all of the command line
          // arguments that were used to start the simulation. Note that
          // element 0 of the array will always be the name of the 
          // executable which started the simulation.
        
          // @uvm-ieee 1800.2-2020 auto G.1.3.1
%000000   function void get_args (output string args[$]);
%000000     args = m_argv;
          endfunction
        
          // Function -- NODOCS -- get_plusargs
          //
          // This function returns a queue with all of the plus arguments
          // that were used to start the simulation. Plusarguments may be
          // used by the simulator vendor, or may be specific to a company
          // or individual user. Plusargs never have extra arguments
          // (i.e. if there is a plusarg as the second argument on the
          // command line, the third argument is unrelated); this is not
          // necessarily the case with vendor specific dash arguments.
        
          // @uvm-ieee 1800.2-2020 auto G.1.3.2
%000000   function void get_plusargs (output string args[$]);
%000000     args = m_plus_argv;
          endfunction
        
          // Function -- NODOCS -- get_uvmargs
          //
          // This function returns a queue with all of the uvm arguments
          // that were used to start the simulation. A UVM argument is
          // taken to be any argument that starts with a - or + and uses
          // the keyword UVM (case insensitive) as the first three
          // letters of the argument.
        
          // @uvm-ieee 1800.2-2020 auto G.1.3.3
%000000   function void get_uvm_args (output string args[$]);
%000000     args = m_uvm_argv;
          endfunction
        
          // Function -- NODOCS -- get_arg_matches
          //
          // This function loads a queue with all of the arguments that
          // match the input expression and returns the number of items
          // that matched. If the input expression is bracketed
          // with //, then it is taken as an extended regular expression 
          // otherwise, it is taken as the beginning of an argument to match.
          // For example:
          //
          //| string myargs[$]
          //| initial begin
          //|    void'(uvm_cmdline_proc.get_arg_matches("+foo",myargs)); //matches +foo, +foobar
          //|                                                            //doesn't match +barfoo
          //|    void'(uvm_cmdline_proc.get_arg_matches("/foo/",myargs)); //matches +foo, +foobar,
          //|                                                             //foo.sv, barfoo, etc.
          //|    void'(uvm_cmdline_proc.get_arg_matches("/^foo.*\.sv",myargs)); //matches foo.sv
          //|                                                                   //and foo123.sv,
          //|                                                                   //not barfoo.sv.
        
          // @uvm-ieee 1800.2-2020 auto G.1.3.4
 000072   function int get_arg_matches (string match, ref string args[$]);
~000072     bit match_is_regex = (match.len() > 2) && (match[0] == "/") && (match[match.len()-1] == "/");
 000072     int len = match.len();
        
 000072     args.delete();
~000072     foreach (m_argv[i]) begin
%000000       if ( match_is_regex && uvm_is_match( match, m_argv[i] ) ) begin
%000000         args.push_back( m_argv[i] );
              end
%000000       else if((m_argv[i].len() >= len) && (m_argv[i].substr(0,len - 1) == match)) begin
%000000         args.push_back(m_argv[i]);
              end
            end
        
 000072     return args.size();
          endfunction
        
        
          // Group -- NODOCS -- Argument Values
        
          // Function -- NODOCS -- get_arg_value
          //
          // This function finds the first argument which matches the ~match~ arg and
          // returns the suffix of the argument. This is similar to the $value$plusargs
          // system task, but does not take a formatting string. The return value is
          // the number of command line arguments that match the ~match~ string, and
          // ~value~ is the value of the first match.
          
          // @uvm-ieee 1800.2-2020 auto G.1.4.1
 000288   function int get_arg_value (string match, ref string value);
 000288     int chars = match.len();
 000288     get_arg_value = 0;
~000288     foreach (m_argv[i]) begin
%000000       if(m_argv[i].len() >= chars) begin
%000000         if(m_argv[i].substr(0,chars-1) == match) begin
%000000           get_arg_value++;
%000000           if(get_arg_value == 1) begin
                    
%000000             value = m_argv[i].substr(chars,m_argv[i].len()-1);
                  end
        
                end
              end
            end
          endfunction
        
          // Function -- NODOCS -- get_arg_values
          //
          // This function finds all the arguments which matches the ~match~ arg and
          // returns the suffix of the arguments in a list of values. The return
          // value is the number of matches that were found (it is the same as
          // values.size() ).
          // For example if '+foo=1,yes,on +foo=5,no,off' was provided on the command
          // line and the following code was executed:
          //
          //| string foo_values[$]
          //| initial begin
          //|    void'(uvm_cmdline_proc.get_arg_values("+foo=",foo_values));
          //|
          //
          // The foo_values queue would contain two entries.  These entries are shown
          // here:
          //
          //   0 - "1,yes,on"
          //   1 - "5,no,off"
          //
          // Splitting the resultant string is left to user but using the
          // uvm_string_split() function is recommended.
        
          // @uvm-ieee 1800.2-2020 auto G.1.4.2
 000015   function int get_arg_values (string match, ref string values[$]);
 000015     int chars = match.len();
        
 000015     values.delete();
~000015     foreach (m_argv[i]) begin
%000000       if(m_argv[i].len() >= chars) begin
%000000         if(m_argv[i].substr(0,chars-1) == match) begin
                  
%000000           values.push_back(m_argv[i].substr(chars,m_argv[i].len()-1));
                end
        
              end
            end
 000015     return values.size();
          endfunction
        
          // Group -- NODOCS -- Tool information
        
          // Function -- NODOCS -- get_tool_name
          //
          // Returns the simulation tool that is executing the simulation.
          // This is a vendor specific string.
        
%000000   function string get_tool_name ();
%000000     return uvm_dpi_get_tool_name();
          endfunction
        
          // Function -- NODOCS -- get_tool_version
          //
          // Returns the version of the simulation tool that is executing the simulation.
          // This is a vendor specific string.
        
%000000   function string  get_tool_version ();
%000000     return uvm_dpi_get_tool_version();
          endfunction
        
          // constructor
        
%000003   function new(string name = "");
%000003     string s;
%000003     string sub;
%000003     int doInit=1;
%000003     super.new(name);
%000000     do 
%000003       begin
%000003         s = uvm_dpi_get_next_arg(doInit);
%000003         doInit=0;
%000003         if(s!="") begin
%000000           m_argv.push_back(s);
%000000           if(s[0] == "+") begin
%000000             m_plus_argv.push_back(s);
                  end 
%000000           if(s.len() >= 4 && (s[0]=="-" || s[0]=="+")) begin
%000000             sub = s.substr(1,3);
%000000             sub = sub.toupper();
%000000             if(sub == "UVM") begin
%000000               m_uvm_argv.push_back(s);
                    end
                  end
                end
              end 
%000003     while(s!=""); 
        
          endfunction
        
%000000   function bit m_convert_verb(string verb_str, output uvm_verbosity verb_enum);
%000000     return uvm_string_to_verbosity(verb_str, verb_enum);
          endfunction
        
        endclass
        
        
