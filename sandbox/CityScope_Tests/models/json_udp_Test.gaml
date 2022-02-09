/**
* Name: json_udp
* Example of json-string compilation and transmission via udp. 
* Author: philip
* Tags: json, udp
*/

model json_udp

global {
	reflex construct_json_object {
		/**
		 * Compiles a json-string containing the current simulation step and a json-object with the given attributes for each household.
		 * The string is saved to ../jstring.json and sent to localhost via udp.
		 */ 
		list<string> numeric_attrs <- ["SN", "CEEK"];
		list<string> text_attrs <- ["name"];
		string json_string <- "{ \"step\": " + cycle + ", \"date\": " + "\"" + current_date + "\",";
		json_string <- json_string + "\"agents\": [";
		bool first <- true;
		ask agents of_generic_species(households){
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
		ask udp_sender {
			do send_message(json_string);
		}
		save json_string to: "../jstring.json" rewrite: true;
	}
	
	init {
		create udp_sender number: 1 {
			do connect to: "localhost" protocol: "udp_emitter" port: 9876;
		}	
	}
}

species udp_sender skills: [network] {
	action send_message(string messg){
		do send contents: messg;
		
	}
}

experiment json_udp type: gui {

	output {
	}
}
