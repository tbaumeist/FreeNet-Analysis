package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

public class PathSet {
	private Node startNode;
	private List<Path> paths = new ArrayList<Path>();
	
	public PathSet(Node start){
		this.startNode = start;
	}
	
	public void addPath(Path p){
		this.paths.add(p);
	}
	
	public void addPaths(List<Path> paths){
		this.paths.addAll(paths);
	}
	
	public Node getStartNode(){
		return this.startNode;
	}
	
	public List<Path> getPaths(){
		return this.paths;
	}
	
	@Override
	public String toString() {
		String s = "Paths from " + this.startNode + "\n";
		for (Path p : this.paths) {
			s += p+"\n";
		}
		return s;
	}
}
