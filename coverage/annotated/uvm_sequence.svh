//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2010-2012 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2013 Cisco Systems, Inc.
        // Copyright 2007-2014 Mentor Graphics Corporation
        // Copyright 2014-2024 NVIDIA Corporation
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
        // $File:     src/seq/uvm_sequence.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_sequence #(REQ,RSP)
        //
        // The uvm_sequence class provides the interfaces necessary in order to create
        // streams of sequence items and/or other sequences.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 14.3.1
        virtual class uvm_sequence #(type REQ = uvm_sequence_item,
                                     type RSP = REQ) extends uvm_sequence_base;
        
          typedef uvm_sequencer_param_base #(REQ, RSP) sequencer_t;
        
          sequencer_t        param_sequencer;
        
          // Variable -- NODOCS -- req
          //
          // The sequence contains a field of the request type called req.  The user
          // can use this field, if desired, or create another field to use.  The
          // default ~do_print~ will print this field.
          REQ                req;
        
          // Variable -- NODOCS -- rsp
          //
          // The sequence contains a field of the response type called rsp.  The user
          // can use this field, if desired, or create another field to use.   The
          // default ~do_print~ will print this field.
          RSP                rsp;
        
          // Function -- NODOCS -- new
          //
          // Creates and initializes a new sequence object.
        
          // @uvm-ieee 1800.2-2020 auto 14.3.3.1
%000003   function new (string name = "uvm_sequence");
%000003     super.new(name);
          endfunction
        
          // Function -- NODOCS -- send_request
          //
          // This method will send the request item to the sequencer, which will forward
          // it to the driver.  If the rerandomize bit is set, the item will be
          // randomized before being sent to the driver. The send_request function may
          // only be called after <uvm_sequence_base::wait_for_grant> returns.
        
%000000   function void send_request(uvm_sequence_item request, bit rerandomize = 0);
%000000     REQ m_request;
        
%000000     if (m_sequencer == null) begin
%000000       uvm_report_fatal("SSENDREQ", "Null m_sequencer reference", UVM_NONE);
            end
%000000     if (!$cast(m_request, request)) begin
%000000       uvm_report_fatal("SSENDREQ", "Failure to cast uvm_sequence_item to request", UVM_NONE);
            end
%000000     m_sequencer.send_request(this, m_request, rerandomize);
          endfunction
        
        
          // Function -- NODOCS -- get_current_item
          //
          // Returns the request item currently being executed by the sequencer. If the
          // sequencer is not currently executing an item, this method will return ~null~.
          //
          // The sequencer is executing an item from the time that get_next_item or peek
          // is called until the time that get or item_done is called.
          //
          // Note that a driver that only calls get will never show a current item,
          // since the item is completed at the same time as it is requested.
        
          // @uvm-ieee 1800.2-2020 auto 14.3.3.2
%000000   function REQ get_current_item();
%000000     if (!$cast(param_sequencer, m_sequencer)) begin
              
%000000       uvm_report_fatal("SGTCURR", "Failure to cast m_sequencer to the parameterized sequencer", UVM_NONE);
            end
        
%000000     return (param_sequencer.get_current_item());
          endfunction
        
        
          // Task -- NODOCS -- get_response
          //
          // By default, sequences must retrieve responses by calling get_response.
          // If no transaction_id is specified, this task will return the next response
          // sent to this sequence.  If no response is available in the response queue,
          // the method will block until a response is received.
          //
          // If a transaction_id is parameter is specified, the task will block until
          // a response with that transaction_id is received in the response queue.
          //
          // The default size of the response queue is 8.  The get_response method must
          // be called soon enough to avoid an overflow of the response queue to prevent
          // responses from being dropped.
          //
          // If a response is dropped in the response queue, an error will be reported
          // unless the error reporting is disabled via
          // set_response_queue_error_report_enabled.
        
          // @uvm-ieee 1800.2-2020 auto 14.3.3.3
%000000   virtual task get_response(output RSP response, input int transaction_id = -1);
%000000     uvm_sequence_item rsp;
%000000     get_base_response( rsp, transaction_id);
%000000     $cast(response,rsp);
          endtask
        
        
        
          // Function- put_response
          //
          // Internal method.
        
%000000   virtual function void put_response(uvm_sequence_item response_item);
%000000     RSP response;
%000000     if (!$cast(response, response_item)) begin
%000000       uvm_report_fatal("PUTRSP", "Failure to cast response in put_response", UVM_NONE);
            end
%000000     put_base_response(response_item);
          endfunction
        
        
          // Function- do_print
          //
%000000   function void do_print (uvm_printer printer);
%000000     super.do_print(printer);
%000000     printer.print_object("req", req);
%000000     printer.print_object("rsp", rsp);
          endfunction
        
        endclass
        
