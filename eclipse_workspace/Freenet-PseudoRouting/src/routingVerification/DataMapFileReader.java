package routingVerification;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

public class DataMapFileReader {
	private File dataFile;
	public DataMapFileReader(String fileName) throws Exception{
		dataFile = new File(fileName);
		if(!dataFile.exists())
			throw new Exception("Unable to find the word map data file.");
	}
	
	public List<ActualData> readData() throws Exception{
		List<ActualData> datas = new ArrayList<ActualData>();
		
		BufferedReader reader = new BufferedReader(new FileReader(this.dataFile));
		
		String line = "";
		int lineCount = 0;
		while((line = reader.readLine()) != null){
			lineCount++;
			if(lineCount <= 1) // skip header line
				continue;
			
			line = line.replace("192.168.0.1", "").replace("\t", " ");
			String[] parsed = line.split(" ");
			
			if(parsed.length < 2){
				continue;
			}
			String location = null;
			String word = null;
			List<String> nodes = new ArrayList<String>();
			for(int i =0; i < parsed.length; i++){
				String s = parsed[i];

				if(s.isEmpty())
					continue;
				if(location == null){
					location = s.trim();
					continue;
				}
				if(word == null){
					word = s.trim();
					continue;
				}
				nodes.add(s.trim());
				i++; // skip extra location info
			}
			datas.add(new ActualData(location, word, nodes));
		}
		
		return datas;
	}
}
