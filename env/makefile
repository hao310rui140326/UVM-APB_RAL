RTL_SRC = ../rtl/

IF = ./apb_if.sv
RTL = ../rtl/traffic.sv
REFMOD = 
PKGS = ./my_pkg.sv 

SEED = 100
COVER = 100
TRANSA = 5000
##CASE = block_test
CASE = blk_R_test

verdi_path = /usr/synopsys/Verdi3_L-2016.06-1
uvm_path = ../uvm-1.2
##uvm_path = ../uvm-1.1d

RUN_ARGS_COMMON = -access +r -input shm.tcl \
          +uvm_set_config_int=*,recording_detail,1 -coverage all -covoverwrite


vcs_sim:
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8  -lca -timescale=1ns/1ps  -P  $(verdi_path)/share/PLI/VCS/LINUX64/novas.tab   $(verdi_path)/share/PLI/VCS/LINUX64/pli.a +vcs+lic+wait +vcd+vcdpluson  -sverilog  $(uvm_path)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS  +verilog2001ext+.v  +lint=TFIPC-L   +define+UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTO  -debug_pp  +incdir+$(uvm_path)/src   $(uvm_path)/src/uvm_pkg.sv  +incdir+$(uvm_path)/examples/integrated/apb    blk_run.sv       -cm line+cond+fsm+tgl+branch+assert -cm_dir ./cov_info      -l vcs_com.log ; 
	./simv   +UVM_TESTNAME=$(CASE)  +UVM_VERBOSITY=UVM_LOW   -cm line+cond+fsm+tgl+branch+assert -cm_dir  ./cov_info         -l vcs_sim.log 


clean:
	@rm -rf INCA_libs waves.shm rtlsim/* *.history *.log rtlsim/* *.key mdv.log imc.log imc.key ncvlog_*.err *.trn *.dsn .simvision/ xcelium.d simv.daidir *.so *.o *.err  simv*   cov_info*  csrc novas*  verdiLog vc_hdrs.h  DVEfiles  vcdplus.vpd 

rebuild: clean vcs_sim

view_waves:
	simvision waves.shm &

view_cover:
	imc &
