// http request library dependency 
import http.requests.*;
// controlP5 for GUI
import controlP5.*;

Request pokedexReq;
Pokedex pokedex;
GUI     mainGUI;

ControlP5 cp5;

void setup() {
	size(500, 500);
	background(0);

	cp5 = new ControlP5(this);

	// pokedexReq = Request.getInstance();
	// pokedex = new Pokedex(pokedexReq.returnPokedexData());

	mainGUI = new GUI();

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

}

class GUI {

	/*
	// GUI Class to instantiate the main home-screen GUI object, takes no parameters and is set up using pre-determined, hard-coded variables declared locally in the class
	*/

	String  poke1, poke2;
	PVector loc = new PVector(100, 100);

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
			.setPosition(loc.x, loc.y + h * 3)
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

	}

}