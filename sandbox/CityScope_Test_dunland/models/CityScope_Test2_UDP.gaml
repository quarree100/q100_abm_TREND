/**
* Name: CityScopeTest
* Modell zur Kommunikation zwischen CityScoPy (per LEGO-Grid) und GAMA. 
* Author: dunland
* Tags: 
*/
model CityScopeTest

/* Insert your model definition here */
global {
	int port <- 5000;
	string url <- "localhost";
	message _message;

	// Variables used to initialize the table's grid.
	float brickSize <- 21.3;
	point center <- {0, 0};

	/////////// CITYMATRIX   //////////////	
	int nrows <- 11;
	int ncols <- 11;

	init {
		create NetworkingAgent number: 1 {
			do connect to: url protocol: "udp_server" port: port;
		}

		int count <- 0;
		loop x from: 0 to: ncols - 1 {
			loop y from: 0 to: nrows - 1 {
				create tile number: 1 {
					self.myCell <- lego_grid[count];
					self.location <- myCell.location;
					count <- count + 1;
				}

			}

		}

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

species NetworkingAgent skills: [network] {

	reflex fetch when: has_more_message() {
		loop while: has_more_message() {
			_message <- fetch_message();
			write "new message";
			if _message != nil {
				list coordinates <- string(_message.contents) split_with ("content:");
				write (coordinates[0]);

				/* decode incoming message: */
				int cell_pointer <- 0;
				int type_pointer <- 0;
				int x_pointer <- 0;
				int y_pointer <- 0;
				//
				int tileCount <- 0;
				loop i from: 0 to: length(coordinates[0]) {
					let c <- coordinates[0] at i;
					if (c = '[' and i > 1) // ignore first and second '['
					{
					    /* next cell: */
						cell_pointer <- (cell_pointer + 1) mod (nrows * ncols);
						x_pointer <- cell_pointer mod ncols;
						y_pointer <- int(cell_pointer / nrows);			
						tileCount <- tileCount + 1;

					} else if (c >= '0' and c <= '9') {
					// set values in array:
					// get ID:
						if type_pointer = 0 {
							write "ID:" + c;
								tile[tileCount].type <- int(c);

							if tile[tileCount].type = 1 {
								tile[tileCount].color <- #brown;
							} else if tile[tileCount].type = 2 {
								tile[tileCount].color <- #purple;
							} else if tile[tileCount].type = 3 {
								tile[tileCount].color <- #green;
							} else if tile[tileCount].type = 4 {
								tile[tileCount].color <- #orange;
							}

							// get rotation:
						} else if type_pointer = 1 {
							write "rotation:" + c;
							if (length(tile) > 0) {
								tile[tileCount].rotation <- int(c) * 90;
							}

						}
						type_pointer <- (type_pointer = 0) ? 1 : 0; // 0 for ID, 1 for rotation

					} }
			} } }


}

grid lego_grid width: ncols height: nrows {
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