class ahb_agent;
	ahb_gen gen;
	ahb_mon mon;
	ahb_bfm bfm;
//	ahb_cov cov;

	function new();
		gen=new();
		mon=new();
		bfm=new();
		//cov=new();
	endfunction

	task run();
		fork 
			gen.run();
			bfm.run();
			#1;
			mon.run();
		join
		$display("inside agent");
	endtask
endclass
