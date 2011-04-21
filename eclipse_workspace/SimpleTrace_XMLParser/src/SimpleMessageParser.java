import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import javax.xml.parsers.*;
import javax.xml.soap.Node;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

public class SimpleMessageParser {
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {
			if (args.length != 2)
				throw new Exception(
						"Incorrect number of parameters: [Input file name] [Output file name]");

			InputStream in = new FileInputStream(args[0]);
			File w = new File(args[1]);
			SimpleMessageParser m = new SimpleMessageParser();
			m.Parse(in, w);
			System.out.println("Output written to " + args[1]);
		} catch (SAXParseException p) {
			System.out.println(p.getMessage() + " at location line="
					+ p.getLineNumber() + " column=" + p.getColumnNumber());
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}

	public class TraceHandler extends HandlerBase {
		private Document _out = null;
		private Element _currentParent = null;
		private ArrayList<Message> _messages = new ArrayList<Message>();
		private Message _currentMessage = null;
		private StringBuffer _accumulator = new StringBuffer();
		private DateFormat _formatter = new SimpleDateFormat(
				"MMM dd, yyyy HH:mm:ss:SSS");

		private class Message {
			public String messageType = null;
			public String to = null;
			public String from = null;
			public String current = null;
			public Date date = null;

			public boolean IsSentMessage() {
				return current.equals(from);
			}

			public boolean IsComplement(Message m) {
				if (m == null)
					return false;
				return messageType.equals(m.messageType) && to.equals(m.to)
						&& from.equals(m.from);
			}
		}

		public TraceHandler(Document out, Element currentParent) {
			_out = out;
			_currentParent = currentParent;
		}

		public void startElement(String name, AttributeList attrs) {
			_accumulator.setLength(0);

			if (name.equals("MessageTrace")) {
				Element trace = _out.createElement("MessageTrace");
				trace.setAttribute("uid", attrs.getValue("uid"));
				_currentParent.appendChild(trace);
				_currentParent = trace;
				_messages = new ArrayList<Message>();
			} else if (name.equals("Message")) {
				_currentMessage = new Message();
				_currentMessage.messageType = attrs.getValue("type");

				_messages.add(_currentMessage);
			}
		}

		public void endElement(String name) {
			if (name.equals("MessageTrace")) {
				processMessageTrace(_currentParent, _messages);
				_messages.clear();
				_currentParent = (Element) _currentParent.getParentNode();
			} else if (name.equals("To")) {
				_currentMessage.to = _accumulator.toString().trim();
			} else if (name.equals("From")) {
				_currentMessage.from = _accumulator.toString().trim();
			} else if (name.equals("Current")) {
				_currentMessage.current = _accumulator.toString().trim();
			} else if (name.equals("Date")) {
				try {
					String strDate = _accumulator.toString().trim();
					_currentMessage.date = (Date) _formatter.parse(strDate
							.replace("\n", ""));
					// System.out.println(_currentMessage.date.toString());
				} catch (Exception ex) {
					System.out.println(ex.getMessage());
				}
			}
		}

		public void characters(char[] buffer, int start, int length) {
			_accumulator.append(buffer, start, length);
		}

		private class MessagePair {
			public Message origin = null;
			public Message destination = null;

			public Date GetTime() {
				if (origin.date.before(destination.date))
					return origin.date;
				return destination.date;
			}

			public String GetType() {
				return origin.messageType;
			}

			public String GetTo() {
				return origin.to;
			}

			public String GetFrom() {
				return origin.from;
			}
		}

		private void processMessageTrace(Element currentParent,
				ArrayList<Message> messages) {
			Document doc = currentParent.getOwnerDocument();
			try {
				ArrayList<MessagePair> messagePairs = sortMessagePairs(messages);

				for (int i = 0; i < messagePairs.size(); i++) {
					MessagePair p = messagePairs.get(i);
					Element mess = doc.createElement("Message");
					mess.setAttribute("type", p.GetType());
					currentParent.appendChild(mess);
					Element to = doc.createElement("To");
					to.appendChild(doc.createTextNode(p.GetTo()));
					mess.appendChild(to);
					Element from = doc.createElement("From");
					from.appendChild(doc.createTextNode(p.GetFrom()));
					mess.appendChild(from);
					Element date = doc.createElement("Date");
					date.appendChild(doc.createTextNode(_formatter.format(p
							.GetTime())));
					mess.appendChild(date);
				}
			} catch (Exception ex) {
				Element error = doc.createElement("Error");
				error.appendChild(doc.createTextNode(ex.getMessage()));
				currentParent.appendChild(error);
			}
		}

		private ArrayList<MessagePair> sortMessagePairs(
				ArrayList<Message> messages) throws Exception {
			ArrayList<MessagePair> messPairs = new ArrayList<MessagePair>();
			ArrayList<Message> messagesCopy = new ArrayList<Message>();
			messagesCopy.addAll(messages);

			while (true) {
				if (messagesCopy.size() == 0)
					break;

				MessagePair pair = new MessagePair();

				// find next earliest sent message
				for (Message m : messagesCopy) {
					if (m.IsSentMessage()
							&& (pair.origin == null || pair.origin.date
									.after(m.date))) {
						pair.origin = m;
					}
				}
				messagesCopy.remove(pair.origin);

				if (pair.origin == null)
					throw new Exception(
							"Unmatched message recorded, no origin message found typically because of location of -1");

				if (pair.origin.to.equals("-1")
						|| pair.origin.from.equals("-1"))
					throw new Exception("Invalid location present, -1");

				// find the match
				for (Message m : messagesCopy) {
					if (!m.IsSentMessage()
							&& pair.origin.IsComplement(m)
							&& (pair.destination == null || pair.destination.date
									.after(m.date))) {
						pair.destination = m;
					}
				}
				messagesCopy.remove(pair.destination);

				if (pair.destination == null)
					throw new Exception(
							"Unmatched message recorded: typically a message location is -1, "
									+ pair.origin.messageType);

				messPairs.add(pair);
			}

			return messPairs;
		}
	}

	public void Parse(InputStream file, File out) throws Exception {
		DocumentBuilderFactory domFactory = DocumentBuilderFactory
				.newInstance();
		domFactory.setValidating(true);
		DocumentBuilder builder = domFactory.newDocumentBuilder();
		Document outDocument = builder.newDocument();
		Element root = outDocument.createElement("MessageTraces");
		outDocument.appendChild(root);

		SAXParserFactory factory = SAXParserFactory.newInstance();
		factory.setValidating(true);
		SAXParser parser = factory.newSAXParser();
		parser.parse(file, new TraceHandler(outDocument, root));

		// write the content into xml file
		TransformerFactory transformerFactory = TransformerFactory
				.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		DOMSource source = new DOMSource(outDocument);
		StreamResult result = new StreamResult(out);
		transformer.transform(source, result);

	}

}
