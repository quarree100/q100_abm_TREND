/**
* Name: CityScopeTest
* Modell zur Kommunikation zwischen CityScoPy (per LEGO-Grid) und GAMA. 
* Author: dunland
* Tags: cityscope, gama, API
* 
* ///////////////////////// USAGE: //////////////////////////////
* includes folder must contain linked folder to cspy/settings
* cspy will output grid data to api.json
* ///////////////////////////////////////////////////////////////
*
*/

model CityScopeTest

/* Insert your model definition here */
global {

	// Variables used to initialize the table's grid.
	float brickSize <- 21.3;
	//	point center <- {1007, 632};
	point center <- {0, 0};

	/////////// CITYMATRIX   //////////////	
	string DATA <- "../includes/settings/api.json";
	string SETTINGS <- "../includes/settings/cityscopy.json";
	map<string, unknown> gridData <- json_file(DATA).contents;
	map<string, unknown> gridSettings <- json_file(SETTINGS).contents;
	int ncols;
	int nrows;

	init {
		do grid_from_json();

		gridSettings <- json_file(SETTINGS).contents;
		nrows <- int(map(gridSettings["cityscopy"])["nrows"]);
		ncols <- int(map(gridSettings["cityscopy"])["ncols"]);
	}

	action grid_from_json {
	// empty agent lists:
		ask tile {
			do die;
		}

		// reinitialize data:
		gridData <- json_file(DATA).contents;
		
		list<map> grid_as_list_of_maps <- gridData["grid"];
		//		write grid_as_list_of_maps;
		brickSize <- 1.0;

				int count <- 0;
				loop i from: 0 to: ncols - 1 {
					loop j from: 0 to: nrows - 1 {
						create tile {
							id <- count;
							myCell <- lego_grid[count];
							location <- myCell.location;
							//					shape <- square(brickSize * 0.9) at_location location;
							type <- int(list(list(gridData["grid"])[count])[0]);
							rotation <- int(list(list(gridData["grid"])[count])[1]) * 90;						
							if type = 1 {
								color <- #brown;
							} else if type = 2 {
								color <- #purple;
							} else if type = 3 {
								color <- #green;
							} else if type = 4 {
								color <- #orange;
							}
						}
						count <- count + 1;
					} 
				}
	}

	reflex updateGrid when: ((cycle mod 1) = 0) {
		do grid_from_json();
	}

}

species tile {
	int id;
	int x;
	int y;
	rgb color <- #red;
	int rotation;
	lego_grid myCell;
	int type;

	aspect base {
		draw rectangle(2, 5) rotated_by -rotation color: rgb(color.red, color.green, color.blue, 75);
	}

}

grid lego_grid width: 11 height: 11 {
}

experiment cityscope_test type: gui {
	float minimum_cycle_duration <- 0.4;
	output {
		display main_display {
			grid lego_grid lines: #black;
			species tile aspect: base;
		}

	}

}