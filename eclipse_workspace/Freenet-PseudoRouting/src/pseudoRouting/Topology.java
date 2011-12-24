package pseudoRouting;

import java.io.*;
import java.util.*;

public class Topology {

	private List<Node> nodes = new CircleList<Node>();

	private final double NOT_INITED_LOC = -1.0;

	public Topology(String topFileName) throws Exception {
		readFromFile(topFileName);
		clearOneWayConnections();
	}

	public Node findNode(double location, String id) {
		Node tmp = new Node(location, id);
		if (!this.nodes.contains(tmp))
			return null;

		return this.nodes.get(this.nodes.indexOf(tmp));
	}

	public List<Node> getAllNodes() {
		return this.nodes;
	}

	@Override
	public String toString() {
		String out = "";
		for (Node n : getAllNodes()) {
			out += n + " -> (";
			for (Node n2 : n.getNeighbors()) {
				out += " " + n2 + ",";
			}
			out += ")\n";
		}
		return out;
	}

	private void addNode(Node node) {
		if (this.nodes.contains(node))
			return;
		if (node.getLocation() == NOT_INITED_LOC)
			return;

		this.nodes.add(node);
		Collections.sort(this.nodes);
	}

	private void clearOneWayConnections() {
		List<Node> removeNodes = new ArrayList<Node>();

		for (Node n : getAllNodes()) {
			List<Node> removeNeighbors = new ArrayList<Node>();

			for (Node n2 : n.getNeighbors()) {
				if (!n2.getNeighbors().contains(n))
					removeNeighbors.add(n2);
			}
			n.removeNeighbors(removeNeighbors);
			if (n.getNeighbors().isEmpty())
				removeNodes.add(n);
		}
		getAllNodes().removeAll(removeNodes);
	}

	private void readFromFile(String topFileName) throws Exception {
		try {
			File top = new File(topFileName);
			if(!top.exists())
				throw new Exception("Unable to find the topology file: "+ topFileName);
			
			BufferedReader in = new BufferedReader(new FileReader(top));
			String line;
			while ((line = in.readLine()) != null) {
				if (!line.contains("->"))
					continue;

				line = line.trim();
				line = line.replace('\t', ' ');
				String[] parsed = line.split("\"");
				if (parsed.length != 4)
					continue;

				double locA = Double.parseDouble(parsed[1].split(" ")[0]);
				String idA	=	parsed[1].split(" ")[1];
				double locB = Double.parseDouble(parsed[3].split(" ")[0]);
				String idB = parsed[3].split(" ")[1];

				Node nodeA = findNode(locA, idA);
				Node nodeB = findNode(locB, idB);
				if (nodeA == null)
					nodeA = new Node(locA, idA);
				if (nodeB == null)
					nodeB = new Node(locB, idB);

				addNode(nodeA);
				addNode(nodeB);

				nodeA.addNeighbor(nodeB);
			}
		} catch (Exception ex) {
			throw new Exception("Error reading topology file. Improperly formatted. "+ ex.getMessage());
		}
	}
}
