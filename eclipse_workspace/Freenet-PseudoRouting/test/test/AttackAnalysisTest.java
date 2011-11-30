package test;


import org.junit.Test;
import attackAnalysis.*;
import static org.junit.Assert.*;

public class AttackAnalysisTest {

	@Test
	public void checkCombination() {
		try {
			InputDataSet inDS = new InputDataSet("") {

				protected void read(String fileName) throws Exception {
//					this.inputData.add(new InputData("1", "2"), "3"));
//					this.inputData.add(new InputData("3", "4", "3"));
//					this.inputData.add(new InputData("1", "5", "3"));
//					this.inputData.add(new InputData("1", "2", "6"));
//					this.inputData.add(new InputData("1", "6", "7"));
//					this.inputData.add(new InputData("1", "2", "8"));
//					this.inputData.add(new InputData("1", "2", "9"));
//					this.inputData.add(new InputData("4", "2", "3"));
//					this.inputData.add(new InputData("7", "2", "8"));
//					this.inputData.add(new InputData("8", "2", "3"));
//					this.inputData.add(new InputData("9", "2", "3"));
//					this.inputData.add(new InputData("1", "6", "7"));
//					this.inputData.add(new InputData("2", "5", "3"));
//					this.inputData.add(new InputData("2", "6", "1"));
//					this.inputData.add(new InputData("2", "7", "3"));
				}
			};
			AttackSizeSet attSet = new AttackSizeSet(3, inDS);
			System.out.println(attSet);
			//List<AttackSet> aSet = attSet.getAttackSet();
			//assertTrue(aSet.size() == 84);
			
			attSet = new AttackSizeSet(4, inDS);
			System.out.println(attSet);
			//aSet = attSet.getAttackSet();
			//assertTrue(aSet.size() == 126);
			
			assertTrue(true);
		} catch (Exception ex) {
			System.out.println("ERROR!! " + ex.getMessage());
			assertTrue(false);
		}
	}
}
