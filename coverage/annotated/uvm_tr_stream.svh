//      // verilator_coverage annotation
        //
        //-----------------------------------------------------------------------------
        // Copyright 2015 Analog Devices, Inc.
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2017 Cisco Systems, Inc.
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
        // $File:     src/base/uvm_tr_stream.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        // File -- NODOCS -- Transaction Recording Streams
        //
        
        // class- m_uvm_tr_stream_cfg
        // Undocumented helper class for storing stream
        // initialization values.
%000000 class m_uvm_tr_stream_cfg;
           uvm_tr_database db;
           string scope;
           string stream_type_name;
        endclass : m_uvm_tr_stream_cfg
        
        typedef class uvm_set_before_get_dap;
        typedef class uvm_text_recorder;
           
        
        // @uvm-ieee 1800.2-2020 auto 7.2.1
        virtual class uvm_tr_stream extends uvm_object;
        
           // Variable- m_cfg_dap
           // Data access protected reference to the DB
           local uvm_set_before_get_dap#(m_uvm_tr_stream_cfg) m_cfg_dap;
        
           // Variable- m_records
           // Active records in the stream (active == open or closed)
           local bit m_records[uvm_recorder];
           
           // Variable- m_warn_null_cfg
           // Used to limit the number of warnings
           local bit m_warn_null_cfg;
        
           // Variable- m_is_opened
           // Used to indicate stream is open
           local bit m_is_opened;
        
           // Variable- m_is_closed
           // Used to indicate stream is closed
           local bit m_is_closed;
           
           // !m_is_opened && !m_is_closed == m_is_freed
           
        
           // @uvm-ieee 1800.2-2020 auto 7.2.2
%000000    function new(string name="unnamed-uvm_tr_stream");
%000000       super.new(name);
%000000       m_cfg_dap = new("cfg_dap");
           endfunction : new
        
           // Variable- m_ids_by_stream
           // An associative array of int, indexed by uvm_tr_streams.  This
           // provides a unique 'id' or 'handle' for each stream, which can be
           // used to identify the stream.
           //
           // By default, neither ~m_ids_by_stream~ or ~m_streams_by_id~ are
           // used.  Streams are only placed in the arrays when the user
           // attempts to determine the id for a stream.
           local static int m_ids_by_stream[uvm_tr_stream];
        
           // Group -- NODOCS -- Configuration API
           
        
           // @uvm-ieee 1800.2-2020 auto 7.2.3.1
%000000    function uvm_tr_database get_db();
%000000       m_uvm_tr_stream_cfg m_cfg;
%000000       if (!m_cfg_dap.try_get(m_cfg)) 
%000000         begin
%000000           if (m_warn_null_cfg == 1) 
%000000           begin
                    `uvm_warning("UVM/REC_STR/NO_CFG",
                    $sformatf("attempt to retrieve DB from '%s' before it was set!",
%000000             get_name()))
                  end
%000000           m_warn_null_cfg = 0;
%000000           return null;
                end
%000000       return m_cfg.db;
           endfunction : get_db
              
        
           // @uvm-ieee 1800.2-2020 auto 7.2.3.2
%000000    function string get_scope();
%000000       m_uvm_tr_stream_cfg m_cfg;
%000000       if (!m_cfg_dap.try_get(m_cfg)) 
%000000         begin
%000000           if (m_warn_null_cfg == 1) 
%000000           begin
                    `uvm_warning("UVM/REC_STR/NO_CFG",
                    $sformatf("attempt to retrieve scope from '%s' before it was set!",
%000000             get_name()))
                  end
%000000           m_warn_null_cfg = 0;
%000000           return "";
                end
%000000       return m_cfg.scope;
           endfunction : get_scope
              
        
           // @uvm-ieee 1800.2-2020 auto 7.2.3.3
%000000    function string get_stream_type_name();
%000000       m_uvm_tr_stream_cfg m_cfg;
%000000       if (!m_cfg_dap.try_get(m_cfg)) 
%000000         begin
%000000           if (m_warn_null_cfg == 1) 
%000000           begin
                    `uvm_warning("UVM/REC_STR/NO_CFG",
                    $sformatf("attempt to retrieve STREAM_TYPE_NAME from '%s' before it was set!",
%000000             get_name()))
                  end
%000000           m_warn_null_cfg = 0;
%000000           return "";
                end
%000000       return m_cfg.stream_type_name;
           endfunction : get_stream_type_name
        
           // Group -- NODOCS -- Stream API
           //
           // Once a stream has been opened via <uvm_tr_database::open_stream>, the user
           // can ~close~ the stream.
           //
           // Due to the fact that many database implementations will require crossing 
           // a language boundary, an additional step of ~freeing~ the stream is required.
           //
           // A ~link~ can be established within the database any time between "Open" and
           // "Free", however it is illegal to establish a link after "Freeing" the stream.
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.4.1
%000000    function void close();
%000000       if (!is_open())
%000000         begin
%000000           return;
                end
        
        
%000000       do_close();
        
%000000       foreach (m_records[idx])
%000000         begin
%000000           if (idx.is_open())
%000000           begin
%000000             idx.close();
                  end
        
                end
        
        
%000000       m_is_opened = 0;
%000000       m_is_closed = 1;
           endfunction : close
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.4.2
%000000    function void free();
%000000        process p;
%000000        string s;
%000000       uvm_tr_database db;
%000000       if (!is_open() && !is_closed())
%000000         begin
%000000           return;
                end
        
        
%000000       if (is_open())
%000000         begin
%000000           close();
                end
        
        
%000000       do_free();
              
%000000       foreach (m_records[idx])
%000000         begin
%000000           idx.free();
                end
        
        
              // Clear out internal state
%000000       db = get_db();
%000000       m_is_closed = 0;
%000000       p = process::self();
%000000       if(p != null)
%000000         begin
%000000           s = p.get_randstate();
                end
        
%000000       m_cfg_dap = new("cfg_dap");
%000000       if(p != null)
%000000         begin
%000000           p.set_randstate(s);
                end
        
%000000       m_warn_null_cfg = 1;
%000000       if (m_ids_by_stream.exists(this))
%000000         begin
%000000           m_free_id(m_ids_by_stream[this]);
                end
        
        
              // Clear out DB state
%000000       if (db != null)
%000000         begin
%000000           db.m_free_stream(this);
                end
        
           endfunction : free
           
           // Function- m_do_open
           // Initializes the state of the stream
           //
           // Parameters-
           // db - Database which the stream belongs to
           // scope - Optional scope
           // stream_type_name - Optional type name for the stream
           //
           // This method will trigger a <do_open> call.
           //
           // An error will be asserted if-
           // - m_do_open is called more than once without the stream
           //   being ~freed~ between.
           // - m_do_open is passed a ~null~ db
%000000    function void m_do_open(uvm_tr_database db,
                                   string scope="",
                                   string stream_type_name="");
              
%000000       m_uvm_tr_stream_cfg m_cfg;
%000000       uvm_tr_database m_db;
%000000       if (db == null) 
%000000         begin
                  `uvm_error("UVM/REC_STR/NULL_DB",
                  $sformatf("Illegal attempt to set DB for '%s' to '<null>'",
%000000           this.get_full_name()))
%000000           return;
                end
        
%000000       if (m_cfg_dap.try_get(m_cfg)) 
%000000         begin
                  `uvm_error("UVM/REC_STR/RE_CFG",
                  $sformatf("Illegal attempt to re-open '%s'",
%000000           this.get_full_name()))
                end
              else 
%000000         begin
                  // Never set before
%000000           m_cfg = new();
%000000           m_cfg.db = db;
%000000           m_cfg.scope = scope;
%000000           m_cfg.stream_type_name = stream_type_name;
%000000           m_cfg_dap.set(m_cfg);
%000000           m_is_opened = 1;
        
%000000           do_open(db, scope, stream_type_name);
                end
              
           endfunction : m_do_open
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.4.3
%000000    function bit is_open();
%000000       return m_is_opened;
           endfunction : is_open
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.4.4
%000000    function bit is_closed();
%000000       return m_is_closed;
           endfunction : is_closed
        
           // Group -- NODOCS -- Transaction Recorder API
           //
           // New recorders can be opened prior to the stream being ~closed~.
           //
           // Once a stream has been closed, requests to open a new recorder
           // will be ignored (<open_recorder> will return ~null~).
           //
           
        
           // @uvm-ieee 1800.2-2020 auto 7.2.5.1
%000000    function uvm_recorder open_recorder(string name,
                                              time   open_time = 0,
                                              string type_name="");
%000000       time m_time = (open_time == 0) ? $time : open_time;
        
              // Check to make sure we're open
%000000       if (!is_open())
%000000         begin
%000000           return null;
                end
        
              else 
%000000         begin
%000000           process p = process::self();
%000000           string s;
        
%000000           if (p != null)
%000000           begin
%000000             s = p.get_randstate();
                  end
        
                 
%000000           open_recorder = do_open_recorder(name,
%000000                                           m_time,
%000000                                           type_name);
        
        
                 
%000000           if (open_recorder != null) 
%000000           begin
%000000             m_records[open_recorder] = 1;
%000000             open_recorder.m_do_open(this, m_time, type_name);
                  end
%000000           if (p != null)
%000000           begin
%000000             p.set_randstate(s);
                  end
         
                end
           endfunction : open_recorder
        
           // Function- m_free_recorder
           // Removes recorder from the internal array
%000000    function void m_free_recorder(uvm_recorder recorder);
%000000       if (m_records.exists(recorder))
%000000         begin
%000000           m_records.delete(recorder);
                end
        
           endfunction : m_free_recorder
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.5.2
%000000    function unsigned get_recorders(ref uvm_recorder q[$]);
              // Clear out the queue first...
%000000       q.delete();
              // Fill in the values
%000000       foreach (m_records[idx])
%000000         begin
%000000           q.push_back(idx);
                end
        
              // Finally return the size of the queue
%000000       return q.size();
           endfunction : get_recorders
           
           // Group -- NODOCS -- Handles
        
           // Variable- m_streams_by_id
           // A corollary to ~m_ids_by_stream~, this indexes the streams by their
           // unique ids.
           local static uvm_tr_stream m_streams_by_id[int];
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.6.1
%000000    function int get_handle();
%000000       if (!is_open() && !is_closed()) 
%000000         begin
%000000           return 0;
                end
              else 
%000000         begin
%000000           int handle = get_inst_id();
                 
                  // Check for the weird case where our handle changed.
%000000           if (m_ids_by_stream.exists(this) && m_ids_by_stream[this] != handle)
%000000           begin
%000000             m_streams_by_id.delete(m_ids_by_stream[this]);
                  end
        
        
%000000           m_streams_by_id[handle] = this;
%000000           m_ids_by_stream[this] = handle;
        
%000000           return handle;
                end
           endfunction : get_handle   
           
           // @uvm-ieee 1800.2-2020 auto 7.2.6.2
%000000    static function uvm_tr_stream get_stream_from_handle(int id);
%000000       if (id == 0)
%000000         begin
%000000           return null;
                end
        
        
%000000       if ($isunknown(id) || !m_streams_by_id.exists(id))
%000000         begin
%000000           return null;
                end
        
        
%000000       return m_streams_by_id[id];
           endfunction : get_stream_from_handle
                
           // Function- m_free_id
           // Frees the id/stream link (memory cleanup)
           //
%000000    static function void m_free_id(int id);
%000000       uvm_tr_stream stream;
%000000       if (!$isunknown(id) && m_streams_by_id.exists(id))
%000000         begin
%000000           stream = m_streams_by_id[id];
                end
        
        
%000000       if (stream != null) 
%000000         begin
%000000           m_streams_by_id.delete(id);
%000000           m_ids_by_stream.delete(stream);
                end
           endfunction : m_free_id
        
           // Group -- NODOCS -- Implementation Agnostic API
           //
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.7.1
%000000    protected virtual function void do_open(uvm_tr_database db,
                                                   string scope,
                                                   string stream_type_name);
           endfunction : do_open
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.7.2
%000000    protected virtual function void do_close();
           endfunction : do_close
              
        
           // @uvm-ieee 1800.2-2020 auto 7.2.7.3
%000000    protected virtual function void do_free();
           endfunction : do_free
        
        
           // @uvm-ieee 1800.2-2020 auto 7.2.7.4
%000000    protected virtual function uvm_recorder do_open_recorder(string name,
                                                                    time   open_time,
                                                                    string type_name);
%000000       return null;
           endfunction : do_open_recorder
        
        endclass : uvm_tr_stream
        
        
