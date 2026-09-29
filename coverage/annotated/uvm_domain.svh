//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2011 AMD
        // Copyright 2012 Accellera Systems Initiative
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2007-2018 Mentor Graphics Corporation
        // Copyright 2015-2026 NVIDIA Corporation
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
        // $File:     src/base/uvm_domain.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_build_phase;
        typedef class uvm_connect_phase;
        typedef class uvm_end_of_elaboration_phase;
        typedef class uvm_start_of_simulation_phase;
        typedef class uvm_run_phase;
        typedef class uvm_extract_phase;
        typedef class uvm_check_phase;
        typedef class uvm_report_phase;
        typedef class uvm_final_phase;
        
        typedef class uvm_pre_reset_phase;
        typedef class uvm_reset_phase;
        typedef class uvm_post_reset_phase;
        typedef class uvm_pre_configure_phase;
        typedef class uvm_configure_phase;
        typedef class uvm_post_configure_phase;
        typedef class uvm_pre_main_phase;
        typedef class uvm_main_phase;
        typedef class uvm_post_main_phase;
        typedef class uvm_pre_shutdown_phase;
        typedef class uvm_shutdown_phase;
        typedef class uvm_post_shutdown_phase;
        
        uvm_phase build_ph;
        uvm_phase connect_ph;
        uvm_phase end_of_elaboration_ph;
        uvm_phase start_of_simulation_ph;
        uvm_phase run_ph;
        uvm_phase extract_ph;
        uvm_phase check_ph;
        uvm_phase report_ph;
           
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_domain
        //
        //------------------------------------------------------------------------------
        //
        // Phasing schedule node representing an independent branch of the schedule.
        // Handle used to assign domains to components or hierarchies in the testbench
        //
        
        // @uvm-ieee 1800.2-2020 auto 9.4.1
        class uvm_domain extends uvm_phase;
        
          static local uvm_domain m_uvm_domain; // run-time phases
          static local uvm_domain m_domains[string];
          static local uvm_phase m_uvm_schedule;
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.4.2.2
%000000   static function void get_domains(output uvm_domain domains[string]);
%000000     domains = m_domains;
          endfunction 
        
        
          // Function -- NODOCS -- get_uvm_schedule
          //
          // Get the "UVM" schedule, which consists of the run-time phases that
          // all components execute when participating in the "UVM" domain.
          //
%000000   static function uvm_phase get_uvm_schedule();
%000000     void'(get_uvm_domain());
%000000     return m_uvm_schedule;
          endfunction 
        
        
          // Function -- NODOCS -- get_common_domain
          //
          // Get the "common" domain, which consists of the common phases that
          // all components execute in sync with each other. Phases in the "common"
          // domain are build, connect, end_of_elaboration, start_of_simulation, run,
          // extract, check, report, and final.
          //
 009354   static function uvm_domain get_common_domain();
        
 009354     uvm_domain domain;
        
~009351     if(m_domains.exists("common"))
 009351       begin
 009351         domain = m_domains["common"];
              end
        
            
%000003     if (domain != null)
%000000       begin
%000000         return domain;
              end
        
        
 009354     domain = new("common");
 009354     domain.add(uvm_build_phase::get());
 009354     domain.add(uvm_connect_phase::get());
 009354     domain.add(uvm_end_of_elaboration_phase::get());
 009354     domain.add(uvm_start_of_simulation_phase::get());
 009354     domain.add(uvm_run_phase::get());
 009354     domain.add(uvm_extract_phase::get());
 009354     domain.add(uvm_check_phase::get());
 009354     domain.add(uvm_report_phase::get());
 009354     domain.add(uvm_final_phase::get());
        
            // for backward compatibility, make common phases visible;
            // same as uvm_<name>_phase::get().
 009354     build_ph               = domain.find(uvm_build_phase::get());
 009354     connect_ph             = domain.find(uvm_connect_phase::get());
 009354     end_of_elaboration_ph  = domain.find(uvm_end_of_elaboration_phase::get());
 009354     start_of_simulation_ph = domain.find(uvm_start_of_simulation_phase::get());
 009354     run_ph                 = domain.find(uvm_run_phase::get());   
 009354     extract_ph             = domain.find(uvm_extract_phase::get());
 009354     check_ph               = domain.find(uvm_check_phase::get());
 009354     report_ph              = domain.find(uvm_report_phase::get());
        
 009354     domain = get_uvm_domain();
 009354     m_domains["common"].add(domain,
 009354                      .with_phase(m_domains["common"].find(uvm_run_phase::get())));
        
        
 009354     return m_domains["common"];
        
          endfunction
        
        
          // Function: find_common_phase
          //
          // Returns the phase node in the "common" domain which corresponds to
          // ~phase~, or ~null~ if no such node exists.
          //
          // @uvm-contrib For potential contribution to 1800.2
%000000   static function uvm_phase find_common_phase(uvm_phase phase);
%000000     uvm_domain domain;
%000000     domain = get_common_domain();
%000000     return domain.find(phase);
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.4.2.3
%000003   static function void add_uvm_phases(uvm_phase schedule);
        
%000003     schedule.add(uvm_pre_reset_phase::get());
%000003     schedule.add(uvm_reset_phase::get());
%000003     schedule.add(uvm_post_reset_phase::get());
%000003     schedule.add(uvm_pre_configure_phase::get());
%000003     schedule.add(uvm_configure_phase::get());
%000003     schedule.add(uvm_post_configure_phase::get());
%000003     schedule.add(uvm_pre_main_phase::get());
%000003     schedule.add(uvm_main_phase::get());
%000003     schedule.add(uvm_post_main_phase::get());
%000003     schedule.add(uvm_pre_shutdown_phase::get());
%000003     schedule.add(uvm_shutdown_phase::get());
%000003     schedule.add(uvm_post_shutdown_phase::get());
        
          endfunction
        
        
          // Function -- NODOCS -- get_uvm_domain
          //
          // Get a handle to the singleton ~uvm~ domain
          //
%000006   static function uvm_domain get_uvm_domain();
          
%000003     if (m_uvm_domain == null) 
%000003       begin
%000003         m_uvm_domain = new("uvm");
%000003         m_uvm_schedule = new("uvm_sched", UVM_PHASE_SCHEDULE);
%000003         add_uvm_phases(m_uvm_schedule);
%000003         m_uvm_domain.add(m_uvm_schedule);
              end
%000006     return m_uvm_domain;
          endfunction
        
        
          // Function: find_run_time_phase
          //
          // Returns the phase node in the "UVM" run-time domain which corresponds
          // to ~phase~, or ~null~ if no such node exists.
          //
          // @uvm-contrib For potential contribution to 1800.2
%000000   static function uvm_phase find_run_time_phase(uvm_phase phase);
%000000     uvm_domain domain;
%000000     domain = get_uvm_domain();
%000000     return domain.find(phase);
          endfunction
        
        
        
          // @uvm-ieee 1800.2-2020 auto 9.4.2.1
%000006   function new(string name);
%000006     super.new(name,UVM_PHASE_DOMAIN);
%000006     if (m_domains.exists(name)) 
%000000       begin
%000000         `uvm_error("UNIQDOMNAM", $sformatf("Domain created with non-unique name '%s'", name))
              end
%000006     m_domains[name] = this;
          endfunction
        
        
          // @uvm-ieee 1800.2-2020 auto 9.4.2.4
%000000   function void jump(uvm_phase phase);
%000000     uvm_phase phases[$];
        
%000000     m_get_transitive_children(phases);
            
%000000     phases = phases.find(item) with (item.get_state() inside {[UVM_PHASE_STARTED:UVM_PHASE_CLEANUP]}); 
            
%000000     foreach(phases[idx]) 
%000000       begin
%000000         if(phases[idx].is_before(phase) || phases[idx].is_after(phase))
%000000         begin
%000000           phases[idx].jump(phase);
                end
        
              end
                
            
          endfunction
        
        // jump_all
        // --------
%000000   static function void jump_all(uvm_phase phase);
%000000     uvm_domain domains[string];
            
%000000     uvm_domain::get_domains(domains);
                   
%000000     foreach(domains[idx])      
%000000       begin
%000000         domains[idx].jump(phase);
              end
                
            
           endfunction
        endclass
        
