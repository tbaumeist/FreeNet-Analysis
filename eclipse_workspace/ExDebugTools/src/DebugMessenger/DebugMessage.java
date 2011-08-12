/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package DebugMessenger;

import java.io.*;
import java.util.Date;
import java.util.Hashtable;

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
    private transient Hashtable<String, String> _customProperties = new Hashtable<String, String>();
    private transient Date _recieved = null;
    
    public void setUniqueId(String s)
    {
        _uniqueId = s;
    }
    
    public String getUniqueId()
    {
    	return _uniqueId;
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
    
    public void setCustomProperty(String name, String value)
    {
    	_customProperties.put(name.toLowerCase(), value.toLowerCase());
    }
    
    public String getCustomProperty(String name)
    {
    	return _customProperties.get(name.toLowerCase());
    }
    
    public boolean hasCustomProperty(String name)
    {
    	return _customProperties.containsKey(name.toLowerCase());
    }

    public String toString() {
        String s = _uniqueId + "\t" + _messageType + "\t";
        if(_recieved != null)
        	s += "Rec:"+ _recieved.toString()+"\t";
        for(String key : _customProperties.keySet())
        	s += key+":" + _customProperties.get(key) +",\t";
        s += _message;
        return s;
    }

    private void writeObject(java.io.ObjectOutputStream out)
            throws IOException {
        out.defaultWriteObject();
        out.write(_customProperties.size());
        for(String key : _customProperties.keySet())
        {
        	out.writeObject(key);
        	out.writeObject(_customProperties.get(key));
        }
    }

    private void readObject(java.io.ObjectInputStream in)
            throws IOException, ClassNotFoundException {
    	
    	// marked as transient so must manually construct
    	// when it was serialized
    	_customProperties = new Hashtable<String, String>(); 
    	_recieved = new Date();
    	
        in.defaultReadObject();
        int size = in.read();
        for(int i =0; i < size; i++)
        {
        	String key = (String)in.readObject();
        	String value = (String)in.readObject();
        	_customProperties.put(key, value);
        }
    }
}

