// http request library dependency 
import http.requests.*;

Request pokedex;
Request james;

void setup() {
	// pokedex = new Request("pokedex/1/");
	pokedex = new Request();
	println(pokedex.getInstance());

	james = new Request();
	println(james.getInstance());
}

void draw() {
	
}

// Declared as static as each Processing sketch is a top level Java class, extending the PApplet. 
public class Request {

	String test;

	private Request() {
		// REQUEST object functionality upon instantiation here
		test = "hello i am a test";
	}

	// The privacy of this class ensures it can only be instantiated from the Request class
	private static class Singleton {
		// holds the single instance of the class to prevent multiple hits to the API - static to allow it global scope
		// Lazy instantiation - Only being created if it is needed 
		private static final Request instance = new Request();
	}

	public static Request getInstance() {
		// Singleton.instance serves as a reference to the Request object instantiated with a singleton pattern.
		return Singleton.instance;
	}

	// String uri;

	// Request(String _uri) {
	// 	uri = _uri;

	// 	// Hit the API at the endpoint specified by the constructor argument
	// 	GetRequest g = new GetRequest("http://pokeapi.co/api/v1/" + uri);
	// 	g.send();

	// 	println("Response Content: " + g.getContent());
	// }

	// HashMap hitApi(  ) {
	// }

}