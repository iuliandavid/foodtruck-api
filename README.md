# Server Side Swift API 

## Features

### Authentication (OAuth2 like).

  - POST `{{API_URL}}`/users a json like:
 
 ```javascript
{
    "email": "example@example.com",
    "name": "myexampleuser",
    "password": "myexamplepassword"
}
```
   
  - POST `{{API_URL}}`/login  with basic authorization header:  **Base64** of `email:password` string: 

```javascript
        Authorization:Basic ZXhhbXBsZUBleGFtcGxlLmNvbTpteWV4YW1wbGVwYXNzd29yZA==
        Content-Type:application/json
```

The output will be something like :
```javascript
{
    "refreshToken": "0axU/lwHRTwPCj2dxpXnIIsM",
    "accessToken": "8QxfpEINJj2JVs5U6zT4XA==",
    "expiryDate": "2017-07-20T04:29:42.258Z"
}
```
  - If access token expires (after 30 minutes as of this case) :  
        
      POST `{{API_URL}}`/users/authorize/refresh_token with a json containing email and refresh_token:
        
```javascript
{
    "refreshToken": "0axU/lwHRTwPCj2dxpXnIIsM",
    "email": "example@example.com"
}
```

### Docker MongoDB Setup

```sh
docker run --name mongo -p 31564:27017 -v /coding/mongodb/db:/data/db -d mongo:latest --storageEngine wiredTiger
```
This will create the MongoDB image and pull in the necessary dependencies