# mochi_websocket

WebSocket transport and subscriptions for mochi GraphQL (graphql-ws protocol).

## Installation

```sh
gleam add mochi_websocket
```

## Usage

```gleam
import mochi_websocket/websocket
import mochi_websocket/subscription

let pubsub = subscription.new()

// Handle WebSocket upgrade
websocket.handler(schema, pubsub)
```

## License

Apache-2.0

