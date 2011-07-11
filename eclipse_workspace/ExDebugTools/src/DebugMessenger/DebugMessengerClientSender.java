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
		/*Thread t = new Thread(this);
		t.start();
		try {
			// t.join(3000);
			t.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			// e.printStackTrace();
		}*/
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
				echoSocket = new Socket();
				echoSocket.connect(new InetSocketAddress(_ip, _port), 5*1000);
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
}
