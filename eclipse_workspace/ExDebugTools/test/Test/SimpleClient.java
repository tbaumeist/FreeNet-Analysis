package Test;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import DebugMessenger.DebugMessage;
import DebugMessenger.DebugMessengerClientSender;

public class SimpleClient {

	public SimpleClient(String ip, int port) throws Exception
	{
		DebugMessengerClientSender sender = new DebugMessengerClientSender(ip, port);
		BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
		
		System.out.println("Client set to connect to "+ip +":"+port);
		
		DebugMessage mess = new DebugMessage();
		mess.setUniqueId("localhost");
		mess.setMessageType("TestClient");
		String inputString = "";
        while ((inputString = r.readLine()) != null) {
            mess.setMessage(inputString);
            System.out.println("Client echo :"+inputString);
            sender.SendMessage(mess);
        }
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {
			if (args.length != 2) {
				System.out.println("Incorrect startup arguements. IP Port");
				return;
			}
			new SimpleClient(args[0], Integer.parseInt(args[1]));
		} catch (Exception e) {
			System.out.println("Error :" + e.getMessage());
			return;
		}
	}

}
