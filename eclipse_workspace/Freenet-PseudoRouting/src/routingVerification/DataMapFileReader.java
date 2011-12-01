package routingVerification;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

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
			WordOriginPair w = new WordOriginPair(parsed[0].trim(), parsed[3].trim());
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
			String origin = findWordOrigin(word, words);
			if(origin == null)
				continue;
			datas.add(new ActualData(origin, location, word, nodes));
		}
		
		return datas;
	}
	
	private String findWordOrigin(String word, List<WordOriginPair> list){
		for(WordOriginPair w : list){
			if(w.getWord().equals(word))
				return w.getOrigin();
		}
		return null;
	}
	
	class WordOriginPair{
		private String word, origin;
		public WordOriginPair(String w, String o){
			this.word = w;
			this.origin = o.replace("192.168.0.1", "");
		}
		public String getWord(){
			return this.word;
		}
		public String getOrigin(){
			return this.origin;
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
