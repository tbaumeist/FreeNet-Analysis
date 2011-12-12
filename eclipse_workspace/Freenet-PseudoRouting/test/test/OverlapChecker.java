package test;

import java.util.List;

import org.junit.Test;

import static org.junit.Assert.*;

import pseudoRouting.Node;
import pseudoRouting.RedirectRange;


public class OverlapChecker {
	
	@Test
	public void checkOverlap(){
		
		RedirectRange r1, r2;
		Node n = new Node(0, "");
		
		// normal checks first
		
		// r1   |--------------|
		// r2        |---------------|
		r1 = new RedirectRange(n, .1, .5);
		r2 = new RedirectRange(n, .3, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1         |------------|
		// r2    |---------------------|
		r1 = new RedirectRange(n, .3, .5);
		r2 = new RedirectRange(n, .1, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1    |------------|
		// r2    |---------------------|
		r1 = new RedirectRange(n, .1, .5);
		r2 = new RedirectRange(n, .1, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1             |------------|
		// r2    |---------------------|
		r1 = new RedirectRange(n, .3, .8);
		r2 = new RedirectRange(n, .1, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1    |------------|
		// r2    |------------|
		r1 = new RedirectRange(n, .3, .8);
		r2 = new RedirectRange(n, .3, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1    |------------|
		// r2                     |------------|
		r1 = new RedirectRange(n, .3, .4);
		r2 = new RedirectRange(n, .5, .6);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		// r1    |------------|
		// r2                 |------------|
		r1 = new RedirectRange(n, .3, .4);
		r2 = new RedirectRange(n, .4, .6);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		
		// wraps around checks
		
		// r1   |-----0---------|
		// r2             |----------|
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .2, .6);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1   |-----0---------|
		// r2                     |----------|
		r1 = new RedirectRange(n, .8, .3);
		r2 = new RedirectRange(n, .4, .6);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		// r1   |-----0---------|
		// r2                   |----------|
		r1 = new RedirectRange(n, .8, .3);
		r2 = new RedirectRange(n, .3, .6);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		// r1                  |-----0---------|
		// r2     |----------|        
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .6, .7);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		// r1                  |-----0---------|
		// r2       |----------|        
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .6, .8);
		assertFalse(r1.overlaps(r2) || r2.overlaps(r1));
		
		// r1             |-----0---------|
		// r2     |----------|        
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .6, .9);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1     |-----0---------|
		// r2              |----|        
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .1, .3);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1     |----------0---------|
		// r2       |----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .7, .8);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		
		// r1     |----------0---------|
		// r2       |--------0----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .7, .3);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1         |------0---------|
		// r2       |--------0----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .5, .3);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1         |------0---------|
		// r2         |------0----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .6, .3);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1         |------0---------|
		// r2         |-----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .6, .9);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
		// r1         |------0---------|
		// r2                    |-----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .2, .4);
		assertTrue(r1.overlaps(r2) && r2.overlaps(r1));
		
	}
	
	@Test
	public void checkSplits(){
		RedirectRange r1, r2;
		List<RedirectRange> newRanges = null;
		Node n = new Node(0, "");
		
		// r1   |--------------|
		// r2        |---------------|
		r1 = new RedirectRange(n, .1, .5);
		r2 = new RedirectRange(n, .3, .8);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .3);
		assertTrue(newRanges.get(0).getStop() == .5);
		assertTrue(newRanges.get(1).getStart() == .5);
		assertTrue(newRanges.get(1).getStop() == .8);
		
		// r1        |---------------|
		// r2   |--------------|
		r1 = new RedirectRange(n, .3, .8);
		r2 = new RedirectRange(n, .1, .5);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .1);
		assertTrue(newRanges.get(0).getStop() == .3);
		assertTrue(newRanges.get(1).getStart() == .3);
		assertTrue(newRanges.get(1).getStop() == .5);
		
		// r1         |------------|
		// r2    |---------------------|
		r1 = new RedirectRange(n, .3, .5);
		r2 = new RedirectRange(n, .1, .8);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 3);
		assertTrue(newRanges.get(0).getStart() == .1);
		assertTrue(newRanges.get(0).getStop() == .3);
		assertTrue(newRanges.get(1).getStart() == .3);
		assertTrue(newRanges.get(1).getStop() == .5);
		assertTrue(newRanges.get(2).getStart() == .5);
		assertTrue(newRanges.get(2).getStop() == .8);
		
		// r1    |---------------------|
		// r2         |------------|
		r1 = new RedirectRange(n, .1, .8);
		r2 = new RedirectRange(n, .3, .5);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 1);
		assertTrue(newRanges.get(0).getStart() == .3);
		assertTrue(newRanges.get(0).getStop() == .5);
		
		// r1    |---------------------|
		// r2    |------------|
		r1 = new RedirectRange(n, .1, .8);
		r2 = new RedirectRange(n, .1, .5);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 1);
		assertTrue(newRanges.get(0).getStart() == .1);
		assertTrue(newRanges.get(0).getStop() == .5);
		
		// r1    |---------------------|
		// r2             |------------|
		r1 = new RedirectRange(n, .1, .8);
		r2 = new RedirectRange(n, .3, .8);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 1);
		assertTrue(newRanges.get(0).getStart() == .3);
		assertTrue(newRanges.get(0).getStop() == .8);
		
		// r1   |-----0---------|
		// r2             |----------|
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .2, .6);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .2);
		assertTrue(newRanges.get(0).getStop() == .4);
		assertTrue(newRanges.get(1).getStart() == .4);
		assertTrue(newRanges.get(1).getStop() == .6);
		
		// r1             |----------|
		// r2   |-----0---------|
		r1 = new RedirectRange(n, .2, .6);
		r2 = new RedirectRange(n, .8, .4);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .8);
		assertTrue(newRanges.get(0).getStop() == .2);
		assertTrue(newRanges.get(1).getStart() == .2);
		assertTrue(newRanges.get(1).getStop() == .4);
		
		// r1             |-----0---------|
		// r2     |----------|        
		r1 = new RedirectRange(n, .8, .4);
		r2 = new RedirectRange(n, .6, .9);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .6);
		assertTrue(newRanges.get(0).getStop() == .8);
		assertTrue(newRanges.get(1).getStart() == .8);
		assertTrue(newRanges.get(1).getStop() == .9);
		
		// r1     |----------| 
		// r2             |-----0---------|       
		r1 = new RedirectRange(n, .6, .9);
		r2 = new RedirectRange(n, .8, .4);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 2);
		assertTrue(newRanges.get(0).getStart() == .8);
		assertTrue(newRanges.get(0).getStop() == .9);
		assertTrue(newRanges.get(1).getStart() == .9);
		assertTrue(newRanges.get(1).getStop() == .4);
		
		// r1     |----------0---------|
		// r2       |--------0----|        
		r1 = new RedirectRange(n, .6, .4);
		r2 = new RedirectRange(n, .7, .3);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 1);
		assertTrue(newRanges.get(0).getStart() == .7);
		assertTrue(newRanges.get(0).getStop() == .3);
		
		// r1       |--------0----|   
		// r2     |----------0---------|
		r1 = new RedirectRange(n, .7, .3);
		r2 = new RedirectRange(n, .6, .4);
		newRanges = r1.splitRangeOverMe(r2);
		newRanges = r1.splitRangeOverMe(r2);
		assertTrue(newRanges.size() == 3);
		assertTrue(newRanges.get(0).getStart() == .6);
		assertTrue(newRanges.get(0).getStop() == .7);
		assertTrue(newRanges.get(1).getStart() == .7);
		assertTrue(newRanges.get(1).getStop() == .3);
		assertTrue(newRanges.get(2).getStart() == .3);
		assertTrue(newRanges.get(2).getStop() == .4);
	}

}
