package edu.umass.cs.reconfiguration.interfaces;

import java.io.IOException;
import java.net.InetSocketAddress;

import edu.umass.cs.gigapaxos.interfaces.ClientRequest;
import edu.umass.cs.gigapaxos.interfaces.NearestServerSelector;
import edu.umass.cs.gigapaxos.interfaces.Request;
import edu.umass.cs.gigapaxos.interfaces.RequestCallback;
import edu.umass.cs.reconfiguration.reconfigurationpackets.ClientReconfigurationPacket;
import edu.umass.cs.reconfiguration.reconfigurationpackets.ReplicableClientRequest;

/**
 * @author arun
 * 
 *         This interface should be implemented by any gigapaxos client
 *         implementation.
 */
public interface GigaPaxosClient {
	/**
	 * A blocking method to retrieve the result of executing {@code request}.
	 * 
	 * @param request
	 * @return The response obtained by executing {@code request}.
	 * @throws IOException
	 */
	public Request sendRequest(Request request) throws IOException;

	/**
	 * This method will automatically convert {@code request} to @
	 * {@link ClientRequest} via {@link ReplicableClientRequest} if necessary.
	 * 
	 * @param request
	 * @param callback
	 * @return Refer {@link #sendRequest(ClientRequest, RequestCallback)}.
	 * @throws IOException
	 */
	public Long sendRequest(Request request, RequestCallback callback)
			throws IOException;

	/**
	 * @param request
	 * @param callback
	 * @return The long request identifier of the request if sent successfully;
	 *         null otherwise.
	 * @throws IOException
	 */
	public Long sendRequest(ClientRequest request, RequestCallback callback)
			throws IOException;

	/**
	 * Sends {@code request} to the nearest server as determined by
	 * {@code redirector}, an interface that returns the nearest server from a
	 * set of server addresses.
	 * 
	 * @param request
	 * @param callback
	 * @param redirector
	 * @return Refer {@link #sendRequest(ClientRequest, RequestCallback)}.
	 * @throws IOException
	 */
	public Long sendRequest(ClientRequest request, RequestCallback callback,
			NearestServerSelector redirector) throws IOException;

	/**
	 * Sends {@code request} to the specified {@code server}.
	 * 
	 * @param request
	 * @param server
	 * @param callback
	 * @return Refer {@link #sendRequest(ClientRequest, RequestCallback)}.
	 * @throws IOException
	 */
	public Long sendRequest(ClientRequest request, InetSocketAddress server,
			RequestCallback callback) throws IOException;
}