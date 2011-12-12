package routingVerification;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class DataFileReader {
	private File dataFile;
	public DataFileReader(String fileName) throws Exception{
		dataFile = new File(fileName);
		if(!dataFile.exists())
			throw new Exception("Unable to find the data file.");
	}
	
	public List<ActualPathSet> readData(List<ActualData> theData) throws Exception{
		List<ActualPathSet> pathSets = new ArrayList<ActualPathSet>();
		
		BufferedReader reader = new BufferedReader(new FileReader(this.dataFile));
		
		ActualPathSet currentSet = null;
		String line = "";
		while((line = reader.readLine()) != null){
			line = line.replace("192.168.0.1", "");
			String[] parsed = line.split(" ");
			
			if(parsed.length < 2){ // reset on empty lines
				currentSet = null;
				continue;
			}
			
			if(currentSet == null){
				currentSet = new ActualPathSet(parsed[1]);
				pathSets.add(currentSet);
			}
			
			ActualPath path = new ActualPath(parsed[0]);
			path.setData(findData(theData, path.getDataLocation()));
			path.addNodes(Arrays.copyOfRange(parsed, 1, parsed.length));
			currentSet.addPath(path);
		}
		
		return pathSets;
	}
	
	private ActualData findData(List<ActualData> theData, String location){
		
		for(ActualData d : theData){
			if(d.getLocation().equals(location))
				return d;
		}
		
		return null;
	}
}
