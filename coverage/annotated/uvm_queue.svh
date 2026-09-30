//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Intel Corporation
        // Copyright 2007-2011 Mentor Graphics Corporation
        // Copyright 2015-2024 NVIDIA Corporation
        // Copyright 2010 Synopsys, Inc.
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
        // $File:     src/base/uvm_queue.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        
        `ifndef UVM_QUEUE_SVH
        `define UVM_QUEUE_SVH
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_queue #(T)
        //
        //------------------------------------------------------------------------------
        // Implements a class-based dynamic queue. Allows queues to be allocated on
        // demand, and passed and stored by reference.
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 11.3.1
        class uvm_queue #(type T=int) extends uvm_object;
        
          typedef uvm_queue #(T) this_type;
        
%000000   `uvm_object_param_utils(uvm_queue#(T))
%000000   `uvm_type_name_decl("uvm_queue")
        
          static local this_type m_global_queue;
          protected T queue[$];
        
          // Function -- NODOCS -- new
          //
          // Creates a new queue with the given ~name~.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.1
~000285   function new (string name="");
~000285     super.new(name);
          endfunction
        
        
          // Function -- NODOCS -- get_global_queue
          //
          // Returns the singleton global queue for the item type, T. 
          //
          // This allows items to be shared amongst components throughout the
          // verification environment.
        
%000000   static function this_type get_global_queue ();
%000000     if (m_global_queue==null)
%000000       begin
%000000         m_global_queue = new("global_queue");
              end
        
%000000     return m_global_queue;
          endfunction
        
        
          // Function -- NODOCS -- get_global
          //
          // Returns the specified item instance from the global item queue. 
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.3
%000000   static function T get_global (int index);
%000000     this_type gqueue;
%000000     gqueue = get_global_queue(); 
%000000     return gqueue.get(index);
          endfunction
        
        
          // Function -- NODOCS -- get
          //
          // Returns the item at the given ~index~.
          //
          // If no item exists by that key, a new item is created with that key
          // and returned.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.4
~000078   virtual function T get (int index);
~000078     T default_value;
~000078     if (index >= size() || index < 0) 
%000000       begin
%000000         uvm_report_warning("QUEUEGET",
%000000         $sformatf("get: given index out of range for queue of size %0d. Ignoring get request",size()));
%000000         return default_value;
              end
~000078     return queue[index];
          endfunction
          
        
          // Function -- NODOCS -- size
          //
          // Returns the number of items stored in the queue.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.5
~004735   virtual function int size ();
~004735     return queue.size();
          endfunction
        
        
          // Function -- NODOCS -- insert
          //
          // Inserts the item at the given ~index~ in the queue.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.6
%000000   virtual function void insert (int index, T item);
%000000     if (index >= size() || index < 0) 
%000000       begin
%000000         uvm_report_warning("QUEUEINS",
%000000         $sformatf("insert: given index out of range for queue of size %0d. Ignoring insert request",size()));
%000000         return;
              end
%000000     queue.insert(index,item);
          endfunction
        
        
          // Function -- NODOCS -- delete
          //
          // Removes the item at the given ~index~ from the queue; if ~index~ is
          // not provided, the entire contents of the queue are deleted.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.7
~000042   virtual function void delete (int index=-1);
~000042     if (index >= size() || index < -1) 
%000000       begin
%000000         uvm_report_warning("QUEUEDEL",
%000000         $sformatf("delete: given index out of range for queue of size %0d. Ignoring delete request",size()));
%000000         return;
              end
~000042     if (index == -1)
~000042       begin
~000042         queue.delete();
              end
        
            else
%000000       begin
%000000         queue.delete(index);
              end
        
          endfunction
        
        
          // Function -- NODOCS -- pop_front
          //
          // Returns the first element in the queue (index=0),
          // or ~null~ if the queue is empty.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.8
%000000   virtual function T pop_front();
%000000     return queue.pop_front();
          endfunction
        
        
          // Function -- NODOCS -- pop_back
          //
          // Returns the last element in the queue (index=size()-1),
          // or ~null~ if the queue is empty.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.9
%000000   virtual function T pop_back();
%000000     return queue.pop_back();
          endfunction
        
        
          // Function -- NODOCS -- push_front
          //
          // Inserts the given ~item~ at the front of the queue.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.10
%000000   virtual function void push_front(T item);
%000000     queue.push_front(item);
          endfunction
        
        
          // Function -- NODOCS -- push_back
          //
          // Inserts the given ~item~ at the back of the queue.
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.11
~000078   virtual function void push_back(T item);
~000078     queue.push_back(item);
          endfunction
        
          // Task -- NODOCS -- wait_until_not_empty
          //
          // Blocks until not empty
        
          // @uvm-ieee 1800.2-2020 auto 11.3.2.12
%000000   virtual task wait_until_not_empty();
%000000       wait(queue.size() > 0);
          endtask
        
%000000   virtual function void do_copy (uvm_object rhs);
%000000     this_type p;
%000000     super.do_copy(rhs);
%000000     if (rhs == null || !$cast(p, rhs))
%000000       begin
%000000         return;
              end
        
%000000     queue = p.queue;
          endfunction
          
%000000   virtual function string convert2string();
%000000       return $sformatf("%p",queue);
          endfunction
        
        endclass
        
        
        `endif // UVM_QUEUE_SVH
        
