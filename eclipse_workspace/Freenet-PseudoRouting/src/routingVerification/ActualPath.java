package routingVerification;

import java.util.ArrayList;
import java.util.List;

public class ActualPath {
	private List<ActualNode> path = new ArrayList<ActualNode>();
	private List<ActualNode> originalPath = new ArrayList<ActualNode>();
	private List<ActualNode> reducedPath = new ArrayList<ActualNode>();
	private String dataLocation;
	private int resetPoint = 3;
	private int maxHTL = 6;
	private ActualData data = null;

	public ActualPath(String dataLocation) {
		this.dataLocation = dataLocation;
	}
	
	public void setData(ActualData d){
		this.data = d;
	}
	
	public ActualData getData(){
		return this.data;
	}

	public String getDataLocation(){
		return this.dataLocation;
	}
	
	public void addNodes(String[] nodes) throws Exception {
		for (int i =0; i + 2 < nodes.length; i = i+3) {
			this.originalPath.add(new ActualNode(nodes[i], nodes[i+1], Integer.parseInt(nodes[i+2]) ));
		}
		this.path = fixPath(this.originalPath);
		this.reducedPath.addAll(this.path);
		reduceLower(this.reducedPath);
		reduceUpper(this.reducedPath);
	}

	public List<ActualNode> getPath() {
		return this.path;
	}

	public List<ActualNode> getReducedPath() {
		return this.reducedPath;
	}
	
	public boolean isFullPath(){
		int prev = -1;
		for( ActualNode n : this.path ){
			if(prev == -1){
				prev = n.getHTL();
				continue;
			}
			if(n.getHTL() != prev && n.getHTL() != prev-1)
				return false;
			prev = n.getHTL();
		}
		return prev == 1;
	}
	
	public boolean isSimplePath(){
		int prev = -1;
		for( ActualNode n : this.path ){
			if(prev == -1){
				prev = n.getHTL();
				continue;
			}
			if(n.getHTL() != prev-1)
				return false;
			prev = n.getHTL();
		}
		return true;
	}

	@Override
	public String toString() {
		String s = "";
		if(this.data != null)
			s += this.data + "\n";
		s += "A\t" + this.dataLocation + " : ";
		for (ActualNode loc : this.path) {
			s += loc + ", ";
		}
		if (this.path.size() != this.reducedPath.size()) {
			s += "\nAR\t" + this.dataLocation + " : ";
			for (ActualNode loc : this.reducedPath) {
				s += loc + ", ";
			}
		}
		return s;
	}
	
	private int getReset(){
		return this.maxHTL - this.resetPoint;
	}

	private void reduceLower(List<ActualNode> lst) {
		reduceLower(lst, this.maxHTL, getReset());
	}

	private void reduceUpper(List<ActualNode> lst) {
		reduceLower(lst, getReset(), 0);
	}
	
	private List<ActualNode> fixPath(List<ActualNode> lst){
		//List<ActualNode>
		return lst;
	}

	private void reduceLower(List<ActualNode> lst, int start, int end) {
		List<ActualNode> seen = new ArrayList<ActualNode>();
		List<Integer> removeIndices = new ArrayList<Integer>();

		for (int i = 0; i < lst.size(); i++) {
			if(lst.get(i).getHTL() >= start)
				continue;
			if(lst.get(i).getHTL() < end)
				break;
			if(seen.contains(lst.get(i)))
				removeIndices.add(i);
			seen.add(lst.get(i));
		}
		for(int i = removeIndices.size() -1; i >= 0; i--){
			lst.remove(removeIndices.get(i).intValue());
		}
	}
}
