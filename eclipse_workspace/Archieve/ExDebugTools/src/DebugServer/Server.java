package DebugServer;

import java.io.IOException;

import DebugMessenger.*;

public class Server {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		try {
			if (args.length < 2)
				throw new Exception(
						"Incorrect startup parameters. Must pass in a port number. [listening port] [telnet port]");

			int port = Integer.parseInt(args[0]);
			int telnet = Integer.parseInt(args[1]);
			System.out.println("Starting server on port "+ port+" w/ telnet "+telnet);
			new Server().runServer(port, telnet);
			
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
		System.out.println("Server Closed");
	}

	private void runServer(int listenPort, int telnetPort) throws IOException {
		DebugMessengerServer server = new DebugMessengerServer(System.out,
				System.in, listenPort, telnetPort);
		server.run();
	}

}
