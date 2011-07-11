/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.util.*;

/**
 *
 * @author Todd Baumeister
 */
public class DebugMessengerServer {

    private DebugMessengerServerListener _listener = null;
    private ArrayList<DebugMessage> _messages = new ArrayList<DebugMessage>();
    private PrintStream _output = null;
    private BufferedReader _input = null;
    private ArrayList<String> _currentMessageFilters = new ArrayList<String>();
    private int _messageCapacity = 800;

    public DebugMessengerServer(PrintStream output, InputStream input, int listenPort) {
        _output = output;
        _input = new BufferedReader(new InputStreamReader(input));
        _listener = new DebugMessengerServerListener(listenPort);
        _listener.addOnMessageRecievedEvent(new RecievedMessageEvent(this));
    }

    public void run() {
        // only one thread and it runs until termination
        DebugMessengerServerInputControllerThread inputControl =
                new DebugMessengerServerInputControllerThread(_output, _input);
        inputControl.addOnHelpEvent(new HelpedEvent(this));
        inputControl.addOnDumpEvent(new DumpEvent(this));
        inputControl.addOnFilterEvent(new FilterEvent(this));
        inputControl.start();

        _output.println("Server Starting");

        _listener.run();
        try {
            _input.close();
        } catch (IOException ex) {
            System.err.println("Error closing input stream");
        }
    }

    protected synchronized void addMessage(DebugMessage mess) {
        while(_messages.size() >= _messageCapacity)
        	_messages.remove(0);
        
    	_messages.add(mess);
        if (_currentMessageFilters.size() == 0
                || _currentMessageFilters.contains("all")
                || _currentMessageFilters.contains(mess.getMessageType())) {
            _output.println(mess);
        }
    }

    protected void showMessageCount() {
        _output.println("Current Number of Messages Stored = " + _messages.size());
    }

    protected void filterMessages(ArrayList<String> messageTypes) {
        _output.print("Filtering Messages of Type: ");
        for(String msg : messageTypes)
        	_output.print(msg+" ");
        if(messageTypes.size() == 0)
        	_output.print("all");
        _output.println();
        
        _currentMessageFilters.addAll(messageTypes);
    }

    protected void dumpMessage(String messageType) {
        _output.println("Dumping All Messages of Type: " + messageType);
        _output.println();
        for (DebugMessage mess : _messages) {
            if (messageType.equals("") || messageType.equalsIgnoreCase("all")
                    || mess.getMessageType().equalsIgnoreCase(messageType)) {
                _output.println(mess);
            }
        }
    }

    private class RecievedMessageEvent implements MessageEventListener<DebugMessage> {

        private DebugMessengerServer _server = null;

        public RecievedMessageEvent(DebugMessengerServer server) {
            _server = server;
        }

        public void onMessageEventOccurred(MessageEvent<DebugMessage> evt) {
            _server.addMessage(evt.getData());
        }
    }

    private class HelpedEvent implements MessageEventListener<String> {

        private DebugMessengerServer _server = null;

        public HelpedEvent(DebugMessengerServer server) {
            _server = server;
        }

        public void onMessageEventOccurred(MessageEvent<String> evt) {
            _server.showMessageCount();
        }
    }

    private class FilterEvent implements MessageEventListener<ArrayList<String>> {

        private DebugMessengerServer _server = null;

        public FilterEvent(DebugMessengerServer server) {
            _server = server;
        }

        public void onMessageEventOccurred(MessageEvent<ArrayList<String>> evt) {
            _server.filterMessages(evt.getData());
        }
    }

    private class DumpEvent implements MessageEventListener<String> {

        private DebugMessengerServer _server = null;

        public DumpEvent(DebugMessengerServer server) {
            _server = server;
        }

        public void onMessageEventOccurred(MessageEvent<String> evt) {
            _server.dumpMessage(evt.getData());
        }
    }
}
