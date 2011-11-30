package pseudoRouting.Intersect;

import java.util.*;

import pseudoRouting.*;

public class RequestNodeIntersect implements Comparable<Object> {
	private Path requestPath;
	private double confidence;
	private RedirectRange intersectionRange;
	private List<Node> possibleAttackNodes = new ArrayList<Node>();

	public RequestNodeIntersect(Path insertPath, Path requestPath,
			Node intersectNode) {
		this.requestPath = requestPath;
		this.confidence = (1.0 / insertPath.getTieCount() * .5)
				* (1.0 / requestPath.getTieCountToNode(intersectNode));
		this.intersectionRange = requestPath.getRange().getIntersection(insertPath.getRange());
		for (Node n : requestPath.getNodes()) {
			if (n.equals(intersectNode))
				break;
			if (n.equals(getRequestNode()))
				continue;
			this.possibleAttackNodes.add(n);
		}
	}

	public Node getRequestNode() {
		return this.requestPath.getStartNode();
	}

	public List<Node> getPossibleAttackNodes() {
		return this.possibleAttackNodes;
	}

	@Override
	public String toString() {
		String s = "Intersect Range: " + this.intersectionRange + ", Request Node: " + getRequestNode();
		s += ", Request Range: " + this.requestPath.getRange();
		s += ", Path: " + this.requestPath.toStringSimple();
		s += ", Target Nodes: {";
		for (Node n : this.possibleAttackNodes) {
			s += n + ", ";
		}

		s += "}, Confidence: " + this.confidence;

		return s;
	}
	

	@Override
	public int compareTo(Object obj) {
		if (obj == null)
			return 1;
		if (!(obj instanceof RequestNodeIntersect))
			return 1;

		RequestNodeIntersect node = (RequestNodeIntersect) obj;
		return new Double(node.confidence).compareTo(new Double(this.confidence));
	}
}
