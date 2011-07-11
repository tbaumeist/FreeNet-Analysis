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
public class DebugMessengerServerListener {

    private EventListenerList _onMessageList = new EventListenerList();
    private int _port;
    
    public DebugMessengerServerListener(int listenPort)
    {
        _port = listenPort;
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
                DebugMessengerServerWorkThread thread = new DebugMessengerServerWorkThread(serverSocket.accept());
                thread.addOnMessageRecievedEvent(new MyEvent(this));
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

    private void fireOnMessageRecieved(MessageEvent<DebugMessage> evt)
    {
        Object[] listeners = _onMessageList.getListenerList();
        // Each listener occupies two elements - the first is the listener class
        // and the second is the listener instance
        for (int i = 0; i < listeners.length; i += 2) {
            if (listeners[i] == MessageEventListener.class) {
                ((MessageEventListener<DebugMessage>) listeners[i + 1]).onMessageEventOccurred(evt);
            }
        }
    }

    public void addOnMessageRecievedEvent(MessageEventListener<DebugMessage> event) {
        _onMessageList.add(MessageEventListener.class, event);
    }

    public void removeOnMessageRecievedEvent(MessageEventListener<DebugMessage> event) {
        _onMessageList.add(MessageEventListener.class, event);
    }

    private class MyEvent implements MessageEventListener<DebugMessage> {

        private DebugMessengerServerListener _server = null;

        public MyEvent(DebugMessengerServerListener server)
        {
            _server = server;
        }

        public void onMessageEventOccurred(MessageEvent<DebugMessage> evt)
        {
            _server.fireOnMessageRecieved(evt);
        }
    }
}
