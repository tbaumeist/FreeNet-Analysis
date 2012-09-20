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
public class ServerWorkThread extends Thread {
    private Socket _socket = null;
    private ControllerInterface _ctrl;

    public ServerWorkThread(ControllerInterface ctrl, Socket socket) {
        super("DebugMessageServerWorkThread");
        _ctrl = ctrl;
        _socket = socket;
    }

	public void run() {

        try {
            ObjectInputStream in = new ObjectInputStream(_socket.getInputStream());
            DebugMessage mess = (DebugMessage) in.readObject();
            _ctrl.onMessageRecieved(mess);
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                _socket.close();
            } catch (IOException ex) {
                System.err.println("Error closing server socket");
            }
        }
    }
}
