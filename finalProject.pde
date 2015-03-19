/*
 * PROGRAM REQUIRES INTERNET CONNECTION
 * Example pokemon to enter: "charizard", "blastoise", "dragonite"
*/

// http request library dependency 
import http.requests.*;
// controlP5 for GUI
import controlP5.*;

PokedexReq pokedexReq;
Pokedex    pokedex;
GUI        mainGUI;

// Holds the Pokemon objects of the two pokemon being compared
ArrayList<Pokemon> pokemonList = new ArrayList<Pokemon>();

// Polymorphic Arraylist to serve reference to every type of request
ArrayList<Request> requestsList = new ArrayList<Request>();

ControlP5 cp5;

void setup() {
	size(1000, 500);
	background(0);

	cp5     = new ControlP5(this);
	mainGUI = new GUI();

	pokedexReq  = PokedexReq.getInstance();
	tryHttpRequest();

}

void draw() {
		println(pokemonList);
	// if there has been two pokemon entered for comparison, the comparisons can take place
	if (pokemonList.size() == 2) {
		// pass both pokemon into the comparison function
		println(compareStats(pokemonList.get(0), pokemonList.get(1)));
	}
}

HashMap compareStats (Pokemon p0, Pokemon p1) {

	/*
	 * The compareStats function compares the two pokemon object and returns a HashMap value with the best stats
	*/

	// HashMap to store the index of the pokemon with the best stats
	// FORMAT: 'stat type', winning index, difference between values 
	HashMap<String,Integer> bestStats = new HashMap<String,Integer>();

	// decide which stats are highest, and place the indexs into the HashMap
	// ATTACK
	if (p0.attack > p1.attack) { 
		bestStats.put("attack", 0); 
	} else { 
		bestStats.put("attack", 1);	
	}
	// DEFENSE
	if (p0.defense > p1.defense) { 
		bestStats.put("defense", 0); 
	} else { 
		bestStats.put("defense", 1);	
	}
	// hp
	if (p0.hp > p1.hp) { 
		bestStats.put("hp", 0); 
	} else { 
		bestStats.put("hp", 1);	
	}
	// sp_atk
	if (p0.sp_atk > p1.sp_atk) { 
		bestStats.put("sp_atk", 0); 
	} else { 
		bestStats.put("sp_atk", 1);	
	}
	// sp_def
	if (p0.sp_def > p1.sp_def) { 
		bestStats.put("sp_def", 0); 
	} else { 
		bestStats.put("sp_def", 1);	
	}
	// speed
	if (p0.speed > p1.speed) { 
		bestStats.put("speed", 0); 
	} else { 
		bestStats.put("speed", 1);	
	}
	// weight
	if (p0.weight > p1.weight) { 
		bestStats.put("weight", 0); 
	} else { 
		bestStats.put("weight", 1);	
	}

	// return the HashMap object with containing the String of the stat and the highest stat
	return bestStats;

}

void tryHttpRequest() {

	/*
	// Functionality with error handling to hit the API of the singleton object, prints out the error if exception if thrown
	*/

	try {
		pokedex = new Pokedex(pokedexReq.returnPokedexData());
	} catch (Exception e) {
		e.printStackTrace();
		g = null;
	}

	if (g == null) {
		println("unable to make connection to API, check your internet connection");
		// if there is no internet connection, close the program
		System.exit(0);
	}

}

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

		// drawing background to remove previous sprites etc as this whole thing is being called in setup
		background(0);

		// Pass the entered text into the findPokemon method, and store the returning uri String object in poke1 and poke2 respectively. 
		poke1Name = pokedex.findPokemon(cp5.get(Textfield.class,"poke1").getText());
		poke2Name = pokedex.findPokemon(cp5.get(Textfield.class,"poke2").getText());

		// if the returned string has a match in the pokedex, make the next request, else throw an error
		if (!(poke1Name.equals("No pokemon found! Did you spell the name right?"))) {
			poke1Obj = new PokeRequest(poke1Name, 1);
		} else {
			println("There was no Pokemon match found from your first entered Pokemon");
		}

		// if the returned string has a match in the pokedex, make the next request, else throw an error
		if (!(poke2Name.equals("No pokemon found! Did you spell the name right?"))) {
			poke2Obj = new PokeRequest(poke2Name, 2);
		} else {
			println("There was no Pokemon match found from your second entered Pokemon");
		}

	}

}

public abstract class Request {

	/*
	// Base HTTP Request super-class in which JSONObject returned is parsed as appropriate according to my program and the PokeAPI. Defined as Abstract to serve the purpose of being the foundation for a subclass, and the Request class cannot be instantiated itself.
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

		// NEED TO IMPLEMENT NATIVE TRY/CATCH ERROR HANDLING
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
	private String     spriteUri, spriteJSON, name;
	private int        index, attack, defense, hp, sp_atk, sp_def, speed, weight;

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
		name       = pokemonData.getString("name");

		// returns the sprite object for the specified pokemon
		spriteUri  = this.returnPokemonData(spriteJSON).getString("image");

		attack     = pokemonData.getInt("attack");
		defense    = pokemonData.getInt("defense");
		hp         = pokemonData.getInt("hp");
		sp_atk     = pokemonData.getInt("sp_atk");
		sp_def     = pokemonData.getInt("sp_def");
		speed      = pokemonData.getInt("speed");
		weight     = pokemonData.getInt("weight");

		// callback function to create a pokemon object from the data returned
		Pokemon pokemon = new Pokemon(name, spriteUri, index, attack, defense, hp, sp_atk, sp_def, speed, weight);

		// Add this request to the polymorphic arraylist of requests
		requestsList.add(this);

		// is the list contains more than 2, delete the first one
		if (pokemonList.size() > 1) {
			// Serves as a reference to the current pokemon entered; the last two requests are the pokemon we are concerned about any any point in time.
			pokemonList.remove(0);
		}

		pokemonList.add(pokemon);

	}

}

class Pokemon {

	/*
	// Base Pokemon class of the selected pokemon, containing all the individual data returned from the API
	*/

	private String name, spriteUri;
	private int    index, attack, defense, hp, sp_atk, sp_def, speed, weight;

	Pokemon(String _name, String _spriteUri, int _index, int _attack, int _defense, int _hp, int _sp_atk, int _sp_def, int _speed, int _weight) {

		index      = _index;
		name       = _name;
	  spriteUri  = _spriteUri;
		attack     = _attack;
		defense    = _defense;
		hp         = _hp;
		sp_atk     = _sp_atk;
		sp_def     = _sp_def;
		speed      = _speed;
		weight     = _weight;

		this.drawSprites();
		this.drawStats();

	}

	void drawSprites() {

		/*
		// Functionality to draw the sprites using the sprite URL provided from the API sprite endpoint, draws the sprites relative to the GUI using properties of the mainGUI as well as using the index of the image for a y- position.
		*/

		PImage sprite;

		// load an individual sprite using the returned spriteURI for each pokemon
		sprite = loadImage("http://pokeapi.co/" + spriteUri);

		// draw the sprite at locations relative to the GUI dimensions
		image(sprite, 
			    mainGUI.loc.x + mainGUI.w + mainGUI.h,
		      mainGUI.loc.y * index, 
		      mainGUI.h, 
		      mainGUI.h
		     );

	}

	void drawStats() {

		/*
		// Functionality to draw the stats of the pokemon chosen
		*/

		int fontSize = 15;

		textSize(fontSize);
		text("Name: "      + name,      mainGUI.loc.x + mainGUI.w * 2, mainGUI.loc.y * index); 
		text("Attack: "    + attack,    mainGUI.loc.x + mainGUI.w * 2, mainGUI.loc.y * index + fontSize); 
		text("Defense: "   + defense,   mainGUI.loc.x + mainGUI.w * 2, mainGUI.loc.y * index + fontSize*2); 
		text("Speed: "     + speed,     mainGUI.loc.x + mainGUI.w * 2, mainGUI.loc.y * index + fontSize*3); 
		text("HP: "        + hp,        mainGUI.loc.x + mainGUI.w * 2, mainGUI.loc.y * index + fontSize*4); 

		text("Special Attack: "  + sp_atk, mainGUI.loc.x + mainGUI.w * 3, mainGUI.loc.y * index);
		text("Special Defense: " + sp_def, mainGUI.loc.x + mainGUI.w * 3, mainGUI.loc.y * index + fontSize); 
		text("Weight: "          + weight, mainGUI.loc.x + mainGUI.w * 3, mainGUI.loc.y * index + fontSize*2); 

	}

}