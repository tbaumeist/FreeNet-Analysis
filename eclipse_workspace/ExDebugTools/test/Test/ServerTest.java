package Test;


import static org.junit.Assert.*;

import java.io.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import DebugMessenger.DebugMessage;
import DebugMessenger.DebugMessengerServer;

public class ServerTest {

	private int _port = 8889;
	private String _ip = "127.0.0.1";
	private Process _client = null;
	private Thread _clientListener = null;
	private PrintWriter _sender = null;

	@Before
	public void setUp() throws Exception {
		ProcessBuilder pb = new ProcessBuilder("java", "Test.SimpleClient", _ip,""+_port);
		pb.redirectErrorStream(true); // merges stderr and stdout
		pb.directory(new File("./bin"));
		_client = pb.start();
		_sender = new PrintWriter(new OutputStreamWriter(new BufferedOutputStream(_client.getOutputStream())), true);
		final InputStream is = _client.getInputStream();
		_clientListener = new Thread(new Runnable() {
            public void run() {
                try {
                    BufferedReader br = new BufferedReader(new InputStreamReader(is));
                    String line;
                    while ((line = br.readLine()) != null) {
                        System.out.println(line);
                    }
                } catch (java.io.IOException e) {
                }
            }
        });
		_clientListener.start();
		
		Thread.sleep(1000); // sleep giving server setup time
	}

	@After
	public void tearDown() throws Exception {
		if(_sender != null)
			_sender.close();
		if(_client != null)
			_client.destroy();
		if(_clientListener != null)
			_clientListener.interrupt();
		
		_sender = null;
		_client = null;
		_clientListener = null;
		Thread.sleep(1000);
	}
	
	@Test
	public void ClientSendMessage()
	{
		DebugMessage lastMess = null;
		Thread t = new Thread(new Runnable(){
			public void run()
			{
				DebugMessengerServer server = new DebugMessengerServer(System.out, System.in, _port);
				server.run();
			}
		});
		t.start();
		try { // setup time for server
			Thread.sleep(1000);
		} catch (InterruptedException e) {}
		
		_sender.println("JabberWokky");

		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {}
		
	}

}
