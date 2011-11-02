package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

public class RoutingManager {

	private NetworkRouter networkRouter;

	public RoutingManager(String routingMode) throws Exception {
		if (routingMode.equalsIgnoreCase("A"))
			this.networkRouter = new NetworkRouter_A();
		else
			throw new Exception(
					"invalid routing model. Unknown network routing model given.");
	}

	public List<PathSet> calculateRoutesFromNodes(List<Double> startNodes,
			Topology top, boolean isInsertPath) throws Exception {
		List<PathSet> pathSets = new ArrayList<PathSet>();
		if (startNodes == null) { // all nodes
			startNodes = new ArrayList<Double>();
			for (Node n : top.getAllNodes())
				startNodes.add(n.getLocation());
		}

		for (double startNode : startNodes) {
			pathSets.add(calculateRoutesFromNode(startNode, top, isInsertPath));
		}
		return pathSets;
	}

	private PathSet calculateRoutesFromNode(double startNode, Topology top, boolean isInsertPath)
			throws Exception {
		PathSet pathSet = new PathSet(top.findNode(startNode));
		pathSet.addPaths(this.networkRouter.findPaths(top, startNode, isInsertPath));
		return pathSet;
	}
}
