/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;
import java.net.Socket;

/**
 *
 * @author Todd Baumeister
 */
public class ServerInputControllerThread extends Thread {

    private BufferedReader _input = null;
    private PrintStream _output = null;
    private ControllerInterface _ctrl;
    private String[][] commands = new String[][]
    {
    		{"Help", "Prints available commands."},
    		{"Reset", "Resets the server to the starting point."},
    		{"PrintChks", "Print all of the stores Chks."},
    		{"ArchiveChks" , "[file name] Archives all chk messages to the given file."},
    		{"Close", "Closes the telnet session."},
    		{"InsertAttackLock", "Used to get and set the insert attack coordination lock."},
    		{"RequestAttackLock", "Used to get and set the request attack coordination lock."}
    };
    private final int HELPCMD =  0, RESETCMD = 1, PRINTCHKCMD = 2, 
    		ARCHIVECHKCMD = 3, TELNETCMD = 4, INSATTLOCKCMD = 5, REQATTLOCK = 6;
    private final int CMD_CMD = 0, DESCRIPTION_CMD = 1;

    public ServerInputControllerThread(ControllerInterface ctrl, Socket socket) throws IOException
    {
    	this(	ctrl, 
    			new PrintStream(socket.getOutputStream()), 
    			new BufferedReader(new InputStreamReader(socket.getInputStream())));
    }
    public ServerInputControllerThread(ControllerInterface ctrl, PrintStream output, BufferedReader input) {
        super("DebugMessengerServerInputController");
        _ctrl = ctrl;
        _output = output;
        _input = input;
    }

    public void run() {
        try {
            //printHelp();
            String inputString = "";
            _output.print("CMD>");
            while ((inputString = _input.readLine()) != null) {
            	try {
            		processLine(inputString.toLowerCase().trim());
            	} catch (Exception e) {
                	_output.println("EXCEPTION: "+e.getMessage());
                }
                _output.print("CMD>");
            }
        } catch (Exception e) {
        	_output.println("EXCEPTION: "+e.getMessage());
        }
    }

    private void printHelp() {
        _output.println("Available Commands:");
        for (String[] com : commands) {
            _output.println("\t" + com[CMD_CMD] + " " + com[DESCRIPTION_CMD]);
        }
    }

    private void processLine(String line) throws Exception {
        String[] parsedInput = line.split(" ");
        if (parsedInput.length < 1) 
            return;
        
        String cmd = parsedInput[0];
        if (cmd.equalsIgnoreCase(commands[HELPCMD][CMD_CMD])) {
            printHelp();
        } else if (cmd.equalsIgnoreCase(commands[RESETCMD][CMD_CMD])) {
        	_ctrl.onReset();
        }else if (cmd.equalsIgnoreCase(commands[PRINTCHKCMD][CMD_CMD])) {
        	_ctrl.onPrintAllChks(_output);
        }else if (cmd.equalsIgnoreCase(commands[ARCHIVECHKCMD][CMD_CMD])) {
        	if (parsedInput.length < 2) 
                return;
        	_ctrl.onArchiveChkMessages(parsedInput[1]);
        }else if (cmd.equalsIgnoreCase(commands[TELNETCMD][CMD_CMD])) {
        	_ctrl.onClose();
        }
        else if (cmd.toLowerCase().startsWith(commands[INSATTLOCKCMD][CMD_CMD].toLowerCase())) {
        	if(cmd.toLowerCase().startsWith(commands[INSATTLOCKCMD][CMD_CMD].toLowerCase()+":"))
        	{
        		boolean value = cmd.toLowerCase().endsWith("true");
        		_ctrl.onSetInsertAttackLock(value);
        	}else
        	{
        		_ctrl.onGetInsertAttackLock(_output);
        	}
        }
        else if (cmd.toLowerCase().startsWith(commands[REQATTLOCK][CMD_CMD].toLowerCase())) {
        	if(cmd.toLowerCase().startsWith(commands[REQATTLOCK][CMD_CMD].toLowerCase()+":"))
        	{
        		boolean value = cmd.toLowerCase().endsWith("true");
        		_ctrl.onSetRequestAttackLock(value);
        	}else
        	{
        		_ctrl.onGetRequestAttackLock(_output);
        	}
        }

    }
}
