package routingVerification;

import java.util.ArrayList;
import java.util.List;

public class ActualData {
	private String location, word;
	private List<String> nodes = new ArrayList<String>();
	
	public ActualData(String loc, String word, List<String> nodes){
		this.location = loc;
		this.word = word;
		this.nodes.addAll(nodes);
	}
	
	public String getLocation(){
		return this.location;
	}
	
	public List<String> getNodes(){
		return this.nodes;
	}
	
	@Override
	public String toString(){
		String s = this.location + " " + this.word;
		for(String n : this.nodes){
			s += " " + n;
		}
		return s;
	}
}
