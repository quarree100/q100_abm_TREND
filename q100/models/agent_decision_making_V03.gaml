/**
* Name: agent_decision_making
* Description: Integration of data and first test of the decision making of agents within the framework of q100 
* Author: lennartwinkeler
* Tags: 
*/


model agent_decision_making


global {
	// shape_file example_shapefile <- shape_file("../includes/shapefiles/example.shp");
	// bool show_heatingnetwork <- true;
	// bool show_roads <- true;
	
	
// for choosing specific value -> [columns, rows]

	// data of survey#1 - values for decision-making distributed in six income-groups
	matrix decision_500_1000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_500-1000_V1.csv", ",", float, true));
	matrix decision_1000_1500 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1000-1500_V1.csv", ",", float, true));
	matrix decision_1500_2000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1500-2000_V1.csv", ",", float, true));
	matrix decision_2000_3000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_2000-3000_V1.csv", ",", float, true));
	matrix decision_3000_4000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_3000-4000_V1.csv", ",", float, true));
	matrix decision_4000etc <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_4000etc_V1.csv", ",", float, true));
	
	// data of survey#2 - values for networking distributed in five employment-groups
	matrix network_employed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_employed_V1.csv", ",", int, true));
	matrix network_pensioner <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_pensioner_V1.csv", ",", int, true));
	matrix network_selfemployed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_self-employed_V1.csv", ",", int, true));
	matrix network_student <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_student_V1.csv", ",", int, true));
	matrix network_unemployed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_unemployed_V1.csv", ",", int, true));
	
	
	matrix share_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-income_V1.csv",  ",", float, true)); // share of households in neighborhood sorted by income
	matrix share_employment_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-employment_income_V1.csv", ",", float, true)); // distribution of employment status of households in neighborhood sorted by income
	matrix share_ownership_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-ownership_income_V1.csv", ",", float, true)); // distribution of ownership status of households in neighborhood sorted by income
	
	matrix share_age_buildings_existing <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-age_existing_V2.csv", ",", float, true)); // distribution of groups of age in neighborhood
	matrix average_lor_inclusive <- matrix(csv_file("../includes/csv-data_socio/2021-12-15/wohndauer_nach_alter_inkl_geburtsort.csv", ",", float, true)); //average lenght of residence for different age-groups including people who never moved
	matrix average_lor_exclusive <- matrix(csv_file("../includes/csv-data_socio/2021-12-15/wohndauer_nach_alter_ohne_geburtsort.csv", ",", float, true)); //average lenght of residence for different age-groups ecluding people who never moved

	int nb_units <- 377; // number of households in v1
	float share_families <- 0.17; // share of families in whole neighborhood
	float share_socialgroup_families <- 0.75; // share of families that are part of a social group
	float share_socialgroup_nonfamilies <- 0.29; // share of households that are not families but part of a social group
	
	
	list income_groups_list <- [households_500_1000, households_1000_1500, households_1500_2000, households_2000_3000, households_3000_4000, households_4000etc];
	map share_income_map <- create_map(income_groups_list, list(share_income));
	map decision_map <- create_map(income_groups_list, [decision_500_1000, decision_1000_1500, decision_1500_2000, decision_2000_3000, decision_3000_4000, decision_4000etc]);
	
	list<float> shares_owner_list <- [share_ownership_income[1,0], share_ownership_income[2,0], share_ownership_income[3,0], share_ownership_income[4,0], share_ownership_income[5,0], share_ownership_income[6,0]];	
	map share_owner_map <- create_map(income_groups_list, shares_owner_list); 


	list<float> shares_student_list <- [share_employment_income[1,0], share_employment_income[2,0], share_employment_income[3,0], share_employment_income[4,0], share_employment_income[5,0], share_employment_income[6,0]];
	list<float> shares_employed_list <- [share_employment_income[1,1], share_employment_income[2,1], share_employment_income[3,1], share_employment_income[4,1], share_employment_income[5,1], share_employment_income[6,1]];
	list<float> shares_selfemployed_list <- [share_employment_income[1,2], share_employment_income[2,2], share_employment_income[3,2], share_employment_income[4,2], share_employment_income[5,2], share_employment_income[6,2]];
	list<float> shares_unemployed_list <- [share_employment_income[1,3], share_employment_income[2,3], share_employment_income[3,3], share_employment_income[4,3], share_employment_income[5,3], share_employment_income[6,3]];
	list<float> shares_pensioner_list <- [share_employment_income[1,4], share_employment_income[2,4], share_employment_income[3,4], share_employment_income[4,4], share_employment_income[5,4], share_employment_income[6,4]];
	
	map share_student <- create_map(income_groups_list, shares_student_list);
	map share_employed <- create_map(income_groups_list, shares_employed_list);
	map share_selfemployed <- create_map(income_groups_list, shares_selfemployed_list);
	map share_unemployed <- create_map(income_groups_list, shares_unemployed_list);
	map share_pensioner <- create_map(income_groups_list, shares_pensioner_list);
		


	init { 
		
		loop income_group over: income_groups_list { // creates households of the different income-groups according to the given share in *share_income_map*
			let letters <- ["a", "b", "c", "d"];
			loop i over: range(0,3) { // 4 subgroups a created for each income_group to represent the distribution of the given variables
				create income_group number: share_income_map[income_group] * nb_units * 0.25 {
					float decision_500_1000_CEEK_min <- decision_500_1000[1,i];
					float decision_500_1000_CEEK_1st <- decision_500_1000[1,i+1];
					CEEK <- rnd (decision_500_1000_CEEK_min, decision_500_1000_CEEK_1st);
					float decision_500_1000_CEEA_min <- decision_500_1000[2,i];
					float decision_500_1000_CEEA_1st <- decision_500_1000[2,i+1];
					CEEA <- rnd (decision_500_1000_CEEA_min, decision_500_1000_CEEA_1st);
					float decision_500_1000_EDA_min <- decision_500_1000[3,i];
					float decision_500_1000_EDA_1st <- decision_500_1000[3,i+1];
					EDA <- rnd (decision_500_1000_EDA_min, decision_500_1000_EDA_1st);
					float decision_500_1000_PN_min <- decision_500_1000[4,i];
					float decision_500_1000_PN_1st <- decision_500_1000[4,i+1];
					PN <- rnd (decision_500_1000_PN_min, decision_500_1000_PN_1st);
					float decision_500_1000_SN_min <- decision_500_1000[5,i];
					float decision_500_1000_SN_1st <- decision_500_1000[5,i+1];
					SN <- rnd (decision_500_1000_SN_min, decision_500_1000_SN_1st);
					float decision_500_1000_EEH_min <- decision_500_1000[6,i];
					float decision_500_1000_EEH_1st <- decision_500_1000[6,i+1];
					EEH <- rnd (decision_500_1000_EEH_min, decision_500_1000_EEH_1st);
					float decision_500_1000_PBC_I_min <- decision_500_1000[7,i];
					float decision_500_1000_PBC_I_1st <- decision_500_1000[7,i+1];
					PBC_I <- rnd (decision_500_1000_PBC_I_min, decision_500_1000_PBC_I_1st);
					float decision_500_1000_PBC_C_min <- decision_500_1000[8,i];
					float decision_500_1000_PBC_C_1st <- decision_500_1000[8,i+1];
					PBC_C <- rnd (decision_500_1000_PBC_C_min, decision_500_1000_PBC_C_1st);
					float decision_500_1000_PBC_S_min <- decision_500_1000[9,i];
					float decision_500_1000_PBC_S_1st <- decision_500_1000[9,i+1];
					PBC_S <- rnd (decision_500_1000_PBC_S_min, decision_500_1000_PBC_S_1st);
					id_group <- string(income_group) + "_" + letters[i]; 			
				}
			}
		}
		
				
// Age -> distributes the share of age-groups among the generic-species household
	
		ask (int(share_age_buildings_existing[0] * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (21, 40);
			let share_families_21_40 <- ((share_families * nb_units) / (int(share_age_buildings_existing[0] * nb_units))); // calculates share of families in neighborhood for households with age 21-40
			if flip(share_families_21_40) {
				family <- true;
			}	
		}
		ask (int(share_age_buildings_existing[1] * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (41, 60);	
		}
		ask (int(share_age_buildings_existing[2] * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (61, 80);	
		}
		ask (int(share_age_buildings_existing[3] * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (81, 100); //max age = 100	
		}
		
		
// Ownership -> distributes the share of ownership-status among household-groups 
	
		loop income_group over: income_groups_list {
			ask income_group {
				ownership <- "tenant";
			}
			
			ask int(share_owner_map[income_group] * length(income_group)) among income_group { 
				ownership <- "owner";
			}
		}
		
	
// Employment -> distributes the share of employment-groups among income-groups

		loop income_group over: income_groups_list {
			ask round(share_student[income_group] * length(income_group)) among income_group{
				employment <- "student";
			}
			ask round(share_selfemployed[income_group] * length(income_group)) among income_group where (each.employment = nil) {
			}
			ask round(share_unemployed[income_group] * length(income_group)) among income_group where (each.employment = nil) {
				employment <- "unemployed";
			}
			ask round(share_pensioner[income_group] * length(income_group)) among income_group where (each.employment = nil) {
				employment <- "pensioner";
			}
			ask income_group where (each.employment = nil) { // all remaining households are assinged to 'employed'
				employment <- "employed";
			}

		}
		
		

		
//Network -> distributes the share of network-relations among the households. there are different network values for each employment status
		let employment_status_list of: string <- ["student", "employed", "self-employed", "unemployed", "pensioner"]; 

		let network_map <- create_map(employment_status_list, [network_student, network_employed, network_selfemployed, network_unemployed, network_pensioner]);
		let temporal_network_attributes <- households.attributes where (each contains "network_contacts_temporal"); // list of all temporal network variables
		let spatial_network_attributes <- households.attributes where (each contains "network_contacts_spatial"); // list of all spatial network variables
		loop emp_status over: employment_status_list { //iterate over the different employment states
			let tmp_households <- agents of_generic_species households where (each.employment = emp_status); //temporary list of households with the current employment status
			let nb <- length(tmp_households); 
			let network_matrix <- network_map[emp_status]; //corresponding matrix of network values
			loop attr over: temporal_network_attributes { //loop over the different temporal network variables of each household
				let index <- index_of(temporal_network_attributes, attr);
				loop i over: range(0, 3) { // loop to split the households in 4 quartiles
					ask (0.25 * nb) among tmp_households where (!bool(self[attr])){
						self[attr] <- rnd(network_matrix[index+2, i],network_matrix[index+2, i+1]);
					}
				}
			}
			loop attr over: spatial_network_attributes { // loop over the different spatial network variables of each household
				let index <- index_of(spatial_network_attributes, attr);
				loop i over: range(0, 3) {// loop to split the households in 4 quarters
					ask (0.25 * nb) among tmp_households where (!bool(self[attr])){
						self[attr] <- rnd(network_matrix[index+6, i],network_matrix[index+6, i+1]);
					}
				}
			}
		}
		
		ask agents of_generic_species households where (bool(each.family)) {
			if flip (share_socialgroup_families) {
				network_socialgroup <- true;
			}	
		}
		ask agents of_generic_species households where (!bool(each.family)) {
			if flip (share_socialgroup_nonfamilies) {
				network_socialgroup <- true;
			}	
		} 	
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
	float EEH; // Energy Efficient Habits
	
	
	int income; // households income/month -> ATTENTION -> besonderer Validierungshinweis, da zufaellige Menge
	string id_group; // identification which quartile within the income group the agent belongs to
		
	int age; // random mean-age of households
	int lenght_of_residence <- 0; //years since the household moved in
	string ownership; // type of ownership status of households
	string employment; // employment status of households !!!
		


	// defines network behavior of each agent in parent species by employment status
	int network_contacts_temporal_daily; // amount of agents a household has daily contact with - 30x / month
	int network_contacts_temporal_weekly; // amount of agents a household has weekly contact with - 4x / month
	int network_contacts_temporal_occasional; // amount of agents a household has occasional contact with - 1x / month
	int network_contacts_spatial_direct; // available amount of contacts within an households network - direct neighbors
	int network_contacts_spatial_street; // available amount of contacts within an households network - contacts in the same street
	int network_contacts_spatial_neighborhood; // available amount of contacts within an households network - contacts in the same neighborhood
	int network_contacts_spatial_beyond; // available amount of contacts within an households network - contacts beyond the system's environment TODO

	bool family; // represents young families - higher possibility of being part of a socialgroup
	bool network_socialgroup; // households are part of a social group - accelerates the networking behavior
	

	
	
	action update_decision_thresholds{
		/* calculate household's current knowledge (0 <= KA <= 1),
		motivation (0 <= PSN <= 1) and
		consideration (0 <= N_PBC <= 1) **/ 
		KA <- mean(CEEK, CEEA, EDA) / 7;
		PSN <- mean(PN, SN) / 7;
		N_PBC <- mean(PBC_I, PBC_C, PBC_S) / 7;
	}
	
	reflex move_out {
		age <- age + 1;
		lenght_of_residence <- lenght_of_residence + 1;
		if age >= 100 {
			do die;
		}
		let current_age_group type: int <- floor(age / 20) - 1; // age-groups are represented with integers. Each group spans 20 years with 0 => [20,39], 1 => [40,59] ...
		let moving_prob type: float <- 1 / average_lor_inclusive[1, current_age_group];
		if flip(moving_prob) {
			do die;
		}
	}

} 


species households_500_1000 parent: households {
	
	aspect base {
		draw circle(1) color: #green; // test-darstellung
	}
	
	int income <- rnd(500, 1000);

	
}

species households_1000_1500 parent: households {
	
	aspect base {
		draw circle(1) color: #red; // test-darstellung
	}

	int income <- rnd(1000, 1500);
	
	
}

species households_1500_2000 parent: households {
	
	aspect base {
		draw circle(1) color: #blue; // test-darstellung
	}

	int income <- rnd(1500, 2000);

	
}

species households_2000_3000 parent: households {
	
	aspect base {
		draw circle(1) color: #yellow; // test-darstellung
	}

	int income <- rnd(2000, 3000);

	
}

species households_3000_4000 parent: households {
	
	aspect base {
		draw circle(1) color: #purple; // test-darstellung
	}
	
	int income <- rnd(3000, 4000);
	
	
}

species households_4000etc parent: households {
	
	aspect base {
		draw circle(1) color: #grey; // test-darstellung
	}
	
	int income <- rnd(4000, 10000); // max income / month = 10.000
	
	
}


	// grid vegetation_cell width: 50 height: 50 neighbors: 4 {} -> Bei derzeitiger Vorstellung wird kein grid benötigt; ggf mit qScope-Tisch-dev abgleichen

experiment agent_decision_making type: gui{
	
  	// parameter "example" var: example (muss global sein) min: 1 max: 1000 category: "example";
	
	output {
		layout #split;
		display neighborhood {
			
			species households_500_1000 aspect: base;
			species households_1000_1500 aspect: base;
			species households_1500_2000 aspect: base;
			species households_2000_3000 aspect: base;
			species households_3000_4000 aspect: base;
			species households_4000etc aspect: base; 
		}		
	
		display "charts" {
			chart "households" type: histogram {
				data "households_500-1000" value: length (households_500_1000) color:#green;
				data "households_1000-1500" value: length (households_1000_1500) color:#red;
				data "households_1500-2000" value: length (households_1500_2000) color:#blue;
				data "households_2000-3000" value: length (households_2000_3000) color:#yellow;
				data "households_3000-4000" value: length (households_3000_4000) color:#purple;
				data "households_>4000" value: length (households_4000etc) color:#grey;
				data "total" value: sum (length (households_500_1000), length (households_1000_1500),length (households_1500_2000), length (households_2000_3000), length (households_3000_4000), length (households_4000etc)) color:#black;
			}
		}
	}
}