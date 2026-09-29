//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_barrier.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        
        //-----------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_barrier
        //
        // The uvm_barrier class provides a multiprocess synchronization mechanism. 
        // It enables a set of processes to block until the desired number of processes
        // get to the synchronization point, at which time all of the processes are
        // released.
        //-----------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 10.3.1
        class uvm_barrier extends uvm_object;
        
          local  int       threshold;
          local  int       num_waiters;
          local  bit       at_threshold;
          local  bit       auto_reset;
          local  uvm_event#(uvm_object) m_event;
        
%000000   `uvm_object_utils(uvm_barrier)
        
          // Function -- NODOCS -- new
          //
          // Creates a new barrier object.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.1
%000000   function new (string name="", int threshold=0);
%000000     super.new(name);
%000000     m_event = new({"barrier_",name});
%000000     this.threshold = threshold;
%000000     num_waiters = 0;
%000000     auto_reset = 1;
%000000     at_threshold = 0;
          endfunction
        
        
          // Task -- NODOCS -- wait_for
          //
          // Waits for enough processes to reach the barrier before continuing. 
          //
          // The number of processes to wait for is set by the <set_threshold> method.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.2
%000000   virtual task wait_for();
        
%000000     if (at_threshold)
%000000       begin
%000000         return;
              end
        
        
%000000     num_waiters++;
        
%000000     if (num_waiters >= threshold) 
%000000       begin
%000000         if (!auto_reset)
%000000         begin
%000000           at_threshold=1;
                end
        
%000000         m_trigger();
%000000         return;
              end
        
%000000     m_event.wait_trigger();
        
          endtask
        
          
          // Function -- NODOCS -- reset
          //
          // Resets the barrier. This sets the waiter count back to zero. 
          //
          // The threshold is unchanged. After reset, the barrier will force processes
          // to wait for the threshold again. 
          //
          // If the ~wakeup~ bit is set, any currently waiting processes will
          // be activated.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.3
%000000   virtual function void reset (bit wakeup=1);
%000000     at_threshold = 0;
%000000     if (num_waiters) 
%000000       begin
%000000         if (wakeup)
%000000         begin
%000000           m_event.trigger();
                end
        
                else
%000000         begin
%000000           m_event.reset();
                end
        
              end
%000000     num_waiters = 0;
          endfunction
        
        
          // Function -- NODOCS -- set_auto_reset
          //
          // Determines if the barrier should reset itself after the threshold is
          // reached. 
          //
          // The default is on, so when a barrier hits its threshold it will reset, and
          // new processes will block until the threshold is reached again. 
          //
          // If auto reset is off, then once the threshold is achieved, new processes
          // pass through without being blocked until the barrier is reset.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.4
%000000   virtual function void set_auto_reset (bit value=1);
%000000     at_threshold = 0;
%000000     auto_reset = value;
          endfunction
        
        
          // Function -- NODOCS -- set_threshold
          //
          // Sets the process threshold. 
          //
          // This determines how many processes must be waiting on the barrier before
          // the processes may proceed. 
          //
          // Once the ~threshold~ is reached, all waiting processes are activated. 
          //
          // If ~threshold~ is set to a value less than the number of currently
          // waiting processes, then the barrier is reset and waiting processes are
          // activated.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.6
%000000   virtual function void set_threshold (int threshold);
%000000     this.threshold = threshold;
%000000     if (threshold <= num_waiters)
%000000       begin
%000000         reset(1);
              end
        
          endfunction
        
        
          // Function -- NODOCS -- get_threshold
          //
          // Gets the current threshold setting for the barrier.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.5
%000000   virtual function int get_threshold ();
%000000     return threshold;
          endfunction
        
          
          // Function -- NODOCS -- get_num_waiters
          //
          // Returns the number of processes currently waiting at the barrier.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.7
%000000   virtual function int get_num_waiters ();
%000000     return num_waiters;
          endfunction
        
        
          // Function -- NODOCS -- cancel
          //
          // Decrements the waiter count by one. This is used when a process that is
          // waiting on the barrier is killed or activated by some other means.
        
          // @uvm-ieee 1800.2-2020 auto 10.3.2.8
%000000   virtual function void cancel ();
%000000     m_event.cancel();
%000000     num_waiters = m_event.get_num_waiters();
          endfunction
        
%000000   local task m_trigger();
%000000     m_event.trigger();
%000000     num_waiters=0;
%000000     #0; //this process was last to wait; allow other procs to resume first
          endtask
        
%000000   virtual function void do_print (uvm_printer printer);
%000000     printer.print_field_int("threshold", threshold, $bits(threshold), UVM_DEC, ".", "int");
%000000     printer.print_field_int("num_waiters", num_waiters, $bits(num_waiters), UVM_DEC, ".", "int");
%000000     printer.print_field_int("at_threshold", at_threshold, $bits(at_threshold), UVM_BIN, ".", "bit");
%000000     printer.print_field_int("auto_reset", auto_reset, $bits(auto_reset), UVM_BIN, ".", "bit");
          endfunction
        
%000000   virtual function void do_copy (uvm_object rhs);
%000000     uvm_barrier b;
%000000     super.do_copy(rhs);
%000000     if(!$cast(b, rhs) || (b==null)) 
%000000       begin
%000000         return;
              end
        
        
%000000     threshold = b.threshold;
%000000     num_waiters = b.num_waiters;
%000000     at_threshold = b.at_threshold;
%000000     auto_reset = b.auto_reset;
%000000     m_event = b.m_event;
          endfunction  
        
        endclass
        
