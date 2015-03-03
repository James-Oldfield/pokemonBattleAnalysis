// http request library dependency 
import http.requests.*;
import org.json.*;

Request pokedexReq;
Pokedex pokedex;

void setup() {
	pokedexReq = Request.getInstance();
	pokedex = new Pokedex(pokedexReq.returnPokedexData());
}

void draw() {
	
}

class Pokedex {

	JSON pokedexData;

	Pokedex(String _pokedexData) {
		pokedexData = JSON.parse(_pokedexData);

		println(pokedexData.getJSONObject(0));
	}

}