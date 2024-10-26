import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import T "Types";

// import CertifiedData "mo:base/CertifiedData";
// import SHA256 "mo:sha256/SHA256";

actor {

  type HttpRequest = T.IncomingHttpRequest;
  type HttpResponse = T.HttpResponse;

  public query func transform(raw : T.TransformArgs) : async T.CanisterHttpResponsePayload {
    let transformed : T.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        {
          name = "Content-Security-Policy";
          value = "default-src 'self'";
        },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        {
          name = "Strict-Transport-Security";
          value = "max-age=63072000";
        },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  public func get_icp_usd_exchange() : async Text {
    // Debug.print("About to add cycles...");
    // let initial_cycles = Cycles.balance();
    // Debug.print("Available cycles before adding: " # Nat64.toText(Nat64.fromNat(initial_cycles)));  // Convert Nat to Nat64

    // Add cycles
    Cycles.add(20_949_972_000);
    // Debug.print("Cycles added successfully!");

    // let final_cycles_after_add = Cycles.balance();
    // Debug.print("Available cycles after adding: " # Nat64.toText(Nat64.fromNat(final_cycles_after_add)));  // Convert Nat to Nat64

    // Making the HTTP request
    // Debug.print("Making the HTTP request...");
    let ic : T.IC = actor ("aaaaa-aa");
    let ONE_MINUTE : Nat64 = 60;
    let start_timestamp : T.Timestamp = 1682978460; // May 1, 2023 22:01:00 GMT
    let end_timestamp : T.Timestamp = 1682978520; // May 1, 2023 22:02:00 GMT
    let host : Text = "api.pro.coinbase.com";
    let url = "https://" # host # "/products/ICP-USD/candles?start=" # Nat64.toText(start_timestamp) # "&end=" # Nat64.toText(end_timestamp) # "&granularity=" # Nat64.toText(ONE_MINUTE);

    let request_headers = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    let transform_context : T.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let http_request : T.HttpRequestArgs = {
      url = url;
      max_response_bytes = null; // Optional for request
      headers = request_headers;
      body = null; // Optional for request
      method = #get;
      transform = ?transform_context;
    };

    try {
      // Debug.print("Attempting to send HTTP request...");
      let http_response : T.HttpResponsePayload = await ic.http_request(http_request);
      // Debug.print("HTTP request completed successfully!");
      let final_cycles_after_request = Cycles.balance();
      // Debug.print("Available cycles after HTTP request: " # Nat64.toText(Nat64.fromNat(final_cycles_after_request)));  // Convert Nat to Nat64
      let response_body : Blob = Blob.fromArray(http_response.body);
      let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
        case (null) { "No value returned" };
        case (?y) { y };
      };
      return decoded_text;
    } catch (err) {
      Debug.print("Error during HTTP request: " # Error.message(err));
      return "Request failed: " # Error.message(err);
    };
  };

  public func get_json_todo_1() : async Text {
    Cycles.add(20_949_972_000); // Add cycles for the HTTP call
    let ic : T.IC = actor ("aaaaa-aa"); // Reference the management canister

    let url = "https://jsonplaceholder.typicode.com/todos/1";

    let request_headers = [
      { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    let transform_context : T.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let http_request : T.HttpRequestArgs = {
      url = url;
      max_response_bytes = null; // Optional for request
      headers = request_headers;
      body = null; // Optional for request
      method = #get;
      transform = ?transform_context;
    };

    try {
      let http_response = await ic.http_request(http_request); // Send the HTTP request
      let response_body : Blob = Blob.fromArray(http_response.body); // Get the body of the response
      let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
        // Decode the response into text
        case (null) { "No value returned" };
        case (?text) { text };
      };
    } catch (err) {
      return "Request failed: " # Error.message(err); // Return the error message if the request fails
    };
  };

  // http_request is a built-in query method that handles incoming HTTP request
  public query func http_request(req : HttpRequest) : async () {
    let bodyBlob : Blob = Blob.fromArray(req.body);
    let maybeBodyText = Text.decodeUtf8(bodyBlob);

    let bodyText : Text = switch (maybeBodyText) {
      case (null) { "No value returned" };
      case (?t) { t };
    };
    Debug.print("Request body: " # bodyText);

    // CANT RETURN a response if there is no certificate().
    // headers = [("Content-Type", "application/json"), certificate()];

    // return {
    //   status_code = 200;
    //   headers = [("Content-Type", "application/json")];
    //   body = Text.encodeUtf8("{\"message\": \"Request processed successfully\"}");
    // };
  };

};
