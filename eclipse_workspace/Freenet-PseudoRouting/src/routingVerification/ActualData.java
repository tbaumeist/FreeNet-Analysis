package routingVerification;

import java.util.ArrayList;
import java.util.List;

public class ActualData {
	private String location, word, originNode;
	private List<String> nodes = new ArrayList<String>();
	
	public ActualData(String origin, String loc, String word, List<String> nodes){
		this.originNode = origin;
		this.location = loc;
		this.word = word;
		this.nodes.addAll(nodes);
	}
	
	public String getWord(){
		return this.word;
	}
	
	public String getOriginNode(){
		return this.originNode;
	}
	
	public String getLocation(){
		return this.location;
	}
	
	public List<String> getActualStorageNodes(){
		return this.nodes;
	}
	
	public String getActualStorageNodesToString(){
		String s = "";
		for(String n : this.nodes){
			s += n + " ";
		}
		return s;
	}
	
	@Override
	public String toString(){
		String s = this.location + " Org:" + this.originNode + " Word:"+ this.word;
		s += " "+ getActualStorageNodesToString();
		return s;
	}
}
