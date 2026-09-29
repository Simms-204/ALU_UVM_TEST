//      // verilator_coverage annotation
        // DESCRIPTION: Verilator: built-in packages and classes
        //
        // Code available from: https://verilator.org
        //
        //*************************************************************************
        //
        // This program is free software; you can redistribute it and/or modify it
        // under the terms of either the GNU Lesser General Public License Version 3
        // or the Perl Artistic License Version 2.0.
        // SPDX-FileCopyrightText: 2022-2026 Wilson Snyder
        // SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0
        //
        //*************************************************************************
        ///
        /// \file
        /// \brief Verilated IEEE std:: header
        ///
        /// This file is included automatically by Verilator, unless '--no-std-package'
        /// is used.
        ///
        /// This file is not part of the Verilated public-facing API.
        /// It is only for internal use.
        ///
        //*************************************************************************
        //
        // The following keywords from this file are hardcoded for detection in the parser:
        // "mailbox", "process", "randomize", "semaphore", "std"
        
        `ifndef VERILATOR_STD_SV_
        `define VERILATOR_STD_SV_
        
        // verilator lint_off DECLFILENAME
        // verilator lint_off TIMESCALEMOD
        // verilator lint_off UNUSEDSIGNAL
        package std;
          // IEEE 1800-specified standard "mailbox"
          class mailbox #(
              type T
          );
            protected int m_bound;
            protected T m_queue[$];
        
~000012     function new(int bound = 0);
~000012       m_bound = bound;
            endfunction
        
~007482     function int num();
~007482       return m_queue.size();
            endfunction
        
%000000     task put(T message);
        `ifdef VERILATOR_TIMING
%000000       while (m_bound != 0 && m_queue.size() >= m_bound)  //
%000000         wait (m_queue.size() < m_bound);
%000000       m_queue.push_back(message);
        `endif
            endtask
        
~003741     function int try_put(T message);
~002494       if (m_bound == 0 || num() < m_bound) begin
%000000         m_queue.push_back(message);
%000000         return 1;
              end
~003741       return 0;
            endfunction
        
~002494     task get(ref T message);
        `ifdef VERILATOR_TIMING
~002494       while (m_queue.size() == 0) begin
~002494         wait (m_queue.size() > 0);
              end
~002494       message = m_queue.pop_front();
        `endif
            endtask
        
~001247     function int try_get(ref T message);
%000000       if (num() > 0) begin
%000000         message = m_queue.pop_front();
%000000         return 1;
              end
~001247       return 0;
            endfunction
        
~001247     task peek(ref T message);
        `ifdef VERILATOR_TIMING
%000000       while (m_queue.size() == 0) begin
%000000         wait (m_queue.size() > 0);
              end
~001247       message = m_queue[0];
        `endif
            endtask
        
%000000     function int try_peek(ref T message);
%000000       if (num() > 0) begin
%000000         message = m_queue[0];
%000000         return 1;
              end
%000000       return 0;
            endfunction
          endclass
        
          // IEEE 1800-specified standard "semaphore"
          class semaphore;
            protected int m_keyCount;
%000003     protected int m_nextKeyCount = '1;
%000003     protected longint unsigned m_ticket = 0;
%000003     protected longint unsigned m_nextTicket = 0;
        
%000003     function new(int keyCount = 0);
%000003       m_keyCount = keyCount;
            endfunction
        
%000003     function void put(int keyCount = 1);
%000003       m_keyCount += keyCount;
            endfunction
        
%000000     task get(int keyCount = 1);
        `ifdef VERILATOR_TIMING
%000000       longint unsigned ticket;
              // Fast path: take if keys fit AND either no one is queued, or
              // the head still doesn't fit (so we're not stealing its keys).
%000000       if (m_keyCount >= keyCount && m_nextKeyCount > m_keyCount) begin
%000000         m_keyCount -= keyCount;
%000000         return;
              end
%000000       ticket = m_nextTicket++;
%000000       wait (m_ticket == ticket);
%000000       m_nextKeyCount = keyCount;
%000000       wait (m_keyCount >= keyCount);
%000000       m_keyCount -= keyCount;
%000000       m_ticket++;
        `endif
            endtask
        
%000003     function int try_get(int keyCount = 1);
%000003       if (m_keyCount < keyCount) return 0;
%000003       m_keyCount -= keyCount;
%000003       return 1;
            endfunction
          endclass
        
          // IEEE 1800-specified standard "process"
 051263   class process;
            typedef enum {
              FINISHED = 0,
              RUNNING = 1,
              WAITING = 2,
              SUSPENDED = 3,
              KILLED = 4
            } state;
        
            // Width visitor changes it to VlProcessRef
            // V3Name is hardcoded not to rename this variable
            protected chandle m_process;
        
 048680     static function process self();
 048680       process p = new;
        `ifdef VERILATOR_TIMING
 048680       $c(p.m_process, " = vlProcess;");
        `endif
 048680       return p;
            endfunction
        
 001289     protected function void set_status(state s);
        `ifdef VERILATOR_TIMING
 001289       $c(m_process, "->state(", s, ");");
        `endif
            endfunction
        
 006247     function state status();
        `ifdef VERILATOR_TIMING
 006247       return state'($cpure(m_process, "->state()"));
        `else
              return RUNNING;
        `endif
            endfunction
        
 001289     function void kill();
 001289       set_status(KILLED);
            endfunction
        
            function void suspend();
              $error("std::process::suspend() not supported");
            endfunction
        
%000000     function void resume();
%000000       set_status(RUNNING);
            endfunction
        
%000000     task await();
        `ifdef VERILATOR_TIMING
%000000       wait (status() == FINISHED || status() == KILLED);
        `endif
            endtask
        
%000000     static task killQueue(ref process processQueue[$]);
        `ifdef VERILATOR_TIMING
%000000       repeat (processQueue.size()) begin
%000000         process p = processQueue.pop_front();
%000000         if (p) p.kill();
              end
        `endif
            endtask
        
            // Two process references are equal if the different classes' containing
            // m_process are equal. Can't yet use <=> as the base class template
            // comparisons doesn't define <=> as they don't yet require --timing and C++20.
            // verilog_format: off
        `ifdef VERILATOR_TIMING
        `systemc_header_post
        template<> template<>
        inline bool VlClassRef<`systemc_class_name>::operator==(const VlClassRef<`systemc_class_name>& rhs) const {
            if (!m_objp && !rhs.m_objp) return true;
            if (!m_objp || !rhs.m_objp) return false;
            return m_objp->m_process == rhs.m_objp->m_process;
        };
        template<> template<>
        inline bool VlClassRef<`systemc_class_name>::operator!=(const VlClassRef<`systemc_class_name>& rhs) const {
            if (!m_objp && !rhs.m_objp) return false;
            if (!m_objp || !rhs.m_objp) return true;
            return m_objp->m_process != rhs.m_objp->m_process;
        };
        template<> template<>
        inline bool VlClassRef<`systemc_class_name>::operator<(const VlClassRef<`systemc_class_name>& rhs) const {
            if (!m_objp && !rhs.m_objp) return false;
            if (!m_objp || !rhs.m_objp) return false;
            return m_objp->m_process < rhs.m_objp->m_process;
        };
        `verilog
        `endif
            // verilog_format: on
        
 013925     function string get_randstate();
              // Initialize with $c to ensure it won't be constified
 013925       string s = string'($c("0"));
        
 013925       $c(s, " = ", m_process, "->randstate();");
 013925       return s;
            endfunction
        
 013925     function void set_randstate(string s);
 013925       $c(m_process, "->randstate(", s, ");");
            endfunction
          endclass
        
          // IEEE 1800-specified standard "std::randomize"
%000000   function int randomize();
%000000     randomize = 0;
          endfunction
        
          // IEEE 1800-2023 19.10 coverage option and type_options
          // IEEE does not define these as std:: structures but Verilator uses
          // them as such currently, so named with a unique prefix
          typedef struct {
            string name;
            int weight;
            int goal;
            string comment;
            int at_least;
            int auto_bin_max;
            int cross_num_print_missing;
            bit cross_retain_auto_bins;
            bit detect_overlap;
            bit per_instance;
            bit get_inst_coverage;
          } vl_covergroup_options_t;
        
          typedef struct {
            int weight;
            int goal;
            string comment;
            int at_least;
            int auto_bin_max;
            bit detect_overlap;
          } vl_coverpoint_options_t;
        
          typedef struct {
            int weight;
            int goal;
            string comment;
            int at_least;
            int cross_num_print_missing;
            bit cross_retain_auto_bins;
          } vl_cross_options_t;
        
          typedef struct {
            int weight;
            int goal;
            string comment;
            bit strobe;
            bit merge_instances;
            bit distribute_first;
            real real_interval;
          } vl_covergroup_type_options_t;
        
          typedef struct {
            int weight;
            int goal;
            string comment;
            real real_interval;
          } vl_coverpoint_type_options_t;
        
          typedef struct {
            int weight;
            int goal;
            string comment;
          } vl_cross_type_options_t;
        
        endpackage
        
        `endif  // Guard
        
