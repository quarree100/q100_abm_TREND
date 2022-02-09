Die Datei `json_udp_Test.gaml` stellt die Möglichkeit bereit, ausgewählte Attribute von Haushalten in einer lokalen json-Datei zu speichern und per UDP über das Netzwerk zu versenden.
### Verwendung
Zunächst muss die Datei im Header des Hauptmodells mit dem `import` Statement eingebunden werden. Je nach Speicherort kann das so aussehen:
```
import "../modules/json_udp_Test.gaml"
 ```

Innerhalb der Datei müssen folgende Einstellungen festgelegt werden.
#### 1.
Adresse und Port des UDP-Clients, sowie Speicherort der json-Datei:
```
string client_ip <- "localhost";
int client_port <- 9876;
string save_path <- "../jstring.json";
```
#### 2.
- Spezies, dessen Attribute gesendet werden sollen (`indicated_species`)
- Liste der numerischen Attribute die gesendet werden sollen (`numeric_attrs`)
- Liste der Text-Attribute die gesendet werden sollen (`text_attrs`)

Hierfür müssen die gewünschten Werte bei der Erstellung des Agenten `udp_sender` übergeben werden. Das sieht zum Beispiel so aus.
```
init {
		create udp_sender number: 1 with: [numeric_attrs::["SN", "CEEK"], text_attrs::["name"], indicated_species::"households" ] {
			do connect to: client_ip protocol: "udp_emitter" port: client_port;

		}
}
```
#### 3.
Sollen die Werte nicht in einer json-Datei gespeichert werden, so muss zusätzlich der Wert `save_json::false` an den udp_sender übergeben werden. 
