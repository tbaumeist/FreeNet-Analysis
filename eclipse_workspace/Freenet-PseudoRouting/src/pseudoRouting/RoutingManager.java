package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

import pseudoRouting.Intersect.*;

public class RoutingManager {

	private NetworkRouter networkRouter;

	public RoutingManager(String routingMode) throws Exception {
		if (routingMode.equalsIgnoreCase("A"))
			this.networkRouter = new NetworkRouter_A();
		else
			throw new Exception(
					"invalid routing model. Unknown network routing model given.");
	}

	public List<PathSet> calculateRoutesFromNodes(int htl, List<Double> startNodes,
			Topology top, boolean isInsertPath) throws Exception {

		List<PathSet> pathSets = new ArrayList<PathSet>();
		startNodes = checkStartNodes(startNodes, top);

		for (double startNode : startNodes) {
			pathSets.add(calculateRoutesFromNode(htl, startNode, top, isInsertPath));
		}
		return pathSets;
	}

	public List<NodeIntersect> calculateNodeIntersects(int htl, List<Double> startNodes,
			Topology top) throws Exception {

		startNodes = checkStartNodes(startNodes, top);
		List<NodeIntersect> nodeIntersects = new ArrayList<NodeIntersect>();

		List<PathSet> pathInsertSets = calculateRoutesFromNodes(htl, startNodes,
				top, true);
		List<PathSet> pathRequestSets = calculateRoutesFromNodes(htl, startNodes,
				top, false);
		
		for( PathSet ps : pathInsertSets ){
			nodeIntersects.add(new NodeIntersect(ps, pathRequestSets));
		}

		return nodeIntersects;
	}

	private List<Double> checkStartNodes(List<Double> startNodes, Topology top) {
		if (startNodes == null) { // all nodes
			startNodes = new ArrayList<Double>();
			for (Node n : top.getAllNodes())
				startNodes.add(n.getLocation());
		}
		return startNodes;
	}

	private PathSet calculateRoutesFromNode(int htl, double startNode, Topology top,
			boolean isInsertPath) throws Exception {
		PathSet pathSet = new PathSet(top.findNode(startNode));
		pathSet.addPaths(this.networkRouter.findPaths(htl, top, startNode,
				isInsertPath));
		return pathSet;
	}
}
