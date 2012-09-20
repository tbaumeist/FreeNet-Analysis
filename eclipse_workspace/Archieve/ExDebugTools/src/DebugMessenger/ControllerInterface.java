package DebugMessenger;

import java.io.PrintStream;

public class ControllerInterface {
	public void onMessageRecieved(DebugMessage message) throws Exception
	{throw new Exception("Method Not Implemented");};
	public void onReset() throws Exception 
	{throw new Exception("Method Not Implemented");};
	public void onPrintAllChks(PrintStream out) throws Exception 
	{throw new Exception("Method Not Implemented");};
	public void onArchiveChkMessages(String fileName) throws Exception
	{throw new Exception("Method Not Implemented");};
	public void onClose() throws Exception
	{throw new Exception("Method Not Implemented");};
	public boolean onGetInsertAttackLock(PrintStream out) throws Exception
	{throw new Exception("Method Not Implemented");};
	public void onSetInsertAttackLock(boolean set) throws Exception
	{throw new Exception("Method Not Implemented");};
	public boolean onGetRequestAttackLock(PrintStream out) throws Exception
	{throw new Exception("Method Not Implemented");};
	public void onSetRequestAttackLock(boolean set) throws Exception
	{throw new Exception("Method Not Implemented");};
}
