//// WebSocket transport and subscriptions for mochi GraphQL.
////
//// Implements the graphql-ws protocol for real-time subscriptions.
////
//// ## Usage
////
//// ```gleam
//// import mochi_websocket
//// import mochi_websocket/subscription
//// import mochi_websocket/websocket
////
//// // Create pub/sub and connection state
//// let pubsub = mochi_websocket.new_pubsub()
//// let state = mochi_websocket.new_connection(schema, pubsub)
////
//// // In your WebSocket message handler:
//// let #(new_state, messages) = mochi_websocket.handle_message(state, raw_msg)
////
//// // Publish events from outside:
//// mochi_websocket.publish(pubsub, "user:created", event_data)
//// ```

import gleam/dynamic.{type Dynamic}
import mochi/schema.{type ExecutionContext, type Schema}
import mochi_websocket/subscription.{type PubSub, type Topic}
import mochi_websocket/websocket.{
  type ClientMessage, type ConnectionState, type HandleResult,
}

pub fn new_pubsub() -> PubSub {
  subscription.new_pubsub()
}

pub fn topic(name: String) -> Topic {
  subscription.topic(name)
}

pub fn topic_with_id(base: String, id: String) -> Topic {
  subscription.topic_with_id(base, id)
}

pub fn publish(pubsub: PubSub, t: Topic, payload: Dynamic) -> Nil {
  subscription.publish(pubsub, t, payload)
}

pub fn new_connection(
  schema: Schema,
  pubsub: PubSub,
  ctx: ExecutionContext,
) -> ConnectionState {
  websocket.new_connection(schema, pubsub, ctx)
}

pub fn handle_message(
  state: ConnectionState,
  message: ClientMessage,
) -> HandleResult {
  websocket.handle_message(state, message)
}
