RTL_SRC = ../rtl/

IF = ./apb_if.sv
RTL = ../rtl/traffic.sv
REFMOD = 
PKGS = ./my_pkg.sv 

SEED = 100
COVER = 100
TRANSA = 5000

verdi_path = /usr/synopsys/Verdi3_L-2016.06-1

RUN_ARGS_COMMON = -access +r -input shm.tcl \
          +uvm_set_config_int=*,recording_detail,1 -coverage all -covoverwrite

sim:
	@xrun -64bit -uvm  +incdir+$(RTL_SRC) $(IF) $(PKGS) $(RTL) top.sv \
	+UVM_TESTNAME=reg_rw_test -covtest reg_rw_test-$(SEED) -svseed $(SEED)  \
	-defparam top.min_cover=$(COVER) -defparam top.min_transa=$(TRANSA) $(RUN_ARGS_COMMON) $(RUN_ARGS)

vcs_sim:
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8  -lca -timescale=1ns/1ps  -P  $(verdi_path)/share/PLI/VCS/LINUX64/novas.tab   $(verdi_path)/share/PLI/VCS/LINUX64/pli.a +vcs+lic+wait +vcd+vcdpluson  -sverilog +verilog2001ext+.v  +lint=TFIPC-L  -ntb_opts  +define+UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTO  -debug_all  +incdir+$(UVM_HOME)/src   $(UVM_HOME)/src/uvm_pkg.sv  +incdir+$(RTL_SRC)   $(IF) $(PKGS) $(RTL) top.sv      -cm line+cond+fsm+tgl -cm_dir ./cov_info      -l vcs_com.log ; 
	./simv    +model_data+"./"   +UVM_TESTNAME=reg_rw_test  +UVM_VERBOSITY=UVM_LOW   -cm line+cond+fsm+tgl -cm_dir  ./cov_info         -l vcs_sim.log 


clean:
	@rm -rf INCA_libs waves.shm rtlsim/* *.history *.log rtlsim/* *.key mdv.log imc.log imc.key ncvlog_*.err *.trn *.dsn .simvision/ xcelium.d simv.daidir *.so *.o *.err  simv*   cov_info*  csrc

rebuild: clean sim

view_waves:
	simvision waves.shm &

view_cover:
	imc &
