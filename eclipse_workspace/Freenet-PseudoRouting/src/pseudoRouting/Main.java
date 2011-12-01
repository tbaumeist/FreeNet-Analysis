package pseudoRouting;

import java.io.File;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import pseudoRouting.Intersect.*;

public class Main {

	private final int TOP_FLAG_I = 0;
	private final int OUT_FLAG_I = 1;
	private final int HTL_FLAG_I = 2;
	private final int ACTION_FLAG_I = 3;
	private final int MODEL_FLAG_I = 4;
	private final int START_NODES_FLAG_I = 5;
	private final int HELP_FLAG_I = 6;

	private final String[][] PROG_ARGS = {
			{ "-t", "(required) topology file location." },
			{ "-o", "(required) output file." },
			{ "-htl", "(required) Hops to live count." },
			{ "-a",	"(default = p)action to perform. {p = predict insert and request paths, i = find intersect nodes}" },
			{ "-m", "(default = A) prediction model to use. {A}" },
			{ "-s",	"(default = all nodes) start nodes to run path predictions on. Comma delimited list." },
			{ "-h", "help command. Prints available arguments." } };

	public static void main(String[] args) {
		new Main(args);
	}

	private Main(String[] args) {
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

			String routingModel = Util.getArg(Util.getArgName(PROG_ARGS,
					MODEL_FLAG_I), lwArgs, "A");
			RoutingManager manager = new RoutingManager(routingModel);

			List<Double> startNodes = getStartNodes(lwArgs);
			String action = Util.getArg(
					Util.getArgName(PROG_ARGS, ACTION_FLAG_I), lwArgs, "p")
					.toUpperCase();
			
			int htl  =Integer.parseInt( Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, HTL_FLAG_I), lwArgs));
			// // End Arguments ////

			// actions
			if (action.equals("P")) {
				List<PathSet> pathInsertSets = manager
						.calculateRoutesFromNodes(htl, startNodes, topology, true);
				writer.println("Insert Paths:\n\n");
				for (PathSet p : pathInsertSets) {
					writer.println(p);
				}

				List<PathSet> pathRequestSets = manager
						.calculateRoutesFromNodes(htl, startNodes, topology, false);
				writer.println("Request Paths:\n\n");
				for (PathSet p : pathRequestSets) {
					writer.println(p);
				}
			} else if (action.equals("I")) {

				List<NodeIntersect> nodeIntersects = manager
						.calculateNodeIntersects(htl, startNodes, topology);
				for (NodeIntersect n : nodeIntersects) {
					writer.println(n);
				}
			}

		} catch (Exception ex) {
			System.out.println(Util.toStringArgs(PROG_ARGS));
			System.out.println(ex.getMessage());
			System.out.println("!!!Error closing program!!!");
		}
	}

	private List<Double> getStartNodes(List<String> args) throws Exception {

		List<Double> startNodes = new ArrayList<Double>();
		String startNodesArg = Util.getArg(Util.getArgName(PROG_ARGS,
				START_NODES_FLAG_I), args, "");
		if (startNodesArg.isEmpty())
			return null;

		try {
			String[] startNode = startNodesArg.split(",");
			for (String s : startNode)
				startNodes.add(Double.parseDouble(s));
		} catch (Exception e) {
			throw new Exception("Error parsing list of start nodes.");
		}

		return startNodes;
	}
}
