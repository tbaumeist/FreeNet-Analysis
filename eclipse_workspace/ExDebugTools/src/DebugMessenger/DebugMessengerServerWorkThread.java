/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.net.*;
import javax.swing.event.*;

/**
 *
 * @author Todd Baumeister
 */
public class DebugMessengerServerWorkThread extends Thread {

    private EventListenerList _onMessageList = new EventListenerList();
    private Socket _socket = null;

    public DebugMessengerServerWorkThread(Socket socket) {
        super("DebugMessageServerWorkThread");
        _socket = socket;
    }

    public void run() {

        try {
            //PrintWriter out = new PrintWriter(_socket.getOutputStream(), true);
            ObjectInputStream in = new ObjectInputStream(_socket.getInputStream());

            DebugMessage mess = (DebugMessage) in.readObject();

            MessageEvent<DebugMessage> event = new MessageEvent<DebugMessage>(this, mess);

            Object[] listeners = _onMessageList.getListenerList();
            // Each listener occupies two elements - the first is the listener class
            // and the second is the listener instance
            for (int i = 0; i < listeners.length; i += 2) {
                if (listeners[i] == MessageEventListener.class) {
                    ((MessageEventListener<DebugMessage>) listeners[i + 1]).onMessageEventOccurred(event);
                }
            }

            //out.close();
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

    public void addOnMessageRecievedEvent(MessageEventListener<DebugMessage> event) {
        _onMessageList.add(MessageEventListener.class, event);
    }

    public void removeOnMessageRecievedEvent(MessageEventListener<DebugMessage> event) {
        _onMessageList.add(MessageEventListener.class, event);
    }
}
