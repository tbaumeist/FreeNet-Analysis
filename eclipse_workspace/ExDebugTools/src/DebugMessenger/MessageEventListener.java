
package DebugMessenger;

import java.util.*;

/**
 *
 * @author Todd Baumeister
 */
public interface MessageEventListener<T> extends EventListener {
    public void onMessageEventOccurred(MessageEvent<T> evt);
}
