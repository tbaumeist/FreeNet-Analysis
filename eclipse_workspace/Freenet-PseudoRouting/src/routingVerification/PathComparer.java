package routingVerification;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

import pseudoRouting.Node;
import pseudoRouting.Path;
import pseudoRouting.PathSet;
import pseudoRouting.Topology;

public class PathComparer {
	private int total = 0;
	private int completeMatch = 0;
	private int missedOne = 0;
	private int missedTwo = 0;
	private int correctLength = 0;
	private int firstThree = 0;
	private int startsAtFour = 0;
	private int storageLocation = 0;
	private int storageLocationActual = 0;
	private int totalGuesses = 0;

	public void compareStorageNodes(PrintStream writer, PrintStream fullData, Topology topology,
			List<ActualData> theData, List<PathSet> pathSets) {
		
		printFullDataHeader(fullData);
		
		for (ActualData data : theData) {
			this.total++;
			try {
				PathSet ps = PathSet.findPathSet(data.getOriginNode(), pathSets);
				if (ps == null)
					continue;

				List<Path> paths = ps.findPaths(Double.parseDouble(data
						.getLocation()));
				int foundCnt = 0;
				double guessConvidence = 0.0;
				String storageNodes ="";
				for(Path p : paths){
					guessConvidence += p.getPathConfidence() / (double)paths.size();
					storageNodes+= p.getProbableStoreNode().getID()+" ";
					this.totalGuesses++;
					if(data.getActualStorageNodes().contains(p.getProbableStoreNode().getID()))
					{
						this.storageLocationActual++;
						foundCnt++;
					}
				}
				printFullData(fullData, foundCnt, data, guessConvidence, storageNodes);
				
				if(foundCnt > 0)
					this.storageLocation++;
			} catch (Exception e) {

			}
		}
		writer.println("Total inserts: "+ this.total);
		writer.println("Total correct predictions: "+ this.storageLocation +" "+ ((double)this.storageLocation/(double)this.total)*100.0+"%");
		writer.println("Total guesses: "+ this.totalGuesses);
		writer.println("Total correct predictions (each guess): "+ this.storageLocationActual +" "+ ((double)this.storageLocationActual/(double)this.totalGuesses)*100.0);
	}

	public void compare(PrintStream writer, List<ActualPathSet> actPathSets,
			List<PathSet> pseudoPathSets) {

		compareSimplePaths(writer, actPathSets, pseudoPathSets);

		for (ActualPathSet actPS : actPathSets) {
			PathSet ps = findEqualPathSet(actPS, pseudoPathSets);
			if (ps == null) {
				writer.println("Skipping " + actPS.getStartNode());
				continue;
			}

			writer.println("Using path set:");
			writer.println(ps);
			writer.println();

			for (ActualPath actPath : actPS.getPaths()) {
				try {
					if (!actPath.isFullPath())
						continue;

					double dataLocation = Double.parseDouble(actPath
							.getDataLocation());
					List<Path> paths = ps.findPaths(dataLocation);
					if (paths.isEmpty())
						continue;

					// have pseudo route and actual now
					if (equalPaths(actPath, paths))
						this.completeMatch++;
					if (equalPathsWithMissed(actPath, paths, 1))
						this.missedOne++;
					if (equalPathsWithMissed(actPath, paths, 2))
						this.missedTwo++;
					if (equalPathLengths(actPath, paths))
						this.correctLength++;
					if (equalPathsFirstX(actPath, paths, 3))
						this.firstThree++;
					if (actPath.getPath().size() > 0
							&& actPath.getPath().get(0).getHTL() == 4)
						this.startsAtFour++;
					if (containsNode(getPossibleEndNode(paths), actPath
							.getData().getActualStorageNodes()))
						this.storageLocation++;
					this.total++;
					writer.println(actPath);
					for (Path path : paths) {
						writer.println(path);
					}
					writer.println();
				} catch (Exception e) {
					// writer.println("");
				}
			}
		}

		System.out.println("Matched Completely " + this.completeMatch + "/"
				+ this.total + " (" + this.completeMatch / (double) this.total
				+ ")");
		System.out.println("Matched Missed One " + this.missedOne + "/"
				+ this.total + " (" + this.missedOne / (double) this.total
				+ ")");
		System.out.println("Matched Missed Two " + this.missedTwo + "/"
				+ this.total + " (" + this.missedTwo / (double) this.total
				+ ")");
		System.out.println("Matched Length " + this.correctLength + "/"
				+ this.total + " (" + this.correctLength / (double) this.total
				+ ")");
		System.out.println("Matched first 3 " + this.firstThree + "/"
				+ this.total + " (" + this.firstThree / (double) this.total
				+ ")");
		System.out.println("Starts at 4 " + this.startsAtFour + "/"
				+ this.total + " (" + this.startsAtFour / (double) this.total
				+ ")");
		System.out.println("Has actual storage location "
				+ this.storageLocation + "/" + this.total + " ("
				+ this.storageLocation / (double) this.total + ")");
	}
	private void printFullDataHeader(PrintStream writer){
		writer.println("Word, Location, Insert Node, Guessed Storage Nodes, Confidence, Hit, Hit Count, Actual Storage Nodes");
	}
	private void printFullData(PrintStream writer, int foundCnt, ActualData data, double guessConvidence,
			String storageNodes){
		
		// word, location, insert node, guessed storage nodes, confidence, hit, hit count, actual storage nodes
		writer.println(data.getWord()+","+data.getLocation()+","+data.getOriginNode()+","+storageNodes
				+","+guessConvidence+","+(foundCnt > 0?"TRUE":"FALSE")+","+foundCnt+","+data.getActualStorageNodesToString());
	}

	private void compareSimplePaths(PrintStream writer,
			List<ActualPathSet> actPathSets, List<PathSet> pseudoPathSets) {
		writer.println("==========================================");
		writer.println("            Simple Paths                  ");
		writer.println("==========================================");
		for (ActualPathSet actPS : actPathSets) {
			PathSet ps = findEqualPathSet(actPS, pseudoPathSets);
			if (ps == null) {
				writer.println("Skipping " + actPS.getStartNode());
				continue;
			}

			for (ActualPath actPath : actPS.getPaths()) {
				try {
					if (!actPath.isFullPath())
						continue;
					if (!actPath.isSimplePath())
						continue;

					double dataLocation = Double.parseDouble(actPath
							.getDataLocation());
					List<Path> paths = ps.findPaths(dataLocation);
					if (paths.isEmpty())
						continue;

					writer.println(actPath);
					for (Path path : paths) {
						writer.println(path);
					}
					writer.println();
				} catch (Exception e) {
					// writer.println("");
				}
			}
		}
		writer.println("==========================================");
		writer.println("            End Simple Paths              ");
		writer.println("==========================================");
	}

	private boolean containsNode(List<Node> nodes, List<String> ids) {
		for (Node n : nodes) {
			for (String id : ids) {
				if (n.getID().equals(id))
					return true;
			}
		}
		return false;
	}

	private List<Node> getPossibleEndNode(List<Path> paths) {
		List<Node> nodes = new ArrayList<Node>();
		for (Path p : paths) {
			if (p.getNodes().isEmpty())
				continue;
			nodes.add(p.getNodes().get(p.getNodes().size() - 1));
		}
		return nodes;
	}

	private boolean equalPaths(ActualPath actPath, List<Path> paths) {
		for (Path path : paths) {
			if (actPath.getReducedPath().size() != path.getNodes().size())
				continue;
			boolean matched = true;
			for (int i = 0; i < actPath.getReducedPath().size(); i++) {
				if (!actPath.getReducedPath().get(i).getID().equals(
						path.getNodes().get(i).getID())) {
					matched = false;
					break;
				}
			}
			if (matched)
				return true;
		}
		return false;
	}

	private boolean equalPathLengths(ActualPath actPath, List<Path> paths) {
		for (Path path : paths) {
			if (actPath.getReducedPath().size() == path.getNodes().size())
				return true;
		}
		return false;
	}

	private boolean equalPathsFirstX(ActualPath actPath, List<Path> paths,
			int count) {
		for (Path path : paths) {
			if (actPath.getReducedPath().size() != path.getNodes().size())
				continue;
			boolean matched = true;
			for (int i = 0; i < actPath.getReducedPath().size(); i++) {
				if (i >= count)
					break;
				if (!actPath.getReducedPath().get(i).getID().equals(
						path.getNodes().get(i).getID())) {
					matched = false;
					break;
				}
			}
			if (matched)
				return true;
		}
		return false;
	}

	private boolean equalPathsWithMissed(ActualPath actPath, List<Path> paths,
			int maxMissed) {
		for (Path path : paths) {
			if (actPath.getReducedPath().size() != path.getNodes().size())
				continue;
			int missed = 0;
			for (int i = 0; i < actPath.getReducedPath().size(); i++) {
				if (!actPath.getReducedPath().get(i).getID().equals(
						path.getNodes().get(i).getID()))
					missed++;
			}
			if (missed <= maxMissed)
				return true;
		}
		return false;
	}

	private PathSet findEqualPathSet(ActualPathSet actPS,
			List<PathSet> pseudoPathSets) {
		if (actPS == null)
			return null;
		for (PathSet ps : pseudoPathSets) {
			if (ps.getStartNode().getID().equals(actPS.getStartNode())) {
				return ps;
			}
		}
		return null;
	}

}