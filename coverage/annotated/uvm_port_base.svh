//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2012-2017 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2021 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2018 Synopsys, Inc.
        // Copyright 2017 Verific
        //   All Rights Reserved Worldwide
        //
        //   Licensed under the Apache License, Version 2.0 (the "License"); you may not
        //   use this file except in compliance with the License.  You may obtain a copy
        //   of the License at
        //
        //       http://www.apache.org/licenses/LICENSE-2.0
        //
        //   Unless required by applicable law or agreed to in writing, software
        //   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
        //   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
        //   License for the specific language governing permissions and limitations
        //   under the License.
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_port_base.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
%000003 const int UVM_UNBOUNDED_CONNECTIONS = -1;
%000003 const string s_connection_error_id = "Connection Error";
%000003 const string s_connection_warning_id = "Connection Warning";
%000003 const string s_spaces = "                       ";
        
        typedef class uvm_port_component_base;
        
        
        // TITLE: Port Base Classes
        //
        
        
        //
        // CLASS: uvm_port_list
        //
        // Associative array of uvm_port_component_base class handles, indexed by string
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        typedef uvm_port_component_base uvm_port_list[string];
        
        //------------------------------------------------------------------------------
        //
        // CLASS: uvm_port_component_base
        //
        //------------------------------------------------------------------------------
        // This class defines an interface for obtaining a port's connectivity lists
        // after or during the end_of_elaboration phase.  The sub-class,
        // <uvm_port_component #(PORT)>, implements this interface.
        //
        // Each port's full name and type name can be retrieved using ~get_full_name~ 
        // and ~get_type_name~ methods inherited from <uvm_component>.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        //------------------------------------------------------------------------------
        
        virtual class uvm_port_component_base extends uvm_component;
           
 000081   function new (string name, uvm_component parent);
 000081     super.new(name,parent);
          endfunction
        
          // Function: get_connected_to
          //
          // For a port or export type, this function fills ~list~ with all
          // of the ports, exports and implementations that this port is
          // connected to.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
%000000   pure virtual function void get_connected_to(ref uvm_port_list list);
          
          // Function -- NODOCS -- get_provided_to
          //
          // For an implementation or export type, this function fills ~list~ with all
          // of the ports, exports and implementations that this port is
          // provides its implementation to.
          // @uvm_compat
%000000   pure virtual function void get_provided_to(ref uvm_port_list list);
        
        
          // Function -- NODOCS -- is_port
          //
%000000   pure virtual function bit is_port();
        
          // Function -- NODOCS -- is_export
          //
%000000   pure virtual function bit is_export();
        
          // Function -- NODOCS -- is_imp
          //
          // These function determine the type of port. The functions are
          // mutually exclusive; one will return 1 and the other two will
          // return 0.
        
%000000   pure virtual function bit is_imp();
        
          // Turn off auto config 
 000081   virtual function bit use_automatic_config();
 000081     return 0;
          endfunction : use_automatic_config    
           
%000000   virtual task do_task_phase (uvm_phase phase);
          endtask
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS: uvm_port_component #(PORT)
        //
        //------------------------------------------------------------------------------
        // This implementation of uvm_port_component class from IEEE 1800.2 declares all the
        // API described in the LRM, plus it inherits from uvm_port_component_base for the
        // purpose of providing the get_connected_to() method.
        //
        // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        //------------------------------------------------------------------------------
        class uvm_port_component #(type PORT=uvm_object) extends uvm_port_component_base;
          
          PORT m_port;
        
~000075   function new (string name, uvm_component parent, PORT port);
~000075     super.new(name,parent);
~000075     if (port == null) begin
              
%000000       uvm_report_fatal("Bad usage", "Null handle to port", UVM_NONE);
            end
        
~000075     m_port = port;
          endfunction
        
~000123   virtual function string get_type_name();
~000048     if(m_port == null) begin
%000000       return "uvm_port_component";
            end
        
~000123     return m_port.get_type_name();
          endfunction
            
~000075   virtual function void resolve_bindings();
~000075     m_port.resolve_bindings();
          endfunction
          
          // Function -- NODOCS -- get_port
          //
          // Retrieve the actual port object that this proxy refers to.
        
%000000   function PORT get_port();
%000000     return m_port;
          endfunction
        
          // Function: get_connected_to
          //
          // Implementation of the pure function declared in uvm_port_component_base
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
%000000   virtual function void get_connected_to(ref uvm_port_list list);
        
%000000     PORT list1[string];
%000000     m_port.get_connected_to(list1);
%000000     list.delete();
%000000     foreach(list1[name]) begin
%000000       list[name] = list1[name].get_comp();
            end
          
          endfunction
          
%000000   virtual function void get_provided_to(ref uvm_port_list list);
        
%000000     PORT list1[string];
%000000     m_port.get_provided_to(list1);
%000000     list.delete();
%000000     foreach(list1[name]) begin
%000000       list[name] = list1[name].get_comp();
            end
          endfunction  
        
%000000   function bit is_port ();
%000000     return m_port.is_port();
          endfunction
        
%000000   function bit is_export ();
%000000     return m_port.is_export();
          endfunction
        
%000000   function bit is_imp ();
%000000     return m_port.is_imp();
          endfunction
        
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_port_base #(IF)
        //
        //------------------------------------------------------------------------------
        //
        // Transaction-level communication between components is handled via its ports,
        // exports, and imps, all of which derive from this class.
        //
        // The uvm_port_base extends IF, which is the type of the interface implemented
        // by derived port, export, or implementation. IF is also a type parameter to
        // uvm_port_base.
        //
        //   IF  - The interface type implemented by the subtype to this base port
        //
        // The UVM provides a complete set of ports, exports, and imps to enable transaction-level communication between entities.
        // They can be found in the ../src/tlm*/ directory. See Section 12.1 of the IEEE Spec for details.
        //
        // Just before <uvm_component::end_of_elaboration_phase>, an internal
        // <uvm_component::resolve_bindings> process occurs, after which each port and
        // export holds a list of all imps connected to it via hierarchical connections
        // to other ports and exports. In effect, we are collapsing the port's fanout,
        // which can span several levels up and down the component hierarchy, into a
        // single array held local to the port. Once the list is determined, the port's
        // min and max connection settings can be checked and enforced.
        //
        // uvm_port_base possesses the properties of components in that they have a
        // hierarchical instance path and parent. Because SystemVerilog does not support
        // multiple inheritance, uvm_port_base cannot extend both the interface it
        // implements and <uvm_component>. Thus, uvm_port_base contains a local instance
        // of uvm_component, to which it delegates such commands as get_name,
        // get_full_name, and get_parent.
        // The connectivity lists are returned in the form of handles to objects of this
        // type. This allowing traversal of any port's fan-out and fan-in network
        // through recursive calls to <get_connected_to> and <get_provided_to>. 
        //
        //------------------------------------------------------------------------------
        
        // Class: uvm_port_base
        // The library implements the following public API beyond what is documented
        // in 1800.2.
        
        // @uvm-ieee 1800.2-2020 auto 5.5.1
        virtual class uvm_port_base #(type IF=uvm_void) extends IF;
           
        
          typedef uvm_port_base #(IF) this_type;
          
          // local, protected, and non-user properties
          protected int unsigned  m_if_mask;
          protected this_type     m_if;    // REMOVE
          protected int unsigned  m_def_index;
          uvm_port_component #(this_type) m_comp;
          local this_type m_provided_by[string];
          local this_type m_provided_to[string];
          local uvm_port_type_e   m_port_type;
          local int               m_min_size;
          local int               m_max_size;
          local bit               m_resolved;
          local this_type         m_imp_list[string];
        
          // Function -- NODOCS -- new
          //
          // The first two arguments are the normal <uvm_component> constructor
          // arguments.
          //
          // The ~port_type~ can be one of <UVM_PORT>, <UVM_EXPORT>, or
          // <UVM_IMPLEMENTATION>.
          //
          // The ~min_size~ and ~max_size~ specify the minimum and maximum number of
          // implementation (imp) ports that must be connected to this port base by the
          // end of elaboration. Setting ~max_size~ to ~UVM_UNBOUNDED_CONNECTIONS~ sets no
          // maximum, i.e., an unlimited number of connections are allowed.
          //
          // By default, the parent/child relationship of any port being connected to
          // this port is not checked. This can be overridden by configuring the
          // port's ~check_connection_relationships~ bit via ~uvm_config_int::set()~. See
          // <connect> for more information.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.1
~000075   function new (string name,
                        uvm_component parent,
                        uvm_port_type_e port_type,
                        int min_size=0,
                        int max_size=1);
~000075     uvm_component comp;
~000075     int tmp;
~000075     m_port_type = port_type;
~000075     m_min_size  = min_size;
~000075     m_max_size  = max_size;
~000075     m_comp = new(name, parent, this);
        
~000075     if (!uvm_config_int::get(m_comp, "", "check_connection_relationships",tmp)) begin
              
~000075       m_comp.set_report_id_action(s_connection_warning_id, UVM_NO_ACTION);
            end
        
        
          endfunction
        
        
          // Function -- NODOCS -- get_name
          //
          // Returns the leaf name of this port. 
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.2
%000000   function string get_name();
%000000     return m_comp.get_name();
          endfunction
        
        
          // Function -- NODOCS -- get_full_name
          //
          // Returns the full hierarchical name of this port. 
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.3
~000084   virtual function string get_full_name();
~000084     return m_comp.get_full_name();
          endfunction
        
        
          // Function -- NODOCS -- get_parent
          //
          // Returns the handle to this port's parent, or ~null~ if it has no parent.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.4
%000006   virtual function uvm_component get_parent();
%000006     return m_comp.get_parent();
          endfunction
        
        
          // Function: get_comp
          //
          // Returns a handle to the internal proxy component representing this port.
          //
          // Ports are considered components. However, they do not inherit
          // <uvm_component>. Instead, they contain an instance of
          // <uvm_port_component #(PORT)> that serves as a proxy to this port.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
%000000   virtual function uvm_port_component_base get_comp();
%000000     return m_comp;
          endfunction
        
        
          // Function -- NODOCS -- get_type_name
          //
          // Returns the type name to this port. Derived port classes must implement
          // this method to return the concrete type. Otherwise, only a generic
          // "uvm_port", "uvm_export" or "uvm_implementation" is returned.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.5
%000000   virtual function string get_type_name();
%000000     case( m_port_type )
%000000       UVM_PORT : begin
%000000         return "port";
              end
        
%000000       UVM_EXPORT : begin
%000000         return "export";
              end
        
%000000       UVM_IMPLEMENTATION : begin
%000000         return "implementation";
              end
        
            endcase
          endfunction
        
        
          // Function -- NODOCS -- min_size
          //
          // Returns the minimum number of implementation ports that must
          // be connected to this port by the end_of_elaboration phase.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.7
~000420   function int max_size ();
~000420     return m_max_size;
          endfunction
        
        
          // Function -- NODOCS -- max_size
          //
          // Returns the maximum number of implementation ports that must
          // be connected to this port by the end_of_elaboration phase.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.6
~000075   function int min_size ();
~000075     return m_min_size;
          endfunction
        
        
          // Function -- NODOCS -- is_unbounded
          //
          // Returns 1 if this port has no maximum on the number of implementation
          // ports this port can connect to. A port is unbounded when the ~max_size~
          // argument in the constructor is specified as ~UVM_UNBOUNDED_CONNECTIONS~.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.8
%000000   function bit is_unbounded ();
%000000     return (m_max_size ==  UVM_UNBOUNDED_CONNECTIONS);
          endfunction
        
        
          // Function -- NODOCS -- is_port
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.11
%000009   function bit is_port ();
%000009     return m_port_type == UVM_PORT;
          endfunction
        
          // Function -- NODOCS -- is_export
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.11
~000018   function bit is_export ();
~000018     return m_port_type == UVM_EXPORT;
          endfunction
        
          // Function -- NODOCS -- is_imp
          //
          // Returns 1 if this port is of the type given by the method name,
          // 0 otherwise.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.11
~000090   function bit is_imp ();
~000090     return m_port_type == UVM_IMPLEMENTATION;
          endfunction
        
        
          // Function -- NODOCS -- size
          //
          // Gets the number of implementation ports connected to this port. The value
          // is not valid before the end_of_elaboration phase, as port connections have
          // not yet been resolved.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.12
~006753   function int size ();
~006753     return m_imp_list.num();
          endfunction
        
        
~000048   function void set_if (int index=0);
~000048     m_if = get_if(index);
~000048     if (m_if != null) begin
              
~000048       m_def_index = index;
            end
        
          endfunction
        
%000000   function int m_get_if_mask();
%000000     return m_if_mask;
          endfunction
        
        
          // Function -- NODOCS -- set_default_index
          // 
          // Sets the default implementation port to use when calling an interface
          // method. This method should only be called on UVM_EXPORT types. The value
          // must not be set before the end_of_elaboration phase, when port connections
          // have not yet been resolved.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.13
%000000   function void set_default_index (int index);
%000000     m_def_index = index;
          endfunction
        
        
          // Function -- NODOCS -- connect
          //
          // Connects this port to the given ~provider~ port. The ports must be 
          // compatible in the following ways
          //
          // - Their type parameters must match
          //
          // - The ~provider~'s interface type (blocking, non-blocking, analysis, etc.)
          //   must be compatible. Each port has an interface mask that encodes the
          //   interface(s) it supports. If the bitwise AND of these masks is equal to
          //   the this port's mask, the requirement is met and the ports are
          //   compatible. For example, a uvm_blocking_put_port #(T) is compatible with
          //   a uvm_put_export #(T) and uvm_blocking_put_imp #(T) because the export
          //   and imp provide the interface required by the uvm_blocking_put_port.
          // 
          // - Ports of type <UVM_EXPORT> can only connect to other exports or imps.
          //
          // - Ports of type <UVM_IMPLEMENTATION> cannot be connected, as they are
          //   bound to the component that implements the interface at time of
          //   construction.
          //
          // In addition to type-compatibility checks, the relationship between this
          // port and the ~provider~ port will also be checked if the port's
          // ~check_connection_relationships~ configuration has been set. (See <new>
          // for more information.)
          //
          // Relationships, when enabled, are checked are as follows:
          //
          // - If this port is an UVM_PORT type, the ~provider~ can be a parent port,
          //   or a sibling export or implementation port.
          //
          // - If this port is a <UVM_EXPORT> type, the provider can be a child
          //   export or implementation port.
          //
          // If any relationship check is violated, a warning is issued.
          //
          // Note- the <uvm_component::connect_phase> method is related to but not the same
          // as this method. The component's ~connect~ method is a phase callback where
          // port's ~connect~ method calls are made.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.14
~000012   virtual function void connect (this_type provider);
~000012      uvm_root top;
~000012      uvm_coreservice_t cs;
~000012      cs = uvm_coreservice_t::get();
~000012      top = cs.get_root();
~000012     if (end_of_elaboration_ph.get_state() == UVM_PHASE_EXECUTING || // TBD tidy
%000000         end_of_elaboration_ph.get_state() == UVM_PHASE_DONE ) begin
%000000       m_comp.uvm_report_warning("Late Connection", 
%000000          {"Attempt to connect ",this.get_full_name()," (of type ",this.get_type_name(),
%000000           ") at or after end_of_elaboration phase.  Ignoring."});
%000000       return;
            end
        
~000012     if (provider == null) begin
%000000       m_comp.uvm_report_error(s_connection_error_id,
%000000                        "Cannot connect to null port handle", UVM_NONE);
%000000       return;
            end
            
~000012     if (provider == this) begin
%000000       m_comp.uvm_report_error(s_connection_error_id,
%000000                        "Cannot connect a port instance to itself", UVM_NONE);
%000000       return;
            end
        
~000012     if ((provider.m_if_mask & m_if_mask) != m_if_mask) begin
%000000       m_comp.uvm_report_error(s_connection_error_id, 
%000000         {provider.get_full_name(),
%000000          " (of type ",provider.get_type_name(),
%000000          ") does not provide the complete interface required of this port (type ",
%000000          get_type_name(),")"}, UVM_NONE);
%000000       return;
            end
        
            // IMP.connect(anything) is illegal
~000012     if (is_imp()) begin
%000000       m_comp.uvm_report_error(s_connection_error_id,
%000000         $sformatf(
%000000 "Cannot call an imp port's connect method. An imp is connected only to the component passed in its constructor. (You attempted to bind this imp to %s)", provider.get_full_name()), UVM_NONE);
%000000       return;
            end
          
            // EXPORT.connect(PORT) are illegal
~000012     if (is_export() && provider.is_port()) begin
%000000       m_comp.uvm_report_error(s_connection_error_id,
%000000         $sformatf(
%000000 "Cannot connect exports to ports Try calling port.connect(export) instead. (You attempted to bind this export to %s).", provider.get_full_name()), UVM_NONE);
%000000       return;
            end
          
~000012     void'(m_check_relationship(provider));
          
~000012     m_provided_by[provider.get_full_name()] = provider;
~000012     provider.m_provided_to[get_full_name()] = this;
            
          endfunction
        
        
          // Function: debug_connected_to
          //
          // The ~debug_connected_to~ method outputs a visual text display of the
          // port/export/imp network to which this port connects (i.e., the port's
          // fanout).
          //
          // This method must not be called before the end_of_elaboration phase, as port
          // connections are not resolved until then.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        
%000000   function void debug_connected_to (int level=0, int max_level=-1);
%000000     int sz, num, curr_num;
%000000     string s_sz;
%000000     static string indent, save;
%000000     this_type port;
          
%000000     if (level <  0) begin
%000000       level = 0;
            end
        
%000000     if (level == 0) begin save = ""; indent="  "; end
          
%000000     if (max_level != -1 && level >= max_level) begin
              
%000000       return;
            end
        
          
%000000     num = m_provided_by.num();
          
%000000     if (m_provided_by.num() != 0) begin
%000000       foreach (m_provided_by[nm]) begin
%000000         curr_num++;
%000000         port = m_provided_by[nm];
%000000         save = {save, indent, "  | \n"};
%000000         save = {save, indent, "  |_",nm," (",port.get_type_name(),")\n"};
%000000         indent = (num > 1 && curr_num != num) ?  {indent,"  | "}:{indent, "    "};
%000000         port.debug_connected_to(level+1, max_level);
%000000         indent = indent.substr(0,indent.len()-4-1);
              end
            end
          
%000000     if (level == 0) begin
%000000       if (save != "") begin
                
%000000         save = {"This port's fanout network:\n\n  ",
%000000                get_full_name()," (",get_type_name(),")\n",save,"\n"};
              end
        
%000000       if (m_imp_list.num() == 0) begin
%000000         uvm_root top;
%000000         uvm_coreservice_t cs;
%000000         cs = uvm_coreservice_t::get();
%000000         top = cs.get_root();
%000000         if (end_of_elaboration_ph.get_state() == UVM_PHASE_EXECUTING ||
%000000         end_of_elaboration_ph.get_state() == UVM_PHASE_DONE ) begin  // TBD tidy
                   
%000000           save = {save,"  Connected implementations: none\n"};
                end
        
%000000         else begin
                   
%000000           save = {save,
%000000                  "  Connected implementations: not resolved until end-of-elab\n"};
                end
        
              end
%000000       else begin
%000000         save = {save,"  Resolved implementation list:\n"};
%000000         foreach (m_imp_list[nm]) begin
%000000           port = m_imp_list[nm];
%000000           s_sz.itoa(sz);
%000000           save = {save, indent, s_sz, ": ",nm," (",port.get_type_name(),")\n"};
%000000           sz++;
                end
              end
%000000       m_comp.uvm_report_info("debug_connected_to", save);
            end
          endfunction
          
        
          // Function: debug_provided_to
          //
          // The ~debug_provided_to~ method outputs a visual display of the port/export
          // network that ultimately connect to this port (i.e., the port's fanin).
          //
          // This method must not be called before the end_of_elaboration phase, as port
          // connections are not resolved until then.
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
        
%000000   function void debug_provided_to  (int level=0, int max_level=-1);
%000000     string nm;
%000000     int num,curr_num;
%000000     this_type port;
%000000     static string indent, save;
          
%000000     if (level <  0) begin
%000000       level = 0;
            end
         
%000000     if (level == 0) begin save = ""; indent = "  "; end
        
%000000     if (max_level != -1 && level > max_level) begin
              
%000000       return;
            end
        
          
%000000     num = m_provided_to.num();
          
%000000     if (num != 0) begin
%000000       foreach (m_provided_to[nm]) begin
%000000         curr_num++;
%000000         port = m_provided_to[nm];
%000000         save = {save, indent, "  | \n"};
%000000         save = {save, indent, "  |_",nm," (",port.get_type_name(),")\n"};
%000000         indent = (num > 1 && curr_num != num) ?  {indent,"  | "}:{indent, "    "};
%000000         port.debug_provided_to(level+1, max_level);
%000000         indent = indent.substr(0,indent.len()-4-1);
              end
            end
        
%000000     if (level == 0) begin
%000000       if (save != "") begin
                
%000000         save = {"This port's fanin network:\n\n  ",
%000000                get_full_name()," (",get_type_name(),")\n",save,"\n"};
              end
        
%000000       if (m_provided_to.num() == 0) begin
                
%000000         save = {save,indent,"This port has not been bound\n"};
              end
        
%000000       m_comp.uvm_report_info("debug_provided_to", save);
            end
          
          endfunction
        
        
          // get_connected_to
          // ----------------
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.9
%000000   function void get_connected_to (ref uvm_port_base #(IF) list[string]);
%000000     this_type port;
%000000     list.delete();
%000000     foreach (m_provided_by[name]) begin
%000000       port = m_provided_by[name];
%000000       list[name] = port;
            end
          endfunction
        
        
          // get_provided_to
          // ---------------
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.10
%000000   function void get_provided_to (ref uvm_port_base #(IF) list[string]);
%000000     this_type port;
%000000     list.delete();
%000000     foreach (m_provided_to[name]) begin
%000000       port = m_provided_to[name];
%000000       list[name] = port;
            end
          endfunction
        
        
          // m_check_relationship
          // --------------------
        
~000012   local function bit  m_check_relationship (this_type provider);  
~000012     string s;
~000012     this_type from;
~000012     uvm_component from_parent;
~000012     uvm_component to_parent;
~000012     uvm_component from_gparent;
~000012     uvm_component to_gparent;
          
            // Checks that the connection is between ports that are hierarchically
            // adjacent (up or down one level max, or are siblings),
            // and check for legal direction, requirer.connect(provider).
        
            // if we're an analysis port, allow connection to anywhere
%000003     if (get_type_name() == "uvm_analysis_port") begin
              
%000000       return 1;
            end
        
            
~000012     from         = this;
~000012     from_parent  = get_parent();
~000012     to_parent    = provider.get_parent();
          
            // skip check if we have a parentless port
%000003     if (from_parent == null || to_parent == null) begin
              
%000000       return 1;
            end
        
          
~000012     from_gparent = from_parent.get_parent();
~000012     to_gparent   = to_parent.get_parent();
          
            // Connecting port-to-port: CHILD.port.connect(PARENT.port)
            //
%000000     if (from.is_port() && provider.is_port() && from_gparent != to_parent) begin
%000000       s = {provider.get_full_name(),
%000000            " (of type ",provider.get_type_name(),
%000000            ") is not up one level of hierarchy from this port. ",
%000000            "A port-to-port connection takes the form ",
%000000            "child_component.child_port.connect(parent_port)"};
%000000       m_comp.uvm_report_warning(s_connection_warning_id, s, UVM_NONE);
%000000       return 0;
            end    
              
            // Connecting port-to-export: SIBLING.port.connect(SIBLING.export)
            // Connecting port-to-imp:    SIBLING.port.connect(SIBLING.imp)
            //
%000000     else if (from.is_port() && (provider.is_export() || provider.is_imp()) &&
%000000              from_gparent != to_gparent) begin
%000000       s = {provider.get_full_name(),
%000000            " (of type ",provider.get_type_name(),
%000000            ") is not at the same level of hierarchy as this port. ",
%000000            "A port-to-export connection takes the form ",
%000000            "component1.port.connect(component2.export)"};
%000000       m_comp.uvm_report_warning(s_connection_warning_id, s, UVM_NONE);
%000000       return 0;
            end
          
            // Connecting export-to-export: PARENT.export.connect(CHILD.export)
            // Connecting export-to-imp:    PARENT.export.connect(CHILD.imp)
            //
%000003     else if (from.is_export() && (provider.is_export() || provider.is_imp()) &&
%000000              from_parent != to_gparent) begin
%000000       s = {provider.get_full_name(),
%000000            " (of type ",provider.get_type_name(),
%000000            ") is not down one level of hierarchy from this export. ",
%000000            "An export-to-export or export-to-imp connection takes the form ",
%000000            "parent_export.connect(child_component.child_export)"};
%000000       m_comp.uvm_report_warning(s_connection_warning_id, s, UVM_NONE);
%000000       return 0;
            end
        
~000012     return 1;
          endfunction
        
        
          // m_add_list
          //
          // Internal method.
        
~000012   local function void m_add_list           (this_type provider);
~000012     string sz;
~000012     this_type imp;
        
~000012     for (int i = 0; i < provider.size(); i++) begin
~000012       imp = provider.get_if(i);
~000012       if (!m_imp_list.exists(imp.get_full_name())) begin
                
~000012         m_imp_list[imp.get_full_name()] = imp;
              end
        
            end
        
          endfunction
        
        
          // Function -- NODOCS -- resolve_bindings
          //
          // This callback is called just before entering the end_of_elaboration phase.
          // It recurses through each port's fanout to determine all the imp 
          // destinations. It then checks against the required min and max connections.
          // After resolution, <size> returns a valid value and <get_if>
          // can be used to access a particular imp.
          //
          // This method is automatically called just before the start of the
          // end_of_elaboration phase. Users should not need to call it directly.
        
          // @uvm-ieee 1800.2-2020 auto 5.5.2.15
~000087   virtual function void resolve_bindings();
~000075     if (m_resolved) begin // don't repeat ourselves
             
%000000       return;
            end
        
        
~000039     if (is_imp()) begin
~000036       m_imp_list[get_full_name()] = this;
            end
~000039     else begin
~000039       foreach (m_provided_by[nm]) begin
~000012         this_type port;
~000012         port = m_provided_by[nm];
~000012         port.resolve_bindings();
~000012         m_add_list(port);
              end
            end
          
~000087     m_resolved = 1;
          
~000075     if (size() < min_size() ) begin
%000000       m_comp.uvm_report_error(s_connection_error_id, 
%000000         $sformatf("connection count of %0d does not meet required minimum of %0d",
%000000         size(), min_size()), UVM_NONE);
            end
          
~000075     if (max_size() != UVM_UNBOUNDED_CONNECTIONS && size() > max_size() ) begin
%000000       m_comp.uvm_report_error(s_connection_error_id, 
%000000         $sformatf("connection count of %0d exceeds maximum of %0d",
%000000         size(), max_size()), UVM_NONE);
            end
        
~000048     if (size()) begin
              
~000048       set_if(0);
            end
        
          
          endfunction
          
        
          // Function -- NODOCS -- get_if
          //
          // Returns the implementation (imp) port at the given index from the array of
          // imps this port is connected to. Use <size> to get the valid range for index.
          // This method can only be called at the end_of_elaboration phase or after, as
          // port connections are not resolved before then.
        
~000831   function uvm_port_base #(IF) get_if(int index=0);
~000831     string s;
~000831     if (size()==0) begin
%000000       m_comp.uvm_report_warning("get_if",
%000000         "Port size is zero; cannot get interface at any index", UVM_NONE);
%000000       return null;
            end
~000831     if (index < 0 || index >= size()) begin
%000000       $sformat(s, "Index %0d out of range [0,%0d]", index, size()-1);
%000000       m_comp.uvm_report_warning(s_connection_error_id, s, UVM_NONE);
%000000       return null;
            end
~000831     foreach (m_imp_list[nm]) begin
%000000       if (index == 0) begin
                
%000000         return m_imp_list[nm];
              end
        
%000000       index--;
            end
          endfunction
        
        endclass
        
