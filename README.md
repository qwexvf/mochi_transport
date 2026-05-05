# mochi_transport

WebSocket and Server-Sent Events transports for
[mochi](https://github.com/qwexvf/mochi) GraphQL subscriptions.

- WebSocket: [graphql-ws](https://github.com/enisdenjo/graphql-ws) protocol
- SSE: [GraphQL over SSE](https://github.com/enisdenjo/graphql-sse) protocol

## Installation

```sh
gleam add mochi_transport
```

## Usage

WebSocket subscriptions:

```gleam
import mochi_transport/subscription
import mochi_transport/websocket

let pubsub = subscription.new()

websocket.handler(schema, pubsub)
```

Server-Sent Events:

```gleam
import mochi_transport/sse

sse.handler(schema, pubsub)
```

## License

Apache-2.0
