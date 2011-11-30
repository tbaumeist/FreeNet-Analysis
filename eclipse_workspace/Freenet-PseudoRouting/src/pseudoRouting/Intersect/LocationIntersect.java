package pseudoRouting.Intersect;

import java.util.*;


import pseudoRouting.*;

public class LocationIntersect {
	private Path insertPath;
	private Node insertionNode;
	private double confidence;
	private List<RequestNodeIntersect> requestNodes = new ArrayList<RequestNodeIntersect>();

	public LocationIntersect(Path insertPath, List<PathSet> pathRequestSets) {
		this.insertPath = insertPath;
		this.insertionNode = insertPath.getProbableStoreNode();
		this.confidence = 1.0 / insertPath.getTieCount() *.5;
		construct(pathRequestSets);
	}

	public List<RequestNodeIntersect> getRequestNodeIntersects() {
		return this.requestNodes;
	}

	public RedirectRange getRange() {
		return this.insertPath.getRange();
	}

	@Override
	public String toString() {
		String s = "Range: " + getRange() + ", Storage Node: "
				+ this.insertionNode;
		s += ", Confidence: " + this.confidence;
		s += ", Path: " + this.insertPath.toStringSimple();

		for (RequestNodeIntersect req : this.requestNodes) {
			s += "\n\t\t" + req;
		}
		
		if( this.requestNodes.isEmpty())
			s += "\n\t\tNo request paths found";

		return s;
	}

	private void construct(List<PathSet> pathRequestSets) {

		for (PathSet ps : pathRequestSets) {
			if (ps.getStartNode().equals(this.insertPath.getStartNode()))
				continue;
			if (ps.getStartNode().equals(this.insertionNode))
				continue;

			for (Path p : ps.getPaths()) {
				List<Node> nodes = p.getNodes();
				if (!nodes.contains(this.insertionNode))
					continue;
				if (!getRange().overlaps(p.getRange()))
					continue;
				if (!hasTargetNodes(this.insertPath, p, this.insertionNode))
					continue;
				if (!isUniquePath(this.insertPath, p, this.insertionNode))
					continue;
				
				this.requestNodes.add(new RequestNodeIntersect(this.insertPath, p, this.insertionNode));
			}
		}
		Collections.sort(this.requestNodes);
	}
	
	private boolean hasTargetNodes(Path insertPath, Path requestPath, Node intersect){
		List<Node> nodes = requestPath.getNodes();
		if(nodes.size() <= 2)
			return false;
		if(nodes.get(1).equals(intersect))
			return false;
		return true;
	}
	
	private boolean isUniquePath(Path insertPath, Path requestPath, Node intersect){
		for (Node n : requestPath.getNodes()){
			if( n.equals(intersect))
				return true;
			
			if( insertPath.getNodes().contains(n))
				return false;
		}
		return true;
	}
}
