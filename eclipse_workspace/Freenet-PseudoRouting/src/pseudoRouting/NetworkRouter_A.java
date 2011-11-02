package pseudoRouting;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class NetworkRouter_A extends NetworkRouter {

	private int maxHopsToLive = 5;
	private int insertResetHop = 3;

	public NetworkRouter_A() {

	}

	@Override
	public List<Path> findPaths(Topology top, double startNode, boolean isInsertPath)
			throws Exception {

		Node start = top.findNode(startNode);
		if (start == null)
			throw new Exception("Unable to find specified start node");
		List<Path> paths = new ArrayList<Path>();
		List<Node> visited = new ArrayList<Node>();

		visited.add(start);
		Path currentPath = new Path();
		RedirectRange startRange = new RedirectRange(start, 0, 0);
		currentPath.addNodeAsRR(startRange, maxHopsToLive);
		
		int resetHop = -1;
		if(isInsertPath)
			resetHop = this.maxHopsToLive - (this.insertResetHop + 1);

		_findPaths(paths, currentPath, visited, startRange,
				maxHopsToLive-1, resetHop);

		currentPath.removeLastNode();
		assert (currentPath.getNodes().isEmpty());
		
		///////////////////////////////////////////////////////////
		// now at max htl -1
		visited = new ArrayList<Node>();
		
		visited.add(start);
		currentPath = new Path();
		currentPath.addNodeAsRR(startRange, maxHopsToLive - 1);

		_findPaths(paths, currentPath, visited, startRange,
				maxHopsToLive - 2, resetHop);

		currentPath.removeLastNode();
		assert (currentPath.getNodes().isEmpty());

		Collections.sort(paths);

		return paths;
	}

	private boolean _findPaths(List<Path> paths, Path currentPath,
			List<Node> visited, RedirectRange range, int hopsToLive, int resetHop)
			throws Exception {

		currentPath.setRange(range);
		if (shouldStop(hopsToLive)) {
			paths.add(currentPath.clone());
			return true;
		}
		List<Node> oldVisited = null;
		if (hopsToLive == resetHop) {
			oldVisited = visited;
			visited = new ArrayList<Node>();
			visited.add(range.getNode());
		}

		List<RedirectRange> allRanges = getRanges(range, visited);

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
					visited.removeAll(visited.subList(visited.indexOf(rr
							.getNode()), visited.size()));
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

	private List<RedirectRange> getRangesSimple(RedirectRange range,
			List<Node> visited) {

		List<RedirectRange> ranges = range.getNode().getPathsOut(visited);
		ranges = splitRanges(range, ranges);

		return ranges;
	}

	private List<RedirectRange> getRanges(RedirectRange range,
			List<Node> visited) {

		List<RedirectRange> ranges = getRangesSimple(range, visited);
		List<Node> visitedOnlyMe = new ArrayList<Node>();
		if(visited.size() > 1) // prev node
			visitedOnlyMe.add(visited.get(visited.size()-2));
		visitedOnlyMe.add(range.getNode()); // currnet node
		List<RedirectRange> allRanges = getRangesSimple(range,
				visitedOnlyMe);
		
		for(RedirectRange rr : allRanges){
			if(visited.contains(rr.getNode()))
				ranges = splitRanges(rr, ranges);
		}
		
		for( RedirectRange rr : ranges ){
			for( RedirectRange rr2 : allRanges){
				if(visited.contains(rr2.getNode())){
					if(rr.overlaps(rr2)){
						rr.setIsRetry(true);
					}
				}
			}
		}
		
		return ranges;
	}

	@Override
	protected boolean shouldStop(int hopsToLive) {
		if (hopsToLive <= 0)
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

//	private boolean noDuplicatePaths(List<Path> paths) {
//		for (int i = 0; i < paths.size() - 1; i++) {
//			for (int j = i + 1; j < paths.size(); j++) {
//				if (paths.get(i).getRange().overlaps(paths.get(j).getRange()))
//					return false;
//			}
//		}
//		return true;
//	}

}
