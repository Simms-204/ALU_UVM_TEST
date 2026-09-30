//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2011 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2018 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2007-2020 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
        // Copyright 2018 Qualcomm, Inc.
        // Copyright 2011-2014 Synopsys, Inc.
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
        // $File:     src/base/uvm_registry.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_REGISTRY_SVH
        `define UVM_REGISTRY_SVH
        
        //------------------------------------------------------------------------------
        // Title: Factory Component and Object Wrappers
        //
        // This section defines the proxy component and object classes used by the
        // factory. 
        //------------------------------------------------------------------------------
        
        typedef class uvm_registry_common;
        typedef class uvm_registry_component_creator;
        typedef class uvm_registry_object_creator;
        
        // Class: uvm_component_registry#(T,Tname)
        // Implementation of uvm_component_registry#(T,Tname), as defined by section
        // 8.2.3.1 of 1800.2-2020.
          
        // @uvm-ieee 1800.2-2020 auto 8.2.3.1
%000003 class uvm_component_registry #(type T=uvm_component, string Tname="<unknown>")
                                                   extends uvm_object_wrapper;
          typedef uvm_component_registry #(T,Tname) this_type;
          typedef uvm_registry_common#( this_type, uvm_registry_component_creator, T, Tname ) common_type;
        
          // Function -- NODOCS -- create_component
          //
          // Creates a component of type T having the provided ~name~ and ~parent~.
          // This is an override of the method in <uvm_object_wrapper>. It is
          // called by the factory after determining the type of object to create.
          // You should not call this method directly. Call <create> instead.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.1
%000003   virtual function uvm_component create_component (string name,
                                                           uvm_component parent);
%000003     T obj;
%000003     obj = new(name, parent);
%000003     return obj;
          endfunction
        
        
%000000    static function string type_name();
%000000      return common_type::type_name();
           endfunction : type_name
        
          // Function -- NODOCS -- get_type_name
          //
          // Returns the value given by the string parameter, ~Tname~. This method
          // overrides the method in <uvm_object_wrapper>.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.2
~000012   virtual function string get_type_name();
~000012      common_type common = common_type::get();
~000012      return common.get_type_name();
          endfunction
        
          // @uvm-ieee 1800.2-2020 manual 8.2.4.2.3
%000009   static function this_type get();
%000009      static this_type m_inst;
%000006      if (m_inst == null) begin
               
%000003        m_inst = new();
             end
        
%000009     return m_inst;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.7
%000003   virtual function void initialize();
%000003      common_type common = common_type::get();
%000003      common.initialize();
          endfunction
        
        
          // Function -- NODOCS -- create
          //
          // Returns an instance of the component type, ~T~, represented by this proxy,
          // subject to any factory overrides based on the context provided by the
          // ~parent~'s full name. The ~contxt~ argument, if supplied, supersedes the
          // ~parent~'s context. The new instance will have the given leaf ~name~
          // and ~parent~.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.4
%000003   static function T create(string name, uvm_component parent, string contxt="");
%000003     return common_type::create( name, parent, contxt );
          endfunction
        
        
          // Function -- NODOCS -- set_type_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type,
          // ~T~, represented by this proxy, provided no instance override applies. The
          // original type, ~T~, is typically a super class of the override type.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.5
%000000   static function void set_type_override (uvm_object_wrapper override_type,
                                                  bit replace=1);
%000000     common_type::set_type_override( override_type, replace );
          endfunction
        
        
          // Function -- NODOCS -- set_inst_override
          //
          // Configures the factory to create a component of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type,
          // ~T~, represented by this proxy,  with matching instance paths. The original
          // type, ~T~, is typically a super class of the override type.
          //
          // If ~parent~ is not specified, ~inst_path~ is interpreted as an absolute
          // instance path, which enables instance overrides to be set from outside
          // component classes. If ~parent~ is specified, ~inst_path~ is interpreted
          // as being relative to the ~parent~'s hierarchical instance path, i.e.
          // ~{parent.get_full_name(),".",inst_path}~ is the instance path that is
          // registered with the override. The ~inst_path~ may contain wildcards for
          // matching against multiple contexts.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.3.2.6
%000000   static function void set_inst_override(uvm_object_wrapper override_type,
                                                 string inst_path,
                                                 uvm_component parent=null);
%000000     common_type::set_inst_override( override_type, inst_path, parent );
          endfunction
        
          // Function: set_type_alias
          // Sets a type alias for this wrapper in the default factory.
          //
          // If this wrapper is not yet registered with a factory (see <uvm_factory::register>),
          // then the alias is deferred until registration occurs.
          //
          // @uvm-contrib This API is being considered for potential contribution to 1800.2
%000000   static function bit set_type_alias(string alias_name);
%000000      common_type::set_type_alias( alias_name );
%000000      return 1;
          endfunction
        
        endclass
        
        
        // Class: uvm_object_registry#(T,Tname)
        // Implementation of uvm_object_registry#(T,Tname), as defined by section
        // 8.2.4.1 of 1800.2-2020.
        
        // @uvm-ieee 1800.2-2020 auto 8.2.4.1
%000003 class uvm_object_registry #(type T=uvm_object, string Tname="<unknown>")
                                                extends uvm_object_wrapper;
          typedef uvm_object_registry #(T,Tname) this_type;
          typedef uvm_registry_common#( this_type, uvm_registry_object_creator, T, Tname ) common_type;
        
          // Function -- NODOCS -- create_object
          //
          // Creates an object of type ~T~ and returns it as a handle to a
          // <uvm_object>. This is an override of the method in <uvm_object_wrapper>.
          // It is called by the factory after determining the type of object to create.
          // You should not call this method directly. Call <create> instead.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.1
~000780   virtual function uvm_object create_object(string name="");
~000780     T obj;
~000780     if (name=="") begin
%000003       obj = new();
            end
        
~000780     else begin
~000780       obj = new(name);
            end
        
~000780     return obj;
          endfunction
        
%000000   static function string type_name();
%000000      return common_type::type_name();
          endfunction : type_name
        
          // Function -- NODOCS -- get_type_name
          //
          // Returns the value given by the string parameter, ~Tname~. This method
          // overrides the method in <uvm_object_wrapper>.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.2
~000012   virtual function string get_type_name();
~000012      common_type common = common_type::get();
~000012      return common.get_type_name();
          endfunction
        
          //
          // Returns the singleton instance of this type. Type-based factory operation
          // depends on there being a single proxy instance for each registered type.
        
~001300   static function this_type get();
~001300      static this_type m_inst;
~001297      if (m_inst == null) begin
               
%000003        m_inst = new();
             end
        
~001300     return m_inst;
          endfunction
        
        
          // Function -- NODOCS -- create
          //
          // Returns an instance of the object type, ~T~, represented by this proxy,
          // subject to any factory overrides based on the context provided by the
          // ~parent~'s full name. The ~contxt~ argument, if supplied, supersedes the
          // ~parent~'s context. The new instance will have the given leaf ~name~,
          // if provided.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.4
~000780   static function T create (string name="", uvm_component parent=null,
                                    string contxt="");
~000780     return common_type::create( name, parent, contxt );
          endfunction
        
        
          // Function -- NODOCS -- set_type_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type
          // represented by this proxy, provided no instance override applies. The
          // original type, ~T~, is typically a super class of the override type.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.5
%000000   static function void set_type_override (uvm_object_wrapper override_type,
                                                  bit replace=1);
%000000     common_type::set_type_override( override_type, replace );
          endfunction
        
        
          // Function -- NODOCS -- set_inst_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type
          // represented by this proxy, with matching instance paths. The original
          // type, ~T~, is typically a super class of the override type.
          //
          // If ~parent~ is not specified, ~inst_path~ is interpreted as an absolute
          // instance path, which enables instance overrides to be set from outside
          // component classes. If ~parent~ is specified, ~inst_path~ is interpreted
          // as being relative to the ~parent~'s hierarchical instance path, i.e.
          // ~{parent.get_full_name(),".",inst_path}~ is the instance path that is
          // registered with the override. The ~inst_path~ may contain wildcards for
          // matching against multiple contexts.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.6
%000000   static function void set_inst_override(uvm_object_wrapper override_type,
                                                 string inst_path,
                                                 uvm_component parent=null);
%000000     common_type::set_inst_override( override_type, inst_path, parent );
          endfunction
        
          // Function: set_type_alias
          // Sets a type alias for this wrapper in the default factory.
          //
          // If this wrapper is not yet registered with a factory (see <uvm_factory::register>),
          // then the alias is deferred until registration occurs.
          //
          // @uvm-contrib This API is being considered for potential contribution to 1800.2
%000000   static function bit set_type_alias(string alias_name);
%000000      common_type::set_type_alias( alias_name );
%000000      return 1;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 8.2.4.2.7
%000003   virtual function void initialize();
%000003      common_type common = common_type::get();
%000003      common.initialize();
          endfunction
        endclass
        
        // Class: uvm_abstract_component_registry#(T,Tname)
        // Implementation of uvm_abstract_component_registry#(T,Tname), as defined by section
        // 8.2.5.1.1 of 1800.2-2020.
        
        // @uvm-ieee 1800.2-2020 auto 8.2.5.1.1
%000003 class uvm_abstract_component_registry #(type T=uvm_component, string Tname="<unknown>")
                                                   extends uvm_object_wrapper;
          typedef uvm_abstract_component_registry #(T,Tname) this_type;
          typedef uvm_registry_common#( this_type, uvm_registry_component_creator, T, Tname ) common_type;
        
          // Function -- NODOCS -- create_component
          //
          // Creates a component of type T having the provided ~name~ and ~parent~.
          // This is an override of the method in <uvm_object_wrapper>. It is
          // called by the factory after determining the type of object to create.
          // You should not call this method directly. Call <create> instead.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.5.1.2
%000000   virtual function uvm_component create_component (string name,
                                                           uvm_component parent);
            `uvm_error(
              "UVM/ABST_RGTRY/CREATE_ABSTRACT_CMPNT",
              $sformatf( "Cannot create an instance of abstract class %s (with name %s and parent %s). Check for missing factory overrides for %s.", this.get_type_name(), name, parent.get_full_name(), this.get_type_name() )
%000000     )
%000000     return null;
          endfunction
        
%000000   static function string type_name();
%000000      return common_type::type_name();
          endfunction : type_name
        
          // Function -- NODOCS -- get_type_name
          //
          // Returns the value given by the string parameter, ~Tname~. This method
          // overrides the method in <uvm_object_wrapper>.
        
~000012   virtual function string get_type_name();
~000012      common_type common = common_type::get();
~000012      return common.get_type_name();
          endfunction
        
        
          // Function -- NODOCS -- get
          //
          // Returns the singleton instance of this type. Type-based factory operation
          // depends on there being a single proxy instance for each registered type.
        
%000006   static function this_type get();
%000006     static this_type m_inst;
%000003      if (m_inst == null) begin
               
%000003        m_inst = new();
             end
        
%000006     return m_inst;
          endfunction
        
        
          // Function -- NODOCS -- create
          //
          // Returns an instance of the component type, ~T~, represented by this proxy,
          // subject to any factory overrides based on the context provided by the
          // ~parent~'s full name. The ~contxt~ argument, if supplied, supersedes the
          // ~parent~'s context. The new instance will have the given leaf ~name~
          // and ~parent~.
        
%000000   static function T create(string name, uvm_component parent, string contxt="");
%000000     return common_type::create( name, parent, contxt );
          endfunction
        
        
          // Function -- NODOCS -- set_type_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type,
          // ~T~, represented by this proxy, provided no instance override applies. The
          // original type, ~T~, is typically a super class of the override type.
        
%000000   static function void set_type_override (uvm_object_wrapper override_type,
                                                  bit replace=1);
%000000     common_type::set_type_override( override_type, replace );
          endfunction
        
        
          // Function -- NODOCS -- set_inst_override
          //
          // Configures the factory to create a component of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type,
          // ~T~, represented by this proxy,  with matching instance paths. The original
          // type, ~T~, is typically a super class of the override type.
          //
          // If ~parent~ is not specified, ~inst_path~ is interpreted as an absolute
          // instance path, which enables instance overrides to be set from outside
          // component classes. If ~parent~ is specified, ~inst_path~ is interpreted
          // as being relative to the ~parent~'s hierarchical instance path, i.e.
          // ~{parent.get_full_name(),".",inst_path}~ is the instance path that is
          // registered with the override. The ~inst_path~ may contain wildcards for
          // matching against multiple contexts.
        
%000000   static function void set_inst_override(uvm_object_wrapper override_type,
                                                 string inst_path,
                                                 uvm_component parent=null);
%000000     common_type::set_inst_override( override_type, inst_path, parent );
          endfunction
        
          // Function: set_type_alias
          // Sets a type alias for this wrapper in the default factory.
          //
          // If this wrapper is not yet registered with a factory (see <uvm_factory::register>),
          // then the alias is deferred until registration occurs.
          //
          // @uvm-contrib This API is being considered for potential contribution to 1800.2
%000000   static function bit set_type_alias(string alias_name);
%000000      common_type::set_type_alias( alias_name );
%000000      return 1;
          endfunction
        
%000003   virtual function void initialize();
%000003      common_type common = common_type::get();
%000003      common.initialize();
          endfunction
        endclass
        
        
        // Class: uvm_abstract_object_registry#(T,Tname)
        // Implementation of uvm_abstract_object_registry#(T,Tname), as defined by section
        // 8.2.5.2.1 of 1800.2-2020.
        
        // @uvm-ieee 1800.2-2020 auto 8.2.5.2.1
%000003 class uvm_abstract_object_registry #(type T=uvm_object, string Tname="<unknown>")
                                                extends uvm_object_wrapper;
          typedef uvm_abstract_object_registry #(T,Tname) this_type;
          typedef uvm_registry_common#( this_type, uvm_registry_object_creator, T, Tname ) common_type;
        
          // Function -- NODOCS -- create_object
          //
          // Creates an object of type ~T~ and returns it as a handle to a
          // <uvm_object>. This is an override of the method in <uvm_object_wrapper>.
          // It is called by the factory after determining the type of object to create.
          // You should not call this method directly. Call <create> instead.
        
          // @uvm-ieee 1800.2-2020 auto 8.2.5.2.2
%000000   virtual function uvm_object create_object(string name="");
            `uvm_error(
              "UVM/ABST_RGTRY/CREATE_ABSTRACT_OBJ",
              $sformatf( "Cannot create an instance of abstract class %s (with name %s). Check for missing factory overrides for %s.", this.get_type_name(), name, this.get_type_name() )
%000000     )
%000000     return null;
          endfunction
        
%000000   static function string type_name();
%000000      return common_type::type_name();
          endfunction : type_name
        
          // Function -- NODOCS -- get_type_name
          //
          // Returns the value given by the string parameter, ~Tname~. This method
          // overrides the method in <uvm_object_wrapper>.
        
~000012   virtual function string get_type_name();
~000012      common_type common = common_type::get();
~000012      return common.get_type_name();
          endfunction
        
          // Function -- NODOCS -- get
          //
          // Returns the singleton instance of this type. Type-based factory operation
          // depends on there being a single proxy instance for each registered type.
        
~000012   static function this_type get();
~000012     static this_type m_inst;
%000009      if (m_inst == null) begin
               
%000003        m_inst = new();
             end
        
~000012     return m_inst;
          endfunction
        
        
          // Function -- NODOCS -- create
          //
          // Returns an instance of the object type, ~T~, represented by this proxy,
          // subject to any factory overrides based on the context provided by the
          // ~parent~'s full name. The ~contxt~ argument, if supplied, supersedes the
          // ~parent~'s context. The new instance will have the given leaf ~name~,
          // if provided.
        
%000000   static function T create (string name="", uvm_component parent=null,
                                    string contxt="");
%000000     return common_type::create( name, parent, contxt );
          endfunction
        
        
          // Function -- NODOCS -- set_type_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type
          // represented by this proxy, provided no instance override applies. The
          // original type, ~T~, is typically a super class of the override type.
        
%000000   static function void set_type_override (uvm_object_wrapper override_type,
                                                  bit replace=1);
%000000     common_type::set_type_override( override_type, replace );
          endfunction
        
        
          // Function -- NODOCS -- set_inst_override
          //
          // Configures the factory to create an object of the type represented by
          // ~override_type~ whenever a request is made to create an object of the type
          // represented by this proxy, with matching instance paths. The original
          // type, ~T~, is typically a super class of the override type.
          //
          // If ~parent~ is not specified, ~inst_path~ is interpreted as an absolute
          // instance path, which enables instance overrides to be set from outside
          // component classes. If ~parent~ is specified, ~inst_path~ is interpreted
          // as being relative to the ~parent~'s hierarchical instance path, i.e.
          // ~{parent.get_full_name(),".",inst_path}~ is the instance path that is
          // registered with the override. The ~inst_path~ may contain wildcards for
          // matching against multiple contexts.
        
%000000   static function void set_inst_override(uvm_object_wrapper override_type,
                                                 string inst_path,
                                                 uvm_component parent=null);
%000000     common_type::set_inst_override( override_type, inst_path, parent );
          endfunction
        
          // Function: set_type_alias
          // Sets a type alias for this wrapper in the default factory.
          //
          // If this wrapper is not yet registered with a factory (see <uvm_factory::register>),
          // then the alias is deferred until registration occurs.
          //
          // @uvm-contrib This API is being considered for potential contribution to 1800.2
%000000   static function bit set_type_alias(string alias_name);
%000000      common_type::set_type_alias( alias_name );
%000000      return 1;
          endfunction
        
%000003   virtual function void initialize();
%000003      common_type common = common_type::get();
%000003      common.initialize();
          endfunction
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_registry_common #(T,Tname)
        //
        // This is a helper class which implements the functioanlity that is identical
        // between uvm_component_registry and uvm_abstract_component_registry.
        //
        //------------------------------------------------------------------------------
        
%000003 class uvm_registry_common #( type Tregistry=int, type Tcreator=int, type Tcreated=int, string Tname="<unknown>" );
        
          typedef uvm_registry_common#(Tregistry,Tcreator,Tcreated,Tname) this_type;
          local static string m__type_aliases[$];
        
~000012   static function string type_name();
~000012      if((Tname == "<unknown>") && (m__type_aliases.size() != 0)) begin
%000000        return m__type_aliases[0];
             end
~000012      return Tname;
          endfunction : type_name
        
~000012   virtual function string get_type_name();
~000012     return type_name();
          endfunction
        
~000015   static function this_type get();
~000015      static this_type m_inst;
~000012      if (m_inst == null) begin
               
%000003        m_inst = new();
             end
        
~000015      return m_inst;
          endfunction : get
        
~000780   static function Tcreated create(string name, uvm_component parent, string contxt);
~000780     uvm_object obj;
~000780     if (contxt == "" && parent != null) begin
              
%000003       contxt = parent.get_full_name();
            end
        
~000780     obj = Tcreator::create_by_type( Tregistry::get(), contxt, name, parent );
~000780     if (!$cast(create, obj)) begin
%000000       string msg;
%000000       msg = {"Factory did not return a ", Tcreator::base_type_name(), " of type '",Tregistry::type_name,
%000000         "'. A component of type '",obj == null ? "null" : obj.get_type_name(),
%000000         "' was returned instead. Name=",name," Parent=",
%000000         parent==null?"null":parent.get_type_name()," contxt=",contxt};
%000000       uvm_report_fatal("FCTTYP", msg, UVM_NONE);
            end
          endfunction
        
%000000   static function void set_type_override (uvm_object_wrapper override_type,
                                                  bit replace);
%000000     uvm_factory factory=uvm_factory::get();
        
%000000     factory.set_type_override_by_type(Tregistry::get(),override_type,replace);
          endfunction
        
%000000   static function void set_inst_override(uvm_object_wrapper override_type,
                                                 string inst_path,
                                                 uvm_component parent);
%000000     string full_inst_path;
%000000     uvm_factory factory=uvm_factory::get();
        
%000000     if (parent != null) begin
%000000       if (inst_path == "") begin
                
%000000         inst_path = parent.get_full_name();
              end
        
%000000       else begin
                
%000000         inst_path = {parent.get_full_name(),".",inst_path};
              end
        
            end
%000000     factory.set_inst_override_by_type(Tregistry::get(),override_type,inst_path);
          endfunction
        
%000000   static function void set_type_alias(string alias_name);
%000000      m__type_aliases.push_back(alias_name);
%000000      m__type_aliases.sort();
%000000      if (uvm_pkg::get_core_state() != UVM_CORE_UNINITIALIZED) begin
%000000        uvm_factory factory = uvm_factory::get();
%000000        Tregistry rgtry = Tregistry::get();
%000000        if (factory.is_type_registered(rgtry)) begin
%000000          factory.set_type_alias(alias_name,rgtry);
               end
             end
          endfunction
        
%000003   static function bit __deferred_init();
%000003      Tregistry rgtry = Tregistry::get();
             // If the core is uninitialized, we defer initialization
%000003      if (uvm_pkg::get_core_state() == UVM_CORE_UNINITIALIZED) begin
%000003        uvm_pkg::uvm_deferred_init.push_back(rgtry);
             end
             // If the core is initialized, then we're static racing,
             // initialize immediately
%000000      else begin
%000000        rgtry.initialize();
             end
%000003      return 1;
          endfunction
%000003   local static bit m__initialized=__deferred_init();
        
%000003   virtual function void initialize();
%000003      uvm_factory factory =uvm_factory::get();
%000003      Tregistry rgtry = Tregistry::get();
%000003      factory.register(rgtry);
             // add aliases that were set before
             // the wrapper was registered with the factory
%000003      foreach(m__type_aliases[i]) begin
%000000        factory.set_type_alias(m__type_aliases[i],rgtry);
             end
          endfunction
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // The next two classes are helper classes passed as type parameters to
        // uvm_registry_common.  They abstract away the function calls
        // uvm_factory::create_component_by_type  and
        // uvm_factory::create_object_by_type.  Choosing between the two is handled at
        // compile time..
        //
        //------------------------------------------------------------------------------
        
%000000 virtual class uvm_registry_component_creator;
        
 000024   static function uvm_component create_by_type(
            uvm_object_wrapper obj_wrpr,
            string contxt,
            string name,
            uvm_component parent
          );
 000024     uvm_coreservice_t cs = uvm_coreservice_t::get();
 000024     uvm_factory factory = cs.get_factory();
 000024     return factory.create_component_by_type( obj_wrpr, contxt, name, parent );
          endfunction
        
%000000   static function string base_type_name();  return "component"; endfunction
        endclass
        
%000000 virtual class uvm_registry_object_creator;
        
 001260   static function uvm_object create_by_type(
            uvm_object_wrapper obj_wrpr,
            string contxt,
            string name,
            uvm_object unused
          );
 001260     uvm_coreservice_t cs = uvm_coreservice_t::get();
 001260     uvm_factory factory = cs.get_factory();
 001260     unused = unused;  // ... to keep linters happy.
 001260     return factory.create_object_by_type( obj_wrpr, contxt, name );
          endfunction
        
%000000   static function string base_type_name();  return "object"; endfunction
        endclass
        
        
        
        // Group -- NODOCS -- Usage
        //
        // This section describes usage for the uvm_*_registry classes.
        //
        // The wrapper classes are used to register lightweight proxies of objects and
        // components.
        //
        // To register a particular component type, you need only typedef a
        // specialization of its proxy class, which is typically done inside the class.
        //
        // For example, to register a UVM component of type ~mycomp~
        //
        //|  class mycomp extends uvm_component;
        //|    typedef uvm_component_registry #(mycomp,"mycomp") type_id;
        //|  endclass
        //
        // However, because of differences between simulators, it is necessary to use a
        // macro to ensure vendor interoperability with factory registration. To
        // register a UVM component of type ~mycomp~ in a vendor-independent way, you
        // would write instead:
        //
        //|  class mycomp extends uvm_component;
        //|    `uvm_component_utils(mycomp)
        //|    ...
        //|  endclass
        //
        // The <`uvm_component_utils> macro is for non-parameterized classes. In this
        // example, the typedef underlying the macro specifies the ~Tname~
        // parameter as "mycomp", and ~mycomp~'s get_type_name() is defined to return
        // the same. With ~Tname~ defined, you can use the factory's name-based methods to
        // set overrides and create objects and components of non-parameterized types.
        //
        // For parameterized types, the type name changes with each specialization, so
        // you cannot specify a ~Tname~ inside a parameterized class and get the behavior
        // you want; the same type name string would be registered for all
        // specializations of the class! (The factory would produce warnings for each
        // specialization beyond the first.) To avoid the warnings and simulator
        // interoperability issues with parameterized classes, you must register
        // parameterized classes with a different macro.
        //
        // For example, to register a UVM component of type driver #(T), you
        // would write:
        //
        //|  class driver #(type T=int) extends uvm_component;
        //|    `uvm_component_param_utils(driver #(T))
        //|    ...
        //|  endclass
        //
        // The <`uvm_component_param_utils> and <`uvm_object_param_utils> macros are used
        // to register parameterized classes with the factory. Unlike the non-param
        // versions, these macros do not specify the ~Tname~ parameter in the underlying
        // uvm_component_registry typedef, and they do not define the get_type_name
        // method for the user class. Consequently, you will not be able to use the
        // factory's name-based methods for parameterized classes.
        //
        // The primary purpose for adding the factory's type-based methods was to
        // accommodate registration of parameterized types and eliminate the many sources
        // of errors associated with string-based factory usage. Thus, use of name-based
        // lookup in <uvm_factory> is no longer recommended.
        
        `endif // UVM_REGISTRY_SVH
        
