package Test;


import static org.junit.Assert.*;

import org.junit.Test;

import DebugMessenger.DebugMessage;
import DebugMessenger.DebugMessengerClientSender;

public class ClientSendMessage extends ClientBase {
	
	@Test
	public void sendMessageSuccess()
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage2(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
	}
	
	@Test
	public void sendMessageNoServer()
	{
		// shutdown server
		try {
			tearDown();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender);
		
		assertFalse(_lastOutputLine.equals(mess.toString()));
	}
	
	@Test
	public void sendMessagesSeverShutdown()
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		// shutdown server
		try {
			tearDown();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		mess = sendMessage(sender);
		assertFalse(_lastOutputLine.equals(mess.toString()));
	}
	
	@Test
	public void sendMessagesSeverRestart()
	{
		// shutdown server
		try {
			tearDown();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender);
		assertFalse(_lastOutputLine.equals(mess.toString()));
		
		// start up server
		try {
			setUp();
		} catch (Exception e) {
			e.printStackTrace();
		}
		// there is a 1 minute retry time on the client sender
		mess = sendMessage(sender);
		assertFalse(_lastOutputLine.equals(mess.toString()));
		
		System.out.println("Sleeping for 1 minute to simulate work......");
		try {
			Thread.sleep(60*1000); // sleep 1 minutes
		} catch (InterruptedException e) {} 
		
		mess = sendMessage(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage2(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
	}
	
	@Test
	public void sendMessageWrongIP()
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender("169.123.123.123", _port);
		DebugMessage mess = sendMessage(sender);
		
		assertFalse(_lastOutputLine.equals(mess.toString()));
	}
	
	private DebugMessage sendMessage(DebugMessengerClientSender sender)
	{
		DebugMessage mess = new DebugMessage();
		mess.setUniqueId("localhost");
		mess.setMessageType("Test");
		mess.setMessage("Hello World");
		mess.setCustomProperty("URL", "http://www.google.com");
		sender.SendMessage(mess);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {} // sleep giving server time to respond
		return mess;
	}
	
	private DebugMessage sendMessage2(DebugMessengerClientSender sender)
	{
		DebugMessage mess = new DebugMessage();
		mess.setUniqueId("localhost");
		mess.setMessageType("Test");
		mess.setMessage("Good Bye");
		mess.setCustomProperty("URL", "http://www.digg.com");
		sender.SendMessage(mess);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {} // sleep giving server time to respond
		return mess;
	}

}
