`include "uvm_macros.svh"

import uvm_pkg :: *;


//====================================================
// DUT
//====================================================

module adder (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [4:0] sum
);

    assign sum = a + b;

endmodule


//====================================================
// INTERFACE
//====================================================

interface adder_if;

    logic [3:0] a;
    logic [3:0] b;
    logic [4:0] sum;

endinterface


//====================================================
// TRANSACTION
//====================================================

class adder_transaction extends uvm_sequence_item;

    rand bit [3:0] a;
    rand bit [3:0] b;

    bit [4:0] sum;

    `uvm_object_utils(adder_transaction)

    function new(string name = "adder_transaction");
        super.new(name);
    endfunction

endclass


//====================================================
// SEQUENCE
//====================================================

class adder_sequence extends uvm_sequence #(adder_transaction);

    `uvm_object_utils(adder_sequence)

    function new(string name = "adder_sequence");
        super.new(name);
    endfunction

    task body();

        adder_transaction req;

        repeat (5) begin

            req = adder_transaction::type_id::create("req");

            start_item(req);

            //assert(req.randomize());

            if ( req.randomize() == 0 ) 
            begin
                `uvm_fatal("RANDFAIL", "Randomization failed")
            end

            finish_item(req);

        end

    endtask

endclass


//====================================================
// DRIVER
//====================================================

class adder_driver extends uvm_driver #(adder_transaction);

    `uvm_component_utils(adder_driver)

    virtual adder_if vif;

    function new( string name = "adder_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        adder_transaction req;

        forever begin

            seq_item_port.get_next_item(req);
`uvm_info( "DRIVER", $sformatf( "Driving a=%0d b=%0d", req.a, req.b ), UVM_MEDIUM )
            vif.a = req.a;
            vif.b = req.b;

            #1;

            

            seq_item_port.item_done();

        end

    endtask

endclass


//====================================================
// MONITOR
//====================================================

class adder_monitor extends uvm_monitor;

    `uvm_component_utils(adder_monitor)

    virtual adder_if vif;

    uvm_analysis_port #(adder_transaction) ap;


    function new( string name = "adder_monitor", uvm_component parent = null );

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    task run_phase(uvm_phase phase);

        adder_transaction tr;

        forever begin

            #1;

            tr = adder_transaction::type_id::create("tr");

            tr.a   = vif.a;
            tr.b   = vif.b;
            tr.sum = vif.sum;

            ap.write(tr);

        end

    endtask

endclass


//====================================================
// SCOREBOARD
//====================================================

class adder_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(adder_scoreboard)

    uvm_analysis_imp #(adder_transaction, adder_scoreboard) analysis_export;


    function new( string name = "adder_scoreboard", uvm_component parent = null );

        super.new(name, parent);

        analysis_export = new("analysis_export", this);

    endfunction


    function void write(adder_transaction tr);

        if (tr.sum == (tr.a + tr.b)) begin

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "PASS: a=%0d b=%0d sum=%0d",
                    tr.a,
                    tr.b,
                    tr.sum
                ),
                UVM_MEDIUM
            )

        end
        else begin

            `uvm_error(
                "SCOREBOARD",
                $sformatf(
                    "FAIL: a=%0d b=%0d expected=%0d actual=%0d",
                    tr.a,
                    tr.b,
                    tr.a + tr.b,
                    tr.sum
                )
            )

        end

    endfunction

endclass


//====================================================
// ENVIRONMENT
//====================================================

class adder_env extends uvm_env;

    `uvm_component_utils(adder_env)

    uvm_sequencer #(adder_transaction) sequencer;

    adder_driver     driver;
    adder_monitor    monitor;
    adder_scoreboard scoreboard;

    virtual adder_if vif;


    function new(
        string name = "adder_env",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        sequencer = uvm_sequencer#(adder_transaction)::
                    type_id::create("sequencer", this);

        driver = adder_driver::
                 type_id::create("driver", this);

        monitor = adder_monitor::
                  type_id::create("monitor", this);

        scoreboard = adder_scoreboard::
                     type_id::create("scoreboard", this);

        if ( !uvm_config_db #( virtual adder_if ) :: get( this, "", "vif", vif ) )
        begin
            `uvm_fatal( get_type_name(), "Error in getting" )
        end

        driver.vif  = vif;
        monitor.vif = vif;

    endfunction


    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );

        monitor.ap.connect(
            scoreboard.analysis_export
        );

    endfunction

endclass


//====================================================
// TEST
//====================================================

class adder_test extends uvm_test;

    `uvm_component_utils(adder_test)

    adder_env env;


    function new(
        string name = "adder_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = adder_env::
              type_id::create("env", this);

    endfunction


    task run_phase(uvm_phase phase);

        adder_sequence seq;

        phase.raise_objection(this);

        seq = adder_sequence::type_id::create("seq");

        seq.start(env.sequencer);

        #10;

        phase.drop_objection(this);

    endtask

endclass


//====================================================
// TOP MODULE
//====================================================

module tb_top;

    adder_if intf();

    adder dut (
        .a   (intf.a),
        .b   (intf.b),
        .sum (intf.sum)
    );


    initial begin

        uvm_config_db#(virtual adder_if)::set(
            null,
            "*",
            "vif",
            intf
        );

        run_test("adder_test");

    end

endmodule
