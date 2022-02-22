/**
* Name: NewModel04
* Test04 
* Author: lennartwinkeler
* Tags: ABM, Energy Transition, Participation, Behaviour change
*/

model NewModel04

global {
	
	float step <- 1 #day;
	date starting_date <- date("2020-01-01");
	
	//definition der geoJson (zuvor .shp) + geometrie:
	
	file geojson_kataster_bestand <- geojson_file("../includes/geojson/gebaeudeliste-bestand.geojson");
	file geojson_kataster_neubau <- geojson_file("../includes/geojson/gebaeudeliste-neubau.geojson");
	file geojson_envelope <- geojson_file ("../includes/geojson/envelope1.geojson");
	file geojson_strasse <- geojson_file("../includes/geojson/RK_Strassen.geojson"); 
	
	geometry shape <- envelope(geojson_envelope);
	
	int global_neighboring_distance <- 20;
	int nb_bewohnerinnen <- 500;
	//int nb_buildings_bestand_oel <- sum (building_bestand where energy_type = "Öl");
	 
	//Erstellen der Gebäudeagenten -> Bestand & Neubau
	init{ 
		create building_bestand from: geojson_kataster_bestand with: [nahwaerme::int(read("Nahwärme")), building_type::string(read("Kataster_Typ")), building_age::float(read("Kataster_Baujahr")), nb_households::int(read("Kataster_WE")), sanierung::string(read("Kataster_Sanierung SIZ [u/t/s]")), energy_type::string(read("Kataster_Energieträger")), nb_building_bewohnerinnen::int(read("Kataster_Einwohner")), building_altersschnitt::float(read("Kataster_Altersschnitt"))] {
			if energy_type = "Öl" {
				color <- #blue;
			}
			else if energy_type = "Gas" {
				color <- #black;
			}
			else if energy_type = "Strom" {
				color <- #green;
			}
			else {
				color <- #beige;
			}
		}
		create building_neubau from: geojson_kataster_neubau with: [nahwaerme::int(read("Nahwärme")), building_type::string(read("Kataster_Typ")), building_age::float(read("Kataster_Baujahr")), nb_households::int(read("Kataster_WE")), sanierung::string(read("Kataster_Sanierung SIZ [u/t/s]")), energy_type::string(read("Kataster_Energieträger")), nb_building_bewohnerinnen::int(read("Kataster_Einwohner")), building_altersschnitt::float(read("Kataster_Altersschnitt"))];
		create strasse from: geojson_strasse;
		
		create bewohnerinnen number: nb_bewohnerinnen {
			living_place <- one_of (building_bestand);
			location <- any_location_in (living_place); //wie lässt sich das begrenzen? Passendes Attribut ist Anzahl HH in gebaeudespezies
			energie_einstellung  <- living_place get ("energy_type");
			
			
		}
	}
}





species generic_building { //Erstellen der Parent-Klasse für Bestand und Neubau, also Häuser allgemein
	
	int nahwaerme;
	string building_type;
	float building_age; 
	int nb_households;
	string sanierung;
	string energy_type;
	int nb_building_bewohnerinnen;
	float building_altersschnitt;
	
	
}

species building_bestand parent: generic_building {
	
	
		
	rgb color <- #black;
	float height <- rnd(10#m, 20#m);
	list<building_bestand> neighbors <- building_bestand at_distance (global_neighboring_distance);
	
	
	aspect base {
		draw shape color: color border: #red depth: height;
			ask neighbors {
			draw polyline([self.location, myself.location]) color: rgb(200, 200, 200);	
		}
	}
	
}
	
species building_neubau parent: generic_building {
		
	rgb color <- #white;
	float height <- rnd(15#m, 20#m);
	
	aspect base {
		draw shape color: color border: #red depth: height;
	}

}

species strasse {
		
	rgb color <- #orange;
		
	aspect base {
		draw shape color: color;
	}

}


//BewohnerInnen ebenfalls aus Kataster heraus erstellen?
species bewohnerinnen {
	
	rgb color <- #yellow;
	aspect sphere3D {
		draw sphere (2) at: {location.x,location.y,location.z + 3} color:color;
		
	}
	
	building_bestand living_place;
	string energie_einstellung;
	
	bool einstellung_gruen <- false;
	list<bewohnerinnen> Einstellung <- bewohnerinnen where (each.einstellung_gruen = true);
	reflex mind_change when: energie_einstellung = "Strom" {
		einstellung_gruen <- true;
		}

}





experiment Q100geoJsonTest01 type: gui {
	float minimum_cycle_duration <- 2.0#minute;
	
	parameter "geoJson fuer Bestand:" var: geojson_kataster_bestand category: "GIS";
	parameter "geoJson fuer Neubau:" var: geojson_kataster_neubau category: "GIS";
	parameter "Anzahl BewohnerInnen:" var: nb_bewohnerinnen min: 1 max: 1000 category: "Menschen";
	parameter "Stärke der Vernetzung" var: global_neighboring_distance min: 1 max: 30 category: "Menschen";
	parameter "Datum" var: starting_date category: "Zeit";

	output {
		monitor "Tag" value: current_date.day;
		monitor "Monat" value: current_date.month;
		monitor "Jahr" value: current_date.year;
		//monitor "Gebäude: Blau, Schwarz, Grau, Beige" value: nb_buildings_bestand_oel;
		
		
	display quartier_display type: opengl
	/*Kamera-Spielerei 
	camera_pos:{200,1,0}
	camera_up_vector:{250,250,50}*/ 
	
	{    		
		image "../includes/pics/180111-QUARREE100-RK_modifiziert.png";
		species bewohnerinnen aspect: sphere3D;
		species building_bestand aspect: base transparency: 0.3;
		species building_neubau aspect: base transparency: 0.3;
		species strasse aspect: base;
			
		}
			
	}

}
