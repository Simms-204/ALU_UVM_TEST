//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2007-2020 Cadence Design Systems, Inc.
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2024 Microsoft
        // Copyright 2014-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2018 Synopsys, Inc.
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
        //------------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/tlm1/uvm_tlm_fifos.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        typedef class uvm_tlm_event;
        
        //------------------------------------------------------------------------------
        //
        // Title -- NODOCS -- UVM TLM FIFO Classes
        //
        // This section defines TLM-based FIFO classes. 
        //
        //------------------------------------------------------------------------------
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_tlm_fifo#(T)
        //
        // This class provides storage of transactions between two independently running
        // processes. Transactions are put into the FIFO via the ~put_export~. 
        // transactions are fetched from the FIFO in the order they arrived via the
        // ~get_peek_export~. The ~put_export~ and ~get_peek_export~ are inherited from
        // the <uvm_tlm_fifo_base #(T)> super class, and the interface methods provided by
        // these exports are defined by the <uvm_tlm_if_base #(T1,T2)> class.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 18.2.8.2
        class uvm_tlm_fifo #(type T=int) extends uvm_tlm_fifo_base #(T);
        
%000000   `uvm_component_param_utils(uvm_tlm_fifo#(T))
%000006   `uvm_type_name_decl("uvm_tlm_fifo #(T)")
        
          local mailbox #( T ) m;
          local int m_size;
         `ifndef UVM_USE_PROCESS_CONTAINER 
          protected bit m_pending_blocked_gets[process];
         `else
          protected bit m_pending_blocked_gets[process_container_c];
         `endif 
        
        
          // Function -- NODOCS -- new
          //
          // The ~name~ and ~parent~ are the normal uvm_component constructor arguments. 
          // The ~parent~ should be ~null~ if the <uvm_tlm_fifo#(T)> is going to be used in a
          // statically elaborated construct (e.g., a module). The ~size~ indicates the
          // maximum size of the FIFO; a value of zero indicates no upper bound.
        
~000012   function new(string name, uvm_component parent = null, int size = 1);
~000012     super.new(name, parent);
~000012     m = new( size );
~000012     m_size = size;
          endfunction
        
          // Function -- NODOCS -- size
          //
          // Returns the capacity of the FIFO-- that is, the number of entries
          // the FIFO is capable of holding. A return value of 0 indicates the
          // FIFO capacity has no limit.
        
%000000   virtual function int size();
%000000     return m_size;
          endfunction
         
        
          // Function -- NODOCS -- used
          //
          // Returns the number of entries put into the FIFO.
        
%000000   virtual function int used();
%000000     return m.num();
          endfunction
        
        
          // Function -- NODOCS -- is_empty
          //
          // Returns 1 when there are no entries in the FIFO, 0 otherwise.
        
%000000   virtual function bit is_empty();
%000000     return (m.num() == 0);
          endfunction
         
        
          // Function -- NODOCS -- is_full
          //
          // Returns 1 when the number of entries in the FIFO is equal to its <size>,
          // 0 otherwise.
        
%000000   virtual function bit is_full();
%000000     return (m_size != 0) && (m.num() == m_size);
          endfunction
         
        
        
%000000   virtual task put( input T t );
%000000     m.put( t );
%000000     put_ap.write( t );
          endtask
        
~002494   virtual task get( output T t );
          `ifndef UVM_USE_PROCESS_CONTAINER
~002494     process pid;
~002494     pid = process::self();
          `else
            process_container_c pid=new(process::self());
          `endif     
~002494     m_pending_blocked_gets[pid] = 1;
~002494     m.get( t );
~002494     m_pending_blocked_gets.delete(pid);
~002494     get_ap.write( t );
          endtask
          
~001247   virtual task peek( output T t );
~001247     m.peek( t );
          endtask
           
~001247   virtual function bit try_get( output T t );
~001247     if( !m.try_get( t ) ) begin
%000000       return 0;
            end
        
~001247     get_ap.write( t );
~001247     return 1;
          endfunction 
          
%000000   virtual function bit try_peek( output T t );
%000000     if( !m.try_peek( t ) ) begin
%000000       return 0;
            end
%000000     return 1;
          endfunction
        
~003741   virtual function bit try_put( input T t );
~003741     if( !m.try_put( t ) ) begin
%000000       return 0;
            end
          
~003741     put_ap.write( t );
~003741     return 1;
          endfunction  
        
%000000   virtual function bit can_put();
%000000     return m_size == 0 || m.num() < m_size;
          endfunction  
        
          // undocumented function for clearing zombie gets
%000000   protected function void m_clear_zombie_gets();
          `ifndef UVM_USE_PROCESS_CONTAINER
%000000     process zombie_gets[$];
          `else
            process_container_c zombie_gets[$];
          `endif  
%000000     foreach (m_pending_blocked_gets[i]) begin
%000000       int status;
          `ifndef UVM_USE_PROCESS_CONTAINER
%000000       status = i.status();
          `else
              status = i.p.status();
          `endif
%000000       if (status == process::KILLED) begin
%000000         zombie_gets.push_back(i);
              end
        
            end
        
%000000     foreach (zombie_gets[i]) begin
              
%000000       m_pending_blocked_gets.delete(zombie_gets[i]);
            end
        
          endfunction : m_clear_zombie_gets
          
%000000   virtual function bit can_get();
%000000     m_clear_zombie_gets();
%000000     return m.num() > 0 && m_pending_blocked_gets.size() == 0;
          endfunction
          
%000000   virtual function bit can_peek();
%000000     return m.num() > 0;
          endfunction
        
        
          // Function -- NODOCS -- flush
          //
          // Removes all entries from the FIFO, after which <used> returns 0
          // and <is_empty> returns 1.
        
%000000   virtual function void flush();
%000000     T t;
%000000     bit r;
        
%000000     m_clear_zombie_gets();
            
%000000     if( m.num() > 0 && m_pending_blocked_gets.size() != 0 ) begin
%000000       uvm_report_error("flush failed" ,
%000000                "there are blocked gets preventing the flush", UVM_NONE);
%000000       return;
            end
        
%000000     r = 1; 
%000000     while( r ) begin
%000000       r = (m.try_get(t) != 0);
            end
        
            
          
          endfunction
         
        endclass 
        
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_tlm_analysis_fifo#(T)
        //
        // An analysis_fifo is a <uvm_tlm_fifo#(T)> with an unbounded size and a write interface.
        // It can be used any place a <uvm_analysis_imp> is used. Typical usage is
        // as a buffer between a <uvm_analysis_port> in an initiator component
        // and TLM1 target component.
        //
        //------------------------------------------------------------------------------
        
        class uvm_tlm_analysis_fifo #(type T = int) extends uvm_tlm_fifo #(T);
%000000   `uvm_component_param_utils(uvm_tlm_analysis_fifo#(T))
~000012   `uvm_type_name_decl("uvm_tlm_analysis_fifo #(T)")
        
          // Port -- NODOCS -- analysis_export #(T)
          //
          // The analysis_export provides the write method to all connected analysis
          // ports and parent exports:
          //
          //|  function void write (T t)
          //
          // Access via ports bound to this export is the normal mechanism for writing
          // to an analysis FIFO. 
          // See write method of <uvm_tlm_if_base #(T1,T2)> for more information.
        
          uvm_analysis_imp #(T, uvm_tlm_analysis_fifo #(T)) analysis_export;
        
        
          // Function -- NODOCS -- new
          //
          // This is the standard uvm_component constructor. ~name~ is the local name
          // of this component. The ~parent~ should be left unspecified when this
          // component is instantiated in statically elaborated constructs and must be
          // specified when this component is a child of another UVM component.
        
%000006   function new(string name ,  uvm_component parent = null);
%000006     super.new(name, parent, 0); // analysis fifo must be unbounded
%000006     analysis_export = new("analysis_export", this);
          endfunction
        
 002494   function void write(input T t);
 002494     void'(this.try_put(t)); // unbounded => must succeed
          endfunction
        
        endclass
        
