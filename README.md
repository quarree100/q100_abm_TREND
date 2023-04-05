# q100_abm
Agent-Based-Modeled Behavior Transformation in QUARREE100

## Recommended folder structure

```
project qScope
└───cspy
│   └───modified MIT CityScoPy Token Tag Decoder
└───data
|   └───outputs
|      └───output_[timestamp]
|         (simulation-specific output)
|         └───buildings_clusters_[timestamp].csv
|         (exportierte Gebäudeliste von Frontend)
|         └───simulation_parameters_[timestamp].xml
|         (xml-Datei mit allen Simulationsparametern zum Starten des headless modes)
|         └───connections
|         |       Export der Anschlussquoten
|         └───emissions
|         |      gebäudespezifische und aggregierte Quartiersemissionen
|         └───snapshot
|               von GAMA produzierte Grafiken
└───q100_abm
│   │   GAMA workspace folder
│   └───q100
│       │   Trend Model
│    	└───models
|       │    └───qscope_ABM.gaml
|       └───__data__ symlink zu data-Ordner (unten))
└───qScope_infoscreen
│       infoscreen (NodeJS/ JavaScript)
└───qScope_frontend
        projection (Python)

```

where:
- cspy: https://github.com/quarree100/cspy
- data: has to be linked from Seafile server
- GAMA: https://github.com/quarree100/q100_abm
- qScope_infoscreen: https://github.com/quarree100/qScope_infoscreen
- qScope_frontend: https://github.com/quarree100/qScope_frontend


## using GAMA with GitHub

- keep your GAMA workspace folder local, outside of this repository!
- a new project only needs a `.project` file indicating the name of the model, next to the folders `models` and `includes`
- a project's`includes` folder should be stored elsewhere **locally**, contain the same data as stored in Seafile. **Create a symlink to point to a local copy of the `includes` folder**!
