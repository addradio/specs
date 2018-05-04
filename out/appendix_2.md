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

    https://icecast.example.org:8000/admin/metadata?mount=%2Fmystream.mp3&mode=updinfo&song=My+Song+Title
