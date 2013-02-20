OpenStack Database API v1
=========================

The Database API primarily fulfills administrative functionality for various
database implementations. The api instruments a virtual database appliance
and takes care of ongoing administration and uptime of the database service.

API Conventions
---------------

The Database API provides a RESTful JSON and XML interface.

Each REST resource contains a canonically unique identifier (ID) defined by the
Database service implementation and is provided as the `id` attribute; Resource
ID's are strings of non-zero length.

The resource paths of all collections are plural and are represented at the
root of the API (e.g. `/v1/entities`).

### Required Attributes

Headers:

 - `X-Auth-Token`

   This header is used to convey the authentication token when accessing
   Database APIs.

For collections:

- `links` (object)

  Specifies a list of relational links to the collection.

  - `self` (url)

    A self-relational link provided as an absolute URL. This attribute is
    provided by the database service implementation.

  - `previous` (url)

    A relational link to the previous page of the list, provided as an absolute
    URL. This attribute is provided by the database service implementation. May
    be null.

  - `next` (url)

    A relational to the next page of the list, provided as an absolute URL.
    This attribute is provided by the database service implementation. May be
    null.

For members:

- `id` (string)

  Globally unique resource identifier. This attribute is provided by the
  database service implementation.

- `links` (object)

  Specifies a set of relational links relative to the collection member.

  - `self` (url)

    A self-relational link provided as an absolute URL. This attribute is
    provided by the database service implementation.

### CRUD Operations

Unless otherwise documented, all resources provided by the Identity API
support basic CRUD operations (create, read, update, delete).

The examples in this section utilize a resource collection of Entities on
`/v1/entities` which is not actually a part of the Identity API, and is used
for illustrative purposes only.

#### Create an Entity

When creating an entity, you must provide all required attributes (except those
provided by the Database service implementation, such as the resource ID):

Request:

    POST /entities

    {
        "entity": {
            "name": string,
            "description": string,
            "enabled": boolean
        }
    }

The full entity is returned in a successful response (including the new
resource's ID and a self-relational link), keyed by the singular form of the
resource name:

    201 Created

    {
        "entity": {
            "id": string,
            "name": string,
            "description": string,
            "enabled": boolean,
            "links": {
                "self": url
            }
        }
    }

#### List Entities

Request the entire collection of entities:

    GET /entities

A successful response includes a list of anonymous dictionaries, keyed by the
plural form of the resource name (identical to that found in the resource URL):

    200 OK

    {
        "entities": [
            {
                "id": string,
                "name": string,
                "description": string,
                "enabled": boolean,
                "links": {
                    "self": url
                }
            },
            {
                "id": string,
                "name": string,
                "description": string,
                "enabled": boolean,
                "links": {
                    "self": url
                }
            }
        ],
        "links": {
            "self": url,
            "next": url,
            "previous": url
        }
    }

#### Get an Entity

Request a specific entity by ID:

    GET /entities/{entity_id}

The full resource is returned in response:

    200 OK

    {
        "entity": {
            "id": string,
            "name": string,
            "description": string,
            "enabled": boolean,
            "links": {
                "self": url
            }
        }
    }

#### Update an Entity

Partially update an entity (unlike a standard `PUT` operation, only the
specified attributes are replaced):

    PATCH /entities/{entity_id}

    {
        "entity": {
            "description": string,
        }
    }

The full entity is returned in response:

    200 OK

    {
        "entity": {
            "id": string,
            "name": string,
            "description": string,
            "enabled": boolean,
            "links": {
                "self": url
            }
        }
    }

#### Delete an Entity

Delete a specific entity by ID:

    DELETE /entities/{entity_id}

A successful response does not include a body:

    204 No Content

### HTTP Status Codes

The Database API uses a subset of the available HTTP status codes to
communicate specific success and failure conditions to the client.

#### 200 OK

This status code is returned in response to successful `GET` and `PATCH
operations.

#### 201 Created

This status code is returned in response to successful `POST` operations.

#### 204 No Content

This status code is returned in response to successful `HEAD`, `PUT` and
`DELETE` operations.

#### 300 Multiple Choices

This status code is returned by the root identity endpoint, with references to
one or more Database API versions (such as ``/v1/``).

#### 400 Bad Request

This status code is returned when the Database service fails to parse the
request as expected. This is most frequently returned when a required attribute
is missing, a disallowed attribute is specified (such as an `id` on `POST` in a
basic CRUD operation), or an attribute is provided of an unexpected data type.

The client is assumed to be in error.

#### 401 Unauthorized

This status code is returned when either authentication has not been performed,
the provided X-Auth-Token is invalid or authentication credentials are invalid
(including the user having been disabled).

#### 403 Forbidden

This status code is returned when the request is successfully authenticated but
not authorized to perform the requested action.

#### 404 Not Found

This status code is returned in response to failed `GET`, `HEAD`, `POST`,
`PUT`, `PATCH` and `DELETE` operations when a referenced entity cannot be found
by ID. In the case of a `POST` request, the referenced entity may be in the
request body as opposed to the resource path.

#### 500 Internal Server Error

This status code is returned when an unexpected error has occurred in the
Database service implementation.

#### 501 Not Implemented

This status code is returned when the Database service implementation is unable
to fulfill the request because it is incapable of implementing the entire API
as specified.

For example, an Database service may be incapable of returning an exhaustive
collection of Instances with any reasonable expectation of performance, or lack
the necessary permission to create or modify the collection of users (depending
on a database implementation); the implementation may therefore choose to
return this status code to communicate this condition to the client.

#### 503 Service Unavailable

This status code is returned when the Database service is unable to communicate
with a backend service, or by a proxy in front of the Database service unable
to communicate with the Database service itself.

API Resources
-------------

### Users: `/v1/instances`

A database instance is an isolated MySQL instance in a single tenant environment 
on a shared physical host machine. Also referred to as instance.

Additional required attributes:

- `name` (string)

  Name of the instance to create. The length of the name is limited to 255 
  characters and any characters are permitted.

- `flavorRef` (integer)

  Reference (href) to a flavor as specified in the response from the List   
  Flavors API call. This is the actual URI as specified by the href field in the 
  link. Refer to the List Flavors response examples that follow for an example 
  of the flavorRef.

- `size` (integer)

  Specifies the volume size in gigabytes (GB).

Optional attributes:

- `databases` (list)

    - `Name` (string)

      Specifies database names for creating databases on instance creation.

    - `character_set` (string)

      Set of symbols and encodings. The default character set is utf8.

    - `collate` (string)

      Set of rules for comparing characters in a character set. The default 
      value for collate is utf8_general_ci.

- `users` (list)

    - `Name` (string)

      Specifies user name for the database on instance creation.

    - `password` (string)

      Specifies password for those users on instance creation.

    - `databases` (list)

        - `name` (string)
        
        Specifies names of databases that those users can access on instance creation.

Example entity:

    {
        "instance": {
            "databases": [
                {
                    "character_set": "utf8", 
                    "collate": "utf8_general_ci", 
                    "name": "sampledb"
                }, 
                {
                    "name": "nextround"
                }
            ], 
            "flavorRef": "https://endpoint/v1.0/1234/flavors/1", 
            "name": "json_rack_instance", 
            "users": [
                {
                    "databases": [
                        {
                            "name": "sampledb"
                        }
                    ], 
                    "name": "demouser", 
                    "password": "demopassword"
                }
            ], 
            "volume": {
                "size": 2
            }
        }
    }
  
### Groups: `/v1/instances/{instance_id}/databases`

A list database within a database instance.

Additional required attributes:

- `name` (string)

  Specifies the database name for creating the database.

Optional attributes:

- `character_set` (string)

  Set of symbols and encodings. The default character set is utf8.

- `collate` (string)

  Set of rules for comparing characters in a character set. The default 
  value for collate is utf8_general_ci.

Example entity:

    {
         "database": {
             "character_set": "utf8", 
             "collate": "utf8_general_ci", 
             "name": "testingdb"
         }
    }

### Users: `/v1/instances/{instance_id}/users`

A user for a specified database.

Additional required attributes:

- `name` (string)

  Specifies the name of the user for the database.

- `password` (string)

  Specifies the user password for database access.

- `database` (list)

    - `name` (string)
      Name of the database that the user can access. One or more database names 
      must be specified.

Example entity:

    {
         "user": {
             "databases": [
                 {
                     "name": "databaseB"
                 }, 
                 {
                     "name": "databaseC"
                 }
             ], 
             "name": "dbuser", 
             "password": "password"
         }
    }

### Flavors: `/v1/flavors`

A flavor is an available hardware configuration for a database instance. Each 
flavor has a unique combination of memory capacity and priority for CPU time

Example entity:

    {
        "flavor": {
            "id": 1, 
            "links": [
                {
                    "href": "https://endpoint/v1.0/1234/flavors/1", 
                    "rel": "self"
                }, 
                {
                    "href": "https://endpoint/flavors/1", 
                    "rel": "bookmark"
                }
            ], 
            "name": "m1.tiny", 
            "ram": 512
        }
    }

Core API
--------

### Versions

#### List versions; `GET /`

(TBD: This needs additional definition to match the detail below)

### Instances

Use cases:

- Creating an instance
- Listing instances
- Retrieving instance details

#### CREATE instance: `POST /instances`

This operation asynchronously provisions a new database instance. This call 
requires the user to specify a flavor and a volume size. The service then 
provisions the instance with the requested flavor and sets up a volume of the 
specified size, which is the storage for the database instance.

Request:

    {
        "instance": {
            "databases": [
                {
                    "character_set": "utf8", 
                    "collate": "utf8_general_ci", 
                    "name": "sampledb"
                }, 
                {
                    "name": "nextround"
                }
            ], 
            "flavorRef": "https://endpoint/v1.0/1234/flavors/1", 
            "name": "json_rack_instance", 
            "users": [
                {
                    "databases": [
                        {
                            "name": "sampledb"
                        }
                    ], 
                    "name": "demouser", 
                    "password": "demopassword"
                }
            ], 
            "volume": {
                "size": 2
            }
        }
    }

Response:

    Status: 200 OK

    {
        "instance": {
            "created": "2012-01-25T21:53:09Z", 
            "flavor": {
                "id": "1", 
                "links": [
                    {
                        "href": "https://endpoint/v1.0/1234/flavors/1", 
                        "rel": "self"
                    }, 
                    {
                        "href": "https://endpoint/flavors/1", 
                        "rel": "bookmark"
                    }
                ]
            }, 
            "hostname": "e09ad9a3f73309469cf1f43d11e79549caf9acf2.rackspaceclouddb.com", 
            "id": "dea5a2f7-3ec7-4496-adab-0abb5a42d635", 
            "links": [
                {
                    "href": "https://endpoint/v1.0/1234/instances/dea5a2f7-3ec7-4496-adab-0abb5a42d635", 
                    "rel": "self"
                }, 
                {
                    "href": "https://endpoint/instances/dea5a2f7-3ec7-4496-adab-0abb5a42d635", 
                    "rel": "bookmark"
                }
            ], 
            "name": "json_rack_instance", 
            "status": "BUILD", 
            "updated": "2012-01-25T21:53:10Z", 
            "volume": {
                "size": 2
            }
        }
    }

#### LIST instances: `GET /instances`

This operation lists the status and information for all database instances.

Response:

    {
        "instances": [
            {
                "flavor": {
                    "id": "1", 
                    "links": [
                        {
                            "href": "https://endpoint/v1.0/1234/flavors/1", 
                            "rel": "self"
                        }, 
                        {
                            "href": "https://endpoint/flavors/1", 
                            "rel": "bookmark"
                        }
                    ]
                }, 
                "id": "28d1b8f3-172a-4f6d-983d-36021508444a", 
                "links": [
                    {
                        "href": "https://endpoint/v1.0/1234/instances/28d1b8f3-172a-4f6d-983d-36021508444a", 
                        "rel": "self"
                    }, 
                    {
                        "href": "https://endpoint/instances/28d1b8f3-172a-4f6d-983d-36021508444a", 
                        "rel": "bookmark"
                    }
                ], 
                "name": "instance1", 
                "status": "ACTIVE", 
                "volume": {
                    "size": 2
                }
            }, 
            {
                "flavor": {
                    "id": "1", 
                    "links": [
                        {
                            "href": "https://endpoint/v1.0/1234/flavors/1", 
                            "rel": "self"
                        }, 
                        {
                            "href": "https://endpoint/flavors/1", 
                            "rel": "bookmark"
                        }
                    ]
                }, 
                "id": "8fb081af-f237-44f5-80cc-b46be1840ca9", 
                "links": [
                    {
                        "href": "https://endpoint/v1.0/1234/instances/8fb081af-f237-44f5-80cc-b46be1840ca9", 
                        "rel": "self"
                    }, 
                    {
                        "href": "https://endpoint/instances/8fb081af-f237-44f5-80cc-b46be1840ca9", 
                        "rel": "bookmark"
                    }
                ], 
                "name": "instance2", 
                "status": "ACTIVE", 
                "volume": {
                    "size": 2
                }
            }
        ]
    }

#### List Database Instance Details `GET /instances/{instance_id}`

This operation lists the status and details of the specified database instance. 
It also lists the volume size in gigabytes (GB) and the approximate GB used.

Response:

    Status: 200 OK

    {
        "instance": {
            "created": "2012-03-28T21:31:02Z", 
            "flavor": {
                "id": "1", 
                "links": [
                    {
                        "href": "https://endpoint/v1.0/1234/flavors/1", 
                        "rel": "self"
                    }, 
                    {
                        "href": "https://endpoint/flavors/1", 
                        "rel": "bookmark"
                    }
                ]
            }, 
            "hostname": "e09ad9a3f73309469cf1f43d11e79549caf9acf2.rackspaceclouddb.com", 
            "id": "2450c73f-7805-4afe-a42c-4094ab42666b", 
            "links": [
                {
                    "href": "https://endpoint/v1.0/1234/instances/2450c73f-7805-4afe-a42c-4094ab42666b", 
                    "rel": "self"
                }, 
                {
                    "href": "https://endpoint/instances/2450c73f-7805-4afe-a42c-4094ab42666b", 
                    "rel": "bookmark"
                }
            ], 
            "name": "xml_rack_instance",  
            "status": "ACTIVE", 
            "updated": "2012-03-28T21:34:25Z", 
            "volume": {
                "size": 2, 
                "used": 0.124542236328125
            }
        }
    }

#### Delete instance: `DELETE /instances/{instance_id}`

Response:
    
    Status: 202 ACCEPTED

#### Enable root user: `POST /instances/{instance_id}/root`

This operation enables login from any host for the root user and provides the 
user with a generated root password.

Response:

    Status: 200 OK
    
    {
        "user": {
            "name": "root", 
            "password": "d4311cb1-d912-45be-8517-e8a46f54df66"
        }
    }    
    
### Get root enabled status: `GET /instances/{instance_id}/root`

This operation checks an active specified database instance to see if root 
access is enabled. It returns True if root user is enabled for the specified 
database instance or False otherwise.

Response:

    Status: 200 OK
    
    {
        "rootEnabled": true
    }
    
### Instance Actions

#### Restart Instance `POST /instances/{instanceId}/action`

The restart operation will restart only the MySQL Instance. Restarting MySQL 
will erase any dynamic configuration settings that you have made within MySQL.

Request:

    {
        "restart": {}
    }

Response:

    Status 202 ACCEPTED

#### Resize Instance `POST /instances/{instanceId}/action`

This operation changes the memory size of the instance, assuming a valid 
flavorRef is provided. Restarts MySQL in the process.

Request:

    {
        "resize": {
            "flavorRef": "https://endpoint/v1.0/1234/flavors/2"
        }
    }

Response:

    Status 202 ACCEPTED

#### Resize Volume `POST /instances/{instanceId}/action`

This operation supports resizing the attached volume for an instance. It 
supports only increasing the volume size and does not support decreasing the 
size. The volume size is in gigabytes (GB) and must be an integer.

Request:

    {
        "resize": {
            "volume": {
                "size": 4
            }
        }
    }

Response:

    Status 202 ACCEPTED
