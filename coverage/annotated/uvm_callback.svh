//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2022 Marvell International Ltd.
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2012-2024 NVIDIA Corporation
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
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_callback.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `include "uvm_macros.svh"
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Callbacks Classes
        //
        // This section defines the classes used for callback registration, management,
        // and user-defined callbacks.
        //------------------------------------------------------------------------------
        
        typedef class uvm_root;
        typedef class uvm_callback;
        typedef class uvm_callbacks_base;
        
        
        //------------------------------------------------------------------------------
        //
        // Class - uvm_typeid_base
        //
        //------------------------------------------------------------------------------
        //
        // Simple typeid interface. Need this to set up the base-super mapping.
        // This is similar to the factory, but much simpler. The idea of this
        // interface is that each object type T has a typeid that can be
        // used for mapping type relationships. This is not a user visible class.
        
 000060 class uvm_typeid_base;
          static string typename;
          static uvm_callbacks_base typeid_map[uvm_typeid_base];
          static uvm_typeid_base type_map[uvm_callbacks_base];
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // Class - uvm_typeid#(T)
        //
        //------------------------------------------------------------------------------
        
%000003 class uvm_typeid#(type T=uvm_object) extends uvm_typeid_base;
          static uvm_typeid#(T) m_b_inst;
~000099   static function uvm_typeid#(T) get();
~000096     if(m_b_inst == null) begin
              
%000003       m_b_inst = new;
            end
        
~000099     return m_b_inst;
          endfunction
        endclass
        
        //------------------------------------------------------------------------------
        // Class - uvm_callbacks_base
        //
        // Base class singleton that holds generic queues for all instance
        // specific objects. This is an internal class. This class contains a
        // global pool that has all of the instance specific callback queues in it. 
        // All of the typewide callback queues live in the derivative class
        // uvm_typed_callbacks#(T). This is not a user visible class.
        //
        // This class holds the class inheritance hierarchy information
        // (super types and derivative types).
        //
        // Note, all derivative uvm_callbacks#() class singletons access this
        // global m_pool object in order to get access to their specific
        // instance queue.
        //------------------------------------------------------------------------------
        
 000102 class uvm_callbacks_base extends uvm_object;
        
          typedef uvm_callbacks_base this_type;
        
%000003   /*protected*/ static bit m_tracing = 1;
          static this_type m_b_inst;
        
          static uvm_pool#(uvm_object,uvm_queue#(uvm_callback)) m_pool;
        
 000033   static function this_type m_initialize();
~000030     if(m_b_inst == null) begin
%000003       m_b_inst = new;
%000003       m_pool = new;
            end
 000033     return m_b_inst;
          endfunction
        
          //Type checking interface
          this_type       m_this_type[$];     //one to many T->T/CB
          uvm_typeid_base m_super_type;       //one to one relation 
          uvm_typeid_base m_derived_types[$]; //one to many relation
        
%000000   virtual function bit m_am_i_a(uvm_object obj);
%000000     return 0;
          endfunction
        
%000000   virtual function bit m_is_for_me(uvm_callback cb);
%000000     return 0;
          endfunction
        
%000000   virtual function bit m_is_registered(uvm_object obj, uvm_callback cb);
%000000     return 0;
          endfunction
        
%000000   virtual function uvm_queue#(uvm_callback) m_get_tw_cb_q(uvm_object obj);
%000000     return null;
          endfunction
        
%000000   virtual function void m_add_tw_cbs(uvm_callback cb, uvm_apprepend ordering);
          endfunction
        
%000000   virtual function bit m_delete_tw_cbs(uvm_callback cb);
%000000     return 0;
          endfunction
        
          //Check registration. To test registration, start at this class and
          //work down the class hierarchy. If any class returns true then
          //the pair is legal.
%000000   function bit check_registration(uvm_object obj, uvm_callback cb);
%000000     this_type dt;
        
%000000     if (m_is_registered(obj,cb)) begin
              
%000000       return 1;
            end
        
        
            // Need to look at all possible T/CB pairs of this type
%000000     foreach(m_this_type[i]) begin
              
%000000       if(m_b_inst != m_this_type[i] && m_this_type[i].m_is_registered(obj,cb)) begin
                
%000000         return 1;
              end
        
            end
        
        
%000000     if(obj == null) begin
%000000       foreach(m_derived_types[i]) begin
%000000         dt = uvm_typeid_base::typeid_map[m_derived_types[i] ];
%000000         if(dt != null && dt.check_registration(null,cb)) begin
                  
%000000           return 1;
                end
        
              end
            end
        
%000000     return 0;
          endfunction
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // Class - uvm_typed_callbacks#(T)
        //
        //------------------------------------------------------------------------------
        //
        // Another internal class. This contains the queue of typewide
        // callbacks. It also contains some of the public interface methods,
        // but those methods are accessed via the uvm_callbacks#() class
        // so they are documented in that class even though the implementation
        // is in this class. 
        //
        // The <add>, <delete>, and <display> methods are implemented in this class.
        
%000009 class uvm_typed_callbacks#(type T=uvm_object) extends uvm_callbacks_base;
        
          static uvm_queue#(uvm_callback) m_tw_cb_q;
          static string m_typename;
        
          typedef uvm_typed_callbacks#(T) this_type;
          typedef uvm_callbacks_base      super_type;
        
          //The actual global object from the derivative class. Note that this is
          //just a reference to the object that is generated in the derived class.
          static this_type m_t_inst;
        
%000006   static function this_type m_initialize();
%000003     if(m_t_inst == null) begin
%000003       void'(super_type::m_initialize());
%000003       m_t_inst = new;
%000003       m_t_inst.m_tw_cb_q = new("typewide_queue");
            end
%000006     return m_t_inst;
          endfunction
        
          //Type checking interface: is given ~obj~ of type T?
~013520   virtual function bit m_am_i_a(uvm_object obj);
~013520     T this_type_inst;
~013520     if (obj == null) begin
              
%000000       return 1;
            end
        
~013520     return($cast(this_type_inst,obj));
          endfunction
        
          //Getting the typewide queue
~013520   virtual function uvm_queue#(uvm_callback) m_get_tw_cb_q(uvm_object obj);
%000000     if(m_am_i_a(obj)) begin
%000000       foreach(m_derived_types[i]) begin
%000000         super_type dt;
%000000         dt = uvm_typeid_base::typeid_map[m_derived_types[i] ];
%000000         if(dt != null && dt != this) begin
%000000           m_get_tw_cb_q = dt.m_get_tw_cb_q(obj);
%000000           if(m_get_tw_cb_q != null) begin
                    
%000000             return m_get_tw_cb_q;
                  end
        
                end
              end
%000000       return m_t_inst.m_tw_cb_q;
            end
%000000     else begin
              
%000000       return null;
            end
        
          endfunction
        
%000000   static function int m_cb_find(uvm_queue#(uvm_callback) q, uvm_callback cb);
%000000     for(int i=0; i<q.size(); ++i) begin
              
%000000       if(q.get(i) == cb) begin
                
%000000         return i;
              end
        
            end
        
%000000     return -1;
          endfunction
        
          //For a typewide callback, need to add to derivative types as well.
%000000   virtual function void m_add_tw_cbs(uvm_callback cb, uvm_apprepend ordering);
%000000     super_type cb_pair;
%000000     uvm_object obj;
%000000     T me;
%000000     uvm_queue#(uvm_callback) q;
%000000     if(m_cb_find(m_t_inst.m_tw_cb_q,cb) == -1) begin
%000000       if(ordering == UVM_APPEND) begin
                  
%000000         m_t_inst.m_tw_cb_q.push_back(cb);
              end
        
%000000       else begin
                  
%000000         m_t_inst.m_tw_cb_q.push_front(cb);
              end
        
            end
%000000     if(m_t_inst.m_pool.first(obj)) begin
%000000       do begin
%000000         if($cast(me,obj)) begin
%000000           q = m_t_inst.m_pool.get(obj);
%000000           if(q==null) begin
%000000             q=new;
%000000             m_t_inst.m_pool.add(obj,q);
                  end
%000000           if(m_cb_find(q,cb) == -1) begin
%000000             if(ordering == UVM_APPEND) begin
                      
%000000               q.push_back(cb);
                    end
        
%000000             else begin
                      
%000000               q.push_front(cb);
                    end
        
                  end
                end
              end 
%000000       while(m_t_inst.m_pool.next(obj));
            end
%000000     foreach(m_derived_types[i]) begin
%000000       cb_pair = uvm_typeid_base::typeid_map[m_derived_types[i] ];
%000000       if(cb_pair != this) begin
                
%000000         cb_pair.m_add_tw_cbs(cb,ordering);
              end
        
            end
          endfunction
        
        
          //For a typewide callback, need to remove from derivative types as well.
%000000   virtual function bit m_delete_tw_cbs(uvm_callback cb);
%000000     super_type cb_pair;
%000000     uvm_object obj;
%000000     uvm_queue#(uvm_callback) q;
%000000     int pos = m_cb_find(m_t_inst.m_tw_cb_q,cb);
        
%000000     if(pos != -1) begin
%000000       m_t_inst.m_tw_cb_q.delete(pos);
%000000       m_delete_tw_cbs = 1;
            end
        
%000000     if(m_t_inst.m_pool.first(obj)) begin
%000000       do begin
%000000         q = m_t_inst.m_pool.get(obj);
%000000         if(q==null) begin
%000000           q=new;
%000000           m_t_inst.m_pool.add(obj,q);
                end
%000000         pos = m_cb_find(q,cb);
%000000         if(pos != -1) begin
%000000           q.delete(pos);
%000000           m_delete_tw_cbs = 1;
                end
              end 
%000000       while(m_t_inst.m_pool.next(obj));
            end
%000000     foreach(m_derived_types[i]) begin
%000000       cb_pair = uvm_typeid_base::typeid_map[m_derived_types[i] ];
%000000       if(cb_pair != this) begin
                
%000000         m_delete_tw_cbs |= cb_pair.m_delete_tw_cbs(cb);
              end
        
            end
          endfunction
        
        
%000000   static function void display(T obj=null);
%000000     T me;
%000000     string cbq[$];
%000000     string inst_q[$];
%000000     string mode_q[$];
%000000     uvm_callback cb;
%000000     string blanks = "                             ";
%000000     uvm_object bobj = obj;
%000000     string qs[$];
        
%000000     uvm_queue#(uvm_callback) q;
%000000     string tname, str;
        
%000000     int max_cb_name=0, max_inst_name=0;
        
%000000     m_tracing = 0; //don't allow tracing during display
        
%000000     if(m_typename != "") begin
%000000       tname = m_typename;
            end
        
%000000     else if(obj != null) begin
%000000       tname = obj.get_type_name();
            end
        
%000000     else begin
%000000       tname = "*";
            end
        
        
%000000     q = m_t_inst.m_tw_cb_q;
%000000     for(int i=0; i<q.size(); ++i) begin
%000000       cb = q.get(i);
%000000       cbq.push_back(cb.get_name());
%000000       inst_q.push_back("(*)");
%000000       if(cb.is_enabled()) begin
%000000         mode_q.push_back("ON");
              end
        
%000000       else begin
%000000         mode_q.push_back("OFF");
              end
        
        
%000000       str = cb.get_name();
%000000       max_cb_name = max_cb_name > str.len() ? max_cb_name : str.len();
%000000       str = "(*)";
%000000       max_inst_name = max_inst_name > str.len() ? max_inst_name : str.len();
            end
        
%000000     if(obj ==null) begin
%000000       if(m_t_inst.m_pool.first(bobj)) begin
%000000         do begin
                  
%000000           if($cast(me,bobj)) begin
%000000             break;
                  end
        
                end
        
%000000         while(m_t_inst.m_pool.next(bobj));
              end
%000000       if(me != null || m_t_inst.m_tw_cb_q.size()) begin
%000000         qs.push_back($sformatf("Registered callbacks for all instances of %s\n", tname)); 
%000000         qs.push_back("---------------------------------------------------------------\n");
              end
%000000       if(me != null) begin
%000000         do begin
%000000           if($cast(me,bobj)) begin
%000000             q = m_t_inst.m_pool.get(bobj);
%000000             if (q==null) begin
%000000               q=new;
%000000               m_t_inst.m_pool.add(bobj,q);
                    end
%000000             for(int i=0; i<q.size(); ++i) begin
%000000               cb = q.get(i);
%000000               cbq.push_back(cb.get_name());
%000000               inst_q.push_back(bobj.get_full_name());
%000000               if(cb.is_enabled()) begin
%000000                 mode_q.push_back("ON");
                      end
        
%000000               else begin
%000000                 mode_q.push_back("OFF");
                      end
        
          
%000000               str = cb.get_name();
%000000               max_cb_name = max_cb_name > str.len() ? max_cb_name : str.len();
%000000               str = bobj.get_full_name();
%000000               max_inst_name = max_inst_name > str.len() ? max_inst_name : str.len();
                    end
                  end
                end 
%000000         while (m_t_inst.m_pool.next(bobj));
              end
%000000       else begin
%000000         qs.push_back($sformatf("No callbacks registered for any instances of type %s\n", tname));
              end
            end
%000000     else begin
%000000       if(m_t_inst.m_pool.exists(bobj) || m_t_inst.m_tw_cb_q.size()) begin
%000000         qs.push_back($sformatf("Registered callbacks for instance %s of %s\n", obj.get_full_name(), tname)); 
%000000         qs.push_back("---------------------------------------------------------------\n");
              end
%000000       if(m_t_inst.m_pool.exists(bobj)) begin
%000000         q = m_t_inst.m_pool.get(bobj);
%000000         if(q==null) begin
%000000           q=new;
%000000           m_t_inst.m_pool.add(bobj,q);
                end
%000000         for(int i=0; i<q.size(); ++i) begin
%000000           cb = q.get(i);
%000000           cbq.push_back(cb.get_name());
%000000           inst_q.push_back(bobj.get_full_name());
%000000           if(cb.is_enabled()) begin
%000000             mode_q.push_back("ON");
                  end
        
%000000           else begin
%000000             mode_q.push_back("OFF");
                  end
        
        
%000000           str = cb.get_name();
%000000           max_cb_name = max_cb_name > str.len() ? max_cb_name : str.len();
%000000           str = bobj.get_full_name();
%000000           max_inst_name = max_inst_name > str.len() ? max_inst_name : str.len();
                end
              end
            end
%000000     if(!cbq.size()) begin
%000000       if(obj == null) begin
%000000         str = "*";
              end
        
%000000       else begin
%000000         str = obj.get_full_name();
              end
        
%000000       qs.push_back($sformatf("No callbacks registered for instance %s of type %s\n", str, tname));
            end
        
%000000     foreach (cbq[i]) begin
%000000       qs.push_back($sformatf("%s  %s %s on %s  %s\n", cbq[i], blanks.substr(0,max_cb_name-cbq[i].len()-1), inst_q[i], blanks.substr(0,max_inst_name - inst_q[i].len()-1), mode_q[i]));
            end
%000000     `uvm_info("UVM/CB/DISPLAY",`UVM_STRING_QUEUE_STREAMING_PACK(qs),UVM_NONE)
        
%000000     m_tracing = 1; //allow tracing to be resumed
          endfunction
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_callbacks #(T,CB)
        //
        // The ~uvm_callbacks~ class provides a base class for implementing callbacks,
        // which are typically used to modify or augment component behavior without
        // changing the component class. To work effectively, the developer of the
        // component class defines a set of "hook" methods that enable users to
        // customize certain behaviors of the component in a manner that is controlled
        // by the component developer. The integrity of the component's overall behavior
        // is intact, while still allowing certain customizable actions by the user.
        // 
        // To enable compile-time type-safety, the class is parameterized on both the
        // user-defined callback interface implementation as well as the object type
        // associated with the callback. The object type-callback type pair are
        // associated together using the <`uvm_register_cb> macro to define
        // a valid pairing; valid pairings are checked when a user attempts to add
        // a callback to an object.
        //
        // To provide the most flexibility for end-user customization and reuse, it
        // is recommended that the component developer also define a corresponding set
        // of virtual method hooks in the component itself. This affords users the ability
        // to customize via inheritance/factory overrides as well as callback object
        // registration. The implementation of each virtual method would provide the
        // default traversal algorithm for the particular callback being called. Being
        // virtual, users can define subtypes that override the default algorithm,
        // perform tasks before and/or after calling super.<method> to execute any
        // registered callbacks, or to not call the base implementation, effectively
        // disabling that particular hook. A demonstration of this methodology is
        // provided in an example included in the kit.
        //------------------------------------------------------------------------------
        
         
        // @uvm-ieee 1800.2-2020 auto 10.7.2.1
%000003 class uvm_callbacks #(type T=uvm_object, type CB=uvm_callback)
            extends uvm_typed_callbacks#(T);
        
          // Parameter -- NODOCS -- T
          //
          // This type parameter specifies the base object type with which the
          // <CB> callback objects will be registered. This object must be
          // a derivative of ~uvm_object~.
        
          // Parameter -- NODOCS -- CB
          //
          // This type parameter specifies the base callback type that will be
          // managed by this callback class. The callback type is typically a
          // interface class, which defines one or more virtual method prototypes 
          // that users can override in subtypes. This type must be a derivative
          // of <uvm_callback>.
          
          typedef uvm_typed_callbacks#(T) super_type;
          typedef uvm_callbacks#(T,CB) this_type;
        
        
          // Singleton instance is used for type checking
          local static this_type m_inst;
        
          // typeinfo
          static uvm_typeid_base m_typeid;
          static uvm_typeid_base m_cb_typeid;
        
          static string m_typename;
          static string m_cb_typename;
          static uvm_callbacks#(T,uvm_callback) m_base_inst;
        
          bit m_registered;
        
          // get
          // ---
        
~013523   static function this_type get();
        
~013520     if (m_inst == null) begin
%000003       uvm_typeid_base cb_base_type;
        
%000003       void'(super_type::m_initialize());
            
%000003       cb_base_type = uvm_typeid#(uvm_callback)::get();
%000003       m_cb_typeid  = uvm_typeid#(CB)::get();
%000003       m_typeid     = uvm_typeid#(T)::get();
        
%000003       m_inst = new;
        
%000003       if (cb_base_type == m_cb_typeid) begin
%000003         $cast(m_base_inst, m_inst);
                // The base inst in the super class gets set to this base inst
%000003         m_t_inst = m_base_inst;
%000003         uvm_typeid_base::typeid_map[m_typeid] = m_inst; 
%000003         uvm_typeid_base::type_map[m_b_inst] = m_typeid;
              end
%000003       else begin
%000003         m_base_inst = uvm_callbacks#(T,uvm_callback)::get();
%000003         m_base_inst.m_this_type.push_back(m_inst);
              end
        
%000003       if (m_inst == null) begin
%000000         `uvm_fatal("CB/INTERNAL","get(): m_inst is null")
              end
            end
        
~013523     return m_inst;
          endfunction
        
        
        
          // m_register_pair
          // -------------
          // Register valid callback type
        
%000003   static function bit m_register_pair(string tname="", cbname="");
%000003     this_type inst = get();
        
%000003     m_typename = tname;
%000003     super_type::m_typename = tname;
%000003     m_typeid.typename = tname;
        
%000003     m_cb_typename = cbname;
%000003     m_cb_typeid.typename = cbname;
        
%000003     inst.m_registered = 1; 
        
%000003     return 1;
          endfunction
        
%000000   virtual function bit m_is_registered(uvm_object obj, uvm_callback cb);
%000000     if(m_is_for_me(cb) && m_am_i_a(obj)) begin
%000000       return m_registered;
            end
          endfunction
        
          //Does type check to see if the callback is valid for this type
%000000   virtual function bit m_is_for_me(uvm_callback cb);
%000000     CB this_cb;
%000000     return($cast(this_cb,cb));
          endfunction
        
          // Group -- NODOCS -- Add/delete interface
        
          // Function -- NODOCS -- add
          //
          // Registers the given callback object, ~cb~, with the given
          // ~obj~ handle. The ~obj~ handle can be ~null~, which allows 
          // registration of callbacks without an object context. If
          // ~ordering~ is UVM_APPEND (default), the callback will be executed
          // after previously added callbacks, else  the callback
          // will be executed ahead of previously added callbacks. The ~cb~
          // is the callback handle; it must be non-~null~, and if the callback
          // has already been added to the object instance then a warning is
          // issued. Note that the CB parameter is optional. For example, the 
          // following are equivalent:
          //
          //| uvm_callbacks#(my_comp)::add(comp_a, cb);
          //| uvm_callbacks#(my_comp, my_callback)::add(comp_a,cb);
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.3.1
%000000   static function void add(T obj, uvm_callback cb, uvm_apprepend ordering=UVM_APPEND);
%000000     uvm_queue#(uvm_callback) q;
%000000     string nm,tnm; 
        
%000000     void'(get());
        
%000000     if (cb==null) begin
%000000       if (obj==null) begin
                 
%000000         nm = "(*)";
              end
        
%000000       else begin
                 
%000000         nm = obj.get_full_name();
              end
        
        
%000000       if (m_base_inst.m_typename!="") begin
                 
%000000         tnm = m_base_inst.m_typename;
              end
        
%000000       else if (obj != null) begin
                 
%000000         tnm = obj.get_type_name();
              end
        
%000000       else begin
                 
%000000         tnm = "uvm_object";
              end
        
        
%000000       uvm_report_error("CBUNREG",
%000000                        {"Null callback object cannot be registered with object ",
%000000                         nm, " (", tnm, ")"}, UVM_NONE);
%000000       return;
            end
        
%000000     if (!m_base_inst.check_registration(obj,cb)) begin
        
%000000       if (obj==null) begin
                 
%000000         nm = "(*)";
              end
        
%000000       else begin
                 
%000000         nm = obj.get_full_name();
              end
        
        
%000000       if (m_base_inst.m_typename!="") begin
                 
%000000         tnm = m_base_inst.m_typename;
              end
        
%000000       else if(obj != null) begin
                 
%000000         tnm = obj.get_type_name();
              end
        
%000000       else begin
                 
%000000         tnm = "uvm_object";
              end
        
        
%000000       uvm_report_warning("CBUNREG",
%000000                           {"Callback ", cb.get_name(), " cannot be registered with object ",
%000000                           nm, " because callback type ", cb.get_type_name(),
%000000                           " is not registered with object type ", tnm }, UVM_NONE);
            end
        
%000000     if(obj == null) begin
        
%000000       if (m_cb_find(m_t_inst.m_tw_cb_q,cb) != -1) begin
        
%000000         if (m_base_inst.m_typename!="") begin
                  
%000000           tnm = m_base_inst.m_typename;
                end
        
%000000         else begin
%000000           tnm = "uvm_object";
                end
        
        
%000000         uvm_report_warning("CBPREG",
%000000                            {"Callback object ", cb.get_name(),
%000000                            " is already registered with type ", tnm }, UVM_NONE);
              end
%000000       else begin
                `uvm_cb_trace_noobj(cb,$sformatf("Add (%s) typewide callback %0s for type %s",
                ordering.name(), cb.get_name(), m_base_inst.m_typename))
%000000         m_t_inst.m_add_tw_cbs(cb,ordering);
              end
            end
        
%000000     else begin
        
              `uvm_cb_trace_noobj(cb,$sformatf("Add (%s) callback %0s to object %0s ",
              ordering.name(), cb.get_name(), obj.get_full_name()))
        
%000000       q = m_base_inst.m_pool.get(obj);
        
%000000       if (q==null) begin
%000000         q=new;
%000000         m_base_inst.m_pool.add(obj,q);
              end
        
%000000       if(q.size() == 0) begin
                // Need to make sure that registered report catchers are added. This
                // way users don't need to set up uvm_report_object as a super type.
%000000         uvm_report_object o; 
        
%000000         if($cast(o,obj)) begin
%000000           uvm_queue#(uvm_callback) qr;
%000000           void'(uvm_callbacks#(uvm_report_object, uvm_callback)::get());
%000000           qr = uvm_callbacks#(uvm_report_object,uvm_callback)::m_t_inst.m_tw_cb_q;
%000000           for(int i=0; i<qr.size(); ++i) begin
                      
%000000             q.push_back(qr.get(i));
                  end
         
                end
        
%000000         for(int i=0; i<m_t_inst.m_tw_cb_q.size(); ++i) begin
                  
%000000           q.push_back(m_t_inst.m_tw_cb_q.get(i));
                end
         
              end
        
              //check if already exists in the queue
%000000       if(m_cb_find(q,cb) != -1) begin
%000000         uvm_report_warning("CBPREG", { "Callback object ", cb.get_name(), " is already registered",
%000000                            " with object ", obj.get_full_name() }, UVM_NONE);
              end
%000000       else begin
%000000         if(ordering == UVM_APPEND) begin
                  
%000000           q.push_back(cb);
                end
        
%000000         else begin
                  
%000000           q.push_front(cb);
                end
        
              end
            end
          endfunction
        
          // Function -- NODOCS -- add_by_name
          //
          // Registers the given callback object, ~cb~, with one or more uvm_components.
          // The components must already exist and must be type T or a derivative. As
          // with <add> the CB parameter is optional. ~root~ specifies the location in
          // the component hierarchy to start the search for ~name~. See <uvm_root::find_all>
          // for more details on searching by name.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.3.2
%000000   static function void add_by_name(string name,
                                           uvm_callback cb,
                                           uvm_component root,
                                           uvm_apprepend ordering=UVM_APPEND);
%000000     uvm_component cq[$];
%000000     uvm_root top;
%000000     uvm_coreservice_t cs;
%000000     T t;
%000000     void'(get());
%000000     cs = uvm_coreservice_t::get();
%000000     top = cs.get_root();
        
%000000     if(cb==null) begin
%000000       uvm_report_error("CBUNREG", { "Null callback object cannot be registered with object(s) ",
%000000          name }, UVM_NONE);
%000000       return;
            end
            `uvm_cb_trace_noobj(cb,$sformatf("Add (%s) callback %0s by name to object(s) %0s ",
                            ordering.name(), cb.get_name(), name))
%000000     top.find_all(name,cq,root);
%000000     if(cq.size() == 0) begin
%000000       uvm_report_warning("CBNOMTC", { "add_by_name failed to find any components matching the name ",
%000000         name, ", callback ", cb.get_name(), " will not be registered." }, UVM_NONE);
            end
%000000     foreach(cq[i]) begin
%000000       if($cast(t,cq[i])) begin 
%000000         add(t,cb,ordering); 
              end
            end
          endfunction
        
        
          // Function -- NODOCS -- delete
          //
          // Deletes the given callback object, ~cb~, from the queue associated with
          //  the given ~obj~ handle. The ~obj~ handle can be ~null~, which allows
          // de-registration of callbacks without an object context. 
          // The ~cb~ is the callback handle; it must be non-~null~, and if the callback
          // has already been removed from the object instance then a warning is
          // issued. Note that the CB parameter is optional. For example, the 
          // following are equivalent:
          //
          //| uvm_callbacks#(my_comp)::delete(comp_a, cb);
          //| uvm_callbacks#(my_comp, my_callback)::delete(comp_a,cb);
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.3.3
%000000   static function void delete(T obj, uvm_callback cb);
%000000     uvm_object b_obj = obj;
%000000     uvm_queue#(uvm_callback) q;
%000000     bit found;
%000000     int pos;
%000000     void'(get());
        
%000000     if(obj == null) begin
              `uvm_cb_trace_noobj(cb,$sformatf("Delete typewide callback %0s for type %s",
              cb.get_name(), m_base_inst.m_typename))
%000000       found = m_t_inst.m_delete_tw_cbs(cb);
            end
%000000     else begin
              `uvm_cb_trace_noobj(cb,$sformatf("Delete callback %0s from object %0s ",
              cb.get_name(), obj.get_full_name()))
%000000       q = m_base_inst.m_pool.get(b_obj);
%000000       pos = m_cb_find(q,cb);
%000000       if(pos != -1) begin
%000000         q.delete(pos);
%000000         found = 1;
              end
            end
%000000     if(!found) begin
%000000       string nm;
%000000       if(obj==null) begin
%000000         nm = "(*)";
              end
%000000       else begin
%000000         nm = obj.get_full_name();
              end
        
%000000       uvm_report_warning("CBUNREG", { "Callback ", cb.get_name(), " cannot be removed from object ",
%000000         nm, " because it is not currently registered to that object." }, UVM_NONE);
            end
          endfunction
        
        
          // Function -- NODOCS -- delete_by_name
          //
          // Removes the given callback object, ~cb~, associated with one or more 
          // uvm_component callback queues. As with <delete> the CB parameter is 
          // optional. ~root~ specifies the location in the component hierarchy to start 
          // the search for ~name~. See <uvm_root::find_all> for more details on searching 
          // by name.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.3.4
%000000   static function void delete_by_name(string name, uvm_callback cb,
             uvm_component root);
%000000     uvm_component cq[$];
%000000     uvm_root top;
%000000     T t;
%000000     uvm_coreservice_t cs;
%000000     void'(get());
%000000     cs = uvm_coreservice_t::get();
%000000     top = cs.get_root();
        
            `uvm_cb_trace_noobj(cb,$sformatf("Delete callback %0s by name from object(s) %0s ",
                            cb.get_name(), name))
%000000     top.find_all(name,cq,root);
%000000     if(cq.size() == 0) begin
%000000       uvm_report_warning("CBNOMTC", { "delete_by_name failed to find any components matching the name ",
%000000         name, ", callback ", cb.get_name(), " will not be unregistered." }, UVM_NONE);
            end
%000000     foreach(cq[i]) begin
%000000       if($cast(t,cq[i])) begin 
%000000         delete(t,cb); 
              end
            end
          endfunction
        
          //--------------------------
          // Group -- NODOCS -- Iterator Interface
          //--------------------------
          //
          // This set of functions provide an iterator interface for callback queues. A facade
          // class, <uvm_callback_iter> is also available, and is the generally preferred way to
          // iterate over callback queues.
        
~013520   static function void m_get_q (ref uvm_queue #(uvm_callback) q, input T obj);
~013520     if(!m_base_inst.m_pool.exists(obj)) begin //no instance specific
~013520       q = (obj == null) ? m_t_inst.m_tw_cb_q : m_t_inst.m_get_tw_cb_q(obj);
            end 
%000000     else begin
%000000       q = m_base_inst.m_pool.get(obj);
%000000       if(q==null) begin
%000000         q=new;
%000000         m_base_inst.m_pool.add(obj,q);
              end
            end
          endfunction
        
        
          // Function -- NODOCS -- get_first
          //
          // Returns the first enabled callback of type CB which resides in the queue for ~obj~.
          // If ~obj~ is ~null~ then the typewide queue for T is searched. ~itr~ is the iterator;
          // it will be updated with a value that can be supplied to <get_next> to get the next
          // callback object.
          //
          // If the queue is empty then ~null~ is returned. 
          //
          // The iterator class <uvm_callback_iter> may be used as an alternative, simplified,
          // iterator interface.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.4.1
~013520   static function CB get_first (ref int itr, input T obj);
~013520     uvm_queue#(uvm_callback) q;
~013520     CB cb;
~013520     void'(get());
~013520     m_get_q(q,obj);
~013520     for(itr = 0; itr<q.size(); ++itr) begin
              
%000000       if($cast(cb, q.get(itr)) && cb.callback_mode()) begin
                 
%000000         return cb;
              end
        
            end
        
~013520     return null;
          endfunction
        
          // Function -- NODOCS -- get_last
          //
          // Returns the last enabled callback of type CB which resides in the queue for ~obj~.
          // If ~obj~ is ~null~ then the typewide queue for T is searched. ~itr~ is the iterator;
          // it will be updated with a value that can be supplied to <get_prev> to get the previous
          // callback object.
          //
          // If the queue is empty then ~null~ is returned.
          //
          // The iterator class <uvm_callback_iter> may be used as an alternative, simplified,
          // iterator interface.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.4.2
%000000   static function CB get_last (ref int itr, input T obj);
%000000     uvm_queue#(uvm_callback) q;
%000000     CB cb;
%000000     void'(get());
%000000     m_get_q(q,obj);
%000000     for(itr = q.size()-1; itr>=0; --itr) begin
              
%000000       if ($cast(cb, q.get(itr)) && cb.callback_mode()) begin
                 
%000000         return cb;
              end
        
            end
        
%000000     return null;
          endfunction
        
        
          // Function -- NODOCS -- get_next
          //
          // Returns the next enabled callback of type CB which resides in the queue for ~obj~,
          // using ~itr~ as the starting point. If ~obj~ is ~null~ then the typewide queue for T
          // is searched. ~itr~ is the iterator; it will be updated with a value that can be 
          // supplied to <get_next> to get the next callback object.
          //
          // If no more callbacks exist in the queue, then ~null~ is returned. <get_next> will
          // continue to return ~null~ in this case until <get_first> or <get_last> has been used to reset
          // the iterator.
          //
          // The iterator class <uvm_callback_iter> may be used as an alternative, simplified,
          // iterator interface.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.4.3
%000000   static function CB get_next (ref int itr, input T obj);
%000000     uvm_queue#(uvm_callback) q;
%000000     CB cb;
%000000     void'(get());
%000000     m_get_q(q,obj);
%000000     for(itr = itr+1; itr<q.size(); ++itr) begin
              
%000000       if ($cast(cb, q.get(itr)) && cb.callback_mode()) begin
                 
%000000         return cb;
              end
        
            end
        
%000000     return null;
          endfunction
        
        
          // Function -- NODOCS -- get_prev
          //
          // Returns the previous enabled callback of type CB which resides in the queue for ~obj~,
          // using ~itr~ as the starting point. If ~obj~ is ~null~ then the typewide queue for T
          // is searched. ~itr~ is the iterator; it will be updated with a value that can be 
          // supplied to <get_prev> to get the previous callback object.
          //
          // If no more callbacks exist in the queue, then ~null~ is returned. <get_prev> will
          // continue to return ~null~ in this case until <get_first> or <get_last> has been used to reset
          // the iterator.
          //
          // The iterator class <uvm_callback_iter> may be used as an alternative, simplified,
          // iterator interface.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.4.4
%000000   static function CB get_prev (ref int itr, input T obj);
%000000     uvm_queue#(uvm_callback) q;
%000000     CB cb;
%000000     void'(get());
%000000     m_get_q(q,obj);
%000000     for(itr = itr-1; itr>= 0; --itr) begin
              
%000000       if($cast(cb, q.get(itr)) && cb.callback_mode()) begin
                 
%000000         return cb;
              end
        
            end
        
%000000     return null;
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto 10.7.2.5
~005000   static function void get_all ( ref CB all_callbacks[$], input T obj=null );
~005000     uvm_queue#(uvm_callback) q;
~005000     CB cb;
~005000     CB callbacks_to_append[$];
~005000     CB unique_callbacks_to_append[$];
        
~005000     void'( get() );
        
~005000     if ((obj == null) || (!m_pool.exists(obj))) begin
              // Only typewide callbacks exist
~005000       for (int qi=0; qi<m_t_inst.m_tw_cb_q.size(); ++qi) begin 
            
%000000         if ($cast(cb, m_t_inst.m_tw_cb_q.get(qi))) begin
              
%000000           callbacks_to_append.push_back( cb );
                end
        
              end
        
            end
%000000     else begin
              // No need to do anything special with typewide,
              // as they're present in the instance queue.
%000000       q = m_pool.get(obj);
%000000       for (int qi=0; qi < q.size(); qi++) begin
            
%000000         if ($cast(cb, q.get( qi ))) begin
              
%000000           callbacks_to_append.push_back( cb );
                end
        
              end
        
            end
        
            // Now remove duplicates and append the final list to all_callbacks.
~005000     unique_callbacks_to_append = callbacks_to_append.unique( cb_ ) with ( cb_.get_inst_id );
~005000     all_callbacks = { all_callbacks, unique_callbacks_to_append };
          endfunction
        
        
          //-------------
          // Group -- NODOCS -- Debug
          //-------------
        
          // Function -- NODOCS -- display
          //
          // This function displays callback information for ~obj~. If ~obj~ is
          // ~null~, then it displays callback information for all objects
          // of type ~T~, including typewide callbacks.
        
%000000   static function void display(T obj=null);
            // For documentation purposes, need a function wrapper here.
%000000     void'(get());
%000000     super_type::display(obj);
          endfunction
        
        endclass
        
        
        
        //------------------------------------------------------------------------------
        //
        // Class- uvm_derived_callbacks #(T,ST,CB)
        //
        //------------------------------------------------------------------------------
        // This type is not really expected to be used directly by the user, instead they are 
        // expected to use the macro `uvm_set_super_type. The sole purpose of this type is to
        // allow for setting up of the derived_type/super_type mapping.
        //------------------------------------------------------------------------------
        
        class uvm_derived_callbacks#(type T=uvm_object, type ST=uvm_object, type CB=uvm_callback)
            extends uvm_callbacks#(T,CB);
        
          typedef uvm_derived_callbacks#(T,ST,CB) this_type;
          typedef uvm_callbacks#(T)            this_user_type;
          typedef uvm_callbacks#(ST)           this_super_type;
         
          // Singleton instance is used for type checking
          static this_type m_d_inst;
          static this_user_type m_user_inst;
          static this_super_type m_super_inst;
        
          // typeinfo
          static uvm_typeid_base m_s_typeid;
        
          static function this_type get();
            m_user_inst = this_user_type::get();
            m_super_inst = this_super_type::get();
            m_s_typeid = uvm_typeid#(ST)::get();
            if(m_d_inst == null) begin
              m_d_inst = new;
            end
            return m_d_inst;
          endfunction
        
          static function bit register_super_type(string tname="", sname="");
            this_user_type u_inst = this_user_type::get();
            uvm_callbacks_base s_obj;
        
            void'(this_type::get()); // make sure it exists
            this_user_type::m_t_inst.m_typename = tname;
        
            if(sname != "") begin
              m_s_typeid.typename = sname;
            end
        
        
            if(u_inst.m_super_type != null) begin
              if(u_inst.m_super_type == m_s_typeid) begin
                return 1;
              end
        
              uvm_report_warning("CBTPREG", { "Type ", tname, " is already registered to super type ", 
                this_super_type::m_t_inst.m_typename, ". Ignoring attempt to register to super type ",
                sname}, UVM_NONE); 
              return 1;
            end
            if(this_super_type::m_t_inst.m_typename == "") begin
              
              this_super_type::m_t_inst.m_typename = sname;
            end
        
            u_inst.m_super_type = m_s_typeid;
            u_inst.m_base_inst.m_super_type = m_s_typeid;
            s_obj = uvm_typeid_base::typeid_map[m_s_typeid];
            s_obj.m_derived_types.push_back(m_typeid);
            return 1;
          endfunction
        
        endclass
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_callback_iter
        //
        //------------------------------------------------------------------------------
        // The ~uvm_callback_iter~ class is an iterator class for iterating over
        // callback queues of a specific callback type. The typical usage of
        // the class is:
        //
        //| uvm_callback_iter#(mycomp,mycb) iter = new(this);
        //| for(mycb cb = iter.first(); cb != null; cb = iter.next())
        //|    cb.dosomething();
        //
        // The callback iteration macros, <`uvm_do_callbacks> and
        // <`uvm_do_callbacks_exit_on> provide a simple method for iterating
        // callbacks and executing the callback methods.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto D.1.1
        class uvm_callback_iter#(type T = uvm_object, type CB = uvm_callback) extends uvm_void;
        
           local int m_i;
           local T   m_obj;
           local CB  m_cb;
        
           // Function -- NODOCS -- new
           //
           // Creates a new callback iterator object. It is required that the object
           // context be provided.
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.1
~000639    function new(T obj);
~000639       m_obj = obj;
           endfunction
        
           // Function -- NODOCS -- first
           //
           // Returns the first valid (enabled) callback of the callback type (or
           // a derivative) that is in the queue of the context object. If the
           // queue is empty then ~null~ is returned.
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.2
~000639    function CB first();
~000639       m_cb = uvm_callbacks#(T,CB)::get_first(m_i, m_obj);
~000639       return m_cb;
           endfunction
        
           // Function -- NODOCS -- last
           //
           // Returns the last valid (enabled) callback of the callback type (or
           // a derivative) that is in the queue of the context object. If the
           // queue is empty then ~null~ is returned.
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.3
%000000    function CB last();
%000000       m_cb = uvm_callbacks#(T,CB)::get_last(m_i, m_obj);
%000000       return m_cb;
           endfunction
        
           // Function -- NODOCS -- next
           //
           // Returns the next valid (enabled) callback of the callback type (or
           // a derivative) that is in the queue of the context object. If there
           // are no more valid callbacks in the queue, then ~null~ is returned.
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.4
%000000    function CB next();
%000000       m_cb = uvm_callbacks#(T,CB)::get_next(m_i, m_obj);
%000000       return m_cb;
           endfunction
        
           // Function -- NODOCS -- prev
           //
           // Returns the previous valid (enabled) callback of the callback type (or
           // a derivative) that is in the queue of the context object. If there
           // are no more valid callbacks in the queue, then ~null~ is returned.
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.5
%000000    function CB prev();
%000000       m_cb = uvm_callbacks#(T,CB)::get_prev(m_i, m_obj);
%000000       return m_cb;
           endfunction
        
           // Function -- NODOCS -- get_cb
           //
           // Returns the last callback accessed via a first() or next()
           // call. 
        
           // @uvm-ieee 1800.2-2020 auto D.1.2.6
%000000    function CB get_cb();
%000000       return m_cb;
           endfunction
        
        /****
           function void trace(uvm_object obj = null);
              if (m_cb != null && T::cbs::get_debug_flags() & UVM_CALLBACK_TRACE) begin
                 uvm_report_object reporter = null;
                 string who = "Executing ";
                 void'($cast(reporter, obj));
                 if (reporter == null) void'($cast(reporter, m_obj));
                 if (reporter == null) reporter = uvm_top;
                 if (obj != null) who = {obj.get_full_name(), " is executing "};
                 else if (m_obj != null) who = {m_obj.get_full_name(), " is executing "};
                 reporter.uvm_report_info("CLLBK_TRC", {who, "callback ", m_cb.get_name()}, UVM_LOW);
              end
           endfunction
        ****/
        endclass
        
        
        
        //------------------------------------------------------------------------------
        // CLASS -- NODOCS -- uvm_callback
        //
        // The ~uvm_callback~ class is the base class for user-defined callback classes.
        // Typically, the component developer defines an application-specific callback
        // class that extends from this class. In it, he defines one or more virtual
        // methods, called a ~callback interface~, that represent the hooks available
        // for user override. 
        //
        // Methods intended for optional override should not be declared ~pure.~ Usually,
        // all the callback methods are defined with empty implementations so users have
        // the option of overriding any or all of them.
        //
        // The prototypes for each hook method are completely application specific with
        // no restrictions.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 10.7.1.1
        class uvm_callback extends uvm_object;
%000006   protected bit m_enabled = 1;
        
%000000   `uvm_object_utils(uvm_callback)
          
          // Function -- NODOCS -- new
          //
          // Creates a new uvm_callback object, giving it an optional ~name~.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.1.2.1
%000006   function new(string name="uvm_callback");
%000006     super.new(name);
          endfunction
        
        
          // Function -- NODOCS -- callback_mode
          //
          // Enable/disable callbacks (modeled like rand_mode and constraint_mode).
        
          // @uvm-ieee 1800.2-2020 auto 10.7.1.2.2
%000000   function bit callback_mode(int on=-1);
%000000     if(on == 0 || on == 1) begin
              `uvm_cb_trace_noobj(this,$sformatf("Setting callback mode for %s to %s",
              get_name(), ((on==1) ? "ENABLED":"DISABLED")))
            end
%000000     else begin
              `uvm_cb_trace_noobj(this,$sformatf("Callback mode for %s is %s",
              get_name(), ((m_enabled==1) ? "ENABLED":"DISABLED")))
            end
%000000     callback_mode = m_enabled;
%000000     if(on==0) begin
%000000       m_enabled=0;
            end
        
%000000     if(on==1) begin
%000000       m_enabled=1;
            end
        
          endfunction
        
        
          // Function -- NODOCS -- is_enabled
          //
          // Returns 1 if the callback is enabled, 0 otherwise.
        
          // @uvm-ieee 1800.2-2020 auto 10.7.1.2.3
%000000   function bit is_enabled();
%000000     return callback_mode();
          endfunction
        
        endclass
        
        
