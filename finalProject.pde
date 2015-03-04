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

	// defined as private so to encapsulate the class 
	private JSONObject pokedexData;
	private JSONArray  pokedexArray;

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

	private String      poke1Name, poke2Name;
	private PokeRequest poke1Obj,  poke2Obj;
	private PVector     loc = new PVector(100, 100);

	private int h = 50, 
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

		poke1Obj  = new PokeRequest(poke1Name, 1);
		poke2Obj  = new PokeRequest(poke2Name, 2);

	}

}

class Request {

	/*
	// Base HTTP Request super-class in which JSONObject returned is parsed as appropriate according to my program and the PokeAPI.
	*/

	private String uri;

	Request(String _uri) {
		uri = _uri;

		this.returnPokemonData(uri);
	}

	JSONObject returnPokemonData(String uri) {

		/*
		// Method to hit the API with the given string and return the JSONObject at the endpoint, returned.
		//
		// @return JSONObject - Returns the JSONObject returned from the HTTPRequest
		// @param uri         - String to suffix the end of the base http request.
		*/

		// NEED TO IMPLEMENT TRY/CATCH ERROR HANDLING
		GetRequest g = new GetRequest("http://pokeapi.co/" + uri);
		g.send();

		// the getContent method innate to the http request library returns the content as a String, so is converted to a JSONObject here
		JSONObject pokemonData = JSONObject.parse(g.getContent());

		return pokemonData;

	}

}

class PokeRequest extends Request {

	/*
	// Extending the basic request class, this class also hits the Sprite endpoint of the given pokemon
	*/

	private JSONObject pokemonData;
	private String     spriteUri, spriteJSON;
	private int        index;

	PokeRequest(String uri, int _index) {
		super(uri);

		// index will be used to offset the sprites
		index = _index;

		// Initial request with the pokemon name as string, stores the returned JSONObject, used to hit the Sprite endpoint in the next method call
		pokemonData = this.returnPokemonData(uri);
		this.createSpriteRequests();
	}

	void createSpriteRequests() {

		/*
		// Functionality to create Sprite requests for this pokemon JSONObject returned, as the Sprite endpoint is different to the Pokemon one
		*/

		// Find the String containing the Sprite URI from the JSONArray and containing JSONObkect  
		spriteJSON = pokemonData.getJSONArray("sprites").getJSONObject(0).getString("resource_uri");

		// returns the sprite object for the specified pokemon
		spriteUri = this.returnPokemonData(spriteJSON).getString("image");

		// callback function to draw the sprites
		this.drawSprites();

	}

	void drawSprites() {

		/*
		// Functionality draw the sprites using the sprite URL provided from the API sprite endpoint, draws the sprites relative to the GUI using properties of the mainGUI as well as using the index of the image for a y- position.
		*/

		PImage sprite;

		// load an individual sprite using the returned spriteURI for each pokemon
		sprite = loadImage("http://pokeapi.co/" + spriteUri);

		// draw the sprite at locations relative to the GUI dimensions
		image(sprite, 
			    mainGUI.loc.x + mainGUI.w + mainGUI.h,
		      mainGUI.loc.y * index, 
		      mainGUI.h, mainGUI.h
		     );

	}

}