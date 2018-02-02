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

### Initial Request Sent from Source Client to Server
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
#### Definitions
```ini
basic-credentials  = base64-user-pass
base64-user-pass   = <base64 [4] encoding of user-pass,
user-pass          = userid ":" password
userid             = *<TEXT excluding ":">
password           = *TEXT
```

### Response from Server
```http
HTTP/1.1 100 Continue
Date: Fri, 31 Dec 1999 23:59:59 UTC
Server: <server-identifier>
```


## Tested / Certified Source Clients

### Clients that are not tested but should be ok
