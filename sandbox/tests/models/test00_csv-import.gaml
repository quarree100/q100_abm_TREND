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
		write csv.contents; // gibt Semikolon-getrennte csv aus
		map<int, int> csvmap <- csv.contents; // weist contents einer Map aus integern zu
		write csvmap[12]; // Zugriff nicht über Indizes! Sondern über konkrete Werte
		
		matrix csvmatrix <- csv_file("../includes/data.csv");
		write csvmatrix[4]; // gibt Wert bei Index 4 aus --> Indizes läuft nach Zeilenumbruch weiter
	}
}

experiment csv_test type:gui{
	
}
