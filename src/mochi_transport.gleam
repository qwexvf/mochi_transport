import gleam/dynamic.{type Dynamic}
import mochi/schema.{type ExecutionContext, type Schema}
import mochi_transport/subscription.{type PubSub, type Topic}
import mochi_transport/websocket.{
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
