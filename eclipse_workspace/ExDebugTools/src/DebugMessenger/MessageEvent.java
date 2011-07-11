
package DebugMessenger;

import java.util.*;

/**
 *
 * @author Todd Baumeister
 */
public class MessageEvent<T> extends EventObject {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private T _data;

    public MessageEvent(Object source, T data) {
        super(source);
        _data = data;
    }

    public T getData()
    {
        return _data;
    }
}