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

	public List<PathSet[]> calculateRoutesFromNodes(int htl, List<Pair<Double, String>> startNodes,
			Topology top, boolean isInsertPath) throws Exception {
		List<PathSet[]> pathSets = new ArrayList<PathSet[]>();
		startNodes = checkStartNodes(startNodes, top);

		for (Pair<Double, String> startNode : startNodes) {
			pathSets.add(calculateRoutesFromNode(htl, startNode.getFirst(), startNode.getSecond(), top, isInsertPath));
		}
		return pathSets;
	}

	public List<NodeIntersect> calculateNodeIntersects(int htl, List<Pair<Double, String>> startNodes,
			Topology top) throws Exception {

		startNodes = checkStartNodes(startNodes, top);
		List<NodeIntersect> nodeIntersects = new ArrayList<NodeIntersect>();

		List<PathSet[]> pathInsertSets = calculateRoutesFromNodes(htl, startNodes,
				top, true);
		List<PathSet[]> pathRequestSets = calculateRoutesFromNodes(htl, startNodes,
				top, false);
		
		for( PathSet[] psArray : pathInsertSets ){
			for(PathSet ps : psArray)
			{
				nodeIntersects.add(new NodeIntersect(ps, pathRequestSets));
			}
		}

		return nodeIntersects;
	}

	private List<Pair<Double, String>> checkStartNodes(List<Pair<Double, String>> startNodes, Topology top) {
		if (startNodes == null) { // all nodes
			startNodes = new ArrayList<Pair<Double, String>>();
			for (Node n : top.getAllNodes())
				startNodes.add(new Pair<Double, String>(n.getLocation(), n.getID()));
		}
		return startNodes;
	}

	private PathSet[] calculateRoutesFromNode(int htl, double startNode, String startNodeId, Topology top,
			boolean isInsertPath) throws Exception {
		PathSet[] pathSetByHTL = new PathSet[htl];
		for(int i= 0; i < htl; i++)
		{
			PathSet pathSet = new PathSet(top.findNode(startNode, startNodeId), i+1);
			pathSet.addPaths(this.networkRouter.findPaths(htl, i+1, top, startNode, startNodeId,
				isInsertPath));
			pathSetByHTL[i] = pathSet;
		}
		return pathSetByHTL;
	}
}
