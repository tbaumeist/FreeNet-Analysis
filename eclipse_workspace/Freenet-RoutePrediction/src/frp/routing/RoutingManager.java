package frp.routing;

import java.util.ArrayList;
import java.util.List;

import frp.utils.Pair;

public class RoutingManager {

	private NetworkRouter networkRouter;
	private int maxHTL, resetHTL;

	private final int insertResetHop = 3;

	public RoutingManager(int maxHTL) {
		this.networkRouter = new NetworkRouter();
		this.maxHTL = maxHTL;
		this.resetHTL = this.maxHTL - this.insertResetHop;
	}
	
	public int getResetHTL(){
		return this.resetHTL;
	}

	public List<PathSet[]> calculateRoutesFromNodes(
			List<Pair<Double, String>> startNodes, Topology top,
			boolean isInsertPath) throws Exception {
		List<PathSet[]> pathSets = new ArrayList<PathSet[]>();
		startNodes = checkStartNodes(startNodes, top);

		for (Pair<Double, String> startNode : startNodes) {
			pathSets.add(calculateRoutesFromNode(startNode.getFirst(),
					startNode.getSecond(), top, isInsertPath));
		}
		return pathSets;
	}

	// public List<NodeIntersect> calculateNodeIntersects(int htl,
	// List<Pair<Double, String>> startNodes,
	// Topology top) throws Exception {
	//
	// startNodes = checkStartNodes(startNodes, top);
	// List<NodeIntersect> nodeIntersects = new ArrayList<NodeIntersect>();
	//
	// List<PathSet[]> pathInsertSets = calculateRoutesFromNodes(htl,
	// startNodes,
	// top, true);
	// List<PathSet[]> pathRequestSets = calculateRoutesFromNodes(htl,
	// startNodes,
	// top, false);
	//
	// for( PathSet[] psArray : pathInsertSets ){
	// for(PathSet ps : psArray)
	// {
	// nodeIntersects.add(new NodeIntersect(ps, pathRequestSets));
	// }
	// }
	//
	// return nodeIntersects;
	// }

	private List<Pair<Double, String>> checkStartNodes(
			List<Pair<Double, String>> startNodes, Topology top) {
		if (startNodes == null) { // all nodes
			startNodes = new ArrayList<Pair<Double, String>>();
			for (Node n : top.getAllNodes())
				startNodes.add(new Pair<Double, String>(n.getLocation(), n
						.getID()));
		}
		return startNodes;
	}

	private PathSet[] calculateRoutesFromNode(double startNode,
			String startNodeId, Topology top, boolean isInsertPath)
			throws Exception {
		PathSet[] pathSetByHTL = new PathSet[this.maxHTL];
		for (int i = 0; i < this.maxHTL; i++) {
			PathSet pathSet = new PathSet(top.findNode(startNode, startNodeId),
					i + 1);
			pathSet.addPaths(this.networkRouter.findPaths(this.resetHTL, i + 1,
					top, startNode, startNodeId, isInsertPath));
			pathSetByHTL[i] = pathSet;
		}
		return pathSetByHTL;
	}
}
