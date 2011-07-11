package DebugServer;

import DebugMessenger.*;

public class Server {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		try {
			if (args.length != 1)
				throw new Exception(
						"Incorrect startup parameters. Must pass in a port number");

			int port = Integer.parseInt(args[0]);
			System.out.println("Starting server on port "+ port);
			new Server().runServer(port);
			
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
		System.out.println("Server Closed");
	}

	private void runServer(int port) {
		DebugMessengerServer server = new DebugMessengerServer(System.out,
				System.in, port);
		server.run();
	}

}
