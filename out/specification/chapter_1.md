General communication with Icecast2
===================================

Communication with Icecast2 is based on HTTP. Icecast2 implements HTTP/1.0 with a set of features from HTTP/1.1 and some usecase specific extensions. In addition Icecast2 may support other protocols such as ICY.

Protocol Specification
----------------------

All Icecast2 clients connect to Icecast2 using the same server address. Mountpoints and general web access uses administrator provided resource names. The administration interface and API is available below the resource prefix "/admin".

Icecast2 implements HTTP/1.0. It understands most HTTP/1.1 requests. If interpretation of a request fails Icecast2 will send a HTTP/1.0 error reply depending on the reason of failure. If Icecast2 can not assume a HTTP client or the error occurs in early stages of client handling Icecast2 may drop the connection without sending data to the client.

### Request headers

Any kind of client must send a proper HTTP request. There are some header fields a client must or should include.

**Mandatory header fields.**

`Host:`  
Any client must send a `Host:`-header. If the underlying transport supports ports the port must be given in the header. The client must send the `Host:`-headr als the first header after the request line. All other considerations of [RFC 7230 Section 5.4] stay valid.

`Accept:`  
Any client must send a `Accept:`-header listening acceptable content encodings. All other considerations of [RFC 7231 Section 5.4.2] stay valid.

`User-Agent:`  
Any cliet must send a `User-Agent:`-header. All other considerations of [RFC 7231 Section 5.5.3] stay valid.

**Optional header fields.**

`Referer:`  
Any client that was directed to the requested resource by another resource must include a `Referer:`-header. All other considerations of [RFC 7231 Section 5.5.2] stay valid.

`From:`  
Any client may send a `From:`-header to allow contacting the operator in case of problems. All other considerations of [RFC 7231 Section 5.5.1] stay valid.

`Accept-Charset:`  
All clients should send a `Accept-Charset:`-header to inform the server about charsets the client supports. Every client must support UTF-8. All other considerations of [RFC 7231 Section 5.3.3] stay valid.

`Accept-Language:`  
All clients should send a `Accept-Language:`-header. This allows to the server to select a response in a language understood by the operator. All other considerations of [RFC 7231 Section 5.5.5] stay valid.

### Status codes

The server may respond with any [RFC 7231 Section 6] status code. Below is a incomplete list of important status codes:

| Status Code                                                                                                                                                             | Reason Phrase                 | UUID                                 | Body                 |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|--------------------------------------|----------------------|
| 100                                                                                                                                                                     | Continue                      |                                      | none                 |
| Is sent if client requested it by adding the corresponding header to its request: `Expect: 100-continue`. See also Section *100-continue*.                              |
| 101                                                                                                                                                                     | Switching Protocols           |                                      | none                 |
| This is sent by the server when the server performs a protocol switch as requested by the client. This may happen e.g. in *RFC 2818 mode*.                              |
| 200                                                                                                                                                                     | OK                            |                                      | depending on request |
| Sent after source client stopped                                                                                                                                        |
| 206                                                                                                                                                                     | Partial Content               |                                      | depending on request |
| The server's replies with a range from a range request. See [RFC 7233 Section 4.1] for details.                                                                         |
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

Authentication is based on [RFC 7617]. The client must send a request with no authentication first. The server will include information in it's error response on how to provide authentication data correctly. This step may be skipped according to the rules in RFC 7617 only.

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

### Tansport states

![ Transport connection states Physical connection refers to OSI layer 1 to 4 while logical connecting refering to any layer 4 to 7 protocol used between the physical connection and HTTP such as TLS. If no such protocol is used the logical connection is considered to share the connection state of the phsyical connection. ]

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

[1] This is similar to what other protocols call "STARTTLS".

  [RFC 7230 Section 5.4]: https://tools.ietf.org/html/rfc7230#section-5.4
  [RFC 7231 Section 5.4.2]: https://tools.ietf.org/html/rfc7231#section-5.3.2
  [RFC 7231 Section 5.5.3]: https://tools.ietf.org/html/rfc7231#section-5.5.3
  [RFC 7231 Section 5.5.2]: https://tools.ietf.org/html/rfc7231#section-5.5.2
  [RFC 7231 Section 5.5.1]: https://tools.ietf.org/html/rfc7231#section-5.5.1
  [RFC 7231 Section 5.3.3]: https://tools.ietf.org/html/rfc7231#section-5.3.3
  [RFC 7231 Section 5.5.5]: https://tools.ietf.org/html/rfc7231#section-5.5.5
  [RFC 7231 Section 6]: https://tools.ietf.org/html/rfc7231#section-6
  [RFC 7233 Section 4.1]: https://tools.ietf.org/html/rfc7233#section-4.1
  [RFC 7617]: https://tools.ietf.org/html/rfc7617
  [ Transport connection states Physical connection refers to OSI layer 1 to 4 while logical connecting refering to any layer 4 to 7 protocol used between the physical connection and HTTP such as TLS. If no such protocol is used the logical connection is considered to share the connection state of the phsyical connection. ]: ../../out/Transport.png
