//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2021-2022 Marvell International Ltd.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_objection.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_OBJECTION_SVH
        `define UVM_OBJECTION_SVH
        
        typedef class uvm_objection_context_object;
        typedef class uvm_objection;
        typedef class uvm_sequence_base;
        typedef class uvm_objection_callback;
        typedef uvm_callbacks #(uvm_objection,uvm_objection_callback) uvm_objection_cbs_t /* @uvm-ieee 1800.2-2020 auto D.4.2*/ ;
        typedef class uvm_cmdline_processor;
        
%000006 class uvm_objection_events;
          int waiters;
          event raised;
          event dropped;
          event all_dropped;
        endclass
        
        //------------------------------------------------------------------------------
        // Title -- NODOCS -- Objection Mechanism
        //------------------------------------------------------------------------------
        // The following classes define the objection mechanism and end-of-test
        // functionality, which is based on <uvm_objection>.
        //------------------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_objection
        //
        //------------------------------------------------------------------------------
        // Objections provide a facility for coordinating status information between
        // two or more participating components, objects, and even module-based IP.
        //
        // Tracing of objection activity can be turned on to follow the activity of
        // the objection mechanism. It may be turned on for a specific objection
        // instance with <uvm_objection::trace_mode>, or it can be set for all 
        // objections from the command line using the option +UVM_OBJECTION_TRACE.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 10.5.1
        // @uvm-ieee 1800.2-2020 auto 10.5.1.1
        class uvm_objection extends uvm_report_object;
%000003   `uvm_register_cb(uvm_objection, uvm_objection_callback)
        
          protected bit     m_trace_mode;
          protected int     m_source_count[uvm_object];
          protected int     m_total_count [uvm_object];
          protected time    m_drain_time  [uvm_object];
          protected uvm_objection_events m_events [uvm_object];
          /*protected*/ bit     m_top_all_dropped;
        
          protected uvm_root m_top;
             
          static uvm_objection m_objections[$];
        
          //// Drain Logic
        
          // The context pool holds used context objects, so that
          // they're not constantly being recreated.  The maximum
          // number of contexts in the pool is equal to the maximum
          // number of simultaneous drains you could have occuring,
          // both pre and post forks.
          //
          // There's the potential for a programmability within the
          // library to dictate the largest this pool should be allowed
          // to grow, but that seems like overkill for the time being.
          local static uvm_objection_context_object m_context_pool[$];
        
          // These are the active drain processes, which have been
          // forked off by the background process.  A raise can
          // use this array to kill a drain.
        `ifndef UVM_USE_PROCESS_CONTAINER   
          local process m_drain_proc[uvm_object];
        `else
          local process_container_c m_drain_proc[uvm_object];
        `endif
           
          // These are the contexts which have been scheduled for
          // retrieval by the background process, but which the
          // background process hasn't seen yet.
          local static uvm_objection_context_object m_scheduled_list[$];
        
          // Once a context is seen by the background process, it is
          // removed from the scheduled list, and placed in the forked
          // list.  At the same time, it is placed in the scheduled
          // contexts array.  A re-raise can use the scheduled contexts
          // array to detect (and cancel) the drain.
          local uvm_objection_context_object m_scheduled_contexts[uvm_object];
          local uvm_objection_context_object m_forked_list[$];
        
          // Once the forked drain has actually started (this occurs
          // ~1 delta AFTER the background process schedules it), the
          // context is removed from the above array and list, and placed
          // in the forked_contexts list.  
          local uvm_objection_context_object m_forked_contexts[uvm_object];
        
 000042   protected bit m_prop_mode = 1;
          protected bit m_cleared; /* for checking obj count<0 */
        
        
          // Function -- NODOCS -- new
          //
          // Creates a new objection instance. Accesses the command line
          // argument +UVM_OBJECTION_TRACE to turn tracing on for
          // all objection objects.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.2
 000042   function new(string name="");
 000042     uvm_cmdline_processor clp;
 000042     uvm_coreservice_t cs_ ;
 000042     string trace_args[$];
 000042     super.new(name);
 000042     cs_ = uvm_coreservice_t::get();
 000042     m_top  = cs_.get_root();
             
 000042     set_report_verbosity_level(m_top.get_report_verbosity_level());
        
            // Get the command line trace mode setting
 000042     clp = uvm_cmdline_processor::get_inst();
~000042     if(clp.get_arg_matches("+UVM_OBJECTION_TRACE", trace_args)) 
%000000       begin
%000000         m_trace_mode=1;
              end
 000042     m_objections.push_back(this);
          endfunction
        
        
          // Function -- NODOCS -- trace_mode
          //
          // Set or get the trace mode for the objection object. If no
          // argument is specified (or an argument other than 0 or 1)
          // the current trace mode is unaffected. A trace_mode of
          // 0 turns tracing off. A trace mode of 1 turns tracing on.
          // The return value is the mode prior to being reset.
        
%000000    function bit trace_mode (int mode=-1);
%000000     trace_mode = m_trace_mode;
%000000     if(mode == 0) 
%000000       begin
%000000         m_trace_mode = 0;
              end
        
%000000     else if(mode == 1) 
%000000       begin
%000000         m_trace_mode = 1;
              end
        
           endfunction
        
          // Function- m_report
          //
          // Internal method for reporting count updates
        
%000000   function void m_report(uvm_object obj, uvm_object source_obj, string description, int count, string action);
%000000     int _count = m_source_count.exists(obj) ? m_source_count[obj] : 0;
%000000     int _total = m_total_count.exists(obj) ? m_total_count[obj] : 0;
%000000     if (!uvm_report_enabled(UVM_NONE,UVM_INFO,"OBJTN_TRC") || !m_trace_mode) 
%000000       begin
%000000         return;
              end
        
        
%000000     if (source_obj == obj)
        
%000000       begin
%000000         uvm_report_info("OBJTN_TRC", 
%000000         $sformatf("Object %0s %0s %0d %0s objection(s)%s: count=%0d  total=%0d",
%000000            obj.get_full_name()==""?"uvm_top":obj.get_full_name(), action,
%000000            count, get_full_name(), description != ""? {" (",description,")"}:"", _count, _total), UVM_NONE);
              end
        
            else 
%000000       begin
%000000         int cpath = 0, last_dot=0;
%000000         string sname = source_obj.get_full_name(), nm = obj.get_full_name();
%000000         int max = sname.len() > nm.len() ? nm.len() : sname.len();
        
                // For readability, only print the part of the source obj hierarchy underneath
                // the current object.
%000000         while((sname[cpath] == nm[cpath]) && (cpath < max)) 
%000000         begin
%000000           if(sname[cpath] == ".") 
%000000             begin
%000000               last_dot = cpath;
                    end
        
%000000           cpath++;
                end 
        
%000000         if(last_dot) 
%000000           begin
%000000             sname = sname.substr(last_dot+1, sname.len());
                  end
        
%000000         uvm_report_info("OBJTN_TRC",
%000000         $sformatf("Object %0s %0s %0d %0s objection(s) %0s its total (%s from source object %s%s): count=%0d  total=%0d",
%000000            obj.get_full_name()==""?"uvm_top":obj.get_full_name(), action=="raised"?"added":"subtracted",
%000000             count, get_full_name(), action=="raised"?"to":"from", action, sname, 
%000000             description != ""?{", ",description}:"", _count, _total), UVM_NONE);
              end
          endfunction
        
        
          // Function- m_get_parent
          //
          // Internal method for getting the parent of the given ~object~.
          // The ultimate parent is uvm_top, UVM's implicit top-level component. 
        
 000168   function uvm_object m_get_parent(uvm_object obj);
 000168     uvm_component comp;
 000168     uvm_sequence_base seq;
%000006     if ($cast(comp, obj)) 
%000006       begin
%000006         obj = comp.get_parent();
              end
~000162     else if ($cast(seq, obj)) 
%000000       begin
%000000         obj = seq.get_sequencer();
              end
            else
 000162       begin
 000162         obj = m_top;
              end
        
~000168     if (obj == null)
%000000       begin
%000000         obj = m_top;
              end
        
 000168     return obj;
          endfunction
        
        
          // Function- m_propagate
          //
          // Propagate the objection to the objects parent. If the object is a
          // component, the parent is just the hierarchical parent. If the object is
          // a sequence, the parent is the parent sequence if one exists, or
          // it is the attached sequencer if there is no parent sequence. 
          //
          // obj : the uvm_object on which the objection is being raised or lowered
          // source_obj : the root object on which the end user raised/lowered the 
          //   objection (as opposed to an anscestor of the end user object)a
          // count : the number of objections associated with the action.
          // raise : indicator of whether the objection is being raised or lowered. A
          //   1 indicates the objection is being raised.
        
 000168   function void m_propagate (uvm_object obj,
                                     uvm_object source_obj,
                                     string description,
                                     int count,
                                     bit raise,
                                     int in_top_thread);
~000168     if (obj != null && obj != m_top) 
 000168       begin
 000168         obj = m_get_parent(obj);
 000084         if(raise)
 000084         begin
 000084           m_raise(obj, source_obj, description, count);
                end
        
                else
 000084         begin
 000084           m_drop(obj, source_obj, description, count, in_top_thread);
                end
        
              end
          endfunction
        
        
          // Group -- NODOCS -- Objection Control
        
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.2
%000000   function void set_propagate_mode (bit prop_mode);
%000000      if (!m_top_all_dropped && (get_objection_total() != 0)) 
%000000        begin
                 `uvm_error("UVM/BASE/OBJTN/PROP_MODE",
                 {"The propagation mode of '", this.get_full_name(),
                 "' cannot be changed while the objection is raised ",
%000000          "or draining!"})
%000000          return;
               end
        
%000000      m_prop_mode = prop_mode;
          endfunction : set_propagate_mode
        
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.1
%000000   function bit get_propagate_mode();
%000000      return m_prop_mode;
          endfunction : get_propagate_mode
           
          // Function -- NODOCS -- raise_objection
          //
          // Raises the number of objections for the source ~object~ by ~count~, which
          // defaults to 1.  The ~object~ is usually the ~this~ handle of the caller.
          // If ~object~ is not specified or ~null~, the implicit top-level component,
          // <uvm_root>, is chosen.
          //
          // Raising an objection causes the following.
          //
          // - The source and total objection counts for ~object~ are increased by
          //   ~count~. ~description~ is a string that marks a specific objection
          //   and is used in tracing/debug.
          //
          // - The objection's <raised> virtual method is called, which calls the
          //   <uvm_component::raised> method for all of the components up the 
          //   hierarchy.
          //
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.3
 000084   virtual function void raise_objection (uvm_object obj=null,
                                                 string description="",
                                                 int count=1);
~000084     if(obj == null)
%000000       begin
%000000         obj = m_top;
              end
        
 000084     m_cleared = 0;
 000084     m_top_all_dropped = 0;
 000084     m_raise (obj, obj, description, count);
          endfunction
        
        
          // Function- m_raise
        
 000168   function void m_raise (uvm_object obj,
                                 uvm_object source_obj,
                                 string description="",
                                 int count=1);
 000168     int idx;
 000168     uvm_objection_context_object ctxt;
        
            // Ignore raise if count is 0
~000168     if (count == 0)
%000000       begin
%000000         return;
              end
        
        
 000090     if (m_total_count.exists(obj))
 000078       begin
 000078         m_total_count[obj] += count;
              end
        
            else 
 000090       begin
 000090         m_total_count[obj] = count;
              end
        
        
 000084     if (source_obj==obj) 
 000084       begin
~000084         if (m_source_count.exists(obj))
%000000         begin
%000000           m_source_count[obj] += count;
                end
        
                else
 000084         begin
 000084           m_source_count[obj] = count;
                end
        
              end
          
~000168     if (m_trace_mode)
%000000       begin
%000000         m_report(obj,source_obj,description,count,"raised");
              end
        
        
 000168     raised(obj, source_obj, description, count);
        
              // Handle any outstanding drains...
        
            // First go through the scheduled list
 000168     idx = 0;
~000168     while (idx < m_scheduled_list.size()) 
%000006       begin
%000006         if ((m_scheduled_list[idx].obj == obj) &&
                (m_scheduled_list[idx].objection == this)) 
%000000         begin
                  // Caught it before the drain was forked
%000000           ctxt = m_scheduled_list[idx];
%000000           m_scheduled_list.delete(idx);
%000000           break;
                end
%000006         idx++;
              end
        
            // If it's not there, go through the forked list
~000168     if (ctxt == null) 
 000168       begin
 000168         idx = 0;
~000168         while (idx < m_forked_list.size()) 
%000000         begin
%000000           if (m_forked_list[idx].obj == obj) 
%000000           begin
                    // Caught it after the drain was forked,
                    // but before the fork started
%000000             ctxt = m_forked_list[idx];
%000000             m_forked_list.delete(idx);
%000000             m_scheduled_contexts.delete(ctxt.obj);
%000000             break;
                  end
%000000           idx++;
                end
              end
        
            // If it's not there, go through the forked contexts
~000168     if (ctxt == null) 
 000168       begin
~000168         if (m_forked_contexts.exists(obj)) 
%000000         begin
                  // Caught it with the forked drain running
%000000           ctxt = m_forked_contexts[obj];
%000000           m_forked_contexts.delete(obj);
                  // Kill the drain
        `ifndef UVM_USE_PROCESS_CONTAINER       
%000000           m_drain_proc[obj].kill();
%000000           m_drain_proc.delete(obj);
        `else
                  m_drain_proc[obj].p.kill();
                  m_drain_proc.delete(obj);
        `endif
               
                end
              end
        
~000168     if (ctxt == null) 
 000168       begin
                // If there were no drains, just propagate as usual
        
%000000         if (!m_prop_mode && obj != m_top)
%000000         begin
%000000           m_raise(m_top,source_obj,description,count);
                end
        
 000084         else if (obj != m_top)
 000084         begin
 000084           m_propagate(obj, source_obj, description, count, 1, 0);
                end
        
              end
            else 
%000000       begin
                // Otherwise we need to determine what exactly happened
%000000         int diff_count;
        
                // Determine the diff count, if it's positive, then we're
                // looking at a 'raise' total, if it's negative, then
                // we're looking at a 'drop', but not down to 0.  If it's
                // a 0, that means that there is no change in the total.
%000000         diff_count = count - ctxt.count;
        
%000000         if (diff_count != 0) 
%000000         begin
                  // Something changed
%000000           if (diff_count > 0) 
%000000           begin
                    // we're looking at an increase in the total
%000000             if (!m_prop_mode && obj != m_top)
%000000             begin
%000000               m_raise(m_top, source_obj, description, diff_count);
                    end
        
%000000             else if (obj != m_top)
%000000             begin
%000000               m_propagate(obj, source_obj, description, diff_count, 1, 0);
                    end
        
                  end
                  else 
%000000           begin
                    // we're looking at a decrease in the total
                    // The count field is always positive...
%000000             diff_count = -diff_count;
%000000             if (!m_prop_mode && obj != m_top)
%000000             begin
%000000               m_drop(m_top, source_obj, description, diff_count);
                    end
        
%000000             else if (obj != m_top)
%000000             begin
%000000               m_propagate(obj, source_obj, description, diff_count, 0, 0);
                    end
        
                  end
                end
        
                // Cleanup
%000000         ctxt.clear();
%000000         m_context_pool.push_back(ctxt);
              end
                
          endfunction
          
        
          // Function -- NODOCS -- drop_objection
          //
          // Drops the number of objections for the source ~object~ by ~count~, which
          // defaults to 1.  The ~object~ is usually the ~this~ handle of the caller.
          // If ~object~ is not specified or ~null~, the implicit top-level component,
          // <uvm_root>, is chosen.
          //
          // Dropping an objection causes the following.
          //
          // - The source and total objection counts for ~object~ are decreased by
          //   ~count~. It is an error to drop the objection count for ~object~ below
          //   zero.
          //
          // - The objection's <dropped> virtual method is called, which calls the
          //   <uvm_component::dropped> method for all of the components up the 
          //   hierarchy.
          //
          // - If the total objection count has not reached zero for ~object~, then
          //   the drop is propagated up the object hierarchy as with
          //   <raise_objection>. Then, each object in the hierarchy will have updated
          //   their ~source~ counts--objections that they originated--and ~total~
          //   counts--the total number of objections by them and all their
          //   descendants.
          //
          // If the total objection count reaches zero, propagation up the hierarchy
          // is deferred until a configurable drain-time has passed and the 
          // <uvm_component::all_dropped> callback for the current hierarchy level
          // has returned. The following process occurs for each instance up
          // the hierarchy from the source caller:
          //
          // A process is forked in a non-blocking fashion, allowing the ~drop~
          // call to return. The forked process then does the following:
          //
          // - If a drain time was set for the given ~object~, the process waits for
          //   that amount of time.
          //
          // - The objection's <all_dropped> virtual method is called, which calls the
          //   <uvm_component::all_dropped> method (if ~object~ is a component).
          //
          // - The process then waits for the ~all_dropped~ callback to complete.
          //
          // - After the drain time has elapsed and all_dropped callback has
          //   completed, propagation of the dropped objection to the parent proceeds
          //   as described in <raise_objection>, except as described below.
          //
          // If a new objection for this ~object~ or any of its descendants is raised
          // during the drain time or during execution of the all_dropped callback at
          // any point, the hierarchical chain described above is terminated and the
          // dropped callback does not go up the hierarchy. The raised objection will
          // propagate up the hierarchy, but the number of raised propagated up is
          // reduced by the number of drops that were pending waiting for the 
          // all_dropped/drain time completion. Thus, if exactly one objection
          // caused the count to go to zero, and during the drain exactly one new
          // objection comes in, no raises or drops are propagated up the hierarchy,
          //
          // As an optimization, if the ~object~ has no set drain-time and no
          // registered callbacks, the forked process can be skipped and propagation
          // proceeds immediately to the parent as described. 
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.4
 000084   virtual function void drop_objection (uvm_object obj=null,
                                                string description="",
                                                int count=1);
~000084     if(obj == null)
%000000       begin
%000000         obj = m_top;
              end
        
 000084     m_drop (obj, obj, description, count, 0);
          endfunction
        
        
          // Function- m_drop
        
 000168   function void m_drop (uvm_object obj,
                                uvm_object source_obj,
                                string description="",
                                int count=1,
%000000                         int in_top_thread=0);
        
            // Ignore drops if the count is 0
~000168     if (count == 0)
%000000       begin
%000000         return;
              end
        
        
~000168     if (!m_total_count.exists(obj) || (count > m_total_count[obj])) 
%000000       begin
%000000         if(m_cleared)
%000000         begin
%000000           return;
                end
        
%000000         uvm_report_fatal("OBJTN_ZERO", {"Object \"", obj.get_full_name(), 
%000000         "\" attempted to drop objection '",this.get_name(),"' count below zero"});
%000000         return;
              end
        
 000084     if (obj == source_obj) 
 000084       begin
~000084         if (!m_source_count.exists(obj) || (count > m_source_count[obj])) 
%000000         begin
%000000           if(m_cleared)
%000000           begin
%000000             return;
                  end
        
%000000           uvm_report_fatal("OBJTN_ZERO", {"Object \"", obj.get_full_name(), 
%000000           "\" attempted to drop objection '",this.get_name(),"' count below zero"});
%000000           return;
                end
 000084         m_source_count[obj] -= count;
              end
        
 000168     m_total_count[obj] -= count;
        
~000168     if (m_trace_mode)
%000000       begin
%000000         m_report(obj,source_obj,description,count,"dropped");
              end
        
            
 000168     dropped(obj, source_obj, description, count);
          
            // if count != 0, no reason to fork
 000090     if (m_total_count[obj] != 0) 
 000078       begin
%000000         if (!m_prop_mode && obj != m_top)
%000000         begin
%000000           m_drop(m_top,source_obj,description, count, in_top_thread);
                end
        
~000078         else if (obj != m_top) 
%000000         begin
%000000           this.m_propagate(obj, source_obj, description, count, 0, in_top_thread);
                end
        
              end
            else 
 000090       begin
 000090         uvm_objection_context_object ctxt;
~000084         if (m_context_pool.size())
 000084         begin
 000084           ctxt = m_context_pool.pop_front();
                end
        
                else
%000006         begin
%000006           ctxt = new;
                end
        
        
 000090         ctxt.obj = obj;
 000090         ctxt.source_obj = source_obj;
 000090         ctxt.description = description;
 000090         ctxt.count = count;
 000090         ctxt.objection = this;
                // Need to be thread-safe, let the background
                // process handle it.
        
                // Why don't we look at in_top_thread here?  Because
                // a re-raise will kill the drain at object that it's
                // currently occuring at, and we need the leaf-level kills
                // to not cause accidental kills at branch-levels in
                // the propagation.
        
                // Using the background process just allows us to
                // separate the links of the chain.
 000090         m_scheduled_list.push_back(ctxt);
        
              end // else: !if(m_total_count[obj] != 0)
        
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.5
 000078   virtual function void clear(uvm_object obj=null);
 000078     string name;
 000078     int  idx;
        
~000078     if (obj==null)
 000078       begin
 000078         obj=m_top;
              end
        
 000078     name = obj.get_full_name();
~000078     if (name == "")
 000078       begin
 000078         name = "uvm_top";
              end
        
            else
%000000       begin
%000000         name = obj.get_full_name();
              end
        
~000078     if (!m_top_all_dropped && get_objection_total(m_top))
%000000       begin
%000000         uvm_report_warning("OBJTN_CLEAR",{"Object '",name,
%000000             "' cleared objection counts for ",get_name()});
              end
        
            //Should there be a warning if there are outstanding objections?
 000078     m_source_count.delete();
 000078     m_total_count.delete();
        
            // Remove any scheduled drains from the static queue
 000078     idx = 0;
%000000     while (idx < m_scheduled_list.size()) 
%000000       begin
%000000         if (m_scheduled_list[idx].objection == this) 
%000000         begin
%000000           m_scheduled_list[idx].clear();
%000000           m_context_pool.push_back(m_scheduled_list[idx]);
%000000           m_scheduled_list.delete(idx);
                end
                else 
%000000         begin
%000000           idx++;
                end
              end
        
            // Scheduled contexts and m_forked_lists have duplicate
            // entries... clear out one, free the other.
 000078     m_scheduled_contexts.delete();
%000000     while (m_forked_list.size()) 
%000000       begin
%000000         m_forked_list[0].clear();
%000000         m_context_pool.push_back(m_forked_list[0]);
%000000         void'(m_forked_list.pop_front());
              end
        
            // running drains have a context and a process
~000078     foreach (m_forked_contexts[o]) 
%000000       begin
        `ifndef UVM_USE_PROCESS_CONTAINER       
%000000         m_drain_proc[o].kill();
%000000         m_drain_proc.delete(o);
        `else
                m_drain_proc[o].p.kill();
                m_drain_proc.delete(o);
        `endif
               
%000000         m_forked_contexts[o].clear();
%000000         m_context_pool.push_back(m_forked_contexts[o]);
%000000         m_forked_contexts.delete(o);
              end
        
 000078     m_top_all_dropped = 0;
 000078     m_cleared = 1;
~000078     if (m_events.exists(m_top))
%000000       begin
%000000         ->m_events[m_top].all_dropped;
              end
        
        
          endfunction
        
          // m_execute_scheduled_forks
          // -------------------------
        
          // background process; when non
%000000   static task m_execute_scheduled_forks();
 000090     while(1) 
 000090       begin
 000090         wait(m_scheduled_list.size() != 0);
~000090         if(m_scheduled_list.size() != 0) 
 000090           begin
 000090             uvm_objection_context_object c;
                    // Save off the context before the fork
 000090             c = m_scheduled_list.pop_front();
                    // A re-raise can use this to figure out props (if any)
 000090             c.objection.m_scheduled_contexts[c.obj] = c;
                    // The fork below pulls out from the forked list
 000090             c.objection.m_forked_list.push_back(c);
                    // The fork will guard the m_forked_drain call, but
                    // a re-raise can kill m_forked_list contexts in the delta
                    // before the fork executes.
 000090             fork : guard
 000090               automatic uvm_objection objection = c.objection;
 000090               begin
                        // Check to maike sure re-raise didn't empty the fifo
~000090                 if (objection.m_forked_list.size() > 0) 
 000090                   begin
 000090                     uvm_objection_context_object ctxt;
 000090                     ctxt = objection.m_forked_list.pop_front();
                            // Clear it out of scheduled
 000090                     objection.m_scheduled_contexts.delete(ctxt.obj);
                            // Move it in to forked (so re-raise can figure out props)
 000090                     objection.m_forked_contexts[ctxt.obj] = ctxt;
                            // Save off our process handle, so a re-raise can kill it...
        `ifndef UVM_USE_PROCESS_CONTAINER             
 000090                     objection.m_drain_proc[ctxt.obj] = process::self();
        `else
                          begin
                            process_container_c c = new(process::self());
                            objection.m_drain_proc[ctxt.obj]=c;
                          end
        `endif             
                            // Execute the forked drain
 000090                     objection.m_forked_drain(ctxt.obj, ctxt.source_obj, ctxt.description, ctxt.count, 1);
                            // Cleanup if we survived (no re-raises)
 000090                     objection.m_drain_proc.delete(ctxt.obj);
 000090                     objection.m_forked_contexts.delete(ctxt.obj);
                            // Clear out the context object (prevent memory leaks)
 000090                     ctxt.clear();
                            // Save the context in the pool for later reuse
 000090                     m_context_pool.push_back(ctxt);
                          end
                      end
                    join_none : guard
                  end
              end
          endtask
        
        
          // m_forked_drain
          // -------------
        
 000090   task m_forked_drain (uvm_object obj,
                               uvm_object source_obj,
                               string description="",
                               int count=1,
                               int in_top_thread=0);
        
~000090       if (m_drain_time.exists(obj)) 
%000000         begin
%000000           `uvm_delay(m_drain_time[obj])
                end
              
~000090       if (m_trace_mode)
%000000         begin
%000000           m_report(obj,source_obj,description,count,"all_dropped");
                end
        
              
 000090       all_dropped(obj,source_obj,description, count);
                  
                  // wait for all_dropped cbs to complete
 000090       wait fork;
        
              /* NOT NEEDED - Any raise would have killed us!
              if(!m_total_count.exists(obj))
                diff_count = -count;
              else
                diff_count = m_total_count[obj] - count;
              */
        
              // we are ready to delete the 0-count entries for the current
              // object before propagating up the hierarchy. 
~000084       if (m_source_count.exists(obj) && m_source_count[obj] == 0)
 000084         begin
 000084           m_source_count.delete(obj);
                end
        
                  
~000090       if (m_total_count.exists(obj) && m_total_count[obj] == 0)
 000090         begin
 000090           m_total_count.delete(obj);
                end
        
        
%000000       if (!m_prop_mode && obj != m_top)
%000000         begin
%000000           m_drop(m_top,source_obj,description, count, 1);
                end
        
~000084       else if (obj != m_top)
 000084         begin
 000084           m_propagate(obj, source_obj, description, count, 0, 1);
                end
        
        
          endtask
        
        
          // m_init_objections
          // -----------------
        
          // Forks off the single background process
%000003   static function void m_init_objections();
%000003     fork 
%000003       begin
%000003         uvm_objection::m_execute_scheduled_forks();
              end
        
            join_none
          endfunction
        
          // Function -- NODOCS -- set_drain_time
          //
          // Sets the drain time on the given ~object~ to ~drain~.
          //
          // The drain time is the amount of time to wait once all objections have
          // been dropped before calling the all_dropped callback and propagating
          // the objection to the parent. 
          //
          // If a new objection for this ~object~ or any of its descendants is raised
          // during the drain time or during execution of the all_dropped callbacks,
          // the drain_time/all_dropped execution is terminated. 
        
          // AE: set_drain_time(drain,obj=null)?
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.7
%000000   function void set_drain_time (uvm_object obj=null, time drain);
%000000     if (obj==null)
%000000       begin
%000000         obj = m_top;
              end
        
%000000     m_drain_time[obj] = drain;
          endfunction
          
        
          //----------------------
          // Group -- NODOCS -- Callback Hooks
          //----------------------
        
          // Function -- NODOCS -- raised
          //
          // Objection callback that is called when a <raise_objection> has reached ~obj~.
          // The default implementation calls <uvm_component::raised>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.4.1
 000168   virtual function void raised (uvm_object obj,
                                        uvm_object source_obj,
                                        string description,
                                        int count);
 000168     uvm_component comp;
 000087     if ($cast(comp,obj))    
 000087       begin
 000087         comp.raised(this, source_obj, description, count);
              end
        
~000168     `uvm_do_callbacks(uvm_objection,uvm_objection_callback,raised(this,obj,source_obj,description,count))
 000090     if (m_events.exists(obj))
 000078       begin
 000078         ->m_events[obj].raised;
              end
        
          endfunction
        
        
          // Function -- NODOCS -- dropped
          //
          // Objection callback that is called when a <drop_objection> has reached ~obj~.
          // The default implementation calls <uvm_component::dropped>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.4.2
 000168   virtual function void dropped (uvm_object obj,
                                         uvm_object source_obj,
                                         string description,
                                         int count);
 000168     uvm_component comp;
 000087     if($cast(comp,obj))    
 000087       begin
 000087         comp.dropped(this, source_obj, description, count);
              end
        
~000168     `uvm_do_callbacks(uvm_objection,uvm_objection_callback,dropped(this,obj,source_obj,description,count))
 000084     if (m_events.exists(obj))
 000084       begin
 000084         ->m_events[obj].dropped;
              end
        
          endfunction
        
        
          // Function -- NODOCS -- all_dropped
          //
          // Objection callback that is called when a <drop_objection> has reached ~obj~,
          // and the total count for ~obj~ goes to zero. This callback is executed
          // after the drain time associated with ~obj~. The default implementation 
          // calls <uvm_component::all_dropped>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.4.3
 000090   virtual task all_dropped (uvm_object obj,
                                    uvm_object source_obj,
                                    string description,
                                    int count);
 000090     uvm_component comp;
~000081     if($cast(comp,obj))    
%000009       begin
%000009         comp.all_dropped(this, source_obj, description, count);
              end
        
~000090     `uvm_do_callbacks(uvm_objection,uvm_objection_callback,all_dropped(this,obj,source_obj,description,count))
~000084     if (m_events.exists(obj))
%000006       begin
%000006         ->m_events[obj].all_dropped;
              end
        
~000084     if (obj == m_top)
%000006       begin
%000006         m_top_all_dropped = 1;
              end
        
          endtask
        
        
          //------------------------
          // Group -- NODOCS -- Objection Status
          //------------------------
        
          // Function -- NODOCS -- get_objectors
          //
          // Returns the current list of objecting objects (objects that
          // raised an objection but have not dropped it).
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.5.1
%000000   function void get_objectors(ref uvm_object list[$]);
%000000     list.delete();
%000000     foreach (m_source_count[obj]) 
%000000       begin
%000000         list.push_back(obj);
              end
         
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.5.2
%000009   task wait_for(uvm_objection_event objt_event, uvm_object obj=null);
        
%000006      if (obj==null)
%000003        begin
%000003          obj = m_top;
               end
        
        
%000006      if (!m_events.exists(obj)) 
%000006        begin
%000006          m_events[obj] = new;
               end
        
%000009      m_events[obj].waiters++;
%000009      case (objt_event)
%000000        UVM_RAISED:      
%000000          begin
%000000            @(m_events[obj].raised);
                 end
        
%000000        UVM_DROPPED:     
%000000          begin
%000000            @(m_events[obj].dropped);
                 end
        
%000009        UVM_ALL_DROPPED: 
%000009          begin
%000009            @(m_events[obj].all_dropped);
                 end
        
             endcase
             
%000009      m_events[obj].waiters--;
        
%000006      if (m_events[obj].waiters == 0)
%000006        begin
%000006          m_events.delete(obj);
               end
        
        
           endtask
        
        
%000000    task wait_for_total_count(uvm_object obj=null, int count=0);
%000000      if (obj==null)
%000000        begin
%000000          obj = m_top;
               end
        
        
%000000      if(!m_total_count.exists(obj) && count == 0)
%000000        begin
%000000          return;
               end
        
%000000      if (count == 0)
%000000        begin
%000000          wait (!m_total_count.exists(obj) && count == 0);
               end
        
             else
%000000        begin
%000000          wait (m_total_count.exists(obj) && m_total_count[obj] == count);
               end
        
           endtask
           
        
          // Function -- NODOCS -- get_objection_count
          //
          // Returns the current number of objections raised by the given ~object~.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.5.3
%000000   function int get_objection_count (uvm_object obj=null);
%000000     if (obj==null)
%000000       begin
%000000         obj = m_top;
              end
        
        
%000000     if (!m_source_count.exists(obj))
%000000       begin
%000000         return 0;
              end
        
%000000     return m_source_count[obj];
          endfunction
          
        
          // Function -- NODOCS -- get_objection_total
          //
          // Returns the current number of objections raised by the given ~object~ 
          // and all descendants.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.5.4
 000210   function int get_objection_total (uvm_object obj=null);
         
~000210     if (obj==null)
%000000       begin
%000000         obj = m_top;
              end
        
        
%000000     if (!m_total_count.exists(obj))
%000000       begin
%000000         return 0;
              end
        
            else
%000000       begin
%000000         return m_total_count[obj];
              end
        
             
          endfunction
          
        
          // Function -- NODOCS -- get_drain_time
          //
          // Returns the current drain time set for the given ~object~ (default: 0 ns).
        
          // @uvm-ieee 1800.2-2020 auto 10.5.1.3.6
%000000   function time get_drain_time (uvm_object obj=null);
%000000     if (obj==null)
%000000       begin
%000000         obj = m_top;
              end
        
        
%000000     if (!m_drain_time.exists(obj))
%000000       begin
%000000         return 0;
              end
        
%000000     return m_drain_time[obj];
          endfunction
        
        
          // m_display_objections
        
%000000   protected function string m_display_objections(uvm_object obj=null, bit show_header=1);
        
%000000     static string blank="                                                                                   ";
            
%000000     string s;
%000000     int total;
%000000     uvm_object list[string];
%000000     uvm_object curr_obj;
%000000     int depth;
%000000     string name;
%000000     string this_obj_name;
%000000     string curr_obj_name;
          
%000000     foreach (m_total_count[o]) 
%000000       begin
%000000         uvm_object theobj = o; 
%000000         if ( m_total_count[o] > 0)
%000000         begin
%000000           list[theobj.get_full_name()] = theobj;
                end
        
              end
        
%000000     if (obj==null)
%000000       begin
%000000         obj = m_top;
              end
        
        
%000000     total = get_objection_total(obj);
            
%000000     s = $sformatf("The total objection count is %0d\n",total);
        
%000000     if (total == 0)
%000000       begin
%000000         return s;
              end
        
        
%000000     s = {s,"---------------------------------------------------------\n"};
%000000     s = {s,"Source  Total   \n"};
%000000     s = {s,"Count   Count   Object\n"};
%000000     s = {s,"---------------------------------------------------------\n"};
        
          
%000000     this_obj_name = obj.get_full_name();
%000000     curr_obj_name = this_obj_name;
        
%000000     do 
        
%000000       begin
        
%000000         curr_obj = list[curr_obj_name];
          
                // determine depth
%000000         depth=0;
%000000         foreach (curr_obj_name[i])
%000000         begin
%000000           if (curr_obj_name[i] == ".")
%000000           begin
%000000             depth++;
                  end
        
                end
        
        
                // determine leaf name
%000000         name = curr_obj_name;
%000000         for (int i=curr_obj_name.len()-1;i >= 0; i--)
%000000         begin
%000000           if (curr_obj_name[i] == ".") 
%000000             begin
%000000               name = curr_obj_name.substr(i+1,curr_obj_name.len()-1); 
%000000               break;
                    end
                end
        
%000000         if (curr_obj_name == "")
%000000         begin
%000000           name = "uvm_top";
                end
        
                else
%000000         begin
%000000           depth++;
                end
        
        
                // print it
%000000         s = {s, $sformatf("%-6d  %-6d %s%s\n",
%000000          m_source_count.exists(curr_obj) ? m_source_count[curr_obj] : 0,
%000000          m_total_count.exists(curr_obj) ? m_total_count[curr_obj] : 0,
%000000          blank.substr(0,2*depth), name)};
        
%000000       end while (list.next(curr_obj_name) &&
                curr_obj_name.substr(0,this_obj_name.len()-1) == this_obj_name);
          
%000000     s = {s,"---------------------------------------------------------\n"};
        
%000000     return s;
        
          endfunction
          
        
%000000   function string convert2string();
%000000     return m_display_objections(m_top,1);
          endfunction
          
          
          // Function -- NODOCS -- display_objections
          // 
          // Displays objection information about the given ~object~. If ~object~ is
          // not specified or ~null~, the implicit top-level component, <uvm_root>, is
          // chosen. The ~show_header~ argument allows control of whether a header is
          // output.
        
%000000   function void display_objections(uvm_object obj=null, bit show_header=1);
%000000     string m = m_display_objections(obj,show_header);
%000000     `uvm_info("UVM/OBJ/DISPLAY",m,UVM_NONE)
          endfunction
        
        
          // Below is all of the basic data stuff that is needed for a uvm_object
          // for factory registration, printing, comparing, etc.
        
          typedef uvm_object_registry#(uvm_objection,"uvm_objection") type_id;
%000000   static function type_id get_type();
%000000     return type_id::get();
          endfunction
        
%000000   function uvm_object create (string name="");
%000000     uvm_objection tmp = new(name);
%000000     return tmp;
          endfunction
        
%000000   virtual function string get_type_name ();
%000000     return "uvm_objection";
          endfunction
        
%000000   function void do_copy (uvm_object rhs);
%000000     uvm_objection _rhs;
%000000     $cast(_rhs, rhs);
%000000     m_source_count = _rhs.m_source_count;
%000000     m_total_count  = _rhs.m_total_count;
%000000     m_drain_time   = _rhs.m_drain_time;
%000000     m_prop_mode    = _rhs.m_prop_mode;
          endfunction
        
          //@uvm-compat for compatibility with 1.1d
%000000   function void m_set_hier_mode (uvm_object obj);
             // this method was available to trade off between performance and
             // functionality, but we have since fixed performance so this
             // method can be a no-op
          endfunction
        
        
        endclass
        
        // TODO: change to plusarg
        //`define UVM_DEFAULT_TIMEOUT 9200s
        
        typedef class uvm_cmdline_processor;
        
        
        // Have a pool of context objects to use
%000006 class uvm_objection_context_object;
            uvm_object obj;
            uvm_object source_obj;
            string description;
            int    count;
            uvm_objection objection;
        
            // Clears the values stored within the object,
            // preventing memory leaks from reused objects
 000090     function void clear();
 000090         obj = null;
 000090         source_obj = null;
 000090         description = "";
 000090         count = 0;
 000090         objection = null;
            endfunction : clear
        endclass
        
        // Typedef - Exists for backwards compat
        typedef uvm_objection uvm_callbacks_objection;
           
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_objection_callback
        //
        //------------------------------------------------------------------------------
        // The uvm_objection is the callback type that defines the callback 
        // implementations for an objection callback. A user uses the callback
        // type uvm_objection_cbs_t to add callbacks to specific objections.
        //
        // For example:
        //
        //| class my_objection_cb extends uvm_objection_callback;
        //|   function new(string name);
        //|     super.new(name);
        //|   endfunction
        //|
        //|   virtual function void raised (uvm_objection objection, uvm_object obj, 
        //|       uvm_object source_obj, string description, int count);
        //|       `uvm_info("RAISED","%0t: Objection %s: Raised for %s", $time, objection.get_name(),
        //|       obj.get_full_name());
        //|   endfunction
        //| endclass
        //| ...
        //| initial begin
        //|   my_objection_cb cb = new("cb");
        //|   uvm_objection_cbs_t::add(null, cb); //typewide callback
        //| end
        
        
        // @uvm-ieee 1800.2-2020 auto 10.5.2.1
        class uvm_objection_callback extends uvm_callback;
%000000   function new(string name);
%000000     super.new(name);
          endfunction
        
          // Function -- NODOCS -- raised
          //
          // Objection raised callback function. Called by <uvm_objection::raised>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.2.2.1
%000000   virtual function void raised (uvm_objection objection, uvm_object obj, 
              uvm_object source_obj, string description, int count);
          endfunction
        
          // Function -- NODOCS -- dropped
          //
          // Objection dropped callback function. Called by <uvm_objection::dropped>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.2.2.2
%000000   virtual function void dropped (uvm_objection objection, uvm_object obj, 
              uvm_object source_obj, string description, int count);
          endfunction
        
          // Function -- NODOCS -- all_dropped
          //
          // Objection all_dropped callback function. Called by <uvm_objection::all_dropped>.
        
          // @uvm-ieee 1800.2-2020 auto 10.5.2.2.3
%000000   virtual task all_dropped (uvm_objection objection, uvm_object obj, 
              uvm_object source_obj, string description, int count);
          endtask
        
        endclass
        
        
        //@uvm-compat for compatibility with 1.2
        class uvm_test_done_objection extends uvm_objection;
        
           protected static uvm_test_done_objection m_inst;
          protected bit m_forced;
        
          // For communicating all objections dropped and end of phasing
          local  bit m_executing_stop_processes;
          local  int m_n_stop_threads;
        
        
          // Function- new DEPRECATED
          //
          // Creates the singleton test_done objection. Users must not call
          // this method directly.
        
          //@uvm-compat for compatibility with 1.2
%000000   function new(string name="uvm_test_done");
%000000     super.new(name);
          endfunction
        
        
          // Function- qualify DEPRECATED
          //
          // Checks that the given ~object~ is derived from either <uvm_component> or
          // <uvm_sequence_base>.
        
          //@uvm-compat for compatibility with 1.2
%000000   virtual function void qualify(uvm_object obj=null,
                                        bit is_raise,
                                        string description);
%000000     uvm_component c;
%000000     uvm_sequence_base s;
%000000     string nm = is_raise ? "raise_objection" : "drop_objection";
%000000     string desc = description == "" ? "" : {" (\"", description, "\")"};
%000000     if(! ($cast(c,obj) || $cast(s,obj))) 
%000000       begin
%000000         uvm_report_error("TEST_DONE_NOHIER", {"A non-hierarchical object, '",
%000000         obj.get_full_name(), "' (", obj.get_type_name(),") was used in a call ",
%000000         "to uvm_test_done.", nm,"(). For this objection, a sequence ",
%000000         "or component is required.", desc });
              end
          endfunction
        
          // Below are basic data operations needed for all uvm_objects
          // for factory registration, printing, comparing, etc.
        
          typedef uvm_object_registry#(uvm_test_done_objection,"uvm_test_done") type_id;
          //@uvm-compat for compatibility with 1.2
%000000   static function type_id get_type();
%000000     return type_id::get();
          endfunction
        
          //@uvm-compat for compatibility with 1.2
%000000   function uvm_object create (string name="");
%000000     uvm_test_done_objection tmp = new(name);
%000000     return tmp;
          endfunction
        
          //@uvm-compat for compatibility with 1.2
%000000   virtual function string get_type_name ();
%000000     return "uvm_test_done";
          endfunction
        
          //@uvm-compat for compatibility with 1.2
%000000   static function uvm_test_done_objection get();
%000000     if(m_inst == null)
%000000       begin
%000000         m_inst = uvm_test_done_objection::type_id::create("run");
              end
        
%000000     return m_inst;
          endfunction
        
        endclass
        
        
        
        `endif
        
