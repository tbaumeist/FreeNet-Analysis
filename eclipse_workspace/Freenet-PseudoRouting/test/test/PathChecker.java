package test;

import java.io.File;
import java.io.PrintStream;
import java.util.List;

import org.junit.Test;

import static org.junit.Assert.*;

import pseudoRouting.Node;
import pseudoRouting.Pair;
import pseudoRouting.Path;
import pseudoRouting.PathSet;
import pseudoRouting.RoutingManager;
import pseudoRouting.SingleRoutePred;
import pseudoRouting.Topology;

public class PathChecker {

	private String topPath = "/home/user/Desktop/TheData/EXP-20-6-4/top.dot";
	private String outPath = "/home/user/Desktop/assertModel.dat";
	private int htl = 4;
	private double stepSize = 0.01;

	@Test
	public void checkPaths() {
		try {
			
			File outputFile = new File(outPath);
			PrintStream writer = new PrintStream(outputFile);

			Topology topology = new Topology(topPath);
			RoutingManager manager = new RoutingManager("A");
			List<PathSet[]> pathSets = manager.calculateRoutesFromNodes(htl,
					null, topology, true);
			
			int total = 0;
			int matched = 0;
			
			for(Node n : topology.getAllNodes()){
				for(double step = 0; step < 1; step += stepSize){
					SingleRoutePred single = new SingleRoutePred();
					Pair<Double, String> startNode = new Pair<Double, String>(n.getLocation(), n.getID());
					Path p = single.routeInsertPath(topology, startNode, step, htl);
					if(p == null)
						continue;
					PathSet ps = PathSet.findPathSet(n.getID(), htl, pathSets);
					if(ps == null)
						continue;
					List<Path> pLst = ps.findPaths(step);
					for(Path p1 : pLst){
						if(p1.getNodes().size() != p.getNodes().size())
							continue;
						total++;
						if(!p1.equalPath(p)){
							writer.println("Loc   : " + step);
							writer.println("Model : " + p1);
							writer.println("Single: " + p);
							writer.println();
							continue;
						}
						matched++;
					}
				}
			}
			writer.println("Final : " + matched+"/"+total+" ("+(double)matched/(double)total+")");
		} catch (Exception ex) {
			assertTrue(false);
		}
	}
}
