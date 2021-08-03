/**
* Name: Complexity Explorer
* Based on the internal empty template. 
* Author: philip
* Tags: 
*/


model complexity_explorer

global {
        int hh_nb <- 50; // number of households
        float hh_network_motivation <- 0.8; //maximum household motivation to communicate ,probability is 0.2 / hh_network_motivation
        float pro_env_share_hh <- 0.5; // share of pro-environment households
        float hh_op_thr <- 1.5; // threshold at which a household's opinion changes from indifferent to pro-env
        float knowledge_loss <- 0.0001; // daily loss of household's knowledge
        string network_type <- "Random";
        
        bool parallel_opps_poss <- true; // switch to enable parallel participation opportunities
        int parallel_part_opps <- 10; // maximum number of possible parallel part opps
        int cum_no_part_opps <- 0; // counter of part opps
        float part_opps_influence <- 0.05; // influence of part opps on household knowledge
        int part_no_per_year <- 100; // average number of part opps per year
        float parallel_opps_prob <- 0.8; // probability for the occurence of parallel part opps
        
        user_command arrange action: arrange_circle; // 
        
        action arrange_circle {
        	// arrange households in a circle ordered by their id.
        	ask household {
        		float phi <- 2* #pi/ hh_nb * int(self);
        		write phi;
        		location <- {30*cos_rad(phi), 30*sin_rad(phi)} + centroid(world.shape) ; 
        	}
        }
        
        action create_part_opps {
        	// create a random number of part opps
        	if flip(part_no_per_year / 365) {
        		if parallel_opps_poss and flip(parallel_opps_prob) {
        			create part_opp number: (rnd(parallel_part_opps));
        		}
        		else {
        			create part_opp;
        		}
        	}
        	
        	cum_no_part_opps <- cum_no_part_opps + length(part_opp);
        }
  
        
        action nw_watts_strogatz(int nh_size, float rewire_prob) {
        	// connects hoseholds in a random network based on the Watts-Strogatz random-Graph algorithm.
        	loop node1 over: household {
        		loop node2 over: household {
        			int i <- int(node1);
        			int j <- int(node2);
        			int dist <- mod(j - i, hh_nb - 1 - nh_size / 2);
        			if i < j and dist <= nh_size/2 and 0 < dist {
        				if flip(1 - rewire_prob) {
         					create link with: [nodes::[node1, node2]];
        				}
        				else {
        					list ids <- range(0, hh_nb - 1) - [i, j];
        					int id <- sample(ids, 1, false) at 0;
        					agent node3 <- household at id;
        					create link with: [nodes::[node1, node3]];
        				}
        			}
        		}
        	}
        }
        
        action nw_preferential_attachment(int min_deg) {
        	// connects hoseholds in a random network based on the Barabási-Albert preferential attachment algorithm.
        	list connected <- sample(household.population, 2, false);
        	create link with:[nodes::connected];
        	
        	loop node over: household - connected {
        		list probs <- collect(connected, each.get_degree() / (2 * length(link)));
        		//write probs;
        		list choice <- sample(connected, min_deg, false, probs);
        		loop node2 over: choice {
        			create link with:[nodes::[node, node2]];
        		}	
        		connected <- connected + node;	
        	}
        }
        
        
        action nw_random(float prob) {
        	// creates a random graph where each edge has the probability 'prob' to exist.
        	loop node1 over: household{
        		loop node2 over: household{
        			if int(node1) < int(node2){
        				if rnd(1.0) <= prob{
        					create link with:[nodes::[node1, node2]];
        					//write [node1, node2];
        				}
        			}
        		}
        	}
        }
        init {
        	// initial setup of the model.
        	create household number: hh_nb;
        	ask int(pro_env_share_hh * hh_nb) among household {
          		knowledge <- rnd(hh_op_thr / 2, 1.0);
          		awareness <- rnd(hh_op_thr / 2, 1.0);
          		do opinion_change;
        	}
        	if network_type = "Random" {
        		do nw_random(0.25);
        	}
        	else if network_type = "Preferential Attachment" {
        		do nw_preferential_attachment(1);
        	}
        	else if network_type = "Watts-Strogatz" {
        		do nw_watts_strogatz(2, 0.1);
        	}
		}
		
		reflex step {
			// pass one day
			do create_part_opps;
			ask household {
				do pass_day;
			}
			ask part_opp { // remove inactive part opps from the previous day.
				if !active {
					ask link where (each.nodes contains self) {
						do die;
					}
					do die;
				}
				else {
					active <- false;
				}
				}
			
		}	
}

species household {
        float knowledge <- rnd(1.0); //knowledge about environmental behavior
        float awareness <- rnd(1.0); // awareness about environmental behavior
        bool opinion <- false; // households opinion false: indifferent, true: env-friendly
        list<agent> neighbors <- []; // list of network-neighbors
        float network_motivation <- rnd(hh_network_motivation); // current motivation to communicate
        
        aspect base {
          draw circle(1.0) color: opinion ? #lightgreen : #grey;
        }
        
        int get_degree { 
        	// method to get the current number of neighbors
        	do get_neighbors;
        	return length(neighbors);
        }
        
        action get_neighbors {
        	// method to get the neighbors in the network
        	neighbors <- [];
        	ask link {
        		if (self.nodes contains myself) {
        			myself.neighbors <- myself.neighbors + (self.nodes - myself);
        		}
        	}
        }
        
        
        action communicate {
        	// lets households communicate with their neighbors if the network_motivation is high enough. Moves awareness closer to the mean of the neighbors awareness'.
        	do get_neighbors;
        	if network_motivation > 0.2 {
        		ask neighbors {
        			if (awareness < mean([awareness, myself.awareness])) and awareness < 1 {
        				awareness <- awareness + 0.05;
        			}
        			else if awareness > 0 {
        				awareness <- awareness - 0.05;
        			}
        			//write awareness;
        			//write myself.awareness;
        		}
        	
        	}
        	if flip(0.2) {
        		ask neighbors {
        			if (knowledge < mean([knowledge, myself.knowledge])) and knowledge < 1 {
        				knowledge <- knowledge + 0.05;
        			}
        			else if knowledge > 0 {
        				knowledge <- knowledge - 0.05;
        			}
        			//write knowledge;
        			//write myself.knowledge;
        		}
        	
        	} 
        }
        
        action opinion_change {
        	// changes the opinion based on knowledge and awareness
        	if awareness + knowledge >= hh_op_thr {
        		opinion <- true;
        	}
        	else {
        		opinion <- false;
        	}
        }
        
        action participate { 
        	//lets households participate at part opps they are connected to. Knowledge and awareness are raised.
        	ask part_opp where each.active {
        		if neighbors contains myself {
        			write myself;
        			if myself.knowledge < 1 {
        				myself.knowledge <- myself.knowledge + part_opps_influence;
        			}
        			if myself.awareness < 1 and !myself.opinion {
        				myself.awareness <- myself.awareness + 0.1;
        			}
        		}
        	}
        }
        
        
        action pass_day {
        	do communicate;
        	do opinion_change;
        	do participate;
        	knowledge <- knowledge - knowledge_loss;
        	network_motivation <- rnd(hh_network_motivation);
        }

}

species part_opp {
	bool active;
	list<agent> neighbors;
	init {
		// When created, part opps are connected to a random number of households with a pro-env opinion and a random number of indifferent households with high knowledge.
		active <- true;
		ask (household where (each.opinion)) {
			if flip(0.5) {
				create link with: [nodes::[self, myself]];
			}
		}
		ask (household where (!each.opinion and each.knowledge > 0.8)) {
			if flip(0.5) {
				create link with: [nodes::[self, myself]];
			}
		}
		do get_neighbors;
	}
	
	action get_neighbors {
        	neighbors <- [];
        	ask link {
        		if (self.nodes contains myself) {
        			myself.neighbors <- myself.neighbors + (self.nodes - myself);
        		}
        	}
        	}
	
	aspect base {
		draw square(3.0) color: rgb(rnd(255), rnd(255), rnd(255));
	}
}


species link {
	list<agent> nodes;
	aspect base{
		draw polyline(nodes) color: #black;
	}
}

experiment complexity_explorer type: gui {
  
  parameter "Number of Households" var: hh_nb min: 1 max: 1000 category: "Household";
  parameter "Share of pro-environmental Households" var: pro_env_share_hh min: 0.0 max: 1.0 category: "Household";
  parameter "Opinion Change Threshold" var: hh_op_thr min: 0.75 max: 1.75 category: "Household";
  parameter "Motivation to Communicate" var: hh_network_motivation min: 0.0 max: 1.0 category: "Household";
  parameter "Daily Knowledge Loss" var: knowledge_loss min:0.0 max: 0.01 category: "Household";
  parameter "Network Type" var: network_type among: ["Random", "Preferential Attachment", "Watts-Strogatz"] category: "Household";
  
  parameter "Influence of Participation Opportunities" var: part_opps_influence min: 0.0 max: 0.3 category: "Participation Opportunity";
  parameter "Probability of parallel Participation Opportunities" var: parallel_opps_prob min: 0.0 max: 1.0 category: "Participation Opportunity";
  parameter "Average Participation Opportunities per Year" var: part_no_per_year min: 0 max: 100 category: "Participation Opportunity";
  parameter "Maximum Number of parallel Participation Opportunites" var: parallel_part_opps min: 0 max: 5 category: "Participation Opportunity";
  parameter "Parallel Participation Opportunities" var: parallel_opps_poss category: "Participation Opportunity";
  output {
    layout #split; 
    monitor Jahr value: floor(cycle/365) + 1 refresh: every(1#cycle);
    monitor "Number of Part_Opps" value: cum_no_part_opps refresh: every(1#cycle);
    display "Sum of Knowledge" {
    	chart "Sum of Knowledge" type: series {
    	data "Knowledge" value: household sum_of (each.knowledge);
    	}
    	
    	
    	}

    display "Sum of Awareness" {
    	chart "Sum of Awareness" type: series {
    		data "Awareness" value: household sum_of (each.awareness);
    	}
    	
    }
    display "Opinion of Households" {
    	chart "Opinion of Households" type: histogram {
    		data "Pro-Env" value: household count (each.opinion);
    		data "Indifferent" value: household count (!each.opinion);
    	}
    }
    
    display main_display {
      
      
      species household aspect: base;
      species link aspect: base;
      species part_opp aspect: base;
    }
  }
}

