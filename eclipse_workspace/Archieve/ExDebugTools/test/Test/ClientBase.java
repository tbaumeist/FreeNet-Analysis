package Test;


import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.junit.After;
import org.junit.Before;

public class ClientBase {

	protected String _ip = "127.0.0.1";
	protected int _port = 8889, _telnetPort = 8887;
	protected Process _server = null;
	protected Thread _listener = null;
	protected volatile String _lastOutputLine = "";
	
	@Before
	public void setUp() throws Exception {
		ProcessBuilder pb = new ProcessBuilder("java", "DebugServer.Server", ""+_port, ""+_telnetPort);
		pb.redirectErrorStream(true); // merges stderr and stdout
		pb.directory(new File("./bin"));
		_server = pb.start();
		final InputStream is = _server.getInputStream();
		_listener = new Thread(new Runnable() {
            public void run() {
                try {
                    BufferedReader br = new BufferedReader(new InputStreamReader(is));
                    String line;
                    while ((line = br.readLine()) != null) {
                    	_lastOutputLine = line;
                        System.out.println(line);
                    }
                } catch (java.io.IOException e) {
                }
            }
        });
		_listener.start();
		Thread.sleep(2000); // sleep giving server setup time
	}

	@After
	public void tearDown() throws Exception {
		if(_server != null)
			_server.destroy();
		if(_listener != null)
			_listener.interrupt();
		
		_lastOutputLine = "";
		_server = null;
		_listener = null;
		Thread.sleep(1000);
	}	
}
