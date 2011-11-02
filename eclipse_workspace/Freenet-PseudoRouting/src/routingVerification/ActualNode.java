package routingVerification;


public class ActualNode {
	private String id = "";
	private String nextNodeId = "";
	private int htl;
	
	public ActualNode(String id, String nextNodeId, int htl){
		this.id = id;
		this.nextNodeId = nextNodeId;
		this.htl = htl;
	}
	
	public int getHTL(){
		return this.htl;
	}
	
	public String getID(){
		return this.id;
	}
	
	public String getNextNodeID(){
		return this.nextNodeId;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == null)
			return false;
		if (this == obj)
			return true;

		if (!(obj instanceof ActualNode))
			return false;
		ActualNode node = (ActualNode) obj;
		return node.getID().equals( getID() );
	}

	@Override
	public int hashCode() {
		return getID().hashCode();
	}
	
	@Override
	public String toString() {
		return getID() + "(" + getHTL() + ")";
	}
}
