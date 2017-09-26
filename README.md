# BoomingProxy

A simple proxy for a RabbitMQ RPC queue.


Things that could be improved or I'm not particularly proud of:
- No tests
  - Definitely could add something along the line of http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/ in order to test both controllers.
  - GenServer could be decoupled from amqp to be testable, as well
- Use distillery to generate docker image
- RPC calls could be cached using ETS for a configurable time

## Running it

```shell
SECRET_KEY_BASE=something docker-compose up --build
```

The Proxy is exposed on port 14000:

```shell
$ curl http://localhost:14000/clients.json
{"clients":["google","facebook","yahoo","twitter"]}

curl http://localhost:14000/invoices.json?client_id=twitter
{"invoices":[{"total":"12 USD","services":"Telling everybody its hard to add edit button","customer":"Who cares"}]}
```
