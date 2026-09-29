//      // verilator_coverage annotation
        //
        //------------------------------------------------------------------------------
        // Copyright 2012-2022 AMD
        // Copyright 2007-2018 Cadence Design Systems, Inc.
        // Copyright 2014-2018 Cisco Systems, Inc.
        // Copyright 2017 Intel Corporation
        // Copyright 2022-2024 Marvell International Ltd.
        // Copyright 2007-2021 Mentor Graphics Corporation
        // Copyright 2013-2024 NVIDIA Corporation
        // Copyright 2014 Semifore
        // Copyright 2010-2014 Synopsys, Inc.
        // Copyright 2013 Verilab
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
        // $File:     src/base/uvm_misc.svh $
        // $Rev:      2024-07-18 12:43:22 -0700 $
        // $Hash:     c114e948eeee0286b84392c4185deb679aac54b3 $
        //
        //----------------------------------------------------------------------
        
        
        // File -- NODOCS -- Miscellaneous Structures
        
        //------------------------------------------------------------------------------
        //
        // Class -- NODOCS -- uvm_void
        //
        // The ~uvm_void~ class is the base class for all UVM classes. It is an abstract
        // class with no data members or functions. It allows for generic containers of
        // objects to be created, similar to a void pointer in the C programming
        // language. User classes derived directly from ~uvm_void~ inherit none of the
        // UVM functionality, but such classes may be placed in ~uvm_void~-typed
        // containers along with other UVM objects.
        //
        //------------------------------------------------------------------------------
        
        // @uvm-ieee 1800.2-2020 auto 5.2
 047379 virtual class uvm_void;
        endclass
        
        // Append/prepend symbolic values for order-dependent APIs
        typedef enum {UVM_APPEND, UVM_PREPEND} uvm_apprepend;
        
        // Forward declaration since scope stack uses uvm_objects now
        typedef class uvm_object;
        
        typedef class uvm_coreservice_t;
        typedef class uvm_factory;
        
        typedef class uvm_config_db;
        // m_uvm_config_obj_misc is an internal typedef for the uvm_misc.svh file
        // to use. UVM users should use the uvm_config_object typedef
        typedef uvm_config_db#(uvm_object) m_uvm_config_obj_misc;
        
        
        typedef class uvm_comparer ;
        typedef class uvm_packer ;
        typedef class uvm_recorder ;
        typedef class uvm_printer ;
        
        // Variable- uvm_global_random_seed
        //
        // Create a seed which is based off of the global seed which can be used to seed
        // srandom processes but will change if the command line seed setting is 
        // changed.
        //
%000003 int unsigned uvm_global_random_seed = $urandom;
        
        
        // Class- uvm_seed_map
        //
        // This map is a seed map that can be used to update seeds. The update
        // is done automatically by the seed hashing routine. The seed_table_lookup
        // uses an instance name lookup and the seed_table inside a given map
        // uses a type name for the lookup.
        //
 000151 class uvm_seed_map;
          int unsigned seed_table [string];
          int unsigned count [string];
        endclass
        
        uvm_seed_map uvm_random_seed_table_lookup [string];
        
        
        //------------------------------------------------------------------------------
        // Internal utility functions
        //------------------------------------------------------------------------------
        
        // Function- uvm_instance_scope
        //
        // A function that returns the scope that the UVM library lives in, either
        // an instance, a module, or a package.
        //
 003953 function string uvm_instance_scope();
 003953   byte c;
 003953   int pos;
          //first time through the scope is ~null~ and we need to calculate, afterwards it
          //is correctly set.
        
~001433   if(uvm_instance_scope != "") begin 
            
%000000     return uvm_instance_scope;
          end
        
        
 003953   $swrite(uvm_instance_scope, "%m");
          //remove the extraneous .uvm_instance_scope piece or ::uvm_instance_scope
 003953   pos = uvm_instance_scope.len()-1;
 003953   c = uvm_instance_scope[pos];
 025794   while(pos && (c != ".") && (c != ":")) begin 
            
 025794     c = uvm_instance_scope[--pos];
          end
        
~001433   if(pos == 0) begin
            
%000000     uvm_report_error("SCPSTR", $sformatf("Illegal name %s in scope string",uvm_instance_scope));
          end
        
 003953   uvm_instance_scope = uvm_instance_scope.substr(0,pos);
        endfunction
        
        
        // Function- uvm_oneway_hash
        //
        // A one-way hash function that is useful for creating srandom seeds. An
        // unsigned int value is generated from the string input. An initial seed can
        // be used to seed the hash, if not supplied the uvm_global_random_seed 
        // value is used. Uses a CRC like functionality to minimize collisions.
        //
        parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;
 000271 function int unsigned uvm_oneway_hash ( string string_in, int unsigned seed=0 );
 000271   bit          msb;
 000271   bit [7:0]    current_byte;
 000271   bit [31:0]   crc1;
              
~000271   if(!seed) begin
%000000     seed = uvm_global_random_seed;
          end
        
 000271   uvm_oneway_hash = seed;
        
 000271   crc1 = 32'hffffffff;
 019139   for (int _byte=0; _byte < string_in.len(); _byte++) begin
 019139     current_byte = string_in[_byte];
~019139     if (current_byte == 0) begin
%000000       break;
            end
        
 153112     for (int _bit=0; _bit < 8; _bit++) begin
 153112       msb = crc1[31];
 153112       crc1 <<= 1;
 079227       if (msb ^ current_byte[_bit]) begin
 073885         crc1 ^=  UVM_STR_CRC_POLYNOMIAL;
 073885         crc1[0] = 1;
              end
            end
          end
 000271   uvm_oneway_hash += ~{crc1[7:0], crc1[15:8], crc1[23:16], crc1[31:24]};
        
        endfunction
        
        
        // Function- uvm_create_random_seed
        //
        // Creates a random seed and updates the seed map so that if the same string
        // is used again, a new value will be generated. The inst_id is used to hash
        // by instance name and get a map of type name hashes which the type_id uses
        // for its lookup.
        
 003953 function int unsigned uvm_create_random_seed ( string type_id, string inst_id="" );
 003953   uvm_seed_map seed_map;
        
 003890   if(inst_id == "") begin
            
 000063     inst_id = "__global__";
          end
        
        
 003802   if(!uvm_random_seed_table_lookup.exists(inst_id)) begin
            
 000151     uvm_random_seed_table_lookup[inst_id] = new;
          end
        
 003953   seed_map = uvm_random_seed_table_lookup[inst_id];
        
 003953   type_id = {uvm_instance_scope(),type_id};
        
 003682   if(!seed_map.seed_table.exists(type_id)) begin
 000271     seed_map.seed_table[type_id] = uvm_oneway_hash ({type_id,"::",inst_id}, uvm_global_random_seed);
          end
 003682   if (!seed_map.count.exists(type_id)) begin
 000271     seed_map.count[type_id] = 0;
          end
        
          //can't just increment, otherwise too much chance for collision, so 
          //randomize the seed using the last seed as the seed value. Check if
          //the seed has been used before and if so increment it.
 003953   seed_map.seed_table[type_id] = seed_map.seed_table[type_id]+seed_map.count[type_id]; 
 003953   seed_map.count[type_id]++;
        
 003953   return seed_map.seed_table[type_id];
        endfunction
        
        
        // Function- uvm_object_value_str 
        //
        //
 007325 function string uvm_object_value_str(uvm_object v);
~007325   if (v == null) begin
            
%000000     return "<null>";
          end
        
 007325   uvm_object_value_str.itoa(v.get_inst_id());
 007325   uvm_object_value_str = {"@",uvm_object_value_str};
        endfunction
        
        
        // Function- uvm_leaf_scope
        //
        //
 062380 function string uvm_leaf_scope (string full_name, byte scope_separator = ".");
 062380   byte bracket_match;
 062380   int  pos;
 062380   int  bmatches;
        
 062380   bmatches = 0;
 062380   case(scope_separator)
%000000     "[": begin
%000000       bracket_match = "]";
            end
        
%000000     "(": begin
%000000       bracket_match = ")";
            end
        
%000000     "<": begin
%000000       bracket_match = ">";
            end
        
%000000     "{": begin
%000000       bracket_match = "}";
            end
        
 062380     default: begin
 062380       bracket_match = "";
            end
        
          endcase
        
          //Only use bracket matching if the input string has the end match
~062380   if(bracket_match != "" && bracket_match != full_name[full_name.len()-1]) begin
            
%000000     bracket_match = "";
          end
        
        
 101633   for(pos=full_name.len()-1; pos>0; --pos) begin
%000000     if(full_name[pos] == bracket_match) begin
%000000       bmatches++;
            end
        
~101633     else if(full_name[pos] == scope_separator) begin
%000000       bmatches--;
%000000       if(!bmatches || (bracket_match == "")) begin
%000000         break;
              end
        
            end
          end
~062380   if(pos) begin
%000000     if(scope_separator != ".") begin
%000000       pos--;
            end
        
%000000     uvm_leaf_scope = full_name.substr(pos+1,full_name.len()-1);
          end
 062380   else begin
 062380     uvm_leaf_scope = full_name;
          end
        endfunction
        
        
        // Class: uvm_bit_vector_utils#(T)
        // 
        // Provides utility functions for converting bit vectors to/from strings.
        //
        // @uvm-contrib - For potential contribution to a future 1800.2 standard
%000000 virtual class uvm_bit_vector_utils#(type T=int);
        
          // Function: to_string
          // Converts a packed array value into a string.
          //
          // The <size> argument is the number of bits in the vector to be converted,
          // all bits beyond the size are ignored/masked out.
          // The <radix> argument controls the base of the conversion, e.g. UVM_BIN for "%0b".
          // The <radix_str> argument is prepended to the converted value, e.g. "'b" for binary.
          // Note that the radix_str argument has no effect on the base of the conversion.
          //
          // The return value is the converted string.
          //
          // @uvm-contrib - For potential contribution to a future 1800.2 standard
~062380   static function string to_string(T value, int size,
                                           uvm_radix_enum radix=UVM_NORADIX,
                                           string radix_str="");
            // sign extend & don't show radix for negative values
~062380     if (radix == UVM_DEC && value[size-1] === 1) begin
%000000       return $sformatf("%0d", value);
            end
        
        
            // TODO $countbits(value,'z) would be even better
~062380     if($isunknown(value)) begin
%000000       T _t;
%000000       _t=0;
%000000       for(int idx=0;idx<size;idx++) begin
%000000         _t[idx]=value[idx];
              end
        
%000000       value=_t;
            end
~062380     else begin
~062380       value &= (1 << size)-1;
            end
        
        
~062380     case(radix)
%000000       UVM_BIN:      begin
%000000         return $sformatf("%0s%0b", radix_str, value);
              end
        
%000000       UVM_OCT:      begin
%000000         return $sformatf("%0s%0o", radix_str, value);
              end
        
%000000       UVM_UNSIGNED: begin
%000000         return $sformatf("%0s%0d", radix_str, value);
              end
        
%000000       UVM_STRING:   begin
%000000         return $sformatf("%0s%0s", radix_str, value);
              end
        
%000000       UVM_TIME:     begin
%000000         return $sformatf("%0s%0t", radix_str, value);
              end
        
%000000       UVM_DEC:      begin
%000000         return $sformatf("%0s%0d", radix_str, value);
              end
        
%000000       default:      begin
%000000         return $sformatf("%0s%0x", radix_str, value);
              end
        
            endcase
        
          endfunction : to_string
        
          // Function: from_string
          // Converts a string value into a packed array.
          //
          // The string ~val_str~ is processed as:
          //
          //| [sign][radix]value
          //
          // Where `[sign]` is an optional sign character, either "+" or "-", and 
          // `[radix]` is an optional radix specifier.  
          //
          // The following radix specifiers are supported:
          //   "'b", "0b": Binary
          //   "'o": Octal
          //   "'d": Decimal
          //   "'h", "'x", "0x": Hexidecimal
          //
          // If the optional radix is omitted, then the ~value~ shall be treated as decimal.  
          //
          // The ~val_str~ is treated as a 4-state value, the characters "X", "x", "Z", "z", 
          // and "?" are legal within the ~val_str~ string.  Additionally, the underscore character
          // ("_") is ignored.
          //
          // @uvm-contrib - For potential contribution to a future 1800.2 standard
%000000   static function int from_string(input string val_str, output T val);
%000000     string base, extval, tmp;
%000000     int    success ;
%000000     bit    is_negative;
        
%000000     if (val_str.len()  > 1) begin
%000000       byte char;
%000000       char = val_str.getc(0);
              // Optional sign
%000000       if (char == "-") begin
                // Signed, negative
%000000         is_negative = 1;
%000000         tmp = val_str.substr(1, val_str.len()-1);
              end
%000000       else if (char == "+") begin
                // Signed, positive (just remove the sign)
%000000         tmp = val_str.substr(1, val_str.len()-1);
              end
%000000       else begin
                // Unsigned
%000000         tmp = val_str;
              end
            end // if (val_str.len() > 1)
%000000     else begin // !(val_str.len() > 1)
%000000       tmp = val_str;
            end
        
%000000     if(tmp.len() > 2) begin
%000000       base = tmp.substr(0,1);
%000000       extval = tmp.substr(2,tmp.len()-1);
%000000       case(base)
%000000         "'b" : begin
%000000           success= $sscanf(extval,"%b", val);
                end
        
%000000         "0b" : begin
%000000           success= $sscanf(extval,"%b", val);
                end
        
%000000         "'o" : begin
%000000           success= $sscanf(extval,"%o", val);
                end
        
%000000         "'d" : begin
%000000           success= $sscanf(extval,"%d", val);
                end
        
%000000         "'h" : begin
%000000           success= $sscanf(extval,"%x", val);
                end
        
%000000         "'x" : begin
%000000           success= $sscanf(extval,"%x", val);
                end
        
%000000         "0x" : begin
%000000           success= $sscanf(extval,"%x", val);
                end
        
%000000         default : begin
%000000           success = $sscanf(val_str,"%d", val);
                end
        
              endcase
            end
%000000     else begin
%000000       success = $sscanf(tmp,"%d", val);
            end // else: !if(tmp.len() > 2)
        
%000000     if ((success == 1) && (is_negative)) begin
%000000       val = -val;
            end
%000000     return success;
          endfunction : from_string
        
        endclass : uvm_bit_vector_utils
        
        // Function- uvm_bitstream_to_string
        //
        //
%000000 function string uvm_bitstream_to_string (uvm_bitstream_t value, int size,
                                                 uvm_radix_enum radix=UVM_NORADIX,
                                                 string radix_str="");
%000000   return uvm_bit_vector_utils#(uvm_bitstream_t)::to_string(value,size,radix,radix_str);
        endfunction
        
        // Function- uvm_integral_to_string
        //
        //
%000000 function string uvm_integral_to_string (uvm_integral_t value, int size,
                                                 uvm_radix_enum radix=UVM_NORADIX,
                                                 string radix_str="");
%000000   return uvm_bit_vector_utils#(uvm_integral_t)::to_string(value, size, radix, radix_str);
        endfunction
        
        // Function- uvm_get_array_index_int
        //
        // The following functions check to see if a string is representing an array
        // index, and if so, what the index is.
        
%000000 function int uvm_get_array_index_int(string arg, output bit is_wildcard);
%000000   int i;
%000000   int rt_val;
           
%000000   uvm_get_array_index_int = 0;
%000000   is_wildcard = 1;
%000000   i = arg.len() - 1;
%000000   if(arg[i] == "]") begin
            
%000000     while(i > 0 && (arg[i] != "[")) begin
%000000       --i;
%000000       if((arg[i] == "*") || (arg[i] == "?")) begin
%000000         i=0;
              end
        
%000000       else if((arg[i] < "0") || (arg[i] > "9") && (arg[i] != "[")) begin
%000000         uvm_get_array_index_int = -1; //illegal integral index
%000000         i=0;
              end
            end
          end
        
%000000   else begin
%000000     is_wildcard = 0;
%000000     return 0;
          end
        
%000000   if(i>0) begin
%000000     arg = arg.substr(i+1, arg.len()-2);
%000000     rt_val = $sscanf(arg, "%d" ,uvm_get_array_index_int ); 
%000000     is_wildcard = 0;
          end
        endfunction 
          
        
        // Function- uvm_get_array_index_string
        //
        //
%000000 function string uvm_get_array_index_string(string arg, output bit is_wildcard);
%000000   int i;
%000000   uvm_get_array_index_string = "";
%000000   is_wildcard = 1;
%000000   i = arg.len() - 1;
%000000   if(arg[i] == "]") begin
            
%000000     while(i > 0 && (arg[i] != "[")) begin
%000000       if((arg[i] == "*") || (arg[i] == "?")) begin
%000000         i=0;
              end
        
%000000       --i;
            end
          end
        
%000000   if(i>0) begin
%000000     uvm_get_array_index_string = arg.substr(i+1, arg.len()-2);
%000000     is_wildcard = 0;
          end
        endfunction
        
        
        // Function- uvm_is_array
        //
        //
%000000 function bit uvm_is_array(string arg);
%000000   return arg[arg.len()-1] == "]";
        endfunction
        
        
        // Function- uvm_has_wildcard
        //
        //
%000000 function automatic bit uvm_has_wildcard (string arg);
%000000   uvm_has_wildcard = 0;
        
          //if it is a regex then return true
%000000   if( (arg.len() > 1) && (arg[0] == "/") && (arg[arg.len()-1] == "/") ) begin
            
%000000     return 1;
          end
        
        
          //check if it has globs
%000000   foreach(arg[i]) begin
            
%000000     if( (arg[i] == "*") || (arg[i] == "+") || (arg[i] == "?") ) begin
              
%000000       uvm_has_wildcard = 1;
            end
        
          end
        
        
        endfunction
        
        
        typedef class uvm_component;
        typedef class uvm_root;
        typedef class uvm_report_object;
        
        //------------------------------------------------------------------------------
        // CLASS -- NODOCS -- uvm_utils #(TYPE,FIELD)
        //
        // This class contains useful template functions.
        //
        //------------------------------------------------------------------------------
        //@uvm-compat        
        class uvm_utils #(type TYPE=int, string FIELD="config");
        
          typedef TYPE types_t[$];
        
          // Function -- NODOCS -- find_all
          //
          // Recursively finds all component instances of the parameter type ~TYPE~,
          // starting with the component given by ~start~. Uses <uvm_root::find_all>.
        //@uvm-compat
          static function types_t find_all(uvm_component start);
            uvm_component list[$];
            types_t types;
            uvm_root top;
            uvm_coreservice_t cs;
            cs = uvm_coreservice_t::get();
            top = cs.get_root();
            top.find_all("*",list,start);
            foreach (list[i]) begin
              TYPE typ;
              if ($cast(typ,list[i])) begin
                
                types.push_back(typ);
              end
        
            end
            if (types.size() == 0) begin
              `uvm_warning("find_type-no match",{"Instance of type '",TYPE::type_name,
              " not found in component hierarchy beginning at ",start.get_full_name()})
            end
            return types;
          endfunction
        //@uvm-compat
          static function TYPE find(uvm_component start);
            types_t types = find_all(start);
            if (types.size() == 0) begin
              
              return null;
            end
        
            if (types.size() > 1) begin
              `uvm_warning("find_type-multi match",{"More than one instance of type '",TYPE::type_name,
              " found in component hierarchy beginning at ",start.get_full_name()})
              return null;
            end
            return types[0];
          endfunction
        //@uvm-compat
          static function TYPE create_type_by_name(string type_name, string contxt);
            uvm_object obj;
            TYPE  typ;
            uvm_coreservice_t cs = uvm_coreservice_t::get();                                                     
            uvm_factory factory=cs.get_factory();
          
            obj = factory.create_object_by_name(type_name,contxt,type_name);
               if (!$cast(typ,obj)) begin
                 
                 uvm_report_error("WRONG_TYPE",{"The type_name given '",type_name,
                        "' with context '",contxt,"' did not produce the expected type."});
               end
        
            return typ;
          endfunction
        
        
          // Function -- NODOCS -- get_config
          //
          // This method gets the object config of type ~TYPE~
          // associated with component ~comp~.
          // We check for the two kinds of error which may occur with this kind of 
          // operation.
        //@uvm-compat
          static function TYPE get_config(uvm_component comp, bit is_fatal);
            uvm_object obj;
            TYPE cfg;
        
            if (!m_uvm_config_obj_misc::get(comp,"",FIELD, obj)) begin
              if (is_fatal) begin
                
                comp.uvm_report_fatal("NO_SET_CFG", {"no set_config to field '", FIELD,
                                   "' for component '",comp.get_full_name(),"'"},
                                   UVM_MEDIUM, `uvm_file , `uvm_line  );
              end
        
              else begin
                
                comp.uvm_report_warning("NO_SET_CFG", {"no set_config to field '", FIELD,
                                   "' for component '",comp.get_full_name(),"'"},
                                   UVM_MEDIUM, `uvm_file , `uvm_line  );
              end
        
              return null;
            end
        
            if (!$cast(cfg, obj)) begin
              if (is_fatal) begin
                
                comp.uvm_report_fatal( "GET_CFG_TYPE_FAIL",
                                  {"set_config_object with field name ",FIELD,
                                  " is not of type '",TYPE::type_name,"'"},
                                  UVM_NONE , `uvm_file , `uvm_line );
              end
        
              else begin
                
                comp.uvm_report_warning( "GET_CFG_TYPE_FAIL",
                                  {"set_config_object with field name ",FIELD,
                                  " is not of type '",TYPE::type_name,"'"},
                                  UVM_NONE , `uvm_file , `uvm_line );
              end
        
            end
        
            return cfg;
          endfunction
        endclass
        
        
        
        `ifdef UVM_USE_PROCESS_CONTAINER
        class process_container_c;
           process p;
           function new(process p_);
             p=p_;
           endfunction
        endclass
        `endif
        
        
        // this is an internal function and provides a string join independent of a streaming pack
%000006 function automatic string m_uvm_string_queue_join(ref string i[$]);
        `ifndef QUESTA
%000006    m_uvm_string_queue_join = {>>{i}};
        `else
            foreach(i[idx])
                m_uvm_string_queue_join = {m_uvm_string_queue_join,i[idx]};
        `endif
        endfunction
        
        
                    
        
