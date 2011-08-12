package DebugMessenger;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

public class ChkMessageTracker {
	public static final String CHK_PROP = "MESSAGE_CHK";
	public static final String UID_PROP = "MESSAGE_UID";
	private final String MESSAGE_TYPE = "MESSAGE_TRACE";
	
	private Hashtable<Long, String> _trackedUids = new Hashtable<Long, String>();
	private Hashtable<String, ArrayList<DebugMessage>> _messages = new Hashtable<String, ArrayList<DebugMessage>>();
	
	public boolean isChkMessage(DebugMessage dm)
	{
		if( dm == null ) return false;
		if(!dm.getMessageType().equalsIgnoreCase(MESSAGE_TYPE))
			return false;
		if( dm.hasCustomProperty(CHK_PROP))
			return true;
		
		if( dm.hasCustomProperty(UID_PROP))
		{
			long uid = Long.parseLong(dm.getCustomProperty(UID_PROP));
			if( _trackedUids.containsKey(uid))
				return true;
		}
		
		return false;
	}
	
	public void addMessage(DebugMessage dm)
	{
		if( dm == null)
			return;
		if( !dm.hasCustomProperty(UID_PROP) )
			return;
		
		long uid = Long.parseLong(dm.getCustomProperty(UID_PROP));
		
		if( dm.hasCustomProperty(CHK_PROP))
		{
			if( !_trackedUids.containsKey(uid))
				_trackedUids.put(uid, dm.getCustomProperty(CHK_PROP));
		}
		
		String chk = _trackedUids.get(uid);
		if(!_messages.containsKey(chk))
			_messages.put(chk, new ArrayList<DebugMessage>());
		
		_messages.get(chk).add(dm);
	}
	
	public String toString()
	{
		String s = "";
		s += "============================= Start Chk Trace ==========================\n";
		for(String chk : _messages.keySet())
		{
			s += chk+"\n";
			for(Long l : _trackedUids.keySet() )
			{
				if(_trackedUids.get(l).equalsIgnoreCase(chk))
					s += "\t"+l+"\n";
			}
		}
		s += "============================ End Chk Trace =============================\n";
		return s;
	}
	
	public String toStringChks()
	{
		String s = "";
		for(String chk : _messages.keySet())
		{
			s += chk+"|";
			for(Long l : _trackedUids.keySet() )
			{
				if(_trackedUids.get(l).equalsIgnoreCase(chk))
					s += l+",";
			}
			s = s.substring(0, s.length()-1); // remove last ,
			s += "|";
			for(String id : getUniqueIds(_messages.get(chk)))
				s += id +",";
			s = s.substring(0, s.length()-1); // remove last ,
			s += "\n";
		}
		return s;
	}
	
	private List<String> getUniqueIds(List<DebugMessage> lstMsg)
	{
		ArrayList<String> ids = new ArrayList<String>();
		for(DebugMessage m : lstMsg)
		{
			if(!ids.contains(m.getUniqueId()))
				ids.add(m.getUniqueId());
		}
		return ids;
	}
	
}
