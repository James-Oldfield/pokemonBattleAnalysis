// http request library dependency 
import http.requests.*;
// controlP5 for GUI
import controlP5.*;

PokedexReq pokedexReq;
Pokedex    pokedex;
GUI        mainGUI;

ControlP5 cp5;

void setup() {
	size(500, 500);
	background(0);

	cp5     = new ControlP5(this);
	mainGUI = new GUI();

	pokedexReq = PokedexReq.getInstance();
	pokedex = new Pokedex(pokedexReq.returnPokedexData());

}

void draw() {}

class Pokedex {

	JSONObject pokedexData;
	JSONArray  pokedexArray;

	Pokedex(String _pokedexData) {
		// Parse the JSON-formatted string as a JSONObject
		pokedexData  = JSONObject.parse(_pokedexData);
		pokedexArray = pokedexData.getJSONArray("pokemon");
	}

	String findPokemon(String desiredName) {

		/*
		// Method to search through the pokedex JSONObject returned from the initial HTTPRequest.
		//
		// @return String     - Either the desired URI needed for the requested pokemon, or the error message on no match.
		// @param desiredName - The String name of the Pokemon that is used as a search string to find the right JSONObject for which to return the uri.
		*/

		JSONObject index;
		String uri, nameFound, 
		       returnError = "No pokemon found! Did you spell the name right?";

		// Loop through entire JSONArray
		for(int i = 0; i < pokedexArray.size(); i++) {
			// Get the JSONObject at each index, containing name and the resource_uri needed to hit the API again
			index     = pokedexArray.getJSONObject(i);
			nameFound = index.getString("name");

			// Does the 'name' value of this JSONObject match what I'm looking for? If so, return the uri needed for that individual pokemon.
		  if(nameFound.equals(desiredName)) {
		  	uri = index.getString("resource_uri");
		    return uri;
		  }
		}	

		return returnError;

	}

}

class GUI {

	/*
	// GUI Class to instantiate the main home-screen GUI object, takes no parameters and is set up using pre-determined, hard-coded variables declared locally in the class
	*/

	String      poke1Name, poke2Name;
	PokeRequest poke1Obj,  poke2Obj;
	PVector     loc = new PVector(100, 100);

	int h = 50, 
      w = 200;

	GUI() {
		// automatically call the display method
		this.display();
	}

	void display() {

	/*
	// Functionality to display the GUI by creating the features
	*/

	// Add submit button
		cp5.addBang("submit")
			.setPosition(loc.x, loc.y + h * 4)
			.setSize(w/2, h)
			// plug to references the current class, rather than the default sketch extending PApplet
			.plugTo(this, "submit")
			.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);    

	// add pokemon 1 field
		cp5.addTextfield("poke1")
			.setPosition(loc.x, loc.y)
			.setSize(w, h)
			.setFont(createFont("helvetica",30))
			.setLabel("pokemon 1")
			.setAutoClear(false);

	// add pokemon 2 field
		cp5.addTextfield("poke2")
			.setPosition(loc.x, loc.y + h*2)
			.setSize(w, h)
			.setFont(createFont("helvetica",30))
			.setLabel("pokemon 2")
			.setAutoClear(false);
	}

	void submit() {

	/*
	// Functionality to take place upon the submit button being pressed
	*/

		println("yo submit button!");

		// Pass the entered text into the findPokemon method, and store the returning uri String object in poke1 and poke2 respectively. 
		poke1Name = pokedex.findPokemon(cp5.get(Textfield.class,"poke1").getText());
		poke2Name = pokedex.findPokemon(cp5.get(Textfield.class,"poke2").getText());

		poke1Obj  = new PokeRequest(poke1Name);

	}

}

class Request {

	/*
	// Base HTTP Request super-class in which JSONObject returned is parsed as appropriate according to my program and the PokeAPI.
	*/

	String uri;
	JSONObject pokemonData;

	Request(String _uri) {
		uri = _uri;

		this.returnPokemonData(uri);
	}

	void returnPokemonData(String uri) {

		/*
		// Functionality to hit the API at the individual pokemon endpoint, returning the data of the individual pokemon that the user's entered.
		*/

		// NEED TO IMPLEMENT TRY/CATCH ERROR HANDLING
		GetRequest g = new GetRequest("http://pokeapi.co/" + uri);
		g.send();

		// the getContent method innate to the http request library returns the content as a String, so is converted to a JSONObject here
		pokemonData = JSONObject.parse(g.getContent());

	}

}

class PokeRequest extends Request{

	/*
	// Extending the basic request class, this class also hits the Sprite endpoint.
	*/

	PokeRequest(String _uri) {
		super(_uri);

		this.returnPokemonData(uri);
		this.createSpriteRequests();
	}

	void createSpriteRequests() {

		/*
		// Functionality to create Sprite requests for this pokemon JSONObject returned, as the Sprite endpoint is different to the Pokemon one
		*/

		// Find the String containing the Sprite URI from the JSONArray and containing JSONObkect  
		String spriteUri = pokemonData.getJSONArray("sprites").getJSONObject(0).getString("resource_uri");

		println(spriteUri);

	}

}