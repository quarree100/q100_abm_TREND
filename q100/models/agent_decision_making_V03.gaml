/**
* Name: agent_decision_making
* Description: Integration of data and first test of the decision making of agents within the framework of q100 
* Author: lennartwinkeler
* Tags: 
*/


model agent_decision_making


global {
	//shape_file example_shapefile <- shape_file("../includes/shapefiles/example.shp");

// for choosing specific value -> [columns, rows]		
	matrix decision_500_1000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_500-1000_V1.csv", ",", float, true));
	matrix decision_1000_1500 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1000-1500_V1.csv", ",", float, true));
	matrix decision_1500_2000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1500-2000_V1.csv", ",", float, true));
	matrix decision_2000_3000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_2000-3000_V1.csv", ",", float, true));
	matrix decision_3000_4000 <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_3000-4000_V1.csv", ",", float, true));
	matrix decision_4000etc <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_4000etc_V1.csv", ",", float, true));
	
	matrix network_employed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_employed_V1.csv", ",", float, true));
	matrix network_pensioner <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_pensioner_V1.csv", ",", float, true));
	matrix network_selfemployed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_self-employed_V1.csv", ",", float, true));
	matrix network_student <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_student_V1.csv", ",", float, true));
	matrix network_unemployed <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_unemployed_V1.csv", ",", float, true));
	
	matrix share_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-income_V1.csv",  ",", float, true)); // share of households in neighborhood sorted by income
	matrix share_employment_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-employment_income_V1.csv", ",", float, true));
	matrix share_ownership_income <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-ownership_income_V1.csv", ",", float, true));
	matrix share_age_buildings_existing <- matrix(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-age_existing_V2.csv", ",", float, true));
	
	
	//bool show_heatingnetwork <- true;
	//bool show_roads <- true;
	

	int nb_units <- 377; // derzeit: anzahl Wohnungen-Bestand; eigentlich: zähle anzahl der freien wohneinheiten -> Wert -> Berechne anschließend Anzahl der inits anhand share-of Einkommensgruppe an Gesamthaushalten
	list income_groups_list <- [households_500_1000, households_1000_1500, households_1500_2000, households_2000_3000, households_3000_4000, households_4000etc];
	map decision_map <- create_map(income_groups_list, [decision_500_1000, decision_1000_1500, decision_1500_2000, decision_2000_3000, decision_3000_4000, decision_4000etc]);
	map share_income_map <- create_map(income_groups_list, list(share_income));


// share of age in neighborhood
	float share_age_21_40 <- share_age_buildings_existing[0];
	float share_age_41_60 <- share_age_buildings_existing[1];
	float share_age_61_80 <- share_age_buildings_existing[2];
	float share_age_80etc <- share_age_buildings_existing[3];	
	
	
	
// share of households in neighborhood sorted by income
	float nb_households_500_1000 <- share_income[0];
	float nb_households_1000_1500 <- share_income[1];
	float nb_households_1500_2000 <- share_income[2];
	float nb_households_2000_3000 <- share_income[3];
	float nb_households_3000_4000 <- share_income[4];
	float nb_households_4000etc <- share_income[5];
	
	
	
	
	
	
// share of ownerships sorted by income	
	float share_owner_500_1000 <- share_ownership_income[1,0];
	float share_tenants_500_1000 <- share_ownership_income[1,1];
	float share_owner_1000_1500 <- share_ownership_income[2,0];
	float share_tenants_1000_1500 <- share_ownership_income[2,1];
	float share_owner_1500_2000 <- share_ownership_income[3,0];
	float share_tenants_1500_2000 <- share_ownership_income[3,1];
	float share_owner_2000_3000 <- share_ownership_income[4,0];
	float share_tenants_2000_3000 <- share_ownership_income[4,1];
	float share_owner_3000_4000 <- share_ownership_income[5,0];
	float share_tenants_3000_4000 <- share_ownership_income[5,1];
	float share_owner_4000etc <- share_ownership_income[6,0];
	float share_tenants_4000etc <- share_ownership_income[6,1];
	
	//to discuss: sinnvoll die zeilen code zu sparen und matritzen direkt in liste überführen? also keine extra globals anlegen? oder werden diese ggf an anderer stelle nochmal benötigt bzw sorgen für bessere übersichtlichkeit?
	
	list<float> shares_owner_list <- [share_ownership_income[1,0], share_ownership_income[2,0], share_ownership_income[3,0], share_ownership_income[4,0], share_ownership_income[5,0], share_ownership_income[6,0]];
	list shares_tenants_list <- [share_tenants_500_1000, share_tenants_1000_1500, share_tenants_1500_2000, share_tenants_2000_3000, share_tenants_3000_4000, share_tenants_4000etc];
	
	map share_owner_map <- create_map(income_groups_list, shares_owner_list); 
	map share_tenants_map <- create_map(income_groups_list, shares_tenants_list);
	
	

// share of employment sorted by income	
	float share_student_500_1000 <- share_employment_income[1,0];
	float share_employed_500_1000 <- share_employment_income[1,1];
	float share_selfemployed_500_1000 <- share_employment_income[1,2];
	float share_unemployed_500_1000 <- share_employment_income[1,3];
	float share_pensioner_500_1000 <- share_employment_income[1,4];
	
	float share_student_1000_1500 <- share_employment_income[2,0];
	float share_employed_1000_1500 <- share_employment_income[2,1];
	float share_selfemployed_1000_1500 <- share_employment_income[2,2];
	float share_unemployed_1000_1500 <- share_employment_income[2,3];
	float share_pensioner_1000_1500 <- share_employment_income[2,4];
	
	float share_student_1500_2000 <- share_employment_income[3,0];
	float share_employed_1500_2000 <- share_employment_income[3,1];
	float share_selfemployed_1500_2000 <- share_employment_income[3,2];
	float share_unemployed_1500_2000 <- share_employment_income[3,3];
	float share_pensioner_1500_2000 <- share_employment_income[3,4];
	
	float share_student_2000_3000 <- share_employment_income[4,0];
	float share_employed_2000_3000 <- share_employment_income[4,1];
	float share_selfemployed_2000_3000 <- share_employment_income[4,2];
	float share_unemployed_2000_3000 <- share_employment_income[4,3];
	float share_pensioner_2000_3000 <- share_employment_income[4,4];
	
	float share_student_3000_4000 <- share_employment_income[5,0];
	float share_employed_3000_4000 <- share_employment_income[5,1];
	float share_selfemployed_3000_4000 <- share_employment_income[5,2];
	float share_unemployed_3000_4000 <- share_employment_income[5,3];
	float share_pensioner_3000_4000 <- share_employment_income[5,4];
	
	float share_student_4000etc <- share_employment_income[5,0];
	float share_employed_4000etc <- share_employment_income[5,1];
	float share_selfemployed_4000etc <- share_employment_income[5,2];
	float share_unemployed_4000etc <- share_employment_income[5,3];
	float share_pensioner_4000etc <- share_employment_income[5,4];

	//list ssl <- share_employment_income row_at 0;
	list shares_student_list <- [share_student_500_1000, share_student_1000_1500, share_student_1500_2000, share_student_2000_3000, share_student_3000_4000, share_student_4000etc];
	list shares_employed_list <- [share_employed_500_1000, share_employed_1000_1500, share_employed_1500_2000, share_employed_2000_3000, share_employed_3000_4000, share_employed_4000etc];
	list shares_selfemployed_list <- [share_selfemployed_500_1000, share_selfemployed_1000_1500, share_selfemployed_1500_2000, share_selfemployed_2000_3000, share_selfemployed_3000_4000, share_selfemployed_4000etc];
	list shares_unemployed_list <- [share_unemployed_500_1000, share_unemployed_1000_1500, share_unemployed_1500_2000, share_unemployed_2000_3000, share_unemployed_3000_4000, share_unemployed_4000etc];
	list shares_pensioner_list <- [share_pensioner_500_1000, share_pensioner_1000_1500, share_pensioner_1500_2000, share_pensioner_2000_3000, share_pensioner_3000_4000, share_pensioner_4000etc];
	
	map share_student <- create_map(income_groups_list, shares_student_list);
	map share_employed <- create_map(income_groups_list, shares_employed_list);
	map share_selfemployed <- create_map(income_groups_list, shares_selfemployed_list);
	map share_unemployed <- create_map(income_groups_list, shares_unemployed_list);
	map share_pensioner <- create_map(income_groups_list, shares_pensioner_list);
		


//verkürzen durch liste?
	init { //erste Integration der Zahl der Haushalte; Schritt 2 -> Ausrichten an Anzahl der im GIS-Datensatz hinterlegten Wohnungen
		
		loop income_group over: income_groups_list {
			let letters <- ["a", "b", "c", "d"];
			loop i over: range(0,3) {
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
					id_group <- string(income_group) + "_" + letters[i]; // passt das, wenn die ID so aussieht?
					
					
				}
			}
		}
		/**
		create households_500_1000 number: nb_households_500_1000 * nb_units * 0.25{ 
			float decision_500_1000_CEEK_min <- decision_500_1000[1,0];
			float decision_500_1000_CEEK_1st <- decision_500_1000[1,1];
			CEEK <- rnd (decision_500_1000_CEEK_min, decision_500_1000_CEEK_1st);
			float decision_500_1000_CEEA_min <- decision_500_1000[2,0];
			float decision_500_1000_CEEA_1st <- decision_500_1000[2,1];
			CEEA <- rnd (decision_500_1000_CEEA_min, decision_500_1000_CEEA_1st);
			float decision_500_1000_EDA_min <- decision_500_1000[3,0];
			float decision_500_1000_EDA_1st <- decision_500_1000[3,1];
			EDA <- rnd (decision_500_1000_EDA_min, decision_500_1000_EDA_1st);
			float decision_500_1000_PN_min <- decision_500_1000[4,0];
			float decision_500_1000_PN_1st <- decision_500_1000[4,1];
			PN <- rnd (decision_500_1000_PN_min, decision_500_1000_PN_1st);
			float decision_500_1000_SN_min <- decision_500_1000[5,0];
			float decision_500_1000_SN_1st <- decision_500_1000[5,1];
			SN <- rnd (decision_500_1000_SN_min, decision_500_1000_SN_1st);
			float decision_500_1000_EEH_min <- decision_500_1000[6,0];
			float decision_500_1000_EEH_1st <- decision_500_1000[6,1];
			EEH <- rnd (decision_500_1000_EEH_min, decision_500_1000_EEH_1st);
			float decision_500_1000_PBC_I_min <- decision_500_1000[7,0];
			float decision_500_1000_PBC_I_1st <- decision_500_1000[7,1];
			PBC_I <- rnd (decision_500_1000_PBC_I_min, decision_500_1000_PBC_I_1st);
			float decision_500_1000_PBC_C_min <- decision_500_1000[8,0];
			float decision_500_1000_PBC_C_1st <- decision_500_1000[8,1];
			PBC_C <- rnd (decision_500_1000_PBC_C_min, decision_500_1000_PBC_C_1st);
			float decision_500_1000_PBC_S_min <- decision_500_1000[9,0];
			float decision_500_1000_PBC_S_1st <- decision_500_1000[9,1];
			PBC_S <- rnd (decision_500_1000_PBC_S_min, decision_500_1000_PBC_S_1st);
			id_group <- "500-1000_a";	
		}
		create households_500_1000 number: nb_households_500_1000 * nb_units * 0.25{
			float decision_500_1000_CEEK_1st <- decision_500_1000[1,1];
			float decision_500_1000_CEEK_median <- decision_500_1000[1,2];
			CEEK <- rnd (decision_500_1000_CEEK_1st, decision_500_1000_CEEK_median);
			float decision_500_1000_CEEA_1st <- decision_500_1000[2,1];
			float decision_500_1000_CEEA_median <- decision_500_1000[2,2];
			CEEA <- rnd (decision_500_1000_CEEA_1st, decision_500_1000_CEEA_median);
			float decision_500_1000_EDA_1st <- decision_500_1000[3,1];
			float decision_500_1000_EDA_median <- decision_500_1000[3,2];
			EDA <- rnd (decision_500_1000_EDA_1st, decision_500_1000_EDA_median);
			float decision_500_1000_PN_1st <- decision_500_1000[4,1];
			float decision_500_1000_PN_median <- decision_500_1000[4,2];
			PN <- rnd (decision_500_1000_PN_1st, decision_500_1000_PN_median);
			float decision_500_1000_SN_1st <- decision_500_1000[5,1];
			float decision_500_1000_SN_median <- decision_500_1000[5,2];
			SN <- rnd (decision_500_1000_SN_1st, decision_500_1000_SN_median);
			float decision_500_1000_EEH_1st <- decision_500_1000[6,1];
			float decision_500_1000_EEH_median <- decision_500_1000[6,2];
			EEH <- rnd (decision_500_1000_EEH_1st, decision_500_1000_EEH_median);
			float decision_500_1000_PBC_I_1st <- decision_500_1000[7,1];
			float decision_500_1000_PBC_I_median <- decision_500_1000[7,2];
			PBC_I <- rnd (decision_500_1000_PBC_I_1st, decision_500_1000_PBC_I_median);
			float decision_500_1000_PBC_C_1st <- decision_500_1000[8,1];
			float decision_500_1000_PBC_C_median <- decision_500_1000[8,2];
			PBC_C <- rnd (decision_500_1000_PBC_C_1st, decision_500_1000_PBC_C_median);
			float decision_500_1000_PBC_S_1st <- decision_500_1000[9,1];
			float decision_500_1000_PBC_S_median <- decision_500_1000[9,2];
			PBC_S <- rnd (decision_500_1000_PBC_S_1st, decision_500_1000_PBC_S_median);
			id_group <- "500-1000_b";
		}
		create households_500_1000 number: nb_households_500_1000 * nb_units * 0.25{
			float decision_500_1000_CEEK_median <- decision_500_1000[1,2];
			float decision_500_1000_CEEK_3rd <- decision_500_1000[1,3];
			CEEK <- rnd (decision_500_1000_CEEK_median, decision_500_1000_CEEK_3rd);
			float decision_500_1000_CEEA_median <- decision_500_1000[2,2];
			float decision_500_1000_CEEA_3rd <- decision_500_1000[2,3];
			CEEA <- rnd (decision_500_1000_CEEA_median, decision_500_1000_CEEA_3rd);
			float decision_500_1000_EDA_median <- decision_500_1000[3,2];
			float decision_500_1000_EDA_3rd <- decision_500_1000[3,3];
			EDA <- rnd (decision_500_1000_EDA_median, decision_500_1000_EDA_3rd);
			float decision_500_1000_PN_median <- decision_500_1000[4,2];
			float decision_500_1000_PN_3rd <- decision_500_1000[4,3];
			PN <- rnd (decision_500_1000_PN_median, decision_500_1000_PN_3rd);
			float decision_500_1000_SN_median <- decision_500_1000[5,2];
			float decision_500_1000_SN_3rd <- decision_500_1000[5,3];
			SN <- rnd (decision_500_1000_SN_median, decision_500_1000_SN_3rd);
			float decision_500_1000_EEH_median <- decision_500_1000[6,2];
			float decision_500_1000_EEH_3rd <- decision_500_1000[6,3];
			EEH <- rnd (decision_500_1000_EEH_median, decision_500_1000_EEH_3rd);
			float decision_500_1000_PBC_I_median <- decision_500_1000[7,2];
			float decision_500_1000_PBC_I_3rd <- decision_500_1000[7,3];
			PBC_I <- rnd (decision_500_1000_PBC_I_median, decision_500_1000_PBC_I_3rd);
			float decision_500_1000_PBC_C_median <- decision_500_1000[8,2];
			float decision_500_1000_PBC_C_3rd <- decision_500_1000[8,3];
			PBC_C <- rnd (decision_500_1000_PBC_C_median, decision_500_1000_PBC_C_3rd);
			float decision_500_1000_PBC_S_median <- decision_500_1000[9,2];
			float decision_500_1000_PBC_S_3rd <- decision_500_1000[9,3];
			PBC_S <- rnd (decision_500_1000_PBC_S_median, decision_500_1000_PBC_S_3rd);
			id_group <- "500-1000_c";
		}
		create households_500_1000 number: nb_households_500_1000 * nb_units * 0.25{
			float decision_500_1000_CEEK_3rd <- decision_500_1000[1,3];
			float decision_500_1000_CEEK_max <- decision_500_1000[1,4];
			CEEK <- rnd (decision_500_1000_CEEK_3rd, decision_500_1000_CEEK_max);
			float decision_500_1000_CEEA_3rd <- decision_500_1000[2,3];
			float decision_500_1000_CEEA_max <- decision_500_1000[2,4];
			CEEA <- rnd (decision_500_1000_CEEA_3rd, decision_500_1000_CEEA_max);
			float decision_500_1000_EDA_3rd <- decision_500_1000[3,3];
			float decision_500_1000_EDA_max <- decision_500_1000[3,4];
			EDA <- rnd (decision_500_1000_EDA_3rd, decision_500_1000_EDA_max);
			float decision_500_1000_PN_3rd <- decision_500_1000[4,3];
			float decision_500_1000_PN_max <- decision_500_1000[4,4];
			PN <- rnd (decision_500_1000_PN_3rd, decision_500_1000_PN_max);
			float decision_500_1000_SN_3rd <- decision_500_1000[5,3];
			float decision_500_1000_SN_max <- decision_500_1000[5,4];
			SN <- rnd (decision_500_1000_SN_3rd, decision_500_1000_SN_max);
			float decision_500_1000_EEH_3rd <- decision_500_1000[6,3];
			float decision_500_1000_EEH_max <- decision_500_1000[6,4];
			EEH <- rnd (decision_500_1000_EEH_3rd, decision_500_1000_EEH_max);
			float decision_500_1000_PBC_I_3rd <- decision_500_1000[7,3];
			float decision_500_1000_PBC_I_max <- decision_500_1000[7,4];
			PBC_I <- rnd (decision_500_1000_PBC_I_3rd, decision_500_1000_PBC_I_max);
			float decision_500_1000_PBC_C_3rd <- decision_500_1000[8,3];
			float decision_500_1000_PBC_C_max <- decision_500_1000[8,4];
			PBC_C <- rnd (decision_500_1000_PBC_C_3rd, decision_500_1000_PBC_C_max);
			float decision_500_1000_PBC_S_3rd <- decision_500_1000[9,3];
			float decision_500_1000_PBC_S_max <- decision_500_1000[9,4];
			PBC_S <- rnd (decision_500_1000_PBC_S_3rd, decision_500_1000_PBC_S_max);
			id_group <- "500-1000_d";
		} 	
		
		create households_1000_1500 number: nb_households_1000_1500 * nb_units * 0.25{
			float decision_1000_1500_CEEK_min <- decision_1000_1500[1,0];
			float decision_1000_1500_CEEK_1st <- decision_1000_1500[1,1];
			CEEK <- rnd (decision_1000_1500_CEEK_min, decision_1000_1500_CEEK_1st);
			float decision_1000_1500_CEEA_min <- decision_1000_1500[2,0];
			float decision_1000_1500_CEEA_1st <- decision_1000_1500[2,1];
			CEEA <- rnd (decision_1000_1500_CEEA_min, decision_1000_1500_CEEA_1st);
			float decision_1000_1500_EDA_min <- decision_1000_1500[3,0];
			float decision_1000_1500_EDA_1st <- decision_1000_1500[3,1];
			EDA <- rnd (decision_1000_1500_EDA_min, decision_1000_1500_EDA_1st);
			float decision_1000_1500_PN_min <- decision_1000_1500[4,0];
			float decision_1000_1500_PN_1st <- decision_1000_1500[4,1];
			PN <- rnd (decision_1000_1500_PN_min, decision_1000_1500_PN_1st);
			float decision_1000_1500_SN_min <- decision_1000_1500[5,0];
			float decision_1000_1500_SN_1st <- decision_1000_1500[5,1];
			SN <- rnd (decision_1000_1500_SN_min, decision_1000_1500_SN_1st);
			float decision_1000_1500_EEH_min <- decision_1000_1500[6,0];
			float decision_1000_1500_EEH_1st <- decision_1000_1500[6,1];
			EEH <- rnd (decision_1000_1500_EEH_min, decision_1000_1500_EEH_1st);
			float decision_1000_1500_PBC_I_min <- decision_1000_1500[7,0];
			float decision_1000_1500_PBC_I_1st <- decision_1000_1500[7,1];
			PBC_I <- rnd (decision_1000_1500_PBC_I_min, decision_1000_1500_PBC_I_1st);
			float decision_1000_1500_PBC_C_min <- decision_1000_1500[8,0];
			float decision_1000_1500_PBC_C_1st <- decision_1000_1500[8,1];
			PBC_C <- rnd (decision_1000_1500_PBC_C_min, decision_1000_1500_PBC_C_1st);
			float decision_1000_1500_PBC_S_min <- decision_1000_1500[9,0];
			float decision_1000_1500_PBC_S_1st <- decision_1000_1500[9,1];
			PBC_S <- rnd (decision_1000_1500_PBC_S_min, decision_1000_1500_PBC_S_1st);
			id_group <- "1000-1500_a";
		}
		create households_1000_1500 number: nb_households_1000_1500 * nb_units * 0.25{
			float decision_1000_1500_CEEK_1st <- decision_1000_1500[1,1];
			float decision_1000_1500_CEEK_median <- decision_1000_1500[1,2];
			CEEK <- rnd (decision_1000_1500_CEEK_1st, decision_1000_1500_CEEK_median);
			float decision_1000_1500_CEEA_1st <- decision_1000_1500[2,1];
			float decision_1000_1500_CEEA_median <- decision_1000_1500[2,2];
			CEEA <- rnd (decision_1000_1500_CEEA_1st, decision_1000_1500_CEEA_median);
			float decision_1000_1500_EDA_1st <- decision_1000_1500[3,1];
			float decision_1000_1500_EDA_median <- decision_1000_1500[3,2];
			EDA <- rnd (decision_1000_1500_EDA_1st, decision_1000_1500_EDA_median);
			float decision_1000_1500_PN_1st <- decision_1000_1500[4,1];
			float decision_1000_1500_PN_median <- decision_1000_1500[4,2];
			PN <- rnd (decision_1000_1500_PN_1st, decision_1000_1500_PN_median);
			float decision_1000_1500_SN_1st <- decision_1000_1500[5,1];
			float decision_1000_1500_SN_median <- decision_1000_1500[5,2];
			SN <- rnd (decision_1000_1500_SN_1st, decision_1000_1500_SN_median);
			float decision_1000_1500_EEH_1st <- decision_1000_1500[6,1];
			float decision_1000_1500_EEH_median <- decision_1000_1500[6,2];
			EEH <- rnd (decision_1000_1500_EEH_1st, decision_1000_1500_EEH_median);
			float decision_1000_1500_PBC_I_1st <- decision_1000_1500[7,1];
			float decision_1000_1500_PBC_I_median <- decision_1000_1500[7,2];
			PBC_I <- rnd (decision_1000_1500_PBC_I_1st, decision_1000_1500_PBC_I_median);
			float decision_1000_1500_PBC_C_1st <- decision_1000_1500[8,1];
			float decision_1000_1500_PBC_C_median <- decision_1000_1500[8,2];
			PBC_C <- rnd (decision_1000_1500_PBC_C_1st, decision_1000_1500_PBC_C_median);
			float decision_1000_1500_PBC_S_1st <- decision_1000_1500[9,1];
			float decision_1000_1500_PBC_S_median <- decision_1000_1500[9,2];
			PBC_S <- rnd (decision_1000_1500_PBC_S_1st, decision_1000_1500_PBC_S_median);
			id_group <- "1000_1500_b";
		}		
		create households_1000_1500 number: nb_households_1000_1500 * nb_units * 0.25{
			float decision_1000_1500_CEEK_median <- decision_1000_1500[1,2];
			float decision_1000_1500_CEEK_3rd <- decision_1000_1500[1,3];
			CEEK <- rnd (decision_1000_1500_CEEK_median, decision_1000_1500_CEEK_3rd);
			float decision_1000_1500_CEEA_median <- decision_1000_1500[2,2];
			float decision_1000_1500_CEEA_3rd <- decision_1000_1500[2,3];
			CEEA <- rnd (decision_1000_1500_CEEA_median, decision_1000_1500_CEEA_3rd);
			float decision_1000_1500_EDA_median <- decision_1000_1500[3,2];
			float decision_1000_1500_EDA_3rd <- decision_1000_1500[3,3];
			EDA <- rnd (decision_1000_1500_EDA_median, decision_1000_1500_EDA_3rd);
			float decision_1000_1500_PN_median <- decision_1000_1500[4,2];
			float decision_1000_1500_PN_3rd <- decision_1000_1500[4,3];
			PN <- rnd (decision_1000_1500_PN_median, decision_1000_1500_PN_3rd);
			float decision_1000_1500_SN_median <- decision_1000_1500[5,2];
			float decision_1000_1500_SN_3rd <- decision_1000_1500[5,3];
			SN <- rnd (decision_1000_1500_SN_median, decision_1000_1500_SN_3rd);
			float decision_1000_1500_EEH_median <- decision_1000_1500[6,2];
			float decision_1000_1500_EEH_3rd <- decision_1000_1500[6,3];
			EEH <- rnd (decision_1000_1500_EEH_median, decision_1000_1500_EEH_3rd);
			float decision_1000_1500_PBC_I_median <- decision_1000_1500[7,2];
			float decision_1000_1500_PBC_I_3rd <- decision_1000_1500[7,3];
			PBC_I <- rnd (decision_1000_1500_PBC_I_median, decision_1000_1500_PBC_I_3rd);
			float decision_1000_1500_PBC_C_median <- decision_1000_1500[8,2];
			float decision_1000_1500_PBC_C_3rd <- decision_1000_1500[8,3];
			PBC_C <- rnd (decision_1000_1500_PBC_C_median, decision_1000_1500_PBC_C_3rd);
			float decision_1000_1500_PBC_S_median <- decision_1000_1500[9,2];
			float decision_1000_1500_PBC_S_3rd <- decision_1000_1500[9,3];
			PBC_S <- rnd (decision_1000_1500_PBC_S_median, decision_1000_1500_PBC_S_3rd);
			id_group <- "1000_1500_c";
		}		
		create households_1000_1500 number: nb_households_1000_1500 * nb_units * 0.25{
			float decision_1000_1500_CEEK_3rd <- decision_1000_1500[1,3];
			float decision_1000_1500_CEEK_max <- decision_1000_1500[1,4];
			CEEK <- rnd (decision_1000_1500_CEEK_3rd, decision_1000_1500_CEEK_max);
			float decision_1000_1500_CEEA_3rd <- decision_1000_1500[2,3];
			float decision_1000_1500_CEEA_max <- decision_1000_1500[2,4];
			CEEA <- rnd (decision_1000_1500_CEEA_3rd, decision_1000_1500_CEEA_max);
			float decision_1000_1500_EDA_3rd <- decision_1000_1500[3,3];
			float decision_1000_1500_EDA_max <- decision_1000_1500[3,4];
			EDA <- rnd (decision_1000_1500_EDA_3rd, decision_1000_1500_EDA_max);
			float decision_1000_1500_PN_3rd <- decision_1000_1500[4,3];
			float decision_1000_1500_PN_max <- decision_1000_1500[4,4];
			PN <- rnd (decision_1000_1500_PN_3rd, decision_1000_1500_PN_max);
			float decision_1000_1500_SN_3rd <- decision_1000_1500[5,3];
			float decision_1000_1500_SN_max <- decision_1000_1500[5,4];
			SN <- rnd (decision_1000_1500_SN_3rd, decision_1000_1500_SN_max);
			float decision_1000_1500_EEH_3rd <- decision_1000_1500[6,3];
			float decision_1000_1500_EEH_max <- decision_1000_1500[6,4];
			EEH <- rnd (decision_1000_1500_EEH_3rd, decision_1000_1500_EEH_max);
			float decision_1000_1500_PBC_I_3rd <- decision_1000_1500[7,3];
			float decision_1000_1500_PBC_I_max <- decision_1000_1500[7,4];
			PBC_I <- rnd (decision_1000_1500_PBC_I_3rd, decision_1000_1500_PBC_I_max);
			float decision_1000_1500_PBC_C_3rd <- decision_1000_1500[8,3];
			float decision_1000_1500_PBC_C_max <- decision_1000_1500[8,4];
			PBC_C <- rnd (decision_1000_1500_PBC_C_3rd, decision_1000_1500_PBC_C_max);
			float decision_1000_1500_PBC_S_3rd <- decision_1000_1500[9,3];
			float decision_1000_1500_PBC_S_max <- decision_1000_1500[9,4];
			PBC_S <- rnd (decision_1000_1500_PBC_S_3rd, decision_1000_1500_PBC_S_max);
			id_group <- "1000_1500_d";
		}
		
		
		create households_1500_2000 number: nb_households_1500_2000 * nb_units * 0.25{
			float decision_1500_2000_CEEK_min <- decision_1500_2000[1,0];
			float decision_1500_2000_CEEK_1st <- decision_1500_2000[1,1];
			CEEK <- rnd (decision_1500_2000_CEEK_min, decision_1500_2000_CEEK_1st);
			float decision_1500_2000_CEEA_min <- decision_1500_2000[2,0];
			float decision_1500_2000_CEEA_1st <- decision_1500_2000[2,1];
			CEEA <- rnd (decision_1500_2000_CEEA_min, decision_1500_2000_CEEA_1st);
			float decision_1500_2000_EDA_min <- decision_1500_2000[3,0];
			float decision_1500_2000_EDA_1st <- decision_1500_2000[3,1];
			EDA <- rnd (decision_1500_2000_EDA_min, decision_1500_2000_EDA_1st);
			float decision_1500_2000_PN_min <- decision_1500_2000[4,0];
			float decision_1500_2000_PN_1st <- decision_1500_2000[4,1];
			PN <- rnd (decision_1500_2000_PN_min, decision_1500_2000_PN_1st);
			float decision_1500_2000_SN_min <- decision_1500_2000[5,0];
			float decision_1500_2000_SN_1st <- decision_1500_2000[5,1];
			SN <- rnd (decision_1500_2000_SN_min, decision_1500_2000_SN_1st);
			float decision_1500_2000_EEH_min <- decision_1500_2000[6,0];
			float decision_1500_2000_EEH_1st <- decision_1500_2000[6,1];
			EEH <- rnd (decision_1500_2000_EEH_min, decision_1500_2000_EEH_1st);
			float decision_1500_2000_PBC_I_min <- decision_1500_2000[7,0];
			float decision_1500_2000_PBC_I_1st <- decision_1500_2000[7,1];
			PBC_I <- rnd (decision_1500_2000_PBC_I_min, decision_1500_2000_PBC_I_1st);
			float decision_1500_2000_PBC_C_min <- decision_1500_2000[8,0];
			float decision_1500_2000_PBC_C_1st <- decision_1500_2000[8,1];
			PBC_C <- rnd (decision_1500_2000_PBC_C_min, decision_1500_2000_PBC_C_1st);
			float decision_1500_2000_PBC_S_min <- decision_1500_2000[9,0];
			float decision_1500_2000_PBC_S_1st <- decision_1500_2000[9,1];
			PBC_S <- rnd (decision_1500_2000_PBC_S_min, decision_1500_2000_PBC_S_1st);
			id_group <- "1500_2000_a";
			}
		create households_1500_2000 number: nb_households_1500_2000 * nb_units * 0.25{
			float decision_1500_2000_CEEK_1st <- decision_1500_2000[1,1];
			float decision_1500_2000_CEEK_median <- decision_1500_2000[1,2];
			CEEK <- rnd (decision_1500_2000_CEEK_1st, decision_1500_2000_CEEK_median);
			float decision_1500_2000_CEEA_1st <- decision_1500_2000[2,1];
			float decision_1500_2000_CEEA_median <- decision_1500_2000[2,2];
			CEEA <- rnd (decision_1500_2000_CEEA_1st, decision_1500_2000_CEEA_median);
			float decision_1500_2000_EDA_1st <- decision_1500_2000[3,1];
			float decision_1500_2000_EDA_median <- decision_1500_2000[3,2];
			EDA <- rnd (decision_1500_2000_EDA_1st, decision_1500_2000_EDA_median);
			float decision_1500_2000_PN_1st <- decision_1500_2000[4,1];
			float decision_1500_2000_PN_median <- decision_1500_2000[4,2];
			PN <- rnd (decision_1500_2000_PN_1st, decision_1500_2000_PN_median);
			float decision_1500_2000_SN_1st <- decision_1500_2000[5,1];
			float decision_1500_2000_SN_median <- decision_1500_2000[5,2];
			SN <- rnd (decision_1500_2000_SN_1st, decision_1500_2000_SN_median);
			float decision_1500_2000_EEH_1st <- decision_1500_2000[6,1];
			float decision_1500_2000_EEH_median <- decision_1500_2000[6,2];
			EEH <- rnd (decision_1500_2000_EEH_1st, decision_1500_2000_EEH_median);
			float decision_1500_2000_PBC_I_1st <- decision_1500_2000[7,1];
			float decision_1500_2000_PBC_I_median <- decision_1500_2000[7,2];
			PBC_I <- rnd (decision_1500_2000_PBC_I_1st, decision_1500_2000_PBC_I_median);
			float decision_1500_2000_PBC_C_1st <- decision_1500_2000[8,1];
			float decision_1500_2000_PBC_C_median <- decision_1500_2000[8,2];
			PBC_C <- rnd (decision_1500_2000_PBC_C_1st, decision_1500_2000_PBC_C_median);
			float decision_1500_2000_PBC_S_1st <- decision_1500_2000[9,1];
			float decision_1500_2000_PBC_S_median <- decision_1500_2000[9,2];
			PBC_S <- rnd (decision_1500_2000_PBC_S_1st, decision_1500_2000_PBC_S_median);
			id_group <- "1500_2000_b";		
		}
		create households_1500_2000 number: nb_households_1500_2000 * nb_units * 0.25{
			float decision_1500_2000_CEEK_median <- decision_1500_2000[1,2];
			float decision_1500_2000_CEEK_3rd <- decision_1500_2000[1,3];
			CEEK <- rnd (decision_1500_2000_CEEK_median, decision_1500_2000_CEEK_3rd);
			float decision_1500_2000_CEEA_median <- decision_1500_2000[2,2];
			float decision_1500_2000_CEEA_3rd <- decision_1500_2000[2,3];
			CEEA <- rnd (decision_1500_2000_CEEA_median, decision_1500_2000_CEEA_3rd);
			float decision_1500_2000_EDA_median <- decision_1500_2000[3,2];
			float decision_1500_2000_EDA_3rd <- decision_1500_2000[3,3];
			EDA <- rnd (decision_1500_2000_EDA_median, decision_1500_2000_EDA_3rd);
			float decision_1500_2000_PN_median <- decision_1500_2000[4,2];
			float decision_1500_2000_PN_3rd <- decision_1500_2000[4,3];
			PN <- rnd (decision_1500_2000_PN_median, decision_1500_2000_PN_3rd);
			float decision_1500_2000_SN_median <- decision_1500_2000[5,2];
			float decision_1500_2000_SN_3rd <- decision_1500_2000[5,3];
			SN <- rnd (decision_1500_2000_SN_median, decision_1500_2000_SN_3rd);
			float decision_1500_2000_EEH_median <- decision_1500_2000[6,2];
			float decision_1500_2000_EEH_3rd <- decision_1500_2000[6,3];
			EEH <- rnd (decision_1500_2000_EEH_median, decision_1500_2000_EEH_3rd);
			float decision_1500_2000_PBC_I_median <- decision_1500_2000[7,2];
			float decision_1500_2000_PBC_I_3rd <- decision_1500_2000[7,3];
			PBC_I <- rnd (decision_1500_2000_PBC_I_median, decision_1500_2000_PBC_I_3rd);
			float decision_1500_2000_PBC_C_median <- decision_1500_2000[8,2];
			float decision_1500_2000_PBC_C_3rd <- decision_1500_2000[8,3];
			PBC_C <- rnd (decision_1500_2000_PBC_C_median, decision_1500_2000_PBC_C_3rd);
			float decision_1500_2000_PBC_S_median <- decision_1500_2000[9,2];
			float decision_1500_2000_PBC_S_3rd <- decision_1500_2000[9,3];
			PBC_S <- rnd (decision_1500_2000_PBC_S_median, decision_1500_2000_PBC_S_3rd);
			id_group <- "1500_2000_c";
		}
		create households_1500_2000 number: nb_households_1500_2000 * nb_units * 0.25{
			float decision_1500_2000_CEEK_3rd <- decision_1500_2000[1,3];
			float decision_1500_2000_CEEK_max <- decision_1500_2000[1,4];
			CEEK <- rnd (decision_1500_2000_CEEK_3rd, decision_1500_2000_CEEK_max);
			float decision_1500_2000_CEEA_3rd <- decision_1500_2000[2,3];
			float decision_1500_2000_CEEA_max <- decision_1500_2000[2,4];
			CEEA <- rnd (decision_1500_2000_CEEA_3rd, decision_1500_2000_CEEA_max);
			float decision_1500_2000_EDA_3rd <- decision_1500_2000[3,3];
			float decision_1500_2000_EDA_max <- decision_1500_2000[3,4];
			EDA <- rnd (decision_1500_2000_EDA_3rd, decision_1500_2000_EDA_max);
			float decision_1500_2000_PN_3rd <- decision_1500_2000[4,3];
			float decision_1500_2000_PN_max <- decision_1500_2000[4,4];
			PN <- rnd (decision_1500_2000_PN_3rd, decision_1500_2000_PN_max);
			float decision_1500_2000_SN_3rd <- decision_1500_2000[5,3];
			float decision_1500_2000_SN_max <- decision_1500_2000[5,4];
			SN <- rnd (decision_1500_2000_SN_3rd, decision_1500_2000_SN_max);
			float decision_1500_2000_EEH_3rd <- decision_1500_2000[6,3];
			float decision_1500_2000_EEH_max <- decision_1500_2000[6,4];
			EEH <- rnd (decision_1500_2000_EEH_3rd, decision_1500_2000_EEH_max);
			float decision_1500_2000_PBC_I_3rd <- decision_1500_2000[7,3];
			float decision_1500_2000_PBC_I_max <- decision_1500_2000[7,4];
			PBC_I <- rnd (decision_1500_2000_PBC_I_3rd, decision_1500_2000_PBC_I_max);
			float decision_1500_2000_PBC_C_3rd <- decision_1500_2000[8,3];
			float decision_1500_2000_PBC_C_max <- decision_1500_2000[8,4];
			PBC_C <- rnd (decision_1500_2000_PBC_C_3rd, decision_1500_2000_PBC_C_max);
			float decision_1500_2000_PBC_S_3rd <- decision_1500_2000[9,3];
			float decision_1500_2000_PBC_S_max <- decision_1500_2000[9,4];
			PBC_S <- rnd (decision_1500_2000_PBC_S_3rd, decision_1500_2000_PBC_S_max);
			id_group <- "1500_2000_d";
		}
		
		
		create households_2000_3000 number: nb_households_2000_3000 * nb_units * 0.25{
			float decision_2000_3000_CEEK_min <- decision_2000_3000[1,0];
			float decision_2000_3000_CEEK_1st <- decision_2000_3000[1,1];
			CEEK <- rnd (decision_2000_3000_CEEK_min, decision_2000_3000_CEEK_1st);
			float decision_2000_3000_CEEA_min <- decision_2000_3000[2,0];
			float decision_2000_3000_CEEA_1st <- decision_2000_3000[2,1];
			CEEA <- rnd (decision_2000_3000_CEEA_min, decision_2000_3000_CEEA_1st);
			float decision_2000_3000_EDA_min <- decision_2000_3000[3,0];
			float decision_2000_3000_EDA_1st <- decision_2000_3000[3,1];
			EDA <- rnd (decision_2000_3000_EDA_min, decision_2000_3000_EDA_1st);
			float decision_2000_3000_PN_min <- decision_2000_3000[4,0];
			float decision_2000_3000_PN_1st <- decision_2000_3000[4,1];
			PN <- rnd (decision_2000_3000_PN_min, decision_2000_3000_PN_1st);
			float decision_2000_3000_SN_min <- decision_2000_3000[5,0];
			float decision_2000_3000_SN_1st <- decision_2000_3000[5,1];
			SN <- rnd (decision_2000_3000_SN_min, decision_2000_3000_SN_1st);
			float decision_2000_3000_EEH_min <- decision_2000_3000[6,0];
			float decision_2000_3000_EEH_1st <- decision_2000_3000[6,1];
			EEH <- rnd (decision_2000_3000_EEH_min, decision_2000_3000_EEH_1st);
			float decision_2000_3000_PBC_I_min <- decision_2000_3000[7,0];
			float decision_2000_3000_PBC_I_1st <- decision_2000_3000[7,1];
			PBC_I <- rnd (decision_2000_3000_PBC_I_min, decision_2000_3000_PBC_I_1st);
			float decision_2000_3000_PBC_C_min <- decision_2000_3000[8,0];
			float decision_2000_3000_PBC_C_1st <- decision_2000_3000[8,1];
			PBC_C <- rnd (decision_2000_3000_PBC_C_min, decision_2000_3000_PBC_C_1st);
			float decision_2000_3000_PBC_S_min <- decision_2000_3000[9,0];
			float decision_2000_3000_PBC_S_1st <- decision_2000_3000[9,1];
			PBC_S <- rnd (decision_2000_3000_PBC_S_min, decision_2000_3000_PBC_S_1st);
			id_group <- "2000_3000_a";	
		}
		create households_2000_3000 number: nb_households_2000_3000 * nb_units * 0.25{
			float decision_2000_3000_CEEK_1st <- decision_2000_3000[1,1];
			float decision_2000_3000_CEEK_median <- decision_2000_3000[1,2];
			CEEK <- rnd (decision_2000_3000_CEEK_1st, decision_2000_3000_CEEK_median);
			float decision_2000_3000_CEEA_1st <- decision_2000_3000[2,1];
			float decision_2000_3000_CEEA_median <- decision_2000_3000[2,2];
			CEEA <- rnd (decision_2000_3000_CEEA_1st, decision_2000_3000_CEEA_median);
			float decision_2000_3000_EDA_1st <- decision_2000_3000[3,1];
			float decision_2000_3000_EDA_median <- decision_2000_3000[3,2];
			EDA <- rnd (decision_2000_3000_EDA_1st, decision_2000_3000_EDA_median);
			float decision_2000_3000_PN_1st <- decision_2000_3000[4,1];
			float decision_2000_3000_PN_median <- decision_2000_3000[4,2];
			PN <- rnd (decision_2000_3000_PN_1st, decision_2000_3000_PN_median);
			float decision_2000_3000_SN_1st <- decision_2000_3000[5,1];
			float decision_2000_3000_SN_median <- decision_2000_3000[5,2];
			SN <- rnd (decision_2000_3000_SN_1st, decision_2000_3000_SN_median);
			float decision_2000_3000_EEH_1st <- decision_2000_3000[6,1];
			float decision_2000_3000_EEH_median <- decision_2000_3000[6,2];
			EEH <- rnd (decision_2000_3000_EEH_1st, decision_2000_3000_EEH_median);
			float decision_2000_3000_PBC_I_1st <- decision_2000_3000[7,1];
			float decision_2000_3000_PBC_I_median <- decision_2000_3000[7,2];
			PBC_I <- rnd (decision_2000_3000_PBC_I_1st, decision_2000_3000_PBC_I_median);
			float decision_2000_3000_PBC_C_1st <- decision_2000_3000[8,1];
			float decision_2000_3000_PBC_C_median <- decision_2000_3000[8,2];
			PBC_C <- rnd (decision_2000_3000_PBC_C_1st, decision_2000_3000_PBC_C_median);
			float decision_2000_3000_PBC_S_1st <- decision_2000_3000[9,1];
			float decision_2000_3000_PBC_S_median <- decision_2000_3000[9,2];
			PBC_S <- rnd (decision_2000_3000_PBC_S_1st, decision_2000_3000_PBC_S_median);
			id_group <- "2000_3000_b";		
		}
		create households_2000_3000 number: nb_households_2000_3000 * nb_units * 0.25{
			float decision_2000_3000_CEEK_median <- decision_2000_3000[1,2];
			float decision_2000_3000_CEEK_3rd <- decision_2000_3000[1,3];
			CEEK <- rnd (decision_2000_3000_CEEK_median, decision_2000_3000_CEEK_3rd);
			float decision_2000_3000_CEEA_median <- decision_2000_3000[2,2];
			float decision_2000_3000_CEEA_3rd <- decision_2000_3000[2,3];
			CEEA <- rnd (decision_2000_3000_CEEA_median, decision_2000_3000_CEEA_3rd);
			float decision_2000_3000_EDA_median <- decision_2000_3000[3,2];
			float decision_2000_3000_EDA_3rd <- decision_2000_3000[3,3];
			EDA <- rnd (decision_2000_3000_EDA_median, decision_2000_3000_EDA_3rd);
			float decision_2000_3000_PN_median <- decision_2000_3000[4,2];
			float decision_2000_3000_PN_3rd <- decision_2000_3000[4,3];
			PN <- rnd (decision_2000_3000_PN_median, decision_2000_3000_PN_3rd);
			float decision_2000_3000_SN_median <- decision_2000_3000[5,2];
			float decision_2000_3000_SN_3rd <- decision_2000_3000[5,3];
			SN <- rnd (decision_2000_3000_SN_median, decision_2000_3000_SN_3rd);
			float decision_2000_3000_EEH_median <- decision_2000_3000[6,2];
			float decision_2000_3000_EEH_3rd <- decision_2000_3000[6,3];
			EEH <- rnd (decision_2000_3000_EEH_median, decision_2000_3000_EEH_3rd);
			float decision_2000_3000_PBC_I_median <- decision_2000_3000[7,2];
			float decision_2000_3000_PBC_I_3rd <- decision_2000_3000[7,3];
			PBC_I <- rnd (decision_2000_3000_PBC_I_median, decision_2000_3000_PBC_I_3rd);
			float decision_2000_3000_PBC_C_median <- decision_2000_3000[8,2];
			float decision_2000_3000_PBC_C_3rd <- decision_2000_3000[8,3];
			PBC_C <- rnd (decision_2000_3000_PBC_C_median, decision_2000_3000_PBC_C_3rd);
			float decision_2000_3000_PBC_S_median <- decision_2000_3000[9,2];
			float decision_2000_3000_PBC_S_3rd <- decision_2000_3000[9,3];
			PBC_S <- rnd (decision_2000_3000_PBC_S_median, decision_2000_3000_PBC_S_3rd);
			id_group <- "2000_3000_c";
		}		
		create households_2000_3000 number: nb_households_2000_3000 * nb_units * 0.25{
			float decision_2000_3000_CEEK_3rd <- decision_2000_3000[1,3];
			float decision_2000_3000_CEEK_max <- decision_2000_3000[1,4];
			CEEK <- rnd (decision_2000_3000_CEEK_3rd, decision_2000_3000_CEEK_max);
			float decision_2000_3000_CEEA_3rd <- decision_2000_3000[2,3];
			float decision_2000_3000_CEEA_max <- decision_2000_3000[2,4];
			CEEA <- rnd (decision_2000_3000_CEEA_3rd, decision_2000_3000_CEEA_max);
			float decision_2000_3000_EDA_3rd <- decision_2000_3000[3,3];
			float decision_2000_3000_EDA_max <- decision_2000_3000[3,4];
			EDA <- rnd (decision_2000_3000_EDA_3rd, decision_2000_3000_EDA_max);
			float decision_2000_3000_PN_3rd <- decision_2000_3000[4,3];
			float decision_2000_3000_PN_max <- decision_2000_3000[4,4];
			PN <- rnd (decision_2000_3000_PN_3rd, decision_2000_3000_PN_max);
			float decision_2000_3000_SN_3rd <- decision_2000_3000[5,3];
			float decision_2000_3000_SN_max <- decision_2000_3000[5,4];
			SN <- rnd (decision_2000_3000_SN_3rd, decision_2000_3000_SN_max);
			float decision_2000_3000_EEH_3rd <- decision_2000_3000[6,3];
			float decision_2000_3000_EEH_max <- decision_2000_3000[6,4];
			EEH <- rnd (decision_2000_3000_EEH_3rd, decision_2000_3000_EEH_max);
			float decision_2000_3000_PBC_I_3rd <- decision_2000_3000[7,3];
			float decision_2000_3000_PBC_I_max <- decision_2000_3000[7,4];
			PBC_I <- rnd (decision_2000_3000_PBC_I_3rd, decision_2000_3000_PBC_I_max);
			float decision_2000_3000_PBC_C_3rd <- decision_2000_3000[8,3];
			float decision_2000_3000_PBC_C_max <- decision_2000_3000[8,4];
			PBC_C <- rnd (decision_2000_3000_PBC_C_3rd, decision_2000_3000_PBC_C_max);
			float decision_2000_3000_PBC_S_3rd <- decision_2000_3000[9,3];
			float decision_2000_3000_PBC_S_max <- decision_2000_3000[9,4];
			PBC_S <- rnd (decision_2000_3000_PBC_S_3rd, decision_2000_3000_PBC_S_max);
			id_group <- "2000_3000_d";
		}
		
		
		create households_3000_4000 number: nb_households_3000_4000 * nb_units * 0.25{
			float decision_3000_4000_CEEK_min <- decision_3000_4000[1,0];
			float decision_3000_4000_CEEK_1st <- decision_3000_4000[1,1];
			CEEK <- rnd (decision_3000_4000_CEEK_min, decision_3000_4000_CEEK_1st);
			float decision_3000_4000_CEEA_min <- decision_3000_4000[2,0];
			float decision_3000_4000_CEEA_1st <- decision_3000_4000[2,1];
			CEEA <- rnd (decision_3000_4000_CEEA_min, decision_3000_4000_CEEA_1st);
			float decision_3000_4000_EDA_min <- decision_3000_4000[3,0];
			float decision_3000_4000_EDA_1st <- decision_3000_4000[3,1];
			EDA <- rnd (decision_3000_4000_EDA_min, decision_3000_4000_EDA_1st);
			float decision_3000_4000_PN_min <- decision_3000_4000[4,0];
			float decision_3000_4000_PN_1st <- decision_3000_4000[4,1];
			PN <- rnd (decision_3000_4000_PN_min, decision_3000_4000_PN_1st);
			float decision_3000_4000_SN_min <- decision_3000_4000[5,0];
			float decision_3000_4000_SN_1st <- decision_3000_4000[5,1];
			SN <- rnd (decision_3000_4000_SN_min, decision_3000_4000_SN_1st);
			float decision_3000_4000_EEH_min <- decision_3000_4000[6,0];
			float decision_3000_4000_EEH_1st <- decision_3000_4000[6,1];
			EEH <- rnd (decision_3000_4000_EEH_min, decision_3000_4000_EEH_1st);
			float decision_3000_4000_PBC_I_min <- decision_3000_4000[7,0];
			float decision_3000_4000_PBC_I_1st <- decision_3000_4000[7,1];
			PBC_I <- rnd (decision_3000_4000_PBC_I_min, decision_3000_4000_PBC_I_1st);
			float decision_3000_4000_PBC_C_min <- decision_3000_4000[8,0];
			float decision_3000_4000_PBC_C_1st <- decision_3000_4000[8,1];
			PBC_C <- rnd (decision_3000_4000_PBC_C_min, decision_3000_4000_PBC_C_1st);
			float decision_3000_4000_PBC_S_min <- decision_3000_4000[9,0];
			float decision_3000_4000_PBC_S_1st <- decision_3000_4000[9,1];
			PBC_S <- rnd (decision_3000_4000_PBC_S_min, decision_3000_4000_PBC_S_1st);
			id_group <- "3000_4000_a";	
		}	
		create households_3000_4000 number: nb_households_3000_4000 * nb_units * 0.25{
			float decision_3000_4000_CEEK_1st <- decision_3000_4000[1,1];
			float decision_3000_4000_CEEK_median <- decision_3000_4000[1,2];
			CEEK <- rnd (decision_3000_4000_CEEK_1st, decision_3000_4000_CEEK_median);
			float decision_3000_4000_CEEA_1st <- decision_3000_4000[2,1];
			float decision_3000_4000_CEEA_median <- decision_3000_4000[2,2];
			CEEA <- rnd (decision_3000_4000_CEEA_1st, decision_3000_4000_CEEA_median);
			float decision_3000_4000_EDA_1st <- decision_3000_4000[3,1];
			float decision_3000_4000_EDA_median <- decision_3000_4000[3,2];
			EDA <- rnd (decision_3000_4000_EDA_1st, decision_3000_4000_EDA_median);
			float decision_3000_4000_PN_1st <- decision_3000_4000[4,1];
			float decision_3000_4000_PN_median <- decision_3000_4000[4,2];
			PN <- rnd (decision_3000_4000_PN_1st, decision_3000_4000_PN_median);
			float decision_3000_4000_SN_1st <- decision_3000_4000[5,1];
			float decision_3000_4000_SN_median <- decision_3000_4000[5,2];
			SN <- rnd (decision_3000_4000_SN_1st, decision_3000_4000_SN_median);
			float decision_3000_4000_EEH_1st <- decision_3000_4000[6,1];
			float decision_3000_4000_EEH_median <- decision_3000_4000[6,2];
			EEH <- rnd (decision_3000_4000_EEH_1st, decision_3000_4000_EEH_median);
			float decision_3000_4000_PBC_I_1st <- decision_3000_4000[7,1];
			float decision_3000_4000_PBC_I_median <- decision_3000_4000[7,2];
			PBC_I <- rnd (decision_3000_4000_PBC_I_1st, decision_3000_4000_PBC_I_median);
			float decision_3000_4000_PBC_C_1st <- decision_3000_4000[8,1];
			float decision_3000_4000_PBC_C_median <- decision_3000_4000[8,2];
			PBC_C <- rnd (decision_3000_4000_PBC_C_1st, decision_3000_4000_PBC_C_median);
			float decision_3000_4000_PBC_S_1st <- decision_3000_4000[9,1];
			float decision_3000_4000_PBC_S_median <- decision_3000_4000[9,2];
			PBC_S <- rnd (decision_3000_4000_PBC_S_1st, decision_3000_4000_PBC_S_median);
			id_group <- "3000_4000_b";		
		}		
		create households_3000_4000 number: nb_households_3000_4000 * nb_units * 0.25{
			float decision_3000_4000_CEEK_median <- decision_3000_4000[1,2];
			float decision_3000_4000_CEEK_3rd <- decision_3000_4000[1,3];
			CEEK <- rnd (decision_3000_4000_CEEK_median, decision_3000_4000_CEEK_3rd);
			float decision_3000_4000_CEEA_median <- decision_3000_4000[2,2];
			float decision_3000_4000_CEEA_3rd <- decision_3000_4000[2,3];
			CEEA <- rnd (decision_3000_4000_CEEA_median, decision_3000_4000_CEEA_3rd);
			float decision_3000_4000_EDA_median <- decision_3000_4000[3,2];
			float decision_3000_4000_EDA_3rd <- decision_3000_4000[3,3];
			EDA <- rnd (decision_3000_4000_EDA_median, decision_3000_4000_EDA_3rd);
			float decision_3000_4000_PN_median <- decision_3000_4000[4,2];
			float decision_3000_4000_PN_3rd <- decision_3000_4000[4,3];
			PN <- rnd (decision_3000_4000_PN_median, decision_3000_4000_PN_3rd);
			float decision_3000_4000_SN_median <- decision_3000_4000[5,2];
			float decision_3000_4000_SN_3rd <- decision_3000_4000[5,3];
			SN <- rnd (decision_3000_4000_SN_median, decision_3000_4000_SN_3rd);
			float decision_3000_4000_EEH_median <- decision_3000_4000[6,2];
			float decision_3000_4000_EEH_3rd <- decision_3000_4000[6,3];
			EEH <- rnd (decision_3000_4000_EEH_median, decision_3000_4000_EEH_3rd);
			float decision_3000_4000_PBC_I_median <- decision_3000_4000[7,2];
			float decision_3000_4000_PBC_I_3rd <- decision_3000_4000[7,3];
			PBC_I <- rnd (decision_3000_4000_PBC_I_median, decision_3000_4000_PBC_I_3rd);
			float decision_3000_4000_PBC_C_median <- decision_3000_4000[8,2];
			float decision_3000_4000_PBC_C_3rd <- decision_3000_4000[8,3];
			PBC_C <- rnd (decision_3000_4000_PBC_C_median, decision_3000_4000_PBC_C_3rd);
			float decision_3000_4000_PBC_S_median <- decision_3000_4000[9,2];
			float decision_3000_4000_PBC_S_3rd <- decision_3000_4000[9,3];
			PBC_S <- rnd (decision_3000_4000_PBC_S_median, decision_3000_4000_PBC_S_3rd);
			id_group <- "3000_4000_c";
		}
		create households_3000_4000 number: nb_households_3000_4000 * nb_units * 0.25{
			float decision_3000_4000_CEEK_3rd <- decision_3000_4000[1,3];
			float decision_3000_4000_CEEK_max <- decision_3000_4000[1,4];
			CEEK <- rnd (decision_3000_4000_CEEK_3rd, decision_3000_4000_CEEK_max);
			float decision_3000_4000_CEEA_3rd <- decision_3000_4000[2,3];
			float decision_3000_4000_CEEA_max <- decision_3000_4000[2,4];
			CEEA <- rnd (decision_3000_4000_CEEA_3rd, decision_3000_4000_CEEA_max);
			float decision_3000_4000_EDA_3rd <- decision_3000_4000[3,3];
			float decision_3000_4000_EDA_max <- decision_3000_4000[3,4];
			EDA <- rnd (decision_3000_4000_EDA_3rd, decision_3000_4000_EDA_max);
			float decision_3000_4000_PN_3rd <- decision_3000_4000[4,3];
			float decision_3000_4000_PN_max <- decision_3000_4000[4,4];
			PN <- rnd (decision_3000_4000_PN_3rd, decision_3000_4000_PN_max);
			float decision_3000_4000_SN_3rd <- decision_3000_4000[5,3];
			float decision_3000_4000_SN_max <- decision_3000_4000[5,4];
			SN <- rnd (decision_3000_4000_SN_3rd, decision_3000_4000_SN_max);
			float decision_3000_4000_EEH_3rd <- decision_3000_4000[6,3];
			float decision_3000_4000_EEH_max <- decision_3000_4000[6,4];
			EEH <- rnd (decision_3000_4000_EEH_3rd, decision_3000_4000_EEH_max);
			float decision_3000_4000_PBC_I_3rd <- decision_3000_4000[7,3];
			float decision_3000_4000_PBC_I_max <- decision_3000_4000[7,4];
			PBC_I <- rnd (decision_3000_4000_PBC_I_3rd, decision_3000_4000_PBC_I_max);
			float decision_3000_4000_PBC_C_3rd <- decision_3000_4000[8,3];
			float decision_3000_4000_PBC_C_max <- decision_3000_4000[8,4];
			PBC_C <- rnd (decision_3000_4000_PBC_C_3rd, decision_3000_4000_PBC_C_max);
			float decision_3000_4000_PBC_S_3rd <- decision_3000_4000[9,3];
			float decision_3000_4000_PBC_S_max <- decision_3000_4000[9,4];
			PBC_S <- rnd (decision_3000_4000_PBC_S_3rd, decision_3000_4000_PBC_S_max);
			id_group <- "3000_4000_d";
		}		
		
		
		create households_4000etc number: nb_households_4000etc * nb_units * 0.25{
			float decision_4000etc_CEEK_min <- decision_4000etc[1,0];
			float decision_4000etc_CEEK_1st <- decision_4000etc[1,1];
			CEEK <- rnd (decision_4000etc_CEEK_min, decision_4000etc_CEEK_1st);
			float decision_4000etc_CEEA_min <- decision_4000etc[2,0];
			float decision_4000etc_CEEA_1st <- decision_4000etc[2,1];
			CEEA <- rnd (decision_4000etc_CEEA_min, decision_4000etc_CEEA_1st);
			float decision_4000etc_EDA_min <- decision_4000etc[3,0];
			float decision_4000etc_EDA_1st <- decision_4000etc[3,1];
			EDA <- rnd (decision_4000etc_EDA_min, decision_4000etc_EDA_1st);
			float decision_4000etc_PN_min <- decision_4000etc[4,0];
			float decision_4000etc_PN_1st <- decision_4000etc[4,1];
			PN <- rnd (decision_4000etc_PN_min, decision_4000etc_PN_1st);
			float decision_4000etc_SN_min <- decision_4000etc[5,0];
			float decision_4000etc_SN_1st <- decision_4000etc[5,1];
			SN <- rnd (decision_4000etc_SN_min, decision_4000etc_SN_1st);
			float decision_4000etc_EEH_min <- decision_4000etc[6,0];
			float decision_4000etc_EEH_1st <- decision_4000etc[6,1];
			EEH <- rnd (decision_4000etc_EEH_min, decision_4000etc_EEH_1st);
			float decision_4000etc_PBC_I_min <- decision_4000etc[7,0];
			float decision_4000etc_PBC_I_1st <- decision_4000etc[7,1];
			PBC_I <- rnd (decision_4000etc_PBC_I_min, decision_4000etc_PBC_I_1st);
			float decision_4000etc_PBC_C_min <- decision_4000etc[8,0];
			float decision_4000etc_PBC_C_1st <- decision_4000etc[8,1];
			PBC_C <- rnd (decision_4000etc_PBC_C_min, decision_4000etc_PBC_C_1st);
			float decision_4000etc_PBC_S_min <- decision_4000etc[9,0];
			float decision_4000etc_PBC_S_1st <- decision_4000etc[9,1];
			PBC_S <- rnd (decision_4000etc_PBC_S_min, decision_4000etc_PBC_S_1st);
			id_group <- "4000etc_a";
		}
		create households_4000etc number: nb_households_4000etc * nb_units * 0.25{
			float decision_4000etc_CEEK_1st <- decision_4000etc[1,1];
			float decision_4000etc_CEEK_median <- decision_4000etc[1,2];
			CEEK <- rnd (decision_4000etc_CEEK_1st, decision_4000etc_CEEK_median);
			float decision_4000etc_CEEA_1st <- decision_4000etc[2,1];
			float decision_4000etc_CEEA_median <- decision_4000etc[2,2];
			CEEA <- rnd (decision_4000etc_CEEA_1st, decision_4000etc_CEEA_median);
			float decision_4000etc_EDA_1st <- decision_4000etc[3,1];
			float decision_4000etc_EDA_median <- decision_4000etc[3,2];
			EDA <- rnd (decision_4000etc_EDA_1st, decision_4000etc_EDA_median);
			float decision_4000etc_PN_1st <- decision_4000etc[4,1];
			float decision_4000etc_PN_median <- decision_4000etc[4,2];
			PN <- rnd (decision_4000etc_PN_1st, decision_4000etc_PN_median);
			float decision_4000etc_SN_1st <- decision_4000etc[5,1];
			float decision_4000etc_SN_median <- decision_4000etc[5,2];
			SN <- rnd (decision_4000etc_SN_1st, decision_4000etc_SN_median);
			float decision_4000etc_EEH_1st <- decision_4000etc[6,1];
			float decision_4000etc_EEH_median <- decision_4000etc[6,2];
			EEH <- rnd (decision_4000etc_EEH_1st, decision_4000etc_EEH_median);
			float decision_4000etc_PBC_I_1st <- decision_4000etc[7,1];
			float decision_4000etc_PBC_I_median <- decision_4000etc[7,2];
			PBC_I <- rnd (decision_4000etc_PBC_I_1st, decision_4000etc_PBC_I_median);
			float decision_4000etc_PBC_C_1st <- decision_4000etc[8,1];
			float decision_4000etc_PBC_C_median <- decision_4000etc[8,2];
			PBC_C <- rnd (decision_4000etc_PBC_C_1st, decision_4000etc_PBC_C_median);
			float decision_4000etc_PBC_S_1st <- decision_4000etc[9,1];
			float decision_4000etc_PBC_S_median <- decision_4000etc[9,2];
			PBC_S <- rnd (decision_4000etc_PBC_S_1st, decision_4000etc_PBC_S_median);
			id_group <- "4000etc_b";		
		}
		create households_4000etc number: nb_households_4000etc * nb_units * 0.25{
			float decision_4000etc_CEEK_median <- decision_4000etc[1,2];
			float decision_4000etc_CEEK_3rd <- decision_4000etc[1,3];
			CEEK <- rnd (decision_4000etc_CEEK_median, decision_4000etc_CEEK_3rd);
			float decision_4000etc_CEEA_median <- decision_4000etc[2,2];
			float decision_4000etc_CEEA_3rd <- decision_4000etc[2,3];
			CEEA <- rnd (decision_4000etc_CEEA_median, decision_4000etc_CEEA_3rd);
			float decision_4000etc_EDA_median <- decision_4000etc[3,2];
			float decision_4000etc_EDA_3rd <- decision_4000etc[3,3];
			EDA <- rnd (decision_4000etc_EDA_median, decision_4000etc_EDA_3rd);
			float decision_4000etc_PN_median <- decision_4000etc[4,2];
			float decision_4000etc_PN_3rd <- decision_4000etc[4,3];
			PN <- rnd (decision_4000etc_PN_median, decision_4000etc_PN_3rd);
			float decision_4000etc_SN_median <- decision_4000etc[5,2];
			float decision_4000etc_SN_3rd <- decision_4000etc[5,3];
			SN <- rnd (decision_4000etc_SN_median, decision_4000etc_SN_3rd);
			float decision_4000etc_EEH_median <- decision_4000etc[6,2];
			float decision_4000etc_EEH_3rd <- decision_4000etc[6,3];
			EEH <- rnd (decision_4000etc_EEH_median, decision_4000etc_EEH_3rd);
			float decision_4000etc_PBC_I_median <- decision_4000etc[7,2];
			float decision_4000etc_PBC_I_3rd <- decision_4000etc[7,3];
			PBC_I <- rnd (decision_4000etc_PBC_I_median, decision_4000etc_PBC_I_3rd);
			float decision_4000etc_PBC_C_median <- decision_4000etc[8,2];
			float decision_4000etc_PBC_C_3rd <- decision_4000etc[8,3];
			PBC_C <- rnd (decision_4000etc_PBC_C_median, decision_4000etc_PBC_C_3rd);
			float decision_4000etc_PBC_S_median <- decision_4000etc[9,2];
			float decision_4000etc_PBC_S_3rd <- decision_4000etc[9,3];
			PBC_S <- rnd (decision_4000etc_PBC_S_median, decision_4000etc_PBC_S_3rd);
			id_group <- "4000etc_c";
		}
		create households_4000etc number: nb_households_4000etc * nb_units * 0.25{
			float decision_4000etc_CEEK_3rd <- decision_4000etc[1,3];
			float decision_4000etc_CEEK_max <- decision_4000etc[1,4];
			CEEK <- rnd (decision_4000etc_CEEK_3rd, decision_4000etc_CEEK_max);
			float decision_4000etc_CEEA_3rd <- decision_4000etc[2,3];
			float decision_4000etc_CEEA_max <- decision_4000etc[2,4];
			CEEA <- rnd (decision_4000etc_CEEA_3rd, decision_4000etc_CEEA_max);
			float decision_4000etc_EDA_3rd <- decision_4000etc[3,3];
			float decision_4000etc_EDA_max <- decision_4000etc[3,4];
			EDA <- rnd (decision_4000etc_EDA_3rd, decision_4000etc_EDA_max);
			float decision_4000etc_PN_3rd <- decision_4000etc[4,3];
			float decision_4000etc_PN_max <- decision_4000etc[4,4];
			PN <- rnd (decision_4000etc_PN_3rd, decision_4000etc_PN_max);
			float decision_4000etc_SN_3rd <- decision_4000etc[5,3];
			float decision_4000etc_SN_max <- decision_4000etc[5,4];
			SN <- rnd (decision_4000etc_SN_3rd, decision_4000etc_SN_max);
			float decision_4000etc_EEH_3rd <- decision_4000etc[6,3];
			float decision_4000etc_EEH_max <- decision_4000etc[6,4];
			EEH <- rnd (decision_4000etc_EEH_3rd, decision_4000etc_EEH_max);
			float decision_4000etc_PBC_I_3rd <- decision_4000etc[7,3];
			float decision_4000etc_PBC_I_max <- decision_4000etc[7,4];
			PBC_I <- rnd (decision_4000etc_PBC_I_3rd, decision_4000etc_PBC_I_max);
			float decision_4000etc_PBC_C_3rd <- decision_4000etc[8,3];
			float decision_4000etc_PBC_C_max <- decision_4000etc[8,4];
			PBC_C <- rnd (decision_4000etc_PBC_C_3rd, decision_4000etc_PBC_C_max);
			float decision_4000etc_PBC_S_3rd <- decision_4000etc[9,3];
			float decision_4000etc_PBC_S_max <- decision_4000etc[9,4];
			PBC_S <- rnd (decision_4000etc_PBC_S_3rd, decision_4000etc_PBC_S_max);
			id_group <- "4000etc_d";
		}
		*/
		
// Age -> distributes the share of age-groups among the generic-species household
		ask (int(share_age_21_40 * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {//!bool(each.age) ist TRUE, wenn age noch nicht existiert
			age <- rnd (21, 40);	
		}
		ask (int(share_age_41_60 * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (41, 60);	
		}
		ask (int(share_age_61_80 * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (61, 80);	
		}
		ask (int(share_age_80etc * nb_units)) among (agents of_generic_species households where (!bool(each.age))) {
			age <- rnd (81, 100); //max age = 100	
		}
		
		
// Ownership -> distributes the share of ownership-status among household-groups 
		
		loop income_group over: income_groups_list {
			ask income_group {
				ownership <- "tenant";
			}
			
			ask int(share_owner_map[income_group] * length(income_group)) among income_group { //das Problem ist, dass der Parser immer wissen möchte, mit welchen Typen er arbeitet. Ich hab die jetzt schon oben als float deklariert (Zeile 80), dann funktioniert es.
				ownership <- "owner";
			}
			
			
		}
		
	
// problem behoben, allerdings duerfte verkuerzen durch liste möglich sein..	
// Employment -> distributes the share of employment-groups among household-groups
		loop income_group over: income_groups_list {
			ask int(share_student[income_group] * length(income_group)) among income_group{
				employment <- "student";
			}
			ask int(share_employed[income_group] * length(income_group)) among income_group where (!bool(each.employment)) {
				employment <- "employed";
			}
			ask int(share_selfemployed[income_group] * length(income_group)) among income_group where (!bool(each.employment)) {
				employment <- "self-employed";
			}
			ask int(share_unemployed[income_group] * length(income_group)) among income_group where (!bool(each.employment)) {
				employment <- "unemployed";
			}
			ask int(share_pensioner[income_group] * length(income_group)) among income_group where (!bool(each.employment)) {
				employment <- "pensioner";
			}
		}
		
		
		
//Network
//Erweiterung: Verknüpfen der Kontakte, die nicht "direct" sind mit Ausprägung der psych-Werte/income, um preferential attachment nach Eigenschaften abzubilden

	//entweder ebenfalls alle an dieser stelle aufführen oder über liste möglich?
	int network_spatial_direct_employed_min <- network_employed[0,1];
	int network_spatial_direct_employed_1st <- network_employed[2,1];
	int network_spatial_direct_employed_median <- network_employed[3,1];
	int network_spatial_direct_employed_3rd <- network_employed[4,1];
	int network_spatial_direct_employed_max <- network_employed[5,1];
	
	int network_spatial_street_employed <- network_employed[1,1];
	int network_spatial_neighborhood_employed <- network_employed[1,1];
	int network_spatial_beyond_employed <- network_employed[1,1];
	int network_temporal_daily_employed <-  network_employed[1,1];
	int network_temporal_weekly_employed <- network_employed[1,1];
	int network_temporal_occasional_employed <- network_employed[1,1];
	
	float network_socialgroup_employed <- network_employed[1,1];
	

		
	//muss weiter geführt werden - liste?
	//noch nicht auf tatsächliche Funktion geprüft - falls "length" in dem kontext nicht funktioniert ggf "count" verwenden
	let nb_employed <- length(agents of_generic_species households where (each.age = "employed"));// ggf nicht als temp_variable sondern als global definieren? ggf an anderer stelle ebenfalls gebraucht
	ask (0.25 * nb_employed) among (agents of_generic_species households where (each.age = "employed")) {
		network_contacts_spatial_direct <- rnd (network_spatial_direct_employed_min, network_spatial_direct_employed_1st);	
	}
	ask (0.25 * nb_employed) among (agents of_generic_species households where ((each.age = "employed") and (!bool(each.network_contacts_spatial_direct)))) {
		network_contacts_spatial_direct <- rnd (network_spatial_direct_employed_1st, network_spatial_direct_employed_median);	
	}		
	ask (0.25 * nb_employed) among (agents of_generic_species households where ((each.age = "employed") and (!bool(each.network_contacts_spatial_direct)))) {
		network_contacts_spatial_direct <- rnd (network_spatial_direct_employed_median, network_spatial_direct_employed_3rd);	
	}	
	ask (0.25 * nb_employed) among (agents of_generic_species households where ((each.age = "employed") and (!bool(each.network_contacts_spatial_direct)))) {
		network_contacts_spatial_direct <- rnd (network_spatial_direct_employed_3rd, network_spatial_direct_employed_max);	
	}
		
				
}		/////////////////////////////////////TO-DO//////////////////////////////////////
	//////////	- Finalisieren der Datenintegration; ggf Uebertragen der struktur in Listen
	//////////	- Ueberpruefung einzelner Werte in Datei "socio-data_export_final" -> bspw "families"
	//////////  - 
	//////////  - Beginn der Erstellung des Entscheidungs-Algorithmus
	//////////  - Uebertrag in Shapefiles
	//////////  - Technischer Layer	
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
	float EEH; // Energy Efficient Habits
	
	
	int income; //households income/month -> ATTENTION -> besonderer Validierungshinweis, da zufaellige Menge
	string id_group; // identification which quartile within the income group agent belongs to
		
	int age; //random mean-age of households
	string ownership; 
	string employment; //defines network behavior of each agent in parent species by employment status

	int network_contacts_spatial_direct;
	int network_contacts_spatial_street;
	int network_contacts_spatial_neighborhood;
	int network_contacts_spatial_beyond;
	int network_contacts_temporal_daily;	
	int network_contacts_temporal_weekly;
	int network_contacts_temporal_occasional;
	float network_socialgroup;
				
} 


species households_500_1000 parent: households {
	
	aspect base {
		draw circle(1) color: #green; //test-darstellung
	}
	
	int income <- rnd(500, 1000);

	
}

species households_1000_1500 parent: households {
	
	aspect base {
		draw circle(1) color: #red; //test-darstellung
	}

	int income <- rnd(1000, 1500);
	
	
}

species households_1500_2000 parent: households {
	
	aspect base {
		draw circle(1) color: #blue; //test-darstellung
	}

	int income <- rnd(1500, 2000);

	
}

species households_2000_3000 parent: households {
	
	aspect base {
		draw circle(1) color: #yellow; //test-darstellung
	}

	int income <- rnd(2000, 3000);

	
}

species households_3000_4000 parent: households {
	
	aspect base {
		draw circle(1) color: #purple; //test-darstellung
	}
	
	int income <- rnd(3000, 4000);
	
	
}

species households_4000etc parent: households {
	
	aspect base {
		draw circle(1) color: #grey; //test-darstellung
	}
	
	int income <- rnd(4000, 10000); //max income / month = 10.000
	
	
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