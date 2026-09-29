//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2011 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2013 Cisco Systems, Inc.
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_runtime_phases.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        // Title -- NODOCS -- UVM Run-Time Phases
        // 
        // The run-time schedule is the pre-defined phase schedule
        // which runs concurrently to the <uvm_run_phase> global run phase.
        // By default, all <uvm_component>s using the run-time schedule
        // are synchronized with respect to the pre-defined phases in the schedule.
        // It is possible for components to belong to different domains
        // in which case their schedules can be unsynchronized.
        //
        // The names of the UVM phases (which will be returned by get_name() for a
        // phase instance) match the class names specified below with the "uvm_"
        // and "_phase" removed.  For example, the main phase corresponds to the 
        // uvm_main_phase class below and has the name "main", which means that 
        // the following can be used to call foo() at the start of main phase:
        //
        // | function void phase_started(uvm_phase phase) ;
        // |    if (phase.get_name()=="main") foo() ;
        // | endfunction
        // 
        // The run-time phases are executed in the sequence they are specified below.
        // 
        // 
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.1
        class uvm_pre_reset_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.pre_reset_phase(phase); 
           endtask
           local static uvm_pre_reset_phase m_inst;
%000000    `uvm_type_name_decl("uvm_pre_reset_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_pre_reset_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="pre_reset"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.2
        class uvm_reset_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.reset_phase(phase); 
           endtask
           local static uvm_reset_phase m_inst;
%000000    `uvm_type_name_decl("uvm_reset_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_reset_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="reset"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.3
        class uvm_post_reset_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.post_reset_phase(phase); 
           endtask
           local static uvm_post_reset_phase m_inst;
%000000    `uvm_type_name_decl("uvm_post_reset_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_post_reset_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="post_reset"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.4
        class uvm_pre_configure_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.pre_configure_phase(phase); 
           endtask
           local static uvm_pre_configure_phase m_inst;
%000000    `uvm_type_name_decl("uvm_pre_configure_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_pre_configure_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="pre_configure"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.5
        class uvm_configure_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.configure_phase(phase); 
           endtask
           local static uvm_configure_phase m_inst;
%000000    `uvm_type_name_decl("uvm_configure_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_configure_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="configure"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.6
        class uvm_post_configure_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.post_configure_phase(phase); 
           endtask
           local static uvm_post_configure_phase m_inst;
%000000    `uvm_type_name_decl("uvm_post_configure_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_post_configure_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="post_configure"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.7
        class uvm_pre_main_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.pre_main_phase(phase); 
           endtask
           local static uvm_pre_main_phase m_inst;
%000000    `uvm_type_name_decl("uvm_pre_main_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_pre_main_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="pre_main"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.8
        class uvm_main_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.main_phase(phase); 
           endtask
           local static uvm_main_phase m_inst;
%000000    `uvm_type_name_decl("uvm_main_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_main_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="main"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.9
        class uvm_post_main_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.post_main_phase(phase); 
           endtask
           local static uvm_post_main_phase m_inst;
%000000    `uvm_type_name_decl("uvm_post_main_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_post_main_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="post_main"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.10
        class uvm_pre_shutdown_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.pre_shutdown_phase(phase); 
           endtask
           local static uvm_pre_shutdown_phase m_inst;
%000000    `uvm_type_name_decl("uvm_pre_shutdown_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_pre_shutdown_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="pre_shutdown"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.11
        class uvm_shutdown_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.shutdown_phase(phase); 
           endtask
           local static uvm_shutdown_phase m_inst;
%000000    `uvm_type_name_decl("uvm_shutdown_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_shutdown_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="shutdown"); 
%000003       super.new(name); 
           endfunction
        endclass
        
        
        
        // @uvm-ieee 1800.2-2020 auto 9.8.2.12
        class uvm_post_shutdown_phase extends uvm_task_phase; 
 000123    virtual task exec_task(uvm_component comp, uvm_phase phase); 
 000123       comp.post_shutdown_phase(phase); 
           endtask
           local static uvm_post_shutdown_phase m_inst;
%000000    `uvm_type_name_decl("uvm_post_shutdown_phase")
        
           // Function -- NODOCS -- get
           // Returns the singleton phase handle 
%000003    static function uvm_post_shutdown_phase get(); 
%000003       if(m_inst == null)
%000003         begin
%000003           m_inst = new;
                end
         
%000003       return m_inst; 
           endfunction
%000003    protected function new(string name="post_shutdown"); 
%000003       super.new(name); 
           endfunction
        endclass
        
