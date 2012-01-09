package pseudoRouting;

import java.io.File;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class SingleRoutePred {

	private final int TOP_FLAG_I = 0;
	private final int OUT_FLAG_I = 1;
	private final int HTL_FLAG_I = 2;
	private final int LOC_FLAG_I = 3;
	private final int START_NODES_FLAG_I = 4;
	private final int HELP_FLAG_I = 5;

	private final String[][] PROG_ARGS = {
			{ "-t", "(required) topology file location." },
			{ "-o", "(required) output file." },
			{ "-htl", "(required) Hops to live count." },
			{ "-l", "(required) insert data's location." },
			{
					"-s",
					"(default = all nodes) start nodes to run path predictions on. Comma delimited list. format: location-id,location-id,..." },
			{ "-h", "help command. Prints available arguments." } };

	private final int insertResetHop = 4;

	public static void main(String[] args) {
		new SingleRoutePred(args);
	}
	
	public SingleRoutePred(){
		
	}

	private SingleRoutePred(String[] args) {
		try {
			List<String> lwArgs = Arrays.asList(args);

			if (lwArgs.contains(Util.getArgName(PROG_ARGS, HELP_FLAG_I))) {
				System.out.println(Util.toStringArgs(PROG_ARGS));
				return;
			}

			// // Arguments ////
			File outputFile = new File(Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, OUT_FLAG_I), lwArgs));
			PrintStream writer = new PrintStream(outputFile);

			String topologyFileName = Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, TOP_FLAG_I), lwArgs);
			Topology topology = new Topology(topologyFileName);

			double dataLoc = Double.parseDouble(Util.getRequiredArg(Util
					.getArgName(PROG_ARGS, LOC_FLAG_I), lwArgs));

			int htl = Integer.parseInt(Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, HTL_FLAG_I), lwArgs));

			List<Pair<Double, String>> startNodes = Util.getStartNodes(lwArgs,
					Util.getArgName(PROG_ARGS, START_NODES_FLAG_I));

			for (Pair<Double, String> origin : startNodes){
				Path p = routeInsertPath(topology, origin, dataLoc, htl);
				writer.println(p);
				
				p = routeInsertPath(topology, origin, dataLoc, htl - 1);
				writer.println(p);
			}

		} catch (Exception ex) {
			System.out.println(Util.toStringArgs(PROG_ARGS));
			System.out.println(ex.getMessage());
			System.out.println("!!!Error closing program!!!");
		}
	}

	public Path routeInsertPath(Topology top, Pair<Double, String> originNode,
			double dataLoc, int htl) throws Exception {

		int maxHopsToLive = htl + 1;
		int resetHop = maxHopsToLive - this.insertResetHop;
		Path path = new Path();

		Node start = top
				.findNode(originNode.getFirst(), originNode.getSecond());
		if (start == null)
			throw new Exception("Unable to find specified start node");

		path.addNodeAsRR(new RedirectRange(start, 0, 0), maxHopsToLive);
		List<Node> visited = new ArrayList<Node>();
		visited.add(start);

		_routeInsert(path, top, visited, start, dataLoc, maxHopsToLive - 1,
				resetHop);

		return path;
	}

	private void _routeInsert(Path path, Topology top, List<Node> visited,
			Node currentNode, double dataLoc, int htl, int resetHop) {

		if (htl < 0)
			return;

		if (htl == resetHop) {
			visited = new ArrayList<Node>();
			visited.add(currentNode);
		}

		Node next = currentNode.getNextClosestNeighborExcluding(dataLoc,
				visited, htl < resetHop);
		if (next == null)
		{
			path.addNodeAsRR(new RedirectRange(currentNode, 0, 0), htl);
			return;
		}

		path.addNodeAsRR(new RedirectRange(next, 0, 0), htl);
		visited.add(next);

		_routeInsert(path, top, visited, next, dataLoc, htl - 1, resetHop);
	}

}
