package routingVerification;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class DataMapFileReader {
	private File dataFile;
	private File wordFile;
	public DataMapFileReader(String fileName, String dataWordFileName) throws Exception{
		dataFile = new File(fileName);
		wordFile = new File(dataWordFileName);
		if(!dataFile.exists())
			throw new Exception("Unable to find the word map data file.");
		if(!wordFile.exists())
			throw new Exception("Unable to find the word meta data file.");
	}
	
	public List<ActualData> readData(PrintStream writer) throws Exception{
		List<WordOriginPair> words = new ArrayList<WordOriginPair>();
		List<WordOriginPair> removeDuplicates = new ArrayList<WordOriginPair>();
		BufferedReader wordReader = new BufferedReader(new FileReader(this.wordFile));
		
		String wordLine = "";
		while((wordLine = wordReader.readLine()) != null){
			String[] parsed = wordLine.split(":");
			if(parsed.length < 4)
				continue;
			String key = parsed[1].trim();
			key = key.split("@")[1].split(",")[0];
			WordOriginPair w = new WordOriginPair(parsed[0].trim(), key, parsed[3].trim(), parsed[2].trim());
			if(!words.contains(w))
				words.add(w);
			else
				removeDuplicates.add(w);
		}
		words.removeAll(removeDuplicates);
		if(!removeDuplicates.isEmpty()){
			writer.println("Removed duplicate entries:");
			for(WordOriginPair w : removeDuplicates)
				writer.println("\t"+w.getWord());
		}
		
		// read other data file
		Hashtable<String, List<String>> storedWords = new Hashtable<String, List<String>>();
		
		BufferedReader reader = new BufferedReader(new FileReader(this.dataFile));
		String line = "";
		while((line = reader.readLine()) != null){
			line = line.replace("192.168.0.1", "").replace("\t", " ");
			String[] parsed = line.split(":");
			if(parsed.length < 4)
				continue;
			String key = parsed[1].split("@")[2].trim();
			String nodeId = parsed[3].trim();
			if(!storedWords.containsKey(key))
				storedWords.put(key, new ArrayList<String>());
			storedWords.get(key).add(nodeId);
		}
		
		List<ActualData> datas = new ArrayList<ActualData>();
		
		for(Map.Entry<String, List<String>> entry : storedWords.entrySet()){
			WordOriginPair origin = findWordOriginPair(entry.getKey(), words);
			if(origin == null)
				continue;
			datas.add(new ActualData(origin.getOrigin(), origin.getLocation(), origin.getWord(), entry.getValue()));
		}
		
		return datas;
	}
	
	private WordOriginPair findWordOriginPair(String word, List<WordOriginPair> list){
		for(WordOriginPair w : list){
			if(w.getKey().equals(word))
				return w;
		}
		return null;
	}
	
	class WordOriginPair{
		private String word, origin, key, location;
		public WordOriginPair(String w, String k, String o, String l){
			this.word = w;
			this.key = k;
			this.origin = o.replace("192.168.0.1", "");
			this.location = l;
		}
		public String getWord(){
			return this.word;
		}
		public String getOrigin(){
			return this.origin;
		}
		public String getKey(){
			return this.key;
		}
		public String getLocation(){
			return this.location;
		}
		@Override
		public boolean equals(Object obj) {
			if (obj == null)
				return false;
			if (this == obj)
				return true;

			if (!(obj instanceof WordOriginPair))
				return false;
			WordOriginPair node = (WordOriginPair) obj;
			return node.getWord().equals(getWord());
		}

		@Override
		public int hashCode() {
			return getWord().hashCode();
		}
	}
	
}
