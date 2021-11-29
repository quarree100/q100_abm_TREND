/**
* Name: test03askspecificagents
* Based on the internal empty template. 
* Author: lennartwinkeler
* Tags: 
*/


model test03askspecificagents

/* Insert your model definition here */



global{
	
	float test;
	int test2 <- (0,25 * 100);
	
	
	init {
		create households number: 100;
		
		
		
		ask 50 among households {
			employment <- "employed";
		}
		
		
		
		ask test among households {
			 
			test1 <- 5000;
			test <- 25;
					
				
			
		} 
		 
	}
		 	
}


species households{
	string employment <- "student";
	int test1;
	
	aspect base {
		if test1 = 5000 {
			draw circle(1) color: #red;
		}
		else {
			draw triangle(1) color: #blue;
		}
	} 
	
}

experiment test1 type: gui{
	
	output{
		
		display test2 {
			species households aspect: base;
		} 
	}
}