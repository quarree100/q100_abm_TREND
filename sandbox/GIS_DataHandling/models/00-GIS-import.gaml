/**
* Name: GIS_import
* Based on the internal skeleton template.
* Author: dunland
* Tags: QUARREE100
* 
* `includes` sollte zu QUARREE100-QGIS-Projektdaten verlinkt werden

Das Modell lädt Gebäudedaten aus dem Shapefile und erstellt Gebäude-Agenten auf dieser Grundlage. 
Metadaten werden ausgelesen und Gebäude entsprechend der Haustypen eingefärbt.
*/
model GIS_import

global {
// define shape file paths:
	file shape_file_buildings <- file("../includes/Shapefiles/bestandsgebaeude_export.shp"); // load shapefiles
	file shape_file_typologiezonen <- file("../includes/Shapefiles/Typologiezonen.shp");
	file nahwaerme <- file("../includes/Shapefiles/Nahwärmenetz.shp");

	geometry shape <- envelope(shape_file_typologiezonen);
	int global_neighboring_distance <- 20;
	
	list attributes_possible_sources <- ["Kataster_A", "Kataster_T"]; // create list from shapefile metadata
	string attributes_source <- attributes_possible_sources[1];

	init {
		create building from: shape_file_buildings with: [type:: string(read(attributes_source))] { // create agents according to shapefile metadata
			if type = "EFH" {
				color <- #blue;
			}

			else if type = "MFH" {
				color <- #orange;
			}

			else if type = "NWG" {
				color <- #red;
			}

			else if type = "DHH" {
				color <- #brown;
			}

			else if type = "E-MG" {
				color <- #yellow;
			}

			else if type = "M-MG" {
				color <- #purple;
			}

			else if type = "RH" {
				color <- #green;
			}

			else if type = "SON" {
				color <- #black;
			}

			else if type = "SOZ" {
				color <- #pink;
			}
			

		}

	create nahwaermenetz from: nahwaerme;
	}

}

species building {
	string type;
	rgb color <- #gray;
	geometry line;

	aspect base {
		draw shape color: color;
		ask building at_distance (global_neighboring_distance) {
			draw polyline([self.location, myself.location]) color: #black;
		}

	}

}

species nahwaermenetz{
	
	rgb color <- #gray;
	
	aspect base{
		draw shape color: color;
	}
}

experiment GIS_import type: gui {
	parameter "shapefile for buildings:" var: shape_file_buildings category: "GIS";
	parameter "neighboring at distance:" var: global_neighboring_distance min: 0 max: 200 category: "Controls";
	parameter "building types source" var: attributes_source among: attributes_possible_sources category: "GIS";
	output {
		display quartier {
			species building aspect: base;
			species nahwaermenetz aspect: base;
		}

	}

}