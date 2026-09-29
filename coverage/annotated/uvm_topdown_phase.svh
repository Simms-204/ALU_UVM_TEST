//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2011 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2015-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_topdown_phase.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_topdown_phase
        //
        //------------------------------------------------------------------------------
        // Virtual base class for function phases that operate top-down.
        // The pure virtual function execute() is called for each component.
        //
        // A top-down function phase completes when the <execute()> method
        // has been called and returned on all applicable components
        // in the hierarchy.
        
        // @uvm-ieee 1800.2-2020 auto 9.7.1
        virtual class uvm_topdown_phase extends uvm_phase;
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.7.2.1
%000006   function new(string name);
%000006     super.new(name,UVM_PHASE_IMP);
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.7.2.2
 000621   virtual function void traverse(uvm_component comp,
                                         uvm_phase phase,
                                         uvm_phase_state state);
 000621     string name;
 000621     uvm_domain phase_domain = phase.get_domain();
 000621     uvm_domain comp_domain = comp.get_domain();
 000621     uvm_phase_hopper hopper;
 000621     hopper = uvm_phase_hopper::get_global_hopper();
        
~000621     if (m_phase_trace) begin
              `uvm_info("PH_TRACE",$sformatf("topdown-phase phase=%s state=%s comp=%s comp.domain=%s phase.domain=%s",
              phase.get_name(), state.name(), comp.get_full_name(),comp_domain.get_name(),phase_domain.get_name()),
%000000       UVM_DEBUG)
            end
        
~000621     if (phase_domain == uvm_domain::get_common_domain() ||
 000621         phase_domain == comp_domain) begin
 000621       case (state)
 000129         UVM_PHASE_STARTED: begin
 000129           comp.m_current_phase = phase;
 000129           comp.m_apply_verbosity_settings(phase);
 000129           comp.phase_started(phase);
                end
 000246         UVM_PHASE_EXECUTING: begin
~000246           if (!(phase.get_name() == "build" && comp.m_build_done)) begin
 000246             uvm_phase ph = this; 
 000246             comp.m_phasing_active++;
~000246             if (comp.m_phase_imps.exists(this)) begin
                        
%000000               ph = comp.m_phase_imps[this];
                    end
        
 000246             hopper.execute_on(ph, comp, phase);
 000246             comp.m_phasing_active--;
                  end
                end
%000000         UVM_PHASE_READY_TO_END: begin
%000000           comp.phase_ready_to_end(phase);
                end
 000246         UVM_PHASE_ENDED: begin
 000246           comp.phase_ended(phase);
 000246           comp.m_current_phase = null;
                end
%000000         default: begin
%000000           `uvm_fatal("PH_BADEXEC","topdown phase traverse internal error")
                end
                endcase
            end
 000408     if(comp.get_first_child(name)) begin
              
 000603       do begin
                
 000603         hopper.traverse_on(this, comp.get_child(name), phase, state);
              end
 000603       while(comp.get_next_child(name));
            end
        
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.7.2.3
 000246   virtual function void execute(uvm_component comp,
                                                  uvm_phase phase);
            // reseed this process for random stability
 000246     process proc = process::self();
 000246     proc.srandom(uvm_create_random_seed(phase.get_type_name(), comp.get_full_name()));
        
 000246     comp.m_current_phase = phase;
 000246     exec_func(comp,phase);
          endfunction
        
        endclass
        
