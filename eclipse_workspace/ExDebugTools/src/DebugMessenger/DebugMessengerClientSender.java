/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.net.*;
import java.util.Calendar;
import java.util.Date;

/**
 * 
 * @author user
 */
public class DebugMessengerClientSender implements Runnable {

	private String _ip = "";
	private int _port;
	private DebugMessage _message = null;

	private static volatile boolean _connected = true;
	private static volatile Date _lastConnectionFail = null;
	private static final int _connectionRetry = 60; // seconds

	public DebugMessengerClientSender(String ip, int port) {
		_ip = ip;
		_port = port;
		_connected = true;
	}

	public void SendMessage(DebugMessage mess) {
		if(mess == null)
			return;
		_message = mess;
		run();
	}
	
	public boolean getInsertLock() throws Exception
	{
		Socket socket = openSocket(_ip, getTelnetPort());
		PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
		LockResponseReader response = new LockResponseReader(socket.getInputStream());
		response.start();
		out.println("InsertAttackLock");
		
		response.join(); // wait for response
		socket.close();
		return response.getResponse();
	}
	public boolean getRequestLock() throws Exception
	{
		Socket socket = openSocket(_ip, getTelnetPort());
		PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
		LockResponseReader response = new LockResponseReader(socket.getInputStream());
		response.start();
		out.println("RequestAttackLock");
		
		response.join(); // wait for response
		socket.close();
		return response.getResponse();
	}
	public void setInsertLock(boolean set) throws Exception
	{
		Socket socket = openSocket(_ip, getTelnetPort());
		PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
		out.println("InsertAttackLock:"+(set?"true":"false"));
		socket.close();
	}
	public void setRequestLock(boolean set) throws Exception
	{
		Socket socket = openSocket(_ip, getTelnetPort());
		PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
		out.println("RequestAttackLock:"+(set?"true":"false"));
		socket.close();
	}

	@Override
	public void run() {
		// TODO Auto-generated method stub

		if (!_connected) // reconnect code
		{
			Calendar now = Calendar.getInstance();
			now.add(Calendar.SECOND, -1 * _connectionRetry);
			if (_lastConnectionFail != null
					&& _lastConnectionFail.after(now.getTime())) {
				System.out.println("Remote debugger is not attached to the server.");
				return;
			}
		}

		try { // send message code
			Socket echoSocket = null;
			ObjectOutput out = null;

			try {
				echoSocket = openSocket(_ip, _port);
				out = new ObjectOutputStream(echoSocket.getOutputStream());
			} catch (UnknownHostException e) {
				System.out.println("Don't know about host: " + _ip);
				_connected = false;
				_lastConnectionFail = new Date();
				return;

			} catch (IOException e) {
				System.out.println("Couldn't get I/O for the connection to: "
						+ _ip);
				_connected = false;
				_lastConnectionFail = new Date();
				return;

			}

			out.writeObject(_message); // write data command

			out.close();
			echoSocket.close();
			
			_connected = true;

		} catch (IOException ex) {
			System.out.println(ex.getMessage());
			_connected = false;
			_lastConnectionFail = new Date();
		}
	}
	
	private Socket openSocket(String ip, int port) throws IOException
	{
		Socket socket = new Socket();
		socket.connect(new InetSocketAddress(ip, port), 5*1000);
		return socket;
	}
	
	private int getTelnetPort()
	{
		return _port-2;
	}
	
	private class LockResponseReader extends Thread
	{
		private boolean _response = false;
		private InputStream _input;
		public LockResponseReader(InputStream i)
		{
			_input = i;	
		}
		public boolean getResponse()
		{
			return _response;
		}
        public void run() {
            try {
                BufferedReader br = new BufferedReader(new InputStreamReader(_input));
                String line;
                while ((line = br.readLine()) != null) {
                    if(line.toLowerCase().contains("status:"))
					{
                    	System.out.println(line);
						_response = line.toLowerCase().contains("true");
						break;
					}
                }
            } catch (java.io.IOException e) {
            }
        }
    }
}
