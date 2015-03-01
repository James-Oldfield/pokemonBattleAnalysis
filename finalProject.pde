import http.requests.*;

void setup() {
	GetRequest get = new GetRequest("http://pokeapi.co/api/v1/pokedex/1/");
	get.send();	
	println("Reponse Content: " + get.getContent());
println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
}

void draw() {
	
}