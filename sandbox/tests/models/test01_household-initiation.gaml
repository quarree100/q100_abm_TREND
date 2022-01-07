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
	matrix decision_1000_1500 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1000-1500_V1.csv",true);
	matrix decision_1500_2000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1500-2000_V1.csv",true);
	matrix decision_2000_3000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_2000-3000_V1.csv",true);
	matrix decision_3000_4000 <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_3000-4000_V1.csv",true);
	matrix decision_4000etc <- csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_4000etc_V1.csv",true);
	
	matrix network_employed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_employed_V1.csv",true);
	matrix network_pensioner <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_pensioner_V1.csv",true);
	matrix network_selfemployed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_self-employed_V1.csv",true);
	matrix network_student <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_student_V1.csv",true);
	matrix network_unemployed <- csv_file("../includes/csv-data_socio/2021-11-18_V1/network_unemployed_V1.csv",true);
	
	matrix share_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-income_V1.csv",true); // share of households in neighborhood sorted by income
	matrix share_employment_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-employment_income_V1.csv",true);
	matrix share_tenants_income <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-tenants_income_V1.csv",true);
	matrix share_age_buildings_existing <- csv_file("../includes/csv-data_socio/2021-11-18_V1/share-age_existing_V1.csv",true);
	
	
	//bool show_heatingnetwork <- true;
	//bool show_roads <- true;
	
	int nb_units <- 623; //eigentlich: zähle anzahl der freien wohneinheiten -> Wert -> Berechne anschließend Anzahl der inits anhand share-of Einkommensgruppe an Gesamthaushalten
	float nb_households_500_1000 <- share_income[0]; //FRAGE: Wieso ist eine direkte Berechnung eines Wertes aus der Matrix mit "*" nicht möglich???
	float nb_households_1000_1500 <- share_income[1];
	float nb_households_1500_2000 <- share_income[2];
	float nb_households_2000_3000 <- share_income[3];
	float nb_households_3000_4000 <- share_income[4];
	float nb_households_4000etc <- share_income[5];
	
		

	init { //erster Versuch der Integration der Zahl der Haushalte; Schritt 2 -> Ausrichten an Anzahl der im GIS-Datensatz hinterlegten freien Wohnungen
		create households_500_1000 number: 5{
			
		}
		create households_500_1000 number: 5{ // schrittweise Erstellung des gleichen Agententyps mit unterschiedlichen Werten ist möglich
			
		}
		

	 
	}	/////////////////////////////////////TO-DO//////////////////////////////////////
	//////////	- übertragen der csv-dateien in matritzen --- fertig
	//////////	- berechnen und initiieren der anderen Gehaltsagenten --- fertig
	//////////	- nächster Schritt: Übertragen der psych. Werte auf einzelne Agentengruppen --- unfertig	
		////////////////////////////////////////////////////////////////////////////////
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
	
	
	int income; //households income/month -> ATTENTION -> besonderer Validierungshinweis, da zufaellige Menge
	string employment; //defines network behavior of each agent in parent species by employment status
	string tenants; 
	int age; //random mean-age of households
	
} 

species households_500_1000 parent: households {
	
	aspect base {
		draw circle(1) color: #green; //test-darstellung
	}
	
}

species households_1000_1500 parent: households {
	
	aspect base {
		draw circle(1) color: #red; //test-darstellung
	}
	
}

species households_1500_2000 parent: households {
	
	aspect base {
		draw circle(1) color: #blue; //test-darstellung
	}
	
}

species households_2000_3000 parent: households {
	
	aspect base {
		draw circle(1) color: #yellow; //test-darstellung
	}
	
}

species households_3000_4000 parent: households {
	
	aspect base {
		draw circle(1) color: #purple; //test-darstellung
	}
	
}

species households_4000etc parent: households {
	
	aspect base {
		draw circle(1) color: #grey; //test-darstellung
	}
	
}

// grid vegetation_cell width: 50 height: 50 neighbors: 4 {} -> Bei derzeitiger Vorstellung wird kein grid benötigt; bei Bedarf mit qScope-Tisch abgleichen

experiment agent_decision_making type: gui{
	
  	// parameter "example" var: example (muss global sein) min: 1 max: 1000 category: "example";
	
	output {
		// layout #split; eigtl toll, bringt aber lwinkelers gama zum crashen
		display neighborhood type:opengl {
			
			//oder aspect: icon?
			species households_500_1000 aspect: base;
			species households_1000_1500 aspect: base;
			species households_1500_2000 aspect: base;
			species households_2000_3000 aspect: base;
			species households_3000_4000 aspect: base;
			species households_4000etc aspect: base; 
		}		
	
		display "charts" {
			chart "households" type: histogram {
				data "households_500-1000" value: households_500_1000 count (each.income >= 0) color:#green;
				data "households_1000-1500" value: households_1000_1500 count (each.income >= 0) color:#red;
				data "households_1500-2000" value: households_1500_2000 count (each.income >= 0) color:#blue;
				data "households_2000-3000" value: households_2000_3000 count (each.income >= 0) color:#yellow;
				data "households_3000-4000" value: households_3000_4000 count (each.income >= 0) color:#purple;
				data "households_>4000" value: households_4000etc count (each.income >= 0) color:#grey;
			}
		}
	}
}