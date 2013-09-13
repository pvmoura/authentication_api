authentication_api
==================
Simple API to authenticate a user

POST /users/sign_in.json

Sample request:

    {
    "name": "John Doe",
    "email": "john@doe.com",
    "password": "s3kr3t",
    "password_confirmation": "s3kr3t"
    }

Sample Response:

    {
    "id": 1,
    "name": "JohnDoe",
    "email": "john@doe.com",
    "authentication_token": "s3kr3t-value"
    }

Required request parameters: name, email, password, password_confirmation

Possible error messages:

    {error: 'malformed json'}

    {error: "missing required param: name"}

    {error: "name param is empty"}

    {error: "email is invalid"}

    {error: "passwords don't match"}

    {error: "email not found in database"}

    {error: "email/password combination not found"}
