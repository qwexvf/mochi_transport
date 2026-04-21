import gleam/bit_array
import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import mochi/executor
import mochi/types
import mochi_transport/sse
import mochi_transport/sse/handler
import mochi_transport/sse/protocol

pub fn parse_request_valid_test() {
  let body = "{\"query\": \"subscription { onMessage }\"}"
  case sse.parse_request(body) {
    Ok(req) -> {
      req.query |> should.equal("subscription { onMessage }")
      req.variables |> should.equal(None)
      req.operation_name |> should.equal(None)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_request_with_variables_test() {
  let body =
    "{\"query\": \"subscription { onMessage }\", \"variables\": {\"id\": \"123\"}}"
  case sse.parse_request(body) {
    Ok(req) -> {
      req.query |> should.equal("subscription { onMessage }")
      req.variables |> should.not_equal(None)
    }
    Error(_) -> should.fail()
  }
}

pub fn parse_request_missing_query_test() {
  let body = "{\"variables\": {}}"
  case sse.parse_request(body) {
    Ok(_) -> should.fail()
    Error(handler.ParseError(_)) -> Nil
    Error(_) -> should.fail()
  }
}

pub fn parse_request_invalid_json_test() {
  let body = "not json"
  case sse.parse_request(body) {
    Ok(_) -> should.fail()
    Error(handler.InvalidJson(_)) -> Nil
    Error(_) -> should.fail()
  }
}

pub fn next_frame_with_data_test() {
  let result =
    executor.ExecutionResult(
      data: Some(
        types.to_dynamic(
          dict.from_list([#("hello", types.to_dynamic("world"))]),
        ),
      ),
      errors: [],
      deferred: [],
    )
  let frame = protocol.next_frame(result)
  let text = bit_array.to_string(frame) |> should.be_ok
  string.contains(text, "event: next") |> should.be_true
  string.contains(text, "data:") |> should.be_true
  string.contains(text, "hello") |> should.be_true
  string.contains(text, "world") |> should.be_true
}

pub fn next_frame_ends_with_double_newline_test() {
  let result = executor.ExecutionResult(data: None, errors: [], deferred: [])
  let frame = protocol.next_frame(result)
  let text = bit_array.to_string(frame) |> should.be_ok
  string.ends_with(text, "\n\n") |> should.be_true
}

pub fn complete_frame_test() {
  let frame = protocol.complete_frame()
  let text = bit_array.to_string(frame) |> should.be_ok
  text |> should.equal("event: complete\ndata: \n\n")
}

pub fn ping_frame_test() {
  let frame = protocol.ping_frame()
  let text = bit_array.to_string(frame) |> should.be_ok
  text |> should.equal(": ping\n\n")
}

pub fn error_frame_test() {
  let frame = protocol.error_frame("Something went wrong")
  let text = bit_array.to_string(frame) |> should.be_ok
  string.contains(text, "event: next") |> should.be_true
  string.contains(text, "errors") |> should.be_true
  string.contains(text, "Something went wrong") |> should.be_true
}

pub fn content_type_test() {
  sse.content_type_header() |> should.equal("text/event-stream")
}

pub fn cache_control_test() {
  sse.cache_control_header() |> should.equal("no-cache")
}

pub fn format_error_parse_error_test() {
  let err = handler.ParseError("Missing field")
  let msg = sse.format_error(err)
  string.contains(msg, "Parse error") |> should.be_true
}

pub fn format_error_invalid_json_test() {
  let err = handler.InvalidJson("Bad JSON")
  let msg = sse.format_error(err)
  string.contains(msg, "Invalid JSON") |> should.be_true
}

pub fn format_error_subscription_error_test() {
  let err = handler.SubscriptionSetupError("Schema missing subscription type")
  let msg = sse.format_error(err)
  string.contains(msg, "Subscription setup failed") |> should.be_true
}
