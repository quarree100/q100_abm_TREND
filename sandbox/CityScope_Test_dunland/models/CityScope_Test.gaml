/**
* Name: CityScopeTest
* Modell zur Kommunikation zwischen CityScoPy (per LEGO-Grid) und GAMA. 
* Author: dunland
* Tags: 
*/
model CityScopeTest

/* Insert your model definition here */
global {

// Variables used to initialize the table's grid.
	float brickSize <- 21.3;
	//	point center <- {1007, 632};
	point center <- {0, 0};

	/////////// CITYMATRIX   //////////////	
	string DATA <- "/home/dunland/github/q100_viz/q100viz/data/export.json";
	map<string, unknown> cityMatrixData <- json_file(DATA).contents;

	init {
		do create_grid();
	}

	action create_grid {
	// empty agent lists:
		ask tile {
			do die;
		}

		// reinitialize data:
		cityMatrixData <- json_file(DATA).contents;
		list<int> gridCells <- cityMatrixData["grid"];
		int nrows <- int(map(map(cityMatrixData["header"])["spatial"])["nrows"]);
		int ncols <- int(map(map(cityMatrixData["header"])["spatial"])["ncols"]);
		write (nrows);
		write (ncols);
		string grid_as_string <- cityMatrixData["grid"];
		//		map grid_as_map <- map(cityMatrixData["grid"]);
		list<map> grid_as_list_of_maps <- cityMatrixData["grid"];
		//		write(grid_as_map);
		write (grid_as_list_of_maps);
//		write (grid_as_list_of_maps[1]['rot']);
		//		brickSize <- float(map(map(cityMatrixData['header'])['spatial'])['cellsize']);
		brickSize <- 1.0;
		int count <- 0;
		loop i from: 0 to: ncols - 1 {
			loop j from: 0 to: nrows - 1 {
				create tile {
				//					id <- int(gridCells[nrows + ncols]);
					id <- count;
					myCell <- lego_grid[count];
					location <- myCell.location;
					//					shape <- square(brickSize * 0.9) at_location location;
					rotation <- int(grid_as_list_of_maps[count]['rot']) * 90;
					type <- int(grid_as_list_of_maps[count]['type']);
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
		do create_grid();
	} }

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