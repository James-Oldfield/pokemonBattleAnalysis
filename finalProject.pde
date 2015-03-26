/*
 * PROGRAM REQUIRES INTERNET CONNECTION
 * Example pokemon to enter: "charizard", "blastoise", "dragonite"
 * REMOTE: https://github.com/James-Oldfield/pokemonBattleAnalysis
*/

// http request library dependency 
import http.requests.*;
// controlP5 for GUI
import controlP5.*;

PokedexReq pokedexReq; // Singleton object
Pokedex    pokedex; // pokedex containing all pokemon 
HomeScreen homeScreen; // home screen object

MainGUI mainGUI; // main GUI for searching

ArrayList<Pokemon>      pokemonList       = new ArrayList<Pokemon>(); // Holds the Pokemon objects of the two pokemon being compared
ArrayList<Request>      requestsList      = new ArrayList<Request>(); // Polymorphic Arraylist to serve reference to every type of request
ArrayList<PokemonView>  pokemonViewsList  = new ArrayList<PokemonView>(); // Holds the pokemonview objects
HashMap<String,Boolean> programStates     = new HashMap<String,Boolean>(); // HashMap to hold Booleans of program states

ControlP5 mainCtrl, homeCtrl, pDexCtrl, searchCtrl;

void setup() {
	size(1000, 500);
	background(0);

	// instantiate the singleton object for main request
	pokedexReq  = PokedexReq.getInstance();
	tryHttpRequest();

	// initialise the homeScreen state
	programStates.put("homeScreen", true); // holds the state of the home screen view
	programStates.put("mainScreen", false); // holds the state of the main GUI view
	programStates.put("beenDrawn", false); // prevents drawing every frame to free up consumption 
	programStates.put("pokemonView", false); // holds the view of the individual pokemon

	homeCtrl   = new ControlP5(this);
	homeScreen = new HomeScreen();
	homeCtrl.setAutoDraw(false);

	pDexCtrl = new ControlP5(this);
	pDexCtrl.setAutoDraw(false);
	searchCtrl = new ControlP5(this);
	searchCtrl.setAutoDraw(false);

	mainCtrl = new ControlP5(this);
	mainGUI  = new MainGUI();
	mainCtrl.setAutoDraw(false);

}

void draw() {

	if (programStates.get("homeScreen")) {
		homeScreen.display();
	} else if (programStates.get("mainScreen")) {
		mainGUI.display();
	} else if (programStates.get("pokemonView")) {
		for (PokemonView v : pokemonViewsList) {
			v.display();
		}
	}

	// find a random string to use
	String rndmString = mainGUI.suffixList.get( (int)random(mainGUI.suffixList.size()) );

	// if there has been two pokemon entered for comparison, the comparisons can take place
	if (pokemonList.size() == 2) {

		if (!programStates.get("beenDrawn")) {
			// draw stats and sprites
			for (Pokemon p : pokemonList) {
				p.drawStats();
				p.drawSprites();
			}

			if (mainGUI.p0Score > mainGUI.p1Score) {
				text(pokemonList.get(0).name + rndmString + pokemonList.get(1).name, 400, 400, 400, 400);
			} else if (mainGUI.p0Score == mainGUI.p1Score) {
				text(pokemonList.get(1).name + " is pretty evenly matched against " + pokemonList.get(0).name, 400, 400, 400, 400);
			} else {
				text(pokemonList.get(1).name + rndmString + pokemonList.get(0).name, 400, 400, 400, 400);
			}
			
		}

		programStates.put("beenDrawn", true);
	}
}

void mousePressed() {

	/*
	 * Top-level mouse pressed innate method to trigger Pokemon class's one
  */

	// so long as there's the search been made
	if (pokemonList.size() == 2) {
	  for (Pokemon p : pokemonList) {
	  	// if there is a pokemon clicked, else returns null
	  	if (!(p.clickedSprite() == null)) {
	  		PokemonView pokeView = new PokemonView(p); // create a new pokemon view from the clicked object
	  		pokemonViewsList.add(pokeView);

				programStates.put("mainScreen", false); // make the pokemonView boolean in programStates hashMap true to draw it
				programStates.put("pokemonView", true); // make the pokemonView boolean in programStates hashMap true to draw it
	  	}
	  }
	}

	// listener for when pokedex view is open 
	if (
		// if clicked on the cross when this state is also true
		programStates.get("pokemonView") &&
		mouseX > mainGUI.loc.x && 
		mouseX < mainGUI.loc.x+25 &&
		mouseY > mainGUI.loc.y &&
		mouseY < mainGUI.loc.y+25
		) {
		// change states back to mainGUI
		background(0);
		programStates.put("mainScreen", true);
		programStates.put("beenDrawn", false);
		programStates.put("pokemonView", false);
	}

}

void tryHttpRequest() {

	/*
	 * Functionality with error handling to hit the API of the singleton object, prints out the error if exception if thrown
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
		 * Method to search through the pokedex JSONObject returned from the initial HTTPRequest.
		 *
		 * @return String     - Either the desired URI needed for the requested pokemon, or the error message on no match.
		 * @param desiredName - The String name of the Pokemon that is used as a search string to find the right JSONObject for which to return the uri.
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

class HomeScreen {

	private PVector cntr = new PVector(width/2, height/2);
	private PImage homeBGImage;

	HomeScreen () {
		homeBGImage = loadImage("homeScreen.jpg");

		this.addControls();
	}

	void addControls () {
		// Add enter button
		homeCtrl.addBang("enter")
			.setPosition(cntr.x+30, cntr.y+100)
			.setSize(200, 50)
			// plug to references the current class, rather than the default sketch extending PApplet
			.plugTo(this, "enter")
			.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
	}

	void display () {
		image(homeBGImage, 0,0,width,height);
		homeCtrl.draw();
	}

	void enter () {

		/*
		 * enter function is called when the enter button is pressed, as this is plugged using the plugTo method of the controlp5 class
		*/

		background(0);

		// alter program states
		programStates.put("homeScreen", false);
		programStates.put("mainScreen", true);

	}
}

class MainGUI {

	/*
	 * GUI Class to instantiate the main home-screen GUI object, takes no parameters and is set up using pre-determined, hard-coded variables declared locally in the class
	*/

	private String       poke1Name, poke2Name;
	private PokeRequest  poke1Obj,  poke2Obj;
	private boolean      pDexMode = false;
	private DropdownList poke1DropDown, poke2DropDown;

	private ArrayList<String> suffixList = new ArrayList<String>(); // Holds the words to show in front of the comparison
	private int p0Score=0, p1Score=0; // ints used to track how many better stats each pokemon has
	private PVector loc = new PVector(50, 75); // used for positioning of the GUI objects
	private int h = 100, 
              w = 200;

	MainGUI() {
		this.addControls();

		// populate suffix string arrayList
		suffixList.add(" kicks the ass of ");
		suffixList.add(" makes easy work of ");
	}

	void addControls() {
	// ADD ALL THE CONTROLS
		mainCtrl.addBang("submit")
		// Add submit button
				.setPosition(loc.x, loc.y + h * 3)
				.setSize(w/2, h/2)
				.plugTo(this, "submit") // plugTo acts kind of like a callback function on click, using this in the context of this class, supposed to the top level main sketch class
				.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);    

		mainCtrl.addBang("toggle search mode")
		// add search toggles
				.setPosition(loc.x, loc.y-50)
				.setSize(w, h/4)
				.plugTo(this, "toggleSearchMode")
				.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);   

 		poke1DropDown = pDexCtrl.addDropdownList("poke1")
	 		.setPosition(loc.x, loc.y)
			.setLabel("select pokemon 1")
			.setSize(w, h);
    poke2DropDown = pDexCtrl.addDropdownList("poke2")
			.setPosition(loc.x, loc.y + h*1.5)
			.setLabel("select pokemon 2")
			.setSize(w, h);

    populateDropdowns(poke1DropDown, poke2DropDown);

		// add pokemon 1 field
			searchCtrl.addTextfield("poke1")
				.setPosition(loc.x, loc.y)
				.setSize(w, h)
				.setFont(createFont("helvetica",30))
				.setLabel("enter pokemon 1")
				.setAutoClear(false);

		// add pokemon 2 field
			searchCtrl.addTextfield("poke2")
				.setPosition(loc.x, loc.y + h*1.5)
				.setSize(w, h)
				.setFont(createFont("helvetica",30))
				.setLabel("enter pokemon 2")
				.setAutoClear(false);
	}

	void populateDropdowns(DropdownList poke1DropDown, DropdownList poke2DropDown) {

		 /*
		  * Function to populate each dropdown with the pokedex's pokemon, using a forloop generated from the fields present in the class
		 */

		for(int i = 0; i < pokedex.pokedexArray.size(); i++) {
			JSONObject index = pokedex.pokedexArray.getJSONObject(i);
			String nameFound = index.getString("name");

			poke1DropDown.addItem(nameFound, i);
			poke2DropDown.addItem(nameFound, i);
		}

	}

	void toggleSearchMode() {

		/*
		 * Function plugged to the toggle search button, which will change the boolean state of the mainGUI
		*/

		pDexMode = !pDexMode;
	}

	void display() {

		/*
		 * Functionality to display the GUI by creating the features
		*/

		fill(0);
		rect(loc.x-10, loc.y-10, w+10, height);
		mainCtrl.draw();

		if (!this.pDexMode) {
			searchCtrl.draw();
		} else if (this.pDexMode) {
			pDexCtrl.draw();
		}

	}

	void submit() {

	/*
	 * Functionality to take place upon the submit button being pressed
	*/

		println("yo submit button!");
		println("sending http request, hold tight...");

		// drawing background to remove previous sprites etc
		background(0);

		// work out which mode is selected
		if (!this.pDexMode) {
			// Pass the entered text into the findPokemon method, and store the returning uri String object in poke1 and poke2 respectively. 
			poke1Name = pokedex.findPokemon(searchCtrl.get(Textfield.class,"poke1").getText());
			poke2Name = pokedex.findPokemon(searchCtrl.get(Textfield.class,"poke2").getText());
		} else if (this.pDexMode) {
			// find names from dropdown
			poke1Name = pokedex.findPokemon(poke1DropDown.item((int)poke1DropDown.getValue()).getName());
			poke2Name = pokedex.findPokemon(poke2DropDown.item((int)poke2DropDown.getValue()).getName());
		}

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

		programStates.put("beenDrawn", false);

		p0Score = 0; 
		p1Score = 0; // Clear the scores

	// STAT COMPARISON FUNCTIONALITY
		// pass both pokemon into the comparison function
		HashMap statComparison = compareStats(pokemonList.get(0), pokemonList.get(1));

		// comparison to check the best stats, weight not included as irrelevant 
		if (Integer.parseInt(statComparison.get("attack").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("attack").toString()) == 2) {} else { p1Score ++; }
		if (Integer.parseInt(statComparison.get("defense").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("defense").toString()) == 2) {} else { p1Score ++; }
		if (Integer.parseInt(statComparison.get("hp").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("hp").toString()) == 2) {} else { p1Score ++; }
		if (Integer.parseInt(statComparison.get("sp_atk").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("sp_atk").toString()) == 2) {} else { p1Score ++; }
		if (Integer.parseInt(statComparison.get("sp_def").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("sp_def").toString()) == 2) {} else { p1Score ++; }
		if (Integer.parseInt(statComparison.get("speed").toString()) == 0) { p0Score ++; } else if (Integer.parseInt(statComparison.get("speed").toString()) == 2) {} else { p1Score ++; }

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
		} else if (p0.attack == p1.attack) { 
			bestStats.put("attack", 2);
		} else {
			bestStats.put("attack", 1);	
		}
		// DEFENSE
		if (p0.defense > p1.defense) { 
			bestStats.put("defense", 0); 
		} else if (p0.defense == p1.defense) { 
			bestStats.put("defense", 2);
		} else {
			bestStats.put("defense", 1);	
		}
		// hp
		if (p0.hp > p1.hp) { 
			bestStats.put("hp", 0); 
		} else if (p0.hp == p1.hp) { 
			bestStats.put("hp", 2);
		} else {
			bestStats.put("hp", 1);	
		}
		// sp_atk
		if (p0.sp_atk > p1.sp_atk) { 
			bestStats.put("sp_atk", 0); 
		} else if (p0.sp_atk == p1.sp_atk) { 
			bestStats.put("sp_atk", 2);
		} else {
			bestStats.put("sp_atk", 1);	
		}
		// sp_def
		if (p0.sp_def > p1.sp_def) { 
			bestStats.put("sp_def", 0); 
		} else if (p0.sp_def == p1.sp_def) { 
			bestStats.put("sp_def", 2);
		} else {
			bestStats.put("sp_def", 1);	
		}
		// speed
		if (p0.speed > p1.speed) { 
			bestStats.put("speed", 0); 
		} else if (p0.speed == p1.speed) { 
			bestStats.put("speed", 2);
		} else {
			bestStats.put("speed", 1);	
		}

		// return the HashMap object with containing the String of the stat and the highest stat
		return bestStats;

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
	 * Extending the basic request class, this class also hits the Sprite endpoint of the given pokemon
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
		 * Functionality to create Sprite requests for this pokemon JSONObject returned, as the Sprite endpoint is different to the Pokemon one
		*/

		// Find the String containing the Sprite URI from the JSONArray and containing JSONObkect  
		spriteJSON = pokemonData.getJSONArray("sprites").getJSONObject(0).getString("resource_uri");

		// returns the sprite object for the specified pokemon
		spriteUri  = this.returnPokemonData(spriteJSON).getString("image");

		// callback function to create a pokemon object from the data returned
		Pokemon pokemon = new Pokemon(pokemonData, index, spriteUri);

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
	 * Base Pokemon class of the selected pokemon, containing all the individual data returned from the API
	*/

	private String name, spriteUri, species;
	private int    index, attack, defense, hp, sp_atk, sp_def, speed, weight, national_id, catch_rate;
	private float  posX, posY, h;
	private PImage sprite;

	Pokemon(JSONObject pokemonData, int _index, String _spriteUri) {

		index       = _index;
		spriteUri   = _spriteUri;
		name        = pokemonData.getString("name");
		species     = pokemonData.getString("species");
		attack      = pokemonData.getInt("attack");
		defense     = pokemonData.getInt("defense");
		hp          = pokemonData.getInt("hp");
		sp_atk      = pokemonData.getInt("sp_atk");
		sp_def      = pokemonData.getInt("sp_def");
		speed       = pokemonData.getInt("speed");
		weight      = pokemonData.getInt("weight");
		national_id = pokemonData.getInt("national_id");
		catch_rate  = pokemonData.getInt("catch_rate");

		println(name);
		println(species);
		println(species.getClass());

		// populate fields if empty
		if(species.isEmpty()) { species = "none specified";	}

		// load an individual sprite using the returned spriteURI for each pokemon
		sprite = loadImage("http://pokeapi.co/" + spriteUri);

	}

	void drawSprites() {

		/*
		 * Functionality to draw the sprites using the sprite URL provided from the API sprite endpoint, draws the sprites relative to the GUI using properties of the mainGUI as well as using the index of the image for a y- position.
		*/

		posX = mainGUI.loc.x + mainGUI.w + mainGUI.h;
		posY = mainGUI.loc.y + (index + (mainGUI.h/2 * (index-1) * 3));
		h    = mainGUI.h;

		// draw the sprite at locations relative to the GUI dimensions
		image(sprite, posX, posY, h, h);

	}

	void drawStats() {

		/*
		 * Functionality to draw the stats of the pokemon chosen
		*/

		int fontSize = 15;

		PFont h = createFont("Helvetica", fontSize);

	  textFont(h);

	  fill(255);

		text("Name: "      + name,      mainGUI.loc.x + mainGUI.w * 2.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15)); 
		text("Attack: "    + attack,    mainGUI.loc.x + mainGUI.w * 2.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize); 
		text("Defense: "   + defense,   mainGUI.loc.x + mainGUI.w * 2.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize*2); 
		text("Speed: "     + speed,     mainGUI.loc.x + mainGUI.w * 2.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize*3); 
		text("HP: "        + hp,        mainGUI.loc.x + mainGUI.w * 2.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize*4); 

		text("Special Attack: "  + sp_atk, mainGUI.loc.x + mainGUI.w * 3.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15));
		text("Special Defense: " + sp_def, mainGUI.loc.x + mainGUI.w * 3.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize); 
		text("Weight: "          + weight, mainGUI.loc.x + mainGUI.w * 3.5, mainGUI.loc.y * (index-1) + (mainGUI.loc.y * (index) + index*15) + fontSize*2); 

	}

	Pokemon clickedSprite() {

		/*
		 * Method to check if the mouse has been clicked on each object
		*/

		if (mouseX > posX && mouseX < posX+h && mouseY > posY && mouseY < posY+h) {
			// return the pokemon object
			return this;
		} else {
			return null;
		}

	}

}

class PokemonView {

	private Pokemon p;
	private PImage cross;

	PokemonView(Pokemon _p) {
		p = _p;
		cross = loadImage("cross.png");
	}

	void display () {
		background(0);

		fill(255);
		text("name: " + p.name, mainGUI.loc.x + 300, mainGUI.loc.y);
		text("species: " + p.species, mainGUI.loc.x + 300, mainGUI.loc.y+20);
		text("attack: " + p.attack, mainGUI.loc.x + 300, mainGUI.loc.y+40);
		text("defense: " + p.defense, mainGUI.loc.x + 300, mainGUI.loc.y+60);
		text("hp: " + p.hp, mainGUI.loc.x + 300, mainGUI.loc.y+80);
		text("special attack: " + p.sp_atk, mainGUI.loc.x + 300, mainGUI.loc.y+100);
		text("special defense: " + p.sp_def, mainGUI.loc.x + 300, mainGUI.loc.y+120);
		text("speed: " + p.speed, mainGUI.loc.x + 300, mainGUI.loc.y+140);
		text("weight: " + p.weight, mainGUI.loc.x + 300, mainGUI.loc.y+160);
		text("national pokedex ID: " + p.national_id, mainGUI.loc.x + 300, mainGUI.loc.y+180);
		text("catch rate: " + p.catch_rate, mainGUI.loc.x + 300, mainGUI.loc.y+200);

		image(cross, mainGUI.loc.x, mainGUI.loc.y, 25, 25);
		image(p.sprite, mainGUI.loc.x+50, mainGUI.loc.y+50, 200, 200);
	}

}