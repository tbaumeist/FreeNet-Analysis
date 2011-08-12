/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package DebugMessenger;

import java.io.*;

/**
 * 
 * @author Todd Baumeister
 */
public class DebugMessengerServer {

	private ServerListener _inputListener = null;
	private ServerListener _telnetListener = null;
	
	private ChkMessageTracker _chkTracker = new ChkMessageTracker();
	
	private boolean _insertAttackLock = false;
	private boolean _requestAttackLock = false;
	
	private PrintStream _output = null;
	private BufferedReader _input = null;
	
	private PrintStream _archiveOutput = null;

	public DebugMessengerServer(PrintStream output, InputStream input,
			int listenPort)  throws IOException 
	{
		this(output, input, listenPort, -1);
	}
	
	public DebugMessengerServer(PrintStream output, InputStream input,
			int listenPort, int telnetPort) throws IOException {
		_output = output;
		_input = new BufferedReader(new InputStreamReader(input));
		
		ControllerInterface ctrl = new ControllerInterface()
		{
			public void onMessageRecieved(DebugMessage message)  throws Exception{
				addMessage(message);
			}
		};
		_inputListener = new ServerListener(ctrl, listenPort, ServerListener.listenerType.INPUT_LISTENER);
		
		if(telnetPort > 0)
		{
			_telnetListener = new ServerListener(new ControllerTelnet(), telnetPort, ServerListener.listenerType.TELNET_LISTENER);
		}
	}

	public void run() {
		// only one thread and it runs until termination
		ServerInputControllerThread inputControl = new ServerInputControllerThread(
				new ControllerTelnet(), _output, _input);
		inputControl.start();

		println("Server Starting");

		_telnetListener.start();
		_inputListener.run(); // waits here until closed
		try {
			_input.close();
		} catch (IOException ex) {
			System.err.println("Error closing input stream");
		}
	}
	
	protected synchronized void archiveChkMessages(String fileName) throws IOException
	{
		if(_archiveOutput != null)
			_archiveOutput.close();
		_archiveOutput = null;
		
		if(fileName == null)
			return;
		
		File f = new File(fileName);
		f.createNewFile();
		_archiveOutput = new PrintStream(f);
	}

	protected synchronized void addMessage(DebugMessage mess) {
		if (_chkTracker.isChkMessage(mess)) {
			_chkTracker.addMessage(mess);

			printlnArchive(mess.toString());
		}

		println(mess.toString());
	}
	
	protected synchronized void reset() throws IOException
	{
		_chkTracker = new ChkMessageTracker();
		archiveChkMessages(null);
	}	
	
	private void println(String s)
	{
		_output.println(s);
	}
	
	private void printlnArchive(String s)
	{
		if(_archiveOutput == null)
			return;
		_archiveOutput.println(s);
	}
	
	private class ControllerTelnet extends ControllerInterface
	{
		public void onArchiveChkMessages(String fileName) throws Exception {
			archiveChkMessages(fileName);
		}
		public void onPrintAllChks(PrintStream out) throws Exception {
			out.print(_chkTracker.toStringChks());
		}
		public void onReset() throws Exception {
			reset();
		}
		public void onClose() throws Exception {
			println("CLOSE can only be used from the telnet interface.");
		}
		public boolean onGetInsertAttackLock(PrintStream out) throws Exception
		{
			if(_insertAttackLock)
				out.println("status:true");
			else
				out.println("status:false");
			return _insertAttackLock;
		}
		public void onSetInsertAttackLock(boolean set) throws Exception
		{
			_insertAttackLock = set;
		}
		public boolean onGetRequestAttackLock(PrintStream out) throws Exception
		{
			if(_requestAttackLock)
				out.println("status:true");
			else
				out.println("status:false");
			return _requestAttackLock;
		}
		public void onSetRequestAttackLock(boolean set) throws Exception
		{
			_requestAttackLock = set;
		}
	};
	
}
