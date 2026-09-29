//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2023-2024 NVIDIA Corporation
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
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_resource_db_implementation.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        
        typedef class uvm_resource_db_options;
        typedef class uvm_cmdline_processor;
        typedef class uvm_resource_db_default_implementation_t;
        
        // Class: uvm_resource_db_implementation_t#(T)
        // Abstract class representing the implementation details of the API for 
        // uvm_resource_db#(T) to allow users to create alternate implementations
        //
        // @uvm-contrib
%000000 virtual class uvm_resource_db_implementation_t #(type T=uvm_object) extends uvm_object;
            typedef uvm_resource #(T) rsrc_t;
        
%000000     `uvm_object_abstract_param_utils(uvm_resource_db_implementation_t #(T))
        
            local static uvm_resource_db_implementation_t #(T) m_rsrc_db_imp;
        
            // Function: set_imp
            //
            // Sets the implementation to be used to:
            //   1) the imp argument if it is not null, else
            //   2) the relevant factory override of uvm_resource_db_implementation_t#(T) if such an override exists, else
            //   3) a new creation of uvm_resource_db_default_implementation_t#(T)
            // @uvm-contrib
%000000     static function void set_imp(uvm_resource_db_implementation_t #(T) imp = null);
%000000       if (imp == null) 
%000000         begin
%000000           uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000           uvm_factory factory = cs.get_factory();
%000000           if (factory.find_override_by_type(uvm_resource_db_implementation_t#(T)::get_type(),"") == uvm_resource_db_implementation_t#(T)::get_type()) 
%000000           begin // no override registered
%000000             imp = uvm_resource_db_default_implementation_t #(T)::type_id::create();
                  end
                  else 
%000000           begin
%000000             imp = uvm_resource_db_implementation_t #(T)::type_id::create();
                  end
        
                end
%000000       m_rsrc_db_imp = imp;
            endfunction : set_imp
        
            // Function: get_imp
            //
            // Returns the implementation instance to be used.  When called the first
            // time, it gets that instance via set_imp().  For all subsequent calls, it
            // returns that same instance.
            // @uvm-contrib
%000000     static function uvm_resource_db_implementation_t #(T) get_imp ();
%000000         if (m_rsrc_db_imp == null)
%000000           begin
%000000             set_imp();
                  end
        
%000000         return m_rsrc_db_imp;
            endfunction : get_imp
        
        
            // Function: get_by_type
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::get_by_type
            // @uvm-contrib
%000000     pure virtual function rsrc_t get_by_type(string scope);
        
        
            // Function: get_by_name
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::get_by_name
            // @uvm-contrib
%000000     pure virtual function rsrc_t get_by_name(string scope,
                                                     string name,
                                                     bit    rpterr);
        
            // Function: set_default
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set_default
            // @uvm-contrib
%000000     pure virtual function rsrc_t set_default(string scope, string name);
        
        
            // Function: show_msg
            //
            // Intended to print a formatted string regarding an access of a particular resource
            // @uvm-contrib
%000000     pure virtual function void show_msg(string id,
                                                string rtype,
                                                string action,
                                                string scope,
                                                string name,
                                                uvm_object accessor,
                                                rsrc_t rsrc);
        
            // Function: set
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set
            // @uvm-contrib
%000000     pure virtual function void set(string scope, 
                                           string name,
                                           T val, 
                                           uvm_object accessor);
        
        
            // Function: set_anonymous
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set_anonymous
            // @uvm-contrib
%000000     pure virtual function void set_anonymous(string scope,
                                                     T val, 
                                                     uvm_object accessor);
        
        
            // Function: set_override
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set_override
            // @uvm-contrib
%000000     pure virtual function void set_override(string scope, 
                                                    string name,
                                                    T val, 
                                                    uvm_object accessor);
        
        
            // Function: set_override_type
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set_override_type
            // @uvm-contrib
%000000     pure virtual function void set_override_type(string scope, 
                                                         string name,
                                                         T val, 
                                                         uvm_object accessor);
        
        
            // Function: set_override_name
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::set_override_name
            // @uvm-contrib
%000000     pure virtual function void set_override_name(string scope, 
                                                         string name,
                                                         T val, 
                                                         uvm_object accessor);
        
        
            // Function: read_by_name
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::read_by_name
            // @uvm-contrib
%000000     pure virtual function bit read_by_name(string scope,
                                                   string name,
                                                   inout T val, 
                                                   input uvm_object accessor);
        
            // Function: read_by_type
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::read_by_type
            // @uvm-contrib
%000000     pure virtual function bit read_by_type(string scope,
                                                   inout T val,
                                                   input uvm_object accessor);
        
            // Function: write_by_name
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::write_by_name
            // @uvm-contrib
%000000     pure virtual function bit write_by_name(string scope, 
                                                    string name,
                                                    T val, 
                                                    uvm_object accessor);
        
            // Function: write_by_type
            //
            // Intended to provide the functionality for uvm_resource_db#(T)::write_by_type
            // @uvm-contrib
%000000     pure virtual function bit write_by_type(string scope,
                                                    T val, 
                                                    uvm_object accessor);
        endclass
        
        // Class: uvm_resource_db_default_implementation_t#(T)
        //
        // Provides an implementation of uvm_resource_db_implementation_t#(T).
        // The user may extend this class to provide an implementation that is
        // a variation of the library implementation.
        //
        // @uvm-contrib
        class uvm_resource_db_default_implementation_t #(type T=uvm_object) extends uvm_resource_db_implementation_t #(T);
            typedef uvm_resource #(T) rsrc_t;
        
%000000     `uvm_object_param_utils(uvm_resource_db_default_implementation_t #(T))
        
%000000     function new(string name = "uvm_resource_db_default_implementation_t"); 
%000000         super.new();
            endfunction : new
        
        
            // Function: get_by_type
            //
            // Provides an implementation of get_by_type, with a 
            // warning if the resource was not located.
            // @uvm-accellera
%000000     virtual function rsrc_t get_by_type(string scope);
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       uvm_resource_base rsrc_base;
%000000       rsrc_t rsrc;
%000000       string msg;
%000000       uvm_resource_base type_handle = rsrc_t::get_type();
          
%000000       if(type_handle == null)
%000000         begin
%000000           return null;
                end
        
          
%000000       rsrc_base = rp.get_by_type(scope, type_handle);
%000000       if(!$cast(rsrc, rsrc_base)) 
%000000         begin
%000000           $sformat(msg, "Resource with specified type handle in scope %s was not located", scope);
%000000           `uvm_warning("RSRCNF", msg)
%000000           return null;
                end
          
%000000       return rsrc;
            endfunction : get_by_type
        
        
            // Function: get_by_name
            //
            // Provides an implementation of get_by_name, with
            // a warning if the matching resource is the wrong type.
            // @uvm-accellera
%000000     virtual function rsrc_t get_by_name(string scope,
                                                string name,
                                                bit    rpterr);
        
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       uvm_resource_base rsrc_base;
%000000       rsrc_t rsrc;
%000000       string msg;
          
%000000       rsrc_base = rp.get_by_name(scope, name, rsrc_t::get_type(), rpterr);
%000000       if(rsrc_base == null)
%000000         begin
%000000           return null;
                end
        
          
%000000       if(!$cast(rsrc, rsrc_base)) 
%000000         begin
%000000           if(rpterr) 
%000000           begin
%000000             $sformat(msg, "Resource with name %s in scope %s has incorrect type", name, scope);
%000000             `uvm_warning("RSRCTYPE", msg)
                  end
%000000           return null;
                end
        
%000000       return rsrc;
            endfunction : get_by_name
        
        
            // Function: set_default
            //
            // Provides an implementation of set_default.
            // @uvm-accellera
%000000     virtual function rsrc_t set_default(string scope, string name);
        
%000000       rsrc_t r;
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
              
%000000       r = new(name);
%000000       rp.set_scope(r, scope);
%000000       return r;
            endfunction : set_default
        
        
            // Function: show_msg
            //
            // Provides an implementation of show_msg.
            // @uvm-accellera
%000000     virtual function void show_msg(string id,
                                           string rtype,
                                           string action,
                                           string scope,
                                           string name,
                                           uvm_object accessor,
                                           rsrc_t rsrc);
%000000         T foo;
%000000         string msg=`uvm_typename(foo);
        
%000000         $sformat(msg, "%s scope='%s' name='%s' (type %s) %s accessor=%s = %s",
%000000                  rtype,scope,name, msg,action,
%000000                  (accessor != null) ? accessor.get_full_name() : "<unknown>",
%000000                  rsrc==null?"null (failed lookup)":rsrc.convert2string());
        
%000000         `uvm_info(id, msg, UVM_LOW)
            endfunction : show_msg
        
        
            // Function: set
            //
            // Provides an implementation of set, including support 
            // for resource tracing
            // @uvm-accellera
%000000     virtual function void set(string scope, 
                                      string name,
                                      T val, 
                                      uvm_object accessor);
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       rsrc_t rsrc = new(name);
%000000       rsrc.write(val, accessor);
%000000       rp.set_scope(rsrc, scope);
          
%000000       if(uvm_resource_db_options::is_tracing())
%000000         begin
%000000           show_msg("RSRCDB/SET", "Resource","set", scope, name, accessor, rsrc);
                end
        
            endfunction : set
            
        
            // Function: set_anonymous
            //
            // Provides an implementation of set_anonymous, including  
            // support for resource tracing
            // @uvm-accellera
%000000     virtual function void set_anonymous(string scope,
                                                T val, 
                                                uvm_object accessor);
        
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       rsrc_t rsrc = new("");
%000000       rsrc.write(val, accessor);
%000000       rp.set_scope(rsrc, scope);
          
%000000       if(uvm_resource_db_options::is_tracing())
%000000         begin
%000000           show_msg("RSRCDB/SETANON","Resource", "set", scope, "", accessor, rsrc);
                end
        
            endfunction : set_anonymous
        
        
            // Function: set_override
            //
            // Provides an implementation of set_override, including support 
            // for resource tracing
            // @uvm-accellera
%000000     virtual function void set_override(string scope,
                                               string name,
                                               T val,
                                               uvm_object accessor);
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       rsrc_t rsrc = new(name);
%000000       rsrc.write(val, accessor);
%000000       rp.set_override(rsrc, scope);
          
%000000       if(uvm_resource_db_options::is_tracing())
%000000         begin
%000000           show_msg("RSRCDB/SETOVRD", "Resource","set", scope, name, accessor, rsrc);
                end
        
            endfunction : set_override
        
        
            // Function: set_override_type
            //
            // Provides an implementation of set_override_type, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function void set_override_type(string scope,
                                                    string name,
                                                    T val,
                                                    uvm_object accessor);
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       rsrc_t rsrc = new(name);
%000000       rsrc.write(val, accessor);
%000000       rp.set_type_override(rsrc, scope);
          
%000000       if(uvm_resource_db_options::is_tracing())
%000000         begin
%000000           show_msg("RSRCDB/SETOVRDTYP","Resource", "set", scope, name, accessor, rsrc);
                end
            endfunction : set_override_type
        
        
            // Function: set_override_name
            //
            // Provides an implementation of set_override_name, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function void set_override_name(string scope,
                                                                   string name,
                                                                   T val,
                                                                   uvm_object accessor);
%000000       uvm_resource_pool rp = uvm_resource_pool::get();
%000000       rsrc_t rsrc = new(name);
%000000       rsrc.write(val, accessor);
%000000       rp.set_name_override(rsrc, scope);
          
%000000       if(uvm_resource_db_options::is_tracing())
%000000         begin
%000000           show_msg("RSRCDB/SETOVRDNAM","Resource", "set", scope, name, accessor, rsrc);
                end
        
            endfunction : set_override_name
        
        
            // Function: read_by_name
            //
            // Provides an implementation of read_by_name, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function bit read_by_name(string scope,
                                              string name,
                                              inout T val,
                                              input uvm_object accessor);
        
%000000         rsrc_t rsrc = get_by_name(scope, name, 1);
        
%000000         if(uvm_resource_db_options::is_tracing())
%000000           begin
%000000             show_msg("RSRCDB/RDBYNAM","Resource", "read", scope, name, accessor, rsrc);
                  end
        
        
%000000         if(rsrc == null)
%000000           begin
%000000             return 0;
                  end
        
        
%000000         val = rsrc.read(accessor);
        
%000000         return 1;
            endfunction : read_by_name
        
        
            // Function: read_by_type
            //
            // Provides an implementation of read_by_type, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function bit read_by_type(input string scope,
                                              inout T val,
                                              input uvm_object accessor);
            
%000000         rsrc_t rsrc = get_by_type(scope);
        
%000000         if(uvm_resource_db_options::is_tracing())
%000000           begin
%000000             show_msg("RSRCDB/RDBYTYP", "Resource","read", scope, "", accessor, rsrc);
                  end
        
        
%000000         if(rsrc == null)
%000000           begin
%000000             return 0;
                  end
        
        
%000000         val = rsrc.read(accessor);
        
%000000         return 1;
        
            endfunction : read_by_type
        
        
            // Function: write_by_name
            //
            // Provides an implementation of write_by_name, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function bit write_by_name(string scope, 
                                                              string name,
                                                              T val, 
                                                              uvm_object accessor);
        
%000000         rsrc_t rsrc = get_by_name(scope, name, 1);
        
%000000         if(uvm_resource_db_options::is_tracing())
%000000           begin
%000000             show_msg("RSRCDB/WR","Resource", "written", scope, name, accessor, rsrc);
                  end
        
        
%000000         if(rsrc == null)
%000000           begin
%000000             return 0;
                  end
        
        
%000000         rsrc.write(val, accessor);
        
%000000         return 1;
            endfunction : write_by_name
        
        
            // Function: write_by_type
            //
            // Provides an implementation of write_by_type, 
            // including support for resource tracing
            // @uvm-accellera
%000000     virtual function bit write_by_type(string scope,
                                                              T val, 
                                                              uvm_object accessor);
        
%000000         rsrc_t rsrc = get_by_type(scope);
        
%000000         if(uvm_resource_db_options::is_tracing())
%000000           begin
%000000             show_msg("RSRCDB/WRTYP", "Resource","written", scope, "", accessor, rsrc);
                  end
        
        
%000000         if(rsrc == null)
%000000           begin
%000000             return 0;
                  end
        
        
%000000         rsrc.write(val, accessor);
        
%000000         return 1;
            endfunction : write_by_type
        
        endclass
        
        
        
