package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

public class RedirectRange implements Comparable<Object> {

	private Node toNode;
	private double rangeStart, rangeStop;
	private boolean isRetry = false;
	private int tieCount = 0;

	public RedirectRange(Node toNode, double rangeStart, double rangeStop, int tieCount){
		this(toNode, rangeStart, rangeStop);
		this.tieCount = tieCount;
	}
	public RedirectRange(Node toNode, double rangeStart, double rangeStop) {
		this.toNode = toNode;
		this.rangeStart = Node.round(rangeStart);
		this.rangeStop = Node.round(rangeStop);
		this.tieCount++;
	}

	public Node getNode() {
		return this.toNode;
	}

	public double getStart() {
		return this.rangeStart;
	}
	
	public int getTieCount(){
		return this.tieCount;
	}

	public boolean getIsRetry() {
		return this.isRetry;
	}

	public void setIsRetry(boolean b) {
		this.isRetry = b;
	}

	public double getStop() {
		return this.rangeStop;
	}

	public boolean containsPoint(double pt) {
		if (!wrapsAround())
			return this.rangeStart <= pt && pt < this.rangeStop;
		return this.rangeStart <= pt || pt < this.rangeStop;
	}

	public boolean overlaps(RedirectRange range) {
		if (range == null)
			return false;

		if (!edgesOverlap(this, range).isEmpty())
			return true;
		if (!edgesOverlap(range, this).isEmpty())
			return true;

		return false;
	}

	public boolean isEntireRange() {
		return this.rangeStart == this.rangeStop;
	}

	public List<RedirectRange> splitRangeOverMe(RedirectRange range) {
		List<RedirectRange> ranges = new ArrayList<RedirectRange>();

		if (range.isEntireRange()) { // special case
			ranges.add(new RedirectRange(range.getNode(), this.rangeStart,
					this.rangeStop, range.tieCount));
			return ranges;
		}

		List<Double> edges = edgesOverlap(this, range);
		edges.remove(range.rangeStart);
		edges.remove(range.rangeStop);

		double prev = range.rangeStart;
		for (double d : edges) {
			ranges.add(new RedirectRange(range.getNode(), prev, d, range.tieCount));
			prev = d;
		}
		ranges.add(new RedirectRange(range.getNode(), prev, range.rangeStop, range.tieCount));

		return ranges;
	}

	@Override
	public String toString() {
		return "[ " + this.rangeStart + ", " + this.rangeStop + " )";
	}

	@Override
	public int compareTo(Object obj) {
		if (obj == null)
			return 1;
		if (!(obj instanceof RedirectRange))
			return 1;

		RedirectRange r = (RedirectRange) obj;
		return new Double(this.rangeStart).compareTo(new Double(r.rangeStart));
	}

	private List<Double> edgesOverlap(RedirectRange r1, RedirectRange r2) {
		List<Double> overlaps = new ArrayList<Double>();
		if (r1.wrapsAround() && r2.wrapsAround()) {
			if (r1.rangeStart >= r2.rangeStart
					&& r1.rangeStart < r2.rangeStop + 1)
				overlaps.add(r1.rangeStart); // r1 front is in r2 ranges
			if (r1.rangeStop + 1 > r2.rangeStart
					&& r1.rangeStop <= r2.rangeStop)
				overlaps.add(r1.rangeStop); // r1 end is in r2 ranges
		} else if (r2.wrapsAround()) {
			if (r1.rangeStart >= r2.rangeStart || r1.rangeStart < r2.rangeStop)
				overlaps.add(r1.rangeStart); // r1 front is in r2 ranges
			if (r1.rangeStop > r2.rangeStart || r1.rangeStop <= r2.rangeStop)
				overlaps.add(r1.rangeStop); // r1 end is in r2 ranges
		} else {
			// normal conditions
			if (r1.rangeStart >= r2.rangeStart && r1.rangeStart < r2.rangeStop)
				overlaps.add(r1.rangeStart); // r1 front is in r2 ranges
			if (r1.rangeStop > r2.rangeStart && r1.rangeStop <= r2.rangeStop)
				overlaps.add(r1.rangeStop); // r1 end is in r2 ranges
		}
		return overlaps;
	}

	private boolean wrapsAround() {
		return this.rangeStart >= this.rangeStop;
	}

}
