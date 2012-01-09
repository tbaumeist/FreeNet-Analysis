package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

public class Path implements Comparable<Object> {

	private List<RedirectRange> ranges = new ArrayList<RedirectRange>();
	private List<Integer> htls = new ArrayList<Integer>();
	private RedirectRange range = null;
	// private double preference = 0;
	private boolean successful = true;

	public void setSuccess(boolean b) {
		this.successful = b;
	}

	public boolean getSuccess() {
		return this.successful;
	}

	public void setRange(RedirectRange range) {
		this.range = range;
	}

	public RedirectRange getRange() {
		return this.range;
	}

	public void addNodeAsRR(RedirectRange r, int htl) {
		// if(this.nodes.contains(n))
		// return;
		this.ranges.add(r);
		this.htls.add(htl);
	}

	public void removeLastNode() {
		this.ranges.remove(this.ranges.size() - 1);
		this.htls.remove(this.htls.size() - 1);
	}

	public List<Node> getNodes() {
		List<Node> nodes = new CircleList<Node>();
		for (RedirectRange rr : this.ranges)
			nodes.add(rr.getNode());
		return nodes;
	}

	public Path clone() {
		Path p = new Path();
		p.ranges.addAll(this.ranges);
		p.htls.addAll(this.htls);
		p.range = this.range;
		return p;
	}

	public double getPathConfidence() {
		return 1.0 / (double) getTieCount();
	}

	public int getTieCount() {
		return getTieCountToNode(null);
	}

	public int getTieCountToNode(Node stopNode) {
		int tie = 0;
		int size = 0;
		for (RedirectRange rr : this.ranges) {
			tie += rr.getTieCount();
			size++;

			if (rr.getNode().equals(stopNode))
				break;
		}
		return tie - size + 1;
	}

	public Node getProbableStoreNode() {
		for (int i = 0; i < this.htls.size(); i++) {
			if (this.htls.get(i) == 1) // first node with htl of 1
				return this.ranges.get(i).getNode();
		}
		// There was no htl of 1 so just take the last node
		if (!this.htls.isEmpty())
			return this.ranges.get(this.ranges.size() - 1).getNode();

		return null;
	}

	public Node getStartNode() {
		if (this.ranges.isEmpty())
			return null;
		return this.ranges.get(0).getNode();
	}

	public boolean equalPath(Path cmp) {
		if (cmp == null)
			return false;
		if (this.getNodes().size() != cmp.getNodes().size())
			return false;
		for (int i = 0; i < this.getNodes().size(); i++) {
			if (!this.getNodes().get(i).getID().equals(
					cmp.getNodes().get(i).getID())) {
				return false;
			}
		}
		return true;
	}

	@Override
	public int compareTo(Object obj) {
		if (obj == null)
			return 1;
		if (!(obj instanceof Path))
			return 1;

		Path r = (Path) obj;
		return getRange().compareTo(r.getRange());
	}

	@Override
	public String toString() {
		String out = "";
		if (!getSuccess())
			out += "FAILED ";
		out += "| 1/" + getTieCount() + " " + 1.0 / getTieCount() + " | ";
		out += getRange() + " -> ";
		for (int i = 0; i < this.ranges.size(); i++) {
			out += this.ranges.get(i).getNode() + "(Tie="
					+ this.ranges.get(i).getTieCount() + ")(HTL="
					+ this.htls.get(i) + "), ";
		}

		return out;
	}

	public String toStringSimple() {
		String out = "";

		for (int i = 0; i < this.ranges.size(); i++) {
			out += this.ranges.get(i).getNode().getID() + ", ";
		}

		return out;
	}
}
