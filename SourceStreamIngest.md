# Ingesting Source Streams to Icecast

This document describes how a source client (e.g. an encoder) submits its 
content to an Icecast server instance. Only Icecast Server versions > 2.4.0 (May 2014) are 
covered by this specification, since the older versions used `SOURCE` as protcol
method, which isn't conform to HTTP standards.

## Contents
* [**Protocol Specification**](#protocol-specification)
** [**Conventions**](#conventions)
** [**Communication Basics**](#communication-basics)

## Protocol Specification

The Icecast protocol is a derivate of `HTTP 1.1`. It could be compared to a simple 
progressive upstream at a nearly constant and low bitrate (compared to what is 
nowadays possible).

### Conventions
The following conventions are valid for the whole section:
* Optional elements in communication are set in *italic* letters
* Encoding is always UTF-8
* Every line has to end with character CRLF (0x13 0x10)

### Communication Basics

1. PUT
1. No chunked transfer encoding!
1. Timing is important

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
**Source client continues sending data**
```http
<binary data>
```
### Response Status Codes

[//]: # (SEBASTIAN Is 200 sent at all?)

**Status Code** | **Description**
--------------- | -----------------
**100** Continue                    | Is sent if client requested it by adding the corresponding header to its request: `Expect: 100-continue`. See also Section [**100-Continue**](#100-continue).
**200** OK                          | Sent after source client stopped
**401** You need to authenticate    | Authentication failed. See also Section [**Authentication**](#authentication).
**403** Content-type not supported  | The supplied content type is not supported. See also Section [**Content Types**](#content-types).
**403** No Content-type given       | Header field `Content-Type` was not set but is mandatory. See also Section [**Content Types**](#content-types).
**403** internal format allocation problem | There was a problem allocating the format handler, this is an internal Icecast problem.
**403** too many sources connected  | The Icecast instance' source client limit was reached. No more connections are allowed.
**403** Mountpoint in use           | The client tried to connect to an occupied mountpoint. That means, another client is connected already.
**500** Internal Server Error       | An internal Icecast server error occured.

### 100-Continue
The client can send an `Excpect` header field to tell the server it shall acknowledge 
the request and verify that sending data is allowed. This behaviour isn't mandatory but 
highly recommended espacially in combination with authorization.

**Expect header in source client request**
```http
...
Expect: 100-continue
...
```
> **Take care:** If the client sends the expect header it is not allowed to send the payload bytes 
> directly! It has to wait until the server responded with `100 Continue`.

**Server responds with 100 Continue if everything is fine**
```http
HTTP/1.1 100 Continue
Date: Fri, 31 Dec 1999 23:59:59 UTC
Server: <server-identifier>
```
**Source client starts sending binary data**
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

Icecast's authentication is based on [RFC 7617][rfc7617]. The source client needs to 
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

### Content Types

### Meta Data


## Tested / Certified Source Clients

### Clients that are not tested but should be ok

[rfc7617]: https://tools.ietf.org/html/rfc7617  "RFC 7617"
