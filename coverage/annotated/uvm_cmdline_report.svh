//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2022 AMD
        // Copyright 2007-2024 Cadence Design Systems, Inc.
        // Copyright 2007-2009 Mentor Graphics Corporation
        // Copyright 2020-2024 NVIDIA Corporation
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
        // $File:     src/base/uvm_cmdline_report.svh $
        // $Rev:      2024-07-18 12:43:22 -0700 $
        // $Hash:     c114e948eeee0286b84392c4185deb679aac54b3 $
        //
        //----------------------------------------------------------------------
        
        
        // Command line classes
%000000 class uvm_cmdline_setting_base;
          string    arg; // Original command line option
          bit used[uvm_component]; // Usage tracking
        endclass : uvm_cmdline_setting_base
        
%000000 class uvm_cmdline_verbosity extends uvm_cmdline_setting_base;
          // Instance Methods/Variables
          int verbosity;
          enum {STANDARD, NON_STANDARD, ILLEGAL} src;
          localparam  string prefix = "+UVM_VERBOSITY=";
        
          // Static Methods/Variables
          static uvm_cmdline_verbosity settings[$];
          
          // Function --NODOCS-- init
          // Initializes the ~settings~ queue with the command line verbosity settings.
          //
          // Warnings for incorrectly formatted command line arguments are routed through
          // the report object ~ro~.  If ~ro~ is null, then no warnings shall be generated.
%000003   static function void init(input uvm_report_object ro);
%000003     string  setting_str[$];
%000003     int     verbosity;
%000003     int     verb_count;
%000003     string  verb_string;
%000003     bit     skip;
%000003     uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
        
        `ifndef UVM_CMDLINE_NO_DPI
            // Retrieve the verbosities provided on the command line
            verb_count = clp.get_arg_values(prefix, setting_str);
        `else
%000003     verb_count = $value$plusargs("UVM_VERBOSITY=%s", verb_string);
%000003     if (verb_count)
%000000       setting_str.push_back(verb_string);
        `endif
        
%000003     foreach(setting_str[i]) begin
%000000       uvm_cmdline_verbosity setting;
%000000       uvm_verbosity temp_verb;
%000000       setting = new();
%000000       setting.arg = setting_str[i];
%000000       setting.src = STANDARD;
              
%000000       if (!uvm_string_to_verbosity(setting_str[i], temp_verb)) begin
%000000         int code;
%000000         code = $sscanf(setting_str[i], "%d", setting.verbosity);
%000000         if (code > 0) begin
                  `uvm_info_context("NSTVERB", 
                  $sformatf("Non-standard verbosity value '%s', converted to '%0d'.",
                  setting_str[i], verbosity),
                  UVM_NONE,
%000000           ro)
%000000           setting.src = NON_STANDARD;
                end
%000000         else begin
%000000           setting.verbosity = UVM_MEDIUM;
%000000           setting.src = ILLEGAL;
                end
              end // if (!uvm_string_to_verbosity(setting_str[i], verbosity))
%000000       else begin
%000000         setting.verbosity = temp_verb;
              end
        
%000000       settings.push_back(setting);
            end // foreach (setting_str[i])
        
          endfunction : init
        
          // Function --NODOCS-- check
          // Checks the settings queue for unused verbosity settings.
          //
          // Verbosity could be unused because it wasn't first on the command line.
%000003   static function void check(uvm_report_object ro);
%000003     string verb_q[$];
            
%000003     foreach (settings[i]) begin
%000000       if (settings[i].src == ILLEGAL) begin
                `uvm_warning_context("ILLVERB",
                $sformatf("Illegal verbosity value '%s', converted to default of UVM_MEDIUM.",
                settings[i].arg),
%000000         ro)
              end
%000000       if (i != 0) begin
                
%000000         verb_q.push_back(", ");
              end
        
%000000       verb_q.push_back(settings[i].arg);
            end // foreach (settings[i])
            
%000003     if (settings.size() > 1) begin
              `uvm_warning_context("MULTVERB",
              $sformatf("Multiple (%0d) +UVM_VERBOSITY arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
              settings.size(),
              settings[0].arg, 
              `UVM_STRING_QUEUE_STREAMING_PACK(verb_q)),
%000000       ro);
            end // if (settings.size() > 1)
          endfunction : check
        
          // Function --NODOCS-- dump
          // Dumps the usage information for the verbosity settings as a string.
          //
%000000   static function string dump();
%000000     string msgs[$];
%000000     int    tmp_verb;
        
%000000     foreach (settings[i]) begin
%000000       msgs.push_back($sformatf("\n%s%s: ", prefix, settings[i].arg));
%000000       if (i == 0) begin
                
%000000         msgs.push_back("Applied");
              end
        
%000000       else begin
                
%000000         msgs.push_back("Not applied (not first on command line)");
              end
        
%000000       if (settings[i].src == NON_STANDARD) begin
                
%000000         msgs.push_back($sformatf(", converted as non-standard to '%0d'", settings[i].verbosity));
              end
         
%000000       else if (settings[i].src == ILLEGAL) begin
                
%000000         msgs.push_back(", converted as ILLEGAL to UVM_MEDIUM");
              end
        
            end // foreach (settings[i])
        
%000000     return `UVM_STRING_QUEUE_STREAMING_PACK(msgs);
          endfunction : dump
        
        endclass : uvm_cmdline_verbosity
        
        
            
%000000 class uvm_cmdline_set_verbosity extends uvm_cmdline_setting_base;
          // Instance Methods/Variables
          string    comp;
          string    id;
          int       verbosity;
          string    phase;
          time      offset;
        
          localparam  string prefix = "+uvm_set_verbosity="; 
          // Static Methods/Variables    
          static uvm_cmdline_set_verbosity settings[$]; // Processed command line settings
        
          
          // Function --NODOCS-- init
          // Initializes the ~settings~ queue with the command line verbosity settings.
          //
          // Warnings for incorrectly formatted command line arguments are routed through
          // the report object ~ro~.  If ~ro~ is null, then no warnings shall be generated.
%000003   static function void init(input uvm_report_object ro);
%000003     string  setting_str[$];
%000003     uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
        
%000003     if (clp.get_arg_values(prefix, setting_str) > 0) begin
%000000       uvm_verbosity temp_verb;
%000000       string  args[$];
%000000       string  message;
%000000       bit     skip;
               
%000000       foreach(setting_str[i]) begin
%000000         skip = 0;
%000000         uvm_string_split(setting_str[i], ",", args);
%000000         if (args.size() < 4 || args.size() > 5) begin
%000000           message = "Invalid number of arguments found, expected 4 or 5";
%000000           skip = 1;
                end
%000000         if (args.size() == 5 && args[3] != "time") begin
%000000           message = "Too many arguments found for <phase>, expected only 4";
%000000           skip = 1;
                end
%000000         if (args.size() == 4 && args[3] == "time") begin
%000000           message = "Too few arguments found for <time>, expected 5";
%000000           skip = 1;
                end
%000000         if (!uvm_string_to_verbosity(args[2], temp_verb)) begin
%000000           message = "Invalid verbosity found";
%000000           skip = 1;
                end
                
%000000         if (!skip) begin
%000000           int rt_val;
%000000           uvm_cmdline_set_verbosity setting;
%000000           setting = new();
%000000           setting.arg = setting_str[i];
%000000           setting.comp = args[0];
%000000           setting.id = args[1];
%000000           setting.verbosity = temp_verb;
%000000           setting.phase = args[3];
%000000           if (setting.phase == "time") begin
%000000             rt_val = $sscanf(args[4], "%d", setting.offset);
                  end
%000000           else begin
                    
%000000             setting.offset = 0;
                  end
        
%000000           settings.push_back(setting);
                end // if (!skip)
%000000         else if (ro != null) begin
                  `uvm_warning_context("INVLCMDARGS",
                  $sformatf("%s, setting '%s%s' will be ignored.",
                  message,
                  prefix,
                  setting_str[i]),
%000000           ro)
                end          
              end // foreach (setting_string[i])
            end // if (clp.get_arg_values(prefix, setting_string) > 0)
            
          endfunction : init
        
          // Function --NODOCS-- check
          // Checks the settings queue for unused verbosity settings.
          //
          // Verbosity could be unused because:
          //   a) It didn't match any components
          //   b) The ~offset~ specified hasn't occurred yet
          //   c) The ~phase~ specified hasn't occurred yet
%000003   static function void check(uvm_report_object ro);
%000003     foreach (settings[i]) begin
%000000       if (settings[i].used.size() == 0) begin
                // Warn if we didn't match any components
                `uvm_warning_context("INVLCMDARGS",
                $sformatf("\"%s%s\" never took effect due to either a mismatching component pattern.",
                prefix,
                settings[i].arg),
%000000         ro)
              end
%000000       else begin
%000000         if (settings[i].phase == "time") begin
%000000           if ($time < settings[i].offset) begin
                    // Warn if we haven't hit the time yet
                    `uvm_warning_context("INVLCMDARGS",
                    $sformatf("\"%s%s\" never took effect due to test ending before offset was reached.",
                    prefix,
                    settings[i].arg),
%000000             ro)
                  end
                end
%000000         else begin
%000000           bit hit;
%000000           uvm_cmdline_set_verbosity setting;
%000000           setting = settings[i];
%000000           foreach (setting.used[i]) begin
%000000             if (setting.used[i]) begin
%000000               hit = 1;
%000000               break;
                    end
                  end // foreach (setting.used[i])
                  
%000000           if (!hit) begin
                    // Warn if all our matching components never saw ~phase~
                    `uvm_warning_context("INVLCMDARGS",
                    $sformatf("\"%s%s\" never took effect due to phase never occurring for matching component(s).",
                    prefix,
                    settings[i].arg),
%000000             ro)
                  end
                end // else: !if(settings[i].phase == "time")
              end // else: !if(settings[i].used.size() == 0)
            end // foreach (settings[i])
            
          endfunction : check
          
          // Function --NODOCS-- dump
          // Dumps the usage information for the verbosity settings as a string.
          //
%000000   static function string dump();
%000000     string msgs[$];
%000000     uvm_component sorted_list[$];
%000000     foreach (settings[i]) begin
%000000       uvm_cmdline_set_verbosity setting;
%000000       setting = settings[i];
%000000       msgs.push_back($sformatf("\n%s%s", prefix, setting.arg));
%000000       msgs.push_back("\n  matching components:");
%000000       if (setting.used.size() == 0) begin
                
%000000         msgs.push_back("\n    <none>");
              end
        
%000000       else begin
%000000         sorted_list.delete();
%000000         foreach (setting.used[j]) begin
                  
%000000           sorted_list.push_back(j);
                end
        
%000000         sorted_list.sort() with ( item.get_full_name() );
%000000         foreach (sorted_list[j]) begin
%000000           string full_name;
%000000           full_name = sorted_list[j].get_full_name();
%000000           if (full_name == "") begin
                    
%000000             full_name = "<uvm_root>";
                  end
        
%000000           msgs.push_back("\n    ");
%000000           msgs.push_back(full_name);
%000000           msgs.push_back(": ");
%000000           if ((setting.phase == "time" && setting.used[sorted_list[j]]) ||
%000000           (setting.phase != "time" && setting.used[sorted_list[j]])) begin
                    
%000000             msgs.push_back("Applied");
                  end
        
%000000           else begin
%000000             msgs.push_back("Not applied ");
%000000             if (setting.phase == "time") begin
                      
%000000               msgs.push_back("(component never reached offset)");
                    end
        
%000000             else begin
                      
%000000               msgs.push_back("(component never saw phase)");
                    end
        
                  end
                end // foreach (setting.used[j])
              end // else: !if(setting.used.size() == 0)
            end // foreach (settings[i])
        
%000000     return `UVM_STRING_QUEUE_STREAMING_PACK(msgs);
          endfunction : dump
            
        endclass // uvm_cmdline_set_verbosity
        
%000000 class uvm_cmdline_set_action extends uvm_cmdline_setting_base;
          // Instance Methods/Variables
          string    comp;
          string    id;
          bit       all_sev;
          uvm_severity sev;
          uvm_action action;
        
          localparam  string prefix = "+uvm_set_action="; 
          
          // Static Methods/Variables
          static uvm_cmdline_set_action settings[$]; // Processed command line settings
          
          // Function --NODOCS-- init
          // Initializes the ~settings~ queue with the command line action settings.
          //
          // Warnings for incorrectly formatted command line arguments are routed through
          // the report object ~ro~.  If ~ro~ is null, then no warnings shall be generated.
%000003   static function void init(input uvm_report_object ro);
%000003     string  setting_str[$];
%000003     uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
            
%000003     if (clp.get_arg_values(prefix, setting_str) > 0) begin
%000000       uvm_action action;
%000000       uvm_severity sev;
%000000       string  args[$];
%000000       string  message;
%000000       bit     skip;
        
%000000       foreach(setting_str[i]) begin
%000000         skip = 0;
%000000         uvm_string_split(setting_str[i], ",", args);
%000000         if (args.size() != 4) begin
%000000           message = "Invalid number of arguments found, expected 4";
%000000           skip = 1;
                end
%000000         if (args[2] != "_ALL_" && !uvm_string_to_severity(args[2], sev)) begin
%000000           message = $sformatf("Bad severity argument '%s'", args[2]);
%000000           skip = 1;
                end
%000000         if (!uvm_string_to_action(args[3], action)) begin
%000000           message = $sformatf("Bad action argument '%s'", args[3]);
%000000           skip = 1;
                end
        
%000000         if (!skip) begin
%000000           uvm_cmdline_set_action setting;
%000000           setting = new();
%000000           setting.arg = setting_str[i];
%000000           setting.comp = args[0];
%000000           setting.id = args[1];
%000000           setting.all_sev = (args[2] == "_ALL_");
%000000           setting.sev = sev;
%000000           setting.action = action;
        
%000000           settings.push_back(setting);
                end // if (!skip)
%000000         else if (ro != null) begin
                  `uvm_warning_context("INVLCMDARGS", 
                  $sformatf("%s, setting '%s%s' will be ignored.",
                  message,
                  prefix,
                  setting_str[i]),
%000000           ro)
                end
              end // foreach (setting_str[i])
            end // if (clp.get_arg_values(prefix, setting_str) > 0)
            
          endfunction : init
        
          // Function --NODOCS-- check
          // Checks the settings queue for unused action settings.
          //
          // Verbosity could be unused because:
          //   a) It didn't match any components
%000003   static function void check(uvm_report_object ro);
%000003     foreach(settings[i]) begin
%000000       if (settings[i].used.size() == 0) begin
                `uvm_warning_context("INVLCMDARGS",
                $sformatf("\"%s%s\" never took effect due to a mismatching component pattern",
                prefix,
                settings[i].arg),
%000000         ro)
              end
            end
          endfunction : check
          
          // Function --NODOCS-- dump
          // Dumps the usage information for the verbosity settings as a string.
          //
%000000   static function string dump();
%000000     string msgs[$];
%000000     uvm_component sorted_list[$];
%000000     foreach (settings[i]) begin
%000000       uvm_cmdline_set_action setting;
%000000       setting = settings[i];
%000000       msgs.push_back($sformatf("\n%s%s", prefix, setting.arg));
%000000       msgs.push_back("\n  matching components:");
%000000       if (setting.used.size() == 0) begin
                
%000000         msgs.push_back("\n    <none>");
              end
        
%000000       else begin
%000000         sorted_list.delete();
%000000         foreach (setting.used[j]) begin
                  
%000000           sorted_list.push_back(j);
                end
        
%000000         sorted_list.sort() with ( item.get_full_name() );
%000000         foreach (sorted_list[j]) begin
%000000           string full_name;
%000000           full_name = sorted_list[j].get_full_name();
%000000           if (full_name == "") begin
                    
%000000             full_name = "<uvm_root>";
                  end
        
%000000           msgs.push_back("\n    ");
%000000           msgs.push_back(full_name);
%000000           msgs.push_back(": Applied");
                end // foreach (setting.used[j])
              end // else: !if(setting.used.size() == 0)
            end // foreach (settings[i])
        
%000000     return `UVM_STRING_QUEUE_STREAMING_PACK(msgs);
          endfunction : dump
        
        endclass : uvm_cmdline_set_action
        
%000000 class uvm_cmdline_set_severity extends uvm_cmdline_setting_base;
          // Instance Methods/Variables
          string    comp;
          string    id;
          bit       all_sev;
          uvm_severity orig_sev;
          uvm_severity sev;
        
          localparam string prefix="+uvm_set_severity=";
          
          // Static Methods/Variables
          static uvm_cmdline_set_severity settings[$]; // Processed command line settings
          
          // Function --NODOCS-- init
          // Initializes the ~settings~ queue with the command line severity settings.
          //
          // Warnings for incorrectly formatted command line arguments are routed through
          // the report object ~ro~.  If ~ro~ is null, then no warnings shall be generated.
%000003   static function void init(input uvm_report_object ro);
%000003     string  setting_str[$];
%000003     uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
            
%000003     if (clp.get_arg_values(prefix, setting_str) > 0) begin
%000000       uvm_severity orig_sev, sev;
%000000       string  args[$];
%000000       string  message;
%000000       bit     skip;
        
%000000       foreach(setting_str[i]) begin
%000000         skip = 0;
%000000         uvm_string_split(setting_str[i], ",", args);
%000000         if (args.size() != 4) begin
%000000           message = "Invalid number of arguments found, expected 4";
%000000           skip = 1;
                end
%000000         if (args[2] != "_ALL_" && !uvm_string_to_severity(args[2], orig_sev)) begin
%000000           message = $sformatf("Bad severity argument '%s'", args[2]);
%000000           skip = 1;
                end
%000000         if (!uvm_string_to_severity(args[3], sev)) begin
%000000           message = $sformatf("Bad severity argument '%s'", args[3]);
%000000           skip = 1;
                end
        
%000000         if (!skip) begin
%000000           uvm_cmdline_set_severity setting;
%000000           setting = new();
%000000           setting.arg = setting_str[i];
%000000           setting.comp = args[0];
%000000           setting.id = args[1];
%000000           setting.all_sev = (args[2] == "_ALL_");
%000000           setting.orig_sev = orig_sev;
%000000           setting.sev = sev;
%000000           settings.push_back(setting);
                end // if (!skip)
%000000         else if (ro != null) begin
                  `uvm_warning_context("INVLCMDARGS", 
                  $sformatf("%s, setting '%s%s' will be ignored.",
                  message, 
                  prefix,
                  setting_str[i]),
%000000           ro)
                end
              end // foreach (setting_str[i])
            end // if (clp.get_arg_values(prefix, setting_str) > 0)
          endfunction : init
        
            
          // Function --NODOCS-- check
          // Checks the settings queue for unused action settings.
          //
          // Verbosity could be unused because:
          //   a) It didn't match any components
%000003   static function void check(uvm_report_object ro);
%000003     foreach(settings[i]) begin
%000000       if (settings[i].used.size() == 0) begin
                `uvm_warning_context("INVLCMDARGS",
                $sformatf("\"%s%s\" never took effect due to a mismatching component pattern",
                prefix,
                settings[i].arg),
%000000         ro)
              end
            end
          endfunction : check
          
          // Function --NODOCS-- dump
          // Dumps the usage information for the verbosity settings as a string.
          //
%000000   static function string dump();
%000000     string msgs[$];
%000000     uvm_component sorted_list[$];
%000000     foreach (settings[i]) begin
%000000       uvm_cmdline_set_severity setting;
%000000       setting = settings[i];
%000000       msgs.push_back($sformatf("\n%s%s", prefix, setting.arg));
%000000       msgs.push_back("\n  matching components:");
%000000       if (setting.used.size() == 0) begin
                
%000000         msgs.push_back("\n    <none>");
              end
        
%000000       else begin
%000000         sorted_list.delete();
%000000         foreach (setting.used[j]) begin
                  
%000000           sorted_list.push_back(j);
                end
        
%000000         sorted_list.sort() with ( item.get_full_name() );
%000000         foreach (sorted_list[j]) begin
%000000           string full_name;
%000000           full_name = sorted_list[j].get_full_name();
%000000           if (full_name == "") begin
                    
%000000             full_name = "<uvm_root>";
                  end
        
%000000           msgs.push_back("\n    ");
%000000           msgs.push_back(full_name);
%000000           msgs.push_back(": Applied");
                end // foreach (setting.used[j])
              end // else: !if(setting.used.size() == 0)
            end // foreach (settings[i])
        
%000000     return `UVM_STRING_QUEUE_STREAMING_PACK(msgs);
          endfunction : dump
            
        
        endclass : uvm_cmdline_set_severity
        
