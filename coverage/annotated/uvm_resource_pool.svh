//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010-2022 AMD
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2017-2018 Cisco Systems, Inc.
        // Copyright 2011-2012 Cypress Semiconductor Corp.
        // Copyright 2017 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2010-2018 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2010-2011 Paradigm Works
        // Copyright 2014 Semifore
        // Copyright 2010-2014 Synopsys, Inc.
        // Copyright 2017-2018 Verific
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
        // $File:     src/base/uvm_resource_pool.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        
        
        
        //----------------------------------------------------------------------
        // Class - get_t
        //
        // Instances of get_t are stored in the history list as a record of each
        // get.  Failed gets are indicated with rsrc set to ~null~.  This is part
        // of the audit trail facility for resources.
        //----------------------------------------------------------------------
%000000 class get_t;
          string name;
          string scope;
          uvm_resource_base rsrc;
          time t;
        endclass
        
        typedef class uvm_tree_printer ;
        
        // Title: Resources
        
        //----------------------------------------------------------------------
        // Class -- NODOCS -- uvm_resource_pool
        //
        // The global (singleton) resource database.
        //
        // Each resource is stored both by primary name and by type handle.  The
        // resource pool contains two associative arrays, one with name as the
        // key and one with the type handle as the key.  Each associative array
        // contains a queue of resources.  Each resource has a regular
        // expression that represents the set of scopes over which it is visible.
        //
        //|  +------+------------+                          +------------+------+
        //|  | name | rsrc queue |                          | rsrc queue | type |
        //|  +------+------------+                          +------------+------+
        //|  |      |            |                          |            |      |
        //|  +------+------------+                  +-+-+   +------------+------+
        //|  |      |            |                  | | |<--+---*        |  T   |
        //|  +------+------------+   +-+-+          +-+-+   +------------+------+
        //|  |  A   |        *---+-->| | |           |      |            |      |
        //|  +------+------------+   +-+-+           |      +------------+------+
        //|  |      |            |      |            |      |            |      |
        //|  +------+------------+      +-------+  +-+      +------------+------+
        //|  |      |            |              |  |        |            |      |
        //|  +------+------------+              |  |        +------------+------+
        //|  |      |            |              V  V        |            |      |
        //|  +------+------------+            +------+      +------------+------+
        //|  |      |            |            | rsrc |      |            |      |
        //|  +------+------------+            +------+      +------------+------+
        //
        // The above diagrams illustrates how a resource whose name is A and
        // type is T is stored in the pool.  The pool contains an entry in the
        // type map for type T and an entry in the name map for name A.  The
        // queues in each of the arrays each contain an entry for the resource A
        // whose type is T.  The name map can contain in its queue other
        // resources whose name is A which may or may not have the same type as
        // our resource A.  Similarly, the type map can contain in its queue
        // other resources whose type is T and whose name may or may not be A.
        //
        // Resources are added to the pool by calling <set>; they are retrieved
        // from the pool by calling <get_by_name> or <get_by_type>.  When an object 
        // creates a new resource and calls <set> the resource is made available to be
        // retrieved by other objects outside of itself; an object gets a
        // resource when it wants to access a resource not currently available
        // in its scope.
        //
        // The scope is stored in the resource itself (not in the pool) so
        // whether you get by name or by type the resource's visibility is
        // the same.
        //
        // As an auditing capability, the pool contains a history of gets.  A
        // record of each get, whether by <get_by_type> or <get_by_name>, is stored 
        // in the audit record.  Both successful and failed gets are recorded. At
        // the end of simulation, or any time for that matter, you can dump the
        // history list.  This will tell which resources were successfully
        // located and which were not.  You can use this information
        // to determine if there is some error in name, type, or
        // scope that has caused a resource to not be located or to be incorrectly
        // located (i.e. the wrong resource is located).
        //
        //----------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Class: uvm_resource_pool
        //
        // The library implements the following public API beyond what is 
        // documented in 1800.2.
        //----------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto C.2.4.1
        class uvm_resource_pool extends uvm_void;
        
        `ifndef UVM_DISABLE_RESOURCE_POOL_SHARED_QUEUE
          typedef uvm_resource_types::rsrc_shared_q_t table_q_t;
         `define M__TABLE_Q(QUEUE_NAME) QUEUE_NAME``.value
         `define M__TABLE_GET(QUEUE_NAME, ITER) QUEUE_NAME``.value[ITER]
         `define M__TABLE_NAME "uvm_shared#(uvm_resource_base[$])"
            
        `else
          typedef uvm_resource_types::rsrc_q_t table_q_t;
         `define M__TABLE_Q(QUEUE_NAME) QUEUE_NAME
         `define M__TABLE_GET(QUEUE_NAME, ITER) QUEUE_NAME``.get(ITER)
         `define M__TABLE_NAME "uvm_queue#(uvm_resource_base)"
            
        `endif // !`ifdef UVM_DISABLE_RESOURCE_POOL_SHARED_QUEUE
        
          table_q_t rtab [string];
          table_q_t ttab [uvm_resource_base];
        
          get_t get_record [$];  // history of gets
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.2.1
%000003   function new();
          endfunction
        
        
          // Function -- NODOCS -- get
          //
          // Returns the singleton handle to the resource pool
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.2.2
 000282   static function uvm_resource_pool get();
 000282     uvm_resource_pool t_rp;
 000282     uvm_coreservice_t cs = uvm_coreservice_t::get();
 000282     t_rp = cs.get_resource_pool();
 000282     return t_rp;
          endfunction
        
        
          // Function -- NODOCS -- spell_check
          //
          // Invokes the spell checker for a string s.  The universe of
          // correctly spelled strings -- i.e. the dictionary -- is the name
          // map.
        
%000000   function bit spell_check(string s);
%000000     return uvm_spell_chkr#(table_q_t)::check(rtab, s);
          endfunction
        
          //-----------
          // Group -- NODOCS -- Set
          //-----------
        
          // Function -- NODOCS -- set
          //
          // Add a new resource to the resource pool.  The resource is inserted
          // into both the name map and type map so it can be located by
          // either.
          //
          // An object creates a resources and ~sets~ it into the resource pool.
          // Later, other objects that want to access the resource must ~get~ it
          // from the pool
          //
          // Overrides can be specified using this interface.  Either a name
          // override, a type override or both can be specified.  If an
          // override is specified then the resource is entered at the front of
          // the queue instead of at the back.  It is not recommended that users
          // specify the override parameter directly, rather they use the
          // <set_override>, <set_name_override>, or <set_type_override>
          // functions.
          //
        
          //@uvm-compat provided for compatibility with 1.2
%000000   function void set (uvm_resource_base rsrc, 
                             uvm_resource_types::override_t override = 0);
        
            // If resource handle is ~null~ then there is nothing to do.
%000000     if (rsrc == null) begin
%000000       return ;
            end
        
%000000     if (override) begin 
                
%000000       set_override(rsrc, rsrc.get_scope()) ;
            end
        
%000000     else begin
                
%000000       set_scope(rsrc, rsrc.get_scope()) ;
            end
         
        
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.1
 000012   function void set_scope (uvm_resource_base rsrc, string scope); 
        
 000012     table_q_t rq;
 000012     string name;
 000012     uvm_resource_base type_handle;
 000012     uvm_resource_base r;
 000012     int unsigned i;
        
            // If resource handle is ~null~ then there is nothing to do.
~000012     if(rsrc == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to set scope of a null resource");
%000000       return;
            end
        
            // Insert into the name map.  Resources with empty names are
            // anonymous resources and are not entered into the name map
 000012     name = rsrc.get_name();
%000006     if ((name != "") && rtab.exists(name)) begin
%000006       rq = rtab[name];
        
%000009       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000009         if (`M__TABLE_GET(rq, iter) == rsrc) begin
                  // Resource is already in pool, just change the scope
%000000           rsrc.m_set_scope(scope);
%000000           return;
                end
              end
            end 
        
            // If the name is new to the pool, create the new queue in
            // the name table
%000006     if (rq == null) begin
%000006       rq = new();
%000006       rtab[name] = rq;
            end 
        
            // Insert the resource into the queue associated with its name.
            // Insert it with low priority (in the back of queue).
 000012     `M__TABLE_Q(rq).push_back(rsrc);
            
            // Insert into the type map
 000012     type_handle = rsrc.get_type_handle();
%000006     if(ttab.exists(type_handle)) begin
%000006       rq = ttab[type_handle];
            end
%000006     else begin
%000006       rq = new();
%000006       ttab[type_handle] = rq;
            end
        
            // Insert the resource into the queue associated with its type.  
            // Insert it with low priority (in the back of queue).
 000012     `M__TABLE_Q(rq).push_back(rsrc);
        
            // Set the scope of resource. 
 000012     rsrc.m_set_scope(scope);
 000012     rsrc.precedence = get_default_precedence(); 
        
          endfunction
        
        
          // Function -- NODOCS -- set_override
          //
          // The resource provided as an argument will be entered into the pool
          // and will override both by name and type.
          // Default value to 'scope' argument is violating 1800.2-2017 LRM, but it
          // is added to make the routine backward compatible
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.2
%000000   function void set_override(uvm_resource_base rsrc, string scope="<not provided>");
%000000      string s ;
%000000      if (rsrc == null) begin
%000000        uvm_report_warning("NULLRASRC", "attempting to change the search priority of a null resource");
%000000        return;
             end
%000000      if (scope == "<not provided>") begin
%000000        s = rsrc.get_scope();
             end
        
%000000      else begin
%000000        s = scope ;
             end
        
%000000      set_scope(rsrc, s);
%000000      set_priority(rsrc, uvm_resource_types::PRI_HIGH);
          endfunction
        
        
          // Function -- NODOCS -- set_name_override
          //
          // The resource provided as an argument will entered into the pool
          // using normal precedence in the type map and will override the name.
          // Default value to 'scope' argument is violating 1800.2-2017 LRM, but it
          // is added to make the routine backward compatible
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.3
%000000   function void set_name_override(uvm_resource_base rsrc, string scope="<not provided>");
%000000     string s ;
%000000     if (rsrc == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to change the search priority of a null resource");
%000000       return;
            end
%000000     if (scope == "<not provided>") begin
%000000       s = rsrc.get_scope();
            end
        
%000000     else begin
%000000       s = scope ;
            end
        
%000000     set_scope(rsrc, s);
%000000     set_priority_name(rsrc, uvm_resource_types::PRI_HIGH);
          endfunction
        
        
          // Function -- NODOCS -- set_type_override
          //
          // The resource provided as an argument will be entered into the pool
          // using normal precedence in the name map and will override the type.
          // Default value to 'scope' argument is violating 1800.2-2017 LRM, but it
          // is added to make the routine backward compatible
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.4
%000000   function void set_type_override(uvm_resource_base rsrc, string scope="<not provided>");
%000000     string s ;
%000000     if (rsrc == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to change the search priority of a null resource");
%000000       return;
            end
%000000     if (scope == "<not provided>") begin
%000000       s = rsrc.get_scope();
            end
        
%000000     else begin
%000000       s = scope ;
            end
        
%000000     set_scope(rsrc, s);
%000000     set_priority_type(rsrc, uvm_resource_types::PRI_HIGH);
          endfunction
        
          
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.5
%000000   virtual function bit get_scope(uvm_resource_base rsrc,
%000000                                  output string scope);
        
%000000     table_q_t rq;
%000000     string name;
%000000     uvm_resource_base r, type_handle;
%000000     int unsigned i;
        
            // If resource handle is ~null~ then there is nothing to do.
%000000     if(rsrc == null) begin 
              
%000000       return 0;
            end
        
        
            // Search the resouce in the name map.  Resources with empty names are
            // anonymous resources and are not entered into the name map
%000000     name = rsrc.get_name();
%000000     if((name != "") && rtab.exists(name)) begin
%000000       rq = rtab[name];
        
%000000       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000         if (`M__TABLE_GET(rq, iter) == rsrc) begin
                  // Resource is in the name table, output the scope
%000000           scope = rsrc.get_scope();
%000000           return 1;
                end
              end
            end
        
            // Resource is not in the name table, check the type table
            // (note that this is likely less efficient, so it comes second)
%000000     type_handle = rsrc.get_type_handle();
%000000     if (ttab.exists(type_handle)) begin
%000000       rq = ttab[type_handle];
%000000       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000         if (`M__TABLE_GET(rq, iter) == rsrc) begin
                  // Resource is in the type table, output the scope
%000000           scope = rsrc.get_scope();
%000000           return 1;
                end
              end
            end
            
            // Resource is not in pool
%000000     scope = "";
%000000     return 0;
        
          endfunction
        
          // Function -- NODOCS -- delete
          // 
          // If rsrc exists within the pool, then it is removed from all internal maps. If the rsrc is null, or does not exist
          // within the pool, then the request is silently ignored.
        
         
          // @uvm-ieee 1800.2-2020 auto C.2.4.3.6
%000000   virtual function void delete ( uvm_resource_base rsrc );
%000000     string name;
%000000     table_q_t rq;
%000000     uvm_resource_base type_handle;
%000000     int    iter;
        
%000000     if (rsrc != null) begin
              
%000000       name = rsrc.get_name();
%000000       if(name != "") begin
%000000         if(rtab.exists(name)) begin
%000000           rq = rtab[name];
%000000           iter = 0;
                  
%000000           while (iter < `M__TABLE_Q(rq).size()) begin
%000000             if (`M__TABLE_GET(rq, iter) == rsrc) begin
%000000               `M__TABLE_Q(rq).delete(iter);
%000000               break;
                    end
%000000             iter++;
                  end
                end // if (rtab.exists(name))
              end // if (name != "")
                
%000000       type_handle = rsrc.get_type_handle();
%000000       if(ttab.exists(type_handle)) begin
%000000         rq = ttab[type_handle];
%000000         iter = 0;
        
%000000         while (iter < `M__TABLE_Q(rq).size()) begin
%000000           if (`M__TABLE_GET(rq, iter) == rsrc) begin
%000000             `M__TABLE_Q(rq).delete(iter);
%000000             break;
                  end
%000000           iter++;
                end
              end // if (ttab.exists(type_handle))
              
            end // if (rsrc != null)
            
          endfunction
        
        
          // function - push_get_record
          //
          // Insert a new record into the get history list.
        
%000000   function void push_get_record(string name, string scope,
                                          uvm_resource_base rsrc);
%000000     get_t impt;
        
            // if auditing is turned off then there is no reason
            // to save a get record
%000000     if(!uvm_resource_options::is_auditing()) begin
              
%000000       return;
            end
        
        
%000000     impt = new();
        
%000000     impt.name  = name;
%000000     impt.scope = scope;
%000000     impt.rsrc  = rsrc;
%000000     impt.t     = $realtime;
        
%000000     get_record.push_back(impt);
          endfunction
        
          // function - dump_get_records
          //
          // Format and print the get history list.
        
%000000   function void dump_get_records();
        
%000000     get_t record;
%000000     bit success;
%000000     string qs[$];
        
%000000     qs.push_back("--- resource get records ---\n");
%000000     foreach (get_record[i]) begin
%000000       record = get_record[i];
%000000       success = (record.rsrc != null);
%000000       qs.push_back($sformatf("get: name=%s  scope=%s  %s @ %0t\n",
%000000                record.name, record.scope,
%000000                ((success)?"success":"fail"),
%000000                record.t));
            end
%000000     `uvm_info("UVM/RESOURCE/GETRECORD",`UVM_STRING_QUEUE_STREAMING_PACK(qs),UVM_NONE)
          endfunction
        
          //--------------
          // Group -- NODOCS -- Lookup
          //--------------
          //
          // This group of functions is for finding resources in the resource database.  
          //
          // <lookup_name> and <lookup_type> locate the set of resources that
          // matches the name or type (respectively) and is visible in the
          // current scope.  These functions return a queue of resources.
          //
          // <get_highest_precedence> traverse a queue of resources and
          // returns the one with the highest precedence -- i.e. the one whose
          // precedence member has the highest value.
          //
          // <get_by_name> and <get_by_type> use <lookup_name> and <lookup_type>
          // (respectively) and <get_highest_precedence> to find the resource with
          // the highest priority that matches the other search criteria.
        
        
          // Function -- NODOCS -- lookup_name
          //
          // Lookup resources by ~name~.  Returns a queue of resources that
          // match the ~name~, ~scope~, and ~type_handle~.  If no resources
          // match the queue is returned empty. If ~rpterr~ is set then a
          // warning is issued if no matches are found, and the spell checker is
          // invoked on ~name~.  If ~type_handle~ is ~null~ then a type check is
          // not made and resources are returned that match only ~name~ and
          // ~scope~.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.1
 000267   function uvm_resource_types::rsrc_q_t lookup_name(string scope = "",
                                                            string name,
                                                            uvm_resource_base type_handle = null,
                                                            bit rpterr = 1);
 000267     table_q_t rq;
 000267     uvm_resource_types::rsrc_q_t q;
 000267     uvm_resource_base rsrc;
 000267     uvm_resource_base r;
 000267     string rsrcs;
        
             // ensure rand stability during lookup
 000267      begin
 000267        process p = process::self();
 000267        string s;
~000267        if(p!=null) begin
 000267          s=p.get_randstate();
               end
        
 000267        q=new();
~000267        if(p!=null) begin
 000267          p.set_randstate(s);
               end
        
             end
        
             
            // resources with empty names are anonymous and do not exist in the name map
~000267     if(name == "") begin
              
%000000       return q;
            end
        
        
            // Does an entry in the name map exist with the specified name?
            // If not, then we're done
~000018     if(!rtab.exists(name)) begin
~000249       if(rpterr) begin
%000000         void'(spell_check(name));
              end
            
%000000       return q;
            end    
        
 000267     rsrc = null;
 000267     rq = rtab[name];
 000267     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
 000039       uvm_resource_base rsrc_iter;
 000039       rsrc_iter = `M__TABLE_GET(rq, iter);
 000039       rsrcs = rsrc_iter != null ? rsrc_iter.get_scope(): "";
              // does the type and scope match?
~000039       if(((type_handle == null) || (rsrc_iter.get_type_handle() == type_handle)) 
 000039       && uvm_is_match(rsrcs, scope)) begin
                
 000039         q.push_back(rsrc_iter);
              end
        
            end
        
 000267     return q;
          endfunction
        
          // Function -- NODOCS -- get_highest_precedence
          //
          // Traverse a queue, ~q~, of resources and return the one with the highest
          // precedence.  In the case where there exists more than one resource
          // with the highest precedence value, the first one that has that
          // precedence will be the one that is returned.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.2
 000018   static function uvm_resource_base get_highest_precedence(ref uvm_resource_types::rsrc_q_t q);
        
 000018     uvm_resource_base rsrc;
 000018     uvm_resource_base r;
 000018     int unsigned i;
 000018     int unsigned prec;
 000018     int unsigned c_prec;
        
~000018     if(q.size() == 0) begin
              
%000000       return null;
            end
        
        
            // get the first resources in the queue
 000018     rsrc = q.get(0);
 000018     prec = (rsrc != null) ? rsrc.precedence: 0;
        
            // start searching from the second resource
 000021     for(int i = 1; i < q.size(); ++i) begin
 000021       r = q.get(i);
 000021       c_prec = (r != null) ? r.precedence: 0;
~000021       if(c_prec > prec) begin
 000021         rsrc = r;
 000021         prec = c_prec;
              end
            end
        
 000018     return rsrc;
        
          endfunction
        
          // Function -- NODOCS -- sort_by_precedence
          //
          // Given a list of resources, obtained for example from <lookup_scope>,
          // sort the resources in  precedence order. The highest precedence
          // resource will be first in the list and the lowest precedence will
          // be last. Resources that have the same precedence and the same name
          // will be ordered by most recently set first.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.3
 000042   static function void sort_by_precedence(ref uvm_resource_types::rsrc_q_t q);
 000042     uvm_resource_types::rsrc_sv_q_t all[int];
 000042     uvm_resource_base r;
 000042     int unsigned prec;
        
~000042     for(int i=0; i<q.size(); ++i) begin
%000000       r = q.get(i);
%000000       prec = (r != null) ? r.precedence: 0;
%000000       all[prec].push_front(r); //since we will push_front in the final
            end
 000042     q.delete();
~000042     foreach(all[aa_iter,q_iter]) begin
%000000       q.push_front(all[aa_iter][q_iter]);
            end
          endfunction // sort_by_precedence
        
          // Function -- NODOCS -- sort_by_precedence_q
          //
          // Sorts a list of resources of resources in a standard SV
          // queue instead of a uvm_queue.
%000000   static function void sort_by_precedence_q(ref uvm_resource_types::rsrc_sv_q_t q);
%000000     uvm_resource_types::rsrc_sv_q_t all[int];
%000000     uvm_resource_base r;
%000000     int unsigned prec;
        
%000000     for(int i=0; i<q.size(); ++i) begin
%000000       r = q[i];
%000000       prec = (r != null) ? r.precedence: 0;
%000000       all[prec].push_back(r);
            end
%000000     q.delete();
%000000     foreach(all[iter]) begin
%000000       q = {q, all[iter]};
            end
          endfunction // sort_by_precedence_q    
        
        
          // Function -- NODOCS -- get_by_name
          //
          // Lookup a resource by ~name~, ~scope~, and ~type_handle~.  Whether
          // the get succeeds or fails, save a record of the get attempt.  The
          // ~rpterr~ flag indicates whether to report errors or not.
          // Essentially, it serves as a verbose flag.  If set then the spell
          // checker will be invoked and warnings about multiple resources will
          // be produced.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.4
%000000   function uvm_resource_base get_by_name(string scope = "",
                                                 string name,
                                                 uvm_resource_base type_handle,
                                                 bit rpterr = 1);
        
%000000     uvm_resource_types::rsrc_sv_q_t svq;
        
%000000     table_q_t rq;
%000000     uvm_resource_base rsrc;
        
%000000     string rsrcs;
              
            // Empty names are anonymous and do not exist in the name map
%000000     if (name == "") begin
%000000       push_get_record(name, scope, null);
%000000       return null;
            end
        
            // Does an entry in the name map exist with the specified name?
            // If not, then we're done
%000000     if(!rtab.exists(name)) begin
%000000       if(rpterr) begin
%000000         void'(spell_check(name));
              end
            
%000000       push_get_record(name, scope, null);
%000000       return null;
            end    
        
            // Find all resource for name, optionally filtering by type
%000000     rq = rtab[name];
%000000     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000       uvm_resource_base rsrc_iter;
%000000       rsrc_iter = `M__TABLE_GET(rq, iter);
%000000       if ((type_handle == null) || (type_handle == rsrc_iter.get_type_handle())) begin
%000000         svq.push_back(rsrc_iter);
              end
            end
        
            // Sort the resource queue
%000000     sort_by_precedence_q(svq);
        
            // Return the first scope match
%000000     foreach (svq[iter]) begin
%000000       rsrc = svq[iter];
%000000       rsrcs = (rsrc != null) ? rsrc.get_scope(): "";
%000000       if (uvm_is_match(rsrcs, scope)) begin
                
%000000         break;
              end
        
%000000       else begin
                
%000000         rsrc = null;
              end
        
            end
         
%000000     push_get_record(name, scope, rsrc);
%000000     return rsrc;
        
          endfunction
        
        
          // Function -- NODOCS -- lookup_type
          //
          // Lookup resources by type. Return a queue of resources that match
          // the ~type_handle~ and ~scope~.  If no resources match then the returned
          // queue is empty.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.5
%000000   function uvm_resource_types::rsrc_q_t lookup_type(string scope = "",
                                                            uvm_resource_base type_handle);
        
%000000     uvm_resource_types::rsrc_q_t q = new();
%000000     table_q_t rq;
%000000     uvm_resource_base r;
%000000     int unsigned i;
        
%000000     if(type_handle == null || !ttab.exists(type_handle)) begin
%000000       return q;
            end
        
%000000     rq = ttab[type_handle];
%000000     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000       uvm_resource_base rsrc_iter;
%000000       rsrc_iter = `M__TABLE_GET(rq, iter);
%000000       if(rsrc_iter != null && uvm_is_match(rsrc_iter.get_scope(), scope)) begin
                
%000000         q.push_back(rsrc_iter);
              end
        
            end
        
%000000     return q;
        
          endfunction
        
          // Function -- NODOCS -- get_by_type
          //
          // Lookup a resource by ~type_handle~ and ~scope~.  Insert a record into
          // the get history list whether or not the get succeeded.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.6
%000000   function uvm_resource_base get_by_type(string scope = "",
                                                 uvm_resource_base type_handle);
        
%000000     table_q_t rq;
%000000     uvm_resource_base r;
%000000     int unsigned i;
        
            // No type handle, or type handle not in type table
%000000     if(type_handle == null || !ttab.exists(type_handle)) begin
%000000       push_get_record("<type>", scope, null);
%000000       return null;
            end
        
            // Find first matching scope in type table
%000000     rq = ttab[type_handle];
%000000     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000       uvm_resource_base rsrc_iter;
%000000       rsrc_iter = `M__TABLE_GET(rq, iter);
%000000       if(rsrc_iter != null && uvm_is_match(rsrc_iter.get_scope(), scope)) begin
%000000         push_get_record("<type>", scope, rsrc_iter);
%000000         return rsrc_iter;
              end
            end
        
            // No matching scopes in type table
%000000     push_get_record("<type>", scope, null);
%000000     return null;
        
          endfunction
        
          // Function -- NODOCS -- lookup_regex_names
          //
          // This utility function answers the question, for a given ~name~,
          // ~scope~, and ~type_handle~, what are all of the resources with requested name,
          // a matching scope (where the resource scope may be a
          // regular expression), and a matching type? 
          // ~name~ and ~scope~ are explicit values.
        
%000000   function uvm_resource_types::rsrc_q_t lookup_regex_names(string scope,
                                                                   string name,
                                                                   uvm_resource_base type_handle = null);
%000000       return lookup_name(scope, name, type_handle, 0);
          endfunction
        
          // Function -- NODOCS -- lookup_regex
          //
          // Looks for all the resources whose name matches the regular
          // expression argument and whose scope matches the current scope.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.7
%000000   function uvm_resource_types::rsrc_q_t lookup_regex(string re, scope);
        
%000000     table_q_t rq;
%000000     uvm_resource_types::rsrc_q_t result_q;
%000000     int unsigned i;
%000000     uvm_resource_base r;
%000000     string s;
        
%000000     result_q = new();
        
%000000     foreach (rtab[name]) begin
%000000       if ( ! uvm_is_match(re, name) ) begin
%000000         continue;
              end
%000000       rq = rtab[name];
%000000       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000         uvm_resource_base rsrc_iter;
%000000         rsrc_iter = `M__TABLE_GET(rq, iter);
%000000         if(rsrc_iter != null && uvm_is_match(rsrc_iter.get_scope(), scope)) begin
                  
%000000           result_q.push_back(rsrc_iter);
                end
        
              end
            end
        
%000000     return result_q;
        
          endfunction
        
          // Function -- NODOCS -- lookup_scope
          //
          // This is a utility function that answers the question: For a given
          // ~scope~, what resources are visible to it?  Locate all the resources
          // that are visible to a particular scope.  This operation could be
          // quite expensive, as it has to traverse all of the resources in the
          // database.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.4.8
%000000   function uvm_resource_types::rsrc_q_t lookup_scope(string scope);
        
%000000     table_q_t rq;
%000000     uvm_resource_base r;
%000000     int unsigned i;
        
%000000     int unsigned err;
%000000     uvm_resource_types::rsrc_q_t q = new();
        
            //iterate in reverse order for the special case of autoconfig
            //of arrays. The array name with no [] needs to be higher priority.
            //This has no effect an manual accesses.
%000000     string name;
        
%000000     if(rtab.last(name)) begin
%000000       do begin
%000000         rq = rtab[name];
%000000         for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000           uvm_resource_base rsrc_iter;
%000000           rsrc_iter = `M__TABLE_GET(rq, iter);
%000000           if(rsrc_iter != null && uvm_is_match(rsrc_iter.get_scope(), scope)) begin
%000000             q.push_back(rsrc_iter);
                  end
                end
%000000       end while(rtab.prev(name));
            end
        
%000000     return q;
            
          endfunction
        
          //--------------------
          // Group -- NODOCS -- Set Priority
          //--------------------
          //
          // Functions for altering the search priority of resources.  Resources
          // are stored in queues in the type and name maps.  When retrieving
          // resources, either by type or by name, the resource queue is search
          // from front to back.  The first one that matches the search criteria
          // is the one that is returned.  The ~set_priority~ functions let you
          // change the order in which resources are searched.  For any
          // particular resource, you can set its priority to UVM_HIGH, in which
          // case the resource is moved to the front of the queue, or to UVM_LOW in
          // which case the resource is moved to the back of the queue.
        
          // function- set_priority_queue
          //
          // This function handles the mechanics of moving a resource to either
          // the front or back of the queue.
        
 000012   local function void set_priority_queue(uvm_resource_base rsrc,
                                                 table_q_t rq,
                                                 uvm_resource_types::priority_e pri);
        
 000012     uvm_resource_base r;
 000012     int unsigned i;
        
 000012     string msg;
 000012     string name = rsrc.get_name();
        
~000012     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000009       r = `M__TABLE_GET(rq, iter); // save for later
%000009       if (r == rsrc) begin
%000000         i = iter;
%000000         break;
              end
            end
        
~000012     if(r != rsrc) begin
%000000       $sformat(msg, "Handle for resource named %s is not in the name table; cannot change its priority", name);
%000000       uvm_report_error("NORSRC", msg);
%000000       return;
            end
        
 000012     `M__TABLE_Q(rq).delete(i);
        
 000012     case(pri)
 000012       uvm_resource_types::PRI_HIGH: begin
 000012         `M__TABLE_Q(rq).push_front(rsrc);
              end
%000000       uvm_resource_types::PRI_LOW: begin
%000000         `M__TABLE_Q(rq).push_back(rsrc);
              end
            endcase
        
         endfunction
        
        
          // Function -- NODOCS -- set_priority_type
          //
          // Change the priority of the ~rsrc~ based on the value of ~pri~, the
          // priority enum argument.  This function changes the priority only in
          // the type map, leaving the name map untouched.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.5.1
%000000   function void set_priority_type(uvm_resource_base rsrc,
                                          uvm_resource_types::priority_e pri);
        
%000000     uvm_resource_base type_handle;
%000000     string msg;
%000000     table_q_t rq;
        
%000000     if(rsrc == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to change the search priority of a null resource");
%000000       return;
            end
        
%000000     type_handle = rsrc.get_type_handle();
%000000     if(!ttab.exists(type_handle)) begin
%000000       $sformat(msg, "Type handle for resrouce named %s not found in type map; cannot change its search priority", rsrc.get_name());
%000000       uvm_report_error("RNFTYPE", msg);
%000000       return;
            end
        
%000000     rq = ttab[type_handle];
%000000     set_priority_queue(rsrc, rq, pri);
          endfunction
        
        
          // Function -- NODOCS -- set_priority_name
          //
          // Change the priority of the ~rsrc~ based on the value of ~pri~, the
          // priority enum argument.  This function changes the priority only in
          // the name map, leaving the type map untouched.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.5.2
 000012   function void set_priority_name(uvm_resource_base rsrc,
                                          uvm_resource_types::priority_e pri);
        
 000012     string name;
 000012     string msg;
        
~000012     if(rsrc == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to change the search priority of a null resource");
%000000       return;
            end
        
 000012     name = rsrc.get_name();
~000012     if(!rtab.exists(name)) begin
%000000       $sformat(msg, "Resrouce named %s not found in name map; cannot change its search priority", name);
%000000       uvm_report_error("RNFNAME", msg);
%000000       return;
            end
        
 000012     set_priority_queue(rsrc, rtab[name], pri);
            
          endfunction
        
        
          // Function -- NODOCS -- set_priority
          //
          // Change the search priority of the ~rsrc~ based on the value of ~pri~,
          // the priority enum argument.  This function changes the priority in
          // both the name and type maps.
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.5.3
%000000   function void set_priority (uvm_resource_base rsrc,
                                      uvm_resource_types::priority_e pri);
%000000     set_priority_type(rsrc, pri);
%000000     set_priority_name(rsrc, pri);
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto C.2.4.5.4
%000000   static function void set_default_precedence( int unsigned precedence);
%000000     uvm_coreservice_t cs = uvm_coreservice_t::get();
%000000     cs.set_resource_pool_default_precedence(precedence);
          endfunction
        
        
 000012   static function int unsigned get_default_precedence();
 000012     uvm_coreservice_t cs = uvm_coreservice_t::get();
 000012     return cs.get_resource_pool_default_precedence(); 
          endfunction
        
          
          // @uvm-ieee 1800.2-2020 auto C.2.4.5.6
 000012   virtual function void set_precedence(uvm_resource_base r,
                                               int unsigned p=uvm_resource_pool::get_default_precedence());
        
 000012     table_q_t rq;
 000012     string name;
 000012     int unsigned i;
 000012     uvm_resource_base rsrc;
        
~000012     if(r == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to set precedence of a null resource");
%000000       return;
            end
        
 000012     name = r.get_name();
~000012     if(rtab.exists(name)) begin
 000012       rq = rtab[name];
~000012       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000009         rsrc = `M__TABLE_GET(rq, iter); // Save for use later
%000009         if (rsrc == r) begin
%000000           break;
                end
        
              end
            end 
          
~000012     if(r != rsrc) begin
%000000       uvm_report_warning("NORSRC", $sformatf("resource named %s is not placed within the pool", name));
%000000       return;
            end
        
 000012     r.precedence = p;
        
          endfunction
        
        
%000000   virtual function int unsigned get_precedence(uvm_resource_base r);
        
%000000     table_q_t rq;
%000000     string name;
%000000     int unsigned i;
%000000     uvm_resource_base rsrc;
        
%000000     if(r == null) begin
%000000       uvm_report_warning("NULLRASRC", "attempting to get precedence of a null resource");
%000000       return uvm_resource_pool::get_default_precedence();
            end
        
%000000     name = r.get_name();
%000000     if(rtab.exists(name)) begin
%000000       rq = rtab[name];
        
%000000       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000         rsrc = `M__TABLE_GET(rq, iter); // Save for use later
%000000         if(rsrc == r) begin
%000000           break;
                end
        
              end
            end 
          
%000000     if(r != rsrc) begin
%000000       uvm_report_warning("NORSRC", $sformatf("resource named %s is not placed within the pool", name));
%000000       return uvm_resource_pool::get_default_precedence();
            end
        
%000000     return r.precedence;
        
          endfunction
        
        
          //--------------------------------------------------------------------
          // Group -- NODOCS -- Debug
          //--------------------------------------------------------------------
        
          // Function: find_unused_resources
          //
          // Locate all the resources that have at least one write and no reads
          //
          // @uvm-accellera The details of this API are specific to the Accellera implementation, and are not being considered for contribution to 1800.2
        
%000000   function uvm_resource_types::rsrc_q_t find_unused_resources();
        
%000000     table_q_t rq;
%000000     uvm_resource_types::rsrc_q_t q = new;
%000000     int unsigned i;
%000000     uvm_resource_base r;
%000000     uvm_resource_types::access_t a;
%000000     int reads;
%000000     int writes;
        
%000000     foreach (rtab[name]) begin
%000000       rq = rtab[name];
%000000       for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000         uvm_resource_base rsrc_iter;
%000000         rsrc_iter = `M__TABLE_GET(rq, iter);
%000000         reads = 0;
%000000         writes = 0;
%000000         foreach(rsrc_iter.dbg.access[str]) begin
%000000           a = rsrc_iter.dbg.access[str];
%000000           reads += a.read_count;
%000000           writes += a.write_count;
                end
%000000         if(writes > 0 && reads == 0) begin
                  
%000000           q.push_back(rsrc_iter);
                end
        
              end
            end
        
%000000     return q;
        
          endfunction
        
        
          // Prints a single resource queue element into ~printer~
%000000   function void m_print_resource_element(uvm_printer printer,
                                                 int unsigned iter,
                                                 uvm_resource_base r,
                                                 bit audit=0);
%000000     string scope;
%000000     printer.push_element($sformatf("[%0d]", iter),
%000000                          "uvm_resource",
%000000                          "-",
%000000                          "-");
            
%000000     void'(get_scope(r, scope));
                
%000000     printer.print_string("name", r.get_name());
        
%000000     printer.print_generic_element("value",
%000000                                   r.m_value_type_name(),
%000000                                   "",
%000000                                   r.m_value_as_string());
                                            
%000000     printer.print_string("scope", scope);
        
%000000     printer.print_field_int("precedence", get_precedence(r), 32, UVM_UNSIGNED);
%000000     if (audit && (r.dbg!=null)) begin
%000000       if (r.dbg.access.size()) begin
%000000         printer.print_array_header("accesses",
%000000                                    r.dbg.access.size(),
%000000                                    "queue");
%000000         foreach(r.dbg.access[i]) begin
%000000           printer.print_string($sformatf("[%s]", i),
%000000                                $sformatf("reads: %0d @ %0t  writes: %0d @ %0t",
%000000                                          r.dbg.access[i].read_count,
%000000                                          r.dbg.access[i].read_time,
%000000                                          r.dbg.access[i].write_count,
%000000                                          r.dbg.access[i].write_time));
                end // foreach(r.dbg.access[i])
                
%000000         printer.print_array_footer(r.dbg.access.size());
              end // (r.dbg.access.size())
            end // (audit)
            
%000000     printer.pop_element();
          endfunction : m_print_resource_element
            
          
          // Prints resouce queue into ~printer~, non-LRM
%000000   function void m_print_resources(uvm_printer printer,
                                          string name,
                                          table_q_t rq,
                                          bit audit = 0);
            
%000000     printer.push_element(name,
%000000                          `M__TABLE_NAME,
%000000                          $sformatf("%0d", `M__TABLE_Q(rq).size()));
        
%000000     for (int iter=0; iter < `M__TABLE_Q(rq).size(); iter++) begin
%000000       m_print_resource_element(printer, iter, `M__TABLE_GET(rq, iter), audit);
            end
        
%000000     printer.pop_element();
        
          endfunction : m_print_resources
                                          
          
          // Function -- NODOCS -- print_resources
          //
          // Print the resources that are in a single queue, ~rq~.  This is a utility
          // function that can be used to print any collection of resources
          // stored in a queue.  The ~audit~ flag determines whether or not the
          // audit trail is printed for each resource along with the name,
          // value, and scope regular expression.
        
%000000   function void print_resources(uvm_resource_types::rsrc_q_t rq, bit audit = 0);
        
%000000     int unsigned i;
%000000     string id;
%000000     static uvm_tree_printer printer = new();
        
            // Basically this is full implementation of something
            // like uvm_object::print, but we're interleaving
            // scope data, so it's all manual.
%000000     printer.flush();
%000000     if (rq == null) begin
%000000       printer.print_generic_element("",
%000000                                     "uvm_queue#(uvm_resource_base)",
%000000                                     "",
%000000                                     "<null>");
            end
%000000     else begin
%000000       printer.push_element(rq.get_name(),
%000000                            "uvm_queue#(uvm_resource_base)",
%000000                            $sformatf("%0d",rq.size()),
%000000                            uvm_object_value_str(rq));
        
%000000       for (int i = 0; i < rq.size(); i++) begin
%000000         m_print_resource_element(printer, i, rq.get(i), audit);
              end
        
%000000       printer.pop_element();
            end
            `uvm_info("UVM/RESOURCE_POOL/PRINT_QUEUE",
                      printer.emit(),
%000000               UVM_NONE)
          endfunction
        
        
          // Function -- NODOCS -- dump
          //
          // dump the entire resource pool.  The resource pool is traversed and
          // each resource is printed.  The utility function print_resources()
          // is used to initiate the printing. If the ~audit~ bit is set then
          // the audit trail is dumped for each resource.
        
%000000   function void dump(bit audit = 0, uvm_printer printer = null);
        
%000000     string name;
%000000     static uvm_tree_printer m_printer;
        
%000000     if (m_printer == null) begin
%000000       m_printer = new();
%000000       m_printer.set_type_name_enabled(1);
            end
              
        
%000000     if (printer == null) begin
              
%000000       printer = m_printer;
            end
        
            
%000000     printer.flush();
%000000     printer.push_element("uvm_resource_pool",
%000000                          "",
%000000                          $sformatf("%0d",rtab.size()),
%000000                          "");
            
%000000     foreach (rtab[name]) begin
%000000       m_print_resources(printer, name, rtab[name], audit);
            end
        
%000000     printer.pop_element();
            
%000000     `uvm_info("UVM/RESOURCE/DUMP", printer.emit(), UVM_NONE)
        
          endfunction
          
        endclass
        
        
        `undef M__TABLE_Q
        `undef M__TABLE_GET
        `undef M__TABLE_NAME
        
