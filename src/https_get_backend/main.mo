import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Types "Types";

actor {
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
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

  public func http_request() : async Text {
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
    let ic : Types.IC = actor ("aaaaa-aa");
    let ONE_MINUTE : Nat64 = 60;
    let start_timestamp : Types.Timestamp = 1682978460; // May 1, 2023 22:01:00 GMT
    let end_timestamp : Types.Timestamp = 1682978520;   // May 1, 2023 22:02:00 GMT
    let host : Text = "api.pro.coinbase.com";
    let url = "https://" # host # "/products/ICP-USD/candles?start=" # Nat64.toText(start_timestamp) # "&end=" # Nat64.toText(end_timestamp) # "&granularity=" # Nat64.toText(ONE_MINUTE);

    let request_headers = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let http_request : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null; // Optional for request
      headers = request_headers;
      body = null;               // Optional for request
      method = #get;
      transform = ?transform_context;
    };

    try {
      // Debug.print("Attempting to send HTTP request...");
      let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);
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
    }
  };
};
