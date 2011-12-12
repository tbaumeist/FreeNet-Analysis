package pseudoRouting;

import java.util.List;

public abstract class NetworkRouter {

	public abstract List<Path> findPaths(int htl, Topology top, double startNode, boolean isInsertPath) throws Exception;
	
	protected abstract boolean shouldStop(int hopsToLive);
	
	protected double getDistance(double a, double b){
		return Util.getDistance(a, b);
	}
}
