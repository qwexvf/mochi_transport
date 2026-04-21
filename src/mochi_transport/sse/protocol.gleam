import gleam/bit_array
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/option.{None, Some}
import mochi/executor.{type ExecutionResult}
import mochi/json
import mochi/types

pub fn next_frame(result: ExecutionResult) -> BitArray {
  let payload = encode_result(result)
  bit_array.from_string("event: next\ndata: " <> payload <> "\n\n")
}

pub fn complete_frame() -> BitArray {
  bit_array.from_string("event: complete\ndata: \n\n")
}

pub fn ping_frame() -> BitArray {
  bit_array.from_string(": ping\n\n")
}

pub fn error_frame(message: String) -> BitArray {
  let err =
    types.to_dynamic(dict.from_list([#("message", types.to_dynamic(message))]))
  let payload =
    json.encode(
      types.to_dynamic(
        dict.from_list([
          #("data", types.to_dynamic(Nil)),
          #("errors", types.to_dynamic([err])),
        ]),
      ),
    )
  bit_array.from_string("event: next\ndata: " <> payload <> "\n\n")
}

pub fn content_type() -> String {
  "text/event-stream"
}

pub fn cache_control() -> String {
  "no-cache"
}

fn encode_result(result: ExecutionResult) -> String {
  case result.data, result.errors {
    Some(data), [] ->
      json.encode(types.to_dynamic(dict.from_list([#("data", data)])))
    Some(data), errs ->
      json.encode(
        types.to_dynamic(
          dict.from_list([
            #("data", data),
            #("errors", encode_errors(errs)),
          ]),
        ),
      )
    None, errs ->
      json.encode(
        types.to_dynamic(
          dict.from_list([
            #("data", types.to_dynamic(Nil)),
            #("errors", encode_errors(errs)),
          ]),
        ),
      )
  }
}

fn encode_errors(errs: List(executor.ExecutionError)) -> Dynamic {
  types.to_dynamic(
    list.map(errs, fn(err) {
      let #(msg, path) = case err {
        executor.ValidationError(message: m, path: p, ..) -> #(m, p)
        executor.ResolverError(message: m, path: p, ..) -> #(m, p)
        executor.TypeError(message: m, path: p, ..) -> #(m, p)
        executor.NullValueError(message: m, path: p, ..) -> #(m, p)
        executor.RichResolverError(graphql_error: e, path: p, ..) -> #(
          e.message,
          p,
        )
      }
      types.to_dynamic(
        dict.from_list([
          #("message", types.to_dynamic(msg)),
          #("path", types.to_dynamic(path)),
        ]),
      )
    }),
  )
}
