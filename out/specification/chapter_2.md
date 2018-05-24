Ingesting Source Streams to Icecast2
====================================

Ingesting source streams to Icecast2 is implemented by sending a HTTP PUT to the mountpoint of the given stream. The server will then try to create the stream automatically based on the provided data and it's configuration.

> **Note**
>
> HTTP PUT was implemented in Icecast2 2.4.0-beta.2. Before that a custom extension was used using the HTTP method "SOURCE".

Protocol Specification
----------------------

### Overview

Sending data to the server is done by:

1.  Optionally a TLS connection is established between client and server.

2.  A PUT request is sent by the client without authentication data.

3.  Optionally the server may refuse the request if authentication is required.

4.  If the server refused the request because of missing authentication, the client then repeats the request with authentication data provided.

5.  Optionally the server replies with a 100-continue message.

6.  The client sends the stream in negotiated transfer encoding.

7.  The server replies with a final 200-OK.

8.  Client and server terminate the connection.

![ Transaction states for source connections ]

### 100-continue

The client should ask the server to send a 100-continue reply. This allows the server to reject the stream cleanly in case there is any problem. Such problems could be e.g. mismatch of credentials or unsupported parameters. Then the 100-continue reply is requested the server may reply with a 100-continue. The client should wait a reasonable long time before starting to provide data if no reply has been received yet.

The 100-continue reply is requested by adding the following header to the request header:

    Expect: 100-continue

> **Warning**
>
> Up to Icecast2 2.4.3 there is a bug that causes the TLS connection to be abnormally terminated when using 100-continue and TLS. This has been fixed in Icecast2 2.4.4 and 2.5.0-beta.2.

Examples
--------

This section lists example communication with an Icecast2 server for sending source streams. Information in &lt;&gt; are comments or special data.

> **Note**
>
> This section is not part of the specification.

### Successful communication with Authentication and 100-continue

This example demonstrates a successful communication between a Icecast2 server and a client using Authentication and 100-continue.

**Client to server: Initial request without authentication.**

The client sends an initial request to the server. The request does not contain any authentication data.

    PUT /example1.ogg HTTP/1.1
    Host: localhost:8000
    User-Agent: IceS 2.0.2
    Content-Type: application/ogg
    ice-public: 0
    ice-name: Example stream name
    ice-genre: Example genre
    ice-description: A short description of your stream
    ice-audio-info: samplerate=48000;channels=2;quality=3%2e00
    <blank line>

**Server to client: Initial response requesting authentication.**

The server replies to the server with status 401 "Authentication Required". This asks the client to authenticate and provides required information.

    HTTP/1.0 401 Authentication Required
    Server: Icecast 2.4.99.3
    Connection: Keep-Alive
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Date: Fri, 13 Apr 2018 08:16:31 GMT
    Content-Type: text/plain; charset=utf-8
    WWW-Authenticate: Basic realm="Icecast2 Server"
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    Content-Length: 26
    <blank line>

**Close to server: Repeated request with authentication.**

The client repeats it's request with authentication data as per request by the server.

    PUT /example1.ogg HTTP/1.0
    Host: localhost:8000
    Expect: 100-continue
    Authorization: Basic c291cmNlOmhhY2ttZQ== <Base64 of "source:hackme">
    User-Agent: IceS 2.0.2
    Content-Type: application/ogg
    ice-public: 0
    ice-name: Example stream name
    ice-genre: Example genre
    ice-description: A short description of your stream
    ice-audio-info: samplerate=48000;channels=2;quality=3%2e00
    <blank line>

**Server to client: 100-continue.**

The server replies with a 100-continue. The client can now assume that the request is likely to pass and can send the body.

    HTTP/1.1 100 Continue
    Server: Icecast 2.4.99.3
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Date: Fri, 13 Apr 2018 08:31:25 GMT
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    <blank line>

**Client to server: Client sends data.**

The client sends the stream data as body of it's second PUT request.

    <data>

**Server to client: Final response to client.**

After the client finished the server acknowledges the request and data by returning a final 200-OK response.

    HTTP/1.0 200 OK
    Server: Icecast 2.4.99.3
    Connection: Close
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Date: Fri, 13 Apr 2018 08:31:25 GMT
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    <blank line>

  [ Transaction states for source connections ]: ../../out/PUT.png
