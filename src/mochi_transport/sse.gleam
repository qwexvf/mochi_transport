import gleam/bit_array
import mochi/executor.{type ExecutionResult}
import mochi/schema.{type ExecutionContext, type Schema}
import mochi_transport/sse/handler
import mochi_transport/sse/protocol
import mochi_transport/subscription.{type PubSub}

pub type SseRequest =
  handler.SseRequest

pub type SseSubscription =
  handler.SseSubscription

pub type SseError =
  handler.SseError

pub fn parse_request(body: String) -> Result(SseRequest, SseError) {
  handler.parse_request(body)
}

pub fn subscribe(
  request: SseRequest,
  schema: Schema,
  context: ExecutionContext,
  pubsub: PubSub,
  on_event: fn(ExecutionResult) -> Nil,
) -> Result(SseSubscription, SseError) {
  handler.subscribe(request, schema, context, pubsub, on_event)
}

pub fn unsubscribe(sub: SseSubscription) -> PubSub {
  handler.unsubscribe(sub)
}

pub fn next_frame(result: ExecutionResult) -> BitArray {
  protocol.next_frame(result)
}

pub fn complete_frame() -> BitArray {
  protocol.complete_frame()
}

pub fn ping_frame() -> BitArray {
  protocol.ping_frame()
}

pub fn error_frame(message: String) -> BitArray {
  protocol.error_frame(message)
}

pub fn frame_to_string(frame: BitArray) -> String {
  case bit_array.to_string(frame) {
    Ok(s) -> s
    Error(_) -> ""
  }
}

pub fn format_error(err: SseError) -> String {
  handler.format_error(err)
}

pub fn content_type_header() -> String {
  protocol.content_type()
}

pub fn cache_control_header() -> String {
  protocol.cache_control()
}
