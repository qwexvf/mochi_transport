# mochi_websocket

WebSocket transport and subscriptions for mochi GraphQL (graphql-ws protocol).

## Installation

```toml
# gleam.toml
[dependencies]
mochi_websocket = { git = "https://github.com/qwexvf/mochi_websocket", ref = "main" }
```

## Usage

```gleam
import mochi_websocket/websocket
import mochi_websocket/subscription

let pubsub = subscription.new()

websocket.handler(schema, pubsub)
```

## License

Apache-2.0

