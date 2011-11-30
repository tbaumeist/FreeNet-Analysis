package attackAnalysis;

import java.util.*;

public class AttackSet {
	private List<String> nodes = new ArrayList<String>();
	private int targets = 0;
	
	public AttackSet(List<String> usedNodes){
		if(usedNodes != null)
			this.nodes.addAll(usedNodes);
	}
	
	public int getTargets(){
		return this.targets;
	}

	
	public void calcProperties(InputDataSet inDS){
		List<String> targets = new ArrayList<String>();
		
		for(int i = 0; i < this.nodes.size(); i++){
			for(int j = 0; j < this.nodes.size(); j++){
				if(i == j)
					continue;
				InputData data = new InputData(this.nodes.get(i), this.nodes.get(j));
				if(inDS.getInputData().containsKey(data)){
					InputData dataFound = inDS.getInputData().get(data);
					for(String t : dataFound.getTargetNodes()){
						if(!targets.contains(t))
							targets.add(t);
					}
				}
			}
		}
		
//		for(InputData i : inDS.getInputData().values()){
//			if(this.nodes.contains(i.getInsertNode()) && this.nodes.contains(i.getRequestNode())){
//				for(String t : i.getTargetNodes()){
//					if(!targets.contains(t))
//						targets.add(t);
//				}
//			}
//		}
		this.targets = targets.size();
	}
	
	@Override
	public String toString(){
		String s = "Count: " + this.targets + " Set: ";
		for(String n : this.nodes)
			s += n +", ";
		return s;
	}
}
