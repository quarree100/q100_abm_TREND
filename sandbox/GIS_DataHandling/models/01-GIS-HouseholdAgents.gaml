/**
* Name: GIS_Household_Agents
* Verteilung der Agenten in "freie" Wohnungen 
* Author: dunland
* 
* 1. erstellt building agents aus Anzahl WE (aus Katasterdaten)
* 2. via loop über buildings → erstelle households
* 3. lege locations übereinander
* 
* Display: zeige Anzahl enthaltener households an; je weniger gebäude, desto durchsichtiger
*/

model GIS_Household_Agents

global {
	file shape_file_buildings <- file("../includes/Shapefiles/bestandsgebaeude_export.shp"); // load shapefiles
	geometry shape <- envelope(shape_file_buildings);

	init {
		create building from: shape_file_buildings with: [nb_households::int(read("Kataster_W"))] {
			color <- rgb(250,125,50, nb_households/31); // use alpha channel according to num of households (with 31 households (max) = 1.0)

		}

		// create households from buildings:
		loop this_building over: building {
			create household number: this_building.nb_households {
				myBuilding <- this_building;
				location <- this_building.location;
			}

		}

	}

}

species building {
	int nb_households; // number of households
	list<household> households; // list of household agents
	rgb color <- #grey;

	aspect base {
		draw shape color: color;
		
		// display numbers of contained households at building's location:
		draw string(nb_households) color: #black at: location;
	}

}

species household {
	building myBuilding;
	rgb color <- #grey;

	aspect base {
		draw shape color: color;
	}

}

experiment GIS_Household_Agents type: gui {
/** Insert here the definition of the input and output of the model */
	output {
		display quartier {
			species building aspect: base;
			species household aspect: base;
		}

	}

}
