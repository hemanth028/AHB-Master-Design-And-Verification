class ahb_env;
	ahb_agent agent;
	ahb_sbd sbd;

	function new();
		agent=new();
		sbd=new();
	endfunction

	task run();
		fork
			agent.run();
			#1;
			sbd.run();
		join
		$display("inside environment");
	endtask
endclass
