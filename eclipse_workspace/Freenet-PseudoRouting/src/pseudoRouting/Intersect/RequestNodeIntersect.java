package pseudoRouting.Intersect;

import java.util.*;

import pseudoRouting.*;

public class RequestNodeIntersect {
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
		String s = "Range: " + this.intersectionRange + ", Request Node: " + getRequestNode();
		s += ", Path: " + this.requestPath.toStringSimple();
		s += ", Target Nodes: {";
		for (Node n : this.possibleAttackNodes) {
			s += n + ", ";
		}

		s += "}, Confidence: " + this.confidence;

		return s;
	}
}
