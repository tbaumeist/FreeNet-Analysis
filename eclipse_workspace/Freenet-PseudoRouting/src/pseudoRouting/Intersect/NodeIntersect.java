package pseudoRouting.Intersect;

import java.util.ArrayList;
import java.util.List;

import pseudoRouting.*;

public class NodeIntersect {
	private Node node;
	private List<LocationIntersect> locIntersects = new ArrayList<LocationIntersect>();

	public NodeIntersect(PathSet pathInsertSet, List<PathSet[]> pathRequestSets) {
		this.node = pathInsertSet.getStartNode();

		for (Path p : pathInsertSet.getPaths()) {
			this.locIntersects.add(new LocationIntersect(p, pathRequestSets));
		}
	}

	public List<LocationIntersect> getLocationIntersects() {
		return this.locIntersects;
	}

	@Override
	public String toString() {
		String s = "Insert Node " + this.node;

		for (LocationIntersect loc : this.locIntersects) {
			s += "\n\t" + loc;
		}

		return s;
	}
}
