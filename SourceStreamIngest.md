# Ingesting Source Streams to Icecast

This document describes how a source client (e.g. an encoder) submits its 
content to an Icecast server instance. Only Icecast Server versions > 2.4.0 are 
covered by this specification, since the older versions used `SOURCE` as protcol
method, which isn't conform to HTTP standards.

## Protocol Specification

The Icecast protocol is a derivate of `HTTP 1.1`. It could be compared to a simple 
progressive upstream at a nearly constant and low bitrated (compared to what is 
nowadays possible).

### Conventions
The following conventions are valid for the whole section:
* Optional elements in communication are set in *italic* letters
* Encoding is always UTF-8
* Every line has to end with character CRLF (0x13 0x10)

### Communication Basis

PUT
TBD

### Example Client Server Communication 

**Initial request sent from source client to server**
```http
PUT <mountpoint> HTTP/1.1
Authorization: Basic <basic-credentials see definition below>
User-Agent: <source client description/version>
Transfer-Encoding: chunked
Content-Type: audio/mpeg
Ice-Public: 1
Ice-Name: Teststream
Ice-Description: This is just a simple test stream
Ice-URL: http://example.org
Ice-Genre: Rock
Expect: 100-continue
```
**Response from server**
```http
HTTP/1.1 100 Continue
Date: Fri, 31 Dec 1999 23:59:59 UTC
Server: <server-identifier>
```
**Source cLient continues sending data**
```http
<binary data>
```

### Authentication
Depending on the mountpoint's configuration, the server expects credentials 
before it allwos to accept the source stream. If a source client does not provide
userid and password in such a case, the server will respond with:

```http
HTTP/1.1 401 Unauthorized
Date: Fri, 31 Dec 1999 23:59:59 UTC
Server: <server-identifier>
```

Icecast's authentication is based on [RFC 7617][1]. The source client needs to 
add the following header to its request to provide the requested credentials:

```http
...
Authorization: Basic <basic-credentials see definition below>
...
```
**Definitions**
```ini
basic-credentials  = base64-user-pass
base64-user-pass   = <base64 [4] encoding of user-pass,
user-pass          = userid ":" password
userid             = *<TEXT excluding ":">
password           = *TEXT
```

### 100-Continue


## Tested / Certified Source Clients

### Clients that are not tested but should be ok

## References
[1]: https://tools.ietf.org/html/rfc7617
