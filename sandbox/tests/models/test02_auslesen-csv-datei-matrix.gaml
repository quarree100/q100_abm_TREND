/**
* Name: agent_decision_making
* Based on the internal empty template. 
* Author: lennartwinkeler
* Tags: 
*/


model agent_decision_making


global {
	//shape_file example_shapefile <- shape_file("../includes/shapefiles/example.shp");
	
	matrix decision_500_1000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_500-1000_V1.csv",true);
	csv_file decision_1000_1500 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1000-1500_V1.csv",true);
	csv_file decision_1500_2000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1500-2000_V1.csv",true);
	csv_file decision_2000_3000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_2000-3000_V1.csv",true);
	csv_file decision_3000_4000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_3000-4000_V1.csv",true);
	csv_file decision_4000etc <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_4000etc_V1.csv",true);
	
	csv_file network_employed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_employed_V1.csv",true);
	csv_file network_pensioner <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_pensioner_V1.csv",true);
	csv_file network_selfemployed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_self-employed_V1.csv",true);
	csv_file network_student <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_student_V1.csv",true);
	csv_file network_unemployed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_unemployed_V1.csv",true);
	
	matrix share_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-income_V1.csv",true);
	csv_file share_employment_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-employment_income_V1.csv",true);
	csv_file share_tenants_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-tenants_income_V1.csv",true);
	csv_file share_age_buildings_existing <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-age_existing_V1.csv",true);
	
	
	bool show_heatingnetwork <- true;
	bool show_roads <- true;
	int nb_households <- 623; //eigentlich: zähle anzahl der freien wohnungen -> Wert -> Berechne anschließend Anzahl der inits anhand share-of Einkommensgruppe an Gesamthaushalten
	float share_of_hh_income; //in Bearbeitung
	
	
		

	init { //erster Versuch der Integration der Zahl der Haushalte; Schritt 2 -> Ausrichten an Anzahl der im GIS-Datensatz hinterlegten freien Wohnungen
		create households_500_1000 number: nb_households * share_of_hh_income;
		
		/* write share_income.contents;
		map<int, int> csvmap <- csv.contents;
		write csvmap[12]; */
		
		write decision_500_1000[1, 3]; //Abfragen des exakten Wertes aus der csv-Datei; Lösung durch Erstellung einer Matrix
		 
	}	
	
}

species households {
	float CEEK; // Climate-Energy-Environment Knowledge
	float CEEA; // Climate-Energy-Environment Awareness
	float EDA; // Energy-Related-Decision Awareness
	float KA; // ---Decision-Threshold---: Knowledge & Awareness
	float PN; // Personal Norms
	float SN; // Subjective Norms
	float PSN; // ---Decicision-Threshold---: Personal & Subjective Norms
	float PBC_I; // Perceived-Behavioral-Control Invest
	float PBC_C; // Perceived-Behavioral-Control Change
	float PBC_S; // Perceived-Behavioral-Control Switch
	float N_PBC; // ---Decicision-Threshold---: Normative Perceived Behavioral Control
	float EHH; // Energy Efficient Habits
	
	
	
} 

species households_500_1000 parent: households {
	
	int income; //households income/month -> ATTENTION -> besonderer Validierungshinweis, da zufaellige Menge
	
}

// grid vegetation_cell width: 50 height: 50 neighbors: 4 {} -> Bei derzeitiger Vorstellung wird kein grid benötigt; bei Bedarf mit qScope-Tisch abgleichen

experiment agent_decision_making type: gui{
	
  	// parameter "example" var: example (muss global sein) min: 1 max: 1000 category: "example";
	
	
		
	
}