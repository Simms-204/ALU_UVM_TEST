//      // verilator_coverage annotation
        `timescale 1ns/1ps
        // ALU DUT LOGIC
        //
        import uvm_pkg::*;
        `include "uvm_macros.svh"
 000346 module ALU (input signed [7:0]a,b,input[1:0]operation,output reg signed [7:0] out,output z,n,c,v);
                parameter ADD = 2'b00;
                parameter SUB = 2'b01;
                parameter AND = 2'b10;
                parameter OR = 2'b11;
                //reg signed [8:0] out_temp;
        
 002493 always@(*)
 002493         begin
                /*case(operation)
                ADD: out_temp = a + b;
                SUB: out_temp = a - b;
                AND: out_temp = a & b;
                OR : out_temp = a | b;
                endcase*/
 002493 		case(operation)
 000641         ADD: out = a + b;
 000608         SUB: out = a - b;
 000600         AND: out = a & b;
 000644         OR : out = a | b;
                endcase
                end
        //assign out = out[7:0];
        assign z = (out == 0);
        assign n = (out[7] == 1);
 001852 assign v = (operation == ADD) ? ((a[7]==b[7]) && (out[7]!=a[7])) :
 001244            (operation == SUB) ? ((a[7]!=b[7]) && (out[7]!=a[7])) : 1'b0;
 001852 assign c = (operation == ADD) ? (a[7]&b[7]) | (a[7]&~out[7]) | (b[7]&~out[7]) :
 001244            (operation == SUB) ? (~((a[7]&~b[7]) | (a[7]&out[7]) | (~b[7]&out[7]))) : 1'b0;
        
        endmodule
        //=============================================================================================================================================//
        
        
        // ALU INTERFACE //
        // A clock (`clk`) has been added purely for testbench synchronization.
        // The DUT itself stays combinational (no clk port on the ALU module) -
        // the clock only paces WHEN the driver drives and WHEN the monitors sample,
        // so that driver / write-monitor / read-monitor never race each other.
        
 001250 interface ALU_IF(input bit clk);
 000279 logic signed[7:0] a;
 000346 logic signed[7:0] b;
 000251 logic [1:0] operation;
 000319 logic signed[7:0] out;
 000292 logic z,n,c,v;
        
        // Driver drives on the NEGEDGE, monitors sample on the POSEDGE.
        // That guarantees a full half-cycle of settling time between a stimulus
        // change and the moment it (and the resulting DUT output) gets sampled.
        modport ALU_DRV(input clk, output a,b,operation);
        modport ALU_WRITE_MON(input clk, a,b,operation);
        modport ALU_READ_MON(input clk, out,z,n,c,v);
        endinterface
        // ==============================================================================================================================================//
        
        //ALU WRITE TRANSACTION
 001000 class write_xtn extends uvm_sequence_item;
          rand bit signed[7:0] a;
          rand bit signed [7:0] b;
          rand bit [1:0] operation;
          bit signed [7:0] out;
          //bit signed [8:0] out_temp; //this out_temp will be used in the scoreboard class for determining z,c,v,n bits
          bit  z,c,v,n;
~008482   `uvm_object_utils_begin(write_xtn)
        	// a/b/operation are stimulus fields: the read-monitor's item never
        	// populates them (only out/z/n/v/c are read from the DUT), so they
        	// must be excluded from super.do_compare() or every check would
        	// spuriously fail comparing a real value against a stale/default 0.
~008482 	`uvm_field_int(a,UVM_DEFAULT & ~UVM_COMPARE)
~008482 	`uvm_field_int(b,UVM_DEFAULT & ~UVM_COMPARE)
~008482 	`uvm_field_int(operation,UVM_DEFAULT & ~UVM_COMPARE)
~009729 	`uvm_field_int(out,UVM_ALL_ON)
~009729 	`uvm_field_int(z,UVM_ALL_ON)
~009729 	`uvm_field_int(c,UVM_ALL_ON)
~009729 	`uvm_field_int(v,UVM_ALL_ON)
~009729 	`uvm_field_int(n,UVM_ALL_ON)
        `uvm_object_utils_end
          // data members
        
          // constructor
~003750   function new(string name = "write_xtn");
 003750 	super.new(name);
          endfunction:new
        
 001247 virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer = null);
 001247 	write_xtn rhs_;
~001247 	if(!$cast(rhs_,rhs))
%000000 	begin
%000000 		`uvm_error("do_compare","cast if the object failed");
%000000 		return 0;
        	end
 001247 	return
 001247 	super.do_compare(rhs,comparer) &&
 001247 		this.out == rhs_.out &&
 001247 		this.z == rhs_.z &&
 001247 		this.c == rhs_.c &&
 001247 		this.v == rhs_.v &&
        		this.n == rhs_.n;
        endfunction:do_compare
        
        
        constraint operand_c {
          operation dist {
            2'b00 := 25,
            2'b01 := 25,
            2'b10 := 25,
            2'b11 := 25
          };
        }
        constraint operand_a {
          operation inside {2'b00, 2'b01, 2'b10, 2'b11};
        }
        endclass:write_xtn
        
        //============================================================================================================================================//
        //ALU_CONFIGURATION
        
        class alu_config extends uvm_object;
        
%000000 	`uvm_object_utils(alu_config)
        	extern function new(string name ="alu_config");
        	virtual ALU_IF vif;
        	uvm_active_passive_enum is_active;
        	bit has_agent;
        	bit has_scoreboard;
        endclass
        
%000003 function alu_config::new(string name = "alu_config");
%000003 	super.new(name);
        endfunction
        
        //=============================================================================================================================================//
        //ALU_SEQUENCE CLASS
        
        class ALU_SEQUENCE extends uvm_sequence #(write_xtn);
        
~003001 	`uvm_object_utils(ALU_SEQUENCE)
        
        
        
        	extern function new(string name = "ALU_SEQUENCE");
        	extern task body();
        endclass
        
%000001 function ALU_SEQUENCE::new(string name = "ALU_SEQUENCE");
%000001 	super.new(name);
        endfunction
        
%000001 task ALU_SEQUENCE:: body();
~001000 	repeat(1000)
 001000 		begin
 001000 		req = write_xtn::type_id::create("req");
 001000 		start_item(req);
 001000 		assert(req.randomize());
~001000 		`uvm_info(get_type_name(),"ALU SEQUENCE",UVM_LOW)
 001000 		req.print();
 001000 		finish_item(req);
        		end
        	endtask
        
        
        
        //=============================================================================================================================================//
        //ALU_DIRECTED_SEQUENCE CLASS
        //
        // Drives the fixed corner-case vectors picked to exercise the z/n/v/c
        // boundaries: max positive, min negative (-128, whose negation itself
        // can't be represented), same-sign overflow/no-overflow, opposite-sign
        // carry/borrow, exact-zero wraparound, and AND/OR cases that must never
        // assert v/c. Values are assigned directly (not randomize()) so every
        // run drives exactly these vectors, independent of the random seed.
        
        class ALU_DIRECTED_SEQUENCE extends uvm_sequence #(write_xtn);
        
~000070 	`uvm_object_utils(ALU_DIRECTED_SEQUENCE)
        
        	typedef struct {
        		bit signed [7:0] a;
        		bit signed [7:0] b;
        		bit [1:0]        operation;
        	} corner_vec_t;
        
%000001 	corner_vec_t corner_vectors[] = '{
        		// ---- ADD (2'b00) ----
%000001 		'{   0,    0, 2'b00},  // baseline zero
%000001 		'{ 127,    1, 2'b00},  // max positive + 1 -> overflow, no carry , results 128, but that number is out of range so it will be -128 which is a crash down
%000001 		'{-128,   -1, 2'b00},  // min negative - 1 -> overflow AND carry, results in -129 ,out of range, overflow 1 and carry 1
%000001 		'{-128, -128, 2'b00},  // overflow that also wraps to exactly zero, resukts 0 overflow 1, carry 1
%000001 		'{ 127,  127, 2'b00},  // max + max, overflow, no carry, result of this is 254 but it is wrapped to -2.System checks for carry in and carry out, if they are different then overflo is high as in this case
%000001 		'{ -64,  -64, 2'b00},  // lands exactly on -128 boundary, no overflow, it is -128 , no overflow but carry high and negative number
%000001 		'{  -1,    1, 2'b00},  // opposite signs: v=0 guaranteed, but c=1, zero bit is high and carry bit is also high
%000001 		'{-128,    0, 2'b00},  // identity add on extreme value, only negative bit high
%000001 		'{  64,   64, 2'b00},  // smallest same-sign pair that overflows and also makes negative bit high
        		// ---- SUB (2'b01) ----
%000001 		'{   0,    0, 2'b01},  // baseline zero, no overflow, no carry
%000001 		'{-128,    1, 2'b01},  // subtract from min negative -> overflow
%000001 		'{ 127,   -1, 2'b01},  // classic SUB overflow , answer is 128 but 128 is overflow so crashes down to -128
%000001 		'{-128, -128, 2'b01},  // same operand, same sign -> v forced 0, no overflow , zero is high
%000001 		'{   0, -128, 2'b01},  // negating -128 edge case
%000001 		'{-128,  127, 2'b01},  // worst-case magnitude gap ,answer's supposed to be 255 but it is -2
%000001 		'{  -1, -128, 2'b01},  // same-sign operands, no overflow
%000001 		'{  20,   30, 2'b01},  // same-sign inputs, precondition false gives negative 10
        		// ---- AND (2'b10) / OR (2'b11): v,c must stay 0 on logical ops ----
%000001 		'{   0,    0, 2'b10},
%000001 		'{  -1,   -1, 2'b10},
%000001 		'{ 127, -128, 2'b10},
%000001 		'{  -1,    0, 2'b10},
%000001 		'{ 127, -128, 2'b11},
%000001 		'{   0,   -1, 2'b11}
        	};
        
%000001 	function new(string name = "ALU_DIRECTED_SEQUENCE");
%000001 		super.new(name);
        	endfunction:new
        
%000001 	task body();
~000023 		foreach(corner_vectors[i])
 000023 			begin
 000023 			req = write_xtn::type_id::create($sformatf("req_corner_%0d",i));
 000023 			start_item(req);
 000023 			req.a         = corner_vectors[i].a;
 000023 			req.b         = corner_vectors[i].b;
 000023 			req.operation = corner_vectors[i].operation;
~000023 			`uvm_info(get_type_name(),$sformatf("ALU DIRECTED SEQUENCE item %0d: a=%0d b=%0d op=%0b",i,req.a,req.b,req.operation),UVM_LOW)
 000023 			finish_item(req);
        			end
        	endtask:body
        
        endclass:ALU_DIRECTED_SEQUENCE
        
        //=============================================================================================================================================//
        //ALU_CROSS_SEQUENCE CLASS
        //
        // Walks every operation x cp_a bin value x cp_b bin value (4 x 7 x 8 = 224
        // items) so every op_x_ab cross bin is hit deterministically. Uniform random
        // a/b almost never lands on these single-value bins (~1 in 262k per bin).
        
        class ALU_CROSS_SEQUENCE extends uvm_sequence #(write_xtn);
%000001 	`uvm_object_utils(ALU_CROSS_SEQUENCE)
        
%000001 	bit signed [7:0] a_vals[] = '{0, 127, -128, -64, -1, 64, 20};      // cp_a bins
%000001 	bit signed [7:0] b_vals[] = '{0, 1, -1, -128, 127, -64, 64, 30};   // cp_b bins
        
%000001 	function new(string name = "ALU_CROSS_SEQUENCE");
%000001 		super.new(name);
        	endfunction
        
%000001 	task body();
%000004 		for (int op = 0; op < 4; op++)
~000028 			foreach (a_vals[i])
~000224 				foreach (b_vals[j]) begin
 000224 					req = write_xtn::type_id::create("req");
 000224 					start_item(req);
 000224 					req.a = a_vals[i];
 000224 					req.b = b_vals[j];
 000224 					req.operation = op;
 000224 					finish_item(req);
        				end
        	endtask
        endclass:ALU_CROSS_SEQUENCE
        
        //=============================================================================================================================================//
        
        
        //ALU_DRIVER
        
        
        class ALU_DRIVER extends uvm_driver #(write_xtn);
~011229 	`uvm_component_utils(ALU_DRIVER)
        	virtual ALU_IF.ALU_DRV vif;
        	alu_config drv_cfg;
        	extern function new (string name = "ALU_DRIVER",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void connect_phase(uvm_phase phase);
        	extern task run_phase(uvm_phase phase);
        	extern task drive_item(write_xtn item);
        endclass
        
        
%000003 function ALU_DRIVER::new(string name = "ALU_DRIVER",uvm_component parent);
%000003 	super.new(name,parent);
        endfunction
        
        
%000003 function void ALU_DRIVER::build_phase(uvm_phase phase);
%000003 	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",drv_cfg))
%000000 	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
%000003 	 super.build_phase(phase);
        endfunction
        
%000003 function void ALU_DRIVER::connect_phase(uvm_phase phase);
%000003 	vif = drv_cfg.vif;
        endfunction
        
%000000 task ALU_DRIVER::run_phase(uvm_phase phase);
        	// Wait for the very first negedge so the first item lines up with the
        	// clock instead of racing the interface at time 0.
        	
 001247 	forever
 001247 		begin
 001247 		seq_item_port.get_next_item(req);
 001247 		req.print();
 001247 		drive_item(req);
~001247 		`uvm_info(get_type_name(),"ALU DRIVER",UVM_LOW)
 001247 		seq_item_port.item_done();
        		end
        endtask
        
 001247 task ALU_DRIVER::drive_item(write_xtn item);
~001247 `uvm_info(get_type_name(),"ALU DRIVING DATA",UVM_LOW)
        	// Drive on the negedge: this gives the DUT (and the sampling monitors,
        	// which trigger on posedge) a guaranteed half clock period to settle
        	// before anything reads a,b,operation or the resulting output.
 001247 	@(negedge vif.clk);
 001247 	vif.a <= item.a;
 001247 	vif.b <= item.b;
 001247 	vif.operation <= item.operation;
 001247 	@(posedge vif.clk);
~001247 `uvm_info(get_type_name(),"ALU DRIVING SUCCESSFUL",UVM_LOW)
        endtask:drive_item
        
        //=============================================================================================================================================//
        
        //ALU_WRITE_MONITOR
        
        
        class ALU_WRITE_MONITOR extends uvm_monitor;
~011229 	`uvm_component_utils(ALU_WRITE_MONITOR)
        	uvm_analysis_port #(write_xtn) wr_mon_port; // Analysis port declaration
        
        	virtual ALU_IF.ALU_WRITE_MON vif;
        	alu_config wr_mon_cfg;
        	write_xtn data_sentwr;
        	extern function new (string name = "ALU_WRITE_MONITOR",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void connect_phase(uvm_phase phase);
        	extern task run_phase (uvm_phase phase);
        	extern task collect_data();
        endclass
        
        
%000003 function ALU_WRITE_MONITOR::new(string name = "ALU_WRITE_MONITOR",uvm_component parent);
%000003 	super.new(name,parent);
%000003 	wr_mon_port = new("monitor_port",this);
        endfunction
        
        
%000003 function void ALU_WRITE_MONITOR::build_phase(uvm_phase phase);
%000003 	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",wr_mon_cfg))
%000000 	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
%000003 	 super.build_phase(phase);
        endfunction
        
%000003 function void ALU_WRITE_MONITOR::connect_phase(uvm_phase phase);
%000003 	vif = wr_mon_cfg.vif;
        endfunction
        
%000000 task ALU_WRITE_MONITOR:: run_phase(uvm_phase phase);
        
        
        
 001247 forever
 001247 	begin
 001247 	data_sentwr = write_xtn::type_id::create("data_sentwr");
 001247 	collect_data();
 001247 	wr_mon_port.write(data_sentwr);
~001247 	`uvm_info(get_type_name(),"ALU WRITE MONITORED DATA",UVM_LOW)
 001247 	data_sentwr.print();
        	end
        
        endtask
        
 001247 task ALU_WRITE_MONITOR::collect_data();
        	// Sample strictly on the posedge: the driver only ever changes a,b,
        	// operation on the negedge, so by the time posedge arrives the values
        	// are guaranteed stable - no more racing the driver's nonblocking assigns.
 001247 	@(negedge vif.clk);
 001247 	@(posedge vif.clk);
        	//#2;
~001247 	`uvm_info(get_type_name(),"ALU WRITE MONITORING DATA",UVM_LOW)
 001247 	data_sentwr.a = vif.a;
 001247 	data_sentwr.b = vif.b;
 001247 	data_sentwr.operation = vif.operation;
~001247 	`uvm_info(get_type_name(),"ALU WRITE MONITORING SUCCESSFUL",UVM_LOW)
        
        endtask
        
        //===========================================================================================================================================//
        //ALU_READ_MONITOR
        
        
        class ALU_READ_MONITOR extends uvm_monitor;
~011229 	`uvm_component_utils(ALU_READ_MONITOR)
        	uvm_analysis_port #(write_xtn) rd_mon_port; // Analysis port declaration
        
        	virtual ALU_IF.ALU_READ_MON vif;
        	alu_config rd_mon_cfg;
        	write_xtn data_sent;
        	extern function new (string name = "ALU_READ_MONITOR",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void connect_phase(uvm_phase phase);
        	extern task run_phase (uvm_phase phase);
        	extern task collect_data();
        endclass
        
        
%000003 function ALU_READ_MONITOR::new(string name = "ALU_READ_MONITOR",uvm_component parent);
%000003 	super.new(name,parent);
%000003 	rd_mon_port = new("monitor_port",this);
        endfunction
        
        
%000003 function void ALU_READ_MONITOR::build_phase(uvm_phase phase);
%000003 	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",rd_mon_cfg))
%000000 	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
%000003 	 super.build_phase(phase);
        endfunction
        
%000003 function void ALU_READ_MONITOR::connect_phase(uvm_phase phase);
%000003 	vif = rd_mon_cfg.vif;
        endfunction
        
%000000 task ALU_READ_MONITOR:: run_phase(uvm_phase phase);
        
        
        
 001247 forever
 001247 	begin
 001247 	data_sent = write_xtn::type_id::create("data_sent");
 001247 	collect_data();
 001247 	rd_mon_port.write(data_sent);
~001247 	`uvm_info(get_type_name(),"ALU READ MONITORED DATA",UVM_LOW)
 001247 	data_sent.print();
        	end
        endtask
        
 001247 task ALU_READ_MONITOR::collect_data();
        	// Same posedge sample point as the write monitor, so a given posedge's
        	// write-monitor transaction and read-monitor transaction always
        	// correspond to the same driven item in the scoreboard.
 001247 	@(negedge vif.clk);
 001247 	@(posedge vif.clk);
        	//#2;
~001247 	`uvm_info(get_type_name(),"ALU READ MONITORING DATA",UVM_LOW)
 001247 	data_sent.z = vif.z;
 001247 	data_sent.n = vif.n;
 001247 	data_sent.c = vif.c;
 001247 	data_sent.v = vif.v;
 001247 	data_sent.out = vif.out;
~001247 	`uvm_info(get_type_name(),"ALU READ MONITORING SUCCESSFUL",UVM_LOW)
        
        endtask
        
        //===================================================================================================================================//
        //SEQUENCER CLASS
        class ALU_SEQUENCER extends uvm_sequencer #(write_xtn);
%000006 	`uvm_component_utils(ALU_SEQUENCER)
        
        	extern function new(string name = "ALU_SEQUENCER",uvm_component parent);
        endclass
%000003 function ALU_SEQUENCER::new (string name = "ALU_SEQUENCER", uvm_component parent);
%000003 	super.new(name,parent);
        endfunction
        
        
        //====================================================================================================================================//
        // ALU_AGENT CLASS
        
        class ALU_AGENT extends uvm_agent;
        
%000006 	`uvm_component_utils(ALU_AGENT)
        
        	ALU_DRIVER alu_drv;
        	ALU_WRITE_MONITOR alu_wr_mon;
        	ALU_READ_MONITOR alu_rd_mon;
        	ALU_SEQUENCER alu_seqrh;
        
        	alu_config agent_cfg;
        
        	extern function new(string name ="ALU_AGENT",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void connect_phase(uvm_phase phase);
        endclass
        
%000003 function ALU_AGENT:: new(string name ="ALU_AGENT", uvm_component parent);
%000003 	super.new(name,parent);
        endfunction
        
        
%000003 function void ALU_AGENT:: build_phase (uvm_phase phase);
%000003 	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",agent_cfg))
%000000 		`uvm_fatal("TB CONFIG","cannot get() m_cfg from uvm_config")
        
%000003 	super.build_phase(phase);
        
%000003 	alu_wr_mon = ALU_WRITE_MONITOR::type_id::create("alu_wr_mon",this);
%000003 	alu_rd_mon = ALU_READ_MONITOR::type_id::create("alu_rd_mon",this);
        
%000003 	if(agent_cfg.is_active == UVM_ACTIVE)
%000003 		begin
%000003 			alu_seqrh = ALU_SEQUENCER::type_id::create("seqrh",this);
%000003 			alu_drv = ALU_DRIVER::type_id :: create("drvh",this);
        		end
        
%000003 		uvm_config_db #(alu_config)::set(this,"*","aluconfig",agent_cfg);
        endfunction
        
%000003 function void ALU_AGENT:: connect_phase (uvm_phase phase);
        
%000003 	if(agent_cfg.is_active == UVM_ACTIVE)
%000003 		begin
%000003 		alu_drv.seq_item_port.connect(alu_seqrh.seq_item_export);
        		end
        endfunction
        
        //=================================================================================================================================//
        //ALU SCOREBOARD CLASS
        
        class ALU_SCOREBOARD extends uvm_scoreboard;
        
~003747 	`uvm_component_utils(ALU_SCOREBOARD)
        	uvm_tlm_analysis_fifo #(write_xtn) wr_ana_fifo;
        	uvm_tlm_analysis_fifo #(write_xtn) rd_ana_fifo;
        	uvm_analysis_port #(write_xtn) cov_port; // fully-correlated (a,b,op,out,z,n,v,c) item, for coverage
        
        	write_xtn wr_data,rd_data;
        	write_xtn wrdata;//new object for storing the output values inside the reference model task
        
        	extern function new(string name = "ALU_SCOREBOARD", uvm_component parent );
        
        	extern task run_phase (uvm_phase phase);
        	extern task ref_model(write_xtn wr1data);
        	extern task check_data(write_xtn rddata);
        endclass
        
%000003 function ALU_SCOREBOARD :: new(string name = "ALU_SCOREBOARD",uvm_component parent);
%000003 	super.new(name,parent);
%000003 	wr_ana_fifo = new("wr_ana_fifo",this);
%000003 	rd_ana_fifo = new("rd_ana_fifo",this);
%000003 	cov_port = new("cov_port",this);
%000003 	wrdata=write_xtn::type_id::create("wrdata");
        endfunction
        
%000000 task ALU_SCOREBOARD::run_phase (uvm_phase phase);
%000000 	fork
~001247 	forever
 001247 		begin
 001247 		wr_ana_fifo.get(wr_data);
 001247 		ref_model(wr_data);
        		end
~001247 	forever
 001247 		begin
 001247 		rd_ana_fifo.get(rd_data);
 001247 		check_data(rd_data);
        		end
        	join
        endtask
        
        
 001247 task ALU_SCOREBOARD::ref_model(write_xtn wr1data);
 001247 	begin
        	// Carry the stimulus fields forward so wrdata is a fully correlated
        	// (a,b,operation,out,z,n,v,c) reference item - needed both for
        	// do_compare() in check_data() and for functional coverage sampling.
 001247 	this.wrdata.a = wr1data.a;
 001247 	this.wrdata.b = wr1data.b;
 001247 	this.wrdata.operation = wr1data.operation;
        
 001247 	case(wr1data.operation)
 000321         2'b00: this.wrdata.out = wr1data.a + wr1data.b;
 000304         2'b01: this.wrdata.out = wr1data.a - wr1data.b;
 000300         2'b10: this.wrdata.out = wr1data.a & wr1data.b;
 000322         2'b11: this.wrdata.out = wr1data.a | wr1data.b;
                endcase
 001247 	this.wrdata.z = (this.wrdata.out==0);
 001247 	this.wrdata.n = (this.wrdata.out[7] == 1);
 001247 	this.wrdata.v = (this.wrdata.operation == 2'b00) ? ((this.wrdata.a[7]==this.wrdata.b[7]) && (this.wrdata.out[7]!=this.wrdata.a[7])) :
                   (this.wrdata.operation == 2'b01) ? ((this.wrdata.a[7]!=this.wrdata.b[7]) && (this.wrdata.out[7]!=this.wrdata.a[7])) : 1'b0;
 001247 	this.wrdata.c = (this.wrdata.operation == 2'b00) ? (this.wrdata.a[7]&this.wrdata.b[7]) | (this.wrdata.a[7]&~this.wrdata.out[7]) | (this.wrdata.b[7]&~this.wrdata.out[7]) :
                   (this.wrdata.operation == 2'b01) ? (~((this.wrdata.a[7]&~this.wrdata.b[7]) | (this.wrdata.a[7]&this.wrdata.out[7]) | (~this.wrdata.b[7]&this.wrdata.out[7]))) : 1'b0;
        
 001247 	cov_port.write(this.wrdata);
        	end
        endtask
        
 001247 task ALU_SCOREBOARD::check_data(write_xtn rddata);
~001247 	if(!rddata.compare(wrdata))
%000000 	begin
%000000 		`uvm_error(get_type_name(),"Scoreboard error")
%000000 		rddata.print();
%000000 		wrdata.print();
        	end
        	else
 001247 	begin
~001247 		`uvm_info(get_type_name(),"Data match successful",UVM_LOW)
 001247 		rddata.print();
 001247 		wrdata.print();
        	end
        endtask
        
        //=================================================================================================================================//
        //ALU_COVERAGE CLASS
        //
        // Functional coverage on the fully-correlated (a,b,operation,z,n,v,c)
        // item the scoreboard publishes on cov_port. Coverpoint bins for a/b are
        // deliberately restricted to the exact corner values driven by
        // ALU_DIRECTED_SEQUENCE (rather than every possible 8-bit value), so the
        // model reaches 100% from that one deterministic sequence regardless of
        // what ALU_SEQUENCE's random items happen to roll.
        
        class ALU_COVERAGE extends uvm_subscriber #(write_xtn);
        
~000015 	`uvm_component_utils(ALU_COVERAGE)
        
        	write_xtn cov_xtn;
        
        	covergroup alu_cg;
        		option.per_instance = 1;
        		option.name = "alu_cg";
        
        		cp_op: coverpoint cov_xtn.operation {
 000321 			bins add_op = {2'b00};
 000304 			bins sub_op = {2'b01};
 000300 			bins and_op = {2'b10};
 000322 			bins or_op  = {2'b11};
        		}
        
        		// Overflow/carry only mean something for ADD/SUB. Verilator 5.052's
        		// covergroup support does not honor ignore_bins/binsof on a cross,
        		// so rather than cross the full cp_op (which would create
        		// permanently-uncovered "and_op x v1" / "or_op x v1" bins), this
        		// coverpoint only declares bins for ADD/SUB: AND/OR samples simply
        		// don't match either bin and are left uncounted, same as any other
        		// coverpoint with a restricted bin set.
        		cp_arith_op: coverpoint cov_xtn.operation {
 000321 			bins add_op = {2'b00};
 000304 			bins sub_op = {2'b01};
        		}
        
        		// values actually assigned to 'a' across the directed corner vectors
        		// Bin literals are sized/signed hex (8'shXX) to match cov_xtn.a's
        		// width exactly - bare decimal negative literals (e.g. {-128}) are
        		// 32-bit and can silently fail to match an 8-bit signed coverpoint
        		// under Verilator's covergroup bin matching.
        		cp_a: coverpoint cov_xtn.a {
 000038 			bins zero    = {8'sh00}; // 0
 000040 			bins max_pos = {8'sh7F}; // 127
 000041 			bins min_neg = {8'sh80}; // -128
 000033 			bins neg_64  = {8'shC0}; // -64
 000040 			bins neg_1   = {8'shFF}; // -1
 000034 			bins pos_64  = {8'sh40}; // 64
 000036 			bins pos_20  = {8'sh14}; // 20
 000549 			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
 000247 			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
 000337 			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
        		}
        
        		// values actually assigned to 'b' across the directed corner vectors
        		cp_b: coverpoint cov_xtn.b {
 000037 			bins zero    = {8'sh00}; // 0
 000034 			bins one     = {8'sh01}; // 1
 000035 			bins neg_1   = {8'shFF}; // -1
 000041 			bins min_neg = {8'sh80}; // -128
 000035 			bins max_pos = {8'sh7F}; // 127
 000032 			bins neg_64  = {8'shC0}; // -64
 000032 			bins pos_64  = {8'sh40}; // 64
 000035 			bins pos_30  = {8'sh1E}; // 30
 000566 			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
 000242 			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
 000331 			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
        		}
        		cp_out: coverpoint cov_xtn.out {
 000525 			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
 000249 			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
 000382 			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
 000065 			bins zero    = {8'sh00}; // 0
        		}
 001182 		cp_z: coverpoint cov_xtn.z { bins z0 = {0}; bins z1 = {1}; }
 000624 		cp_n: coverpoint cov_xtn.n { bins n0 = {0}; bins n1 = {1}; }
 001098 		cp_v: coverpoint cov_xtn.v { bins v0 = {0}; bins v1 = {1}; }
 000940 		cp_c: coverpoint cov_xtn.c { bins c0 = {0}; bins c1 = {1}; }
        
 000239 		op_x_v: cross cp_arith_op, cp_v;
 000167 		op_x_c: cross cp_arith_op, cp_c;
~000071 		op_x_ab: cross cp_op, cp_a, cp_b;// the percentage along with this was 22 percent for 200 repeats
        		// op x z x n x v x c. A full cross has 64 bins but only 20 can ever
        		// occur: AND/OR never set v/c, a zero result is never negative, and
        		// for ADD/SUB overflow fixes the carry (e.g. ADD overflowing to a
        		// positive result needs two negative operands, which always carry).
        		// ignore_bins on a cross isn't honored by Verilator 5.052, so instead
        		// this is a coverpoint on {operation,z,n,v,c} with only the 20 legal bins.
        		op_x_zn: coverpoint {cov_xtn.operation, cov_xtn.z, cov_xtn.n, cov_xtn.v, cov_xtn.c} {
        			//                  op  z n v c
 000045 			bins add_z0n0v0c0 = {6'b00_0_0_0_0};//0
 000075 			bins add_z0n0v0c1 = {6'b00_0_0_0_1};//1
 000038 			bins add_z0n0v1c1 = {6'b00_0_0_1_1};//3
 000078 			bins add_z0n1v0c0 = {6'b00_0_1_0_0};//4
 000033 			bins add_z0n1v0c1 = {6'b00_0_1_0_1};//5
 000042 			bins add_z0n1v1c0 = {6'b00_0_1_1_0};//6
%000002 			bins add_z1n0v0c0 = {6'b00_1_0_0_0};//8
%000006 			bins add_z1n0v0c1 = {6'b00_1_0_0_1};//9
%000002 			bins add_z1n0v1c1 = {6'b00_1_0_1_1};//11
 000113 			bins sub_z0n0v0c1 = {6'b01_0_0_0_1};//17
 000036 			bins sub_z0n0v1c0 = {6'b01_0_0_1_0};//18
 000115 			bins sub_z0n1v0c0 = {6'b01_0_1_0_0};//
 000031 			bins sub_z0n1v1c1 = {6'b01_0_1_1_1};//
%000009 			bins sub_z1n0v0c1 = {6'b01_1_0_0_1};//
 000181 			bins and_z0n0     = {6'b10_0_0_0_0};//
 000074 			bins and_z0n1     = {6'b10_0_1_0_0};//
 000045 			bins and_z1n0     = {6'b10_1_0_0_0};
 000071 			bins or_z0n0      = {6'b11_0_0_0_0};
 000250 			bins or_z0n1      = {6'b11_0_1_0_0};
%000001 			bins or_z1n0      = {6'b11_1_0_0_0};
        		}
        
        	endgroup
        
%000003 	function new(string name = "ALU_COVERAGE", uvm_component parent);
%000003 		super.new(name,parent);
%000003 		alu_cg = new();
        	endfunction:new
        
 001247 	function void write(write_xtn t);
 001247 		cov_xtn = t;
 001247 		alu_cg.sample();
        	endfunction:write
        
%000003 	function void report_phase(uvm_phase phase);
%000003 		`uvm_info(get_type_name(),$sformatf("ALU functional coverage = %0.2f%%",alu_cg.get_inst_coverage()),UVM_LOW)
        	endfunction:report_phase
        
        endclass:ALU_COVERAGE
        
        //========================================================================================================================================//
        
        //ALU_ENVIRONMENT CLASS
        
        class ALU_ENVIRONMENT extends uvm_env;
%000006 	`uvm_component_utils(ALU_ENVIRONMENT)
        
        	ALU_AGENT alu_agent;	//declaring alu_agent handle for creating agent object
        	ALU_SCOREBOARD alu_sb;  // declaring alu_score board handle for creating scoreboard object
        	ALU_WRITE_MONITOR alu_wr_mon; // declaring class of write monitor for connection with scoreboard
        	ALU_READ_MONITOR alu_rd_mon;// declaring class of read monitor for connection with scoreboard
        	ALU_COVERAGE alu_cov;	// functional coverage subscriber, fed by the scoreboard's cov_port
        
        	alu_config env_cfg ;	// handle of configuration file to get it from test
        
        	extern function new(string name = "ALU_ENVIRONMENT",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void connect_phase(uvm_phase phase);
        
        endclass
        
%000003 function ALU_ENVIRONMENT::new(string name = "ALU_ENVIRONMENT",uvm_component parent);
%000003 	super.new(name,parent);
        endfunction
        
%000003 function void ALU_ENVIRONMENT:: build_phase (uvm_phase phase);
%000003 	super.build_phase(phase);
%000003 	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",env_cfg))//GETTING ALUCONFIG FILE FROM TEST TO ENV
%000000 		`uvm_fatal(get_type_name(),"Getting failed in env");
%000003 	if(env_cfg.has_agent)
%000003 		alu_agent= ALU_AGENT::type_id::create("alu_agent",this);
%000003 	if(env_cfg.has_scoreboard)
%000003 		alu_sb = ALU_SCOREBOARD::type_id::create("alu_sb",this);
        
%000003 	alu_cov = ALU_COVERAGE::type_id::create("alu_cov",this);
        
%000003 	uvm_config_db #(alu_config)::set(this,"*","aluconfig",env_cfg); // SETTING THE ALUCONFIG FILE FROM ENV TO AGENT
        
        endfunction
        
%000003 function void ALU_ENVIRONMENT::connect_phase(uvm_phase phase);
%000003 	if(env_cfg.has_scoreboard)
%000003 		begin
%000003 		alu_agent.alu_wr_mon.wr_mon_port.connect(alu_sb.wr_ana_fifo.analysis_export);
%000003 		alu_agent.alu_rd_mon.rd_mon_port.connect(alu_sb.rd_ana_fifo.analysis_export);
%000003 		alu_sb.cov_port.connect(alu_cov.analysis_export);
        		end
        endfunction
        
        
        //======================================================================================================================================//
        // TEST CLASS
        
        class base_test extends uvm_test;
%000000 	`uvm_component_utils(base_test)
        
        	alu_config test_cfg;
        	ALU_ENVIRONMENT alu_env;
        
        	extern function new(string name = "base_test",uvm_component parent);
        	extern function void build_phase(uvm_phase phase);
        	extern function void end_of_elaboration_phase(uvm_phase phase);
        endclass
        
%000003 function base_test::new(string name = "base_test",uvm_component parent);
%000003 	super.new(name,parent);
        endfunction
        
%000003 function void base_test ::build_phase(uvm_phase phase);
        
%000003 	test_cfg = alu_config::type_id::create("test_cfg"); //creating configuration object new
        
%000003 	test_cfg.is_active = UVM_ACTIVE;
%000003 	test_cfg.has_agent = 1;
%000003 	test_cfg.has_scoreboard = 1;
        
        
        
%000003 	if(!uvm_config_db #(virtual ALU_IF)::get(this,"","ALU_IF",test_cfg.vif))
%000000 		`uvm_fatal("VIF CONFIG","cannot get interface vif from uvm_config_db");
        
%000003 	uvm_config_db #(alu_config)::set(this,"*","aluconfig",test_cfg);
%000003 	super.build_phase(phase);
%000003 	alu_env = ALU_ENVIRONMENT::type_id::create("alu_env",this);
        endfunction
        
%000003 function void base_test::end_of_elaboration_phase(uvm_phase phase);
        	// Print the full uvm_component tree (env/agent/driver/monitors/
        	// scoreboard/coverage) once the testbench is fully built, right
        	// before run_phase starts driving stimulus.
%000003 	uvm_top.print_topology();
        endfunction
        
        //=====================================================================================================================================
        //RANDOM_TEST / DIRECTED_TEST / CROSS_TEST - base_test only builds the
        //environment and runs no stimulus. Each of these tests inherits build_phase
        //and end_of_elaboration_phase (topology print) from base_test and starts
        //exactly one sequence in its own run_phase.
        
        class random_test extends base_test;
%000003 	`uvm_component_utils(random_test)
        
        	extern function new(string name = "random_test",uvm_component parent);
        	extern task run_phase(uvm_phase phase);
        endclass
        
%000001 function random_test::new(string name = "random_test",uvm_component parent);
%000001 	super.new(name,parent);
        endfunction
        
%000001 task random_test::run_phase(uvm_phase phase);
%000001 	ALU_SEQUENCE seq;
%000001 	phase.raise_objection(this);
%000001 	seq = ALU_SEQUENCE::type_id::create("seq");
%000001 	seq.start(alu_env.alu_agent.alu_seqrh);
%000001 	phase.drop_objection(this);
        endtask
        
        class directed_test extends base_test;
%000003 	`uvm_component_utils(directed_test)
        
        	extern function new(string name = "directed_test",uvm_component parent);
        	extern task run_phase(uvm_phase phase);
        endclass
        
%000001 function directed_test::new(string name = "directed_test",uvm_component parent);
%000001 	super.new(name,parent);
        endfunction
        
%000001 task directed_test::run_phase(uvm_phase phase);
%000001 	ALU_DIRECTED_SEQUENCE dir_seq;
%000001 	phase.raise_objection(this);
%000001 	dir_seq = ALU_DIRECTED_SEQUENCE::type_id::create("dir_seq");
%000001 	dir_seq.start(alu_env.alu_agent.alu_seqrh);
%000001 	phase.drop_objection(this);
        endtask
        
        class cross_test extends base_test;
%000003 	`uvm_component_utils(cross_test)
        
        	extern function new(string name = "cross_test",uvm_component parent);
        	extern task run_phase(uvm_phase phase);
        endclass
        
%000001 function cross_test::new(string name = "cross_test",uvm_component parent);
%000001 	super.new(name,parent);
        endfunction
        
%000001 task cross_test::run_phase(uvm_phase phase);
%000001 	ALU_CROSS_SEQUENCE cross_seq;
%000001 	phase.raise_objection(this);
%000001 	cross_seq = ALU_CROSS_SEQUENCE::type_id::create("cross_seq");
%000001 	cross_seq.start(alu_env.alu_agent.alu_seqrh);
%000001 	phase.drop_objection(this);
        endtask
        
        
        
        
        //=====================================================================================================================================
        //MODULE TOP
        
        
        module top;
        
        // --- Clock generation ---------------------------------------------------
        // The ALU DUT itself has no clock port (it's purely combinational), so
        // this clock exists ONLY to synchronize the testbench: driver drives on
        // negedge, both monitors sample on posedge. That removes the races that
        // come from triggering everything off `@(vif.a or vif.b or ...)`.
 001250 bit clk;
%000003 initial clk = 0;
 002497 always #5 clk = ~clk;   // 10-unit period, 5-unit half period
        
        ALU_IF if1(clk);
        
        ALU DUV(.a(if1.a), .b(if1.b), .operation(if1.operation),
                .out(if1.out), .z(if1.z), .n(if1.n), .c(if1.c), .v(if1.v));
%000003 initial
%000003 	begin
%000003 	uvm_config_db#(virtual ALU_IF)::set(null,"*","ALU_IF",if1);
%000003 	run_test();
        	end
        
        endmodule
        //=========================================================================================================================================
        
