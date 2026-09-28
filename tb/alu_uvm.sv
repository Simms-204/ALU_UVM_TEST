/*// ALU DUT LOGIC
//
import uvm_pkg::*;
`include "uvm_macros.svh"
module ALU (input signed [7:0]a,b,input[1:0]operation,output signed [7:0] out,output z,n,c,v);
        parameter ADD = 2'b00;
        parameter SUB = 2'b01;
        parameter AND = 2'b10;
        parameter OR = 2'b11;
        reg signed [8:0] out_temp;

always@(*)
        begin
        case(operation)
        ADD: out_temp = a + b;
        SUB: out_temp = a - b;
        AND: out_temp = a & b;
        OR : out_temp = a | b;
        endcase
        end
assign out = out_temp[7:0];
assign z = (out_temp==0);
assign n = (out_temp[7] == 1);
assign v = (out_temp[8]);
assign c = (out_temp[8]);

endmodule
//=============================================================================================================================================//


// ALU INTERFACE //

interface ALU_IF;
logic signed[7:0] a;
logic signed[7:0] b;
logic [1:0] operation;
logic signed[7:0] out;
logic z,n,c,v;
modport ALU_DRV(output a,b,operation);
modport ALU_WRITE_MON(input a,b,operation);
modport ALU_READ_MON(input out,z,n,c,v);
endinterface
// ==============================================================================================================================================//

//ALU WRITE TRANSACTION
class write_xtn extends uvm_sequence_item;
  rand bit signed[7:0] a;
  rand bit signed [7:0] b;
  rand bit [1:0] operation;
  bit signed [7:0] out;
  bit signed [8:0] out_temp; //this out_temp will be used in the scoreboard class for determining z,c,v,n bits
  bit  z,c,v,n;
  `uvm_object_utils_begin(write_xtn)
	`uvm_field_int(a,UVM_ALL_ON)
	`uvm_field_int(b,UVM_ALL_ON)
	`uvm_field_int(operation,UVM_ALL_ON)
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
	
	
	
	extern function new(string name = "ALU_SEQUENCE");
	extern task body();
endclass

function ALU_SEQUENCE::new(string name = "ALU_SEQUENCE");
	super.new(name);
endfunction

task ALU_SEQUENCE:: body();
	repeat(2)
		begin
		req = write_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		`uvm_info(get_type_name(),"ALU SEQUENCE",UVM_LOW)
		req.print();
		finish_item(req);
		end
	endtask



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
//#1;
	forever
		begin
		seq_item_port.get_next_item(req);
		drive_item(req);
		`uvm_info(get_type_name(),"ALU DRIVER",UVM_LOW)
		req.print();
		seq_item_port.item_done();
		end
endtask

task ALU_DRIVER::drive_item(write_xtn item);
`uvm_info(get_type_name(),"ALU DRIVING DATA",UVM_LOW)
	vif.a <= item.a;
	vif.b <= item.b;
	vif.operation <= item.operation;
	//$display("vif.a= %b\n vif.b = %b \n vif.operation = %b",vif.a,vif.b,vif.operation);
`uvm_info(get_type_name(),"ALU DRIVING SUCCESSFUL",UVM_LOW)
	#10;
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
@(vif.a or vif.b or vif.operation); // checks first if there's any vif data a,b,operation driven by the driver to the interface
#1;
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
@(vif.z or vif.n or vif.c or vif.v or vif.out) // checks if there's any data coming from the interface when output is obtained
#1;
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
	case(wr1data.operation)
        2'b00: this.wrdata.out_temp = wr1data.a + wr1data.b;
        2'b01: this.wrdata.out_temp = wr1data.a - wr1data.b;
        2'b10: this.wrdata.out_temp = wr1data.a & wr1data.b;
        2'b11: this.wrdata.out_temp = wr1data.a | wr1data.b;
        endcase
	this.wrdata.out = wr1data.out_temp[7:0];
	this.wrdata.z = (wr1data.out_temp==0);
	this.wrdata.n = (wr1data.out_temp[7] == 1);
	this.wrdata.v = (wr1data.out_temp[8]);
	this.wrdata.c = (wr1data.out_temp[8]);
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

//========================================================================================================================================//

//ALU_ENVIRONMENT CLASS

class ALU_ENVIRONMENT extends uvm_env;
	`uvm_component_utils(ALU_ENVIRONMENT)
	
	ALU_AGENT alu_agent;	//declaring alu_agent handle for creating agent object
	ALU_SCOREBOARD alu_sb;  // declaring alu_score board handle for creating scoreboard object
	ALU_WRITE_MONITOR alu_wr_mon; // declaring class of write monitor for connection with scoreboard
	ALU_READ_MONITOR alu_rd_mon;// declaring class of read monitor for connection with scoreboard
	
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
		
	uvm_config_db #(alu_config)::set(this,"*","aluconfig",env_cfg); // SETTING THE ALUCONFIG FILE FROM ENV TO AGENT

endfunction

function void ALU_ENVIRONMENT::connect_phase(uvm_phase phase);
	if(env_cfg.has_scoreboard)
		begin
		alu_agent.alu_wr_mon.wr_mon_port.connect(alu_sb.wr_ana_fifo.analysis_export);
		alu_agent.alu_rd_mon.rd_mon_port.connect(alu_sb.rd_ana_fifo.analysis_export);
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
	extern task run_phase(uvm_phase phase);
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

task base_test::run_phase(uvm_phase phase);
	ALU_SEQUENCE seq;
	phase.raise_objection(this);
	seq = ALU_SEQUENCE::type_id::create("seq");
	seq.start(alu_env.alu_agent.alu_seqrh);
	phase.drop_objection(this);
endtask

//=====================================================================================================================================
//MODULE TOP


module top;


ALU_IF if1();

//ALU DUV(if1);
  ALU DUV(.a(if1.a), .b(if1.b), .operation(if1.operation),
          .out(if1.out), .z(if1.z), .n(if1.n), .c(if1.c), .v(if1.v));
initial
	begin
	uvm_config_db#(virtual ALU_IF)::set(null,"*","ALU_IF",if1);
	run_test();
	end
	
endmodule
//=========================================================================================================================================
*/

// ALU DUT LOGIC
//
import uvm_pkg::*;
`include "uvm_macros.svh"
module ALU (input signed [7:0]a,b,input[1:0]operation,output signed [7:0] out,output z,n,c,v);
        parameter ADD = 2'b00;
        parameter SUB = 2'b01;
        parameter AND = 2'b10;
        parameter OR = 2'b11;
        reg signed [8:0] out_temp;

always@(*)
        begin
        case(operation)
        ADD: out_temp = a + b;
        SUB: out_temp = a - b;
        AND: out_temp = a & b;
        OR : out_temp = a | b;
        endcase
        end
assign out = out_temp[7:0];
assign z = (out_temp==0);
assign n = (out_temp[7] == 1);
assign v = (out_temp[8]);
assign c = (out_temp[8]);

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
  bit signed [8:0] out_temp; //this out_temp will be used in the scoreboard class for determining z,c,v,n bits
  bit  z,c,v,n;
  `uvm_object_utils_begin(write_xtn)
	`uvm_field_int(a,UVM_ALL_ON)
	`uvm_field_int(b,UVM_ALL_ON)
	`uvm_field_int(operation,UVM_ALL_ON)
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



	extern function new(string name = "ALU_SEQUENCE");
	extern task body();
endclass

function ALU_SEQUENCE::new(string name = "ALU_SEQUENCE");
	super.new(name);
endfunction

task ALU_SEQUENCE:: body();
	repeat(2)
		begin
		req = write_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize());
		`uvm_info(get_type_name(),"ALU SEQUENCE",UVM_LOW)
		req.print();
		finish_item(req);
		end
	endtask



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
	//@(negedge vif.clk);
	forever
	
		begin
		seq_item_port.get_next_item(req);
		drive_item(req);
		`uvm_info(get_type_name(),"ALU DRIVER",UVM_LOW)
		req.print();
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
	@(posedge vif.clk);
	#2;
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
	//@(posedge vif.clk);
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
	@(posedge vif.clk);
	#2;
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
	//@(posedge vif.clk);
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
	case(wr1data.operation)
        2'b00: this.wrdata.out_temp = wr1data.a + wr1data.b;
        2'b01: this.wrdata.out_temp = wr1data.a - wr1data.b;
        2'b10: this.wrdata.out_temp = wr1data.a & wr1data.b;
        2'b11: this.wrdata.out_temp = wr1data.a | wr1data.b;
        endcase
	this.wrdata.out = this.wrdata.out_temp[7:0];
	this.wrdata.z = (this.wrdata.out_temp==0);
	this.wrdata.n = (this.wrdata.out_temp[7] == 1);
	this.wrdata.v = (this.wrdata.out_temp[8]);
	this.wrdata.c = (this.wrdata.out_temp[8]);
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

//========================================================================================================================================//

//ALU_ENVIRONMENT CLASS

class ALU_ENVIRONMENT extends uvm_env;
	`uvm_component_utils(ALU_ENVIRONMENT)

	ALU_AGENT alu_agent;	//declaring alu_agent handle for creating agent object
	ALU_SCOREBOARD alu_sb;  // declaring alu_score board handle for creating scoreboard object
	ALU_WRITE_MONITOR alu_wr_mon; // declaring class of write monitor for connection with scoreboard
	ALU_READ_MONITOR alu_rd_mon;// declaring class of read monitor for connection with scoreboard

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

	uvm_config_db #(alu_config)::set(this,"*","aluconfig",env_cfg); // SETTING THE ALUCONFIG FILE FROM ENV TO AGENT

endfunction

function void ALU_ENVIRONMENT::connect_phase(uvm_phase phase);
	if(env_cfg.has_scoreboard)
		begin
		alu_agent.alu_wr_mon.wr_mon_port.connect(alu_sb.wr_ana_fifo.analysis_export);
		alu_agent.alu_rd_mon.rd_mon_port.connect(alu_sb.rd_ana_fifo.analysis_export);
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
	extern task run_phase(uvm_phase phase);
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

task base_test::run_phase(uvm_phase phase);
	ALU_SEQUENCE seq;
	phase.raise_objection(this);
	seq = ALU_SEQUENCE::type_id::create("seq");
	seq.start(alu_env.alu_agent.alu_seqrh);
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



