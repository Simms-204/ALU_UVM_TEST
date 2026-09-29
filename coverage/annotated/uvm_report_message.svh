//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014-2018 Cisco Systems, Inc.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2013 Synopsys, Inc.
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
        // $File:     src/base/uvm_report_message.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_REPORT_MESSAGE_SVH
        `define UVM_REPORT_MESSAGE_SVH
        
        
        typedef class uvm_report_server;
        typedef class uvm_report_handler;
        typedef class uvm_root;
         
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message_element_base
        //
        // Base class for report message element. Defines common interface.
        //
        //------------------------------------------------------------------------------
        
%000000 virtual class uvm_report_message_element_base;
           protected uvm_action _action;
           protected string          _name;
        
        
           // Function -- NODOCS -- get_name
           // 
        
%000000    virtual function string get_name();
%000000      return _name;
           endfunction
        
           // Function -- NODOCS -- set_name
           // 
           // Get or set the name of the element
           //
        
%000000    virtual function void set_name(string name);
%000000      _name = name;
           endfunction
             
        
           // Function -- NODOCS -- get_action
           // 
        
%000000    virtual function uvm_action get_action();
%000000      return _action;
           endfunction
        
           // Function -- NODOCS -- set_action
           // 
           // Get or set the authorized action for the element
           //
        
%000000    virtual function void set_action(uvm_action action);
%000000      _action = action;
           endfunction
             
             
%000000    function void print(uvm_printer printer);
%000000       if (_action & (UVM_LOG | UVM_DISPLAY))
%000000         begin
%000000           do_print(printer);
                end
        
           endfunction : print
%000000    function void record(uvm_recorder recorder);
%000000       if (_action & UVM_RM_RECORD)
%000000         begin
%000000           do_record(recorder);
                end
        
           endfunction : record
%000000    function void copy(uvm_report_message_element_base rhs);
%000000       do_copy(rhs);
           endfunction : copy
%000000    function uvm_report_message_element_base clone();
%000000       return do_clone();
           endfunction : clone
        
%000000    pure virtual function void do_print(uvm_printer printer);
%000000    pure virtual function void do_record(uvm_recorder recorder);
%000000    pure virtual function void do_copy(uvm_report_message_element_base rhs);
%000000    pure virtual function uvm_report_message_element_base do_clone();
           
        endclass : uvm_report_message_element_base
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message_int_element
        //
        // Message element class for integral type
        //
        //------------------------------------------------------------------------------
        
%000000 class uvm_report_message_int_element extends uvm_report_message_element_base;
           typedef uvm_report_message_int_element this_type;
           
           protected uvm_bitstream_t _val;
           protected int             _size;
           protected uvm_radix_enum  _radix;
        
           // Function -- NODOCS -- get_value
           //
        
%000000    virtual function uvm_bitstream_t get_value(output int size, 
%000000                                               output uvm_radix_enum radix);
%000000      size = _size;
%000000      radix = _radix;
%000000      return _val;
           endfunction
        
        
           // Function -- NODOCS -- set_value
           //
           // Get or set the value (integral type) of the element, with size and radix
           //
        
%000000    virtual function void set_value(uvm_bitstream_t value,
                                      int size, 
                                      uvm_radix_enum radix);
%000000      _size = size;
%000000      _radix = radix;
%000000      _val = value;
           endfunction
        
        
%000000    virtual function void do_print(uvm_printer printer);
%000000       printer.print_field(_name, _val, _size, _radix);
           endfunction : do_print
        
%000000    virtual function void do_record(uvm_recorder recorder);
%000000       recorder.record_field(_name, _val, _size, _radix);
           endfunction : do_record
        
%000000    virtual function void do_copy(uvm_report_message_element_base rhs);
%000000       this_type _rhs;
%000000       $cast(_rhs, rhs);
%000000       _name = _rhs._name;
%000000       _val = _rhs._val;
%000000       _size = _rhs._size;
%000000       _radix = _rhs._radix;
%000000       _action = rhs._action;
           endfunction : do_copy
        
%000000    virtual function uvm_report_message_element_base do_clone(); 
%000000      this_type tmp = new; 
%000000      tmp.copy(this); 
%000000      return tmp; 
           endfunction : do_clone
        endclass : uvm_report_message_int_element
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message_string_element
        //
        // Message element class for string type
        //
        //------------------------------------------------------------------------------
        
%000000 class uvm_report_message_string_element extends uvm_report_message_element_base;
           typedef uvm_report_message_string_element this_type;
           protected string  _val;
        
        
           // Function -- NODOCS -- get_value
           //
        
%000000    virtual function string get_value();
%000000      return _val;
           endfunction
        
           // Function -- NODOCS -- set_value
           //
           // Get or set the value (string type) of the element
           //
        
%000000    virtual function void set_value(string value);
%000000      _val = value;
           endfunction
        
        
%000000    virtual function void do_print(uvm_printer printer);
%000000       printer.print_string(_name, _val);
           endfunction : do_print
        
%000000    virtual function void do_record(uvm_recorder recorder);
%000000       recorder.record_string(_name, _val);
           endfunction : do_record
        
%000000    virtual function void do_copy(uvm_report_message_element_base rhs);
%000000       this_type _rhs;
%000000       $cast(_rhs, rhs);
%000000       _name = _rhs._name;
%000000       _val = _rhs._val;
%000000       _action = rhs._action;
           endfunction : do_copy
           
%000000    virtual function uvm_report_message_element_base do_clone(); 
%000000      this_type tmp = new; 
%000000      tmp.copy(this); 
%000000      return tmp; 
           endfunction : do_clone
        endclass : uvm_report_message_string_element
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message_object_element
        //
        // Message element class for object type
        //
        //------------------------------------------------------------------------------
        
%000000 class uvm_report_message_object_element extends uvm_report_message_element_base;
           typedef uvm_report_message_object_element this_type;
           protected uvm_object _val;
        
        
           // Function -- NODOCS -- get_value
           //
           // Get the value (object reference) of the element
           //
        
%000000    virtual function uvm_object get_value();
%000000      return _val;
           endfunction
        
           // Function -- NODOCS -- set_value
           //
           // Get or set the value (object reference) of the element
           //
        
%000000    virtual function void set_value(uvm_object value);
%000000      _val = value;
           endfunction
        
        
%000000    virtual function void do_print(uvm_printer printer);
%000000       printer.print_object(_name, _val);
           endfunction : do_print
        
%000000    virtual function void do_record(uvm_recorder recorder);
%000000       recorder.record_object(_name, _val);
           endfunction : do_record
        
%000000    virtual function void do_copy(uvm_report_message_element_base rhs);
%000000       this_type _rhs;
%000000       $cast(_rhs, rhs);
%000000       _name = _rhs._name;
%000000       _val = _rhs._val;
%000000       _action = rhs._action;
           endfunction : do_copy
           
%000000    virtual function uvm_report_message_element_base do_clone(); 
%000000      this_type tmp = new; 
%000000      tmp.copy(this); 
%000000      return tmp; 
           endfunction : do_clone
        endclass : uvm_report_message_object_element
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message_element_container
        //
        // A container used by report message to contain the dynamically added elements,
        // with APIs to add and delete the elements.
        //
        //------------------------------------------------------------------------------
        
        class uvm_report_message_element_container extends uvm_object;
        
          protected uvm_report_message_element_base elements[$];
        
%000000   `uvm_object_utils(uvm_report_message_element_container)
        
          // Function -- NODOCS -- new
          //
          // Create a new uvm_report_message_element_container object
          //
        
~013520   function new(string name = "element_container");
 013520     super.new(name);
          endfunction
        
        
          // Function -- NODOCS -- size
          //
          // Returns the size of the container, i.e. the number of elements
          //
        
 013520   virtual function int size();
 013520     return elements.size();
          endfunction
        
        
          // Function -- NODOCS -- delete
          //
          // Delete the ~index~-th element in the container
          //
        
%000000   virtual function void delete(int index);
%000000     elements.delete(index);
          endfunction
        
        
          // Function -- NODOCS -- delete_elements
          //
          // Delete all the elements in the container
          //
        
%000000   virtual function void delete_elements();
%000000     elements.delete();
          endfunction
        
        
          // Function -- NODOCS -- get_elements
          //
          // Get all the elements from the container and put them in a queue
          //
        
          typedef uvm_report_message_element_base queue_of_element[$];
%000000   virtual function queue_of_element get_elements();
%000000     return elements;
          endfunction
        
        
          // Function -- NODOCS -- add_int
          // 
          // This method adds an integral type of the name ~name~ and value ~value~ to
          // the container.  The required ~size~ field indicates the size of ~value~. 
          // The required ~radix~ field determines how to display and 
          // record the field. The optional print/record bit is to specify whether 
          // the element will be printed/recorded.
          //
        
%000000   virtual function void add_int(string name, uvm_bitstream_t value, 
                                        int size, uvm_radix_enum radix,
                            uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000      process p;
%000000      string rand_state;
%000000      uvm_report_message_int_element urme;
        
%000000      p = process::self();
%000000      if (p != null)
%000000        begin
%000000          rand_state = p.get_randstate();
               end
        
%000000      urme = new();
%000000      if (p != null)
%000000        begin
%000000          p.set_randstate(rand_state);
               end
        
        
%000000      urme.set_name(name);
%000000      urme.set_value(value, size, radix);
%000000      urme.set_action(action);
%000000      elements.push_back(urme);
          endfunction
        
        
          // Function -- NODOCS -- add_string
          // 
          // This method adds a string of the name ~name~ and value ~value~ to the 
          // message. The optional print/record bit is to specify whether 
          // the element will be printed/recorded.
          //
        
%000000   virtual function void add_string(string name, string value, 
                                           uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000      process p;
%000000      string rand_state;
%000000      uvm_report_message_string_element urme;
        
%000000      p = process::self();
%000000      if (p != null)
%000000        begin
%000000          rand_state = p.get_randstate();
               end
        
%000000      urme = new();
%000000      if (p != null)
%000000        begin
%000000          p.set_randstate(rand_state);
               end
        
        
%000000      urme.set_name(name);
%000000      urme.set_value(value);
%000000      urme.set_action(action);
%000000      elements.push_back(urme);
          endfunction
        
        
          // Function -- NODOCS -- add_object
          // 
          // This method adds a uvm_object of the name ~name~ and reference ~obj~ to
          // the message. The optional print/record bit is to specify whether 
          // the element will be printed/recorded. 
          //
        
%000000   virtual function void add_object(string name, uvm_object obj, 
                                           uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000      process p;
%000000      string rand_state;
%000000      uvm_report_message_object_element urme;
        
%000000      p = process::self();
%000000      if (p != null)
%000000        begin
%000000          rand_state = p.get_randstate();
               end
        
%000000      urme = new();
%000000      if (p != null)
%000000        begin
%000000          p.set_randstate(rand_state);
               end
        
        
%000000      urme.set_name(name);
%000000      urme.set_value(obj);
%000000      urme.set_action(action);
%000000      elements.push_back(urme);
          endfunction
        
%000000   virtual function void do_print(uvm_printer printer);
%000000     super.do_print(printer);
%000000     for(int i = 0; i < elements.size(); i++) 
%000000       begin
%000000         elements[i].print(printer);
              end 
          endfunction
        
%000000   virtual function void do_record(uvm_recorder recorder);
%000000     super.do_record(recorder);
%000000     for(int i = 0; i < elements.size(); i++) 
%000000       begin
%000000         elements[i].record(recorder);
              end
          endfunction
        
%000000   virtual function void do_copy(uvm_object rhs);
%000000     uvm_report_message_element_container urme_container;
        
%000000     super.do_copy(rhs);
        
%000000     if(!$cast(urme_container, rhs) || (rhs==null))
%000000       begin
%000000         return;
              end
        
        
%000000     delete_elements();
%000000     foreach (urme_container.elements[i])
%000000       begin
%000000         elements.push_back(urme_container.elements[i].clone());
              end
        
        
          endfunction
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_report_message
        //
        // The uvm_report_message is the basic UVM object message class.  It provides 
        // the fields that are common to all messages.  It also has a message element 
        // container and provides the APIs necessary to add integral types, strings and
        // uvm_objects to the container. The report message object can be initialized
        // with the common fields, and passes through the whole reporting system (i.e. 
        // report object, report handler, report server, report catcher, etc) as an
        // object. The additional elements can be added/deleted to/from the message 
        // object anywhere in the reporting system, and can be printed or recorded
        // along with the common fields.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 6.2.1
        class uvm_report_message extends uvm_object;
        
          protected uvm_report_object _report_object;
          protected uvm_report_handler _report_handler;
          protected uvm_report_server _report_server;
        
          protected uvm_severity _severity; 
          protected string _id;
          protected string _message;
          protected int _verbosity;
          protected string _filename;
          protected int _line;
          protected string _context_name;
          protected uvm_action _action; 
          protected UVM_FILE _file;
        
          // Not documented.
          protected uvm_report_message_element_container _report_message_element_container;
        
        
          // Function -- NODOCS -- new
          // 
          // Creates a new uvm_report_message object.
          //
        
          // @uvm-ieee 1800.2-2020 auto 6.2.2.1
~013520   function new(string name = "uvm_report_message");
 013520     super.new(name);
 013520     _report_message_element_container = new();
          endfunction
        
        
          // Function -- NODOCS -- new_report_message
          // 
          // Creates a new uvm_report_message object.
          // This function is the same as new(), but keeps the random stability.
          //
        
          // @uvm-ieee 1800.2-2020 auto 6.2.2.2
 013520   static function uvm_report_message new_report_message(string name = "uvm_report_message");
 013520     process p;
 013520     string rand_state;
        
 013520     p = process::self();
        
~013520     if (p != null)
 013520       begin
 013520         rand_state = p.get_randstate();
              end
        
 013520     new_report_message = new(name);
~013520     if (p != null)
 013520       begin
 013520         p.set_randstate(rand_state);
              end
        
        
          endfunction
        
        
          // Function -- NODOCS -- print
          //
          // The uvm_report_message implements <uvm_object::do_print()> such that
          // ~print~ method provides UVM printer formatted output
          // of the message.  A snippet of example output is shown here:
          //
          //| --------------------------------------------------------
          //| Name                Type               Size  Value
          //| --------------------------------------------------------
          //| uvm_report_message  uvm_report_message  -     @532
          //|   severity          uvm_severity        2     UVM_INFO
          //|   id                string              10    TEST_ID
          //|   message           string              12    A message...
          //|   verbosity         uvm_verbosity       32    UVM_LOW
          //|   filename          string              7     test.sv
          //|   line              integral            32    'd58
          //|   context_name      string              0     ""
          //|   color             string              3     red
          //|   my_int            integral            32    'd5
          //|   my_string         string              3     foo
          //|   my_obj            my_class            -     @531
          //|     foo             integral            32    'd3
          //|     bar             string              8     hi there
        
        
          // @uvm-ieee 1800.2-2020 auto 6.2.2.3
%000000   virtual function void do_print(uvm_printer printer);
%000000     uvm_verbosity l_verbosity;
        
%000000     super.do_print(printer);
        
%000000     printer.print_generic("severity", "uvm_severity", 
%000000                           $bits(_severity), _severity.name());
%000000     printer.print_string("id", _id);
%000000     printer.print_string("message",_message);
%000000     if ($cast(l_verbosity, _verbosity))
%000000       begin
%000000         printer.print_generic("verbosity", "uvm_verbosity", 
%000000                             $bits(l_verbosity), l_verbosity.name());
              end
        
            else
%000000       begin
%000000         printer.print_field("verbosity", _verbosity, $bits(_verbosity), UVM_HEX);
              end
        
%000000     printer.print_string("filename", _filename);
%000000     printer.print_field("line", _line, $bits(_line), UVM_UNSIGNED);
%000000     printer.print_string("context_name", _context_name);
        
%000000     if (_report_message_element_container.size() != 0) 
%000000       begin
%000000         uvm_report_message_element_base elements[$];
%000000         elements  = _report_message_element_container.get_elements();
%000000         foreach (elements[i])
%000000         begin
%000000           elements[i].print(printer);
                end
        
              end
          endfunction
        
        
%000000   `uvm_object_utils(uvm_report_message)
        
        
        
          // do_pack() not needed
          // do_unpack() not needed
          // do_compare() not needed
        
        
          // Not documented.
%000000   virtual function void do_copy (uvm_object rhs);
%000000     uvm_report_message report_message;
        
%000000     super.do_copy(rhs);
        
%000000     if(!$cast(report_message, rhs) || (rhs==null))
%000000       begin
%000000         return;
              end
        
        
%000000     _report_object = report_message.get_report_object();
%000000     _report_handler = report_message.get_report_handler();
%000000     _report_server = report_message.get_report_server();
%000000     _context_name = report_message.get_context();
%000000     _file = report_message.get_file();
%000000     _filename = report_message.get_filename();
%000000     _line = report_message.get_line();
%000000     _action = report_message.get_action();
%000000     _severity = report_message.get_severity();
%000000     _id = report_message.get_id();
%000000     _message = report_message.get_message();
%000000     _verbosity = report_message.get_verbosity();
        
%000000     _report_message_element_container.copy(report_message._report_message_element_container);
          endfunction
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS --  Infrastructure References
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- get_report_object
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.1
 013520   virtual function uvm_report_object get_report_object();
 013520     return _report_object;
          endfunction
        
          // Function -- NODOCS -- set_report_object
          //
          // Get or set the uvm_report_object that originated the message.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.1
 013520   virtual function void set_report_object(uvm_report_object ro);
 013520     _report_object = ro;
          endfunction
        
        
          // Function -- NODOCS -- get_report_handler
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.2
 027040   virtual function uvm_report_handler get_report_handler();
 027040     return _report_handler;
          endfunction
        
          // Function -- NODOCS -- set_report_handler
          //
          // Get or set the uvm_report_handler that is responsible for checking
          // whether the message is enabled, should be upgraded/downgraded, etc.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.2
 013520   virtual function void set_report_handler(uvm_report_handler rh);
 013520     _report_handler = rh;
          endfunction
        
          
          // Function -- NODOCS -- get_report_server
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.3
%000000   virtual function uvm_report_server get_report_server();
%000000     return _report_server;
          endfunction
        
          // Function -- NODOCS -- set_report_server
          //
          // Get or set the uvm_report_server that is responsible for servicing
          // the message's actions.  
        
          // @uvm-ieee 1800.2-2020 auto 6.2.3.3
 013520   virtual function void set_report_server(uvm_report_server rs);
 013520     _report_server = rs;
          endfunction
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS --  Message Fields
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- get_severity
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.1
 054086   virtual function uvm_severity get_severity();
 054086     return _severity;
          endfunction
        
          // Function -- NODOCS -- set_severity
          //
          // Get or set the severity (UVM_INFO, UVM_WARNING, UVM_ERROR or 
          // UVM_FATAL) of the message.  The value of this field is determined via
          // the API used (`uvm_info(), `uvm_waring(), etc.) and populated for the user.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.1
%000000   virtual function void set_severity(uvm_severity sev);
%000000     _severity = sev;
          endfunction
        
        
          // Function -- NODOCS -- get_id
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.2
 040560   virtual function string get_id();
 040560     return _id;
          endfunction
        
          // Function -- NODOCS -- set_id
          //
          // Get or set the id of the message.  The value of this field is 
          // completely under user discretion.  Users are recommended to follow a
          // consistent convention.  Settings in the uvm_report_handler allow various
          // messaging controls based on this field.  See <uvm_report_handler>.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.2
%000000   virtual function void set_id(string id);
%000000     _id = id;
          endfunction
        
        
          // Function -- NODOCS -- get_message
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.3
 013520   virtual function string get_message();
 013520     return _message;
          endfunction
        
          // Function -- NODOCS -- set_message
          //
          // Get or set the user message content string.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.3
%000000   virtual function void set_message(string msg);
%000000     _message = msg;
          endfunction
        
        
          // Function -- NODOCS -- get_verbosity
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.4
%000000   virtual function int get_verbosity();
%000000     return _verbosity;
          endfunction
        
          // Function -- NODOCS -- set_verbosity
          //
          // Get or set the message threshold value.  This value is compared
          // against settings in the <uvm_report_handler> to determine whether this
          // message should be executed.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.4
%000000   virtual function void set_verbosity(int ver);
%000000     _verbosity = ver;
          endfunction
        
        
          // Function -- NODOCS -- get_filename
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.5
 027037   virtual function string get_filename();
 027037     return _filename;
          endfunction
        
          // Function -- NODOCS -- set_filename
          //
          // Get or set the file from which the message originates.  This value
          // is automatically populated by the messaging macros.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.5
%000000   virtual function void set_filename(string fname);
%000000     _filename = fname;
          endfunction
        
        
          // Function -- NODOCS -- get_line
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.6
 013517   virtual function int get_line();
 013517     return _line;
          endfunction
        
          // Function -- NODOCS -- set_line
          //
          // Get or set the line in the ~file~ from which the message originates.
          // This value is automatically populate by the messaging macros.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.6
%000000   virtual function void set_line(int ln);
%000000     _line = ln;
          endfunction
        
        
          // Function -- NODOCS -- get_context
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.7
 015566   virtual function string get_context();
 015566     return _context_name;
          endfunction
        
          // Function -- NODOCS -- set_context
          //
          // Get or set the optional user-supplied string that is meant to convey
          // the context of the message.  It can be useful in scopes that are not
          // inherently UVM like modules, interfaces, etc.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.7
 001023   virtual function void set_context(string cn);
 001023     _context_name = cn;
          endfunction
         
        
          // Function -- NODOCS -- get_action
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.8
 121680   virtual function uvm_action get_action();
 121680     return _action;
          endfunction
        
          // Function -- NODOCS -- set_action
          //
          // Get or set the action(s) that the uvm_report_server should perform
          // for this message.  This field is populated by the uvm_report_handler during
          // message execution flow.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.8
 013520   virtual function void set_action(uvm_action act);
 013520     _action = act;
          endfunction
        
        
          // Function -- NODOCS -- get_file
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.9
%000000   virtual function UVM_FILE get_file();
%000000     return _file;
          endfunction
        
          // Function -- NODOCS -- set_file
          //
          // Get or set the file that the message is to be written to when the 
          // message's action is UVM_LOG.  This field is populated by the 
          // uvm_report_handler during message execution flow.
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.9
 013520   virtual function void set_file(UVM_FILE fl);
 013520     _file = fl;
          endfunction
        
        
          // Function -- NODOCS -- get_element_container
          //
          // Get the element_container of the message
        
 013520   virtual function uvm_report_message_element_container get_element_container();
 013520     return _report_message_element_container;
          endfunction
        
        
          // Function -- NODOCS -- set_report_message
          //
          // Set all the common fields of the report message in one shot.
          //
        
          // @uvm-ieee 1800.2-2020 auto 6.2.4.10
 013520   virtual function void set_report_message(uvm_severity severity, 
                                   string id,
                               string message,
                               int verbosity, 
                                   string filename,
                               int line,
                               string context_name);
 013520     this._context_name = context_name;
 013520     this._filename = filename;
 013520     this._line = line;
 013520     this._severity = severity;
 013520     this._id = id;
 013520     this._message = message;
 013520     this._verbosity = verbosity;
          endfunction
        
        
          //----------------------------------------------------------------------------
          // Group-  Message Recording
          //----------------------------------------------------------------------------
        
          // Not documented.
%000000   virtual function void m_record_message(uvm_recorder recorder);
%000000     recorder.record_string("message", _message);
          endfunction
        
        
          // Not documented.
%000000   virtual function void m_record_core_properties(uvm_recorder recorder);
        
%000000     string l_string;
%000000     uvm_verbosity l_verbosity;
        
%000000     if (_context_name != "")
%000000       begin
%000000         recorder.record_string("context_name", _context_name);
              end
        
%000000     recorder.record_string("filename", _filename);
%000000     recorder.record_field("line", _line, $bits(_line), UVM_UNSIGNED);
%000000     recorder.record_string("severity", _severity.name());
%000000     if ($cast(l_verbosity, _verbosity))
%000000       begin
%000000         recorder.record_string("verbosity", l_verbosity.name());
              end
        
            else 
%000000       begin
%000000         l_string.itoa(_verbosity);
%000000         recorder.record_string("verbosity", l_string);
              end
        
%000000     recorder.record_string("id", _id);
%000000     m_record_message(recorder);
          endfunction
        
          // Not documented.
%000000   virtual function void do_record(uvm_recorder recorder);
        
%000000     super.do_record(recorder);
        
%000000     m_record_core_properties(recorder);
%000000     _report_message_element_container.record(recorder);
        
          endfunction
        
        
          //----------------------------------------------------------------------------
          // Group -- NODOCS --  Message Element APIs
          //----------------------------------------------------------------------------
        
        
          // Function -- NODOCS -- add_int
          // 
          // This method adds an integral type of the name ~name~ and value ~value~ to
          // the message.  The required ~size~ field indicates the size of ~value~. 
          // The required ~radix~ field determines how to display and 
          // record the field. The optional print/record bit is to specify whether 
          // the element will be printed/recorded.
          //
        
%000000   virtual function void add_int(string name, uvm_bitstream_t value, 
                                        int size, uvm_radix_enum radix, 
                                        uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     _report_message_element_container.add_int(name, value, size, radix, action);
          endfunction
        
        
          // Function -- NODOCS -- add_string
          // 
          // This method adds a string of the name ~name~ and value ~value~ to the 
          // message. The optional print/record bit is to specify whether 
          // the element will be printed/recorded.
          //
        
%000000   virtual function void add_string(string name, string value,
                                           uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     _report_message_element_container.add_string(name, value, action);
          endfunction
        
        
          // Function -- NODOCS -- add_object
          // 
          // This method adds a uvm_object of the name ~name~ and reference ~obj~ to
          // the message. The optional print/record bit is to specify whether 
          // the element will be printed/recorded. 
          //
        
%000000   virtual function void add_object(string name, uvm_object obj,
                                           uvm_action action = (UVM_LOG|UVM_RM_RECORD));
%000000     _report_message_element_container.add_object(name, obj, action);
          endfunction
        
        endclass
        
        
        `endif
        
