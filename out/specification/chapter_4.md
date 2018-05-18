Accessing administration interface and API
==========================================

Both API and administration interface are mounted in the virtual directory `/admin` on the server. The administration interface is for administrator interaction only. It's pages are not machine readable. For machine readable access the API is used.

The API defines serveral endpoints. Each endpoint provides access to a specific aspect of the server. Most endpoints return data as XML. Some endpoints may also return plain text. Most endpoints require data. Those data can be provided by the client as GET or POST parameters. POST must not be used if a server if a server does not post POST in the `Allow:`-header for that resource.

> **Tip**
>
> A client can try a request using POST and retry using GET if the requested failed.

![ Transaction states for API connections ]

Common parameters
-----------------

`mount`  
The mount parameter is used to select the mount the operation is applied to. For requests that list data this filters the list to the given mountpoint by selecting only the given one. This parameter most not be used more than once.

API endpoints
-------------

### General endpoints

General endpoints operate on the server as a whole. They *do not accept* a `mount` parameter.

`reloadconfig`  
This API endpoint queues reload of the config.

> **Note**
>
> The config reload is only queued. The server has likely not yet reloaded the config when sending the reply to the client.

**Parameters.**

This endpoint requires no parameters.

`listmounts`  
This lists active mountpoints on the server. The server my exclude mounts that are hidden to the user issuing the request as well as mounts that are inactive.

**Parameters.**

This endpoint requires no parameters.

`manageauth`  
This endpoints allows to alter roles.

> **Note**
>
> This is not available in Icecast2 before 2.5.0-beta.1.

**Parameters.**

`id`  
This is the ID of the role to modify. The ID can be found in successful responses to requests to endpoint `stats`. This parameter is required.

`action`  
This is the action to perform. If not given a default of `list` is used.

`username`  
The name of the user to act on if any.

`password`  
The new password for the user if any.

**Actions.**

`list`  
List all users in the corresponding role. Not supported by all roles types.

`add`  
Add the given user to the role. This can not be used to update the user's password. Not supported by all roles types.

`delete`  
Delete the named user from the role. Not supported by all roles types.

### Mount specific endpoints

Mount speciffic endpoints operate on specific mounts. Therefore they *require* a `mount` parameter.

`listclients`  
This endpoint lists the listeners connected to a specific source.

`moveclients`  
This endpoint moves all clients from the source pointed to by `mount`

**Parameters.**

`destination`  
The mountpoint to move the listeners to.

`killclient`  
This kicks a listener client off the stream.

**Parameters.**

`id`  
This is the ID of the client to kill. The ID can be obtained using the `listclients` endpoint.

`killsource`  
This kills the source connection, emulating the effect of the source client disconnecting uncleanly.

**Parameters.**

This endpoint requires no additional parameters.

`fallbacks`  
This endpoint replaces the currently set fallback for the given mount with some other mountpoint.

**Parameters.**

`fallback`  
The mountpoint that should be set as fallback.

`metadata`  
This alters the metadata for ICY streams only. Other streams have metadata provided by the encoder.

> **Warning**
>
> This endpoint must not be used with any supported streaming format.

> **Note**
>
> It is considered an error to use this endpoint with streams generated using PUT.

**Parameters.**

`mode`  
This parameter is required. It must have the fixed value of `updinfo`

`song`  
This is an alias for `title`.

`title`  
Sets the title of the current track.

`artist`  
Sets the artist of the current track.

`charset`  
Charset `title` and `artist` are encoded in.

### Hybrid endpints

Hybrid endpoints operate on all mounts or a specific one. They *optionally* take a `mount` parameter.

`stats`  
This generates is list of information about the current server state. The provided information may be filtered by the server according to the user's permissions.

**Parameters.**

This endpoint requires no additional parameters.

  [ Transaction states for API connections ]: ../../out/API.png
