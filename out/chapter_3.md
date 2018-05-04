Accessing a Icecast2 stream as listener
=======================================

Listener clients (audio and video) request streams by using HTTP GET.

Protocol Specification
----------------------

Listener clients request the corresponding stream using HTTP GET. Clients should send a HTTP/1.1 request. Icecast2 will respond with the stream if the request is successful or corresponding error code if not. Icecast2 may also require the client to authenticate before allowing access.

Examples
--------

### Successful communication without Authentication

This example demonstrates a successful communication between a Icecast2 server and a client.

**Client to server: Client requests the stream.**

The client sends it request for the given stream.

    GET /example1.ogg HTTP/1.1
    Host: localhost:8000
    User-Agent: Wget/1.16 (linux-gnu)
    Accept: */*
    Connection: Keep-Alive
    <blank line>

**Server to client: Response to client.**

The server does have the corresponding resource and allows access. Therefore it sends 200-OK and the content of the stream.

    HTTP/1.0 200 OK
    Server: Icecast 2.4.99.3
    Connection: Close
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Date: Wed, 18 Apr 2018 10:10:54 GMT
    Content-Type: application/ogg
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    ice-audio-info: samplerate=0;channels=0;quality=3%2e00
    icy-description:A short description of your stream
    icy-genre:Example genre
    icy-name:Example stream name
    icy-pub:0
    <blank line>
    <data>

### Successful communication with Authentication

This example demonstrates a successful communication between a Icecast2 server and a client. Authorization is used.

**Client to server: The client requests the stream with no authentication.**

The client sends the request for the stream without authentication data provided.

    GET /example1.ogg HTTP/1.1
    Host: localhost:8000
    User-Agent: Wget/1.16 (linux-gnu)
    Accept: */*
    Connection: Keep-Alive
    <blank line>

**Server to client: Refusal of the request by the server.**

The server informs the client that the given resource requires authentication. It also provides the required information for that.

    HTTP/1.0 401 Authentication Required
    Server: Icecast 2.4.99.3
    Connection: Keep-Alive
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Upgrade: TLS/1.0
    Date: Wed, 18 Apr 2018 12:08:30 GMT
    Content-Type: text/plain; charset=utf-8
    WWW-Authenticate: Basic realm="Icecast2 Server"
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    Content-Length: 26
    <blank line>
    You need to authenticate

**Client to server: The client resends the request with authentication.**

The client retries the request based on the provided information. It includes the authentication data as requested by the server.

    GET /example1.ogg HTTP/1.1
    Host: localhost:8000
    User-Agent: Wget/1.16 (linux-gnu)
    Accept: */*
    Connection: Keep-Alive
    Authorization: Basic bGlzdGVuZXI6aGFja21l <Base64 of "listener:hackme">
    <blank line>

**Server to client: Final response to client.**

The server responds with the stream mounted on the provided resource.

    HTTP/1.0 200 OK
    Server: Icecast 2.4.99.3
    Connection: Close
    Accept-Encoding: identity, chunked
    Allow: GET, PUT, SOURCE
    Upgrade: TLS/1.0
    Date: Wed, 18 Apr 2018 12:08:30 GMT
    Content-Type: application/ogg
    Cache-Control: no-cache
    Expires: Mon, 26 Jul 1997 05:00:00 GMT
    Pragma: no-cache
    Access-Control-Allow-Origin: *
    ice-audio-info: samplerate=0;channels=0;quality=3%2e00
    icy-description:A short description of your stream
    icy-genre:Example genre
    icy-name:Example stream name
    icy-pub:0
    <blank line>
    <data>
