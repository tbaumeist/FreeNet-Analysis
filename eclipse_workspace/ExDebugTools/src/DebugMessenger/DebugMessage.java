/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package DebugMessenger;

import java.io.*;

/**
 *
 * @author user
 */
public class DebugMessage implements Serializable {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String _uniqueId = "";
    private String _messageType = "";
    private String _message = "";

    public void setUniqueId(String s)
    {
        _uniqueId = s;
    }

    public void setMessageType(String s)
    {
        _messageType = s;
    }

    public void setMessage(String s)
    {
        _message = s;
    }

    public String getMessageType()
    {
        return _messageType;
    }
    
    public String getMessage()
    {
        return _message;
    }

    public String toString() {
        return _uniqueId + "\t" + _messageType + "\t" + _message;
    }

    private void writeObject(java.io.ObjectOutputStream out)
            throws IOException {
        out.defaultWriteObject();
    }

    private void readObject(java.io.ObjectInputStream in)
            throws IOException, ClassNotFoundException {
        in.defaultReadObject();
    }
}

