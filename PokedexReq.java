/*
// Java class implemented using a Singleton design pattern to ensure only ever one instantiation of the class can be made to prevent multiple HTTP requests which would have a detrimental effect on the API limit.
*/

// Using the same library as main Processing sketch to take the pain out of HTTP requests
import http.requests.*;

public class PokedexReq {

	String uri;

	// holds the single instance of the class to prevent multiple hits to the API - static to allow it global scope
	private static PokedexReq instance = null;

	// The constructor is created as Private so that there cannot be any instantiations of the class other than the singleton.
	private PokedexReq() {
		// Hit the pokedex endpoint, returning a list of all data on the database as a reference point for further requests
		uri = "pokedex/1";
	}

	public static PokedexReq getInstance() {

		/*
		// Public method which is used for the singleton pattern instantiation
		// 
		// @return PokedexReq - Returns the singleton-Request object which serves as a reference.
		*/

		if (instance == null) {
			// Lazy instantiation - Only being created if it is needed and getInstance method is called
			instance = new PokedexReq();
		}

		// By now, the instance object will always be in the instantiation of the Request class via the Singleton pattern.
		return instance;
	}

	public String returnPokedexData() throws Exception {

		/*
		// Method to return the JSON-formatted string containing all the data of every Pokemon in the Pokedex from the http request.
		//
		// @return String - Returns a string in JSON-format of the pokedex data.
		*/

		final GetRequest g;

		g = new GetRequest("http://pokeapi.co/api/v1/" + uri);
		g.send();

		// the getContent method innate to the http request library returns the content as a String, so needs to be converted to a JSONObject in Processing
		String pokedexData = g.getContent();

		// return the string containing the whole Pokedex data
		return pokedexData;
	}

}