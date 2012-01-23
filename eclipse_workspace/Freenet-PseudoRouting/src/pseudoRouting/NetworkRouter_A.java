package pseudoRouting;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class NetworkRouter_A extends NetworkRouter {

	private int maxHopsToLive = 0;
	private final int insertResetHop = 3;

	public NetworkRouter_A() {

	}

	@Override
	public List<Path> findPaths(int htl, Topology top, double startNode,
			String startNodeId, boolean isInsertPath) throws Exception {
		this.maxHopsToLive = htl;

		Node start = top.findNode(startNode, startNodeId);
		if (start == null)
			throw new Exception("Unable to find specified start node");

		List<Path> paths = new ArrayList<Path>();
		List<Node> visited = new ArrayList<Node>();
		Path currentPath = new Path();
		RedirectRange startRange = new RedirectRange(start, 0, 0);
		int resetHop = -1;

		if (isInsertPath) // reset hop only used for inserts
			resetHop = this.maxHopsToLive - this.insertResetHop ;

		visited.add(start);
		currentPath.addNodeAsRR(startRange, maxHopsToLive);

		_findPaths(paths, currentPath, visited, startRange, maxHopsToLive - 1,
				resetHop);

		currentPath.removeLastNode();
		assert (currentPath.getNodes().isEmpty());

		return paths;
	}

	private boolean _findPaths(List<Path> paths, Path currentPath,
			List<Node> visited, RedirectRange range, int hopsToLive,
			int resetHop) throws Exception {

		currentPath.setRange(range);
		// stop when htl expires
		// stop when the next closest node is the same as the previous node
		// (self route)
		if (shouldStop(hopsToLive) || range.isSelfRoute()) {
			paths.add(currentPath.clone());
			return true;
		}
		List<Node> oldVisited = null;
		if (hopsToLive == resetHop) {
			oldVisited = visited;
			visited = new ArrayList<Node>();
			visited.add(range.getNode());
		}

		List<RedirectRange> allRanges = getRanges(range, visited,
				hopsToLive < resetHop);

		int pathsFound = 0;

		for (RedirectRange rr : allRanges) {
			if (range.overlaps(rr)) {
				int hopMod = 0;
				if (rr.getIsRetry()) {
					hopMod++;
				}
				pathsFound++;
				visited.add(rr.getNode());
				currentPath.addNodeAsRR(rr, hopsToLive);
				if (_findPaths(paths, currentPath, visited, rr, hopsToLive - 1
						+ hopMod, resetHop)) {

					removeFromEndUpTo(visited, rr.getNode());
				}
				currentPath.removeLastNode();
			}
		}
		if (pathsFound == 0) {
			Path failed = currentPath.clone();
			failed.setSuccess(false);
			paths.add(failed);
		}

		if (oldVisited != null)
			visited = oldVisited;

		return pathsFound > 0;
	}

	private void removeFromEndUpTo(List<Node> visited, Node n) {
		for (int i = visited.size() - 1; i >= 0; i--) {
			boolean found = visited.get(i).equals(n);
			visited.remove(i);
			if (found)
				return;
		}
	}

	private List<RedirectRange> getRangesSimple(RedirectRange range,
			List<Node> visited, boolean includeSelf) {

		List<RedirectRange> ranges = range.getNode().getPathsOut(visited,
				includeSelf);
		ranges = splitRanges(range, ranges);

		return ranges;
	}

	private List<RedirectRange> getRanges(RedirectRange range,
			List<Node> visited, boolean includeSelf) {

		List<RedirectRange> ranges = getRangesSimple(range, visited,
				includeSelf);
		List<Node> visitedOnlyMe = new ArrayList<Node>();
		if (visited.size() > 1) // prev node
			visitedOnlyMe.add(visited.get(visited.size() - 2));
		visitedOnlyMe.add(range.getNode()); // currnet node
		List<RedirectRange> allRanges = getRangesSimple(range, visitedOnlyMe,
				includeSelf);

		for (RedirectRange rr : allRanges) {
			if (visited.contains(rr.getNode()))
				ranges = splitRanges(rr, ranges);
		}

		for (RedirectRange rr : ranges) {
			for (RedirectRange rr2 : allRanges) {
				if (visited.contains(rr2.getNode())) {
					if (rr.overlaps(rr2)) {
						rr.setIsRetry(true);
					}
				}
			}
		}

		return ranges;
	}

	@Override
	protected boolean shouldStop(int hopsToLive) {
		if (hopsToLive < 0)
			return true;

		return false;
	}

	private List<RedirectRange> splitRanges(RedirectRange range,
			List<RedirectRange> ranges) {

		List<RedirectRange> newRanges = new ArrayList<RedirectRange>();

		for (RedirectRange rr : ranges) {
			if (range.overlaps(rr)) {

				newRanges.addAll(range.splitRangeOverMe(rr));
			} else {
				newRanges.add(rr);
			}
		}
		Collections.sort(newRanges);
		return newRanges;
	}

	// private boolean noDuplicatePaths(List<Path> paths) {
	// for (int i = 0; i < paths.size() - 1; i++) {
	// for (int j = i + 1; j < paths.size(); j++) {
	// if (paths.get(i).getRange().overlaps(paths.get(j).getRange()))
	// return false;
	// }
	// }
	// return true;
	// }

}
