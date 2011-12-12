package attackAnalysis;

import java.io.*;
import java.util.*;

public class InputDataSet {
	protected Hashtable<InputData, InputData> inputData = new Hashtable<InputData, InputData>();
	private List<String> uniquesNodes = null;

	public InputDataSet(String fileName) throws Exception {
		
		read(fileName);
	}

	public Hashtable<InputData, InputData> getInputData() {
		return this.inputData;
	}

	public List<String> getUniqueNodes() {
		if (uniquesNodes == null) {
			uniquesNodes = new ArrayList<String>();
			for (InputData i : this.inputData.values()) {
				if (!uniquesNodes.contains(i.getInsertNode()))
					uniquesNodes.add(i.getInsertNode());
				if (!uniquesNodes.contains(i.getRequestNode()))
					uniquesNodes.add(i.getRequestNode());
			}
		}
		return uniquesNodes;
	}

	protected void read(String fileName) throws Exception {
		File f = new File(fileName);
		if (!f.exists())
			throw new Exception("Unable to find the data file : " + fileName);
		
		BufferedReader reader = new BufferedReader(new FileReader(f));
		String line = "";
		while ((line = reader.readLine()) != null) {
			String[] parsed = line.split(",");
			InputData data = new InputData(parsed[0].trim(),	parsed[1].trim());
			if(!this.inputData.containsKey(data))
				this.inputData.put(data, data);
			
			InputData dataFound = this.inputData.get(data);
			dataFound.addTargetNode(parsed[2].trim());
		}
	}
}
