/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.net.*;

/**
 *
 * @author Todd Baumeister
 */
public class ServerListener  extends Thread{

    private int _port;
    private ControllerInterface _ctrl;
    
    public enum listenerType{INPUT_LISTENER, TELNET_LISTENER, UNKNOWN};
    private listenerType _type = listenerType.UNKNOWN;
    
    public ServerListener(ControllerInterface ctrl, int listenPort, listenerType type)
    {
    	_ctrl = ctrl;
        _port = listenPort;
        _type = type;
    }

    public void run() {
        ServerSocket serverSocket = null;
        boolean listen = true;

        try {
            serverSocket = new ServerSocket(_port);
        } catch (IOException ex) {
            System.err.println("Could not listen on port: " + _port);
            System.exit(-1);
        }

		while (listen) {
			try {
				Thread thread = null;
				Socket socket = serverSocket.accept();
				switch (_type) {
				case INPUT_LISTENER:
					thread = new ServerWorkThread(_ctrl, socket);
					break;
				case TELNET_LISTENER:
					ControllerInterface ctrl = new ControllerTelnetThread(socket);
					thread = new ServerInputControllerThread(ctrl, socket);
					break;
				}
				if (thread != null)
					thread.start();
			} catch (IOException ex) {
				System.err.println("Unable to accept a connection");
			}
		}

        try {
            serverSocket.close();
        } catch (IOException ex) {
            System.err.println("Error closing server socket");
        }
    }
    private class ControllerTelnetThread extends ControllerInterface
	{
    	private Socket _socket = null;
    	public ControllerTelnetThread(Socket socket) throws IOException
    	{
    		_socket = socket;
    	}
		public void onArchiveChkMessages(String fileName) throws Exception {
			_ctrl.onArchiveChkMessages(fileName);
		}
		public void onPrintAllChks(PrintStream out) throws Exception {
			_ctrl.onPrintAllChks(out);
		}
		public void onReset() throws Exception {
			_ctrl.onReset();
		}
		public void onClose() throws Exception {
			if(_socket == null)
				return;
			_socket.close();
		}
		public boolean onGetInsertAttackLock(PrintStream out) throws Exception
		{
			return _ctrl.onGetInsertAttackLock(out);
		}
		public void onSetInsertAttackLock(boolean set) throws Exception
		{
			_ctrl.onSetInsertAttackLock(set);
		}
		public boolean onGetRequestAttackLock(PrintStream out) throws Exception
		{
			return _ctrl.onGetRequestAttackLock(out);
		}
		public void onSetRequestAttackLock(boolean set) throws Exception
		{
			_ctrl.onSetRequestAttackLock(set);
		}
	}
}
