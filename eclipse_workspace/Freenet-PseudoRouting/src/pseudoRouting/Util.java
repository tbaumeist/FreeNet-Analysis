package pseudoRouting;

import java.util.ArrayList;
import java.util.List;

public class Util {
	public static double getDistance(double a, double b) {
		if (a > b)
			return Math.min(a - b, 1.0 - a + b);
		return Math.min(b - a, 1.0 - b + a);
	}

	public static String getRequiredArg(String argName, List<String> args
			) throws Exception {
		
		String value = getArg(argName, args, "");
		if (value.isEmpty())
			throw new Exception("Required argument " + argName
					+ " was not found.");
		return value;
	}

	public static String getArg(String argName, List<String> args,
			String defaultValue) throws Exception {
		
		String value = defaultValue;
		if (!args.contains(argName))
			return value;
		try {
			value = args.get(args.indexOf(argName) + 1);
		} catch (Exception e) {
			throw new Exception("Error reading argument " + argName
					+ ", please validate its properly formatted.");
		}
		return value;
	}
	
	public static String toStringArgs(String[][] args){
		String s = "HELP: Program arguments\n";
		for(String[] arg : args){
			s += arg[0] + "\t" + arg[1] + "\n";
		}
		return s;
	}
	
	public static String getArgName(String[][] args, int index){
		return args[index][0];
	}
	
	public static List<Pair<Double, String>> getStartNodes(List<String> args, String argName) throws Exception {

		List<Pair<Double, String>> startNodes = new ArrayList<Pair<Double, String>>();
		String startNodesArg = Util.getArg(argName, args, "");
		if (startNodesArg.isEmpty())
			return null;

		try {
			String[] startNode = startNodesArg.split(",");
			for (String s : startNode)
				startNodes.add(new Pair<Double, String>(Double.parseDouble(s.split("-")[0]), s.split("-")[1]));
		} catch (Exception e) {
			throw new Exception("Error parsing list of start nodes.");
		}

		return startNodes;
	}
}