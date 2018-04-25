General communication with Icecast2
===================================

Communication with Icecast2 is based on HTTP. Icecast2 implements HTTP/1.0 with a set of features from HTTP/1.1 and some usecase specific extensions. In addition Icecast2 may support other protocols such as ICY.

Protocol Specification
----------------------

All Icecast2 clients connect to Icecast2 using the same server address. Mountpoints and general web access uses administor provided resource names. The administration interface and API is available below the resource prefix "/admin".

Icecast2 implements HTTP/1.0. It understands most HTTP/1.1 requests. If interpretation of a request fails Icecast2 will send a HTTP/1.0 error reply depending on the reason of failture. If Icecast2 can not assume a HTTP client or the error occurs in early stages of client handling Icecast2 may drop the connection without sending data to the client.

### Error codes

The server may respond with any [RFC 7231 Section 6](https://tools.ietf.org/html/rfc7231#section-6) status code. Below is a incomplete list of important status codes:

| Code | Text                                                         | Description                                                                                                                                      |
|------|--------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| 100  | Continue                                                     | Is sent if client requested it by adding the corresponding header to its request: `Expect: 100-continue`. See also Section *100-continue*.       |
| 101  | Switching Protocols                                          | This is sent by the server when the server preforms a protocol switch as requested by the client. This may happen e.g. in *RFC 2818 mode*.       |
| 200  | OK                                                           | Sent after source client stopped                                                                                                                 |
| 206  | Partial Content                                              | The server's replies with a range from a range request. See [RFC 7233 Section 4.1](https://tools.ietf.org/html/rfc7233#section-4.1) for details. |
| 400  | Bad Request                                                  | The client sent a request that was not understood by the server.                                                                                 |
| 401  | Authentication Required                                      | No or invalid authentication data was provided. See also Section *Authentication*.                                                               |
| 403  | Content-type not supported                                   | The supplied content type is not supported. See also Section *Content Types*.                                                                    |
| 403  | No Content-type given                                        | Header field `Content-Type` was not set but is mandatory. See also Section *Content Types*.                                                      |
| 403  | internal format allocation problem                           | There was a problem allocating the format handler. This is an internal Icecast2 problem.                                                         |
| 403  | too many sources connected                                   | The Icecast2 instance' source client limit was reached. No more source connections are allowed.                                                  |
| 403  | Mountpoint in use                                            | The client tried to connect to an occupied mountpoint. That means, another source lient is connected already.                                    |
| 403  | busy, please try again later                                 | The server is busy. The client should try again later.[1]                                                                                        |
| 403  | Icecast connection limit reached                             | A server's client limit is reached. The client can try again later.                                                                              |
| 403  | Reached limit of concurrent connections on those credentials | The server refuses the client's request as the user reached it's request limit. See *Authentication* for details.                                |
| 403  | Rejecting client for whatever reason                         | The server refused the client for internal reasons.                                                                                              |
| 404  | File Not Found                                               | The requested resource was not found on the server.                                                                                              |
| 416  | Request Range Not Satisfiable                                | The range requested by the client is invalid or the resource can not provide the given range.                                                    |
| 426  | Upgrade Required                                             | The request sent by the client can not be handled with the current protocol. The protocol must be switched. See also *TLS*.                      |
| 500  | Internal Server Error                                        | An internal Icecast server error occured                                                                                                         |
| 501  | Unimplemented                                                | The request seems to be valid but uses an option that is unsuported by the server.                                                               |

### Authentication

Depending on operation and resource Icecast2 may require the client to authenticate. If such a resource is accessed in such a operation and no authentication data was sent along with the request Icecast2 will respond with the corresponding error status.

Authentication is based on [RFC 7617](https://tools.ietf.org/html/rfc7617). The client must send a request with no authentication first. The server will include information in it's error response on how to provide authentication data correctly. This step may be skipped according to the rules in RFC 7617 only.

The client must support the "Basic" authentication scheme.

### Transfer encodings

Icecast2 supports diffrent transfer encodings for sending data to Icecast2. A client is free to choice any of what is supported by the server. An application must consider what transfer encodings are announced by the server.

The transfer encoding is announced by the server using the `Accept-Encoding` HTTP header.

| Encoding | min. Icecast2 version | Comment                    |
|----------|-----------------------|----------------------------|
| identity | Icecast2 2.0.0        | This is the safe fallback. |
| chunked  | Icecast2 2.5.0-beta.1 |                            |

> **Warning**
>
> Prior to Icecast2 2.5.0-beta.1 the server did not return error in case a unsupported transfer encoding was used by the client. Those servers only support the "identity" encoding.

> **Note**
>
> RFC 7230 removed the "identity" encoding from the standard. See
> RFC 7230 Appendinx A.2
> for details.

> **Tip**
>
> When chunked is not used as outmost transfer encoding the client can half-close the connection to signal the end of the request if the transport supports half-closed connections.
>
> On IEEE Std 1003.1 ("POSIX") systems this can be achieved calling `shutdown` with `SHUT_WR`.

TLS
---

Icecast2 has TLS support included. Available TLS versions and options depend on the actual deployment. The following modes are supported:

| Mode     | min. Icecast2 version | Comment                       |
|----------|-----------------------|-------------------------------|
| RFC 2817 | Icecast2 2.3.2        | HTTP over TLS                 |
| RFC 2818 | Icecast2 2.5.0-beta.1 | Upgrade to TLS within HTTP[2] |

> **Note**
>
> Some older documentation may call TLS SSL.

Content Types
-------------

The following content types are support for streaming. Other content types my be used for non-streaming resources such as the administration interface and the API.

| Mime Type           | Container     | Codecs                                                  | min. Icecast2 version | Comment                                                           |
|---------------------|---------------|---------------------------------------------------------|-----------------------|-------------------------------------------------------------------|
| application/x-ogg   | Ogg           | *See application/ogg*                                   | Icecast2 2.0.0        | For backwards compatibility only. Do not use in new applications. |
| application/ogg     | Ogg           | Vorbis, Opus, FLAC, Speex, MIDI, Theora, Kate, Skeleton | Icecast2 2.3.2        |                                                                   |
| audio/ogg           | Ogg           | Vorbis, Opus, FLAC, Speex, MIDI, Skeleton               | Icecast2 2.3.2        |                                                                   |
| video/ogg           | Ogg           | Vorbis, Opus, FLAC, Speex, MIDI, Theora, Kate, Skeleton | Icecast2 2.3.2        |                                                                   |
| audio/webm          | WebM          | *Any as per WebM specification*                         | Icecast2 2.4.0-beta.1 |                                                                   |
| video/webm          | WebM          | *Any as per WebM specification*                         | Icecast2 2.4.0-beta.1 |                                                                   |
| audio/x-matroska    | Matroska      | *Any as per Matroska specification*                     | Icecast2 2.4.0-beta.1 |                                                                   |
| video/x-matroska    | Matroska      | *Any as per Matroska specification*                     | Icecast2 2.4.0-beta.1 |                                                                   |
| video/x-matroska-3d | Matroska      | *Any as per Matroska specification*                     | Icecast2 2.4.0-beta.1 |                                                                   |
| audio/mpeg          | MP3           | *ignored*                                               | Icecast2 2.0.0        | Handled as *any other* since Icecast2 2.2.0.                      |
| *any other*         | MP3, AAC, NSV | *ignored*                                               | Icecast2 2.2.0        | Deprecated. Handled using a generic format handler.               |

| Codec       | Containers          | min. Icecast2 version | Comment                                   |
|-------------|---------------------|-----------------------|-------------------------------------------|
| Vorbis      | Ogg, WebM, Matroska |                       |                                           |
| Opus        | Ogg, WebM, Matroska |                       |                                           |
| FLAC        | Ogg                 |                       |                                           |
| Speex       | Ogg                 |                       | Deprecated.                               |
| MIDI        | Ogg                 |                       |                                           |
| Theora      | Ogg                 |                       |                                           |
| Kate        | Ogg                 |                       |                                           |
| Skeleton    | Ogg                 |                       |                                           |
| *any other* | WebM, Matroska      |                       | Supported as per container specification. |

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

3.  Optionally the server may refuse the request if authentication is required. The client then repeats the request with authentication data provided.

4.  Optionally the server replies with a 100-continue message.

5.  The client sends the stream in negotiated transfer encoding.

6.  The server replies with a final 200-OK.

7.  Client and server terminate the connection.

### 100-continue

The client should ask the server to send a 100-continue reply. This allows the server to reject the stream cleanly in case there is any problem. Such problems could be e.g. missmatch of credentials or unsupported parameters. Then the 100-continue reply is requested the server may reply with a 100-continue. The client should wait a resonable long time before starting to provide data if no reply has been received yet.

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

### Successfull communication with Authentication and 100-continue

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

Accessing a Icecast2 stream as listener
=======================================

Listener clients (audio and video) request streams by using HTTP GET.

Protocol Specification
----------------------

Listener clients request the corresponding stream using HTTP GET. Clients should send a HTTP/1.1 request. Icecast2 will respond with the stream if the request is successful or corresponding error code if not. Icecast2 may also require the client to authenticate before allowing access.

Examples
--------

### Successfull communication without Authentication

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

### Successfull communication with Authentication

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

Accessing administration interface and API
==========================================

Tested and Certified Source Clients
===================================

[1] This most likely indicates that the server is under heavy load or that backend servers do not keep up with requests from Icecast2. The client should not repeat the request too soon. A delay of at least a few seconds is strongly recommended.

[2] This is similar to what other protocols call "STARTTLS".
