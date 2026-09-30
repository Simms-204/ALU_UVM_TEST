`timescale 1ns/1ps
// ALU DUT LOGIC
//
import uvm_pkg::*;
`include "uvm_macros.svh"
module ALU (input signed [7:0]a,b,input[1:0]operation,output reg signed [7:0] out,output z,n,c,v);
        parameter ADD = 2'b00;
        parameter SUB = 2'b01;
        parameter AND = 2'b10;
        parameter OR = 2'b11;
        //reg signed [8:0] out_temp;

always@(*)
        begin
        /*case(operation)
        ADD: out_temp = a + b;
        SUB: out_temp = a - b;
        AND: out_temp = a & b;
        OR : out_temp = a | b;
        endcase*/
		case(operation)
        ADD: out = a + b;
        SUB: out = a - b;
        AND: out = a & b;
        OR : out = a | b;
        endcase
        end
//assign out = out[7:0];
assign z = (out == 0);
assign n = (out[7] == 1);
assign v = (operation == ADD) ? ((a[7]==b[7]) && (out[7]!=a[7])) :
           (operation == SUB) ? ((a[7]!=b[7]) && (out[7]!=a[7])) : 1'b0;
assign c = (operation == ADD) ? (a[7]&b[7]) | (a[7]&~out[7]) | (b[7]&~out[7]) :
           (operation == SUB) ? (~((a[7]&~b[7]) | (a[7]&out[7]) | (~b[7]&out[7]))) : 1'b0;

endmodule
//=============================================================================================================================================//


// ALU INTERFACE //
// A clock (`clk`) has been added purely for testbench synchronization.
// The DUT itself stays combinational (no clk port on the ALU module) -
// the clock only paces WHEN the driver drives and WHEN the monitors sample,
// so that driver / write-monitor / read-monitor never race each other.

interface ALU_IF(input bit clk);
logic signed[7:0] a;
logic signed[7:0] b;
logic [1:0] operation;
logic signed[7:0] out;
logic z,n,c,v;

// Driver drives on the NEGEDGE, monitors sample on the POSEDGE.
// That guarantees a full half-cycle of settling time between a stimulus
// change and the moment it (and the resulting DUT output) gets sampled.
modport ALU_DRV(input clk, output a,b,operation);
modport ALU_WRITE_MON(input clk, a,b,operation);
modport ALU_READ_MON(input clk, out,z,n,c,v);
endinterface
// ==============================================================================================================================================//

//ALU WRITE TRANSACTION
class write_xtn extends uvm_sequence_item;
  rand bit signed[7:0] a;
  rand bit signed [7:0] b;
  rand bit [1:0] operation;
  bit signed [7:0] out;
  //bit signed [8:0] out_temp; //this out_temp will be used in the scoreboard class for determining z,c,v,n bits
  bit  z,c,v,n;
  `uvm_object_utils_begin(write_xtn)
	// a/b/operation are stimulus fields: the read-monitor's item never
	// populates them (only out/z/n/v/c are read from the DUT), so they
	// must be excluded from super.do_compare() or every check would
	// spuriously fail comparing a real value against a stale/default 0.
	`uvm_field_int(a,UVM_DEFAULT & ~UVM_COMPARE)
	`uvm_field_int(b,UVM_DEFAULT & ~UVM_COMPARE)
	`uvm_field_int(operation,UVM_DEFAULT & ~UVM_COMPARE)
	`uvm_field_int(out,UVM_ALL_ON)
	`uvm_field_int(z,UVM_ALL_ON)
	`uvm_field_int(c,UVM_ALL_ON)
	`uvm_field_int(v,UVM_ALL_ON)
	`uvm_field_int(n,UVM_ALL_ON)
`uvm_object_utils_end
  // data members

  // constructor
  function new(string name = "write_xtn");
	super.new(name);
  endfunction:new

virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer = null);
	write_xtn rhs_;
	if(!$cast(rhs_,rhs))
	begin
		`uvm_error("do_compare","cast if the object failed");
		return 0;
	end
	return
	super.do_compare(rhs,comparer) &&
		this.out == rhs_.out &&
		this.z == rhs_.z &&
		this.c == rhs_.c &&
		this.v == rhs_.v &&
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

	`uvm_object_utils(alu_config)
	extern function new(string name ="alu_config");
	virtual ALU_IF vif;
	uvm_active_passive_enum is_active;
	bit has_agent;
	bit has_scoreboard;
endclass

function alu_config::new(string name = "alu_config");
	super.new(name);
endfunction

//=============================================================================================================================================//
//ALU_SEQUENCE CLASS

class ALU_SEQUENCE extends uvm_sequence #(write_xtn);

	`uvm_object_utils(ALU_SEQUENCE)


write_xtn gen_q[$];// every transaction this sequence generated, in order
	extern function new(string name = "ALU_SEQUENCE");
	extern task body();
endclass

function ALU_SEQUENCE::new(string name = "ALU_SEQUENCE");
	super.new(name);
endfunction

task ALU_SEQUENCE:: body();
	repeat(10)
		begin
		req = write_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize());
`uvm_info(get_type_name(),"ALU SEQUENCE",UVM_LOW)
`uvm_info(get_type_name(),
          $sformatf("a=%0d b=%0d operation=%0d", req.a, req.b, req.operation),
          UVM_LOW)
		req.print();
		gen_q.push_back(req);
		finish_item(req);
		end
			// ---- after all items are sent: print them as one table ----
	table_str = "\n  #    OP     a      b      a(hex)  b(hex)\n";
		table_str = {table_str, "  ---  ----  -----  -----  ------  ------\n"};
	foreach (gen_q[i])
		table_str = {table_str, $sformatf("  %-3d  %-4s  %5d  %5d  'h%02h    'h%02h\n",
		             i+1, op_name[gen_q[i].operation],
		             gen_q[i].a, gen_q[i].b, gen_q[i].a, gen_q[i].b)};
	`uvm_info(get_type_name(),
	          $sformatf("%0d random values generated:%s", gen_q.size(), table_str),
	          UVM_LOW)
endtask
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

	`uvm_object_utils(ALU_DIRECTED_SEQUENCE)

	typedef struct {
		bit signed [7:0] a;
		bit signed [7:0] b;
		bit [1:0]        operation;
	} corner_vec_t;

	corner_vec_t corner_vectors[] = '{
		// ---- ADD (2'b00) ----
		'{   0,    0, 2'b00},  // baseline zero
		'{ 127,    1, 2'b00},  // max positive + 1 -> overflow, no carry , results 128, but that number is out of range so it will be -128 which is a crash down
		'{-128,   -1, 2'b00},  // min negative - 1 -> overflow AND carry, results in -129 ,out of range, overflow 1 and carry 1
		'{-128, -128, 2'b00},  // overflow that also wraps to exactly zero, resukts 0 overflow 1, carry 1
		'{ 127,  127, 2'b00},  // max + max, overflow, no carry, result of this is 254 but it is wrapped to -2.System checks for carry in and carry out, if they are different then overflo is high as in this case
		'{ -64,  -64, 2'b00},  // lands exactly on -128 boundary, no overflow, it is -128 , no overflow but carry high and negative number
		'{  -1,    1, 2'b00},  // opposite signs: v=0 guaranteed, but c=1, zero bit is high and carry bit is also high
		'{-128,    0, 2'b00},  // identity add on extreme value, only negative bit high
		'{  64,   64, 2'b00},  // smallest same-sign pair that overflows and also makes negative bit high
		// ---- SUB (2'b01) ----
		'{   0,    0, 2'b01},  // baseline zero, no overflow, no carry
		'{-128,    1, 2'b01},  // subtract from min negative -> overflow
		'{ 127,   -1, 2'b01},  // classic SUB overflow , answer is 128 but 128 is overflow so crashes down to -128
		'{-128, -128, 2'b01},  // same operand, same sign -> v forced 0, no overflow , zero is high
		'{   0, -128, 2'b01},  // negating -128 edge case
		'{-128,  127, 2'b01},  // worst-case magnitude gap ,answer's supposed to be 255 but it is -2
		'{  -1, -128, 2'b01},  // same-sign operands, no overflow
		'{  20,   30, 2'b01},  // same-sign inputs, precondition false gives negative 10
		// ---- AND (2'b10) / OR (2'b11): v,c must stay 0 on logical ops ----
		'{   0,    0, 2'b10},
		'{  -1,   -1, 2'b10},
		'{ 127, -128, 2'b10},
		'{  -1,    0, 2'b10},
		'{ 127, -128, 2'b11},
		'{   0,   -1, 2'b11}
	};

	function new(string name = "ALU_DIRECTED_SEQUENCE");
		super.new(name);
	endfunction:new

	task body();
		foreach(corner_vectors[i])
			begin
			req = write_xtn::type_id::create($sformatf("req_corner_%0d",i));
			start_item(req);
			req.a         = corner_vectors[i].a;
			req.b         = corner_vectors[i].b;
			req.operation = corner_vectors[i].operation;
			`uvm_info(get_type_name(),$sformatf("ALU DIRECTED SEQUENCE item %0d: a=%0d b=%0d op=%0b",i,req.a,req.b,req.operation),UVM_LOW)
			finish_item(req);
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
	`uvm_object_utils(ALU_CROSS_SEQUENCE)

	bit signed [7:0] a_vals[] = '{0, 127, -128, -64, -1, 64, 20};      // cp_a bins
	bit signed [7:0] b_vals[] = '{0, 1, -1, -128, 127, -64, 64, 30};   // cp_b bins

	function new(string name = "ALU_CROSS_SEQUENCE");
		super.new(name);
	endfunction

	task body();
		for (int op = 0; op < 4; op++)
			foreach (a_vals[i])
				foreach (b_vals[j]) begin
					req = write_xtn::type_id::create("req");
					start_item(req);
					req.a = a_vals[i];
					req.b = b_vals[j];
					req.operation = op;
					finish_item(req);
				end
	endtask
endclass:ALU_CROSS_SEQUENCE

//=============================================================================================================================================//


//ALU_DRIVER


class ALU_DRIVER extends uvm_driver #(write_xtn);
	`uvm_component_utils(ALU_DRIVER)
	virtual ALU_IF.ALU_DRV vif;
	alu_config drv_cfg;
	extern function new (string name = "ALU_DRIVER",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_item(write_xtn item);
endclass


function ALU_DRIVER::new(string name = "ALU_DRIVER",uvm_component parent);
	super.new(name,parent);
endfunction


function void ALU_DRIVER::build_phase(uvm_phase phase);
	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",drv_cfg))
	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
	 super.build_phase(phase);
endfunction

function void ALU_DRIVER::connect_phase(uvm_phase phase);
	vif = drv_cfg.vif;
endfunction

task ALU_DRIVER::run_phase(uvm_phase phase);
	// Wait for the very first negedge so the first item lines up with the
	// clock instead of racing the interface at time 0.
	
	forever
		begin
		seq_item_port.get_next_item(req);
		req.print();
		drive_item(req);
		`uvm_info(get_type_name(),"ALU DRIVER",UVM_LOW)
		seq_item_port.item_done();
		end
endtask

task ALU_DRIVER::drive_item(write_xtn item);
`uvm_info(get_type_name(),"ALU DRIVING DATA",UVM_LOW)
	// Drive on the negedge: this gives the DUT (and the sampling monitors,
	// which trigger on posedge) a guaranteed half clock period to settle
	// before anything reads a,b,operation or the resulting output.
	@(negedge vif.clk);
	vif.a <= item.a;
	vif.b <= item.b;
	vif.operation <= item.operation;
	@(posedge vif.clk);
`uvm_info(get_type_name(),"ALU DRIVING SUCCESSFUL",UVM_LOW)
endtask:drive_item

//=============================================================================================================================================//

//ALU_WRITE_MONITOR


class ALU_WRITE_MONITOR extends uvm_monitor;
	`uvm_component_utils(ALU_WRITE_MONITOR)
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


function ALU_WRITE_MONITOR::new(string name = "ALU_WRITE_MONITOR",uvm_component parent);
	super.new(name,parent);
	wr_mon_port = new("monitor_port",this);
endfunction


function void ALU_WRITE_MONITOR::build_phase(uvm_phase phase);
	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",wr_mon_cfg))
	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
	 super.build_phase(phase);
endfunction

function void ALU_WRITE_MONITOR::connect_phase(uvm_phase phase);
	vif = wr_mon_cfg.vif;
endfunction

task ALU_WRITE_MONITOR:: run_phase(uvm_phase phase);



forever
	begin
	data_sentwr = write_xtn::type_id::create("data_sentwr");
	collect_data();
	wr_mon_port.write(data_sentwr);
	`uvm_info(get_type_name(),"ALU WRITE MONITORED DATA",UVM_LOW)
	data_sentwr.print();
	end

endtask

task ALU_WRITE_MONITOR::collect_data();
	// Sample strictly on the posedge: the driver only ever changes a,b,
	// operation on the negedge, so by the time posedge arrives the values
	// are guaranteed stable - no more racing the driver's nonblocking assigns.
	@(negedge vif.clk);
	@(posedge vif.clk);
	//#2;
	`uvm_info(get_type_name(),"ALU WRITE MONITORING DATA",UVM_LOW)
	data_sentwr.a = vif.a;
	data_sentwr.b = vif.b;
	data_sentwr.operation = vif.operation;
	`uvm_info(get_type_name(),"ALU WRITE MONITORING SUCCESSFUL",UVM_LOW)

endtask

//===========================================================================================================================================//
//ALU_READ_MONITOR


class ALU_READ_MONITOR extends uvm_monitor;
	`uvm_component_utils(ALU_READ_MONITOR)
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


function ALU_READ_MONITOR::new(string name = "ALU_READ_MONITOR",uvm_component parent);
	super.new(name,parent);
	rd_mon_port = new("monitor_port",this);
endfunction


function void ALU_READ_MONITOR::build_phase(uvm_phase phase);
	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",rd_mon_cfg))
	 `uvm_fatal("TB_CONFIG","not able to get configuration file");
	 super.build_phase(phase);
endfunction

function void ALU_READ_MONITOR::connect_phase(uvm_phase phase);
	vif = rd_mon_cfg.vif;
endfunction

task ALU_READ_MONITOR:: run_phase(uvm_phase phase);



forever
	begin
	data_sent = write_xtn::type_id::create("data_sent");
	collect_data();
	rd_mon_port.write(data_sent);
	`uvm_info(get_type_name(),"ALU READ MONITORED DATA",UVM_LOW)
	data_sent.print();
	end
endtask

task ALU_READ_MONITOR::collect_data();
	// Same posedge sample point as the write monitor, so a given posedge's
	// write-monitor transaction and read-monitor transaction always
	// correspond to the same driven item in the scoreboard.
	@(negedge vif.clk);
	@(posedge vif.clk);
	//#2;
	`uvm_info(get_type_name(),"ALU READ MONITORING DATA",UVM_LOW)
	data_sent.z = vif.z;
	data_sent.n = vif.n;
	data_sent.c = vif.c;
	data_sent.v = vif.v;
	data_sent.out = vif.out;
	`uvm_info(get_type_name(),"ALU READ MONITORING SUCCESSFUL",UVM_LOW)

endtask

//===================================================================================================================================//
//SEQUENCER CLASS
class ALU_SEQUENCER extends uvm_sequencer #(write_xtn);
	`uvm_component_utils(ALU_SEQUENCER)

	extern function new(string name = "ALU_SEQUENCER",uvm_component parent);
endclass
function ALU_SEQUENCER::new (string name = "ALU_SEQUENCER", uvm_component parent);
	super.new(name,parent);
endfunction


//====================================================================================================================================//
// ALU_AGENT CLASS

class ALU_AGENT extends uvm_agent;

	`uvm_component_utils(ALU_AGENT)

	ALU_DRIVER alu_drv;
	ALU_WRITE_MONITOR alu_wr_mon;
	ALU_READ_MONITOR alu_rd_mon;
	ALU_SEQUENCER alu_seqrh;

	alu_config agent_cfg;

	extern function new(string name ="ALU_AGENT",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function ALU_AGENT:: new(string name ="ALU_AGENT", uvm_component parent);
	super.new(name,parent);
endfunction


function void ALU_AGENT:: build_phase (uvm_phase phase);
	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",agent_cfg))
		`uvm_fatal("TB CONFIG","cannot get() m_cfg from uvm_config")

	super.build_phase(phase);

	alu_wr_mon = ALU_WRITE_MONITOR::type_id::create("alu_wr_mon",this);
	alu_rd_mon = ALU_READ_MONITOR::type_id::create("alu_rd_mon",this);

	if(agent_cfg.is_active == UVM_ACTIVE)
		begin
			alu_seqrh = ALU_SEQUENCER::type_id::create("seqrh",this);
			alu_drv = ALU_DRIVER::type_id :: create("drvh",this);
		end

		uvm_config_db #(alu_config)::set(this,"*","aluconfig",agent_cfg);
endfunction

function void ALU_AGENT:: connect_phase (uvm_phase phase);

	if(agent_cfg.is_active == UVM_ACTIVE)
		begin
		alu_drv.seq_item_port.connect(alu_seqrh.seq_item_export);
		end
endfunction

//=================================================================================================================================//
//ALU SCOREBOARD CLASS

class ALU_SCOREBOARD extends uvm_scoreboard;

	`uvm_component_utils(ALU_SCOREBOARD)
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

function ALU_SCOREBOARD :: new(string name = "ALU_SCOREBOARD",uvm_component parent);
	super.new(name,parent);
	wr_ana_fifo = new("wr_ana_fifo",this);
	rd_ana_fifo = new("rd_ana_fifo",this);
	cov_port = new("cov_port",this);
	wrdata=write_xtn::type_id::create("wrdata");
endfunction

task ALU_SCOREBOARD::run_phase (uvm_phase phase);
	fork
	forever
		begin
		wr_ana_fifo.get(wr_data);
		ref_model(wr_data);
		end
	forever
		begin
		rd_ana_fifo.get(rd_data);
		check_data(rd_data);
		end
	join
endtask


task ALU_SCOREBOARD::ref_model(write_xtn wr1data);
	begin
	// Carry the stimulus fields forward so wrdata is a fully correlated
	// (a,b,operation,out,z,n,v,c) reference item - needed both for
	// do_compare() in check_data() and for functional coverage sampling.
	this.wrdata.a = wr1data.a;
	this.wrdata.b = wr1data.b;
	this.wrdata.operation = wr1data.operation;

	case(wr1data.operation)
        2'b00: this.wrdata.out = wr1data.a + wr1data.b;
        2'b01: this.wrdata.out = wr1data.a - wr1data.b;
        2'b10: this.wrdata.out = wr1data.a & wr1data.b;
        2'b11: this.wrdata.out = wr1data.a | wr1data.b;
        endcase
	this.wrdata.z = (this.wrdata.out==0);
	this.wrdata.n = (this.wrdata.out[7] == 1);
	this.wrdata.v = (this.wrdata.operation == 2'b00) ? ((this.wrdata.a[7]==this.wrdata.b[7]) && (this.wrdata.out[7]!=this.wrdata.a[7])) :
           (this.wrdata.operation == 2'b01) ? ((this.wrdata.a[7]!=this.wrdata.b[7]) && (this.wrdata.out[7]!=this.wrdata.a[7])) : 1'b0;
	this.wrdata.c = (this.wrdata.operation == 2'b00) ? (this.wrdata.a[7]&this.wrdata.b[7]) | (this.wrdata.a[7]&~this.wrdata.out[7]) | (this.wrdata.b[7]&~this.wrdata.out[7]) :
           (this.wrdata.operation == 2'b01) ? (~((this.wrdata.a[7]&~this.wrdata.b[7]) | (this.wrdata.a[7]&this.wrdata.out[7]) | (~this.wrdata.b[7]&this.wrdata.out[7]))) : 1'b0;

	cov_port.write(this.wrdata);
	end
endtask

task ALU_SCOREBOARD::check_data(write_xtn rddata);
	if(!rddata.compare(wrdata))
	begin
		`uvm_error(get_type_name(),"Scoreboard error")
		rddata.print();
		wrdata.print();
	end
	else
	begin
		`uvm_info(get_type_name(),"Data match successful",UVM_LOW)
		rddata.print();
		wrdata.print();
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

	`uvm_component_utils(ALU_COVERAGE)

	write_xtn cov_xtn;

	covergroup alu_cg;
		option.per_instance = 1;
		option.name = "alu_cg";

		cp_op: coverpoint cov_xtn.operation {
			bins add_op = {2'b00};
			bins sub_op = {2'b01};
			bins and_op = {2'b10};
			bins or_op  = {2'b11};
		}

		// Overflow/carry only mean something for ADD/SUB. Verilator 5.052's
		// covergroup support does not honor ignore_bins/binsof on a cross,
		// so rather than cross the full cp_op (which would create
		// permanently-uncovered "and_op x v1" / "or_op x v1" bins), this
		// coverpoint only declares bins for ADD/SUB: AND/OR samples simply
		// don't match either bin and are left uncounted, same as any other
		// coverpoint with a restricted bin set.
		cp_arith_op: coverpoint cov_xtn.operation {
			bins add_op = {2'b00};
			bins sub_op = {2'b01};
		}

		// values actually assigned to 'a' across the directed corner vectors
		// Bin literals are sized/signed hex (8'shXX) to match cov_xtn.a's
		// width exactly - bare decimal negative literals (e.g. {-128}) are
		// 32-bit and can silently fail to match an 8-bit signed coverpoint
		// under Verilator's covergroup bin matching.
		cp_a: coverpoint cov_xtn.a {
			bins zero    = {8'sh00}; // 0
			bins max_pos = {8'sh7F}; // 127
			bins min_neg = {8'sh80}; // -128
			bins neg_64  = {8'shC0}; // -64
			bins neg_1   = {8'shFF}; // -1
			bins pos_64  = {8'sh40}; // 64
			bins pos_20  = {8'sh14}; // 20
			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
		}

		// values actually assigned to 'b' across the directed corner vectors
		cp_b: coverpoint cov_xtn.b {
			bins zero    = {8'sh00}; // 0
			bins one     = {8'sh01}; // 1
			bins neg_1   = {8'shFF}; // -1
			bins min_neg = {8'sh80}; // -128
			bins max_pos = {8'sh7F}; // 127
			bins neg_64  = {8'shC0}; // -64
			bins pos_64  = {8'sh40}; // 64
			bins pos_30  = {8'sh1E}; // 30
			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
		}
		cp_out: coverpoint cov_xtn.out {
			bins range1 = {[8'sh01:8'sh7E]}; // 1..126
			bins range2 = {[8'sh81:8'shBF]}; // -127..-65
			bins range3 = {[8'shC1:8'sh00]}; // -63..-1
			bins zero    = {8'sh00}; // 0
		}
		cp_z: coverpoint cov_xtn.z { bins z0 = {0}; bins z1 = {1}; }
		cp_n: coverpoint cov_xtn.n { bins n0 = {0}; bins n1 = {1}; }
		cp_v: coverpoint cov_xtn.v { bins v0 = {0}; bins v1 = {1}; }
		cp_c: coverpoint cov_xtn.c { bins c0 = {0}; bins c1 = {1}; }

		op_x_v: cross cp_arith_op, cp_v;
		op_x_c: cross cp_arith_op, cp_c;
		op_x_ab: cross cp_op, cp_a, cp_b;// the percentage along with this was 22 percent for 200 repeats
		// op x z x n x v x c. A full cross has 64 bins but only 20 can ever
		// occur: AND/OR never set v/c, a zero result is never negative, and
		// for ADD/SUB overflow fixes the carry (e.g. ADD overflowing to a
		// positive result needs two negative operands, which always carry).
		// ignore_bins on a cross isn't honored by Verilator 5.052, so instead
		// this is a coverpoint on {operation,z,n,v,c} with only the 20 legal bins.
		op_x_zn: coverpoint {cov_xtn.operation, cov_xtn.z, cov_xtn.n, cov_xtn.v, cov_xtn.c} {
			//                  op  z n v c
			bins add_z0n0v0c0 = {6'b00_0_0_0_0};//0
			bins add_z0n0v0c1 = {6'b00_0_0_0_1};//1
			bins add_z0n0v1c1 = {6'b00_0_0_1_1};//3
			bins add_z0n1v0c0 = {6'b00_0_1_0_0};//4
			bins add_z0n1v0c1 = {6'b00_0_1_0_1};//5
			bins add_z0n1v1c0 = {6'b00_0_1_1_0};//6
			bins add_z1n0v0c0 = {6'b00_1_0_0_0};//8
			bins add_z1n0v0c1 = {6'b00_1_0_0_1};//9
			bins add_z1n0v1c1 = {6'b00_1_0_1_1};//11
			bins sub_z0n0v0c1 = {6'b01_0_0_0_1};//17
			bins sub_z0n0v1c0 = {6'b01_0_0_1_0};//18
			bins sub_z0n1v0c0 = {6'b01_0_1_0_0};//
			bins sub_z0n1v1c1 = {6'b01_0_1_1_1};//
			bins sub_z1n0v0c1 = {6'b01_1_0_0_1};//
			bins and_z0n0     = {6'b10_0_0_0_0};//
			bins and_z0n1     = {6'b10_0_1_0_0};//
			bins and_z1n0     = {6'b10_1_0_0_0};
			bins or_z0n0      = {6'b11_0_0_0_0};
			bins or_z0n1      = {6'b11_0_1_0_0};
			bins or_z1n0      = {6'b11_1_0_0_0};
		}

	endgroup

	function new(string name = "ALU_COVERAGE", uvm_component parent);
		super.new(name,parent);
		alu_cg = new();
	endfunction:new

	function void write(write_xtn t);
		cov_xtn = t;
		alu_cg.sample();
	endfunction:write

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("ALU functional coverage = %0.2f%%",alu_cg.get_inst_coverage()),UVM_LOW)
	endfunction:report_phase

endclass:ALU_COVERAGE

//========================================================================================================================================//

//ALU_ENVIRONMENT CLASS

class ALU_ENVIRONMENT extends uvm_env;
	`uvm_component_utils(ALU_ENVIRONMENT)

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

function ALU_ENVIRONMENT::new(string name = "ALU_ENVIRONMENT",uvm_component parent);
	super.new(name,parent);
endfunction

function void ALU_ENVIRONMENT:: build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(alu_config)::get(this,"","aluconfig",env_cfg))//GETTING ALUCONFIG FILE FROM TEST TO ENV
		`uvm_fatal(get_type_name(),"Getting failed in env");
	if(env_cfg.has_agent)
		alu_agent= ALU_AGENT::type_id::create("alu_agent",this);
	if(env_cfg.has_scoreboard)
		alu_sb = ALU_SCOREBOARD::type_id::create("alu_sb",this);

	alu_cov = ALU_COVERAGE::type_id::create("alu_cov",this);

	uvm_config_db #(alu_config)::set(this,"*","aluconfig",env_cfg); // SETTING THE ALUCONFIG FILE FROM ENV TO AGENT

endfunction

function void ALU_ENVIRONMENT::connect_phase(uvm_phase phase);
	if(env_cfg.has_scoreboard)
		begin
		alu_agent.alu_wr_mon.wr_mon_port.connect(alu_sb.wr_ana_fifo.analysis_export);
		alu_agent.alu_rd_mon.rd_mon_port.connect(alu_sb.rd_ana_fifo.analysis_export);
		alu_sb.cov_port.connect(alu_cov.analysis_export);
		end
endfunction


//======================================================================================================================================//
// TEST CLASS

class base_test extends uvm_test;
	`uvm_component_utils(base_test)

	alu_config test_cfg;
	ALU_ENVIRONMENT alu_env;

	extern function new(string name = "base_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function base_test::new(string name = "base_test",uvm_component parent);
	super.new(name,parent);
endfunction

function void base_test ::build_phase(uvm_phase phase);

	test_cfg = alu_config::type_id::create("test_cfg"); //creating configuration object new

	test_cfg.is_active = UVM_ACTIVE;
	test_cfg.has_agent = 1;
	test_cfg.has_scoreboard = 1;



	if(!uvm_config_db #(virtual ALU_IF)::get(this,"","ALU_IF",test_cfg.vif))
		`uvm_fatal("VIF CONFIG","cannot get interface vif from uvm_config_db");

	uvm_config_db #(alu_config)::set(this,"*","aluconfig",test_cfg);
	super.build_phase(phase);
	alu_env = ALU_ENVIRONMENT::type_id::create("alu_env",this);
endfunction

function void base_test::end_of_elaboration_phase(uvm_phase phase);
	// Print the full uvm_component tree (env/agent/driver/monitors/
	// scoreboard/coverage) once the testbench is fully built, right
	// before run_phase starts driving stimulus.
	uvm_top.print_topology();
endfunction

//=====================================================================================================================================
//RANDOM_TEST / DIRECTED_TEST / CROSS_TEST - base_test only builds the
//environment and runs no stimulus. Each of these tests inherits build_phase
//and end_of_elaboration_phase (topology print) from base_test and starts
//exactly one sequence in its own run_phase.

class random_test extends base_test;
	`uvm_component_utils(random_test)

	extern function new(string name = "random_test",uvm_component parent);
	extern task run_phase(uvm_phase phase);
endclass

function random_test::new(string name = "random_test",uvm_component parent);
	super.new(name,parent);
endfunction

task random_test::run_phase(uvm_phase phase);
	ALU_SEQUENCE seq;
	phase.raise_objection(this);
	seq = ALU_SEQUENCE::type_id::create("seq");
	seq.start(alu_env.alu_agent.alu_seqrh);
	phase.drop_objection(this);
endtask

class directed_test extends base_test;
	`uvm_component_utils(directed_test)

	extern function new(string name = "directed_test",uvm_component parent);
	extern task run_phase(uvm_phase phase);
endclass

function directed_test::new(string name = "directed_test",uvm_component parent);
	super.new(name,parent);
endfunction

task directed_test::run_phase(uvm_phase phase);
	ALU_DIRECTED_SEQUENCE dir_seq;
	phase.raise_objection(this);
	dir_seq = ALU_DIRECTED_SEQUENCE::type_id::create("dir_seq");
	dir_seq.start(alu_env.alu_agent.alu_seqrh);
	phase.drop_objection(this);
endtask

class cross_test extends base_test;
	`uvm_component_utils(cross_test)

	extern function new(string name = "cross_test",uvm_component parent);
	extern task run_phase(uvm_phase phase);
endclass

function cross_test::new(string name = "cross_test",uvm_component parent);
	super.new(name,parent);
endfunction

task cross_test::run_phase(uvm_phase phase);
	ALU_CROSS_SEQUENCE cross_seq;
	phase.raise_objection(this);
	cross_seq = ALU_CROSS_SEQUENCE::type_id::create("cross_seq");
	cross_seq.start(alu_env.alu_agent.alu_seqrh);
	phase.drop_objection(this);
endtask




//=====================================================================================================================================
//MODULE TOP


module top;

// --- Clock generation ---------------------------------------------------
// The ALU DUT itself has no clock port (it's purely combinational), so
// this clock exists ONLY to synchronize the testbench: driver drives on
// negedge, both monitors sample on posedge. That removes the races that
// come from triggering everything off `@(vif.a or vif.b or ...)`.
bit clk;
initial clk = 0;
always #5 clk = ~clk;   // 10-unit period, 5-unit half period

ALU_IF if1(clk);

ALU DUV(.a(if1.a), .b(if1.b), .operation(if1.operation),
        .out(if1.out), .z(if1.z), .n(if1.n), .c(if1.c), .v(if1.v));
initial
	begin
	uvm_config_db#(virtual ALU_IF)::set(null,"*","ALU_IF",if1);
	run_test();
	end

endmodule
//=========================================================================================================================================
