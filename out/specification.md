General communication with Icecast2
===================================

Communication with Icecast2 is based on HTTP. Icecast2 implements HTTP/1.0 with a set of features from HTTP/1.1 and some usecase specific extensions. In addition Icecast2 may support other protocols such as ICY.

Protocol Specification
----------------------

All Icecast2 clients connect to Icecast2 using the same server address. Mountpoints and general web access uses administrator provided resource names. The administration interface and API is available below the resource prefix "/admin".

Icecast2 implements HTTP/1.0. It understands most HTTP/1.1 requests. If interpretation of a request fails Icecast2 will send a HTTP/1.0 error reply depending on the reason of failure. If Icecast2 can not assume a HTTP client or the error occurs in early stages of client handling Icecast2 may drop the connection without sending data to the client.

### Status codes

The server may respond with any [RFC 7231 Section 6](https://tools.ietf.org/html/rfc7231#section-6) status code. Below is a incomplete list of important status codes:

| Status Code                                                                                                                                                             | Reason Phrase                 | UUID                                 | Body                 |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|--------------------------------------|----------------------|
| 100                                                                                                                                                                     | Continue                      |                                      | none                 |
| Is sent if client requested it by adding the corresponding header to its request: `Expect: 100-continue`. See also Section *100-continue*.                              |
| 101                                                                                                                                                                     | Switching Protocols           |                                      | none                 |
| This is sent by the server when the server performs a protocol switch as requested by the client. This may happen e.g. in *RFC 2818 mode*.                              |
| 200                                                                                                                                                                     | OK                            |                                      | depending on request |
| Sent after source client stopped                                                                                                                                        |
| 206                                                                                                                                                                     | Partial Content               |                                      | depending on request |
| The server's replies with a range from a range request. See [RFC 7233 Section 4.1](https://tools.ietf.org/html/rfc7233#section-4.1) for details.                        |
| 400                                                                                                                                                                     | Bad Request                   | 1ae45ead-40fc-4de2-b56f-e54d3247f2ee | Error report         |
| Source's mountpoint does not begin with a slash ("/").                                                                                                                  |
| 400                                                                                                                                                                     | Bad Request                   | 2cd86778-ac30-49e7-a108-26d627a7923b | Error report         |
| Header field `Content-Type` was not set but is mandatory. See also Section *Content Types*.                                                                             |
| 400                                                                                                                                                                     | Bad Request                   | ec16f654-f262-415f-ab91-95703ae33704 | Error report         |
| The client tried to upgrade to a protocol the server is not willing to upgrade to.                                                                                      |
| 400                                                                                                                                                                     | Bad Request                   | 811bddac-5be5-4580-9cde-7b849e66dfe5 | Error report         |
| The client sent an unrecognized API or admin command.                                                                                                                   |
| 400                                                                                                                                                                     | Bad Request                   | cb11dc71-6149-454c-8d4e-47a3af26b03a | Error report         |
| The request misses a GET or POST parameter that is required for request.                                                                                                |
| 400                                                                                                                                                                     | Bad Request                   | 00b9d977-f41d-455f-820f-6d457dffb246 | Error report         |
| API or admin request on a source that exists but is not available at this point.                                                                                        |
| 400                                                                                                                                                                     | Bad Request                   | 52735a81-16fe-4d7e-9984-5aed8a941055 | Error report         |
| API or admin request with destination source not available.                                                                                                             |
| 400                                                                                                                                                                     | Bad Request                   | 4be9a010-7a3f-44e4-b74d-3c6d9c4f7236 | Error report         |
| API or admin request points to same source for source and destination.                                                                                                  |
| 401                                                                                                                                                                     | Authentication Required       | 25387198-0643-4577-9139-7c4f24f59d4a | Error report         |
| No or invalid authentication data was provided. See also Section *Authentication*.                                                                                      |
| 404                                                                                                                                                                     | File Not Found                | 18c32b43-0d8e-469d-b434-10133cdd06ad | Error report         |
| The requested resource was not found on the server.                                                                                                                     |
| 404                                                                                                                                                                     | File Not Found                | f966870a-e3d1-4a33-a728-f0cbac0b90f3 | Error report         |
| Source related API or admin command not found.                                                                                                                          |
| 404                                                                                                                                                                     | File Not Found                | a96442e7-ca74-4ef7-8fcf-69ed057a5841 | Error report         |
| Global API or admin command not found.                                                                                                                                  |
| 404                                                                                                                                                                     | File Not Found                | 2f51a026-02e4-4fe4-bf9d-cc16557b3b65 | Error report         |
| Source does not exist.                                                                                                                                                  |
| 404                                                                                                                                                                     | File Not Found                | c5f1ee06-46a0-4697-9f01-6e9fc333d555 | Error report         |
| Destination does not exist.                                                                                                                                             |
| 404                                                                                                                                                                     | File Not Found                | 59fe9c81-8c34-49ff-800f-7ec42ea498be | Error report         |
| Role not found.                                                                                                                                                         |
| 405                                                                                                                                                                     | Method Not Allowed            | 78f590cc-8812-40d5-a4ef-17344ab75b35 | Error report         |
| The client used a method that was not understood by the server or is not allowed on the requested resource.                                                             |
| 409                                                                                                                                                                     | Conflict                      | c5724467-5f85-48c7-b45a-915c3150c292 | Error report         |
| The client sent a request for creation or manipulation of a mountpoint that already exists.                                                                             |
| 415                                                                                                                                                                     | Unsupported Media Type        | f684ad3c-513b-4d87-9a66-424788bc6adb | Error report         |
| Client's Content-Type is not supported by the server.                                                                                                                   |
| 416                                                                                                                                                                     | Request Range Not Satisfiable | 5874cc51-770b-42b5-82d2-737b2b406b30 | Error report         |
| The range that was requested by the client can not be satisfied by the server.                                                                                          |
| 426                                                                                                                                                                     | Upgrade Required              |                                      | Error report         |
| The client send the request using a protocol that is not permitted for the request. The client is required to upgrade the the protocol listed in the `Upgrade:`-Header. |
| 429                                                                                                                                                                     | Too Many Requests             | 9c72c1ec-f638-4d33-a077-6acbbff25317 | Error report         |
| The request was declined by the server as the client reached the concurrent connection limit of the used credentials.                                                   |
| 500                                                                                                                                                                     | Internal Server Error         | 47a4b11b-5d2a-46e2-8948-942e7b0af3e6 | Error report         |
| The server was unable to allocate the format.                                                                                                                           |
| 500                                                                                                                                                                     | Internal Server Error         | cda8203e-f237-4090-8d43-544efdd6295c | Error report         |
| The server was unable to reallocate internal buffers.                                                                                                                   |
| 500                                                                                                                                                                     | Internal Server Error         | a8b3c3fe-cb87-45fe-9a9d-ee4c2075d43a | Error report         |
| The server was unable to generate headers for a proper response.                                                                                                        |
| 500                                                                                                                                                                     | Internal Server Error         | d3c6e4b3-7d6e-4191-a81b-970273067ae3 | Error report         |
| The server was unable to render a XSLT document.                                                                                                                        |
| 501                                                                                                                                                                     | Unimplemented                 | 3bed51bb-a10f-4af3-9965-4e67181de7d6 | Error report         |
| The source does not accept metadata updates via ABI or admin command.                                                                                                   |
| 501                                                                                                                                                                     | Unimplemented                 | 7e1a8426-2ae1-4a6b-bfd9-59d8f8153021 | Error report         |
| Adding new users to role not supported by role.                                                                                                                         |
| 501                                                                                                                                                                     | Unimplemented                 | 367fbad1-389e-4292-bba8-c97984e616cc | Error report         |
| Deleting users from role not supported by role.                                                                                                                         |
| 501                                                                                                                                                                     | Unimplemented                 | 58ce6cb4-72b4-49da-8ad2-feaf775bc61e | Error report         |
| Client sent an request with a Transfer-Encoding not supported by the server.                                                                                            |
| 503                                                                                                                                                                     | Service Unavailable           | 26708754-8f98-4191-81d1-7fb7246200d6 | Error report         |
| Server is currently busy. Try again later.                                                                                                                              |
| 503                                                                                                                                                                     | Service Unavailable           | c770182d-c854-422a-a8e5-7142689234a3 | Error report         |
| Too many source are currently connected. Try again later.                                                                                                               |
| 503                                                                                                                                                                     | Service Unavailable           | 87fd3e61-6702-4473-b506-f616d27a142f | Error report         |
| Too many clients are currently connected. Try again later.                                                                                                              |
| 503                                                                                                                                                                     | Service Unavailable           | 18411e73-713e-4910-b7e4-52a2e324b4e0 | Error report         |
| Memory exhausted. Try again later.                                                                                                                                      |

### Authentication

Depending on operation and resource Icecast2 may require the client to authenticate. If such a resource is accessed in such a operation and no authentication data was sent along with the request Icecast2 will respond with the corresponding error status.

Authentication is based on [RFC 7617](https://tools.ietf.org/html/rfc7617). The client must send a request with no authentication first. The server will include information in it's error response on how to provide authentication data correctly. This step may be skipped according to the rules in RFC 7617 only.

The client must support the "Basic" authentication scheme.

### Transfer encodings

Icecast2 supports different transfer encodings for sending data to Icecast2. A client is free to choice any of what is supported by the server. An application must consider what transfer encodings are announced by the server.

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
> RFC 7230 Appendix A.2
> for details.

> **Tip**
>
> When chunked is not used as outermost transfer encoding the client can half-close the connection to signal the end of the request if the transport supports half-closed connections.
>
> On IEEE Std 1003.1 ("POSIX") systems this can be achieved calling `shutdown` with `SHUT_WR`.

### Metadata

Metadata is an important part of modern audio and video streaming. With Icecast2 metadata are transported as part of the transported datastream. All supported formats support metadata. Only for non-supported MP3 and AAC (and derivates) streams the ICY protocol must be used. This protocol is not part of this specification. For details see the corresponding documentation of the used streaming format. For ICY see the appendix in this document.

TLS
---

Icecast2 has TLS support included. Available TLS versions and options depend on the actual deployment. The following modes are supported:

| Mode     | min. Icecast2 version | Comment                       |
|----------|-----------------------|-------------------------------|
| RFC 2817 | Icecast2 2.3.2        | HTTP over TLS                 |
| RFC 2818 | Icecast2 2.5.0-beta.1 | Upgrade to TLS within HTTP[1] |

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

Accessing administration interface and API
==========================================

Tested and Certified Source Clients
===================================

ICY Protocol
============

> **Warning**
>
> This Appendix is informational only. It is not part of the specification.

The ICY source protocol is must not be used. The ICY listener protocol is however used for metadata transfer from Icecast2 to listeners for non-supported streaming formats such as MP3 and AAC. Those formats lack native support for metadata. Sources providing such formats to Icecast2 must use the described protocol using HTTP PUT. In addition they can use the corresponding API endpoint for metadata updates.

ICY listener protocol
---------------------

The ICY protocol is a protocol very similar to HTTP. Yet it is different protocol, not a HTTP dialect. ICY implements multiplexing actual data with metadata. To activate the ICY mode clients must pass the header `Icy-MetaData` set to `1` in the request. Icecast2 may reply with an ICY response including a `icy-metaint` header. If such a header is detected the client must switch to ICY mode. The response must not be interpreted as HTTP.

In ICY mode Icecast2 will send a block of metadata every `icy-metaint` bytes of payload. The metadata frame consists of a length byte and the metadata string. The length byte is the first byte in the frame. The frame length is 16 times the value of the length byte not including the length byte itself. The remainder of the frame is the frame is the metadata string. The is application specific. However it is common that the string is in format `Key0='Value0';Key1='Value1';[...]`. Common keys are `StreamTitle` and `StreamUrl` defining the current title, and URL for the stream. The frame is 0-byte-padded. If metadata is not to be updated a frame with the length byte of 0 is generated.

Metadata updates using API
--------------------------

> **Warning**
>
> This must not be used for streaming formats supporting metadata.

In order to update metadata for an ICY stream you must call the API endpoint `metadata`. The parameter `mount` must be set to the corresponding mount point. The parameter `mode` is set to the constant `updinfo`. The actual metadata are transported using the parameter `song`.

**Example URI.**

    https://icecast.example.org:8000/admin/metadata?mount=/mystream.mp3&mode=updinfo&song=My+Song+Title

[1] This is similar to what other protocols call "STARTTLS".
