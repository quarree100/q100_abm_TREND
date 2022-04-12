/**
* Name: executionordertest
* Based on the internal empty template. 
* Author: lennartwinkeler
* Tags: 
*/

model execution_order_test

global {
	init {
		create test_species number: 3;
	
	}
	
	reflex global_reflex {
		write " GLOBAL reflex";
		write " ------- ";
	}
}

species test_species {
	
	reflex first_reflex {
		write "" + self + " in FIRST reflex";
	}
	reflex second_reflex {
		write "" + self + " in SECOND reflex";
	}	
}



experiment NewModel type: gui  { }