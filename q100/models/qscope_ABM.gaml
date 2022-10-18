/*
* Name: qScope_ABM
*
* Authors: lennartwinkeler, davidunland, philipolaleye
* Institution: University of Bremen, Department of Resilient Energy Systems
* Date: 2022-03-18
* Description: agent-based model within the project quarree100 - work group 2
*
* Obejctives:
* (1) simulating household pro environmental decision-making in built-up neighborhoods to develop an understanding of sociotechnical dynamics of energy transitions;
* (2) implementing the simulation in a CityScope framework for increasing the project's participation process and investigating stakeholder interaction & empowerment
*
*
*/


model q100
import "../modules/json_udp.gaml"

global {

	// bool show_heatingnetwork <- true;

	float step <- 1 #day;
	date starting_date <- date([2020,1,1,0,0,0]);



	string model_runtime_string <- string(get_initial_value("model_runtime_string"));
	reflex end_simulation when: (current_date.year = model_runtime()) and (current_date.month = 1) and (current_date.day = 1){
    	do pause;
    }

	int model_runtime {
		if model_runtime_string = "2020-2030" {
			return 2030;
		}
		else if model_runtime_string = "2020-2040" {
			return 2040;
		}
		else {
			return 2045;
		}
	}


	graph network <- graph([]);
	geometry shape <- envelope(shape_file_typologiezonen);
	list<string> months <- ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"];

	// load shapefiles
	file shape_file_buildings <- file("../includes/Shapefiles/bestandsgebaeude_export.shp");
	file shape_file_typologiezonen <- file("../includes/Shapefiles/Typologiezonen.shp");
	file nahwaerme <- file("../includes/Shapefiles/Nahwaermenetz.shp");
	file background_map <- file("../includes/Shapefiles/ruesdorfer_kamp_osm.png");
	file shape_file_new_buildings <- file("../includes/Shapefiles/Neubau Gebaeude Kataster.shp");

	matrix<string> initial_values <- matrix<string>(csv_file("../includes/csv-data_technical/initial_variables.csv", ",", true));

	list attributes_possible_sources <- ["Kataster_A", "Kataster_T"]; // create list from shapefile metadata; kataster_a = art, kataster_t = typ
	string attributes_source <- attributes_possible_sources[0];

	matrix<float> decision_500_1000 <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_500-1000_V1.csv", ",", float, true));
	matrix<float> decision_1000_1500 <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1000-1500_V1.csv", ",", float, true));
	matrix<float> decision_1500_2000 <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_1500-2000_V1.csv", ",", float, true));
	matrix<float> decision_2000_3000 <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_2000-3000_V1.csv", ",", float, true));
	matrix<float> decision_3000_4000 <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_3000-4000_V1.csv", ",", float, true));
	matrix<float> decision_4000etc <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/decision-making_4000etc_V1.csv", ",", float, true));

	matrix<int> network_employed <- matrix<int>(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_employed_V1.csv", ",", int, true));
	matrix<int> network_pensioner <- matrix<int>(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_pensioner_V1.csv", ",", int, true));
	matrix<int> network_selfemployed <- matrix<int>(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_self-employed_V1.csv", ",", int, true));
	matrix<int> network_student <- matrix<int>(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_student_V1.csv", ",", int, true));
	matrix<int> network_unemployed <- matrix<int>(csv_file("../includes/csv-data_socio/2021-11-18_V1/network_unemployed_V1.csv", ",", int, true));

	matrix<float> share_income <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-income_V1.csv",  ",", float, true)); // share of households in neighborhood sorted by income
	matrix<float> share_employment_income <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-employment_income_V1.csv", ",", float, true)); // distribution of employment status of households in neighborhood sorted by income
	matrix<float> share_ownership_income <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-ownership_income_V1.csv", ",", float, true)); // distribution of ownership status of households in neighborhood sorted by income

	list<float> savings_rates <- list<float>(list(csv_file("../includes/csv-data_socio/2022-07-01/sparquote_einkommen.csv", ",", float)));
	list<int> income_distribution_germany <- list<int>(csv_file("../includes/csv-data_socio/2022-07-01/einkommensdezile_obergrenzen.csv"));
	
	matrix<float> share_age_buildings_existing <- matrix<float>(csv_file("../includes/csv-data_socio/2021-11-18_V1/share-age_existing_V2.csv", ",", float, true)); // distribution of groups of age in neighborhood
	matrix<float> average_lor_inclusive <- matrix<float>(csv_file("../includes/csv-data_socio/2021-12-15/wohndauer_nach_alter_inkl_geburtsort.csv", ",", float, true)); //average length of residence for different age-groups including people who never moved
	matrix<float> average_lor_exclusive <- matrix<float>(csv_file("../includes/csv-data_socio/2021-12-15/wohndauer_nach_alter_ohne_geburtsort.csv", ",", float, true)); //average length of residence for different age-groups excluding people who never moved


	matrix<float> agora_45 <- matrix<float>(csv_file("../includes/csv-data_technical/agora2045_modell_rates.csv", ",", float, true));
	matrix<float> alphas <- matrix<float>(csv_file("../includes/csv-data_technical/alpha.csv", ",", float, true));
	matrix<float> carbon_prices <- matrix<float>(csv_file("../includes/csv-data_technical/carbon-prices.csv", ",", float, true));
	matrix<float> energy_prices_emissions <- matrix<float>(csv_file("../includes/csv-data_technical/energy_prices-emissions.csv", ",", float, true));
	matrix<float> q100_concept_prices_emissions <- matrix<float>(csv_file("../includes/csv-data_technical/q100_prices_emissions-dummy.csv", ",", float, true));

	string buildings_file <- (timestamp = "") ? "../data/outputs/output/buildings_clusters.csv" : "../data/outputs/output_" + timestamp + "/buildings_clusters_" + timestamp + ".csv";
	matrix<string> qscope_interchange_matrix <- matrix<string>(csv_file(buildings_file, ",", string, true));




	float alpha <- alphas [alpha_column(), 0]; // share of a household's expenditures that are spent on energy - the rest are composite goods
	string alpha_scenario;

	int alpha_column {
		if alpha_scenario = "Static_mean" {
			return 1;
		}
		else if alpha_scenario = "Dynamic_moderate" {
			return 2;
		}
		else if alpha_scenario = "Dynamic_high" {
			return 3;
		}
		else if alpha_scenario = "Static_high" {
			return 4;
		}
		else {
			return 0;
		}
	}

	bool carbon_price_on_off <- false;

	bool delta_on_off <- false;
	bool B_do_nothing <- false;
	float carbon_price <- carbon_prices [carbon_price_column(), 0];

	string carbon_price_scenario;

	int carbon_price_column {
		if  carbon_price_scenario = "A - Conservative" {
			return 1;
		}
		else if carbon_price_scenario = "B - Moderate" {
			return 2;
		}
		else if carbon_price_scenario = "C1 - Progressive" {
			return 3;
		}
		else if carbon_price_scenario = "C2 - Progressive" {
			return 4;
		}
		else if carbon_price_scenario = "C3 - Progressive" {
			return 5;
		}

	}

	float gas_price <- energy_prices_emissions [gas_price_column(), 0];
	string energy_price_scenario;
	int gas_price_column {
		if  energy_price_scenario = "Prices_Project start" {
			return 1;
		}
		else if energy_price_scenario = "Prices_2021" {
			return 2;
		}
		else if energy_price_scenario = "Prices_2022 1st half" {
			return 3;
		}
	}

	float oil_price <- energy_prices_emissions [oil_price_column(), 0];
	int oil_price_column {
		if  energy_price_scenario = "Prices_Project start" {
			return 5;
		}
		else if energy_price_scenario = "Prices_2021" {
			return 6;
		}
		else if energy_price_scenario = "Prices_2022 1st half" {
			return 7;
		}
	}

	float power_price <- energy_prices_emissions [power_price_column(), 0];
	int power_price_column {
		if  energy_price_scenario = "Prices_Project start" {
			return 9;
		}
		else if energy_price_scenario = "Prices_2021" {
			return 10;
		}
		else if energy_price_scenario = "Prices_2022 1st half" {
			return 11;
		}
	}

	float q100_price_opex <- q100_concept_prices_emissions [q100_price_opex_column(), 0];
	string q100_price_opex_scenario;
	int q100_price_opex_column {
		if  q100_price_opex_scenario = "12 ct / kWh (static)" {
			return 1;
		}
		else if q100_price_opex_scenario = "9-15 ct / kWh (dynamic)" {
			return 2;
		}
	}

	float gas_emissions <- energy_prices_emissions [4, 0];
	float oil_emissions <- energy_prices_emissions [8, 0];
	float power_emissions <- energy_prices_emissions [12, 0];

	float q100_emissions <- q100_concept_prices_emissions [q100_emissions_column(), 0];
	string q100_emissions_scenario;
	int q100_emissions_column {
		if  q100_emissions_scenario = "Constant_50g_/_kWh" {
			return 6;
		}
		else if q100_emissions_scenario = "Declining_Steps" {
			return 7;
		}
		else if q100_emissions_scenario = "Declining_Linear" {
			return 8;
		}
		else if q100_emissions_scenario = "Constant_Zero_emissions" {
			return 9;
		}
	}


	float income_change_rate <- agora_45 [11, 0];

	float power_consumption_change_rate <- agora_45 [13, 0];
	float heat_consumption_new_EFH_change_rate <- agora_45 [14, 0];
	float heat_consumption_new_MFH_change_rate <- agora_45 [15, 0];
	float heat_consumption_exist_EFH_change_rate <- agora_45 [16, 0];
	float heat_consumption_exist_MFH_change_rate <- agora_45 [17, 0];


	//	DATA FOR DECISION MAKING INVEST


	// MAX E AND C VALUES FOR NORMALIZATION
	float e_current_max;
	float e_invest_max;
	float e_change_max;
	float e_switch_max;
	float c_current_max;
	float c_invest_max;
	float c_change_max;
	float c_switch_max;

	int get_initial_value_int(string descr) {
		list<string> names <- column_at(initial_values, 3);
		int row <- index_of(names, descr);

		string type <- initial_values[1, row];
		string value <- initial_values[2, row];
		write [descr, row, type, value];
		if type = "int" {
			return int(value);
		}
		else {
			error "The type of the value should be int but is " + type;
		}
	}

	float get_initial_value_float(string descr) {
		list<string> names <- column_at(initial_values, 3);
		int row <- index_of(names, descr);

		string type <- initial_values[1, row];
		string value <- initial_values[2, row];
		write [descr, row, type, value];
		if type = "float" {
			return float(value);
		}
		else {
			error "The type of the value should be float but is " + type;
		}
	}

	string get_initial_value_string(string descr) {
		list<string> names <- column_at(initial_values, 3);
		int row <- index_of(names, descr);

		string type <- initial_values[1, row];
		string value <- initial_values[2, row];
		write [descr, row, type, value];
		if type = "string" {
			return string(value);
		}
		else {
			error "The type of the value should be string but is " + type;
		}
	}

	bool get_initial_value_bool(string descr) {
		list<string> names <- column_at(initial_values, 3);
		int row <- index_of(names, descr);

		string type <- initial_values[1, row];
		string value <- initial_values[2, row];
		write [descr, row, type, value];
		if type = "bool" {
			return bool(value);
		}
		else {
			error "The type of the value should be bool but is " + type;
		}
	}

	action get_initial_value(string descr) { //Retrieves the inital value for the variable with name "name".
		list<string> names <- column_at(initial_values, 3);
		int row <- index_of(names, descr);

		string type <- initial_values[1, row];
		string value <- initial_values[2, row];
		write [descr, row, type, value];
		if type = "bool"  {
			return bool(value);
		}
		else if type = "int" {
			return int(value);
		}
		else if type = "float" {
			return float(value);
		}
		else if type = "string" {
			return value;
		}


	}

	action update_max_values {	// Calculate MAX E AND C VALUES FOR NORMALIZATION //

		e_current_max <- max((agents of_generic_species households) accumulate (each.e_current));
		e_invest_max <- max((agents of_generic_species households) accumulate (each.e_invest));
		e_change_max <- max((agents of_generic_species households) accumulate (each.e_change));
		e_switch_max <- max((agents of_generic_species households) accumulate (each.e_switch));
		c_current_max <- max((agents of_generic_species households) accumulate (each.c_current));
		c_invest_max <- max((agents of_generic_species households) accumulate (each.c_invest));
		c_change_max <- max((agents of_generic_species households) accumulate (each.c_change));
		c_switch_max <- max((agents of_generic_species households) accumulate (each.c_switch));
	}

	action print_power_supplier{
		string export_file <- (timestamp != "") ? "../data/outputs/output_" + timestamp + "/buildings_power_suppliers.csv" : "../data/outputs/output/buildings_power_suppliers.csv";
		ask agents of_generic_species households {
			save [house.id, power_supplier] to: export_file type: "csv" rewrite: false;
		}
	}

	float q100_price_capex <- q100_concept_prices_emissions [q100_price_capex_column(), 0];
	string q100_price_capex_scenario;
	int q100_price_capex_column {
		if  q100_price_capex_scenario = "1 payment" {
			return 3;
		}
		else if q100_price_capex_scenario = "2 payments" {
			return 4;
		}
		else if q100_price_capex_scenario = "5 payments" {
			return 5;
		}
	}


	int nb_units <- get_nb_units(); // number of households
	int global_neighboring_distance <- get_initial_value_int("global_neighboring_distance");
	string new_buildings_parameter <- "none"; // determines the speed of completion of new_buildings
	bool new_buildings_order_random <- get_initial_value_bool("new_buildings_order_random"); // TODO future work will determine a specific order of construction of new_buildings

	bool new_buildings_flag <- true; // flag to disable new_buildings reflex, when no more buildings are available
	float energy_saving_rate <- get_initial_value_float("energy_saving_rate"); // generaliuzed energy-saving of modernized buildings in percent
  	float change_factor <- get_initial_value_float("change_factor"); // Energy-Saving of households with change = true
  	float change_threshold <- get_initial_value_float("change_threshold"); // minimum value for EEH to decide for decision "change" -> based on above average values of agent's EEH variable
  	float landlord_prop <- get_initial_value_float("landlord_prop"); // chance to convince landlord of building to connect to q100_heat_network after invest_decision was made - strong need of validation due to lack of data / literature
  	float MFH_connection_threshold <- get_initial_value_float("MFH_connection_threshold"); // share of MFH households with decision invest=true that is needed to connect building to heat_network
  	float feedback_factor <- get_initial_value_float("feedback_factor"); // influence factor of feedback after a decision is made or household moved into a building with q100-connection
  	bool B_feedback <- get_initial_value_bool("B_feedback"); // Feedback of a decision on other perceived behavioral control values on-off

	bool view_toggle <- get_initial_value_bool("view_toggle"); // Parameter to toggle the 3D-View.
	bool keep_seed <- get_initial_value_bool("keep_seed"); // When true, the simulation seed will not change.
	string timestamp <- "";

	int refurbished_buildings_year; // sum of buildings refurbished this year
	int unrefurbished_buildings_year; // sum of unrefurbished buildings at the beginning of the year
	float modernization_rate; // yearly rate of modernization

	list list_of_power_suppliers <- ["id", "power_supplier"]; // exports list of power suppliers for debug purposes

	float share_families <- get_initial_value_float("share_families"); // share of families in whole neighborhood
	float share_socialgroup_families <- get_initial_value_float("share_socialgroup_families"); // share of families that are part of a social group
	float share_socialgroup_nonfamilies <- get_initial_value_float("share_socialgroup_nonfamilies"); // share of households that are not families but part of a social group

	float private_communication <- get_initial_value_float("private_communication"); // influence on psychological data while private communication; value used in communication action, accessable in monitor; must be experimented, since high influence

	string influence_type <- get_initial_value_string("influence_type");
	bool communication_memory <- get_initial_value_bool("communication_memory");

	list<species<households>> income_groups_list <- [households_500_1000, households_1000_1500, households_1500_2000, households_2000_3000, households_3000_4000, households_4000etc];
	map<species<households>,float> share_income_map <- create_map(income_groups_list, list(share_income));
	map decision_map <- create_map(income_groups_list, [decision_500_1000, decision_1000_1500, decision_1500_2000, decision_2000_3000, decision_3000_4000, decision_4000etc]);

	list<float> shares_owner_list <- [share_ownership_income[1,0], share_ownership_income[2,0], share_ownership_income[3,0], share_ownership_income[4,0], share_ownership_income[5,0], share_ownership_income[6,0]];
	map<species<households>,float> share_owner_map <- create_map(income_groups_list, shares_owner_list);


	list<float> shares_student_list <- [share_employment_income[1,0], share_employment_income[2,0], share_employment_income[3,0], share_employment_income[4,0], share_employment_income[5,0], share_employment_income[6,0]];
	list<float> shares_employed_list <- [share_employment_income[1,1], share_employment_income[2,1], share_employment_income[3,1], share_employment_income[4,1], share_employment_income[5,1], share_employment_income[6,1]];
	list<float> shares_selfemployed_list <- [share_employment_income[1,2], share_employment_income[2,2], share_employment_income[3,2], share_employment_income[4,2], share_employment_income[5,2], share_employment_income[6,2]];
	list<float> shares_unemployed_list <- [share_employment_income[1,3], share_employment_income[2,3], share_employment_income[3,3], share_employment_income[4,3], share_employment_income[5,3], share_employment_income[6,3]];
	list<float> shares_pensioner_list <- [share_employment_income[1,4], share_employment_income[2,4], share_employment_income[3,4], share_employment_income[4,4], share_employment_income[5,4], share_employment_income[6,4]];

	map<species<households>,float> share_student <- create_map(income_groups_list, shares_student_list);
	map<species<households>,float> share_employed <- create_map(income_groups_list, shares_employed_list);
	map<species<households>,float> share_selfemployed <- create_map(income_groups_list, shares_selfemployed_list);
	map<species<households>,float> share_unemployed <- create_map(income_groups_list, shares_unemployed_list);
	map<species<households>,float> share_pensioner <- create_map(income_groups_list, shares_pensioner_list);

	int get_nb_units { //Calculates the number of available units based on the Kataster-data.
		int sum <- 0;
		loop bldg over: (building where (each.built)) {
			if (bldg.type != "NWG") {
				sum <- sum + bldg.units;
			}
		}
		return sum;
	}

	list<agent> get_all_instances(species<agent> spec) {
        return spec.population + spec.subspecies accumulate (get_all_instances(each));
    }


	list<list> random_groups(list input, int n) { // Randomly distributes the elements of the input-list in n lists of similar size.
		int len <- length(input);
		if len = 0 {
			return range(n - 1) accumulate [[]];
		}
		else if len = 1 {
			list<list> output <- range(n - 2) accumulate [[]];
			add input to: output;
			return shuffle(output);
		}
		else {
			list shuffled_input <- shuffle(input);
			list inds <- split_in(range(len - 1), n);
			list<list> output;
			loop group over: inds {
				add shuffled_input where (index_of(shuffled_input, each) in group) to: output;
			}
			return shuffle(output);
		}

	}

	action distribute_budget(list<households> household_list) { // assigns each household in the input list a budget based on their income and their age.
//		list<households> all_households <- list<households>(get_all_instances(households));
//		all_households <- sort_by(all_households, (each.income)); // list of all households is sorted by income to split them into deciles.
//		int n <- length(all_households);
		loop h over: household_list {
				int i <- index_of(collect(income_distribution_germany, (h.income <= each)), true); // Calculates income decile of the current household.
				ask h{
					self.budget <- self.income * 12 * savings_rates[i] / 100 * (self.age - 20); // Calculates households savings. It is assumed that a household starts saving at the age of 20.
				}
			}


	}

	init {
	global_neighboring_distance <- get_initial_value_int("global_neighboring_distance");
	new_buildings_order_random <- get_initial_value_bool("new_buildings_order_random"); // TODO future work will determine a specific order of construction of new_buildings
	energy_saving_rate <- get_initial_value_float("energy_saving_rate"); // generaliuzed energy-saving of modernized buildings in percent
  	change_factor <- get_initial_value_float("change_factor"); // Energy-Saving of households with change = true
  	change_threshold <- get_initial_value_float("change_threshold"); // minimum value for EEH to decide for decision "change" -> based on above average values of agent's EEH variable
  	landlord_prop <- get_initial_value_float("landlord_prop"); // chance to convince landlord of building to connect to q100_heat_network after invest_decision was made - strong need of validation due to lack of data / literature
  	MFH_connection_threshold <- get_initial_value_float("MFH_connection_threshold"); // share of MFH households with decision invest=true that is needed to connect building to heat_network
  	feedback_factor <- get_initial_value_float("feedback_factor"); // influence factor of feedback after a decision is made or household moved into a building with q100-connection
  	B_feedback <- get_initial_value_bool("B_feedback"); // Feedback of a decision on other perceived behavioral control values on-off
	view_toggle <- get_initial_value_bool("view_toggle"); // Parameter to toggle the 3D-View.
	keep_seed <- get_initial_value_bool("keep_seed"); // When true, the simulation seed will not change.
	share_families <- get_initial_value_float("share_families"); // share of families in whole neighborhood
	share_socialgroup_families <- get_initial_value_float("share_socialgroup_families"); // share of families that are part of a social group
	share_socialgroup_nonfamilies <- get_initial_value_float("share_socialgroup_nonfamilies"); // share of households that are not families but part of a social group
	private_communication <- get_initial_value_float("private_communication"); // influence on psychological data while private communication; value used in communication action, accessable in monitor; must be experimented, since high influence
	influence_type <- get_initial_value_string("influence_type");
	communication_memory <- get_initial_value_bool("communication_memory");

	write rnd(1.0);
	write qscope_interchange_matrix;

	if (timestamp = "") // only delete files in general output folder if using GUI
	{
		bool delete_csv_export_power_supplier <- delete_file("../data/outputs/output/buildings_power_suppliers.csv");
    	bool delete_csv_export_emissions <- delete_file("../data/outputs/output/emissions/");
    	bool delete_csv_export_energy_prices <- delete_file("../data/outputs/output/energy_prices/");
    	bool delete_csv_export_connections <- delete_file("../data/outputs/output/connections/");
	}
		create technical_data_calculator number: 1;
		create building from: shape_file_buildings with: [id::string(read("Kataster_C")), type::string(read(attributes_source)), units::int(read("Kataster_W")), street::string(read("Kataster_S")), mod_status::string(read("Kataster_8")), net_floor_area::int(read("Kataster_6")), spec_heat_consumption::float(read("Kataster13")), spec_power_consumption::float(read("Kataster15")), energy_source::string(read("Kataster_E"))] { // create agents according to shapefile metadata

			vacant <- bool(units);

			if type = "EFH" {
				color <- #blue;
			}
			else if type = "MFH" {
				color <- #lightblue;
			}
			else if type = "NWG" {
				color <- #gray;
			}

		}


		create building from: shape_file_new_buildings with: [id::string(read("Kataster_C")), type::string(read(attributes_source)), units::int(read("Kataster_W")), street::string(read("Kataster_S")), net_floor_area::int(read("Kataster_6")), spec_heat_consumption::float(read("Kataster13")), spec_power_consumption::float(read("Kataster15"))] { // create agents according to shapefile metadata
			vacant <- false;
			built <- false;
			mod_status <- "s";
			energy_source <- "q100"; // expecting a connection of all new buildings to the q100 heat network
			if type = "EFH" {
				color <- #blue;
			}
			else if type = "MFH" {
				color <- #lightblue;
			}
			else if type = "NWG" {
				color <- #gray;
			}
		}
		nb_units <- get_nb_units();




		int row_interchange <- 0;
		loop qscope_interchange over: qscope_interchange_matrix column_at 0 { // integrates individually made changes on qscope by users for buildings of the GAMA model
			ask (building where (each.id = qscope_interchange)) {
				qscope_interchange_flag <- true;


				if (int(qscope_interchange_matrix[4,row_interchange]) = 0) {

					energy_source <- qscope_interchange_matrix[3,row_interchange];

				}

				else if (int(qscope_interchange_matrix[4,row_interchange]) > 0)  // ATTENTION: Wert kommt als "False" oder (int2020-2045 rein.. ist "False" zulässig?
				{
					connection_year <- int(qscope_interchange_matrix[4,row_interchange]);
				}
				if (qscope_interchange_matrix[5,row_interchange] = "True") {
					mod_status <- "s";
					self.spec_heat_consumption <- self.spec_heat_consumption * (energy_saving_rate);
				}

				if (qscope_interchange_matrix[6,row_interchange] = "True") {
					self.change_tenants <- true;


//					ask self.get_tenants() {
//						write self.name + "I change";
//						change <- true;
//						// do decision_feedback_attitude;
//						// do decision_feedback_B ---> validation ---> should be implemented?
//					}
				}
			}
			row_interchange <- row_interchange + 1;
		}




		create nahwaermenetz from: nahwaerme;

		loop income_group over: income_groups_list { // creates households of the different income-groups according to the given share in *share_income_map*
			let letters <- ["a", "b", "c", "d"];
			loop i over: range(0,3) { // 4 subgroups a created for each income_group to represent the distribution of the given variables
				create income_group number: share_income_map[income_group] * nb_units * 0.25 {
					float decision_500_1000_CEEK_min <- decision_map[income_group][1,i];
					float decision_500_1000_CEEK_1st <- decision_map[income_group][1,i+1];
					A_k <- rnd (decision_500_1000_CEEK_min, decision_500_1000_CEEK_1st);
					float decision_500_1000_CEEA_min <- decision_map[income_group][2,i];
					float decision_500_1000_CEEA_1st <- decision_map[income_group][2,i+1];
					A_e <- rnd (decision_500_1000_CEEA_min, decision_500_1000_CEEA_1st);
					float decision_500_1000_EDA_min <- decision_map[income_group][3,i];
					float decision_500_1000_EDA_1st <- decision_map[income_group][3,i+1];
					A_d <- rnd (decision_500_1000_EDA_min, decision_500_1000_EDA_1st);
					float decision_500_1000_PN_min <- decision_map[income_group][4,i];
					float decision_500_1000_PN_1st <- decision_map[income_group][4,i+1];
					PN <- rnd (decision_500_1000_PN_min, decision_500_1000_PN_1st);
					float decision_500_1000_SN_min <- decision_map[income_group][5,i];
					float decision_500_1000_SN_1st <- decision_map[income_group][5,i+1];
					SN <- rnd (decision_500_1000_SN_min, decision_500_1000_SN_1st);
					float decision_500_1000_EEH_min <- decision_map[income_group][6,i];
					float decision_500_1000_EEH_1st <- decision_map[income_group][6,i+1];
					EEH <- rnd (decision_500_1000_EEH_min, decision_500_1000_EEH_1st);
					float decision_500_1000_PBC_I_min <- decision_map[income_group][7,i];
					float decision_500_1000_PBC_I_1st <- decision_map[income_group][7,i+1];
					B_i <- rnd (decision_500_1000_PBC_I_min, decision_500_1000_PBC_I_1st);
					float decision_500_1000_PBC_C_min <- decision_map[income_group][8,i];
					float decision_500_1000_PBC_C_1st <- decision_map[income_group][8,i+1];
					B_c <- rnd (decision_500_1000_PBC_C_min, decision_500_1000_PBC_C_1st);
					float decision_500_1000_PBC_S_min <- decision_map[income_group][9,i];
					float decision_500_1000_PBC_S_1st <- decision_map[income_group][9,i+1];

					B_s <- rnd (decision_500_1000_PBC_S_min, decision_500_1000_PBC_S_1st);
					id_group <- string(income_group) + "_" + letters[i];

					do find_house; //Locate household in a random building.
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
				employment <- "self_employed";
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


// Power Supplier -> distributes the power supplier among households

		ask (0.1 * nb_units) among agents of_generic_species households where (each.EEH > change_threshold) { //see documentation for references of supplier distribution; EEH is chosen by value above the median // change_threshold als Bedingung passend?
		 	power_supplier <- "green";
		}

		ask (0.08 * nb_units) among agents of_generic_species households where (each.power_supplier = nil) {
		 	power_supplier <- "mixed";
		}

		ask agents of_generic_species households where (each.power_supplier = nil) {
			power_supplier <- "conventional";
		}


// Floor area

		ask agents of_generic_species households {
			my_floor_area <- int(self.house.net_floor_area / self.house.units);
		}


//Network -> distributes the share of network-relations among the households. there are different network values for each employment status
		list<string> employment_status_list  <- ["student", "employed", "self_employed", "unemployed", "pensioner"];

		map<string,matrix<int>> network_map <- create_map(employment_status_list, [network_student, network_employed, network_selfemployed, network_unemployed, network_pensioner]);
		list<string> temporal_network_attributes <- households.attributes where (each contains "network_contacts_temporal"); // list of all temporal network variables
		list<string>  spatial_network_attributes <- households.attributes where (each contains "network_contacts_spatial"); // list of all spatial network variables
		loop emp_status over: employment_status_list { //iterate over the different employment states
			list<households> tmp_households <- (agents of_generic_species households) where (each.employment = emp_status); //temporary list of households with the current employment status
			int nb <- length(tmp_households);
			matrix<int> network_matrix <- network_map[emp_status]; //corresponding matrix of network values
			loop attr over: temporal_network_attributes { //loop over the different temporal network variables of each household
				int index <- index_of(temporal_network_attributes, attr);
				list tmp_households_grouped  <- list<list<households>>(random_groups(tmp_households, 4));
				loop i over: range(0, 3) { // loop to split the households in 4 quartiles
					ask tmp_households_grouped[i] {
						self[attr] <- rnd(network_matrix[index+2, i],network_matrix[index+2, i+1]);

					}
				}
			}
			loop attr over: spatial_network_attributes { // loop over the different spatial network variables of each household
				int index <- index_of(spatial_network_attributes, attr);
				list tmp_households_grouped  <- list<list<households>>(random_groups(tmp_households, 4));
				loop i over: range(0, 3) {// loop to split the households in 4 quarters
					ask tmp_households_grouped[i] {
						self[attr] <- rnd(network_matrix[index+6, i],network_matrix[index+6, i+1]);
					}
				}
			}
		}


		ask agents of_generic_species households where (each.family) { //distributes belonging to socialgroups over non-/families

			if flip (share_socialgroup_families) {
				network_socialgroup <- true;
			}
		}
		ask agents of_generic_species households where (!each.family) {
			if flip (share_socialgroup_nonfamilies) {
				network_socialgroup <- true;
			}
		}

		ask agents of_generic_species households { //creates network of social contacts
			do get_social_contacts;
			network <- network add_node(self);
		}

		loop edges_from over: agents of_generic_species households {
			loop edges_to over: edges_from.social_contacts {
				if !(contains_edge(network, edges_from::edges_to)) {
					network <- network add_edge(edges_from::edges_to);
				}
			}
		}


		do distribute_budget(agents of_generic_species households);


		ask agents of_generic_species households {
			do consume_energy;
		}
		do update_max_values;
		do print_power_supplier;
	}


	reflex new_household { //creates new households to keep the total number of households constant.
		let new_households of: households <- [];
		let n <- length(agents of_generic_species households);
		let wheights <- list(share_income);
		remove 1.0 from: wheights;
		let employment_status_list of: string <- ["student", "employed", "self_employed", "unemployed", "pensioner"];
		loop while: n < nb_units {
			let income_group<- sample(income_groups_list, 1, false, wheights)[0];
			let i <- rnd(0,3);
			create income_group number: 1 {
				add self to: new_households;
				do find_house;
				age <- rnd(21, 40);
				let share_families_21_40 <- ((share_families * nb_units) / (int(share_age_buildings_existing[0] * nb_units)));
				family <- flip(share_families_21_40);
				float decision_500_1000_CEEK_min <- decision_map[income_group][1,i];
				float decision_500_1000_CEEK_1st <- decision_map[income_group][1,i+1];
				A_k <- rnd (decision_500_1000_CEEK_min, decision_500_1000_CEEK_1st);
				float decision_500_1000_CEEA_min <- decision_map[income_group][2,i];
				float decision_500_1000_CEEA_1st <- decision_map[income_group][2,i+1];
				A_e <- rnd (decision_500_1000_CEEA_min, decision_500_1000_CEEA_1st);
				float decision_500_1000_EDA_min <- decision_map[income_group][3,i];
				float decision_500_1000_EDA_1st <- decision_map[income_group][3,i+1];
				A_d <- rnd (decision_500_1000_EDA_min, decision_500_1000_EDA_1st);
				float decision_500_1000_PN_min <- decision_map[income_group][4,i];
				float decision_500_1000_PN_1st <- decision_map[income_group][4,i+1];
				PN <- rnd (decision_500_1000_PN_min, decision_500_1000_PN_1st);
				float decision_500_1000_SN_min <- decision_map[income_group][5,i];
				float decision_500_1000_SN_1st <- decision_map[income_group][5,i+1];
				SN <- rnd (decision_500_1000_SN_min, decision_500_1000_SN_1st);
				float decision_500_1000_EEH_min <- decision_map[income_group][6,i];
				float decision_500_1000_EEH_1st <- decision_map[income_group][6,i+1];
				EEH <- rnd (decision_500_1000_EEH_min, decision_500_1000_EEH_1st);
				float decision_500_1000_PBC_I_min <- decision_map[income_group][7,i];
				float decision_500_1000_PBC_I_1st <- decision_map[income_group][7,i+1];
				B_i <- rnd (decision_500_1000_PBC_I_min, decision_500_1000_PBC_I_1st);
				float decision_500_1000_PBC_C_min <- decision_map[income_group][8,i];
				float decision_500_1000_PBC_C_1st <- decision_map[income_group][8,i+1];
				B_c <- rnd (decision_500_1000_PBC_C_min, decision_500_1000_PBC_C_1st);
				float decision_500_1000_PBC_S_min <- decision_map[income_group][9,i];
				float decision_500_1000_PBC_S_1st <- decision_map[income_group][9,i+1];
				B_s <- rnd (decision_500_1000_PBC_S_min, decision_500_1000_PBC_S_1st);
				id_group <- string(income_group) + "_" + ["a", "b", "c", "d"][i];
				employment <- sample(employment_status_list, 1, false)[0];
				if flip(share_owner_map[income_group]) {
					ownership <- "owner";
				}
				else {
					ownership <- "tenant";
				}

				if (EEH > 4.5 and flip(0.1)) {
					power_supplier <- "green";
				}
				else if flip(0.08) {
					power_supplier <- "mixed";
				}
				else {
					power_supplier <- "conventional";
				}
				my_floor_area <- int(self.house.net_floor_area / self.house.units);

				if self.house.energy_source = "q100" {
					do decision_feedback_attitude;
				}
			}
			n <- n + 1;
		}

 		// Distribute network values among the new households
		map<string, matrix<int>> network_map <- create_map(employment_status_list, [network_student, network_employed, network_selfemployed, network_unemployed, network_pensioner]);
		list<string> temporal_network_attributes <- households.attributes where (each contains "network_contacts_temporal"); // list of all temporal network variables
		list<string> spatial_network_attributes <- households.attributes where (each contains "network_contacts_spatial"); // list of all spatial network variables
		loop emp_status over: employment_status_list { //iterate over the different employment states
			let tmp_households <- new_households of_generic_species households where (each.employment = emp_status); //temporary list of households with the current employment status
			let nb <- length(tmp_households);
			//write [nb, 0.25 * nb];
			matrix<int> network_matrix <- network_map[emp_status]; //corresponding matrix of network values
			loop attr over: temporal_network_attributes { //loop over the different temporal network variables of each household
				let index <- index_of(temporal_network_attributes, attr);
				list tmp_households_grouped <- list<list<households>>(random_groups(tmp_households, 4));
				loop i over: range(0, 3) { // loop to split the households in 4 quartiles
					ask (tmp_households_grouped[i]) {
						//write self.name;
						self[attr] <- rnd(network_matrix[index+2, i],network_matrix[index+2, i+1]);
					}
				}
			}
			loop attr over: spatial_network_attributes { // loop over the different spatial network variables of each household
				int index <- index_of(spatial_network_attributes, attr);
				list tmp_households_grouped <- list<list<households>>(random_groups(tmp_households, 4));
				loop i over: range(0, 3) {// loop to split the households in 4 quarters
					ask tmp_households_grouped[i] {
						self[attr] <- rnd(network_matrix[index+6, i],network_matrix[index+6, i+1]);
					}
				}
			}
		}

		ask new_households of_generic_species households where (bool(each.family)) {
			if flip (share_socialgroup_families) {
				network_socialgroup <- true;
			}
		}

		ask new_households of_generic_species households where (!bool(each.family)) {
			if flip (share_socialgroup_nonfamilies) {
				network_socialgroup <- true;
			}
		}

		ask new_households of_generic_species households {
			do get_social_contacts;
			network <- network add_node(self);
			loop edges_to over: self.social_contacts {

					if !(contains_edge(network, self::edges_to)){
						network <- network add_edge(self::edges_to);
					}
			}
		}

		do distribute_budget(new_households);
		if sum_of(new_households of_generic_species households, length(each.social_contacts)) > 0 {

		}

	}

	reflex new_building{ // Reflex to introduce new buildings into the model. Three different options are available.
		if new_buildings_flag and (cycle mod 365 = 0){ // New buildings are only created once a year.
			if (new_buildings_parameter = "at_once") and (current_date.year = 2025) { // All new buildings are introduced at once.
				ask building where (!each.built) {
					self.built <- true;
					self.vacant <- bool(self.units);
				}
				nb_units <- get_nb_units(); // Updates the number of available housing units.
			}
			if (new_buildings_parameter = "continuously"){ // Each year, two new buildings are introduced.
				ask 2 among (building where (!each.built)) {
					self.built <- true;
					self.vacant <- bool(self.units);
				}
				nb_units <- get_nb_units();
			}
			if (new_buildings_parameter = "linear2030") and (current_date.year < 2030){ // The number of buildings grows linearly with a rate that ensures, all buildings are introduced by year 2030.
				int remaining_buildings <- length(building where (!each.built));
				int rate <- int(remaining_buildings / (2030 - current_date.year) + 1); // + 1 rounds the rate up to the next integer.
				ask rate among (building where (!each.built)) {
					self.built <- true;
					self.vacant <- bool(self.units);
				}
				nb_units <- get_nb_units();
			}
			if length(building where (!each.built)) = 0 or (new_buildings_parameter = "none") { // If no more buildings are available, the reflex is deactivated.
				new_buildings_flag <- false;
			}
		}

	}



	reflex annual_updates_technical_data {
		if (current_date.month = 1) and (current_date.day = 1) {

			alpha <- alphas [alpha_column(), current_date.year - 2020];
			carbon_price <- carbon_prices [carbon_price_column(), current_date.year - 2020];
			gas_price <- energy_prices_emissions [gas_price_column(), current_date.year - 2020];
			oil_price <- energy_prices_emissions [oil_price_column(), current_date.year - 2020];
			power_price <- energy_prices_emissions [power_price_column(), current_date.year - 2020];
			q100_price_opex <- q100_concept_prices_emissions [q100_price_opex_column(), current_date.year - 2020];
			power_emissions <- energy_prices_emissions [12, current_date.year - 2020];
			q100_emissions <- q100_concept_prices_emissions [q100_emissions_column(), current_date.year - 2020];

			income_change_rate <- income_change_rate * agora_45 [11, current_date.year - 2020];
			power_consumption_change_rate <- power_consumption_change_rate * agora_45 [13, current_date.year - 2020];
			heat_consumption_new_EFH_change_rate <- heat_consumption_new_EFH_change_rate * agora_45 [14, current_date.year - 2020];
			heat_consumption_new_MFH_change_rate <- heat_consumption_new_MFH_change_rate * agora_45 [15, current_date.year - 2020];
			heat_consumption_exist_EFH_change_rate <- heat_consumption_exist_EFH_change_rate * agora_45 [16, current_date.year - 2020];
			heat_consumption_exist_MFH_change_rate <- heat_consumption_exist_MFH_change_rate * agora_45 [17, current_date.year - 2020];

		}

	}

	reflex calculate_modernization_status{
		if (current_date.month = 12) and (current_date.day = 31) {
			modernization_rate <- refurbished_buildings_year / unrefurbished_buildings_year;
		}
	}

	reflex reset_modernization_status{
		if (current_date.month = 1) and (current_date.day = 1) {
			refurbished_buildings_year <- 0;
			unrefurbished_buildings_year <- length(building where (each.mod_status = "u"));
		}
	}


	reflex step_households {
		list<households> household_list <- (agents of_generic_species households);
//		ask household_list {
//			do communicate_daily;
//			do communicate_weekly;
//			do communicate_occasional;
//		}
		if (current_date.day = 1) {
			ask household_list {
				do calculate_c;
			}
		}
		do update_max_values;
		if (current_date.day = 1) {
			ask household_list {
				// do decision_making;
				do consume_energy;
			}
		}
	}
}


species technical_data_calculator {
	float emissions_neighborhood_heat;
	float emissions_neighborhood_power;
	float emissions_neighborhood_total;
	float emissions_neighborhood_accu;
	float emissions_household_average;
	float emissions_household_average_accu;
	int month_counter <- 1;

	reflex monthly_updates_technical_data {
		if (current_date.day = 2) {
			list<households> household_list <- agents of_generic_species households;
			self.emissions_neighborhood_heat <- sum_of(household_list, each.my_heat_emissions);
			self.emissions_neighborhood_power <- sum_of(household_list, each.my_power_emissions);
			self.emissions_neighborhood_total <- self.emissions_neighborhood_heat + self.emissions_neighborhood_power;
			self.emissions_neighborhood_accu <- self.emissions_neighborhood_accu + self.emissions_neighborhood_total;
			self.emissions_household_average <- self.emissions_neighborhood_total / nb_units;
			self.emissions_household_average_accu <- self.emissions_household_average_accu + self.emissions_household_average;
			if cycle > 10 {
				self.month_counter <- self.month_counter + 1;

			}
		}
	}
}

species building {
	string type;
	int units;
	int tenants <- 0;
	bool vacant <- true;
	string street;
	bool built <- true;
	string mod_status; //modernization-status
	date mod_date;
	int net_floor_area;
	float spec_heat_consumption;
	float spec_power_consumption;
	string energy_source;
	int connection_year;
	rgb color <- #gray;
	geometry line;
	string id;
	bool change_tenants;


	int invest_counter;

	action invoke_investment { // Gets called when the tenants decide to invest in a refurbishment of the house. The invest_counter is set depending on the selected payment scenario.
		if self.mod_status = "s" {}
		else {
			self.mod_status <- "s";
			self.mod_date <- current_date;
			self.energy_source <- "q100";
			if q100_price_capex_scenario = "1 payment" {
				self.invest_counter <- 1;

			}
			else if q100_price_capex_scenario = "2 payments" {
				self.invest_counter <- 2;

			}
			else if q100_price_capex_scenario = "5 payments" {
				self.invest_counter <- 5;

			}
		}
	}



	bool qscope_interchange_flag <- false;
	float building_emissions;
	float building_expenses_heat;
	float building_expenses_power;
	float building_household_emissions;
	float building_household_expenses_heat;
	float building_household_expenses_power;



	action add_tenant {
		self.tenants <- self.tenants + 1;
		if self.tenants = self.units {
			self.vacant <- false;
		}

		return any_location_in(self);
	}
	action remove_tenant {
		self.tenants <- self.tenants - 1;
		self.vacant <- true;
		do modernize;
	}

	action modernize {
		if (self.type = "EFH") and (self.mod_status = "u") {
			self.mod_status <- "s";
			self.energy_source <- "q100";
			refurbished_buildings_year <- refurbished_buildings_year + 1;
			self.spec_heat_consumption <- self.spec_heat_consumption * (energy_saving_rate);
		}
	}


	reflex investment_costs { // When self.invest_counter is set to a value > 0, the tenants of the building will be charged with the costs of the home refurbishment.
		if self.invest_counter > 0 and current_date.month = mod_date.month and current_date.day = mod_date.day {
			ask self.get_tenants() {
				if self.ownership = "owner" {
					self.budget <- self.budget - q100_price_capex;
				}
			}
			self.invest_counter <- self.invest_counter - 1;
		}
	}

	reflex connect_q100 {
		if current_date.year = connection_year {
			self.energy_source <- "q100";
		}
	}


	list get_neighboring_households { // returns a list of all households living in the n closest buildings, where n is defined by the parameter 'global_neighboring_distance'.
		list neighbors;
		ask closest_to(building, self, global_neighboring_distance) {
			neighbors <- self.get_tenants() + neighbors;
		}
		return neighbors;
	}

	list<households> get_tenants { // returns a list of all households that are living in the building.
		return inside(agents of_generic_species(households), self);
	}




	aspect base {
		if built {
			draw shape color: color;

		}

	}
	aspect threedim {
		float height <- (floor(self.units / 10) + 1) * 10;

		if self.type = "NWG" {
			height <- 20.0;
		}
		if built {
			draw shape color: color depth: height;
		}
	}

	reflex monthly_updates_emissions { //to validate! TODO
		if (current_date.day = 2) {
			building_emissions <- 0.0;
			ask self.get_tenants() {
				house.building_emissions <- (house.building_emissions + self.my_energy_emissions);
			}
			if building_emissions > 0 {
				building_household_emissions <- building_emissions / units;	
			}
		}
	}

	reflex monthly_updates_expenses { //to validate! TODO
		if (current_date.day = 2) {
			building_expenses_heat <- 0.0;
			ask self.get_tenants() {
				house.building_expenses_heat <- house.building_expenses_heat + self.my_heat_expenses;
			}
			if building_expenses_heat > 0 {
				building_household_expenses_heat <- building_expenses_heat / units;
			}
		}
		if (current_date.day = 2) {
			building_expenses_power <- 0.0;
			ask self.get_tenants() {
				house.building_expenses_power <- house.building_expenses_power + self.my_power_expenses;
			}
			if building_expenses_power > 0 {
				building_household_expenses_power <- building_expenses_power / units;
			}
		}
	}

}


species nahwaermenetz{

	rgb color <- #indianred;
	aspect base{
		draw shape color: color;
	}
}


species households {


	float A_k; // Climate-Energy-Environment Knowledge
	float A_e; // Climate-Energy-Environment Awareness
	float A_d; // Energy-Related-Decision Awareness
	float A; // ---Decision-Threshold---: Knowledge & Awareness
	float PN; // Personal Norms
	float SN; // Subjective Norms
	float N; // ---Decicision-Threshold---: Norms

	float B_i; // Perceived-Behavioral-Control Invest
	float B_c; // Perceived-Behavioral-Control Change
	float B_s; // Perceived-Behavioral-Control Switch
	float B_i_7; // Perceived-Behavioral-Control Invest divided by 7
	float B_c_7; // Perceived-Behavioral-Control Change divided by 7
	float B_s_7; // Perceived-Behavioral-Control Switch divided by 7

	float EEH; // Energy Efficient Habits TODO

	float U; // Utility value that is selected in decision phase
	float U_current;
	float U_i;
	float U_c;
	float U_s;


	int income; // households income/month
	float budget <- 0.0; // TODO every household starts with zero savings?
	string id_group; // identification which quartile within the income group the agent belongs to


	float c_current; // TODO composite goods
	float c_invest;
	float c_change;
	float c_switch;
	float e_current; // TODO total energy expenses a household has to pay for energy supply - heat & power
	float e_invest;
	float e_change;
	float e_switch;
	bool change <- false; // init value needs to be set for household with fitting settings TODO
	bool invest <- false;
	string power_supplier;
	float delta;



	float my_heat_consumption; // monthly heat consumption in kWh
	float my_power_consumption; // monthly power consumption in kWh
	float my_heat_expenses; // monthly expenses for heat
	float my_power_expenses; // monthly expsenses for power
	float my_heat_emissions; // monthly emissions of heat consumption
	float my_power_emissions; // monthly emissions of power consumption
	float my_energy_emissions; // monthly emissions of totalg energy consumption

	float cost_benefit_invest; //costs or benefits of the investment action (aktuelle nur bestehend aus Investitionskosten /CapEx


	int age; // random mean-age of households
	int length_of_residence <- 0; //years since the household moved in
	string ownership; // type of ownership status of households
	string employment; // employment status of households



	// defines network behavior of each agent in parent species by employment status
	int network_contacts_temporal_daily <- -99; // amount of agents a household has daily contact with - 30x / month
	int network_contacts_temporal_weekly; // amount of agents a household has weekly contact with - 4x / month
	int network_contacts_temporal_occasional; // amount of agents a household has occasional contact with - 1x / month
	int network_contacts_spatial_direct; // available amount of contacts within an households network - direct neighbors
	int network_contacts_spatial_street; // available amount of contacts within an households network - contacts in the same street
	int network_contacts_spatial_neighborhood; // available amount of contacts within an households network - contacts in the same neighborhood
	int network_contacts_spatial_beyond; // available amount of contacts within an households network - contacts beyond the system's environment TODO - not yet implemented - no influence beyond the system boundaries

	bool family; // represents young families - higher possibility of being part of a socialgroup
	bool network_socialgroup; // households are part of a social group - accelerates the networking behavior; e.g. football club

	building house;

	int my_floor_area;


	list<households> social_contacts_direct;
	list<households> social_contacts_street;
	list<households> social_contacts_neighborhood;
	list<households> social_contacts;




	action find_house {
		self.house <- any (building where ((each.vacant) and (each.type != "NWG")));
		self.location <- self.house.add_tenant();
		self.change <- self.house.change_tenants;

	}

	action get_social_contacts {
		social_contacts_direct <- self.network_contacts_spatial_direct among (self.house.get_neighboring_households() + self.house.get_tenants() - self);
		social_contacts_street <- self.network_contacts_spatial_street among agents of_generic_species households where(each.house.street = self.house.street);
		social_contacts_neighborhood <- self.network_contacts_spatial_neighborhood among agents of_generic_species households where(each.house.street != self.house.street);
		social_contacts <- remove_duplicates(social_contacts_direct + social_contacts_street + social_contacts_neighborhood);
	}

	action update_social_contacts(agent old_contact) { //removes the 'old_contact' from the households list of contacts and adds a new random contact.

		if (old_contact in self.social_contacts_direct) {
			remove old_contact from: self.social_contacts_direct;
			social_contacts_direct <- social_contacts_direct + (1 among ((agents of_generic_species households) at_distance(global_neighboring_distance)));
		}
		if (old_contact in self.social_contacts_street) {
			remove old_contact from: self.social_contacts_street;
			social_contacts_street <- social_contacts_street + (1 among agents of_generic_species households where(each.employment = self.employment));
		}
		if (old_contact in self.social_contacts_neighborhood) {
			remove old_contact from: self.social_contacts_neighborhood;
			social_contacts_neighborhood <- social_contacts_neighborhood + (1 among agents of_generic_species households where(each.employment = self.employment));
		}
		let new_social_contacts <- remove_duplicates(social_contacts_direct + social_contacts_street + social_contacts_neighborhood) - social_contacts;
		social_contacts <- remove_duplicates(social_contacts_direct + social_contacts_street + social_contacts_neighborhood);
		loop node over: new_social_contacts {
			network <- network add_edge(self::node);
		}
	}





	action communicate_daily {


		if network_contacts_temporal_daily > 0 {
			ask network_contacts_temporal_daily among social_contacts {
        		let current_edge <- edge_between(network, self::myself);
        		let flag <- false;
        		if communication_memory {
        			if weight_of(network, current_edge) != cycle{
        				network <- with_weights(network, [current_edge::cycle]);
        				flag <- true;
        				create edge_vis number: 1 with: (my_edge:current_edge);
        			}
        		}
        		else {
        			flag <- true;
        			create edge_vis number: 1 with: (my_edge:current_edge);
        		}
        		if flag {
	        		if (self.A_e < mean([myself.A_e, self.A_e])) and self.A_e < 7 {
	        			self.A_e <- self.A_e + private_communication;
	        			if influence_type = "both_sides"{
	        				myself.A_e <- myself.A_e - private_communication;
	        			}
	        		}
	        		else if A_e > 0 {
	        			self.A_e <- self.A_e - private_communication;
	        			if influence_type = "both_sides"{
	        				myself.A_e <- myself.A_e + private_communication;
	        			}
	        		}


	        		if (self.A_d < mean([myself.A_d, self.A_d])) and self.A_d < 7 {
	        			self.A_d <- self.A_d + private_communication;

	        			if influence_type = "both_sides"{
	        				myself.A_d <- myself.A_d - private_communication;
	        			}
	        		}
	        		else if A_d > 0 {
	        			self.A_d <- self.A_d - private_communication;
	        			if influence_type = "both_sides"{
	        				myself.A_d <- myself.A_d + private_communication;
	        			}
	        		}

	        		if (self.SN < mean([myself.SN, self.SN])) and self.SN < 7 {
	        			self.SN <- self.SN + private_communication;
	        			if influence_type = "both_sides"{
	        				myself.SN <- myself.SN - private_communication;
	        			}
	        		}
	        		else if SN > 0 {
	        			self.SN <- self.SN - private_communication;
	        			if influence_type = "both_sides"{
	        				myself.SN <- myself.SN + private_communication;
	        			}
	        		}

        		}

        	}

        }
	}


	action communicate_weekly { // includes communication with social groups -> increasing factor

		if network_contacts_temporal_weekly > 0 {
			if cycle mod 7 = 0 {
				ask network_contacts_temporal_weekly among social_contacts {
        			let flag <- false;
        			let current_edge <- edge_between(network, self::myself);
	        		if communication_memory {
	        			if weight_of(network, current_edge) != cycle{
	        				network <- with_weights(network, [current_edge::cycle]);
	        				flag <- true;
	        				create edge_vis number: 1 with: (my_edge:current_edge);
	        			}
	        		}
        			else {
        				flag <- true;
        				create edge_vis number: 1 with: (my_edge:current_edge);
        			}
        			if flag {
	        			if self.network_socialgroup = true and ((self.A_e < mean([myself.A_e, self.A_e])) and self.A_e < 7) {
	        				self.A_e <- self.A_e + (private_communication * 2);
	        				if influence_type = "both_sides"{

	        					myself.A_e <- myself.A_e - (private_communication * 2);
	        				}

	        			}
	        			else if self.network_socialgroup = true and self.A_e > 0 {
	        				self.A_e <- self.A_e - (private_communication * 2);
	        				if influence_type = "both_sides"{

	        					myself.A_e <- myself.A_e + (private_communication * 2);
	        				}

	      			  	}
	      			  	else if self.network_socialgroup = false and ((self.A_e < mean([myself.A_e, self.A_e])) and self.A_e < 7) {
	        				self.A_e <- self.A_e + private_communication;
	        				if influence_type = "both_sides"{

	        					myself.A_e <- myself.A_e - private_communication;
	        				}

	        			}
	        			else if self.network_socialgroup = false and self.A_e > 0 {
	        				self.A_e <- self.A_e - private_communication;
	        				if influence_type = "both_sides"{
	        					myself.A_e <- myself.A_e + private_communication;
	        				}
	      			  	}



	        			if self.network_socialgroup = true and ((self.A_d < mean([myself.A_d, self.A_d])) and self.A_d < 7) {
	        				self.A_d <- self.A_d + (private_communication * 2);
	        				if influence_type = "both_sides"{
	        					myself.A_d <- myself.A_d - (private_communication * 2);
	        				}

	        			}
	        			else if self.network_socialgroup = true and self.A_d > 0 {
	        				self.A_d <- self.A_d - (private_communication * 2);
	        				if influence_type = "both_sides"{

	        					myself.A_d <- myself.A_d + (private_communication * 2);
	        				}

	      			  	}
	      			  	else if self.network_socialgroup = false and ((self.A_d < mean([myself.A_d, self.A_d])) and self.A_d < 7) {
	        				self.A_d <- self.A_d + private_communication;
	        				if influence_type = "both_sides"{

	        					myself.A_d <- myself.A_d - private_communication;
	        				}

	        			}
	        			else if self.network_socialgroup = false and self.A_d > 0 {
	        				self.A_d <- self.A_d - private_communication;
	        				if influence_type = "both_sides"{
	        					myself.A_d <- myself.A_d + private_communication;
	        				}
	      			  	}

	        			if (self.SN < mean([myself.SN, self.SN])) and self.SN < 7 {
	        				self.SN <- self.SN + private_communication;
	        				if influence_type = "both_sides"{
	        					myself.SN <- myself.SN - private_communication;
	        				}
	        			}
	        			else if SN > 0 {
	        				self.SN <- self.SN - private_communication;
	        				if influence_type = "both_sides"{
	        					myself.SN <- myself.SN + private_communication;
	        				}
	        			}

	        		}
        		}
        	}
        }
	}


	action communicate_occasional {
		if network_contacts_temporal_occasional > 0 {
			if (current_date.day = 1) {

				ask network_contacts_temporal_occasional among social_contacts {
       		 		let flag <- false;
       		 		let current_edge <- edge_between(network, self::myself);
	        		if communication_memory {
	        			if weight_of(network, current_edge) != cycle{
	        				network <- with_weights(network, [current_edge::cycle]);
	        				flag <- true;
	        				create edge_vis number: 1 with: (my_edge:current_edge);
	        			}
	        		}
	        		else {
	        			flag <- true;
	        			create edge_vis number: 1 with: (my_edge:current_edge);
	        		}
	        		if flag {
		        		if (self.A_e < mean([myself.A_e, self.A_e])) and self.A_e < 7 {
		        			self.A_e <- self.A_e + private_communication;
		        			if influence_type = "both_sides"{
		        				myself.A_e <- myself.A_e - private_communication;// validierung - wie kann hier ein nachvollziehbarer wert gewaehlt werden? Oder muss dies Teil der Untersuchtung sein? & wieso - unendlich?
		        			}
		        		}
		        		else if A_e > 0 {
		        			self.A_e <- self.A_e - private_communication;
		        			if influence_type = "both_sides"{
		        				myself.A_e <- myself.A_e + private_communication;
		        			}
		        		}


		        		if (self.A_d < mean([myself.A_d, self.A_d])) and self.A_d < 7 {
		        			self.A_d <- self.A_d + private_communication;

		        			if influence_type = "both_sides"{
		        				myself.A_d <- myself.A_d - private_communication;
		        			}
		        		}
		        		else if A_d > 0 {
		        			self.A_d <- self.A_d - private_communication;
		        			if influence_type = "both_sides"{
		        				myself.A_d <- myself.A_d + private_communication;
		        			}
		        		}

		        		if (self.SN < mean([myself.SN, self.SN])) and self.SN < 7 {
		        			self.SN <- self.SN + private_communication;
		        			if influence_type = "both_sides"{
		        				myself.SN <- myself.SN - private_communication;
		        			}
		        		}
		        		else if SN > 0 {
		        			self.SN <- self.SN - private_communication;
		        			if influence_type = "both_sides"{
		        				myself.SN <- myself.SN + private_communication;
		        			}
		        		}

	        		}

        		}
        	}
        }
	}




	action calculate_c { // calculation of c is used for decision making

		do calculate_hypo_e;

		c_current <- income - (e_current);
		c_invest <- income - (e_invest + q100_price_capex); // langfristige Vorteile des Investments müssen evtl noch bedacht werden??
		c_change <- income - (e_change);
		c_switch <- income - (e_switch);
	}


	action decision_making {


		do update_decision_thresholds;

		do calculate_utility;


		U <- max ([U_current, U_i, U_c, U_s]);

		if (U = U_i) and (q100_price_capex <= budget) {
			invest <- true;
			int no_owners_invest <- length(self.house.get_tenants() where (each.invest = true));
			int no_total_owner <- length(self.house.get_tenants());
			if (ownership = "owner") and (self.house.type = "EFH") {
				ask self.house {
					do invoke_investment;
				}
				do decision_feedback_attitude;
				do decision_feedback_B;
			}
			else if (ownership = "tenant") and (self.house.type = "EFH") { // the CapEx will not appear in this situation - landlord is outside of system boundaries
				if (flip (landlord_prop)) {
					ask self.house {
						do invoke_investment;
					}
					do decision_feedback_attitude;
					do decision_feedback_B;
				}
				else {
					invest <- false;
				}
			}

			else if (ownership = "owner") and (self.house.type = "MFH") and (MFH_connection_threshold <= (no_owners_invest / no_total_owner)) {
				ask self.house {
					do invoke_investment;
				}
				do decision_feedback_attitude;
				do decision_feedback_B;
			}

			else if (ownership = "tenant") and (self.house.type = "MFH") {
				if (flip (landlord_prop)) {
					do decision_feedback_attitude;
					do decision_feedback_B;
					if (MFH_connection_threshold <= (no_owners_invest / no_total_owner)) {
						ask self.house {
							do invoke_investment;
						}
					}
				}
				else {
					invest <- false;
				}
			}
		}

		else if (U = U_c) and (EEH > change_threshold) {
			change <- true;
			do decision_feedback_attitude;
			do decision_feedback_B;
		}

		else if U = U_s {
			if power_supplier = "conventional" {
				power_supplier <- "mixed";
			}
			else if power_supplier = "mixed" {
				power_supplier <- "green";
			}
			do decision_feedback_attitude;
			do decision_feedback_B;
		}
	}

	action decision_feedback_attitude { // decision feedback calculation for attitude values

		A_k <- A_k * feedback_factor;
		A_e <- A_e * feedback_factor;
		A_d <- A_d * feedback_factor;

	}

	action decision_feedback_B { // decision feedback calculation for other values of perceived behavioral control

		if B_feedback {

			if U = U_i {
				if !change {
					B_c <- B_c * feedback_factor;
				}
				if power_supplier != "green" {
					B_s <- B_s * feedback_factor;
				}
			}

			if U = U_c {
				if !invest {
					B_i <- B_i * feedback_factor;
				}
				if power_supplier != "green" {
					B_s <- B_s * feedback_factor;
				}
			}

			if U = U_s {
				if !invest {
					B_i <- B_i * feedback_factor;
				}
				if !change {
					B_c <- B_c * feedback_factor;
				}
			}
		}
	}


	action consume_energy { // calculation of energy consumption of a household // has to be calculated after c, to represent t-1 // grafische Darstellung des Endenergieverbrauchs von Haushalten im Vergleich mit Agora-Wert?

		do calculate_consumption;
		do calculate_emissions;
		do calculate_heat_expenses;
		do calculate_power_expenses;

		e_current <- my_heat_expenses + my_power_expenses;

	}


	action update_decision_thresholds {
		/* calculate household's current
		Attitude (0 <= KA <= 1),
		Norms (0 <= N <= 1) and
		Perceived behavioral control (0 <= PBC <= 1) */
		A <- mean(A_k, A_e, A_d) / 7;
		N <- mean(SN) / 7;
		B_i_7 <- mean(B_i) / 7;
		B_c_7 <- mean(B_c) / 7;
		B_s_7 <- mean(B_s) / 7;
	}

	action calculate_hypo_e {
		float hypo_q100_carbon_exp <- my_heat_consumption * q100_emissions * carbon_price * int(carbon_price_on_off);
		e_invest <- (my_heat_consumption * q100_price_opex / 100) + hypo_q100_carbon_exp + my_power_expenses;
		e_change <- my_heat_expenses * change_factor + my_power_expenses * change_factor;
		if power_supplier = "mixed" {
			e_switch <- my_power_consumption * (power_price + 10) / 100 + my_heat_expenses;
		}
	}

	action calculate_utility {
		U_current <- alpha * e_current / e_current_max + (1 - alpha) * c_current / c_current_max + (A + N + int(B_do_nothing)); // urspruenglich Utility Vergleich U(t-1) mit U(t), allerdings wirft das Frage auf, was U(t0) ist - daher zunächst jeweils Berechnung einer "nichts-tun-Utility" -> vgl Niamir TODO

		if (invest = true) or (self.house.energy_source = "q100") {
			U_i <- 0.0;
		}
		else {
			if delta_on_off {
				self.delta <- self.B_i / 7 * int(self.ownership = "owner");
				U_i <- (1 - self.delta) * (alpha * e_invest / e_invest_max + (1 - alpha) * c_invest / c_invest_max) + self.delta *(A + N + B_i_7);
			}
			else {
				U_i <- alpha * e_invest / e_invest_max + (1 - alpha) * c_invest / c_invest_max + (A + N + B_i_7);
			}

		}

		if change = true {
			U_c <- 0.0;
		}
		else {
			if delta_on_off {
				self.delta <- self.B_c / 7;
				U_c <- (1 + self.delta) * (alpha * e_change / e_change_max + (1 - alpha) * c_change / c_change_max) + self.delta * (A + N + B_c_7);
			}
			else {
				U_c <- alpha * e_change / e_change_max + (1 - alpha) * c_change / c_change_max + (A + N + B_c_7);
			}

		}

		if power_supplier = "green" {
			U_s <- 0.0;
		}
		else {
			if delta_on_off {
				self.delta <- self.B_s / 7;
				U_s <- (1 - self.delta) * (alpha * e_switch / e_switch_max + (1 - alpha) * c_switch / c_switch_max) + self.delta * (A + N + B_s_7);
			}
			else {
				U_s <- alpha * e_switch / e_switch_max + (1 - alpha) * c_switch / c_switch_max + (A + N + B_s_7);
			}
		}
	}



	action calculate_consumption { // consumption divided by building type

		if (self.house.type = "EFH") and (self.house.mod_status = "u") {
			my_heat_consumption <- my_floor_area * self.house.spec_heat_consumption * heat_consumption_exist_EFH_change_rate / 12;
		}
		else if (self.house.type = "EFH") and (self.house.mod_status = "s") {
			my_heat_consumption <- my_floor_area * self.house.spec_heat_consumption * heat_consumption_new_EFH_change_rate / 12;
		}
		else if (self.house.type = "MFH") and (self.house.mod_status = "u") {
			my_heat_consumption <- my_floor_area * self.house.spec_heat_consumption * heat_consumption_exist_MFH_change_rate / 12;
		}
		else if (self.house.type = "EFH") and (self.house.mod_status = "s") {
			my_heat_consumption <- my_floor_area * self.house.spec_heat_consumption * heat_consumption_new_MFH_change_rate / 12;
		}
		my_power_consumption <- my_floor_area * self.house.spec_power_consumption * power_consumption_change_rate / 12; // tatsaechlich kwh/qm spez stromverbrauch?

		// implementation of "change" factor on energy consumption
		if (change = true) {
			my_heat_consumption <- my_heat_consumption * change_factor;
			my_power_consumption <- my_power_consumption * change_factor;
		}
	}

	action calculate_heat_expenses {
		if (self.house.energy_source = "Gas") {
			my_heat_expenses <- my_heat_consumption * gas_price / 100;
		}
		else if (self.house.energy_source = "Öl") {
			my_heat_expenses <- my_heat_consumption * oil_price / 100;
		}
		else if (self.house.energy_source = "q100") { // TODO !! neben q100 sind im Kataster die Werte "nil" & "strom"; wie damit umgehen?
			my_heat_expenses <- my_heat_consumption * q100_price_opex / 100;
		}
		if carbon_price_on_off {
			my_heat_expenses <- my_heat_expenses + my_heat_emissions * carbon_price;
		}
	}

	action calculate_power_expenses {
		if (power_supplier = "green") {
			my_power_expenses <- my_power_consumption * (power_price + 10) / 100; // es stellt sich die Frage, ob Ökostrom immer teurer bleibt; bzw. es ein "höherklassiges" Angebot geben wird;; ggf Szenario einrichten mit 30 % und 10 ct
		}
		else {
			my_power_expenses <- my_power_consumption * power_price / 100;
		}
		if carbon_price_on_off {
			my_power_expenses <- my_power_expenses + my_power_emissions * carbon_price;
		}
	}

	action calculate_emissions { // emissions in g of CO2 eq
		if (self.house.energy_source = "Gas") {
			my_heat_emissions <- my_heat_consumption * gas_emissions;
		}
		else if (self.house.energy_source = "Öl") {
			my_heat_emissions <- my_heat_consumption * oil_emissions;
		}
		else if (self.house.energy_source = "q100") { // TODO !! neben q100 sind im Kataster die Werte "nil" & "strom"; wie damit umgehen?
			my_heat_emissions <- my_heat_consumption * q100_emissions;
		}


		if (power_supplier = "green") {

			my_power_emissions <- 0.0; // Emissionen tatsaechlich als 0 annehmen?

		}
		else if (power_supplier = "mixed") {
			my_power_emissions <- my_power_consumption * power_emissions * 0.5;
		}
		else if (power_supplier = "conventional") {
			my_power_emissions <- my_power_consumption * power_emissions;
		}

		my_energy_emissions <- my_heat_emissions + my_power_emissions;
	}




	reflex calculate_energy_budget { // households save budget from the difference between energy expenses and available budget
		int i <- index_of(collect(income_distribution_germany, (self.income <= each)), true); // Calculates income decile of the current household.
		self.budget <- self.budget + self.income * savings_rates[i]; // Adds monthly savings to the budget.
				
			
	}


//	reflex move_out {
//		if (current_date.month = 12) and (current_date.day = 15) {
//
//			//initiation of moving-out-procedure by age
//			age <- age + 1;
//			length_of_residence <- length_of_residence + 1;
//			let current_agent <- self;
//			if age >= 100 {
//				ask neighbors_of(network, self) {
//					do update_social_contacts(current_agent);
//				}
//				remove self from: network;
//				ask self.house{
//					do remove_tenant;
//				}
//				do die;
//			}
//
//			//initiation of moving-out-procedure by average probability
//			int current_age_group <- int(floor(age / 20)) - 1; // age-groups are represented with integers. Each group spans 20 years with 0 => [20,39], 1 => [40,59] ...
//			float moving_prob  <- 1 / average_lor_inclusive[1, current_age_group];
//			if flip(moving_prob) {
//				households my_temporary_network <- households(neighbors_of(network, self));
//				if my_temporary_network != nil {
//					ask my_temporary_network {
//						do update_social_contacts(current_agent);
//					}
//				}
//				remove self from: network;
//				ask self.house {
//					do remove_tenant;
//				}
//				do die;
//
//			}
//
//		}
//
//	}

	reflex retire { //emp-status of the household moves to "pensioner" when they reach age 64.
		if (self.age >= 64) and (self.employment != "pensioner") {
			self.employment <- "pensioner";
		}
	}



	aspect by_energy {
		map<string,rgb> power_colors <- ["conventional"::#black, "mixed"::#lightseagreen, "green"::#green];
		draw circle(2) color: power_colors[power_supplier];
		if (self.house.energy_source = "q100") or (self.house.mod_status = "s") { // sanierte gebaeude ebenfalls anschluss an q100? -> Stand Basismodell Ja TODO
		// wenn invest entscheidung getroffen wird, nimmt diese einfluss auf parameter "energy_source" einfluss //  Unterscheidung Mieter/Vermieter
			nahwaermenetz netz <- closest_to(nahwaermenetz, self);
			list conn <- closest_points_with(netz, self);
			draw polyline(conn) color: #red width: 2;
		}

	}


}


species households_500_1000 parent: households {

	int income <- rnd(500, 1000);

}

species households_1000_1500 parent: households {

	int income <- rnd(1000, 1500);

}

species households_1500_2000 parent: households {

	int income <- rnd(1500, 2000);

}

species households_2000_3000 parent: households {

	int income <- rnd(2000, 3000);

}

species households_3000_4000 parent: households {

	int income <- rnd(3000, 4000);

}

species households_4000etc parent: households {

	int income <- rnd(4000, 10000); // max income / month = 10.000

}

species edge_vis {
	pair my_edge;
	int age <- 0;

	reflex disappear {
		if self.age = 0 {
			self.age <- self.age + 1;
		}
		else {
			do die;
		}
	}

	aspect base {
		draw geometry(my_edge) color: #lightgreen;
	}
}


	// grid vegetation_cell width: 50 height: 50 neighbors: 4 {} -> Bei derzeitiger Vorstellung wird kein grid benoetigt; ggf mit qScope-Tisch-dev abgleichen

experiment agent_decision_making type: gui{


 	parameter "Influence of private communication" var: private_communication min: 0.0 max: 1.0 category: "Decision making";
 	parameter "Energy Efficient Habits Threshold for Change Decision" var: change_threshold category: "Decision making";
 	parameter "Chance to convince landlord for connection of Q100 heat network" var: landlord_prop category: "Decision making";
 	parameter "Use delta in utility calculation" var: delta_on_off category: "Decision making";
 	parameter "Include PBC-Value in the current utility" var: B_do_nothing category: "Decision making";
 	parameter "Share of MFH units that is needed to connect to Q100 heat_network" var: MFH_connection_threshold category: "Decision making";
 	parameter "Influence of feedback of decision making on own personal values" var: feedback_factor category: "Decision making";
 	parameter "Feedback of decision on perceived behavioral control" var: B_feedback category: "Decision making";

 	parameter "Neighboring distance" var: global_neighboring_distance min: 0 max: 5 category: "Communication";
	parameter "Influence-Type" var: influence_type among: ["one-side", "both_sides"] category: "Communication";
	parameter "Memory" var: communication_memory category: "Communication";
	parameter "New Buildings" var: new_buildings_parameter <- "none" among: ["at_once", "continuously", "linear2030", "none"] category: "Buildings";
	parameter "Random Order of new Buildings" var: new_buildings_order_random category: "Buildings";
 	parameter "Modernization Energy Saving" var: energy_saving_rate category: "Buildings" min: 0.0 max: 1.0 step: 0.05;
 	parameter "Shapefile for buildings:" var: shape_file_buildings category: "GIS";
 	parameter "Building types source" var: attributes_source <- "Kataster_A" among: ["Kataster_A", "Kataster_T"] category: "GIS";
 	parameter "3D-View" var: view_toggle category: "GIS";
  	parameter "Alpha scenario" var: alpha_scenario <- "Static_mean" among: ["Static_mean", "Dynamic_moderate", "Dynamic_high", "Static_high"] category: "Technical data";
 	parameter "Carbon price scenario" var: carbon_price_scenario <- "B - Moderate" among: ["A - Conservative", "B - Moderate", "C1 - Progressive", "C2 - Progressive", "C3 - Progressive"] category: "Technical data";
 	parameter "Energy prices scenario" var: energy_price_scenario <- "Prices_2021" among: ["Prices_Project start", "Prices_2021", "Prices_2022 1st half"] category: "Technical data";
 	parameter "Q100 OpEx prices scenario" var: q100_price_opex_scenario <- "12 ct / kWh (static)" among: ["12 ct / kWh (static)", "9-15 ct / kWh (dynamic)"] category: "Technical data";
  	parameter "Q100 CapEx prices scenario" var: q100_price_capex_scenario <- "1 payment" among: ["1 payment", "2 payments", "5 payments"] category: "Technical data";

  	parameter "Q100 Emissions scenario" var: q100_emissions_scenario <- "Constant_Zero_emissions" among: ["Constant_50g_/_kWh", "Declining_Steps", "Declining_Linear", "Constant_Zero_emissions"] category: "Technical data";
  	parameter "Carbon price for households?" var: carbon_price_on_off <- false category: "Technical data";

  	parameter "Seed" var: seed <- seed category: "Simulation";
  	parameter "Keep seed" var: keep_seed category: "Simulation";
  	parameter "timestamp" var: timestamp <- "";
  	parameter "Model runtime" var: model_runtime_string among: ["2020-2030", "2020-2040", "2020-2045"] category: "Simulation";

  	font my_font <- font("Arial", 12, #bold);



//csv_export for frontend test

	reflex save_num_connections {
		float value <- length(building where ((each.mod_status = "s") and (each.built))) / length(building where (each.built)) * 100;
		string export_file <- (timestamp != "") ? "../data/outputs/output_" + timestamp + "/connections/connections_export.csv" : "../data/outputs/output/connections/connections_export.csv";
		save [cycle, current_date, value]
		to: export_file type: csv rewrite: false;
	}

// export energy costs:

	reflex save_energy_costs {
		if (current_date.month = 1) and (current_date.day = 1) {
				string export_file <- (timestamp = "") ? "../data/outputs/output/energy_prices/energy_prices_total.csv" : "../data/outputs/output_" + timestamp + "/energy_prices/energy_prices_total.csv";

			save [cycle, current_date, power_price, oil_price, gas_price, q100_price_opex] // TODO exportiert derzeit "nur" die Werte, welche an anderer Stelle importiert werden; koennte erweitert werden durch zB "monatliche Ausgaben eines Durchschnitts-Haushalts fuer Energie"
			to: export_file type: csv rewrite: false  header: true;
		}
	}
//csv_export for output test - line graph infoscreen /////////////////////////////// TODO Thema Datenschutz -> eigentlich nur durchschnittswerte exportieren; flag-export wofuer noetig?

	reflex save_results_co2_graph {
		string export_file;
		if current_date.day = 3 {

			ask building where (each.qscope_interchange_flag = true) {
				export_file <- (timestamp = "") ? "../data/outputs/output/emissions/CO2_emissions_" + id + ".csv" : "../data/outputs/output_" + timestamp + "/emissions/CO2_emissions_" + id + ".csv";
				save [cycle, current_date, id, building_household_emissions]
				to: export_file type: csv rewrite: false header: true;
			}

			ask technical_data_calculator {
				export_file <- (timestamp = "") ? "../data/outputs/output/emissions/CO2_emissions_neighborhood.csv" : "../data/outputs/output_" + timestamp + "/emissions/CO2_emissions_neighborhood.csv";

				save [cycle, current_date, emissions_neighborhood_total, emissions_household_average, emissions_neighborhood_accu, emissions_household_average_accu, modernization_rate]

				to: export_file type: csv rewrite: false header: true; // löschung der datei implementieren
			}
		}
	}

	reflex save_results_energy_prices_building {
		string export_file;
		if current_date.day = 3 {

			ask building where (each.qscope_interchange_flag = true) {
				export_file <- (timestamp = "") ? "../data/outputs/output/energy_prices/energy_prices_" + id + ".csv" : "../data/outputs/output_" + timestamp + "/energy_prices/energy_prices_" + id + ".csv";
				save [cycle, current_date, id, building_household_expenses_power, building_household_expenses_heat]
				to: export_file type: csv rewrite: false header: true;
			}
		}
	}


	//option 2

//		reflex save_csv {
//			save (agents of_generic_species households) to: "../output/households.csv" type: "csv" rewrite: false header: true;
//			save building to: "../output/buildings.csv" type: "csv" rewrite: false header: true;
//			//Examples of global variables.
//			float avg_CEEA <- sum_of(agents of_generic_species households, each.CEEA) / length(agents of_generic_species households);
//			int nb_employed <- length (agents of_generic_species households where (each.employment = "employed"));
//			save [cycle, avg_CEEA, nb_employed] to: "../output/globals.csv" type: "csv" rewrite: false header: true;
//
//	}



	output {
		//monitor monat value: ((technical_data_calculator[0].month_counter - 1) mod 12) ;


		layout #split;
		display neighborhood {


			image background_map;


			species edge_vis aspect: base;

			species building aspect: base;
			species nahwaermenetz aspect: base;

			species households_500_1000 aspect: by_energy;
			species households_1000_1500 aspect: by_energy;
			species households_1500_2000 aspect: by_energy;
			species households_2000_3000 aspect: by_energy;
			species households_3000_4000 aspect: by_energy;
			species households_4000etc aspect: by_energy;

			overlay position: { 5, 5 } size: { 140#px, 190#px } background: # black transparency: 0.5 border: #black rounded: true {
				draw "Date" at: {5#px, 5#px} anchor: #top_left color: #black font: my_font;
				draw string (current_date) at: {5#px, 17#px} anchor: #top_left color: #black font: my_font;
				draw "Transformation level" at: {5#px,38#px} anchor: #top_left color: #black font: my_font;
				int percentage <- int(length(building where (each.mod_status = "s")) / length(building) * 100);
				draw line([{5,5} + {0#px, 62#px}, {5,5}+{139#px, 62#px}]) color: #black;
				draw string ("" + percentage + " %") at: {5#px,50#px} anchor: #top_left color: #black font: my_font;
				draw square(10#px) at: { 10#px, 74#px } color: #blue border: #white ;
				draw string ("EFH") at: { 20#px, 74#px} color: #black font: my_font anchor: #left_center;
				draw square(10#px) at: { 10#px, 94#px } color: #lightblue border: #white ;
				draw string ("MFH") at: { 20#px, 94#px} color: #black font: my_font anchor: #left_center;
				draw square(10#px) at: { 10#px, 114#px } color: #gray border: #white ;
				draw string ("NWG") at: { 20#px, 114#px} color: #black font: my_font anchor: #left_center;
				map<string,rgb> power_colors <- ["conventional"::#black, "mixed"::#lightseagreen, "green"::#green];
				int i <- 1;
				draw line([{5,5} + {0#px, 124#px}, {5,5}+{139#px, 124#px}]) color: #black;
				loop powertype over: power_colors.keys {
					draw square(10#px) at: { 10#px, 114#px + (i * 20)#px } color: power_colors[powertype] border: #white ;
					draw string (powertype) at: { 20#px, 114#px + (i * 20)#px} color: #black font: my_font anchor: #left_center;
					i <- i + 1;
				}
			}


		}



//		display "households_income_bar" {
//			chart "households_income" type: histogram {
//				data "households_500-1000" value: length (households_500_1000) color:#darkblue;
//				data "households_1000-1500" value: length (households_1000_1500) color:#darkcyan;
//				data "households_1500-2000" value: length (households_1500_2000) color:#darkgoldenrod;
//				data "households_2000-3000" value: length (households_2000_3000) color:#darkgray;
//				data "households_3000-4000" value: length (households_3000_4000) color:#darkgreen;
//				data "households_>4000" value: length (households_4000etc) color:#darkkhaki;
//				data "total" value: sum (length (households_500_1000), length (households_1000_1500),length (households_1500_2000), length (households_2000_3000), length (households_3000_4000), length (households_4000etc)) color:#darkmagenta;
//			}
//
//		}
//
		display "households_employment_pie" type: java2D {
			chart "households_employment" type: pie {
				data "student" value: length (agents of_generic_species households where (each.employment = "student")) color: #lightblue;
				data "employed" value: length (agents of_generic_species households where (each.employment = "employed")) color: #lightcoral;
				data "self_employed" value: length (agents of_generic_species households where (each.employment = "self_employed")) color: #lightcyan;
				data "unemployed" value: length (agents of_generic_species households where (each.employment = "unemployed")) color: #lightgoldenrodyellow;
				data "pensioner" value: length (agents of_generic_species households where (each.employment = "pensioner")) color: #lightgray;
			}
		}

		display "Charts" {
			chart "Average of decision-variables" type: series {
				data "CEEA" value: sum_of(agents of_generic_species households, each.A_e) / length(agents of_generic_species households);
				data "EDA" value: sum_of(agents of_generic_species households, each.A_d) / length(agents of_generic_species households);

				data "SN" value: sum_of(agents of_generic_species households, each.SN) / length(agents of_generic_species households);
			}
		}

		display "Modernization" {
			chart "Rate of Modernization"
			type: series
			//y_range: {0,0.03}
			style: line
			x_label: "Year"
			x_serie: [current_date.year]
			x_serie_labels: string(current_date.year)
			y_label: "Rate of Modernization"
			{
				data "Rate of Modernization"
				value: modernization_rate
				color: #gold;
				data "1% Refurbishment Rate"
				value: 0.01
				marker: false
				thickness: 2.0
				color: #red;
				data "1.5% Refurbishment Rate"
				value: 0.015
				marker: false
				thickness: 2.0
				color: #darkblue;
				data "2% Refurbishment Rate"
				value: 0.02
				marker: false
				thickness: 2.0
				color: #darkgreen;
			}
		}


		display "Monthly Emissions"{ // TODO
			chart "Emissions per month within the neighborhood"
			type: series
			x_label: "Month"
			y_label: "g of CO2 eq"
			x_serie: [technical_data_calculator[0].month_counter]
			x_serie_labels: months[((technical_data_calculator[0].month_counter - 1) mod 12)]
			{
				data "Total energy emissions of neighborhood per month"
				value: technical_data_calculator[0].emissions_neighborhood_total;

				data "Total heat emissions of neighborhood per month"
				value: technical_data_calculator[0].emissions_neighborhood_heat;

				data "Total power emissions of neighborhood per month"
				value: technical_data_calculator[0].emissions_neighborhood_power;
				//data "Average energy emissions of a household per month" value: technical_data_calculator[0].emissions_household_average;
			}
		}

		display "Emissions cumulative" { // TODO
			chart "Cumulative emissions of the neighborhood"
			type: series
			x_label: "Month"
			y_label: "g of CO2 eq"
			x_serie: [technical_data_calculator[0].month_counter]
			x_serie_labels: months[((technical_data_calculator[0].month_counter - 1) mod 12)] {
				data "Total energy emissions of neighborhood per year"
				value: technical_data_calculator[0].emissions_neighborhood_accu
				;
			}
		}
		display "Average Emissions Cumulative" { // TODO
			chart "Average cumulative emissions of the neighborhood"
			type: series
			x_label: "Month"
			y_label: "g of CO2 eq"
			x_serie: [technical_data_calculator[0].month_counter]
			x_serie_labels: months[((technical_data_calculator[0].month_counter - 1) mod 12)] {
				data "Accumulated Average energy emissions of a household"
				value: technical_data_calculator[0].emissions_household_average_accu
				;

			}
		}

		display "Average Emissions"{
			chart "Average Emissions per Household"
			type: series
			x_serie: [technical_data_calculator[0].month_counter]
			x_label: "Month"
			y_label: "g of CO2 eq"
			x_serie_labels: months[((technical_data_calculator[0].month_counter - 1) mod 12)]
			{
				data "Average energy emissions of a household"
				value: technical_data_calculator[0].emissions_household_average;
			}




		}
	}
}

experiment agent_decision_making_3d type: gui{


 	parameter "Influence of private communication" var: private_communication min: 0.0 max: 1.0 category: "Decision making";
 	parameter "Energy Efficient Habits Threshold for Change Decision" var: change_threshold category: "Decision making";
 	parameter "Chance to convince landlord for connection of Q100 heat network" var: landlord_prop category: "Decision making";
 	parameter "Use delta in utility calculation" var: delta_on_off category: "Decision making";
 	parameter "Include PBC-Value in the current utility" var: B_do_nothing category: "Decision making";
 	parameter "Share of MFH units that is needed to connect to Q100 heat_network" var: MFH_connection_threshold category: "Decision making";
 	parameter "Influence of feedback of decision making on own personal values" var: feedback_factor category: "Decision making";
 	parameter "Feedback of decision on perceived behavioral control" var: B_feedback category: "Decision making";

 	parameter "Neighboring distance" var: global_neighboring_distance min: 0 max: 5 category: "Communication";
	parameter "Influence-Type" var: influence_type <- "one-side" among: ["one-side", "both_sides"] category: "Communication";
	parameter "Memory" var: communication_memory <- true among: [true, false] category: "Communication";
	parameter "New Buildings" var: new_buildings_parameter <- "none" among: ["at_once", "continuously", "linear2030", "none"] category: "Buildings";
	parameter "Random Order of new Buildings" var: new_buildings_order_random <- true category: "Buildings";
 	parameter "Modernization Energy Saving" var: energy_saving_rate category: "Buildings" min: 0.0 max: 1.0 step: 0.05;
 	parameter "Shapefile for buildings:" var: shape_file_buildings category: "GIS";
 	parameter "Building types source" var: attributes_source <- "Kataster_A" among: ["Kataster_A", "Kataster_T"] category: "GIS";
 	parameter "3D-View" var: view_toggle category: "GIS";
  	parameter "Alpha scenario" var: alpha_scenario <- "Static_mean" among: ["Static_mean", "Dynamic_moderate", "Dynamic_high", "Static_high"] category: "Technical data";
 	parameter "Carbon price scenario" var: carbon_price_scenario <- "A - Conservative" among: ["A - Conservative", "B - Moderate", "C1 - Progressive", "C2 - Progressive", "C3 - Progressive"] category: "Technical data";
 	parameter "Energy prices scenario" var: energy_price_scenario <- "Prices_Project start" among: ["Prices_Project start", "Prices_2021", "Prices_2022 1st half"] category: "Technical data";
 	parameter "Q100 OpEx prices scenario" var: q100_price_opex_scenario <- "12 ct / kWh (static)" among: ["12 ct / kWh (static)", "9-15 ct / kWh (dynamic)"] category: "Technical data";
  	parameter "Q100 CapEx prices scenario" var: q100_price_capex_scenario <- "1 payment" among: ["1 payment", "2 payments", "5 payments"] category: "Technical data";
  	parameter "Q100 Emissions scenario" var: q100_emissions_scenario <- "Constant_50g / kWh" among: ["Constant_50g / kWh", "Declining_Steps", "Declining_Linear", "Constant_ Zero emissions"] category: "Technical data";

  	parameter "Carbon price for households?" var: carbon_price_on_off <- false category: "Technical data";

  	parameter "Model runtime" var: model_runtime_string among: ["2020-2030", "2020-2040", "2020-2045"] category: "Simulation";



  	font my_font <- font("Arial", 12, #bold);

	output {
//		monitor date value: current_date refresh: every(1#cycle);


		layout #split;

		display neighborhood3d type: opengl{

			image background_map;

			species households_500_1000 aspect: by_energy;
			species households_1000_1500 aspect: by_energy;
			species households_1500_2000 aspect: by_energy;
			species households_2000_3000 aspect: by_energy;
			species households_3000_4000 aspect: by_energy;
			species households_4000etc aspect: by_energy;

			species building aspect: threedim transparency: 0.8;
			species nahwaermenetz aspect: base;

			species edge_vis aspect: base;

			overlay position: { 5, 5 } size: { 140#px, 190#px } background: # black transparency: 0.5 border: #black rounded: true {
				draw string ("Date") at: {5#px, 5#px} anchor: #top_left color: #black font: my_font;
				draw string (current_date) at: {5#px, 17#px} anchor: #top_left color: #black font: my_font;
				draw string ("Transformation level") at: {5#px,38#px} anchor: #top_left color: #black font: my_font;
				int percentage <- int(length(building where (each.mod_status = "s")) / length(building) * 100);
				draw line([{5,5} + {0#px, 62#px}, {5,5}+{139#px, 62#px}]) color: #black;
				draw string ("" + percentage + " %") at: {5#px,50#px} anchor: #top_left color: #black font: my_font;
				draw square(10#px) at: { 10#px, 74#px } color: #blue border: #white ;
				draw string ("EFH") at: { 20#px, 74#px} color: #black font: my_font anchor: #left_center;
				draw square(10#px) at: { 10#px, 94#px } color: #lightblue border: #white ;
				draw string ("MFH") at: { 20#px, 94#px} color: #black font: my_font anchor: #left_center;
				draw square(10#px) at: { 10#px, 114#px } color: #gray border: #white ;
				draw string ("NWG") at: { 20#px, 114#px} color: #black font: my_font anchor: #left_center;
				map<string,rgb> power_colors <- ["conventional"::#black, "mixed"::#lightseagreen, "green"::#green];
				int i <- 1;
				draw line([{5,5} + {0#px, 124#px}, {5,5}+{139#px, 124#px}]) color: #black;
				loop powertype over: power_colors.keys {
					draw square(10#px) at: { 10#px, 114#px + (i * 20)#px } color: power_colors[powertype] border: #white ;
					draw string (powertype) at: { 20#px, 114#px + (i * 20)#px} color: #black font: my_font anchor: #left_center;
					i <- i + 1;
				}
			}
		}

//		display "households_income_bar" {
//			chart "households_income" type: histogram {
//				data "households_500-1000" value: length (households_500_1000) color:#darkblue;
//				data "households_1000-1500" value: length (households_1000_1500) color:#darkcyan;
//				data "households_1500-2000" value: length (households_1500_2000) color:#darkgoldenrod;
//				data "households_2000-3000" value: length (households_2000_3000) color:#darkgray;
//				data "households_3000-4000" value: length (households_3000_4000) color:#darkgreen;
//				data "households_>4000" value: length (households_4000etc) color:#darkkhaki;
//				data "total" value: sum (length (households_500_1000), length (households_1000_1500),length (households_1500_2000), length (households_2000_3000), length (households_3000_4000), length (households_4000etc)) color:#darkmagenta;
//			}
//
//		}
//
		display "households_employment_pie" type: java2D {
			chart "households_employment" type: pie {
				data "student" value: length (agents of_generic_species households where (each.employment = "student")) color: #lightblue;
				data "employed" value: length (agents of_generic_species households where (each.employment = "employed")) color: #lightcoral;
				data "self_employed" value: length (agents of_generic_species households where (each.employment = "self_employed")) color: #lightcyan;
				data "unemployed" value: length (agents of_generic_species households where (each.employment = "unemployed")) color: #lightgoldenrodyellow;
				data "pensioner" value: length (agents of_generic_species households where (each.employment = "pensioner")) color: #lightgray;
			}
		}

		display "Charts" {
			chart "Average of decision-variables" type: series {
				data "CEEA" value: sum_of(agents of_generic_species households, each.A_e) / length(agents of_generic_species households);
				data "EDA" value: sum_of(agents of_generic_species households, each.A_d) / length(agents of_generic_species households);
				data "SN" value: sum_of(agents of_generic_species households, each.SN) / length(agents of_generic_species households);
			}
		}

		display "Modernization" {
			chart "Rate of Modernization" type: xy y_range: {0,0.03} style: line{
				data "Rate of Modernization" value: {current_date.year, modernization_rate};
				data "1% Refurbishment Rate" value: {current_date.year, 0.01};
				data "1.5% Refurbishment Rate" value: {current_date.year, 0.015};
				data "2% Refurbishment Rate" value: {current_date.year, 0.02};
			}
		}

		display "Monthly Emissions" refresh: (current_date.day = 1){ // TODO
			chart "Emissions per month within the neighborhood" type: series {
				data "Total energy emissions of neighborhood per year" value: technical_data_calculator[0].emissions_neighborhood_total;
				data "Total heat emissions of neighborhood per year" value: technical_data_calculator[0].emissions_neighborhood_heat;
				data "Total power emissions of neighborhood per year" value: technical_data_calculator[0].emissions_neighborhood_power;
				data "Average energy emissions of a household per year" value: technical_data_calculator[0].emissions_household_average;
			}
		}

		display "Emissions cumulative" { // TODO
			chart "Cumulative emissions of the neighborhood" type: series {

				data "Accumulated energy emissions of neighborhood per year" value: technical_data_calculator[0].emissions_neighborhood_accu;
				data "Average accumulated energy emissions of neighborhood per year" value: technical_data_calculator[0].emissions_household_average_accu;

			}
		}
	}
}

experiment debug type:gui {
	parameter "Influence of private communication" var: private_communication min: 0.0 max: 1.0 category: "Decision making";
 	parameter "Energy Efficient Habits Threshold for Change Decision" var: change_threshold category: "Decision making";
 	parameter "Chance to convince landlord for connection of Q100 heat network" var: landlord_prop category: "Decision making";
 	parameter "Neighboring distance" var: global_neighboring_distance min: 0 max: 5 category: "Communication";
	parameter "Influence-Type" var: influence_type <- "one-side" among: ["one-side", "both_sides"] category: "Communication";
	parameter "Memory" var: communication_memory <- true among: [true, false] category: "Communication";
	parameter "New Buildings" var: new_buildings_parameter <- "none" among: ["at_once", "continuously", "linear2030", "none"] category: "Buildings";
	parameter "Random Order of new Buildings" var: new_buildings_order_random <- true category: "Buildings";
 	parameter "Modernization Energy Saving" var: energy_saving_rate category: "Buildings" min: 0.0 max: 1.0 step: 0.05;
 	parameter "Shapefile for buildings:" var: shape_file_buildings category: "GIS";
 	parameter "Building types source" var: attributes_source <- "Kataster_A" among: ["Kataster_A", "Kataster_T"] category: "GIS";
 	parameter "3D-View" var: view_toggle category: "GIS";
  	parameter "Alpha scenario" var: alpha_scenario <- "Static_mean" among: ["Static_mean", "Dynamic_moderate", "Dynamic_high", "Static_high"] category: "Technical data";
 	parameter "Carbon price scenario" var: carbon_price_scenario <- "A - Conservative" among: ["A - Conservative", "B - Moderate", "C1 - Progressive", "C2 - Progressive", "C3 - Progressive"] category: "Technical data";
 	parameter "Energy prices scenario" var: energy_price_scenario <- "Prices_Project start" among: ["Prices_Project start", "Prices_2021", "Prices_2022 1st half"] category: "Technical data";
 	parameter "Q100 OpEx prices scenario" var: q100_price_opex_scenario <- "12 ct / kWh (static)" among: ["12 ct / kWh (static)", "9-15 ct / kWh (dynamic)"] category: "Technical data";
  	parameter "Q100 CapEx prices scenario" var: q100_price_capex_scenario <- "1 payment" among: ["1 payment", "2 payments", "5 payments"] category: "Technical data";
  	parameter "Q100 Emissions scenario" var: q100_emissions_scenario <- "Constant_50g / kWh" among: ["Constant_50g / kWh", "Declining_Steps", "Declining_Linear", "Constant_ Zero emissions"] category: "Technical data";
  	parameter "Carbon price for households?" var: carbon_price_on_off <- false category: "Technical data";
  	parameter "Seed" var: seed <- seed category: "Simulation";
  	parameter "Keep seed" var: keep_seed <- false category: "Simulation";
  	parameter "Model runtime" var: model_runtime_string among: ["2020-2030", "2020-2040", "2020-2045"] category: "Simulation";

}
