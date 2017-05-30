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

## Specification

- This project uses API Blueprint for [REST API specs](), you can find their source in [apiary.apib](apiary.apib) file.

- [API docs](http://docs.mithril1.apiary.io) or [apiary.apib](apiary.apib).
- [Entity-relation diagram](docs/erd.pdf)
- [oAuth Sequence](https://www.websequencediagrams.com/cgi-bin/cdraw?lz=dGl0bGUgb0F1dGggRmxvdwoKQ2xpZW50IC0-IExvZ2luIFVJOiByZWRpcmVjdCB0bwANCSB3aXRoIGBjACoFX2lkYCwgYAAgCF91cmlgIGFuZCBgcmVzcG9uc2VfdHlwZT1jb2RlYCBxdWVyeSBwYXJhbXMKAEcJAGUNY29tcGxldGUgU2Vzc2lvbiBhdXRoIGZsb3cAJA1Vc2VyOiByZW5kZXIgcGFnZQCBEAZBcHByb3ZhbCAod2hpY2ggbGlzdHMgcmVxdWVzdGVkIHNjb3BlcykKVXNlcgCBXA5hADUFZQAbBwCBEA0Agh8FU2VydmVyOiBzZW5kIGBQT1NUIC9hcHBzYABWCAoAHAsAgjcOSFRUUCAyMDEsAIEVCmFuZCBMb2NhdGlvbiBoZWFkZXIAggMNAIMGBgCCdQt1c2VyIHRvIHVybCByZXR1cm5lZCBpbiBgAD4IYAA_CACDPQoAgSYSAIExBnRva2Vucz9ncmFudACDGAZhdXRob3JpegCBCwVfY29kZSAtIGV4Y2hhbmdlIGAAgzcGZnJvbQCDNgxldGVycyB0byBhbiBgYWNjZXNzXwBWBWAAgXsQAIIzDnRvcmUgcmVmcmVzaCAAgQcFAIIrEACBdggAJQZgACUHAFYHIChpbiBiYWNrLWVuZCEpAIRoBQCDDwYAdw0gdG8Agj8HIFVJCm5vdGUgb3ZlcgBMEAAmDihpbiBsb2NhbACBIQVhZ2UsIGNvb2tpZSwgZXRjLgBnBm1ha2VzIGFsbCBmdXR1AIFHBQCEWgVzAIYSB0F1aHQAgkQJOiBCZWFyZXIgPACCFgw-AIMlCQo&s=modern-blue)

## Installation

### Heroku One-click deployment

Mithril can be deployed by one button click on Heroku, by-default instance will fit in free tier and you will be able to change it later:

  [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nebo15/mithril.api)

### Docker container

Official Docker containers can be found on Docker Hub:

* [nebo15/mithril_api](https://hub.docker.com/r/nebo15/mithril_api/),
* [nebo15/mithril-web](https://hub.docker.com/r/nebo15/mithril-web/).

### Dependencies

- PostgreSQL 9.6 is used as storage back-end.

## Configuration

See [ENVIRONMENT.md](docs/ENVIRONMENT.md).

## License

See [LICENSE.md](LICENSE.md).
