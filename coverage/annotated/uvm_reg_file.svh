//      // verilator_coverage annotation
        //
        // -------------------------------------------------------------
        // Copyright 2010 AMD
        // Copyright 2010-2018 Cadence Design Systems, Inc.
        // Copyright 2010-2011 Mentor Graphics Corporation
        // Copyright 2025 Microsoft
        // Copyright 2015-2026 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2018 Synopsys, Inc.
        //    All Rights Reserved Worldwide
        //
        //    Licensed under the Apache License, Version 2.0 (the
        //    "License"); you may not use this file except in
        //    compliance with the License.  You may obtain a copy of
        //    the License at
        //
        //        http://www.apache.org/licenses/LICENSE-2.0
        //
        //    Unless required by applicable law or agreed to in
        //    writing, software distributed under the License is
        //    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
        //    CONDITIONS OF ANY KIND, either express or implied.  See
        //    the License for the specific language governing
        //    permissions and limitations under the License.
        // -------------------------------------------------------------
        //
        
        //----------------------------------------------------------------------
        // Git details (see DEVELOPMENT.md):
        //
        // $File:     src/reg/uvm_reg_file.svh $
        // $Rev:      2026-05-08 07:53:24 -0700 $
        // $Hash:     b79027c3a6650c9072fd2772cb849c270ae4cc85 $
        //
        //----------------------------------------------------------------------
        
        
        // @uvm-ieee 1800.2-2020 auto 18.3.1
        class uvm_reg_file extends uvm_object;
        
           local uvm_reg_block     parent;
           local uvm_reg_file   m_rf;
%000000    local string            default_hdl_path = "RTL";
           local uvm_object_string_pool #(uvm_queue #(string)) hdl_paths_pool;
        
        
%000000    `uvm_object_utils(uvm_reg_file)
        
        
           //----------------------
           // Group -- NODOCS -- Initialization
           //----------------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.2.1
           extern function new(string name="");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.2.2
           extern function void     configure  (uvm_reg_block blk_parent,
                                                uvm_reg_file regfile_parent,
                                                string hdl_path = "");
         
           //---------------------
           // Group -- NODOCS -- Introspection
           //---------------------
        
           //
           // Function -- NODOCS -- get_name
           // Get the simple name
           //
           // Return the simple object name of this register file.
           //
        
           //
           // Function -- NODOCS -- get_full_name
           // Get the hierarchical name
           //
           // Return the hierarchal name of this register file.
           // The base of the hierarchical name is the root block.
           //
           extern virtual function string        get_full_name();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.3.1
           extern virtual function uvm_reg_block get_parent ();
           extern virtual function uvm_reg_block get_block  ();
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.3.2
           extern virtual function uvm_reg_file  get_regfile     ();
        
        
           //----------------
           // Group -- NODOCS -- Backdoor
           //----------------
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.1
           extern function void clear_hdl_path    (string kind = "RTL");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.2
           extern function void add_hdl_path      (string path, string kind = "RTL");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.3
           extern function bit  has_hdl_path      (string kind = "");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.4
           extern function void get_hdl_path      (ref string paths[$], input string kind = "");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.5
           extern function void get_full_hdl_path (ref string paths[$],
                                                   input string kind = "",
                                                   input string separator = ".");
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.7
           extern function void   set_default_hdl_path (string kind);
        
        
           // @uvm-ieee 1800.2-2020 auto 18.3.4.6
           extern function string get_default_hdl_path ();
        
        
           extern virtual function void          do_print (uvm_printer printer);
           extern virtual function string        convert2string();
           extern virtual function uvm_object    clone      ();
           extern virtual function void          do_copy    (uvm_object rhs);
           extern virtual function bit           do_compare (uvm_object  rhs,
                                                             uvm_comparer comparer);
           extern virtual function void          do_pack    (uvm_packer packer);
           extern virtual function void          do_unpack  (uvm_packer packer);
        
        endclass: uvm_reg_file
        
        
        //------------------------------------------------------------------------------
        // IMPLEMENTATION
        //------------------------------------------------------------------------------
        
        
        // new
        
%000000 function uvm_reg_file::new(string name="");
%000000    super.new(name);
%000000    hdl_paths_pool = new("hdl_paths");
        endfunction: new
        
        
        // configure
        
%000000 function void uvm_reg_file::configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent, string hdl_path = "");
%000000    if (blk_parent == null) 
%000000      begin
%000000        `uvm_error("UVM/RFILE/CFG/NOBLK", {"uvm_reg_file::configure() called without a parent block for instance \"", get_name(), "\" of register file type \"", get_type_name(), "\"."})
%000000        return;
             end
        
%000000    this.parent = blk_parent;
%000000    this.parent.add_rf(this);
%000000    this.m_rf = regfile_parent;
%000000    this.add_hdl_path(hdl_path);
        endfunction: configure
        
        
        // get_block
        
%000000 function uvm_reg_block uvm_reg_file::get_block();
%000000    get_block = this.parent;
        endfunction: get_block
        
        
        // get_regfile
        
%000000 function uvm_reg_file uvm_reg_file::get_regfile();
%000000    return m_rf;
        endfunction
        
        
        // clear_hdl_path
        
%000000 function void uvm_reg_file::clear_hdl_path(string kind = "RTL");
%000000   if (kind == "ALL") 
%000000     begin
%000000       hdl_paths_pool = new("hdl_paths");
%000000       return;
            end
        
%000000   if (kind == "") 
%000000     begin
%000000       if (m_rf != null)
%000000       begin
%000000         kind = m_rf.get_default_hdl_path();
              end
        
              else
%000000       begin
%000000         kind = parent.get_default_hdl_path();
              end
        
            end
        
%000000   if (!hdl_paths_pool.exists(kind)) 
%000000     begin
%000000       `uvm_warning("RegModel",{"Unknown HDL Abstraction '",kind,"'"})
%000000       return;
            end
        
%000000   hdl_paths_pool.delete(kind);
        endfunction
        
        
        // add_hdl_path
        
%000000 function void uvm_reg_file::add_hdl_path(string path, string kind = "RTL");
        
%000000   uvm_queue #(string) paths;
        
%000000   paths = hdl_paths_pool.get(kind);
        
%000000   paths.push_back(path);
        
        endfunction
        
        
        // has_hdl_path
        
%000000 function bit  uvm_reg_file::has_hdl_path(string kind = "");
%000000   if (kind == "") 
%000000     begin
%000000       if (m_rf != null)
%000000       begin
%000000         kind = m_rf.get_default_hdl_path();
              end
        
              else
%000000       begin
%000000         kind = parent.get_default_hdl_path();
              end
        
            end
          
%000000   return hdl_paths_pool.exists(kind);
        endfunction
        
        
        // get_hdl_path
        
%000000 function void uvm_reg_file::get_hdl_path(ref string paths[$], input string kind = "");
        
%000000   uvm_queue #(string) hdl_paths;
        
%000000   if (kind == "") 
%000000     begin
%000000       if (m_rf != null)
%000000       begin
%000000         kind = m_rf.get_default_hdl_path();
              end
        
              else
%000000       begin
%000000         kind = parent.get_default_hdl_path();
              end
        
            end
        
%000000   if (!has_hdl_path(kind)) 
%000000     begin
%000000       `uvm_error("RegModel",{"Register does not have hdl path defined for abstraction '",kind,"'"})
%000000       return;
            end
        
%000000   hdl_paths = hdl_paths_pool.get(kind);
        
%000000   for (int i=0; i<hdl_paths.size();i++)
%000000     begin
%000000       paths.push_back(hdl_paths.get(i));
            end
        
        
        endfunction
        
        
        // get_full_hdl_path
        
%000000 function void uvm_reg_file::get_full_hdl_path(ref string paths[$],
                                                      input string kind = "",
                                                      input string separator = ".");
%000000    if (kind == "")
%000000      begin
%000000        kind = get_default_hdl_path();
             end
        
        
%000000    if (!has_hdl_path(kind)) 
%000000      begin
%000000        `uvm_error("RegModel",{"Register file does not have hdl path defined for abstraction '",kind,"'"})
%000000        return;
             end
           
%000000    paths.delete();
        
%000000    begin
%000000      uvm_queue #(string) hdl_paths = hdl_paths_pool.get(kind);
%000000      string parent_paths[$];
        
%000000      if (m_rf != null)
%000000        begin
%000000          m_rf.get_full_hdl_path(parent_paths, kind, separator);
               end
        
%000000      else if (parent != null)
%000000        begin
%000000          parent.get_full_hdl_path(parent_paths, kind, separator);
               end
        
        
%000000      for (int i=0; i<hdl_paths.size();i++) 
%000000        begin
%000000          string hdl_path = hdl_paths.get(i);
        
%000000          if (parent_paths.size() == 0) 
%000000          begin
%000000            if (hdl_path != "")
%000000            begin
%000000              paths.push_back(hdl_path);
                   end
        
        
%000000            continue;
                 end
                 
%000000          foreach (parent_paths[j])  
%000000          begin
%000000            if (hdl_path == "")
%000000            begin
%000000              paths.push_back(parent_paths[j]);
                   end
        
                   else
%000000            begin
%000000              paths.push_back({ parent_paths[j], separator, hdl_path });
                   end
        
                 end
               end
           end
        
        endfunction
        
        
        // get_default_hdl_path
        
%000000 function string uvm_reg_file::get_default_hdl_path();
%000000   if (default_hdl_path == "") 
%000000     begin
%000000       if (m_rf != null)
%000000       begin
%000000         return m_rf.get_default_hdl_path();
              end
        
              else
%000000       begin
%000000         return parent.get_default_hdl_path();
              end
        
            end
%000000   return default_hdl_path;
        endfunction
        
        
        // set_default_hdl_path
        
%000000 function void uvm_reg_file::set_default_hdl_path(string kind);
        
%000000   if (kind == "") 
%000000     begin
%000000       if (m_rf != null)
%000000         begin
%000000           kind = m_rf.get_default_hdl_path();
                end
        
%000000       else if (parent == null)
%000000         begin
%000000           kind = parent.get_default_hdl_path();
                end
        
              else 
%000000       begin
                `uvm_error("RegModel",{"Register file has no parent. ",
%000000         "Must specify a valid HDL abstraction (kind)"})
%000000         return;
              end
            end
        
%000000   default_hdl_path = kind;
        
        endfunction
        
        
        // get_parent
        
%000000 function uvm_reg_block uvm_reg_file::get_parent();
%000000   return get_block();
        endfunction
        
        
        // get_full_name
        
%000000 function string uvm_reg_file::get_full_name();
%000000    uvm_reg_block blk;
        
%000000    get_full_name = this.get_name();
        
           // Is there a parent register file?
%000000    if (m_rf != null)
%000000      begin
%000000        return {m_rf.get_full_name(), ".", get_full_name};
             end
        
        
           // No: then prepend the full name of the parent block (if any)
%000000    if (this.parent == null)
%000000      begin
%000000        return get_full_name;
             end
        
%000000    get_full_name = {this.parent.get_full_name(), ".", get_full_name};
        endfunction: get_full_name
        
        
        //-------------
        // STANDARD OPS
        //-------------
        
        // convert2string
        
%000000 function string uvm_reg_file::convert2string();
%000000   `uvm_fatal("RegModel","RegModel register files cannot be converted to strings")
%000000    return "";
        endfunction: convert2string
        
        
        // do_print
        
%000000 function void uvm_reg_file::do_print (uvm_printer printer);
%000000   super.do_print(printer);
        endfunction
        
        
        
        // clone
        
%000000 function uvm_object uvm_reg_file::clone();
%000000   `uvm_fatal("RegModel","RegModel register files cannot be cloned")
%000000   return null;
        endfunction
        
        // do_copy
        
%000000 function void uvm_reg_file::do_copy(uvm_object rhs);
%000000   `uvm_fatal("RegModel","RegModel register files cannot be copied")
        endfunction
        
        
        // do_compare
        
%000000 function bit uvm_reg_file::do_compare (uvm_object  rhs,
                                                uvm_comparer comparer);
%000000   `uvm_warning("RegModel","RegModel register files cannot be compared")
%000000   return 0;
        endfunction
        
        
        // do_pack
        
%000000 function void uvm_reg_file::do_pack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel register files cannot be packed")
        endfunction
        
        
        // do_unpack
        
%000000 function void uvm_reg_file::do_unpack (uvm_packer packer);
%000000   `uvm_warning("RegModel","RegModel register files cannot be unpacked")
        endfunction
        
