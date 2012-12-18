package Test;

import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.Socket;

import org.junit.Test;

import DebugMessenger.DebugMessage;
import DebugMessenger.DebugMessengerClientSender;

public class ClientSendChkMessages extends ClientBase {
	
	@Test
	public void sendChkMessageSuccess()
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender(_ip, _port);
		DebugMessage mess = sendMessage(sender, "9734907#$05435:fkjs98", "456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendRegMessage(sender);
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, null, "456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, "t97349fllkjd435:fkjs98", "245687213556");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, null, "245687213556");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, null, "456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		// should not be logged
		mess = sendMessage(sender, null, "7456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, "9734907#$05435:fkjs98", "7456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, null, "7456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		// check if the server stored them correctly
		try {
			Socket socket = new Socket("localhost", _telnetPort);
			PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
			out.println("PrintChks");
			try{
				Thread.sleep(1000);
			}catch(Exception ex){}
			//assertTrue(_lastOutputLine.startsWith("t97349fllkjd435:fkjs98|") || _lastOutputLine.startsWith("9734907#$05435:fkjs98|"));
			out.println("reset");
			socket.close();
        } catch (IOException e) {
        	System.out.println(e.getMessage());
            return;
        }
        
        mess = sendMessage(sender, "9734907#$05435:fkjs98", "7456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		mess = sendMessage(sender, null, "7456872135");
		assertTrue(_lastOutputLine.contains(mess.getMessage()));
		
		// check if the server stored them correctly, again
		try {
			Socket socket = new Socket("localhost", _telnetPort);
			PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
			out.println("PrintChks");
			try{
				Thread.sleep(1000);
			}catch(Exception ex){}
			//assertTrue(_lastOutputLine.startsWith("9734907#$05435:fkjs98|7456872135"));
			socket.close();
        } catch (IOException e) {
        	System.out.println(e.getMessage());
            return;
        }
	}
	
	private DebugMessage sendMessage(DebugMessengerClientSender sender, String chk, String uid)
	{
		DebugMessage mess = new DebugMessage();
		mess.setUniqueId("localhost");
		mess.setMessageType("MESSAGE_TRACE");
		mess.setMessage("Hello World");
		if( chk != null)
			mess.setCustomProperty("MESSAGE_CHK", chk);
		if( uid != null)
			mess.setCustomProperty("MESSAGE_UID", uid);
		sender.SendMessage(mess);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {} // sleep giving server time to respond
		return mess;
	}
	
	private DebugMessage sendRegMessage(DebugMessengerClientSender sender)
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
}
