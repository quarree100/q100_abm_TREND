/**
* Name: json_udp
* json-string compilation and transmission via udp. 
* Author: philipoalleye
* Tags: json, udp
*/

model json_udp

global {
	string client_ip <- "localhost";
	int client_port <- 8081;
	string save_path <- "../jstring.json";
	
	
	init {
		create udp_sender number: 1 with: [save_json::false, interval::100] {
			do connect to: client_ip protocol: "udp_emitter" port: client_port;
		    
		}	
	}
}

species udp_sender skills: [network] {
	bool save_json <- true;
	int interval <- 100;
	list<string> numeric_attrs;
	list<string> text_attrs;
	string indicated_species;
	
	string construct_json_object {
		/**
		 * Compiles a json-string containing the current simulation step and a json-object with the given attributes for each household.
		 * The string is saved to ../jstring.json and sent to localhost via udp.
		 */ 
		
		string json_string <- "{'step' : " + cycle;
		
		if !bool(indicated_species) {
			json_string <- json_string + "}";
			return json_string;
		}
		
		json_string <- json_string + "\"agents\": [";
		bool first <- true;
		ask agents of_generic_species(species(indicated_species)){
			string my_string <- "{";
			loop a over: text_attrs{
				if my_string = "{" {
					my_string <- my_string + "\"" + a + "\": " + "\"" + self[a] + "\"";
				}
				else {
					my_string <- my_string + ", " + "\"" + a + "\": " + "\"" + self[a] + "\"";
				}
			}
			loop a over: numeric_attrs{
				if my_string = "{" {
					my_string <- my_string + "\"" + a + "\": " + self[a];
				}
				else {
					my_string <- my_string + ", " + "\"" + a + "\": " + self[a];
				}
			}
			my_string <- my_string + "}";
			if first {
				json_string <- json_string + my_string;
				first <- false;
			}
			else {
				json_string <- json_string + ", " + my_string;
			}
		}
		json_string <- json_string + " ] }";
		if save_json {
			save json_string to: save_path rewrite: true;
		}
		
		return json_string;
	}
	
	
	reflex send_message{
		if cycle mod interval = 0 {
			string messg <- self.construct_json_object(); 
			do send contents: messg;	
		}
	}
}
