package routingVerification;

import java.util.ArrayList;
import java.util.List;

public class ActualPathSet {
	private String startLocation;
	private List<ActualPath> paths = new ArrayList<ActualPath>();
	
	public ActualPathSet(String location){
		this.startLocation = location;
	}
	
	public void addPath(ActualPath path){
		this.paths.add(path);
	}
	
	public String getStartNode(){
		return this.startLocation;
	}
	
	public List<ActualPath> getPaths(){
		return this.paths;
	}
	
	@Override
	public String toString() {
		String s = "Start Node " + this.startLocation + "\n";
		for (ActualPath p : this.paths) {
			s += p+"\n\n";
		}
		return s;
	}
}
