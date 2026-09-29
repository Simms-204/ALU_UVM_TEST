//      // verilator_coverage annotation
        //
        //----------------------------------------------------------------------
        // Copyright 2025-2026 NVIDIA Corporation
        // Copyright 2025 Siemens
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
        // $File:     src/base/uvm_core_state_callback.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        // Class: uvm_core_state_callback
        //
        // This class is used to notify the user when the core state changes.
        //
        // This is a virtual class and must be derived from.
        //
        // @uvm-contrib - For potential contributions to the 1800.2 standard.
        virtual class uvm_core_state_callback extends uvm_callback;
        
          // Function: new
          // Initializes a new instance with ~name~.
          //
          // @uvm-contrib - For potential contributions to the 1800.2 standard.
          extern function new( string name="uvm_core_state_callback");
        
          // Function: core_state_change
          // This function is called when the core state changes.
          //
          // @uvm-contrib - For potential contributions to the 1800.2 standard.
%000000   pure virtual function void core_state_change(uvm_core_state state, uvm_core_state prev_state);
        
          // Function: add
          // Adds a new core state callback to the list of callbacks.
          //
          // @uvm-contrib - For potential contributions to the 1800.2 standard.
          extern static function bit add( uvm_core_state_callback cb );
        
          // Function: delete
          // Deletes a core state callback from the list of callbacks.
          //
          // @uvm-contrib - For potential contributions to the 1800.2 standard.
          extern static function bit delete( uvm_core_state_callback cb );
        
          // Implementation details
        
          extern static function void m_do_core_state_change(uvm_core_state state, uvm_core_state prev_state);
        
          local static uvm_core_state_callback   m_registered_cbs[$];
        
        endclass : uvm_core_state_callback
        
        // Implementation details
        
%000006 function uvm_core_state_callback::new( string name="uvm_core_state_callback");
%000006   super.new( name );
        endfunction
        
        
        // Adds cb to the list of callbacks to be processed. The method returns 1 if cb is not already in the list of
        // callbacks; otherwise, a 0 is returned. If cb is null, 0 is returned.
%000006 function bit uvm_core_state_callback::add( uvm_core_state_callback cb );
%000006   bit found;
%000006   int unsigned i;
        
%000006   if ( cb == null ) begin
%000000     return 0;
          end
        
%000003   while ( !found && ( i < m_registered_cbs.size() ) ) begin
%000003     if ( m_registered_cbs[ i ] == cb ) begin
%000000       found = 1;
            end
%000003     ++i;
          end
%000006   if ( !found ) begin
%000006     m_registered_cbs.push_back( cb );
          end
        
%000006   return !found;
        endfunction
        
        // Deletes cb from the list of callbacks to be processed. The method returns 1 if cb is in the list of callbacks;
        // otherwise, a 0 is returned. If cb is null, 0 is returned.
%000000 function bit uvm_core_state_callback::delete( uvm_core_state_callback cb );
%000000   int cb_idxs[$];
        
%000000   if ( cb == null ) begin
%000000     return 0;
          end
        
%000000   cb_idxs = m_registered_cbs.find_index( item ) with ( item == cb );
%000000   foreach ( cb_idxs[ i ] ) begin
%000000     m_registered_cbs.delete( cb_idxs[i] );
          end
%000000   return ( cb_idxs.size() > 0 );
        endfunction
        
 000018 function void uvm_core_state_callback::m_do_core_state_change(uvm_core_state state, uvm_core_state prev_state);
 000018   uvm_core_state_callback registered_cbs[$];
 000018   int cb_idxs[$];
        
          // Callbacks may delete themselves while handling a state change.
 000018   registered_cbs = m_registered_cbs;
~000036   foreach ( registered_cbs[ i ] ) begin
~000036     if ( registered_cbs[ i ] != null ) begin
 000036       cb_idxs = m_registered_cbs.find_index( item ) with ( item == registered_cbs[ i ] );
~000036       if ( cb_idxs.size() > 0 ) begin
 000036         registered_cbs[ i ].core_state_change( state, prev_state );
              end
            end
          end
        endfunction
          
          
        
