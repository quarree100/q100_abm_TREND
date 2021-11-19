/**
* Name: csvtest
* Based on the internal empty template. 
* Author: dunland
* Tags: 
*/


model csvtest

/* Insert your model definition here */

global{
	init{
		csv_file csv <- ("../includes/data.csv");
		write csv.contents;
		map<int, int> csvmap <- csv.contents;
		write csvmap[12];
		
		matrix csvmatrix <- csv_file("../includes/data.csv");
		write csvmatrix[4];
	}
}

experiment csv_test type:gui{
	
}