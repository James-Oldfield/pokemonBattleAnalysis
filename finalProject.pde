// http request library dependency 
import http.requests.*;

Request pokedexReq;
Pokedex pokedex;

void setup() {
	pokedexReq = Request.getInstance();
	pokedex = new Pokedex(pokedexReq.returnPokedexData());
}

void draw() {
	
}

class Pokedex {

	JSONObject pokedexData;

	Pokedex(String _pokedexData) {
		pokedexData = _pokedexData;
		// pokedexData = loadJSONObject(_pokedexData);
		println(pokedexData.getClass());
	}

}