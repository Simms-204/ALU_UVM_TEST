//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2022-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_config_db_implementation.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_phase;
        
        
        //Internal class for config waiters
        class m_uvm_waiter;
          string inst_name;
          string field_name;
          event trigger;
%000000   function new (string inst_name, string field_name);
%000000     this.inst_name = inst_name;
%000000     this.field_name = field_name;
          endfunction
        endclass
        
        typedef class uvm_root;
        typedef class uvm_config_db_options;
        typedef class uvm_config_db_default_implementation_t;
        
        // Class: uvm_config_db_implementation_t#(T)
        // Abstract class representing the implementation details of the API for 
        // uvm_config_db#(T) to allow users to create alternate implementations 
        //
        // @uvm-contrib
%000003 virtual class uvm_config_db_implementation_t #(type T=int) extends uvm_object;
           typedef uvm_resource #(T) rsrc_t;
        
%000006    `uvm_object_abstract_param_utils(uvm_config_db_implementation_t #(T))
        
           local static uvm_config_db_implementation_t #(T) m_config_db_imp;
        
            // Function: set_imp
            //
            // Sets the implementation to be used to:
            //   1) the imp argument if it is not null, else
            //   2) the relevant factory override of uvm_config_db_implementation_t#(T) if such an override exists, else
            //   3) a new creation of uvm_config_db_default_implementation_t#(T)
            // @uvm-contrib
%000003    static function void set_imp(uvm_config_db_implementation_t #(T) imp = null);
%000003       if (imp == null) 
%000003         begin
%000003           uvm_coreservice_t cs = uvm_coreservice_t::get();
%000003           uvm_factory factory = cs.get_factory();
%000003           if (factory.find_override_by_type(uvm_config_db_implementation_t#(T)::get_type(),"") == uvm_config_db_implementation_t#(T)::get_type()) 
%000003           begin // no override registered
%000003             imp = uvm_config_db_default_implementation_t #(T)::type_id::create();
                  end
                  else 
%000000           begin
%000000             imp = uvm_config_db_implementation_t #(T)::type_id::create();
                  end
        
                end
%000003       m_config_db_imp = imp ;
           endfunction : set_imp
        
            // Function: get_imp
            //
            // Returns the implementation instance to be used.  When called the first
            // time, it gets that instance via set_imp().  For all subsequent calls, it
            // returns that same instance.
            // @uvm-contrib
~000084    static function uvm_config_db_implementation_t #(T) get_imp();
~000081       if (m_config_db_imp == null) 
%000003         begin
%000003           set_imp();
                end
        
~000084       return m_config_db_imp;
           endfunction : get_imp
        
           // Function: get
           //
           // Intended to provide the functionality for uvm_config_db#(T)::get
           // @uvm-contrib
%000000    pure virtual function bit get (uvm_component     cntxt,
                                                string            inst_name,
                                                string            field_name,
                                                inout T           value);
        
           // Function: set
           //
           // Intended to provide the functionality for uvm_config_db#(T)::set
           // @uvm-contrib
%000000    pure virtual function void set(string                              cntxt_name,
                                                string                              inst_name,
                                                string                              field_name,
                                                T                                   value,
                                                int                                 cntxt_depth,
                                                uvm_pool#(string, uvm_resource#(T)) pool,
                                                uvm_component                       cntxt);
        
           // Function: exists
           //
           // Intended to provide the functionality for uvm_config_db#(T)::exists
           // @uvm-contrib
%000000    pure virtual function bit exists(uvm_component cntxt, 
                                            string        inst_name,
                                            string        field_name, 
                                            bit           rpterr);
        
           // Function: wait_modified
           //
           // Intended to provide the functionality for uvm_config_db#(T)::wait_modified
           // @uvm-contrib
%000000    pure virtual task wait_modified(uvm_component cntxt, 
                                           string inst_name,
                                           string field_name);
        
           // Function: trigger_modified
           //
           // Triggers the event associated with ~inst_name~ and ~field_name~, potentially
           // unblocking calls to <wait_modified>.
           //
           // The ~inst_name~ variable supports regular expressions via <uvm_is_match>.
           //
           // @uvm-contrib
%000000    pure virtual function void trigger_modified(string inst_name,
                                                       string field_name);
        
           // Function: show_msg
           //
           // Intended to print a formatted string regarding an access of a particular config item
           // @uvm-contrib
%000000    pure virtual function void show_msg(string id,
                                               string rtype,
                                               string action,
                                               string scope,
                                               string name,
                                               uvm_object accessor,
                                               rsrc_t rsrc);
        
        
        endclass
        
        // Class: uvm_config_db_default_implementation_t#(T)
        //
        // Provides an implementation of uvm_config_db_implementation_t#(T).
        // Users may extend this class to provide an implementation that is
        // a variation of the library implementation.
        //
        // @uvm-contrib
        class uvm_config_db_default_implementation_t #(type T=int) extends uvm_config_db_implementation_t#(T);
        
%000003   function new (string name = "uvm_config_db_default_implementation");
%000003      super.new();
          endfunction : new
        
%000000   `uvm_object_param_utils(uvm_config_db_default_implementation_t #(T))
        
          // Function: get
          //
          // Provides an implementation of get, including support for  
          // config_db tracing
          // @uvm-accellera
~000084   virtual function bit get (uvm_component     cntxt,
                                          string            inst_name,
                                          string            field_name,
                                          inout T           value);
~000084     uvm_resource#(T) r;
~000084     uvm_resource_pool rp = uvm_resource_pool::get();
~000084     uvm_resource_types::rsrc_q_t rq;
~000084     uvm_coreservice_t cs = uvm_coreservice_t::get();
        
~000084     if(cntxt == null) 
%000000       begin
%000000         cntxt = cs.get_root();
              end
        
~000084     if(inst_name == "") 
~000084       begin
~000084         inst_name = cntxt.get_full_name();
              end
        
%000000     else if(cntxt.get_full_name() != "") 
%000000       begin
%000000         inst_name = {cntxt.get_full_name(), ".", inst_name};
              end
        
         
~000084     rq = rp.lookup_name(inst_name, field_name, uvm_resource#(T)::get_type(), 0);
~000084     r = uvm_resource#(T)::get_highest_precedence(rq);
            
~000084     if(uvm_config_db_options::is_tracing())
%000000       begin
%000000         show_msg("CFGDB/GET", "Configuration","read", inst_name, field_name, cntxt, r);
              end
        
        
~000015     if(r == null)
%000000       begin
%000000         return 0;
              end
        
        
~000084     value = r.read(cntxt);
        
~000084     return 1;
          endfunction : get
        
        
          // Internal waiter list for wait_modified
          static local uvm_queue#(m_uvm_waiter) m_waiters[string];
        
          // Function: wait_modified
          //
          // Provides an implementation of wait_modified
          // @uvm-accellera
%000000   virtual task wait_modified(uvm_component cntxt, string inst_name,
                                                      string field_name);
%000000     process p = process::self();
%000000     string rstate;
%000000     m_uvm_waiter waiter;
%000000     uvm_coreservice_t cs;
        
%000000     if (p != null)
%000000       begin
%000000         rstate = p.get_randstate();
              end
        
        
%000000     cs = uvm_coreservice_t::get();
        
%000000     if(cntxt == null)
%000000       begin
%000000         cntxt = cs.get_root();
              end
        
%000000     if(cntxt != cs.get_root()) 
%000000       begin
%000000         if(inst_name != "")
%000000         begin
%000000           inst_name = {cntxt.get_full_name(),".",inst_name};
                end
        
                else
%000000         begin
%000000           inst_name = cntxt.get_full_name();
                end
        
              end
        
%000000     waiter = new(inst_name, field_name);
        
%000000     if(!m_waiters.exists(field_name))
%000000       begin
%000000         m_waiters[field_name] = new;
              end
        
%000000     m_waiters[field_name].push_back(waiter);
        
%000000     if (p != null)
%000000       begin
%000000         p.set_randstate(rstate);
              end
        
        
            // wait on the waiter to trigger
%000000     @waiter.trigger;
          
            // Remove the waiter from the waiter list 
%000000     for(int i=0; i<m_waiters[field_name].size(); ++i) 
%000000       begin
%000000         if(m_waiters[field_name].get(i) == waiter) 
%000000         begin
%000000           m_waiters[field_name].delete(i);
%000000           break;
                end
              end 
          endtask : wait_modified
        
          // Function: trigger_modified
          //
          // @uvm-accellera
%000009   virtual function void trigger_modified(string inst_name,
                                                 string field_name);
            //trigger any waiters
%000009     if(m_waiters.exists(field_name)) 
%000000       begin
%000000         m_uvm_waiter w;
%000000         for(int i=0; i<m_waiters[field_name].size(); ++i) 
%000000         begin
%000000           w = m_waiters[field_name].get(i);
%000000           if(uvm_is_match(inst_name,w.inst_name) )
%000000             begin
%000000               ->w.trigger;
                    end
          
                end
              end
        
          endfunction : trigger_modified    
        
          // Function: set
          //
          // Provides an implementation of set, including support for  
          // config_db tracing
          // @uvm-accellera
%000009   virtual function void set(string                              cntxt_name,
                                          string                              inst_name,
                                          string                              field_name,
                                          T                                   value,
                                          int                                 cntxt_depth,
                                          uvm_pool#(string, uvm_resource#(T)) pool,
                                          uvm_component                       cntxt);
        
%000009     uvm_root top;
%000009     uvm_phase curr_phase;
%000009     uvm_resource#(T) r;
%000009     string lookup;
%000009     string rstate;
%000009     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000009     uvm_resource_pool rp = cs.get_resource_pool();
%000009     int unsigned precedence;
        
            //take care of random stability during allocation
%000009     process p = process::self();
%000009     if (p != null)
%000009       begin
%000009         rstate = p.get_randstate();
              end
        
        
%000009     top = cs.get_root();
%000009     curr_phase = top.m_current_phase;
        
%000009     if (cntxt == null) 
%000000       begin
%000000         cntxt = top;
              end
        
%000000     if (inst_name == "") 
%000000       begin
%000000         inst_name = cntxt.get_full_name();
              end
        
%000009     else if(cntxt.get_full_name() != "") 
%000009       begin
%000009         string slash_or_blank = "" ;
%000009         string close_or_blank = "" ;
%000009         string separator = "." ;
%000009         if (inst_name[0] == "/" && inst_name.len()>2 && inst_name[inst_name.len()-1] == "/") 
%000000           begin //regex
%000000             slash_or_blank = "/";
%000000             close_or_blank = ")/" ;
%000000             separator = "\.(" ;
%000000             inst_name = inst_name.substr(1,inst_name.len()-2); //strip enclosing "/"
                  end
%000009         inst_name = {slash_or_blank, 
%000009                    cntxt.get_full_name(), 
%000009                    separator, 
%000009                    inst_name, 
%000009                    close_or_blank};
              end
        
            // Insert the token in the middle to prevent cache
            // oddities like i=foobar,f=xyz and i=foo,f=barxyz.
            // Can't just use '.', because '.' isn't illegal
            // in field names
%000009     lookup = {inst_name, "__M_UVM__", field_name};
        
%000009     if(!pool.exists(lookup)) 
%000009       begin
%000009         r = new(field_name);
%000009         rp.set_scope(r, inst_name);
%000009         pool.add(lookup, r);
              end
            else 
%000000       begin
%000000         r = pool.get(lookup);
              end
              
%000009     if(curr_phase != null && curr_phase.get_name() == "build")
%000009       begin
%000009         precedence = cs.get_resource_pool_default_precedence() - (cntxt.get_depth());
              end
        
            else
%000003       begin
%000003         precedence = cs.get_resource_pool_default_precedence();
              end
        
        
%000009     rp.set_precedence(r, precedence);
%000009     r.write(value, cntxt);
        
%000009     rp.set_priority_name(r, uvm_resource_types::PRI_HIGH);
        
%000009     trigger_modified(inst_name, field_name);
            
%000009     if (p != null)
%000009       begin
%000009         p.set_randstate(rstate);
              end
        
        
%000009     if(uvm_config_db_options::is_tracing())
%000000       begin
%000000         show_msg("CFGDB/SET", "Configuration","set", inst_name, field_name, cntxt, r);
              end
        
        
          endfunction : set
        
        
          // Function: exists
          //
          // Provides an implementation of get
          // @uvm-accellera
%000000   virtual function bit exists(uvm_component cntxt, 
                                                       string        inst_name,
                                                       string        field_name, 
                                                       bit           rpterr);
        
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
        
%000000     if(cntxt == null)
%000000       begin
%000000         cntxt = cs.get_root();
              end
        
%000000     if(inst_name == "")
%000000       begin
%000000         inst_name = cntxt.get_full_name();
              end
        
%000000     else if(cntxt.get_full_name() != "")
%000000       begin
%000000         inst_name = {cntxt.get_full_name(), ".", inst_name};
              end
        
        
%000000     return (uvm_resource_db#(T)::get_by_name(inst_name,field_name,rpterr) != null);  
          endfunction : exists
        
        
          // Function: show_msg
          //
          // Provides an implementation of show_msg.
          // @uvm-accellera
%000000   virtual function void show_msg(string id,
                                         string rtype,
                                         string action,
                                         string scope,
                                         string name,
                                         uvm_object accessor,
                                         rsrc_t rsrc);
%000000       T foo;
%000000       string msg=`uvm_typename(foo);
        
%000000       $sformat(msg, "%s scope='%s' name='%s' (type %s) %s accessor=%s = %s",
%000000                rtype,scope,name, msg,action,
%000000                (accessor != null) ? accessor.get_full_name() : "<unknown>",
%000000                rsrc==null?"null (failed lookup)":rsrc.convert2string());
        
%000000       `uvm_info(id, msg, UVM_LOW)
        
          endfunction : show_msg
        endclass : uvm_config_db_default_implementation_t 
        
        
        
        
