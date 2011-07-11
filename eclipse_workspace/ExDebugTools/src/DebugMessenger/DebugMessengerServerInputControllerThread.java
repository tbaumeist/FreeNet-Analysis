/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.util.ArrayList;

import javax.swing.event.*;

/**
 *
 * @author Todd Baumeister
 */
public class DebugMessengerServerInputControllerThread extends Thread {

    private EventListenerList _onHelpList = new EventListenerList();
    private EventListenerList _onFilterList = new EventListenerList();
    private EventListenerList _onDumpList = new EventListenerList();
    private BufferedReader _input = null;
    private PrintStream _output = null;
    private String[] commands = new String[]{
        "Help",
        "Dump [MessageType] -All dumps all message types",
        "Filter [MessageType] [MessageType] -All doesn't filter any message types. Space between each filter type"
    };

    public DebugMessengerServerInputControllerThread(PrintStream output, BufferedReader input) {
        super("DebugMessengerServerInputController");
        _output = output;
        _input = input;
    }

    public void run() {

        try {

            printHelp();
            String inputString = "";
            while ((inputString = _input.readLine()) != null) {
                processLine(inputString.toLowerCase().trim());
            }


        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void printHelp() {
        _output.println("Available Commands:");
        for (String s : commands) {
            _output.println("\t" + s);
        }
        fireHelpEvent();
    }

    private void processLine(String line) {
        String[] parsedInput = line.split(" ");
        if (parsedInput.length < 1) {
            return;
        }

        if (parsedInput[0].equalsIgnoreCase(commands[0].split(" ")[0])) {
            printHelp();
        } else if (parsedInput[0].equalsIgnoreCase(commands[1].split(" ")[0])) {
            fireDumpEvent(parsedInput.length > 1?parsedInput[1]:"all");
        }else if (parsedInput[0].equalsIgnoreCase(commands[2].split(" ")[0])) {
        	ArrayList<String> filters = new ArrayList<String>();
        	for(int i = 1; i < parsedInput.length; i++)
        		filters.add(parsedInput[i].toLowerCase());
            fireFilterEvent(filters);
        }

    }

    public void addOnHelpEvent(MessageEventListener<String> event) {
        _onHelpList.add(MessageEventListener.class, event);
    }

    public void removeOnHelpEvent(MessageEventListener<String> event) {
        _onHelpList.add(MessageEventListener.class, event);
    }

    private void fireHelpEvent() {
        MessageEvent<String> ev = new MessageEvent<String>(this, "");
        Object[] listeners = _onHelpList.getListenerList();
        // Each listener occupies two elements - the first is the listener class
        // and the second is the listener instance
        for (int i = 0; i < listeners.length; i += 2) {
            if (listeners[i] == MessageEventListener.class) {
                ((MessageEventListener<String>) listeners[i + 1]).onMessageEventOccurred(ev);
            }
        }
    }

    public void addOnFilterEvent(MessageEventListener<ArrayList<String>> event) {
        _onFilterList.add(MessageEventListener.class, event);
    }

    public void removeOnFilterEvent(MessageEventListener<ArrayList<String>> event) {
        _onFilterList.add(MessageEventListener.class, event);
    }

    private void fireFilterEvent(ArrayList<String> filter) {
        MessageEvent<ArrayList<String>> ev = new MessageEvent<ArrayList<String>>(this, filter);
        Object[] listeners = _onFilterList.getListenerList();
        // Each listener occupies two elements - the first is the listener class
        // and the second is the listener instance
        for (int i = 0; i < listeners.length; i += 2) {
            if (listeners[i] == MessageEventListener.class) {
                ((MessageEventListener<ArrayList<String>>) listeners[i + 1]).onMessageEventOccurred(ev);
            }
        }
    }

    public void addOnDumpEvent(MessageEventListener<String> event) {
        _onDumpList.add(MessageEventListener.class, event);
    }

    public void removeOnDumpEvent(MessageEventListener<String> event) {
        _onDumpList.add(MessageEventListener.class, event);
    }

    private void fireDumpEvent(String messageType) {
        MessageEvent<String> ev = new MessageEvent<String>(this, messageType);
        Object[] listeners = _onDumpList.getListenerList();
        // Each listener occupies two elements - the first is the listener class
        // and the second is the listener instance
        for (int i = 0; i < listeners.length; i += 2) {
            if (listeners[i] == MessageEventListener.class) {
                ((MessageEventListener<String>) listeners[i + 1]).onMessageEventOccurred(ev);
            }
        }
    }
}
