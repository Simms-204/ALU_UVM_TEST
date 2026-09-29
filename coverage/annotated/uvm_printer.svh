//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014-2018 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2020-2022 Marvell International Ltd.
        // Copyright 2007-2018 Mentor Graphics Corporation
        // Copyright 2013-2026 NVIDIA Corporation
        // Copyright 2018 Qualcomm, Inc.
        // Copyright 2014 Semifore
        // Copyright 2018 Synopsys, Inc.
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
        //   the License or the specific language governing
        //   permissions and limitations under the License.
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_printer.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        
        typedef class m_uvm_printer_knobs;
        typedef class uvm_printer_element;
        typedef class uvm_structure_proxy;
        
        //@uvm-compat provided for compatibility with 1.2
        typedef struct {
          int    level;
          string name;
          string type_name;
          string size;
          string val;
        } uvm_printer_row_info;
        
        // File: uvm_printer
          
        // @uvm-ieee 1800.2-2020 auto 16.2.1
        virtual class uvm_printer extends uvm_policy;
        
%000000    `uvm_object_abstract_utils(uvm_printer)
        
          extern function new(string name="") ;
        
          bit m_flushed ; // 0 = needs flush, 1 = flushed since last use
        
          //config values from set_* accessors are stored in knobs
        
          //@uvm-compat for compatibility with 1.2
          m_uvm_printer_knobs knobs ;
        
 243347 protected function m_uvm_printer_knobs get_knobs() ; return knobs; endfunction
        
          // Group -- NODOCS -- Methods for printer usage
        
          // These functions are called from <uvm_object::print>, or they are called
          // directly on any data to get formatted printing.
        
          extern static function void set_default(uvm_printer printer) ;
        
          extern static function uvm_printer get_default() ;
        
          // Function -- NODOCS -- print_field
          //
          // Prints an integral field (up to 4096 bits).
          //
          // name  - The name of the field.
          // value - The value of the field.
          // size  - The number of bits of the field (maximum is 4096).
          // radix - The radix to use for printing. The printer knob for radix is used
          //           if no radix is specified.
          // scope_separator - is used to find the leaf name since many printers only
          //           print the leaf name of a field.  Typical values for the separator
          //           are . (dot) or [ (open bracket).
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.8
          extern virtual function void print_field (string          name,
                                                    uvm_bitstream_t value,
                                                    int    size,
                                                    uvm_radix_enum radix=UVM_NORADIX,
                                                    byte   scope_separator=".",
                                                    string type_name="");
        
          //@uvm-compat provided for compatibility with 1.2
%000000   virtual function void print_int (string          name,
                                           uvm_bitstream_t value,
                                           int    size,
                                           uvm_radix_enum radix=UVM_NORADIX,
                                           byte   scope_separator=".",
                                           string type_name="");
%000000     print_field (name, value, size, radix, scope_separator, type_name);
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.9
          extern virtual function void print_field_int (string name,
                                                        uvm_integral_t value,
                                                        int    size,
                                                        uvm_radix_enum radix=UVM_NORADIX,
                                                        byte   scope_separator=".",
                                                        string type_name="");
        
          // Function -- NODOCS -- print_object
          //
          // Prints an object. Whether the object is recursed depends on a variety of
          // knobs, such as the depth knob; if the current depth is at or below the
          // depth setting, then the object is not recursed.
          //
          // By default, the children of <uvm_components> are printed. To turn this
          // behavior off, you must set the <uvm_component::print_enabled> bit to 0 for
          // the specific children you do not want automatically printed.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.1
          extern virtual function void print_object (string     name,
                                                     uvm_object value,
                                                     byte       scope_separator=".");
        
        
          extern virtual function void print_object_header (string name,
                                                            uvm_object value,
                                                            byte scope_separator=".");
        
        
          // Function -- NODOCS -- print_string
          //
          // Prints a string field.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.10
          extern virtual function void print_string (string name,
                                                     string value,
                                                     byte   scope_separator=".");
        
          uvm_policy::recursion_state_e m_recur_states[uvm_object][uvm_recursion_policy_enum /*recursion*/] ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.2
          extern virtual function uvm_policy::recursion_state_e object_printed ( uvm_object value,
                                                                                 uvm_recursion_policy_enum recursion);
        
          // Function -- NODOCS -- print_time
          //
          // Prints a time value. name is the name of the field, and value is the
          // value to print.
          //
          // The print is subject to the ~$timeformat~ system task for formatting time
          // values.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.11
          extern virtual function void print_time (string name,
                                                   time   value,
                                                   byte   scope_separator=".");
        
        
          // Function -- NODOCS -- print_real
          //
          // Prints a real field.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.12
          extern virtual function void print_real (string  name,
                                                   real    value,
                                                   byte    scope_separator=".");
        
          // Function -- NODOCS -- print_generic
          //
          // Prints a field having the given ~name~, ~type_name~, ~size~, and ~value~.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.3
          extern virtual function void print_generic (string  name,
                                                      string  type_name,
                                                      int     size,
                                                      string  value,
                                                      byte    scope_separator=".");
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.4
          extern virtual function void print_generic_element (string  name,
                                                              string  type_name,
                                                              string  size,
                                                              string  value);
        
          // Group -- NODOCS -- Methods for printer subtyping
        
          // Function -- NODOCS -- emit
          //
          // Emits a string representing the contents of an object
          // in a format defined by an extension of this object.
        
          extern virtual function string emit ();
        
          extern virtual function void flush ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.1
          extern virtual function void set_name_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.1
          extern virtual function bit get_name_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.2
          extern virtual function void set_type_name_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.2
          extern virtual function bit get_type_name_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.3
          extern virtual function void set_size_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.3
          extern virtual function bit get_size_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.4
          extern virtual function void set_id_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.4
          extern virtual function bit get_id_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.5
          extern virtual function void set_radix_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.5
          extern virtual function bit get_radix_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.6
          extern virtual function void set_radix_string (uvm_radix_enum radix, string prefix);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.6
          extern virtual function string get_radix_string (uvm_radix_enum radix);
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.7
          extern virtual function void set_default_radix (uvm_radix_enum radix);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.7
          extern virtual function uvm_radix_enum get_default_radix ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.8
          extern virtual function void set_root_enabled (bit enabled);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.8
          extern virtual function bit get_root_enabled ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.9
          extern virtual function void set_recursion_policy (uvm_recursion_policy_enum policy);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.9
          extern virtual function uvm_recursion_policy_enum get_recursion_policy ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.10
          extern virtual function void set_max_depth (int depth);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.10
          extern virtual function int get_max_depth ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.11
          extern virtual function void set_file (UVM_FILE fl);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.11
          extern virtual function UVM_FILE get_file ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.5.12
          extern virtual function void set_line_prefix (string prefix);
          // @uvm-ieee 1800.2-2020 auto 16.2.5.12
          extern virtual function string get_line_prefix ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.6
          extern virtual function void set_begin_elements (int elements = 5);
          // @uvm-ieee 1800.2-2020 auto 16.2.6
          extern virtual function int get_begin_elements ();
          // @uvm-ieee 1800.2-2020 auto 16.2.6
          extern virtual function void set_end_elements (int elements = 5);
          // @uvm-ieee 1800.2-2020 auto 16.2.6
          extern virtual function int get_end_elements ();
        
          local uvm_printer_element m_element_stack[$] ;
        
 076452   protected function int m_get_stack_size(); return m_element_stack.size(); endfunction
        
          // @uvm-ieee 1800.2-2020 auto 16.2.7.1
          extern protected virtual function uvm_printer_element get_bottom_element ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.7.2
          extern protected virtual function uvm_printer_element get_top_element ();
        
          // @uvm-ieee 1800.2-2020 auto 16.2.7.3
          extern virtual function void push_element ( string name,
                                                      string type_name,
                                                      string size,
                                                      string value=""
          );
        
          // @uvm-ieee 1800.2-2020 auto 16.2.7.4
          extern virtual function void pop_element ();
        
          // return an element from the recycled stack if available or a new one otherwise
          extern function uvm_printer_element get_unused_element() ;
        
          // store element instances that have been created but are not currently on the stack
          uvm_printer_element m_recycled_elements[$];
        
          // Function -- NODOCS -- print_array_header
          //
          // Prints the header of an array. This function is called before each
          // individual element is printed. <print_array_footer> is called to mark the
          // completion of array printing.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.5
          extern virtual  function void print_array_header(string name,
                                                           int    size,
                                                           string arraytype="array",
                                                           byte   scope_separator=".");
        
          // Function -- NODOCS -- print_array_range
          //
          // Prints a range using ellipses for values. This method is used when honoring
          // the array knobs for partial printing of large arrays,
          // <m_uvm_printer_knobs::begin_elements> and <m_uvm_printer_knobs::end_elements>.
          //
          // This function should be called after begin_elements have been printed
          // and before end_elements have been printed.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.6
          extern virtual function void print_array_range (int min, int max);
        
        
          // Function -- NODOCS -- print_array_footer
          //
          // Prints the header of a footer. This function marks the end of an array
          // print. Generally, there is no output associated with the array footer, but
          // this method let's the printer know that the array printing is complete.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.3.7
          extern virtual  function void print_array_footer (int size = 0);
        
          // Compat methods
        
          //@uvm-compat provided for compatibility with 1.2
 076452   virtual function string format_row (uvm_printer_row_info row);
 076452     return "";
          endfunction
        
          //@uvm-compat provided for compatibility with 1.2
 007238   virtual function string format_header();
 007238     return "";
          endfunction
        
          //@uvm-compat provided for compatibility with 1.2
 007238   virtual function string format_footer();
 007238     return "";
          endfunction
        
          //@uvm-compat provided for compatibility with 1.2
 062380   virtual protected function string adjust_name (string id,
                                                         byte scope_separator=".");
~062380     if (get_root_enabled() &&
                istop() ||
                knobs.full_name ||
%000000         id == "...") begin
              
%000000       return id;
            end
        
 062380     return uvm_leaf_scope(id, scope_separator);
          endfunction
        
          // Utility methods
          extern  function bit istop ();
          extern  function string index_string (int index, string name="");
        
          string m_string;
        
        endclass
        
        // @uvm-ieee 1800.2-2020 auto 16.2.8.1
        class uvm_printer_element extends uvm_object;
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.1
           extern function new (string name="");
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.2
           extern virtual function void set (string element_name = "",
                                             string element_type_name = "",
                                             string element_size = "",
                                             string element_value = ""
           );
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.3
           extern virtual function void set_element_name (string element_name);
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.3
           extern virtual function string get_element_name ();
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.4
           extern virtual function void set_element_type_name (string element_type_name);
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.4
           extern virtual function string get_element_type_name ();
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.5
           extern virtual function void set_element_size (string element_size);
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.5
           extern virtual function string get_element_size ();
        
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.6
           extern virtual function void set_element_value (string element_value);
           // @uvm-ieee 1800.2-2020 auto 16.2.8.2.6
           extern virtual function string get_element_value ();
        
           extern function void add_child(uvm_printer_element child) ;
           extern function void get_children(ref uvm_printer_element children[$], input bit recurse) ;
           extern function void clear_children() ;
        
           local string m_name ;
           local string m_type_name ;
           local string m_size ;
           local string m_value ;
           local uvm_printer_element m_children[$] ;
        endclass
        
        // @uvm-ieee 1800.2-2020 auto 16.2.9.1
        class uvm_printer_element_proxy extends uvm_structure_proxy#(uvm_printer_element);
           // @uvm-ieee 1800.2-2020 auto 16.2.9.2.1
           extern function new (string name="");
           // @uvm-ieee 1800.2-2020 auto 16.2.9.2.2
           extern virtual function void get_immediate_children(uvm_printer_element s, ref uvm_printer_element children[$]);
        endclass : uvm_printer_element_proxy
        
        
        //------------------------------------------------------------------------------
        //
        // Class: uvm_table_printer
        //
        // The table printer prints output in a tabular format.
        //
        // The following shows sample output from the table printer.
        //
        //|  ---------------------------------------------------
        //|  Name        Type            Size        Value
        //|  ---------------------------------------------------
        //|  c1          container       -           @1013
        //|  d1          mydata          -           @1022
        //|  v1          integral        32          'hcb8f1c97
        //|  e1          enum            32          THREE
        //|  str         string          2           hi
        //|  value       integral        12          'h2d
        //|  ---------------------------------------------------
        //
        //------------------------------------------------------------------------------
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        // @uvm-ieee 1800.2-2020 auto 16.2.10.1
        class uvm_table_printer extends uvm_printer;
        
             // @uvm-ieee 1800.2-2020 auto 16.2.10.2.2
%000000      `uvm_object_utils(uvm_table_printer)
        
        
          // @uvm-ieee 1800.2-2020 auto 16.2.10.2.1
          extern function new(string name="");
        
          // Function -- NODOCS -- emit
          //
          // Formats the collected information from prior calls to ~print_*~
          // into table format.
          //
          extern virtual function string emit();
        
          extern virtual function string m_emit_element(uvm_printer_element element, int unsigned level);
        
          local static string m_space ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.10.2.3
          extern static function void set_default(uvm_table_printer printer) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.10.2.4
          extern static function uvm_table_printer get_default() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.10.3
          extern virtual function void set_indent(int indent) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.10.3
          extern virtual function int get_indent() ;
        
          extern virtual function void flush() ;
        
          // Variables- m_max_*
          //
          // holds max size of each column, so table columns can be resized dynamically
        
%000003   protected int m_max_name=4;
%000003   protected int m_max_type=4;
%000003   protected int m_max_size=4;
%000003   protected int m_max_value=5;
        
          extern virtual function void pop_element();
        
        
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // Class: uvm_tree_printer
        //
        // By overriding various methods of the <uvm_printer> super class,
        // the tree printer prints output in a tree format.
        //
        // The following shows sample output from the tree printer.
        //
        //|  c1: (container@1013) {
        //|    d1: (mydata@1022) {
        //|         v1: 'hcb8f1c97
        //|         e1: THREE
        //|         str: hi
        //|    }
        //|    value: 'h2d
        //|  }
        //
        //------------------------------------------------------------------------------
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        
        // @uvm-ieee 1800.2-2020 auto 16.2.11.1
        class uvm_tree_printer extends uvm_printer;
        
%000009   protected string m_newline = "\n";
          protected string m_linefeed ;
        
             // @uvm-ieee 1800.2-2020 auto 16.2.11.2.2
%000000      `uvm_object_utils(uvm_tree_printer)
          // Variable -- NODOCS -- new
          //
          // Creates a new instance of ~uvm_tree_printer~.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.2.1
          extern function new(string name="");
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.2.3
          extern static function void set_default(uvm_tree_printer printer) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.2.4
          extern static function uvm_tree_printer get_default() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.3.1
          extern virtual function void set_indent(int indent) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.3.1
          extern virtual function int get_indent() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.3.2
          extern virtual function void set_separators(string separators) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.11.3.2
          extern virtual function string get_separators() ;
        
          extern virtual function void flush() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.4.1
          extern virtual function string emit();
        
          extern virtual function string m_emit_element(uvm_printer_element element, int unsigned level);
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // Class: uvm_line_printer
        //
        // The line printer prints output in a line format.
        //
        // The following shows sample output from the line printer.
        //
        //| c1: (container@1013) { d1: (mydata@1022) { v1: 'hcb8f1c97 e1: THREE str: hi } value: 'h2d }
        //------------------------------------------------------------------------------
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        
        // @uvm-ieee 1800.2-2020 auto 16.2.12.1
        class uvm_line_printer extends uvm_tree_printer;
        
             // @uvm-ieee 1800.2-2020 auto 16.2.12.2.2
%000000      `uvm_object_utils(uvm_line_printer)
          // Variable -- NODOCS -- new
          //
          // Creates a new instance of ~uvm_line_printer~. It differs from the
          // <uvm_tree_printer> only in that the output contains no line-feeds
          // and indentation.
        
          // @uvm-ieee 1800.2-2020 auto 16.2.12.2.1
          // @uvm-ieee 1800.2-2020 auto 16.2.2.1
          extern function new(string name="");
        
          // @uvm-ieee 1800.2-2020 auto 16.2.12.2.3
          // @uvm-ieee 1800.2-2020 auto 16.2.2.2
          extern static function void set_default(uvm_line_printer printer) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.12.2.4
          // @uvm-ieee 1800.2-2020 auto 16.2.2.3
          extern static function uvm_line_printer get_default() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.12.3
          extern virtual function void set_separators(string separators) ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.12.3
          extern virtual function string get_separators() ;
        
          // @uvm-ieee 1800.2-2020 auto 16.2.4.2
          extern virtual function void flush() ;
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- m_uvm_printer_knobs
        //
        // The ~m_uvm_printer_knobs~ class defines the printer settings available to all
        // printer subtypes.
        //
        //------------------------------------------------------------------------------
        
 000012 class m_uvm_printer_knobs;
        
          // Variable -- NODOCS -- identifier
          //
          // Indicates whether <uvm_printer::adjust_name> should print the identifier. This is useful
          // in cases where you just want the values of an object, but no identifiers.
        
 000012   bit identifier = 1;
        
        
          // Variable -- NODOCS -- type_name
          //
          // Controls whether to print a field's type name.
        
 000012   bit type_name = 1;
        
        
          // Variable -- NODOCS -- size
          //
          // Controls whether to print a field's size.
        
 000012   bit size = 1;
        
        
          // Variable -- NODOCS -- depth
          //
          // Indicates how deep to recurse when printing objects.
          // A depth of -1 means to print everything.
        
 000012   int depth = -1;
        
        
          // Variable -- NODOCS -- reference
          //
          // Controls whether to print a unique reference ID for object handles.
          // The behavior of this knob is simulator-dependent.
        
 000012   bit reference = 1;
        
        
          // Variable -- NODOCS -- begin_elements
          //
          // Defines the number of elements at the head of a list to print.
          // Use -1 for no max.
        
 000012   int begin_elements = 5;
        
        
          // Variable -- NODOCS -- end_elements
          //
          // This defines the number of elements at the end of a list that
          // should be printed.
        
 000012   int end_elements = 5;
        
        
          // Variable -- NODOCS -- prefix
          //
          // Specifies the string prepended to each output line
        
 000012   string prefix = "";
        
        
          // Variable -- NODOCS -- indent
          //
          // This knob specifies the number of spaces to use for level indentation.
          // The default level indentation is two spaces.
        
 000012   int indent = 2;
        
        
          // Variable -- NODOCS -- show_root
          //
          // This setting indicates whether or not the initial object that is printed
          // (when current depth is 0) prints the full path name. By default, the first
          // object is treated like all other objects and only the leaf name is printed.
        
 000012   bit show_root = 0;
        
        
          // Variable -- NODOCS -- mcd
          //
          // This is a file descriptor, or multi-channel descriptor, that specifies
          // where the print output should be directed.
          //
          // By default, the output goes to the standard output of the simulator.
        
 000012   int mcd = UVM_STDOUT;
        
        
          // Variable -- NODOCS -- separator
          //
          // For tree printers only, determines the opening and closing
          // separators used for nested objects.
        
 000012   string separator = "{}";
        
        
          // Variable -- NODOCS -- show_radix
          //
          // Indicates whether the radix string ('h, and so on) should be prepended to
          // an integral value when one is printed.
        
 000012   bit show_radix = 1;
        
        
          // Variable -- NODOCS -- default_radix
          //
          // This knob sets the default radix to use for integral values when no radix
          // enum is explicitly supplied to the <uvm_printer::print_field> or
          // <uvm_printer::print_field_int> methods.
        
 000012   uvm_radix_enum default_radix = UVM_HEX;
        
        
          // Variable -- NODOCS -- dec_radix
          //
          // This string should be prepended to the value of an integral type when a
          // radix of <UVM_DEC> is used for the radix of the integral object.
          //
          // When a negative number is printed, the radix is not printed since only
          // signed decimal values can print as negative.
        
 000012   string dec_radix = "'d";
        
        
          // Variable -- NODOCS -- bin_radix
          //
          // This string should be prepended to the value of an integral type when a
          // radix of <UVM_BIN> is used for the radix of the integral object.
        
 000012   string bin_radix = "'b";
        
        
          // Variable -- NODOCS -- oct_radix
          //
          // This string should be prepended to the value of an integral type when a
          // radix of <UVM_OCT> is used for the radix of the integral object.
        
 000012   string oct_radix = "'o";
        
        
          // Variable -- NODOCS -- unsigned_radix
          //
          // This is the string which should be prepended to the value of an integral
          // type when a radix of <UVM_UNSIGNED> is used for the radix of the integral
          // object.
        
 000012   string unsigned_radix = "'d";
        
        
          // Variable -- NODOCS -- hex_radix
          //
          // This string should be prepended to the value of an integral type when a
          // radix of <UVM_HEX> is used for the radix of the integral object.
        
 000012   string hex_radix = "'h";
        
          uvm_recursion_policy_enum recursion_policy ;
        
          //@uvm-compat provided for compatibility with 1.2
 000012   bit header = 1;
          //@uvm-compat provided for compatibility with 1.2
 000012   bit footer = 1;
          //@uvm-compat provided for compatibility with 1.2
 000012   bit full_name = 0;
        
          //@uvm-compat provided for compatibility with 1.2
 000012   int max_width = 999;
          //@uvm-compat provided for compatibility with 1.2
 000012   string truncation = "+";
          //@uvm-compat provided for compatibility with 1.2
 000012   int name_width = -1;
          //@uvm-compat provided for compatibility with 1.2
 000012   int type_width = -1;
          //@uvm-compat provided for compatibility with 1.2
 000012   int size_width = -1;
          //@uvm-compat provided for compatibility with 1.2
 000012   int value_width = -1;
          //@uvm-compat provided for compatibility with 1.2
 000012   bit sprint = 1;
        
          //@uvm-compat provided for compatibility with 1.2
%000000   function string get_radix_str(uvm_radix_enum radix);
%000000     if(show_radix == 0) begin
%000000       return "";
            end
        
%000000     if(radix == UVM_NORADIX) begin
%000000       radix = default_radix;
            end
        
%000000     if(radix == UVM_DEC) begin
%000000       return dec_radix;
            end
        
%000000     else if(radix == UVM_BIN) begin
%000000       return bin_radix;
            end
        
%000000     else if(radix == UVM_OCT) begin
%000000       return oct_radix;
            end
        
%000000     else if(radix == UVM_UNSIGNED) begin
%000000       return unsigned_radix;
            end
        
%000000     else if(radix == UVM_HEX) begin
%000000       return hex_radix;
            end
        
%000000     return "";
          endfunction
        
        endclass
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
 000012 function uvm_printer::new(string name="");
 000012    super.new(name);
 000012    knobs = new ;
 000012    flush();
        endfunction
        
%000000 function void uvm_printer::set_default(uvm_printer printer) ;
%000000    uvm_coreservice_t coreservice ;
%000000    coreservice = uvm_coreservice_t::get() ;
%000000    coreservice.set_default_printer(printer) ;
        endfunction
        
 007238 function uvm_printer uvm_printer::get_default() ;
 007238    uvm_coreservice_t coreservice ;
 007238    coreservice = uvm_coreservice_t::get() ;
 007238    return coreservice.get_default_printer() ;
        endfunction
        
        // print_field
        // ---------
        
%000000 function void uvm_printer::print_field (string name,
                                              uvm_bitstream_t value,
                                              int size,
                                              uvm_radix_enum radix=UVM_NORADIX,
                                              byte scope_separator=".",
                                              string type_name="");
        
%000000   string sz_str, val_str;
        
%000000   if(type_name == "") begin
%000000     if(radix == UVM_TIME) begin
              
%000000       type_name ="time";
            end
        
%000000     else if(radix == UVM_STRING) begin
              
%000000       type_name ="string";
            end
        
%000000     else begin
              
%000000       type_name ="integral";
            end
        
          end
        
%000000   sz_str.itoa(size);
        
%000000   if(radix == UVM_NORADIX) begin
            
%000000     radix = get_default_radix();
          end
        
%000000   val_str = uvm_bit_vector_utils#(uvm_bitstream_t)::to_string(value, size, radix, get_radix_string(radix));
        
%000000   name = adjust_name(name,scope_separator);
        
%000000   push_element(name,type_name,sz_str,val_str);
%000000   pop_element() ;
        
        endfunction
        
        
        // print_field_int
        // ---------
        
 062380 function void uvm_printer::print_field_int (string name,
                                                    uvm_integral_t value,
                                                    int          size,
                                                    uvm_radix_enum radix=UVM_NORADIX,
                                                    byte         scope_separator=".",
 002247                                             string       type_name="");
        
 062380   string sz_str, val_str;
        
 060127   if(type_name == "") begin
 002247     if(radix == UVM_TIME) begin
              
 002247       type_name ="time";
            end
        
%000006     else if(radix == UVM_STRING) begin
              
%000000       type_name ="string";
            end
        
%000006     else begin
              
%000006       type_name ="integral";
            end
        
          end
        
 062380   sz_str.itoa(size);
        
 057880   if(radix == UVM_NORADIX) begin
            
 057880     radix = get_default_radix();
          end
        
 062380   val_str = uvm_bit_vector_utils#(uvm_integral_t)::to_string(value, size, radix, get_radix_string(radix));
        
 062380   name = adjust_name(name,scope_separator);
        
 062380   push_element(name,type_name,sz_str,val_str);
 062380   pop_element() ;
        
        endfunction
        
        
        // emit
        // ----
        
%000000 function string uvm_printer::emit ();
%000000   `uvm_error("NO_OVERRIDE","emit() method not overridden in printer subtype")
%000000   return "";
        endfunction
        
 007250 function void uvm_printer::flush ();
           // recycle all elements that were on the stack
 007250    uvm_printer_element element = get_bottom_element() ;
 007250    uvm_printer_element all_descendent_elements[$] ;
        
 007250    element = get_bottom_element() ;
 007235    if (element != null) begin
 007235      element.get_children(all_descendent_elements,1) ; //recursive
~069190      foreach (all_descendent_elements[i]) begin
 069190        m_recycled_elements.push_back(all_descendent_elements[i]) ;
 069190        all_descendent_elements[i].clear_children() ;
             end
 007235      element.clear_children();
 007235      m_recycled_elements.push_back(element) ;
             // now delete the stack
 007235      m_element_stack.delete() ;
           end
 007250    m_recur_states.delete();
 007250    m_flushed = 1 ;
        endfunction
        
%000000 function void uvm_printer::set_name_enabled (bit enabled);
%000000    knobs.identifier = enabled ;
        endfunction
 083690 function bit uvm_printer::get_name_enabled ();
 083690    return knobs.identifier ;
        endfunction
        
%000009 function void uvm_printer::set_type_name_enabled (bit enabled);
%000009    knobs.type_name = enabled ;
        endfunction
 083690 function bit uvm_printer::get_type_name_enabled ();
 083690    return knobs.type_name ;
        endfunction
        
%000009 function void uvm_printer::set_size_enabled (bit enabled);
%000009    knobs.size = enabled ;
        endfunction
 083690 function bit uvm_printer::get_size_enabled ();
 083690    return knobs.size ;
        endfunction
        
%000000 function void uvm_printer::set_id_enabled (bit enabled);
%000000    knobs.reference = enabled ;
        endfunction
 007325 function bit uvm_printer::get_id_enabled ();
 007325    return knobs.reference ;
        endfunction
        
%000000 function void uvm_printer::set_radix_enabled (bit enabled);
%000000    knobs.show_radix = enabled ;
        endfunction
%000000 function bit uvm_printer::get_radix_enabled ();
%000000    return knobs.show_radix ;
        endfunction
        
%000000 function void uvm_printer::set_radix_string (uvm_radix_enum radix, string prefix);
%000000    if (radix == UVM_DEC) begin
%000000      knobs.dec_radix = prefix ;
           end
        
%000000    else if (radix == UVM_BIN) begin
%000000      knobs.bin_radix = prefix ;
           end
        
%000000    else if (radix == UVM_OCT) begin
%000000      knobs.oct_radix = prefix ;
           end
        
%000000    else if (radix == UVM_UNSIGNED) begin
%000000      knobs.unsigned_radix = prefix ;
           end
        
%000000    else if (radix == UVM_HEX) begin
%000000      knobs.hex_radix = prefix ;
           end
        
%000000    else begin
%000000      `uvm_warning("PRINTER_UNKNOWN_RADIX",$sformatf("set_radix_string called with unsupported radix %s",radix))
           end
        endfunction
 062380 function string uvm_printer::get_radix_string (uvm_radix_enum radix);
%000000    if (radix == UVM_DEC) begin
%000000      return knobs.dec_radix ;
           end
        
%000000    else if (radix == UVM_BIN) begin
%000000      return knobs.bin_radix ;
           end
        
%000000    else if (radix == UVM_OCT) begin
%000000      return knobs.oct_radix ;
           end
        
%000000    else if (radix == UVM_UNSIGNED) begin
%000000      return knobs.unsigned_radix ;
           end
        
%000000    else if (radix == UVM_HEX) begin
%000000      return knobs.hex_radix ;
           end
        
%000000    else begin
%000000      return "";
           end
        
        endfunction
        
%000000 function void uvm_printer::set_default_radix (uvm_radix_enum radix);
%000000    knobs.default_radix = radix ;
        endfunction
 057880 function uvm_radix_enum uvm_printer::get_default_radix ();
 057880    return knobs.default_radix ;
        endfunction
        
%000000 function void uvm_printer::set_root_enabled (bit enabled);
%000000    knobs.show_root = enabled ;
        endfunction
 069618 function bit uvm_printer::get_root_enabled ();
 069618    return knobs.show_root ;
        endfunction
        
%000000 function void uvm_printer::set_recursion_policy (uvm_recursion_policy_enum policy);
%000000    knobs.recursion_policy = policy ;
        endfunction
 007325 function uvm_recursion_policy_enum uvm_printer::get_recursion_policy ();
 007325    return knobs.recursion_policy ;
        endfunction
        
%000000 function void uvm_printer::set_max_depth (int depth);
%000000    knobs.depth = depth ;
        endfunction
 007325 function int uvm_printer::get_max_depth ();
 007325    return knobs.depth ;
        endfunction
        
%000000 function void uvm_printer::set_file (UVM_FILE fl);
%000000    knobs.mcd = fl ;
        endfunction
 007238 function UVM_FILE uvm_printer::get_file ();
 007238    return knobs.mcd ;
        endfunction
        
%000000 function void uvm_printer::set_line_prefix (string prefix);
%000000    knobs.prefix = prefix ;
        endfunction
 090928 function string uvm_printer::get_line_prefix ();
 090928    return knobs.prefix ;
        endfunction
        
%000000 function void uvm_printer::set_begin_elements (int elements = 5);
%000000    knobs.begin_elements = elements ;
        endfunction
%000000 function int uvm_printer::get_begin_elements ();
%000000    return knobs.begin_elements ;
        endfunction
        
%000000 function void uvm_printer::set_end_elements (int elements = 5);
%000000    knobs.end_elements = elements ;
        endfunction
%000000 function int uvm_printer::get_end_elements ();
%000000    return knobs.end_elements ;
        endfunction
        
 021738 function uvm_printer_element uvm_printer::get_bottom_element ();
%000000    if (m_element_stack.size() > 0) begin
%000000      return m_element_stack[0] ;
           end
        
%000000    else begin
%000000      return null ;
           end
        
        endfunction
        
 152904 function uvm_printer_element uvm_printer::get_top_element ();
%000000    if (m_element_stack.size() > 0) begin
%000000      return m_element_stack[$] ;
           end
        
%000000    else begin
%000000      return null ;
           end
        
        endfunction
        
%000006 function uvm_printer_element_proxy::new (string name="");
%000006    super.new(name) ;
        endfunction
        
 076452 function void uvm_printer_element_proxy::get_immediate_children(uvm_printer_element s,
                                                                        ref uvm_printer_element children[$]);
 076452    s.get_children(children,0) ;
        endfunction
        
        
        
 076452 function void uvm_printer::push_element ( string name,
                                                  string type_name,
                                                  string size,
                                                  string value="");
 076452    uvm_printer_element element ;
 076452    uvm_printer_element parent ;
 076452    element = get_unused_element() ;
 076452    parent = get_top_element() ;
~076452    if (knobs.full_name && (parent != null)) begin
%000000      name = $sformatf("%s.%s",parent.get_element_name(),name);
           end
 076452    element.set(name,type_name,size,value);
 069214    if (parent != null) begin
 069214      parent.add_child(element) ;
           end
        
 076452    m_element_stack.push_back(element) ;
        endfunction
        
 076452 function void uvm_printer::pop_element ();
 069214    if (m_element_stack.size() > 1) begin
 069214      void'(m_element_stack.pop_back());
           end
        endfunction
        
 076452 function uvm_printer_element uvm_printer::get_unused_element() ;
 076452    uvm_printer_element element ;
 076350    if (m_recycled_elements.size() > 0) begin
 076350      element = m_recycled_elements.pop_back() ;
           end
 000102    else begin
 000102      element = new() ;
           end
 076452    return element ;
        endfunction
        
        // print_array_header
        // ------------------
        
%000006 function void uvm_printer::print_array_header (string name,
                                                       int size,
                                                       string arraytype="array",
                                                       byte scope_separator=".");
%000006   push_element(name,arraytype,$sformatf("%0d",size),"-");
        
        endfunction
        
        
        // print_array_footer
        // ------------------
        
%000006 function void  uvm_printer::print_array_footer (int size=0);
%000006   pop_element() ;
        endfunction
        
        
        // print_array_range
        // -----------------
        
%000000 function void uvm_printer::print_array_range(int min, int max);
%000000   string tmpstr;
%000000   if(min == -1 && max == -1) begin
             
%000000     return;
          end
        
%000000   if(min == -1) begin
             
%000000     min = max;
          end
        
%000000   if(max == -1) begin
             
%000000     max = min;
          end
        
%000000   if(max < min) begin
             
%000000     return;
          end
        
%000000   print_generic_element("...", "...", "...", "...");
        endfunction
        
        
        // print_object_header
        // -------------------
        
 007325 function void uvm_printer::print_object_header (string name,
                                                        uvm_object value,
                                                        byte scope_separator=".");
~007322   if(name == "") begin
            
%000003     name = "<unnamed>";
          end
        
        
 007325   push_element(name,
 007325                (value != null) ?  value.get_type_name() : "object",
 007325                "-",
~007325                get_id_enabled() ? uvm_object_value_str(value) : "-");
        endfunction
        
        
        // print_object
        // ------------
        
 007325 function void uvm_printer::print_object (string name, uvm_object value,
                                                 byte scope_separator=".");
 007325   uvm_component comp, child_comp;
 007325   uvm_field_op field_op ;
 007325   uvm_recursion_policy_enum recursion_policy;
 007325   recursion_policy = get_recursion_policy();
        
~007325   if ((value == null) ||
              (recursion_policy == UVM_REFERENCE) ||
              (object_printed(value, recursion_policy) == uvm_policy::STARTED) ||
%000000       (get_max_depth() == get_active_object_depth())) begin
%000000     print_object_header(name,value,scope_separator); // calls push_element
%000000     pop_element();
          end
 007325   else begin
 007325     push_active_object(value);
 007325     m_recur_states[value][recursion_policy] = uvm_policy::STARTED ;
 007325     print_object_header(name,value,scope_separator); // calls push_element
        
 007325     field_op = uvm_field_op::m_get_available_op() ;
 007325     field_op.set(UVM_PRINT,this,null);
 007325     value.do_execute_op(field_op);
~007325     if (field_op.user_hook_enabled()) begin
              
 007325       value.do_print(this);
            end
        
 007325     field_op.m_recycle();
        
 007325     pop_element() ; // matches push in print_object_header
        
 007325     m_recur_states[value][recursion_policy] = uvm_policy::FINISHED ;
 007325     void'(pop_active_object());
          end
        endfunction
        
        
        // istop
        // -----
        
%000000 function bit uvm_printer::istop ();
%000000   return (get_active_object_depth() == 0);
        endfunction
        
        // print_generic
        // -------------
        
%000000 function void uvm_printer::print_generic (string name,
                                                  string type_name,
                                                  int size,
                                                  string value,
                                                  byte scope_separator=".");
        
%000000   push_element(name,
%000000                type_name,
%000000                (size == -2 ? "..." : $sformatf("%0d",size)),
%000000                value);
%000000   pop_element();
        
        endfunction
        
        
%000000 function void uvm_printer::print_generic_element (string  name,
                                                          string  type_name,
                                                          string  size,
                                                          string  value);
%000000   push_element(name,type_name,size,value);
%000000   pop_element() ;
        endfunction
        
        
        // print_time
        // ----------
        
 002247 function void uvm_printer::print_time (string name,
                                               time value,
                                               byte scope_separator=".");
 002247   print_field_int(name, value, 64, UVM_TIME, scope_separator);
        endfunction
        
        
        // print_string
        // ------------
        
 006741 function void uvm_printer::print_string (string name,
                                                 string value,
                                                 byte scope_separator=".");
        
 006741   push_element(name,
 006741                "string",
 006741                $sformatf("%0d",value.len()),
~006741                (value == "" ? "\"\"" : value));
 006741   pop_element() ;
        
        endfunction
        
 007325 function uvm_policy::recursion_state_e uvm_printer::object_printed (uvm_object value,
                                                                            uvm_recursion_policy_enum recursion);
        
%000000    if (!m_recur_states.exists(value)) begin
%000000      return NEVER ;
           end
        
%000000    if (!m_recur_states[value].exists(recursion)) begin
%000000      return NEVER ;
           end
        
%000000    else begin
%000000      return m_recur_states[value][recursion] ;
           end
        
        endfunction
        
        // print_real
        // ----------
        
%000000 function void uvm_printer::print_real (string name,
                                               real value,
                                               byte scope_separator=".");
        
%000000   push_element(name,"real","64",$sformatf("%f",value));
%000000   pop_element() ;
        
        endfunction
        
        
        // index_string
        // ------------
        
%000000 function string uvm_printer::index_string(int index, string name="");
%000000   index_string.itoa(index);
%000000   index_string = { name, "[", index_string, "]" };
        endfunction
        
        //------------------------------------------------------------------------------
        // Class- uvm_printer_element
        //------------------------------------------------------------------------------
        
 000102 function uvm_printer_element::new (string name = "");
 000102    super.new(name) ;
        endfunction
        
 076452 function void uvm_printer_element::set (string element_name = "",
                                                string element_type_name = "",
                                                string element_size = "",
                                                string element_value = ""
           );
 076452    m_name = element_name ;
 076452    m_type_name = element_type_name ;
 076452    m_size = element_size ;
 076452    m_value = element_value ;
        endfunction
        
%000000 function void uvm_printer_element::set_element_name (string element_name);
%000000    m_name = element_name ;
        endfunction
 229356 function string uvm_printer_element::get_element_name ();
 229356    return m_name ;
        endfunction
        
%000000 function void uvm_printer_element::set_element_type_name (string element_type_name);
%000000    m_type_name = element_type_name ;
        endfunction
 229356 function string uvm_printer_element::get_element_type_name ();
 229356    return m_type_name ;
        endfunction
        
%000000 function void uvm_printer_element::set_element_size (string element_size);
%000000    m_size = element_size ;
        endfunction
 229356 function string uvm_printer_element::get_element_size ();
 229356    return m_size ;
        endfunction
        
%000000 function void uvm_printer_element::set_element_value (string element_value);
%000000    m_value = element_value ;
        endfunction
 229356 function string uvm_printer_element::get_element_value ();
 229356    return m_value ;
        endfunction
        
 069214 function void uvm_printer_element::add_child(uvm_printer_element child) ;
 069214    m_children.push_back(child) ;
        endfunction
 152877 function void uvm_printer_element::get_children(ref uvm_printer_element children[$], input bit recurse) ;
~152877    foreach (m_children[i]) begin
 138404      children.push_back(m_children[i]) ;
 069214      if (recurse) begin
 069190        m_children[i].get_children(children,1) ;
             end
           end
        endfunction
 076425 function void uvm_printer_element::clear_children() ;
 076425    m_children.delete() ;
        endfunction
        
        //------------------------------------------------------------------------------
        // Class- uvm_table_printer
        //------------------------------------------------------------------------------
        
        // new
        // ---
        
%000003 function uvm_table_printer::new(string name="");
%000003   super.new(name);
        endfunction
        
        
 076452 function void uvm_table_printer::pop_element();
 076452    int name_len;
 076452    int level ;
 076452    uvm_printer_element popped ;
 076452    string name_str ;
 076452    string type_name_str ;
 076452    string size_str ;
 076452    string value_str ;
        
 076452    popped = get_top_element() ;
        
 076452    level = m_get_stack_size() - 1 ;
 076452    name_str = popped.get_element_name() ;
 076452    type_name_str = popped.get_element_type_name() ;
 076452    size_str = popped.get_element_size() ;
 076452    value_str = popped.get_element_value() ;
        
 062464    if ((name_str.len() + (get_indent() * level)) > m_max_name) begin
 013988      m_max_name = (name_str.len() + (get_indent() * level));
           end
        
 061973    if (type_name_str.len() > m_max_type) begin
 014479      m_max_type = type_name_str.len();
           end
        
~076452    if (size_str.len() > m_max_size) begin
%000000      m_max_size = size_str.len();
           end
        
 069569    if (value_str.len() > m_max_value) begin
 006883      m_max_value = value_str.len();
           end
        
        
 076452    super.pop_element() ;
        
        endfunction
        
        // emit
        // ----
        
 007238 function string uvm_table_printer::emit();
        
 007238   string s;
 007238   string user_format;
 007238   static string dash; // = "---------------------------------------------------------------------------------------------------";
 007238   string dashes;
        
 007238   string linefeed;
        
~007238   if (!m_flushed) begin
%000000     `uvm_error("UVM/PRINT/NO_FLUSH","printer emit() method called twice without intervening uvm_printer::flush()")
          end
 007238   else begin
 007238     m_flushed = 0 ;
          end
        
 007238   linefeed = {"\n", get_line_prefix()};
        
 007238    begin
 007238      int q[5];
 007238      int m;
 007238      int qq[$];
        
 007238      q = '{m_max_name,m_max_type,m_max_size,m_max_value,100};
 007238      qq = q.max;
 007238      m = qq[0];
~007235      if(dash.len()<m) begin
%000003        dash = {m{"-"}};
%000003        m_space = {m{" "}};
             end
           end
        
          // for backward compatibility
~007238   if (knobs.header) begin
 007238     user_format = format_header();
~007238     if (user_format != "") begin
%000000       s = {s, user_format, linefeed};
            end
 007238     else begin // branch taken if backward compatibility not used
 007238       string header;
 007238       string dash_id, dash_typ, dash_sz;
 007238       string head_id, head_typ, head_sz;
~007238       if (get_name_enabled()) begin
 007238         dashes = {dash.substr(1,m_max_name+2)};
 007238         header = {"Name",m_space.substr(1,m_max_name-2)};
              end
~007238       if (get_type_name_enabled()) begin
 007238         dashes = {dashes, dash.substr(1,m_max_type+2)};
 007238         header = {header, "Type",m_space.substr(1,m_max_type-2)};
              end
~007238       if (get_size_enabled()) begin
 007238         dashes = {dashes, dash.substr(1,m_max_size+2)};
 007238         header = {header, "Size",m_space.substr(1,m_max_size-2)};
              end
 007238       dashes = {dashes, dash.substr(1,m_max_value), linefeed};
 007238       header = {header, "Value", m_space.substr(1,m_max_value-5), linefeed};
            
 007238       s = {s, dashes, header, dashes};
            end
          end
        
        
 007238   s = {s, m_emit_element(get_bottom_element(),0)} ;
        
          // for backward compatibility
~007238   if (knobs.footer) begin
 007238     user_format = format_footer();
~007238     if (user_format != "") begin
%000000       s = {s, user_format, linefeed};
            end
        
 007238     else begin // branch taken if backward compatibility not used
 007238       s = {s, dashes}; // add dashes for footer
            end
          end
        
 007238   emit = {get_line_prefix(), s};
        endfunction
        
 076452 function string uvm_table_printer::m_emit_element(uvm_printer_element element, int unsigned level) ;
 076452   string result ;
 076452   static uvm_printer_element_proxy proxy = new("proxy") ;
 076452   uvm_printer_element element_children[$];
 076452   string linefeed = {"\n", get_line_prefix()};
        
        // begin code for compatibility
 076452     uvm_printer_row_info row ;
 076452     string user_format ;
 076452     row.level = level ;
 076452     row.name = element.get_element_name() ;
 076452     row.type_name = element.get_element_type_name() ;
 076452     row.size = element.get_element_size() ;
 076452     row.val = element.get_element_value() ;
 076452     user_format = format_row(row);
~076452     if (user_format != "") begin
%000000       result = {user_format, linefeed};
            end
 076452     else begin
              // end code for compatibility
        
            
 076452       string row_str;
 076452       string name_str ;
 076452       string value_str ;
 076452       string type_name_str ;
 076452       string size_str ;
 076452       name_str = element.get_element_name() ;
 076452       value_str = element.get_element_value() ;
 076452       type_name_str = element.get_element_type_name() ;
 076452       size_str = element.get_element_size() ;
~076452       if (get_name_enabled()) begin
                
 076452         result = {result, m_space.substr(1,level * get_indent()), name_str,
 076452                    m_space.substr(1,m_max_name-name_str.len()-(level*get_indent())+2)};
              end
        
~076452       if (get_type_name_enabled()) begin
                
 076452         result = {result, type_name_str, m_space.substr(1,m_max_type-type_name_str.len()+2)};
              end
        
~076452       if (get_size_enabled()) begin
                
 076452         result = {result, size_str, m_space.substr(1,m_max_size-size_str.len()+2)};
              end
        
 076452       result = {result, row_str, value_str, m_space.substr(1,m_max_value-value_str.len()), linefeed};
            end
 076452   proxy.get_immediate_children(element,element_children) ;
~076452   foreach (element_children[i]) begin
 069214     result = {result, m_emit_element(element_children[i],level+1)} ;
          end
 076452   return result ;
        endfunction
        
        
        //------------------------------------------------------------------------------
        // Class- uvm_tree_printer
        //------------------------------------------------------------------------------
        
        
        // new
        // ---
        
%000009 function uvm_tree_printer::new(string name="");
%000009   super.new(name);
%000009   set_size_enabled(0);
%000009   set_type_name_enabled(0);
          //for backward compatibility
%000009   knobs.header = 0;
%000009   knobs.footer = 0;
        endfunction
        
        
%000003 function void uvm_tree_printer::set_indent(int indent) ;
%000003    m_uvm_printer_knobs _knobs = get_knobs();
%000003    _knobs.indent = indent ;
        endfunction
%000000 function int uvm_tree_printer::get_indent() ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    return _knobs.indent ;
        endfunction
        
%000000 function void uvm_tree_printer::set_separators(string separators) ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    _knobs.separator = separators ;
        endfunction
%000000 function string uvm_tree_printer::get_separators() ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    return _knobs.separator ;
        endfunction
        
%000009 function void uvm_tree_printer::flush() ;
%000009    super.flush() ;
           //set_indent(2) ; // LRM says to include this call
           //set_separators("{}"); // LRM says to include this call
        endfunction
        
        // emit
        // ----
        
%000000 function string uvm_tree_printer::emit();
        
%000000   string s ;
%000000   string user_format;
%000000   int unsigned level ;
%000000   uvm_printer_element element ;
        
%000000   if (!m_flushed) begin
%000000     `uvm_error("UVM/PRINT/NO_FLUSH","printer emit() method called twice without intervening uvm_printer::flush()")
          end
%000000   else begin
%000000     m_flushed = 0 ;
          end
        
        
%000000   s = get_line_prefix() ;
%000000   m_linefeed = m_newline == "" || m_newline == " " ? m_newline : {m_newline, get_line_prefix()};
        
          // backward compatibility
%000000   if (knobs.header) begin
%000000     user_format = format_header();
%000000     if (user_format != "") begin
              
%000000       s = {s, user_format, m_linefeed};
            end
        
          end
        
%000000   s = {s,m_emit_element(get_bottom_element(),0)} ;
        
          // backward compatibility
%000000   if (knobs.footer) begin
%000000     user_format = format_footer();
%000000     if (user_format != "") begin
              
%000000       s = {s, user_format, m_linefeed};
            end
        
          end
        
%000000   if (m_newline == "" || m_newline == " ") begin
            
%000000     s = {s, "\n"};
          end
        
        
%000000   return(s);
        endfunction
        
%000000 function string uvm_tree_printer::m_emit_element(uvm_printer_element element, int unsigned level) ;
%000000    string result ;
%000000    string space= "                                                                                                   ";
%000000    static uvm_printer_element_proxy proxy = new("proxy") ;
%000000    uvm_printer_element element_children[$];
%000000    string separators;
%000000    string indent_str;
%000000    string user_format ; // for compatibility only
        
%000000    separators=get_separators() ;
%000000    indent_str = space.substr(1,level * get_indent());
%000000    proxy.get_immediate_children(element,element_children) ;
        
        // begin code for compatibility
%000000     begin
%000000       uvm_printer_row_info row ;
%000000       row.level = level ;
%000000       row.name = element.get_element_name() ;
%000000       row.type_name = element.get_element_type_name() ;
%000000       row.size = element.get_element_size() ;
%000000       row.val = element.get_element_value() ;
%000000       user_format = format_row(row);
            end
%000000     if (user_format != "") begin
%000000       result = user_format;
            end
%000000     else begin
              // end code for compatibility
        
            
%000000       string value_str ;
        
              // Name (id)
%000000       if (get_name_enabled()) begin
%000000         result = {result,indent_str, element.get_element_name()};
%000000         if (element.get_element_name() != "" && element.get_element_name() != "...") begin
                  
%000000           result = {result, ": "};
                end
        
              end
        
              // Type Name
%000000       value_str = element.get_element_value();
%000000       if ((value_str.len() > 0) && (value_str[0] == "@")) begin // is an object w/ id_enabled() on
                
%000000         result = {result,"(",element.get_element_type_name(),value_str,") "};
              end
        
              else
%000000         if (get_type_name_enabled() &&
                (element.get_element_type_name() != "" ||
                element.get_element_type_name() != "-" ||
%000000         element.get_element_type_name() != "...")) begin
                  
%000000           result = {result,"(",element.get_element_type_name(),") "};
                end
        
        
              // Size
%000000       if (get_size_enabled()) begin
%000000         if (element.get_element_size() != "" || element.get_element_size() != "-") begin
                    
%000000           result = {result,"(",element.get_element_size(),") "};
                end
        
              end
        
%000000       if (element_children.size() > 0) begin
%000000         result = {result, string'(separators[0]), m_linefeed};
              end
%000000       else begin
%000000         result = {result, value_str, " ", m_linefeed};
              end
        
            end
        
            //process all children (if any) of this element
%000000     foreach (element_children[i]) begin
%000000       result = {result, m_emit_element(element_children[i],level+1)} ;
            end
            //if there were children, add the closing separator
%000000     if ((user_format == "") && (element_children.size() > 0)) begin
%000000       result = {result, indent_str, string'(separators[1]), m_linefeed};
            end
%000000     return result ;
        endfunction : m_emit_element
        
%000000 function void uvm_table_printer::set_default(uvm_table_printer printer) ;
           // for backward compatibility we store default in global variable
%000000    uvm_default_table_printer = printer ;
        endfunction
        
%000000 function uvm_table_printer uvm_table_printer::get_default() ;
%000000    if (uvm_default_table_printer == null) begin
%000000      uvm_default_table_printer = new() ;
           end
%000000    return uvm_default_table_printer ;
        endfunction
        
%000000 function void uvm_table_printer::set_indent(int indent) ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    _knobs.indent = indent ;
        endfunction
 243344 function int uvm_table_printer::get_indent() ;
 243344    m_uvm_printer_knobs _knobs = get_knobs();
 243344    return _knobs.indent ;
        endfunction
        
 007241 function void uvm_table_printer::flush() ;
 007241    super.flush() ;
 007241    m_max_name=4;
 007241    m_max_type=4;
 007241    m_max_size=4;
 007241    m_max_value=5;
           //set_indent(2) ; // LRM says to include this call
        endfunction
        
        
%000000 function void uvm_tree_printer::set_default(uvm_tree_printer printer) ;
           // for backward compatibility we store default in global variable
%000000    uvm_default_tree_printer = printer ;
        endfunction
        
%000000 function uvm_tree_printer uvm_tree_printer::get_default() ;
%000000    if (uvm_default_tree_printer == null) begin
%000000      uvm_default_tree_printer = new() ;
           end
%000000    return uvm_default_tree_printer ;
        endfunction
        
%000003 function uvm_line_printer::new(string name="") ;
%000003   super.new(name);
%000003   m_newline = " ";
%000003   set_indent(0);
        endfunction
        
%000000 function void uvm_line_printer::set_default(uvm_line_printer printer) ;
           // for backwards compatibility we store default in global variable
%000000    uvm_default_line_printer = printer ;
        endfunction
        
%000000 function uvm_line_printer uvm_line_printer::get_default() ;
%000000    if (uvm_default_line_printer == null) begin
%000000      uvm_default_line_printer = new() ;
           end
%000000    return uvm_default_line_printer ;
        endfunction
        
%000000 function void uvm_line_printer::set_separators(string separators) ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    if (separators.len() < 2) begin
%000000      `uvm_error("UVM/PRINT/SHORT_SEP",$sformatf("Bad call: set_separators(%s) (Argument must have at least 2 characters)",separators))
           end
%000000    _knobs.separator = separators ;
        endfunction
%000000 function string uvm_line_printer::get_separators() ;
%000000    m_uvm_printer_knobs _knobs = get_knobs();
%000000    return _knobs.separator ;
        endfunction
        
%000003 function void uvm_line_printer::flush() ;
%000003    super.flush() ;
           //set_indent(0); // LRM says to include this call
           //set_separators("{}"); // LRM says to include this call
        endfunction
        
