//      // verilator_coverage annotation
        //
        //-----------------------------------------------------------------------------
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
        // Copyright 2014 Intel Corporation
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
        //-----------------------------------------------------------------------------
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/base/uvm_tr_database.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        // File -- NODOCS -- Transaction Recording Databases
        //
        // The UVM "Transaction Recording Database" classes are an abstract representation
        // of the backend tool which is recording information for the user.  Usually this
        // tool would be dumping information such that it can be viewed with the ~waves~ 
        // of the DUT.
        //
        
        typedef class uvm_recorder;
        typedef class uvm_tr_stream;
        typedef class uvm_link_base;
           
           
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_tr_database
        //
        // The ~uvm_tr_database~ class is intended to hide the underlying database implementation
        // from the end user, as these details are often vendor or tool-specific.
        //
        // The ~uvm_tr_database~ class is pure virtual, and must be extended with an
        // implementation.  A default text-based implementation is provided via the
        // <uvm_text_tr_database> class.
        //
        
        // @uvm-ieee 1800.2-2020 auto 7.1.1
        virtual class uvm_tr_database extends uvm_object;
        
           // Variable- m_is_opened
           // Tracks the opened state of the database
           local bit m_is_opened;
        
           // Variable- m_streams
           // Used for tracking streams which are between the open and closed states
           local bit m_streams[uvm_tr_stream];
           
        
           // @uvm-ieee 1800.2-2020 auto 7.1.2
%000003    function new(string name="unnamed-uvm_tr_database");
%000003       super.new(name);
           endfunction : new
        
           // Group -- NODOCS -- Database API
           
        
           // @uvm-ieee 1800.2-2020 auto 7.1.3.1
%000000    function bit open_db();
%000000       if (!m_is_opened) begin
                
%000000         m_is_opened = do_open_db();
              end
        
%000000       return m_is_opened;
           endfunction : open_db
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.3.2
%000000    function bit close_db();
%000000       if (m_is_opened) begin
%000000         if (do_close_db()) begin
                   
%000000           m_is_opened = 0;
                end
        
              end
%000000       return (m_is_opened == 0);
           endfunction : close_db
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.3.3
%000000    function bit is_open();
%000000       return m_is_opened;
           endfunction : is_open
        
           // Group -- NODOCS -- Stream API
           
        
           // @uvm-ieee 1800.2-2020 auto 7.1.4.1
%000000    function uvm_tr_stream open_stream(string name,
                                              string scope="",
                                              string type_name="");
%000000       if (!open_db()) begin
%000000         return null;
              end
%000000       else begin
%000000         process p = process::self();
%000000         string s;
        
%000000         if (p != null) begin
                   
%000000           s = p.get_randstate();
                end
        
        
%000000         open_stream = do_open_stream(name, scope, type_name);
        
        
%000000         if (open_stream != null) begin
%000000           m_streams[open_stream] = 1;
%000000           open_stream.m_do_open(this, scope, type_name);
                end
                 
%000000         if (p != null) begin
                   
%000000           p.set_randstate(s);
                end
        
        
              end
           endfunction : open_stream
        
           // Function- m_free_stream
           // Removes stream from the internal array
%000000    function void m_free_stream(uvm_tr_stream stream);
%000000       if (m_streams.exists(stream)) begin
                
%000000         m_streams.delete(stream);
              end
        
           endfunction : m_free_stream
           
        
           // @uvm-ieee 1800.2-2020 auto 7.1.4.2
%000000    function unsigned get_streams(ref uvm_tr_stream q[$]);
              // Clear out the queue first...
%000000       q.delete();
              // Then fill in the values
%000000       foreach (m_streams[idx]) begin
                
%000000         q.push_back(idx);
              end
        
              // Finally, return the size of the queue
%000000       return q.size();
           endfunction : get_streams
           
           // Group -- NODOCS -- Link API
           
        
           // @uvm-ieee 1800.2-2020 auto 7.1.5
%000000    function void establish_link(uvm_link_base link);
%000000       uvm_tr_stream s_lhs, s_rhs;
%000000       uvm_recorder r_lhs, r_rhs;
%000000       uvm_object lhs = link.get_lhs();
%000000       uvm_object rhs = link.get_rhs();
%000000       uvm_tr_database db;
        
%000000       if (lhs == null) begin
                `uvm_warning("UVM/TR_DB/BAD_LINK",
%000000         "left hand side '<null>' is not supported in links for 'uvm_tr_database'")
%000000         return;
              end
%000000       if (rhs == null) begin
                `uvm_warning("UVM/TR_DB/BAD_LINK",
%000000         "right hand side '<null>' is not supported in links for 'uvm_tr_database'")
%000000         return;
              end
              
%000000       if (!$cast(s_lhs, lhs) && 
%000000           !$cast(r_lhs, lhs)) begin
                `uvm_warning("UVM/TR_DB/BAD_LINK",
                $sformatf("left hand side of type '%s' not supported in links for 'uvm_tr_database'",
%000000         lhs.get_type_name()))
%000000         return;
              end
%000000       if (!$cast(s_rhs, rhs) && 
%000000           !$cast(r_rhs, rhs)) begin
                `uvm_warning("UVM/TR_DB/BAD_LINK",
                $sformatf("right hand side of type '%s' not supported in links for 'uvm_record_datbasae'",
%000000         rhs.get_type_name()))
%000000         return;
              end
              
%000000       if (r_lhs != null) begin
%000000         s_lhs = r_lhs.get_stream();
              end
%000000       if (r_rhs != null) begin
%000000         s_rhs = r_rhs.get_stream();
              end
        
%000000       if ((s_lhs != null) && (s_lhs.get_db() != this)) begin
%000000         db = s_lhs.get_db();
                `uvm_warning("UVM/TR_DB/BAD_LINK",
                $sformatf("attempt to link stream from '%s' into '%s'",
%000000         db.get_name(), this.get_name()))
%000000         return;
              end
%000000       if ((s_rhs != null) && (s_rhs.get_db() != this)) begin
%000000         db = s_rhs.get_db();
                `uvm_warning("UVM/TR_DB/BAD_LINK",
                $sformatf("attempt to link stream from '%s' into '%s'",
%000000         db.get_name(), this.get_name()))
%000000         return;
              end
        
%000000       do_establish_link(link);
           endfunction : establish_link
              
           // Group -- NODOCS -- Implementation Agnostic API
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.6.1
%000000    pure virtual protected function bit do_open_db();
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.6.2
%000000    pure virtual protected function bit do_close_db();
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.6.3
%000000    pure virtual protected function uvm_tr_stream do_open_stream(string name,
                                                                        string scope,
                                                                        string type_name);
        
        
           // @uvm-ieee 1800.2-2020 auto 7.1.6.4
%000000    pure virtual protected function void do_establish_link(uvm_link_base link);
        
        endclass : uvm_tr_database
        
        
