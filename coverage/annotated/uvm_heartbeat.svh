//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2007-2018 Cadence Design Systems, Inc.
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
        // $File:     src/base/uvm_heartbeat.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        `ifndef UVM_HEARTBEAT_SVH
        `define UVM_HEARTBEAT_SVH
        
        typedef enum {
          UVM_ALL_ACTIVE,
          UVM_ONE_ACTIVE,
          UVM_ANY_ACTIVE,
          UVM_NO_HB_MODE
        } uvm_heartbeat_modes;
        
        typedef class uvm_heartbeat_callback;
        typedef uvm_callbacks #(uvm_objection,uvm_heartbeat_callback) uvm_heartbeat_cbs_t;
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_heartbeat
        //
        //------------------------------------------------------------------------------
        // Heartbeats provide a way for environments to easily ensure that their
        // descendants are alive. A uvm_heartbeat is associated with a specific
        // objection object. A component that is being tracked by the heartbeat
        // object must raise (or drop) the synchronizing objection during
        // the heartbeat window. 
        //
        // The uvm_heartbeat object has a list of participating objects. The heartbeat
        // can be configured so that all components (UVM_ALL_ACTIVE), exactly one
        // (UVM_ONE_ACTIVE), or any component (UVM_ANY_ACTIVE) must trigger the
        // objection in order to satisfy the heartbeat condition.
        //------------------------------------------------------------------------------
        
        typedef class uvm_objection_callback;
        // @uvm-ieee 1800.2-2020 auto 10.6.1
        class uvm_heartbeat extends uvm_object;
        
          protected uvm_objection m_objection;
          protected uvm_heartbeat_callback m_cb;
          protected uvm_component   m_cntxt;
          protected uvm_heartbeat_modes   m_mode;
          protected uvm_component   m_hblist[$];
          protected uvm_event#(uvm_object)       m_event;
          protected bit             m_started;
          protected event           m_stop_event;
        
          // Function -- NODOCS -- new
          //
          // Creates a new heartbeat instance associated with ~cntxt~. The context
          // is the hierarchical location that the heartbeat objections will flow
          // through and be monitored at. The ~objection~ associated with the heartbeat 
          // is optional, if it is left ~null~ but it must be set before the heartbeat
          // monitor will activate.
          //
          //| uvm_objection myobjection = new("myobjection"); //some shared objection
          //| class myenv extends uvm_env;
          //|    uvm_heartbeat hb = new("hb", this, myobjection);
          //|    ...
          //| endclass
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.1
%000000   function new(string name, uvm_component cntxt, uvm_objection objection=null);
%000000      uvm_coreservice_t cs;
%000000     super.new(name);
%000000     m_objection = objection;
%000000     cs  = uvm_coreservice_t::get();
             
            //if a cntxt is given it will be used for reporting.
%000000     if(cntxt != null) begin
%000000       m_cntxt = cntxt;
            end
        
%000000     else begin
%000000       m_cntxt = cs.get_root();
            end
        
        
%000000     m_cb = new({name,"_cb"},m_cntxt);
        
          endfunction
        
        
          // Function -- NODOCS -- set_mode
          //
          // Sets or retrieves the heartbeat mode. The current value for the heartbeat
          // mode is returned. If an argument is specified to change the mode then the
          // mode is changed to the new value.
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.2
%000000   function uvm_heartbeat_modes set_mode (uvm_heartbeat_modes mode = UVM_NO_HB_MODE);
%000000     set_mode = m_mode;
%000000     if(mode == UVM_ANY_ACTIVE || mode == UVM_ONE_ACTIVE || mode == UVM_ALL_ACTIVE) begin
              
%000000       m_mode = mode;
            end
        
          endfunction
        
        
          // Function -- NODOCS -- set_heartbeat 
          //
          // Sets up the heartbeat event and assigns a list of objects to watch. The
          // monitoring is started as soon as this method is called. Once the
          // monitoring has been started with a specific event, providing a new
          // monitor event results in an error. To change trigger events, you
          // must first <stop> the monitor and then <start> with a new event trigger.
          //
          // If the trigger event ~e~ is ~null~ and there was no previously set
          // trigger event, then the monitoring is not started. Monitoring can be 
          // started by explicitly calling <start>.
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.3
%000000   function void set_heartbeat (uvm_event#(uvm_object) e, ref uvm_component comps[$]);
%000000     uvm_object c;
%000000     foreach(comps[i]) begin
%000000       c = comps[i];
%000000       if(!m_cb.cnt.exists(c)) begin 
                
%000000         m_cb.cnt[c]=0;
              end
        
%000000       if(!m_cb.last_trigger.exists(c)) begin 
                
%000000         m_cb.last_trigger[c]=0;
              end
        
            end
%000000     if(e==null && m_event==null) begin
%000000       return;
            end
        
%000000     start(e);
          endfunction
        
          // Function -- NODOCS -- add
          //
          // Add a single component to the set of components to be monitored.
          // This does not cause monitoring to be started. If monitoring is
          // currently active then this component will be immediately added
          // to the list of components and will be expected to participate
          // in the currently active event window.
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.4
%000000   function void add (uvm_component comp);
%000000     uvm_object c = comp;
%000000     if(m_cb.cnt.exists(c)) begin
%000000       return;
            end
        
%000000     m_cb.cnt[c]=0;
%000000     m_cb.last_trigger[c]=0;
          endfunction
        
          // Function -- NODOCS -- remove
          //
          // Remove a single component to the set of components being monitored.
          // Monitoring is not stopped, even if the last component has been
          // removed (an explicit stop is required).
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.5
%000000   function void remove (uvm_component comp);
%000000     uvm_object c = comp;
%000000     if(m_cb.cnt.exists(c)) begin
%000000       m_cb.cnt.delete(c);
            end
        
%000000     if(m_cb.last_trigger.exists(c)) begin
%000000       m_cb.last_trigger.delete(c);
            end
        
          endfunction
        
        
          // Function -- NODOCS -- start
          //
          // Starts the heartbeat monitor. If ~e~ is ~null~ then whatever event
          // was previously set is used. If no event was previously set then
          // a warning is issued. It is an error if the monitor is currently
          // running and ~e~ is specifying a different trigger event from the
          // current event.
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.6
%000000   function void start (uvm_event#(uvm_object) e=null);
%000000     if(m_event == null && e == null) begin
%000000       m_cntxt.uvm_report_warning("NOEVNT", { "start() was called for: ",
%000000         get_name(), " with a null trigger and no currently set trigger" },
%000000         UVM_NONE);
%000000       return;
            end
%000000     if((m_event != null) && (e != m_event) && m_started) begin
%000000       m_cntxt.uvm_report_error("ILHBVNT", { "start() was called for: ",
%000000         get_name(), " with trigger ", e.get_name(), " which is different ",
%000000         "from the original trigger ", m_event.get_name() }, UVM_NONE);
%000000       return;
            end  
%000000     if(e != null) begin
%000000       m_event = e;
            end
        
%000000     m_enable_cb();
%000000     m_start_hb_process();
          endfunction
        
          // Function -- NODOCS -- stop
          //
          // Stops the heartbeat monitor. Current state information is reset so
          // that if <start> is called again the process will wait for the first
          // event trigger to start the monitoring.
        
          // @uvm-ieee 1800.2-2020 auto 10.6.2.7
%000000   function void stop ();
%000000     m_started = 0;
%000000     ->m_stop_event;
%000000     m_disable_cb();
          endfunction
        
%000000   function void m_start_hb_process();
%000000     if(m_started) begin
%000000       return;
            end
        
%000000     m_started = 1;
%000000     fork
%000000       begin
%000000         m_hb_process;
              end
        
            join_none
          endfunction
        
          protected bit m_added;
%000000   function void m_enable_cb;
%000000     void'(m_cb.callback_mode(1));
%000000     if(m_objection == null) begin
%000000       return;
            end
        
%000000     if(!m_added) begin 
              
%000000       uvm_heartbeat_cbs_t::add(m_objection, m_cb);
            end
        
%000000     m_added = 1;
          endfunction
        
%000000   function void m_disable_cb;
%000000     void'(m_cb.callback_mode(0));
          endfunction
        
%000000   task m_hb_process;
%000000     uvm_object obj;
%000000     bit  triggered;
%000000     time last_trigger=0;
%000000     fork
%000000       begin
                // The process waits for the event trigger. The first trigger is
                // ignored, but sets the first start window. On susequent triggers
                // the monitor tests that the mode criteria was full-filled.
%000000         while(1) begin
%000000           m_event.wait_trigger();
%000000           if(triggered) begin
%000000             case (m_mode)
%000000               UVM_ALL_ACTIVE: begin              
                        
%000000                 foreach(m_cb.cnt[idx]) begin
%000000                   obj = idx;
%000000                   if(!m_cb.cnt[obj]) begin
%000000                     m_cntxt.uvm_report_fatal("HBFAIL", $sformatf("Did not recieve an update of %s for component %s since last event trigger at time %0t : last update time was %0t",
%000000                         m_objection.get_name(), obj.get_full_name(), 
%000000                         last_trigger, m_cb.last_trigger[obj]), UVM_NONE);
                          end
                        end
                      end 
%000000               UVM_ANY_ACTIVE: begin              
                        
%000000                 if(m_cb.cnt.num() && !m_cb.objects_triggered()) begin
%000000                   string s;
%000000                   foreach(m_cb.cnt[idx]) begin
%000000                     obj = idx;
%000000                     s={s,"\n  ",obj.get_full_name()};
                          end
%000000                   m_cntxt.uvm_report_fatal("HBFAIL", $sformatf("Did not recieve an update of %s on any component since last event trigger at time %0t. The list of registered components is:%s",
%000000                       m_objection.get_name(), last_trigger, s), UVM_NONE); 
                        end
                      end 
%000000               UVM_ONE_ACTIVE: begin              
                        
%000000                 if(m_cb.objects_triggered() > 1) begin
%000000                   string s;
%000000                   foreach(m_cb.cnt[idx])  begin
%000000                     obj = idx;
%000000                     if(m_cb.cnt[obj]) begin
%000000                       $swrite(s,"%s\n  %s (updated: %0t)",
%000000                          s, obj.get_full_name(), m_cb.last_trigger[obj]);
                            end
        
                          end
%000000                   m_cntxt.uvm_report_fatal("HBFAIL", $sformatf("Recieved update of %s from more than one component since last event trigger at time %0t. The list of triggered components is:%s",
%000000                       m_objection.get_name(), last_trigger, s), UVM_NONE); 
                        end
%000000                 if(m_cb.cnt.num() && !m_cb.objects_triggered()) begin
%000000                   string s;
%000000                   foreach(m_cb.cnt[idx]) begin
%000000                     obj = idx;
%000000                     s={s,"\n  ",obj.get_full_name()};
                          end
%000000                   m_cntxt.uvm_report_fatal("HBFAIL", $sformatf("Did not recieve an update of %s on any component since last event trigger at time %0t. The list of registered components is:%s",
%000000                       m_objection.get_name(), last_trigger, s), UVM_NONE); 
                        end
                      end 
                    endcase
                  end 
%000000           m_cb.reset_counts();
%000000           last_trigger = $realtime;
%000000           triggered = 1;
                end
              end
%000000       begin
%000000         @(m_stop_event);
              end
        
            join_any
%000000     disable fork;
          endtask
        endclass
        
        
        class uvm_heartbeat_callback extends uvm_objection_callback;
          int  cnt [uvm_object];
          time last_trigger [uvm_object];
          uvm_object target;
%000000   uvm_coreservice_t cs = uvm_coreservice_t::get();
        
%000000   function new(string name, uvm_object target);
%000000     super.new(name);
%000000     if (target != null) begin
               
%000000       this.target = target;
            end
        
%000000     else begin
               
%000000       this.target = cs.get_root();
            end
        
          endfunction
        
%000000   virtual function void raised (uvm_objection objection,
                                        uvm_object obj,
                                        uvm_object source_obj,
                                        string description,
                                        int count);
%000000     if(obj == target) begin
%000000       if(!cnt.exists(source_obj)) begin
                
%000000         cnt[source_obj] = 0;
              end
        
%000000       cnt[source_obj] = cnt[source_obj]+1;
%000000       last_trigger[source_obj] = $realtime;
            end
          endfunction
        
%000000   virtual function void dropped (uvm_objection objection,
                                         uvm_object obj,
                                         uvm_object source_obj,
                                         string description,
                                         int count);
%000000     raised(objection,obj,source_obj,description,count);
          endfunction
        
%000000   function void reset_counts;
%000000     foreach(cnt[i]) begin
%000000       cnt[i] = 0;
            end
        
          endfunction
        
%000000   function int objects_triggered;
%000000     objects_triggered = 0; 
%000000     foreach(cnt[i]) begin
              
%000000       if (cnt[i] != 0) begin
                
%000000         objects_triggered++;
              end
        
            end
        
          endfunction
        
        endclass
        
        `endif
        
