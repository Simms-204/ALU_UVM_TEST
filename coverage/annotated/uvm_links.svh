//      // verilator_coverage annotation
        //
        //-----------------------------------------------------------------------------
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014 Intel Corporation
        // Copyright 2007-2009 Mentor Graphics Corporation
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
        // $File:     src/base/uvm_links.svh $
        // $Rev:      2024-02-08 13:43:04 -0800 $
        // $Hash:     29e1e3f8ee4d4aa2035dba1aba401ce1c19aa340 $
        //
        //----------------------------------------------------------------------
        
        
        // File -- NODOCS -- UVM Links
        //
        // The <uvm_link_base> class, and its extensions, are provided as a mechanism
        // to allow for compile-time safety when trying to establish links between
        // records within a <uvm_tr_database>.
        //
        // 
        
        
        // @uvm-ieee 1800.2-2020 auto 7.3.1.1
        virtual class uvm_link_base extends uvm_object;
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.2
%000000    function new(string name="unnamed-uvm_link_base");
%000000       super.new(name);
           endfunction : new
        
           // Group -- NODOCS --  Accessors
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.3.2
%000000    function void set_lhs(uvm_object lhs);
%000000       do_set_lhs(lhs);
           endfunction : set_lhs
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.3.1
%000000    function uvm_object get_lhs();
%000000       return do_get_lhs();
           endfunction : get_lhs
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.3.4
%000000    function void set_rhs(uvm_object rhs);
%000000       do_set_rhs(rhs);
           endfunction : set_rhs
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.3.3
%000000    function uvm_object get_rhs();
%000000       return do_get_rhs();
           endfunction : get_rhs
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.3.5
%000000    function void set(uvm_object lhs, rhs);
%000000       do_set_lhs(lhs);
%000000       do_set_rhs(rhs);
           endfunction : set
        
           // Group -- NODOCS -- Implementation Callbacks
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.4.2
%000000    pure virtual function void do_set_lhs(uvm_object lhs);
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.4.1
%000000    pure virtual function uvm_object do_get_lhs();
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.4.4
%000000    pure virtual function void do_set_rhs(uvm_object rhs);
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.1.4.3
%000000    pure virtual function uvm_object do_get_rhs();
        
        endclass : uvm_link_base
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_parent_child_link
        //
        // The ~uvm_parent_child_link~ is used to represent a Parent/Child relationship
        // between two objects.
        //
        
        // @uvm-ieee 1800.2-2020 auto 7.3.2.1
        class uvm_parent_child_link extends uvm_link_base;
        
           // Variable- m_lhs,m_rhs
           // Implementation details
           local uvm_object m_lhs;
           local uvm_object m_rhs;
        
           // Object utils
%000000    `uvm_object_utils(uvm_parent_child_link)
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.2.2.1
%000000    function new(string name="unnamed-uvm_parent_child_link");
%000000       super.new(name);
           endfunction : new
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.2.2.2
%000000    static function uvm_parent_child_link get_link(uvm_object lhs,
                                                          uvm_object rhs,
                                                          string name="pc_link");
%000000       process p_;
%000000       string s_;
        
%000000       p_ = process::self();
%000000       if (p_ != null)
%000000         begin
%000000           s_ = p_.get_randstate();
                end
        
              
%000000       get_link = new(name);
        
%000000       if (p_ != null)
%000000         begin
%000000           p_.set_randstate(s_);
                end
        
              
%000000       get_link.set(lhs, rhs);
           endfunction : get_link
           
           // Group -- NODOCS -- Implementation Callbacks
        
           // Function -- NODOCS -- do_set_lhs
           // Sets the left-hand-side (Parent)
           //
%000000    virtual function void do_set_lhs(uvm_object lhs);
%000000       m_lhs = lhs;
           endfunction : do_set_lhs
        
           // Function -- NODOCS -- do_get_lhs
           // Retrieves the left-hand-side (Parent)
           //
%000000    virtual function uvm_object do_get_lhs();
%000000       return m_lhs;
           endfunction : do_get_lhs
        
           // Function -- NODOCS -- do_set_rhs
           // Sets the right-hand-side (Child)
           //
%000000    virtual function void do_set_rhs(uvm_object rhs);
%000000       m_rhs = rhs;
           endfunction : do_set_rhs
        
           // Function -- NODOCS -- do_get_rhs
           // Retrieves the right-hand-side (Child)
           //
%000000    virtual function uvm_object do_get_rhs();
%000000       return m_rhs;
           endfunction : do_get_rhs
        
        endclass : uvm_parent_child_link
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_cause_effect_link
        //
        // The ~uvm_cause_effect_link~ is used to represent a Cause/Effect relationship
        // between two objects.
        //
        
        // @uvm-ieee 1800.2-2020 auto 7.3.3.1
        class uvm_cause_effect_link extends uvm_link_base;
        
           // Variable- m_lhs,m_rhs
           // Implementation details
           local uvm_object m_lhs;
           local uvm_object m_rhs;
        
           // Object utils
%000000    `uvm_object_utils(uvm_cause_effect_link)
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.3.2.1
%000000    function new(string name="unnamed-uvm_cause_effect_link");
%000000       super.new(name);
           endfunction : new
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.3.2.2
%000000    static function uvm_cause_effect_link get_link(uvm_object lhs,
                                                         uvm_object rhs,
                                                         string name="ce_link");
%000000       process p_;
%000000       string s_;
%000000       p_ = process::self();
%000000       if (p_ != null)
%000000         begin
%000000           s_ = p_.get_randstate();
                end
        
              
%000000       get_link = new(name);
        
%000000       if (p_ != null)
%000000         begin
%000000           p_.set_randstate(s_);
                end
        
              
%000000       get_link.set(lhs, rhs);
           endfunction : get_link
           
           // Group -- NODOCS -- Implementation Callbacks
        
           // Function -- NODOCS -- do_set_lhs
           // Sets the left-hand-side (Cause)
           //
%000000    virtual function void do_set_lhs(uvm_object lhs);
%000000       m_lhs = lhs;
           endfunction : do_set_lhs
        
           // Function -- NODOCS -- do_get_lhs
           // Retrieves the left-hand-side (Cause)
           //
%000000    virtual function uvm_object do_get_lhs();
%000000       return m_lhs;
           endfunction : do_get_lhs
        
           // Function -- NODOCS -- do_set_rhs
           // Sets the right-hand-side (Effect)
           //
%000000    virtual function void do_set_rhs(uvm_object rhs);
%000000       m_rhs = rhs;
           endfunction : do_set_rhs
        
           // Function -- NODOCS -- do_get_rhs
           // Retrieves the right-hand-side (Effect)
           //
%000000    virtual function uvm_object do_get_rhs();
%000000       return m_rhs;
           endfunction : do_get_rhs
        
        endclass : uvm_cause_effect_link
        
        //------------------------------------------------------------------------------
        //
        // CLASS -- NODOCS -- uvm_related_link
        //
        // The ~uvm_related_link~ is used to represent a generic "is related" link
        // between two objects.
        //
        
        // @uvm-ieee 1800.2-2020 auto 7.3.4.1
        class uvm_related_link extends uvm_link_base;
        
           // Variable- m_lhs,m_rhs
           // Implementation details
           local uvm_object m_lhs;
           local uvm_object m_rhs;
        
           // Object utils
%000000    `uvm_object_utils(uvm_related_link)
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.4.2.1
%000000    function new(string name="unnamed-uvm_related_link");
%000000       super.new(name);
           endfunction : new
        
        
           // @uvm-ieee 1800.2-2020 auto 7.3.4.2.2
%000000    static function uvm_related_link get_link(uvm_object lhs,
                                                         uvm_object rhs,
                                                         string name="ce_link");
%000000       process p_;
%000000       string s_;
%000000       p_ = process::self();
%000000       if (p_ != null)
%000000         begin
%000000           s_ = p_.get_randstate();
                end
        
              
%000000       get_link = new(name);
        
%000000       if (p_ != null)
%000000         begin
%000000           p_.set_randstate(s_);
                end
        
              
%000000       get_link.set(lhs, rhs);
           endfunction : get_link
           
           // Group -- NODOCS -- Implementation Callbacks
        
           // Function -- NODOCS -- do_set_lhs
           // Sets the left-hand-side
           //
%000000    virtual function void do_set_lhs(uvm_object lhs);
%000000       m_lhs = lhs;
           endfunction : do_set_lhs
        
           // Function -- NODOCS -- do_get_lhs
           // Retrieves the left-hand-side
           //
%000000    virtual function uvm_object do_get_lhs();
%000000       return m_lhs;
           endfunction : do_get_lhs
        
           // Function -- NODOCS -- do_set_rhs
           // Sets the right-hand-side
           //
%000000    virtual function void do_set_rhs(uvm_object rhs);
%000000       m_rhs = rhs;
           endfunction : do_set_rhs
        
           // Function -- NODOCS -- do_get_rhs
           // Retrieves the right-hand-side
           //
%000000    virtual function uvm_object do_get_rhs();
%000000       return m_rhs;
           endfunction : do_get_rhs
        
        endclass : uvm_related_link
        
