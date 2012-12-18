package Test;

import org.junit.Test;

import DebugMessenger.DebugMessengerClientSender;
import static org.junit.Assert.*;

public class ClientTestLocks extends ClientBase {
	
	@Test
	public void insertLock()
	{
		try
		{
			DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
			sender.setInsertLock(true);
			assertTrue(sender.getInsertLock());
			
			sender.setInsertLock(false);
			assertFalse(sender.getInsertLock());
			
			sender.setInsertLock(true);
			assertTrue(sender.getInsertLock());
		}catch(Exception e)
		{
			assertTrue(false);
		}
	}
	
	@Test
	public void requestLock()
	{
		try
		{
			DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
			sender.setRequestLock(true);
			assertTrue(sender.getRequestLock());
			
			sender.setRequestLock(false);
			assertFalse(sender.getRequestLock());
			
			sender.setRequestLock(true);
			assertTrue(sender.getRequestLock());
		}catch(Exception e)
		{
			assertTrue(false);
		}
	}
}
