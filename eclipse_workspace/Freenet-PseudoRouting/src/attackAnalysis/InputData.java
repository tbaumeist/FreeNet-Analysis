package attackAnalysis;

import java.util.*;

public class InputData implements Comparable<Object> {
	private String insertNode;
	private String requestNode;
	private List<String> targetNodes = new ArrayList<String>();
	
	public InputData(String i, String r){
		this.insertNode = i;
		this.requestNode = r;
	}
	
	public void addTargetNode(String t){
		if(!this.targetNodes.contains(t))
			this.targetNodes.add(t);
	}
	
	public String getInsertNode(){
		return this.insertNode;
	}
	public String getRequestNode(){
		return this.requestNode;
	}
	public List<String> getTargetNodes(){
		return this.targetNodes;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == null)
			return false;
		if (this == obj)
			return true;

		if (!(obj instanceof InputData))
			return false;
		InputData node = (InputData) obj;
		return node.insertNode.equals(this.insertNode) && node.requestNode.equals(this.requestNode);
	}

	@Override
	public int hashCode() {
		return this.insertNode.hashCode() + this.requestNode.hashCode();
	}

	@Override
	public int compareTo(Object o) {
		if(o == null)
			return -1;
		if(!(o instanceof InputData))
			return -1;
		InputData i = (InputData)o;
		int cmp = this.insertNode.compareTo(i.insertNode);
		if(cmp != 0)
			return cmp;
		return this.requestNode.compareTo(i.requestNode);
	}
}
