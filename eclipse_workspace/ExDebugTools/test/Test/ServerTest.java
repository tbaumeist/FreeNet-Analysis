package Test;



import static org.junit.Assert.*;

import java.io.*;
import java.net.Socket;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import DebugMessenger.DebugMessengerServer;


public class ServerTest {

	private int _port = 8889, _telnetPort = 8887;
	private String _ip = "127.0.0.1";
	private String _tmpFile = "/tmp/exdebugtool.dat";
	private Process _client = null;
	private Thread _clientListener = null;
	private PrintWriter _sender = null;

	@Before
	public void setUp() throws Exception {
		File f = new File(_tmpFile);
		f.delete();
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
		File f = new File(_tmpFile);
		f.delete();
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

		Thread t = new Thread(new Runnable(){
			public void run()
			{
				
				DebugMessengerServer server;
				try {
					server = new DebugMessengerServer(System.out, System.in, _port, _telnetPort);
					server.run();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
		t.start();
		try { // setup time for server
			Thread.sleep(1000);
		} catch (InterruptedException e) {}
		
		try {
			Socket socket = new Socket("localhost", _telnetPort);
			PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
			out.println("ArchiveChks "+ _tmpFile);
			socket.close();
        } catch (IOException e) {
        	System.out.println(e.getMessage());
            return;
        }

		_sender.println("JabberWokky");

		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {}
		
		File f = new File(_tmpFile);
		try {
			BufferedReader reader = new BufferedReader(new FileReader(f));
			String line = reader.readLine();
			assertTrue(line.contains("JabberWokky"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			assertTrue(false);
		}
	}

}
