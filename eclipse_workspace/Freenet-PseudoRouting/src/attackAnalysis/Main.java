package attackAnalysis;

import java.io.File;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

import pseudoRouting.Util;

public class Main {

	private final int DATA_FILE_FLAG_I = 0;
	private final int OUT_FLAG_I = 1;
	private final int HELP_FLAG_I = 2;

	private final String[][] PROG_ARGS = {
			{ "-d", "(required) Data file location." },
			{ "-o", "(required) output file." },
			{ "-h", "help command. Prints available arguments." } };

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

			String dataFileName = Util.getRequiredArg(Util.getArgName(
					PROG_ARGS, DATA_FILE_FLAG_I), lwArgs);
			
			InputDataSet inDS = new InputDataSet(dataFileName);
			for(int i = 0; i < inDS.getUniqueNodes().size(); i++){
				AttackSizeSet attSet = new AttackSizeSet(i, inDS);
				writer.println(attSet);
			}

		} catch (Exception ex) {
			System.out.println(Util.toStringArgs(PROG_ARGS));
			System.out.println(ex.getMessage());
			System.out.println("!!!Error closing program!!!");
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		new Main(args);
	}

}
