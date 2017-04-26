# Mithril

[![Build Status](https://travis-ci.org/Nebo15/mithril.api.svg?branch=master)](https://travis-ci.org/Nebo15/mithril.api)[![Coverage Status](https://coveralls.io/repos/github/Nebo15/mithril.api/badge.svg?branch=master)](https://coveralls.io/github/Nebo15/mithril.api?branch=master)
[![Ebert](https://ebertapp.io/github/Nebo15/mithril.api.svg)](https://ebertapp.io/github/Nebo15/mithril.api)

Mithril – authentication and role management service.

> Mithril is a precious Silvery metal, very lightweight but capable of providing extreme strength in alloys.

Mithril is known for:

1. Implementing OAuth2 flow (e.g. issuing or revoking tokens);
2. Token verification service;
3. Role management;
4. Client management.

Mithril consists of two main parts:

- [REST API back-end](https://github.com/Nebo15/mithril.api),
- [Management UI](https://github.com/Nebo15/mithril.web).

Mithril by itself does not have any authorization tools, but you have two options to integrate with it:

- Use a Annon API Gateway that allows to configure Access Control Layer over your API;
- Write your own authorization plug that will resolve token scopes via [Mithrill's API](http://docs.mithril1.apiary.io/#).

## Authorization Flows

### oAuth

1. Client UI: redirects user to Login UI with `client_id`, `redirect_uri` and `response_type=code` query params;
2. Login UI: completes [Session]() auth flow with `apps:create` scope;
3. Login UI: renders page with Approval (which lists requested scopes);
4. User: approves scopes;
5. Login UI: sends `POST /apps` request and redirects user to location returned in `Location` header;
6. Client: exchanges `code` from query parameters to an `access_token` by sending `POST /tokens` request with `grant_type=authorization_code`.
7. Client Back-End: stores `refresh_token` (in back-end!) and sends `access_token` to Client UI;
8. Client UI: stores `access_token` (in local storage, cookie, etc.) and makes all future requests with `Auhtorization: Bearer <access_token>` header.

Notes:
- If User already has approval with insufficient scopes, all steps are required, but Login UI MAY render page that shows only newly added scopes.
- When `access_token` expires, Client repeats steps 6-8 but via `grant_type=refresh_token`.

**Sequence Diagram**

![oAuth Sequence](https://www.websequencediagrams.com/cgi-bin/cdraw?lz=dGl0bGUgb0F1dGggRmxvdwoKQ2xpZW50IC0-IExvZ2luIFVJOiByZWRpcmVjdCB0bwANCSB3aXRoIGBjACoFX2lkYCwgYAAgCF91cmlgIGFuZCBgcmVzcG9uc2VfdHlwZT1jb2RlYCBxdWVyeSBwYXJhbXMKAEcJAGUNY29tcGxldGUgU2Vzc2lvbiBhdXRoIGZsb3cAJA1Vc2VyOiByZW5kZXIgcGFnZQCBEAZBcHByb3ZhbCAod2hpY2ggbGlzdHMgcmVxdWVzdGVkIHNjb3BlcykKVXNlcgCBXA5hADUFZQAbBwCBEA0Agh8FU2VydmVyOiBzZW5kIGBQT1NUIC9hcHBzYABWCAoAHAsAgjcOSFRUUCAyMDEsAIEVCmFuZCBMb2NhdGlvbiBoZWFkZXIAggMNAIMGBgCCdQt1c2VyIHRvIHVybCByZXR1cm5lZCBpbiBgAD4IYAA_CACDPQoAgSYSAIExBnRva2Vucz9ncmFudACDGAZhdXRob3JpegCBCwVfY29kZSAtIGV4Y2hhbmdlIGAAgzcGZnJvbQCDNgxldGVycyB0byBhbiBgYWNjZXNzXwBWBWAAgXsQAIIzDnRvcmUgcmVmcmVzaCAAgQcFAIIrEACBdggAJQZgACUHAFYHIChpbiBiYWNrLWVuZCEpAIRoBQCDDwYAdw0gdG8Agj8HIFVJCm5vdGUgb3ZlcgBMEAAmDihpbiBsb2NhbACBIQVhZ2UsIGNvb2tpZSwgZXRjLgBnBm1ha2VzIGFsbCBmdXR1AIFHBQCEWgVzAIYSB0F1aHQAgkQJOiBCZWFyZXIgPACCFgw-AIMlCQo&s=modern-blue)

### Session

If user does not have session stored in browser cookie, or session is expired, or scopes is insufficient:

1. Login UI: render form with email/password;
2. User: input and submit data;
3. Login UI: send request `POST /tokens` with `grant_type=password`;
4. Auth Server: generates `session_token` and returns it;
5. Login UI: stores `session_token` in Cookie and/or Local Storage.

If user has valid session token (can be checked by sending `GET /tokens/{id}/user` request), he is already logged in.

`session_token` is used in all internal services.

**Sequence Diagram**

![Session Sequence](https://www.websequencediagrams.com/cgi-bin/cdraw?lz=dGl0bGUgU2Vzc2lvbiBhdXRoIEZsb3cKCgABGExvZ2luIFVJIC0-IFVzZXI6IHJlbmRlciBmb3JtIHdpdGggZW1haWwgYW5kIHBhc3N3b3JkClVzZXIgLT4gADYIOgARFABPDEF1dGggU2VydmVyIDogYFBPU1QgL3Rva2Vucz9ncmFudF90eXBlPQBZCGAKACUMAF4LIDogYHMAgVgGXwA6BWAAgTUNAIEGCnN0b3JlcwAdECBpbiBDb29raWUgYW5kL29yIExvY2FsIFN0b3JhZ2UK&s=modern-blue)

## Urgent Data

Endpoint `GET /tokens/:id/user` returns `urgent` field that allows Clients to:
1. Retrieve Token expiration;
2. Retrieve User Roles (for a specific Client token was issued for).

This data MAY be used to pro-actively react on scopes or roles chanes, and to renew token before it expires.

## Installation

### Heroku One-click deployment

Trump can be deployed by one button click on Heroku, by-default instance will fit in free tier and you will be able to change it later:

  [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nebo15/mitrhril.api)

### Docker

Also you can deploy Mithril as Docker container.
We constantly are releasing pre-built versions that will reduce time to deploy:

- [Back-End Docker container](https://hub.docker.com/r/nebo15/mithril_api/);
- [PostgreSQL Docker container](https://hub.docker.com/r/nebo15/alpine-postgre/);
- [UI Docker container](https://hub.docker.com/r/nebo15/mithril-web/).

### Heroku

Template allows to deploy Man to Heroku just in minute (and use it for free within Heroku tiers):

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nebo15/man.api)

## Documentation

This project uses API Blueprint for [REST API specs](http://docs.mithril1.apiary.io/#), you can find their source in [apiary.apib](apiary.apib) file.

## License

See [LICENSE.md](LICENSE.md).
