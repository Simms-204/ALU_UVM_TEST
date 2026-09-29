# ============================================================
# Verilator Makefile for ALU UVM Project
# ============================================================

VERILATOR = verilator

# Find project root relative to this Makefile
PROJECT_ROOT = $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

# UVM installation
#UVM_HOME ?= $(HOME)/uvm/1800.2-2020.3.2/src

UVM_HOME ?= $(HOME)/backup/uvm/1800.2-2020.3.2/src
# ------------------------------------------------------------
# Include directories
# ------------------------------------------------------------
# The ALU DUT, interface, transaction, driver, monitors,
# scoreboard, env, test and top module all live in a single
# flat testbench file under tb/, so there is no separate
# rtl/, test/ or agent split to include.

INC = \
	+incdir+$(UVM_HOME) \
	+incdir+$(PROJECT_ROOT)/tb \
	+incdir+$(PROJECT_ROOT)/sim


# ------------------------------------------------------------
# Compile-time definitions
# ------------------------------------------------------------

DEFINES = \
	+define+UVM_NO_DPI


# ------------------------------------------------------------
# Source files
# ------------------------------------------------------------

UVM_SRC = $(UVM_HOME)/uvm_pkg.sv

# Single flat file: ALU DUT + ALU_IF + write_xtn + sequence +
# driver + monitors + sequencer + agent + scoreboard + env +
# random_test + directed_test + cross_test + module top
TB_SRC = \
	 $(PROJECT_ROOT)/tb/alu_uvm_tb_with_clock.sv


# ------------------------------------------------------------
# Verilator options
# ------------------------------------------------------------

VERILATOR_FLAGS = \
	-Wno-fatal \
	-Wno-TIMESCALEMOD \
	--timing \
	--coverage \
	--top-module top \
	-j $(shell nproc)


# ------------------------------------------------------------
# Coverage files and directories
# ------------------------------------------------------------

COVERAGE_DIR = $(PROJECT_ROOT)/coverage

CROSS_COV    = $(COVERAGE_DIR)/coverage_cross.dat
RANDOM_COV   = $(COVERAGE_DIR)/coverage_random.dat
DIRECTED_COV = $(COVERAGE_DIR)/coverage_directed.dat

MERGED_COV = $(COVERAGE_DIR)/merged.dat

ANNOTATED_DIR = $(COVERAGE_DIR)/annotated

SUMMARY_FILE = $(COVERAGE_DIR)/coverage_summary.txt
BINS_FILE = $(COVERAGE_DIR)/coverage_bins.txt


# ------------------------------------------------------------
# Targets
# ------------------------------------------------------------

.PHONY: help \
	lint \
	build \
	run \
	run_cross \
	run_random \
	run_directed \
	coverage_cross \
	coverage_random \
	coverage_directed \
	merge_coverage \
	coverage_bins \
	coverage_report \
	coverage \
	regression \
	clean


# ============================================================
# Help
# ============================================================

help:
	@echo "ALU Verilator UVM - run 'make <target>' from sim/"
	@echo ""
	@echo "  lint               Verilator lint/checks only"
	@echo "  build              build DUT + UVM testbench (coverage enabled)"
	@echo "  run                run random_test, directed_test and cross_test"
	@echo "  run_cross          run cross_test (op x a-bin x b-bin sweep only)"
	@echo "  run_random         run random_test (ALU_SEQUENCE only)"
	@echo "  run_directed       run directed_test (corner-case vectors only)"
	@echo "  coverage_cross     run cross_test -> coverage_cross.dat"
	@echo "  coverage_random    run random_test -> coverage_random.dat"
	@echo "  coverage_directed  run directed_test -> coverage_directed.dat"
	@echo "  merge_coverage     merge whichever .dat files exist"
	@echo "  coverage_bins      list every ALU_COVERAGE bin as HIT/MISS"
	@echo "  coverage_report    annotate + summarize merged coverage"
	@echo "  coverage           build + coverage_cross + merge + report"
	@echo "  regression         build + all 3 tests + merge + report"
	@echo "  clean              remove obj_dir/ and coverage/"


# ============================================================
# Lint
# ============================================================

lint:
	$(VERILATOR) \
		$(VERILATOR_FLAGS) \
		--lint-only \
		$(INC) \
		$(DEFINES) \
		$(UVM_SRC) \
		$(TB_SRC)


# ============================================================
# Build
# ============================================================

build:
	$(VERILATOR) \
		$(VERILATOR_FLAGS) \
		--binary \
		$(INC) \
		$(DEFINES) \
		$(UVM_SRC) \
		$(TB_SRC)


# ============================================================
# Normal simulation
# ============================================================

run: run_random run_directed run_cross

run_random:
	./obj_dir/Vtop +UVM_TESTNAME=random_test

run_directed:
	./obj_dir/Vtop +UVM_TESTNAME=directed_test

run_cross:
	./obj_dir/Vtop +UVM_TESTNAME=cross_test


# ============================================================
# Coverage runs
# ============================================================
# Three UVM_TESTNAMEs share the one compiled binary (base_test itself
# only builds the environment and runs no stimulus):
#   random_test   - ALU_SEQUENCE only
#   directed_test - ALU_DIRECTED_SEQUENCE (the fixed corner-case vectors) only
#   cross_test    - ALU_CROSS_SEQUENCE (every op x a-bin x b-bin) only
# Each writes its own .dat file so the regression's merged coverage
# reflects all three runs together.

coverage_cross:
	mkdir -p $(COVERAGE_DIR)
	./obj_dir/Vtop \
		+UVM_TESTNAME=cross_test \
		+verilator+coverage+file+$(CROSS_COV)

coverage_random:
	mkdir -p $(COVERAGE_DIR)
	./obj_dir/Vtop \
		+UVM_TESTNAME=random_test \
		+verilator+coverage+file+$(RANDOM_COV)

coverage_directed:
	mkdir -p $(COVERAGE_DIR)
	./obj_dir/Vtop \
		+UVM_TESTNAME=directed_test \
		+verilator+coverage+file+$(DIRECTED_COV)


# ============================================================
# Merge coverage
# ============================================================
# Merges the coverage .dat files from whichever of the three runs
# have been generated so far (random/directed/cross), so this works
# whether you ran `coverage` (cross only) or `regression` (all three).

merge_coverage:
	verilator_coverage \
		--write $(MERGED_COV) \
		$(wildcard $(RANDOM_COV) $(DIRECTED_COV) $(CROSS_COV))


# ============================================================
# Per-bin functional coverage: every ALU_COVERAGE coverpoint/cross
# bin as HIT (n>0) or MISS (n=0), read straight out of merged.dat.
# verilator_coverage's own --annotate output is line/branch/toggle
# annotation of every source file (including the UVM library), which
# buries the handful of bins that actually matter here - this pulls
# just the covergroup entries out and prints them as a flat list.
# ============================================================

coverage_bins:
	@mkdir -p $(COVERAGE_DIR)
	@{ \
		echo "ALU_COVERAGE bins (HIT = sampled at least once, MISS = never hit):"; \
		echo "--------------------------------------------------------------"; \
		grep "__vlAnonCG_alu_cg\." $(MERGED_COV) | \
			awk '{ \
				n = split($$0, parts, " "); \
				hits = parts[n] + 0; \
				match($$0, /__vlAnonCG_alu_cg\.[^'"'"']+/); \
				bin = substr($$0, RSTART, RLENGTH); \
				sub(/^__vlAnonCG_alu_cg\./, "", bin); \
				status = (hits > 0) ? "HIT " : "MISS"; \
				printf "  [%s] %-30s hits=%d\n", status, bin, hits; \
				if (hits > 0) hit_n++; else miss_n++; \
				total++; \
				cp = bin; sub(/\..*$$/, "", cp); \
				if (!(cp in cp_total)) cp_order[++cp_n] = cp; \
				cp_total[cp]++; \
				if (hits > 0) cp_hit[cp]++; \
			} END { \
				printf "--------------------------------------------------------------\n"; \
				printf "Per coverpoint / cross:\n"; \
				printf "  %-16s %6s %6s %6s %9s\n", "NAME", "HIT", "MISS", "TOTAL", "COVERAGE"; \
				for (i = 1; i <= cp_n; i++) { \
					cp = cp_order[i]; \
					printf "  %-16s %6d %6d %6d %8.2f%%\n", cp, cp_hit[cp], cp_total[cp] - cp_hit[cp], cp_total[cp], 100.0 * cp_hit[cp] / cp_total[cp]; \
				} \
				printf "--------------------------------------------------------------\n"; \
				printf "Bins hit     : %d\n", hit_n; \
				printf "Bins missed  : %d\n", miss_n; \
				printf "Total bins   : %d\n", total; \
				printf "Functional coverage: %.2f%% (%d/%d bins hit)\n", (total > 0) ? 100.0 * hit_n / total : 0, hit_n, total; \
			}'; \
	} | tee $(BINS_FILE)


# ============================================================
# Generate annotated coverage report
# ============================================================

coverage_report: coverage_bins
	rm -rf $(ANNOTATED_DIR)
	mkdir -p $(ANNOTATED_DIR)

	verilator_coverage \
		--annotate $(ANNOTATED_DIR) \
		$(MERGED_COV) \
		> $(SUMMARY_FILE).tmp
	cat $(BINS_FILE) $(SUMMARY_FILE).tmp > $(SUMMARY_FILE)
	rm -f $(SUMMARY_FILE).tmp

	@echo ""
	@echo "============================================================"
	@echo " Coverage Report Generated"
	@echo "============================================================"
	@echo ""
	@echo "Summary:"
	@cat $(SUMMARY_FILE)
	@echo ""
	@echo "Summary file:"
	@echo "  $(SUMMARY_FILE)"
	@echo ""
	@echo "Annotated source:"
	@echo "  $(ANNOTATED_DIR)"
	@echo ""
	@echo "Merged coverage:"
	@echo "  $(MERGED_COV)"
	@echo ""
	@echo "============================================================"
	@echo ""


# ============================================================
# Complete coverage flow
# ============================================================

coverage: build coverage_cross merge_coverage coverage_report


# ============================================================
# Full regression: all three tests, one merged coverage report
# ============================================================

regression: build coverage_random coverage_directed coverage_cross merge_coverage coverage_report


# ============================================================
# Clean
# ============================================================

clean:
	rm -rf obj_dir
	rm -rf $(COVERAGE_DIR)
