extensions [nw]

breed [households household]
breed [part_opps part_opp]

households-own [

  knowledge ;;knowledge about environmental behavior, fixed and randomly distributed
  awareness ;;awareness about environmental behavior, fixed and randomly distributed
  opinion ;;opinion about environmental behavior -> can be changed if knowledge and opinion together reach a >threshold<
          ;;the opinion is simplified into "pro-environmental" and "indifferent"
          ;;randomly distributed -> defineable in interface
  network_motivation ;;motivation of households to communicate -> fixed and randomly distributed
]

globals [
  parallel_part_opps_bool ;;bool for decision if parallel participation opportunities will take place or not
  cum_no_part_opps ;;cumulated number of participation opportunities that took place
]


to setup

  clear-all

  ;;creating household agents depending on selected network structure
  ;;probabilities and attributes of network theories are not (yet) calibrated
  if network = "random" [
    nw:generate-random households links hh_no 0.03 [ ;;hh_no = number of households -> defined in interface
      set shape "person"
      setxy random-xcor random-ycor
    ]
  ]

  if network = "preferential attachment" [
    nw:generate-preferential-attachment households links hh_no 1 [ ;;hh_no = number of households -> defined in interface
      set shape "person"
      setxy random-xcor random-ycor
    ]
  ]

  if network = "watts-strogatz" [
    nw:generate-watts-strogatz households links hh_no 1 0.1 [ ;;hh_no = number of households -> defined in interface
      set shape "person"
      setxy random-xcor random-ycor
    ]
  ]

  ask households [ ;;defining household variables
    set opinion "indifferent"
    set knowledge random-float 1
    set awareness random-float 1
    set network_motivation random-float hh_network_motivation
  ]

  ask n-of (pro_environmental_share_hh * hh_no) households [ ;;pro_environmental_share_hh -> defined in interface
    let new_number (random-float (2 - hh_opinion_threshold)) + hh_opinion_threshold ;;puts the variables of households with pro_environmental properties on a random value which is > opinion threshold
    set knowledge (new_number / 2)
    set awareness (new_number / 2)
    ]

  opinion_change

  ask households [
    ifelse opinion = "pro_environmental" [
      set color green
    ]
    [
      set color grey
    ]
  ]



  set parallel_part_opps_bool false
  set cum_no_part_opps 0




  repeat 20 [layout-spring households links 0.2 5 1] ;;layouts the network structure

  reset-ticks
end



to go

  ;;participation opportunities

  parallel_opps_per_tick ;;ask procedure if parallel opportunities are possible in this run

  ifelse parallel_part_opps_bool = false [
  part_opps_1 ;;single event
  ]

  [
  part_opps_multiple ;;multiple events
  ]

  set parallel_part_opps_bool false
  set cum_no_part_opps cum_no_part_opps + (count part_opps) ;;add number of part_opps for plotting

;;households interactions

  communicate ;;important that procedure "communicate" runs before "participate" so that only households are communicating with each other
  opinion_change
  participate

  ask households [ ;;minimal "loss" of knowledge about environmental relevant knowledge
    if knowledge > 0 [
      set knowledge knowledge - 0.0001 ;;fixed
    ]
  ]

  ask households [ ;;update network motivation for next tick
    set network_motivation random-float hh_network_motivation
  ]

  ask households [ ;;update color
    ifelse opinion = "pro_environmental" [
      set color green
    ]
    [
      set color grey
    ]
  ]

;;dying of part_opps

  ask part_opps [
    die
  ]

tick
end


to communicate ;;network_motivation is variable via interface, hh influence friends!not the other way around (influence-direction)

  ask households [
    if network_motivation > 0.2 [ ;;variates network_motivation every tick within the frame defined via hh_network_motivation in interface, every hh under 0.2 will not communicate
      ask link-neighbors [
        ifelse awareness < (([awareness] of self + [awareness] of myself) / 2) [ ;;compares awareness of friendly households and moves awareness of friend into the direction of the mean
          if awareness < 1 [
            set awareness awareness + 0.05
          ]
        ]
        [
          if awareness > 0 [
            set awareness awareness - 0.05
          ]
        ]
      ]
    ]
  ]

  ask households [
    let know_prob random-float 1 ;;runs same procedure with awareness but for knowledge and with a probability of 20% + lower rates
    if know_prob < 0.2 [
      ask link-neighbors [
        ifelse knowledge < (([knowledge] of self + [knowledge] of myself) / 2) [ ;;compares knowledge of friendly households and moves knowledge of friend into the direction of the mean
          if knowledge < 1 [
            set knowledge knowledge + 0.01
          ]
        ]
        [
          if knowledge > 0 [
            set knowledge knowledge - 0.01
          ]
        ]
      ]
    ]
  ]

end


to opinion_change ;;updates the opinion based on awareness & knowledge

  ask households [
    let aware_know_sum (awareness + knowledge)
    ifelse aware_know_sum >= hh_opinion_threshold [
      set opinion "pro_environmental"
    ]
    [
      set opinion "indifferent"
    ]
  ]

end


to participate ;;lets households participate on participation events

 if count part_opps > 0 [ ;;creates links between "pro_environmental" households and part_opps
  ask households with [opinion = "pro_environmental"] [
    create-links-with n-of (random (count part_opps + 1)) part_opps ;;gives a random number of households the possibility to participate at a random (multiple) number of part_opps
  ]
  ask n-of (random (count households with [opinion = "indifferent" and knowledge > 0.8])) households with [opinion = "indifferent" and knowledge > 0.8] [ ;;creates randomly chosen links between "indifferent" but "high knowledge" hh & part_opps
    create-link-with one-of part_opps
  ]
 ]

  ask part_opps [
    ask link-neighbors [
      if knowledge < 1 [
        set knowledge (knowledge + part_opps_influence) ;;part_opps_influence is defined in interface
      ]
      if awareness < 1 and opinion = "indifferent" [ ;;if a random indifferent hh with high knowledge participates, it's awareness will be increased slighly
        set awareness (awareness + 0.1)
      ]
    ]
  ]


end






;;calculating possibility of more than one part_opp per tick
to parallel_opps_per_tick

  if parallel_opps_possible? = true [ ;;switch in interface

    let part_opps_probs_calc (parallel_part_opps_probs * 100) ;;probability defined in interface
    if random 100 < part_opps_probs_calc [
      set parallel_part_opps_bool true
    ]
  ]
end


;; procedure of only >>>1<<< participation opportunity popping up
to part_opps_1

  if (random-float 1 < (part_no_per_year / 365)) [ ;;probability that participation opportunity will arise in this time step - defined in interface
    create-part_opps 1 [ ;;number of participation-opportunities - defined in interface
      set shape "house"
      set size 3
      setxy random-xcor random-ycor

    ]
  ]
end

;; procedure of more than 1 participation opportunity popping up
to part_opps_multiple

  if (random-float 1 < (part_no_per_year / 365)) [ ;;probability that participation opportunity will arise in this time step - defined in interface
    create-part_opps ((random parallel_part_opps) + 1) [ ;;number of participation-opportunities - defined in interface
      set shape "house"
      set size 3
      setxy random-xcor random-ycor

    ]
  ]
end



@#$#@#$#@
GRAPHICS-WINDOW
447
49
956
559
-1
-1
15.2
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
days
30.0

BUTTON
15
50
90
95
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
50
180
95
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
190
210
223
hh_no
hh_no
0
1000
50.0
50
1
NIL
HORIZONTAL

SLIDER
235
295
430
328
parallel_part_opps_probs
parallel_part_opps_probs
0.1
1
0.9
0.1
1
NIL
HORIZONTAL

CHOOSER
230
50
430
95
network
network
"random" "preferential attachment" "watts-strogatz"
0

SWITCH
235
375
430
408
parallel_opps_possible?
parallel_opps_possible?
0
1
-1000

SLIDER
15
335
210
368
part_no_per_year
part_no_per_year
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
235
335
430
368
parallel_part_opps
parallel_part_opps
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
15
110
430
143
pro_environmental_share_hh
pro_environmental_share_hh
0
1
0.25
0.05
1
NIL
HORIZONTAL

PLOT
970
410
1170
560
opinion of households
time
no of hh
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Pro" 1.0 0 -10899396 true "" "plot count households with [opinion = \"pro_environmental\"]"
"Indiff" 1.0 0 -7500403 true "" "plot count households with [opinion = \"indifferent\"]"

SLIDER
15
150
210
183
hh_opinion_threshold
hh_opinion_threshold
0.75
1.75
1.25
0.05
1
NIL
HORIZONTAL

PLOT
970
50
1170
200
sum of knowledge
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [knowledge] of households"

PLOT
970
230
1170
380
sum of awareness
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [awareness] of households"

SLIDER
15
295
210
328
part_opps_influence
part_opps_influence
0
0.3
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
235
150
430
183
hh_network_motivation
hh_network_motivation
0
1
0.8
0.05
1
NIL
HORIZONTAL

MONITOR
120
515
282
560
cumulated no part_opps
cum_no_part_opps
17
1
11

MONITOR
305
515
432
560
year
round (ticks / 365)
17
1
11

SLIDER
235
190
430
223
knowledge_loss
knowledge_loss
0
0.01
0.006
0.001
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Residential energy systems are faced with a lot of unknown, innovative and transformational issues. The energy systems in those areas are strongly connected to neighborhood infrastructures and private energy consumption. Additionally the technologies used for end consumption are owned by the citizens. That leads directly to the strong need for communication and participation with and of citizens to encourage decisions and raise awareness for sustainable transitions and why they are needed. This model uses *Exploritory Modeling* approach for investigating the following question:
**Neighborhood communication about environmental behavior - Individual communication behavior (on a network basis) and impact of events of information and participation**
How do possibilities of participation influence the opinion in the neighborhood? Where is the tipping point at which participation events make a difference within communication of the neighborhood? The model tries to generate a better understanding of these dynamics.

There are two principal types of agents in the model: **Households** & **Participation Opportunities**

### Households (Individual-human level, sometimes referred to as "hh") -> shape "person"
- Households are geographically located at a specific spot within the residential area
- Represent the citizens of a residential area - every household owns a heterogeneous set of personal attitudes about environmental sustainability
- Reflixive cognition

### Participation opportunities (organizational level, somtimes referred to as "part_opps") -> shape "house"
- Takes place in irregular time steps
- Random amount of participants
- Improves the usual communication of Households
- Encourages Awareness and especially Knowledge about sustainable transitions
- Reflexive Cognition

### Environment
The neighborhood will be placed on patches (*discrete, spatial environment*) in a *bounded topology*
- After setup households have static place within the neighborhood
- Participation opportunities will take place on random patches within the neighborhood
- Furthermore the household's communication follow a *neighboring network* 


## HOW IT WORKS

### Properties
**Households**
- located at a random but static spot
- own a network of "friends" following three network-options: random, preferential attachment, watts-strogatz
- have awareness about environmental sustainability
- own knowledge about  environmental sustainability
- have an environmental opinion ("indifferent", "pro_environmental")
- have a fluctuating network-motivation which changes the possibility to communicate with their network

**Participation opportunities**
- frequency of occurance per year
- random places of occurance
- possibility of parallel opportunities within the neighborhood

### Actions
**Households**
- communicate with "friends"/network (on the chosen basis of networks)
 - households influence the awareness of their connected friends (only one-directional) and move it into the direction of the mean
 - households influence the knowledge of their connected friends (only one-directional) and move it into the direction of the mean
- in case the households reach a variable threshold (awareness + knowledge) they change their opinion (indifferent -> pro_environmental / the other way around)
- if there are Participation Opportunities, Household participate

**Participation opportunities**
- take place (variable, specific frequency per year)
- it's possible that there are more than one opportunities (variable)
- strongly influence the knowledge of participants (variable) and slightly the awareness
- only exist for one tick (day)

**Additional actions**
- households loose a small amount of knowledge over time
- every tick the network_motivation of households is changed


## HOW TO USE IT

- setup: Use the "setup" button to randomly spread the households in the "neighborhood"
- go: Use the "go" button to start the simulation
- network: use the "network" chooser to choose one of the three applicable network-principles (random, preferential attachment, watts-strogatz)
- pro_environmental_share_hh: use this slider to set the initial share of pro_environmental households in the simulation
- hh_opinion_threshold: use this slider to set the threshold of the opinion change of households (the lower the number, the lower the threshold to change)
- hh_network_motivation: use this slider to set the "motivation" (possibility) of households to communicate with each other
- hh_no: use this slider to set the number of households
- knowledge_loss: use this slider to set the loss of knowledge the households have every day (tick)
- part_opps_influence: use this slider to set the influence of the participation opportunities on the knowledge of households
- parallel_part_opps_probs: use this slider to set the probability that parallel participation events take place
- part_no_per_year: use this slider to set the number of participation events per year (randomly distributed -> x / 365)
- parallel_part_opps: use this slider to set the maximum number of possible parallel participation opportunities
- parallel_opps_possible?: use this switch to turn on/off the possibility of parallel participation opportunities

## THINGS TO NOTICE

- the "year"-monitor shows the year the simulation is in (ticks / 365)
- the "cumulated no part_opps"-monitor shows the number of participation opportunities that took place in total
- the "sum of knowledge/awareness" plots show how these properties of the whole population is distributed
- the "opinion of households" plot shows the distribution of households with "indifferent" and pro_environmental" opinions

## THINGS TO TRY

The starting conditions of the interface balance the neighborhood. Try to find out where the tipping points of participation events are. To what conditions opinions are absorbed by the communication dynamics of the neighborhood? To what conditions there is a real incluence of the participation events?
How do the network theories influence the outcome?
What change of inputs lead to emergent dynamics?

## EXTENDING THE MODEL

- Households may consist of several members which are communicating seperately
- Households could follow a goal- or utility based cognition
- Memory: Households can have a good or a bad impression of the participation event and remember it for two weeks (adaptive cognition)

## NETLOGO FEATURES

NW-extensions

## RELATED MODELS

-

## CREDITS AND REFERENCES

Please see the Netlogo-Extensions Website for information about the network extensions.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
