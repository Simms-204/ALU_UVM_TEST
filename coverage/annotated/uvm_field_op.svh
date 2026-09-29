//      // verilator_coverage annotation
        //----------------------------------------------------------------------
        // Copyright 2018 Cadence Design Systems, Inc.
        // Copyright 2018 Cisco Systems, Inc.
        // Copyright 2026 Microsoft
        // Copyright 2018-2026 NVIDIA Corporation
        // Copyright 2018 Synopsys, Inc.
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
        // $File:     src/base/uvm_field_op.svh $
        // $Rev:      2026-06-10 09:59:36 -0700 $
        // $Hash:     d69bd29b12f83a7fb6866ad5fd1247d0968f1bca $
        //
        //----------------------------------------------------------------------
        
        
        //------------------------------------------------------------------------------
        // Class - uvm_field_op
        //
        // uvm_field_op is the UVM class for describing all operations supported by the do_execute_op function
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 5.7.1
        class uvm_field_op extends uvm_object;
        
%000000    `uvm_object_utils(uvm_field_op)
        
           local uvm_policy m_policy;
           local bit m_user_hook;
           local uvm_object m_object;
           // Bit m_is_set is set when the set() method is called and acts
           // like a state variable. It is cleared when flush is called.
           local bit m_is_set;
           local  uvm_field_flag_t m_op_type;
        
        
           // Function -- new
           //
           // Creates a policy with the specified instance name. If name is not provided, then the policy instance is
           // unnamed.
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.1
~000018    function new (string name="");
 000018       super.new(name);
 000018       m_is_set = 1'b0;
 000018       m_user_hook = 1'b1;
           endfunction
        
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.2
 008602    virtual function void set( uvm_field_flag_t op_type, uvm_policy policy = null, uvm_object rhs = null);
 008602       uvm_field_flag_t flag_check;
        
 008602       flag_check = (op_type & ( UVM_COPY | UVM_COMPARE | UVM_PRINT | UVM_RECORD | UVM_PACK | UVM_UNPACK | UVM_SET));
        
~008602       if (flag_check & !$onehot(flag_check)) begin
%000000          string msg_queue[$];
        
%000000          msg_queue.push_back("(");
        
%000000          if (op_type & UVM_COPY) begin
%000000             msg_queue.push_back("UVM_COPY");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_COMPARE) begin
%000000             msg_queue.push_back("UVM_COMPARE");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_PRINT) begin
%000000             msg_queue.push_back("UVM_PRINT");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_RECORD) begin
%000000             msg_queue.push_back("UVM_RECORD");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_PACK) begin
%000000             msg_queue.push_back("UVM_PACK");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_UNPACK) begin
%000000             msg_queue.push_back("UVM_UNPACK");
%000000             msg_queue.push_back(",");
                 end
        
%000000          if (op_type & UVM_SET) begin
%000000             msg_queue.push_back("UVM_SET");
%000000             msg_queue.push_back(",");
                 end
%000000          msg_queue[$] = ")";
%000000          `uvm_error("UVM/FIELD_OP/SET_BAD_OP_TYPE", {"set() was passed op_type matching multiple operations: ", `UVM_STRING_QUEUE_STREAMING_PACK(msg_queue)})
              end
~008602       if(m_is_set == 0) begin
 008602          m_op_type = op_type;
 008602          m_policy = policy;
 008602          m_object = rhs;
 008602          m_is_set = 1'b1;
              end
%000000       else begin
%000000          `uvm_error("UVM/FIELD_OP/SET","Attempting to set values in policy without flushing")
              end
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.3
%000000    virtual function string get_op_name();
%000000       case(m_op_type)
%000000         UVM_COPY : begin
%000000           return "copy";
                end
        
%000000         UVM_COMPARE : begin
%000000           return "compare";
                end
        
%000000         UVM_PRINT : begin
%000000           return "print";
                end
        
%000000         UVM_RECORD : begin
%000000           return "record";
                end
        
%000000         UVM_PACK : begin
%000000           return "pack";
                end
        
%000000         UVM_UNPACK : begin
%000000           return "unpack";
                end
        
%000000         UVM_SET : begin
%000000           return "set";
                end
        
%000000         default: begin
%000000           return "";
                end
        
              endcase
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.4
 008602    virtual function uvm_field_flag_t get_op_type();
%000000       if(m_is_set == 1'b1) begin
        
%000000         return m_op_type;
              end
        
%000000       else begin
%000000         `uvm_error("UVM/FIELD_OP/GET_OP_TYPE","Calling get_op_type() before calling set() is not allowed")
              end
           endfunction
        
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.5
 008572    virtual function uvm_policy get_policy();
%000000       if(m_is_set == 1'b1) begin
        
%000000         return m_policy;
              end
        
%000000       else begin
%000000         `uvm_error("UVM/FIELD_OP/GET_POLICY","Attempting to call get_policy() before calling set() is not allowed")
              end
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.6
 016964    virtual function uvm_object get_rhs();
%000000       if(m_is_set == 1'b1) begin
        
%000000         return m_object;
              end
        
%000000       else begin
%000000         `uvm_error("UVM/FIELD_OP/GET_RHS","Calling get_rhs() before calling set() is not allowed")
              end
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.7
 008572    function bit user_hook_enabled();
%000000       if(m_is_set == 1'b1) begin
        
%000000         return m_user_hook;
              end
        
%000000       else begin
%000000         `uvm_error("UVM/FIELD_OP/GET_USER_HOOK","Attempting to get_user_hook before calling set() is not allowed")
              end
           endfunction
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.8
%000000    function void disable_user_hook();
%000000       m_user_hook = 1'b0;
           endfunction
        
           static uvm_field_op m_recycled_op[$] ;
        
           // @uvm-ieee 1800.2-2020 auto 5.7.2.9
 008602    virtual function void flush();
 008602       m_policy = null;
 008602       m_object = null;
 008602       m_user_hook = 1'b1;
 008602       m_is_set = 0;
           endfunction
        
           // API for reusing uvm_field_op instances.  Implementation
           // artifact, should not be used directly by the user.
 008602    function void m_recycle();
 008602      this.flush();
 008602      m_recycled_op.push_back(this);
           endfunction : m_recycle
        
 008602    static function uvm_field_op m_get_available_op() ;
 008602       uvm_field_op field_op ;
 008584       if (m_recycled_op.size() > 0) begin
 008584         field_op = m_recycled_op.pop_back() ;
              end
        
 000018       else begin
 000018         field_op = uvm_field_op::type_id::create("field_op");
              end
        
 008602       return field_op ;
           endfunction
        endclass
        
