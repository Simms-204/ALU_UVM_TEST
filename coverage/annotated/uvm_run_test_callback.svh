//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2018 Cadence Design Systems, Inc.
        // Copyright 2018-2026 NVIDIA Corporation
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
        // $File:     src/base/uvm_run_test_callback.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        // @uvm-ieee 1800.2-2020 auto F.6.1
        virtual class uvm_run_test_callback extends uvm_core_state_callback;
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.1
          extern function new( string name="uvm_run_test_callback");
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.2
%000000   virtual function void pre_run_test();
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.3
%000000   virtual function void post_run_test();
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.4
%000000   virtual function void pre_abort();
          endfunction
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.5
          extern static function bit add( uvm_run_test_callback cb );
        
          // @uvm-ieee 1800.2-2020 auto F.6.2.6
          extern static function bit delete( uvm_run_test_callback cb );
        
          // @uvm-contrib - For potential contributions to the 1800.2 standard.
          extern virtual function void core_state_change(uvm_core_state state, uvm_core_state prev_state);
        
        endclass : uvm_run_test_callback
        
%000000 function uvm_run_test_callback::new( string name="uvm_run_test_callback");
%000000   super.new( name );
        endfunction
        
%000000 function void uvm_run_test_callback::core_state_change(uvm_core_state state, uvm_core_state prev_state);
%000000   case ( state )
%000000     UVM_CORE_PRE_RUN: pre_run_test();
%000000     UVM_CORE_POST_RUN: post_run_test();
%000000     UVM_CORE_PRE_ABORT: pre_abort();
          endcase
        endfunction
        
%000000 function bit uvm_run_test_callback::add( uvm_run_test_callback cb );
%000000   return uvm_core_state_callback::add( cb ) ;
        endfunction
        
%000000 function bit uvm_run_test_callback::delete( uvm_run_test_callback cb );
%000000   return uvm_core_state_callback::delete( cb );
        endfunction
        
        
        
