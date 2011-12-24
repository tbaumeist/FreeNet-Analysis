package pseudoRouting;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Node extends INode {

	private List<Node> neighbors = new CircleList<Node>();
	private final static String doublePrecision = "#.######";

	public Node(double loc, String id) {
		this.location = round(loc);
		this.id = id;
	}

	public void addNeighbor(Node node) {
		if (this.neighbors.contains(node))
			return;

		this.neighbors.add(node);
		Collections.sort(this.neighbors);
	}

	public void removeNeighbors(List<Node> nodes) {
		this.neighbors.removeAll(nodes);
	}

	public List<Node> getNeighbors() {
		return getNeighbors(null);
	}

	public List<Node> getNeighbors(List<Node> ignoreNodes) {
		List<Node> ns = new CircleList<Node>();
		ns.addAll(this.neighbors);

		if (ignoreNodes != null)
			ns.removeAll(ignoreNodes);

		return ns;
	}

	@Override
	public String toString() {
		return this.getLocation() + " {" + this.id + "}";
	}

	public List<RedirectRange> getPathsOut() {
		List<Node> ignoreNodes = new ArrayList<Node>();
		ignoreNodes.add(this);
		return getPathsOut(ignoreNodes, false);
	}

	public List<RedirectRange> getPathsOut(List<Node> ignoreNodes, boolean includeSelf) {
		List<_Node> allPeers = new CircleList<_Node>();
		List<Node> directPeers = getNeighbors(ignoreNodes);
		
		for (Node n : directPeers) {
			for (Node n2 : n.getNeighbors(ignoreNodes)) {
				if (!allPeers.contains(n2)) {
					allPeers.add(new _Node(n, n2.getLocation())); // peer's													// peers
				} else {
					allPeers.get(allPeers.indexOf(n2)).tie(); // increment tie counter
				}
			}
		}

		// direct peers get preference or peer of peer
		allPeers.removeAll(directPeers); // remove peer of peer entry
		for (Node n : directPeers) {
			allPeers.add(new _Node(n, n.getLocation()));
		}
		
		// add current node so it can detect when it is the closest
		if(includeSelf)
			allPeers.add(new _Node(this, this.getLocation()));

		Collections.sort(allPeers);

		// calculate the mid points
		for (int i = 0; i < allPeers.size(); i++) {
			allPeers.get(i).setMid(
					calcMid(allPeers.get(i).getLocation(), allPeers.get(i + 1)
							.getLocation()));
		}

		List<RedirectRange> rangesList = new CircleList<RedirectRange>();
		for (int i = 0; i < allPeers.size(); i++) {
			rangesList.add(new RedirectRange(allPeers.get(i).getNode(),
					allPeers.get(i - 1).getMid(), 
					allPeers.get(i).getMid(), 
					allPeers.get(i).getTieCount(), 
					allPeers.get(i).getNode() == this));
		}
		// buildRangeLists(rangesList, allPeers, 0);

		return rangesList;
	}

	private double calcMid(double locA, double locB) {
		// distance = (( next +1 ) - me) % 1
		double dist = ((locB + 1) - locA) % 1;
		// middle = (( distance/2 ) + me ) % 1
		return ((dist / 2.0) + locA) % 1;
	}

	// private void buildRangeLists(List<List<RedirectRange>> rangesList,
	// List<_Node> allPeers, int allPeersIndex) {
	// if (allPeersIndex >= allPeers.size())
	// return;
	//
	// if (rangesList.size() == 0)
	// rangesList.add(new CircleList<RedirectRange>());
	//
	// List<RedirectRange> currentList = rangesList.get(rangesList.size() - 1);
	// _Node currentNode = allPeers.get(allPeersIndex);
	//
	// for (int i = 0; i < currentNode.getNodes().size(); i++) {
	//
	// if (i > 0) {
	// List<RedirectRange> newRange = new CircleList<RedirectRange>();
	// newRange.addAll(currentList.subList(0, allPeersIndex));
	// rangesList.add(newRange);
	// currentList = rangesList.get(rangesList.size() - 1);
	// }
	// currentList.add(new RedirectRange(currentNode.getNodes().get(i),
	// allPeers.get(allPeersIndex - 1).getMid(), allPeers.get(
	// allPeersIndex).getMid()));
	// buildRangeLists(rangesList, allPeers, allPeersIndex + 1);
	// }
	// }

	public static double round(double d) {
		DecimalFormat twoDForm = new DecimalFormat(doublePrecision);
		return Double.valueOf(twoDForm.format(d));
	}

	private class _Node extends INode {
		private Node node;
		private double mid;
		private int ties = 0;

		public _Node(double l) {
			this.location = l;
			this.tie();
		}

		public _Node(Node n, double l) {
			this(l);
			this.node = n;
		}
		
		public void tie(){
			this.ties++;
		}
		
		public int getTieCount(){
			return this.ties;
		}

		public Node getNode() {
			return this.node;
		}

		public void setMid(double m) {
			this.mid = m;
		}

		public double getMid() {
			return this.mid;
		}

		@Override
		public String toString() {
			return this.getLocation() + " (" + this.getNode().getLocation()
					+ ")";
		}
	}
}
