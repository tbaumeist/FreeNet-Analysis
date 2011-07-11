package Test;


import static org.junit.Assert.*;

import java.io.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import DebugMessenger.DebugMessage;
import DebugMessenger.DebugMessengerClientSender;

public class ClientSendMessage {

	private int _port = 8889;
	private String _ip = "127.0.0.1";
	private Process _server = null;
	private volatile String _lastOutputLine = "";
	private Thread _listener = null;
	
	@Before
	public void setUp() throws Exception {
		ProcessBuilder pb = new ProcessBuilder("java", "DebugServer.Server", ""+_port);
		pb.redirectErrorStream(true); // merges stderr and stdout
		pb.directory(new File("./bin"));
		_server = pb.start();
		final InputStream is = _server.getInputStream();
		_listener = new Thread(new Runnable() {
            public void run() {
                try {
                    BufferedReader br = new BufferedReader(new InputStreamReader(is));
                    String line;
                    while ((line = br.readLine()) != null) {
                    	_lastOutputLine = line;
                        System.out.println(line);
                    }
                } catch (java.io.IOException e) {
                }
            }
        });
		_listener.start();
		Thread.sleep(1000); // sleep giving server setup time
	}

	@After
	public void tearDown() throws Exception {
		if(_server != null)
			_server.destroy();
		if(_listener != null)
			_listener.interrupt();
		
		_lastOutputLine = "";
		_server = null;
		_listener = null;
		Thread.sleep(1000);
	}
	
	@Test
	public void sendMessageSuccess()
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender);
		assertTrue(_lastOutputLine.equals(mess.toString()));
		
		mess = sendMessage2(sender);
		assertTrue(_lastOutputLine.equals(mess.toString()));
		
		mess = sendMessage(sender);
		assertTrue(_lastOutputLine.equals(mess.toString()));
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
		assertTrue(_lastOutputLine.equals(mess.toString()));
		
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
		assertTrue(_lastOutputLine.equals(mess.toString()));
		
		mess = sendMessage2(sender);
		assertTrue(_lastOutputLine.equals(mess.toString()));
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
		sender.SendMessage(mess);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {} // sleep giving server time to respond
		return mess;
	}

}
