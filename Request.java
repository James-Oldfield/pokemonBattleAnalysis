public class Request {

	String test;


	// The privacy of this object ensures it can only be instantiated from the Request class
	// holds the single instance of the class to prevent multiple hits to the API - static to allow it global scope
	private static Request instance = null;

	// The constructor is created as Private so that there cannot be any instantiations of the class other than the singleton.
	private Request() {
		test = "hello i am a test";
	}

	public static Request getInstance() {
		if (instance == null) {
			// Lazy instantiation - Only being created if it is needed and getInstance method is called
			instance = new Request();
		}

		// By now, the instance object will always be in the instantiation of the Request class via the Singleton pattern.
		return instance;
	}

	public void showMessage() {
		System.out.println(test);
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