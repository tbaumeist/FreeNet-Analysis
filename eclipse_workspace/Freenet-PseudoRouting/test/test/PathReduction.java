package test;

import org.junit.Test;

import routingVerification.ActualPath;

import static org.junit.Assert.*;

public class PathReduction {

	@Test
	public void checkPathNoReduction() {
		try {
			// no reduction
			ActualPath p = new ActualPath("0.4567");
			String[] nodes = new String[] { ".123", ".234", ".345", ".456",
					".567", ".678", ".789" };
			p.addNodes(nodes);
			assertTrue(p.getPath().size() == p.getReducedPath().size());	
		} catch (Exception e) {
			assertTrue(false);
		}
	}
	
	@Test
	public void checkPathLowerReduction() {
		try {
			// no reduction
			ActualPath p = new ActualPath("0.4567");
			String[] nodes = new String[] { ".123", ".234",  ".123", ".345", ".456",
					".567", ".678", ".789" };
			p.addNodes(nodes);
			assertTrue(p.getPath().size() != p.getReducedPath().size());	
			assertTrue(p.getReducedPath().get(0).equals(".123"));
			assertTrue(p.getReducedPath().get(1).equals(".345"));
			assertTrue(p.getReducedPath().get(2).equals(".456"));
			assertTrue(p.getReducedPath().get(3).equals(".567"));
			assertTrue(p.getReducedPath().get(4).equals(".678"));
			assertTrue(p.getReducedPath().get(5).equals(".789"));
		} catch (Exception e) {
			assertTrue(false);
		}
	}
	
	@Test
	public void checkPathUpperReduction() {
		try {
			// no reduction
			ActualPath p = new ActualPath("0.4567");
			String[] nodes = new String[] { ".123", ".234", ".345", ".456",
					".567", ".678", ".567", ".789" };
			p.addNodes(nodes);
			assertTrue(p.getPath().size() != p.getReducedPath().size());	
			assertTrue(p.getReducedPath().get(0).equals(".123"));
			assertTrue(p.getReducedPath().get(1).equals(".234"));
			assertTrue(p.getReducedPath().get(2).equals(".345"));
			assertTrue(p.getReducedPath().get(3).equals(".456"));
			assertTrue(p.getReducedPath().get(4).equals(".567"));
			assertTrue(p.getReducedPath().get(5).equals(".789"));
		} catch (Exception e) {
			assertTrue(false);
		}
	}
	
	@Test
	public void checkPathLowerUpperReduction() {
		try {
			// no reduction
			ActualPath p = new ActualPath("0.4567");
			String[] nodes = new String[] { ".123", ".234", ".123", ".345", ".456",
					".567", ".678", ".567", ".789" };
			p.addNodes(nodes);
			assertTrue(p.getPath().size() != p.getReducedPath().size());	
			assertTrue(p.getReducedPath().get(0).equals(".123"));
			assertTrue(p.getReducedPath().get(1).equals(".345"));
			assertTrue(p.getReducedPath().get(2).equals(".456"));
			assertTrue(p.getReducedPath().get(3).equals(".567"));
			assertTrue(p.getReducedPath().get(4).equals(".789"));
		} catch (Exception e) {
			assertTrue(false);
		}
	}
	
	@Test
	public void checkPathDoubleReduction() {
		try {
			// no reduction
			ActualPath p = new ActualPath("0.4567");
			String[] nodes = new String[] { ".123", ".234", ".234", ".123", ".345", ".456",
					".567", ".678", ".567", ".789", ".890", ".789" };
			p.addNodes(nodes);
			assertTrue(p.getPath().size() != p.getReducedPath().size());	
			assertTrue(p.getReducedPath().get(0).equals(".123"));
			assertTrue(p.getReducedPath().get(1).equals(".345"));
			assertTrue(p.getReducedPath().get(2).equals(".456"));
			assertTrue(p.getReducedPath().get(3).equals(".567"));
			assertTrue(p.getReducedPath().get(4).equals(".789"));
		} catch (Exception e) {
			assertTrue(false);
		}
	}
}
