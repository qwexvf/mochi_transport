import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json as gj
import gleam/option.{type Option}
import gleam/result
import mochi/executor.{type ExecutionResult}
import mochi/schema.{type ExecutionContext, type Schema}
import mochi_transport/subscription.{type PubSub, type SubscriptionId}
import mochi_transport/subscription_executor

pub type SseRequest {
  SseRequest(
    query: String,
    variables: Option(dict.Dict(String, Dynamic)),
    operation_name: Option(String),
  )
}

pub type SseSubscription {
  SseSubscription(subscription_id: SubscriptionId, pubsub: PubSub)
}

pub type SseError {
  ParseError(String)
  SubscriptionSetupError(String)
  InvalidJson(String)
}

pub fn parse_request(body: String) -> Result(SseRequest, SseError) {
  case gj.parse(body, decode.dynamic) {
    Error(_) -> Error(InvalidJson("Request body is not valid JSON"))
    Ok(dyn) -> decode_request(dyn)
  }
}

fn decode_request(dyn: Dynamic) -> Result(SseRequest, SseError) {
  use query <- result.try(
    decode.run(dyn, decode.at(["query"], decode.string))
    |> result.map_error(fn(_) { ParseError("Missing required field: query") }),
  )

  let variables =
    decode.run(dyn, decode.at(["variables"], decode.dynamic))
    |> result.try(fn(v) {
      decode.run(v, decode.dict(decode.string, decode.dynamic))
    })
    |> option.from_result

  let operation_name =
    decode.run(dyn, decode.at(["operationName"], decode.string))
    |> option.from_result

  Ok(SseRequest(
    query: query,
    variables: variables,
    operation_name: operation_name,
  ))
}

pub fn subscribe(
  request: SseRequest,
  schema: Schema,
  context: ExecutionContext,
  pubsub: PubSub,
  on_event: fn(ExecutionResult) -> Nil,
) -> Result(SseSubscription, SseError) {
  let var_values = option.unwrap(request.variables, dict.new())

  let sub_ctx =
    subscription_executor.SubscriptionContext(
      schema: schema,
      pubsub: pubsub,
      execution_context: context,
      variable_values: var_values,
    )

  case subscription_executor.subscribe(sub_ctx, request.query, on_event) {
    subscription_executor.SubscriptionError(msg) ->
      Error(SubscriptionSetupError(msg))
    subscription_executor.SubscriptionResult(sub_id, _topic, new_pubsub) ->
      Ok(SseSubscription(subscription_id: sub_id, pubsub: new_pubsub))
  }
}

pub fn unsubscribe(sub: SseSubscription) -> PubSub {
  subscription.unsubscribe(sub.pubsub, sub.subscription_id)
}

pub fn format_error(err: SseError) -> String {
  case err {
    ParseError(msg) -> "Parse error: " <> msg
    SubscriptionSetupError(msg) -> "Subscription setup failed: " <> msg
    InvalidJson(msg) -> "Invalid JSON: " <> msg
  }
}
