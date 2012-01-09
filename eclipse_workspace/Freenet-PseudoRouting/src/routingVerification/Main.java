package routingVerification;

import java.io.File;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

import pseudoRouting.Pair;
import pseudoRouting.PathSet;
import pseudoRouting.RoutingManager;
import pseudoRouting.Topology;
import pseudoRouting.Util;

public class Main {

	private final int TOP_FLAG_I = 0;
	private final int OUT_FLAG_I = 1;
	private final int HTL_FLAG_I = 2;
	private final int DATA_FLAG_I = 3;
	private final int DATA_MAP_FLAG_I = 4;
	private final int DATA_WORD_FLAG_I = 5;
	private final int MODEL_FLAG_I = 6;
	private final int START_NODES_FLAG_I = 7;
	private final int HELP_FLAG_I = 8;

	private final String[][] PROG_ARGS = {
			{ "-t", "(required) topology file location." },
			{ "-o", "(required) output file." },
			{ "-htl", "(required) Hops to live count." },
			{ "-d", "(Optional, required for full path analysis) actual insert paths data file location." },
			{ "-dm", "(required) word insertions into freenet data file location." },
			{ "-dw", "(required) inserted word meta data, insert origin." },
			{ "-m", "(default = A) prediction model to use. {A}" },
			{ "-s",	"(default = all nodes) start nodes to run path predictions on. Comma delimited list. format: location-id,location-id,..." },
			{ "-h", "help command. Prints available arguments." } };

	public static void main(String[] args) {
		new Main(args);
	}

	private Main(String[] args) {
		try {
			List<String> lwArgs = Arrays.asList(args);
			
			if(lwArgs.contains(Util.getArgName(PROG_ARGS, HELP_FLAG_I))){
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

			String dataMapFileName = Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, DATA_MAP_FLAG_I), lwArgs);
			String dataWordFileName = Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, DATA_WORD_FLAG_I), lwArgs);
			DataMapFileReader mapReader = new DataMapFileReader(dataMapFileName, dataWordFileName);

			int htl  =Integer.parseInt( Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, HTL_FLAG_I), lwArgs));
			
			List<Pair<Double, String>> startNodes = Util.getStartNodes(lwArgs, Util.getArgName(PROG_ARGS, START_NODES_FLAG_I));
			
			// use insert path only here
			List<PathSet> pathSets = manager.calculateRoutesFromNodes(htl, startNodes,
					topology, true);
			
			List<ActualData> theData = mapReader.readData(writer);
			
			String dataFileName = Util.getArg(Util.getArgName(
					PROG_ARGS, DATA_FLAG_I), lwArgs, "");
			
			if(dataFileName.isEmpty()){
				File fullDataFile = new File(outputFile.getAbsoluteFile() + ".fulldat");
				PrintStream fullWriter = new PrintStream(fullDataFile);
				
				File predictDataFile = new File(outputFile.getAbsoluteFile() + ".pred");
				PrintStream predictWriter = new PrintStream(predictDataFile);
				predictWriter.println(topology);
				for(PathSet s : pathSets )
					predictWriter.println(s);
				// only have actual stored nodes
				//writer.println(pathSets.get(0));
				PathComparer comp = new PathComparer();
				comp.compareStorageNodes(writer, fullWriter, topology, theData, pathSets);
				return;
			}
			
			DataFileReader reader = new DataFileReader(dataFileName);
			// // End Arguments ////
			
			List<ActualPathSet> actPathSets = reader.readData(theData);

			writer.println("Using network topology:");
			writer.println(topology.toString());

			PathComparer comp = new PathComparer();
			comp.compare(writer, actPathSets, pathSets);

		} catch (Exception ex) {
			System.out.println(Util.toStringArgs(PROG_ARGS));
			System.out.println(ex.getMessage());
			System.out.println("!!!Error closing program!!!");
		}
	}
}
