module Types {
    public type Timestamp = Nat64;

    public type IncomingHttpRequest = {
        body : [Nat8];
        // Add other fields as necessary
    };

    // Define the HttpRequest and HttpResponse types for local canister use
    public type HttpRequest = {
        method : HttpMethod;
        url : Text;
        headers : [HttpHeader];
        body : [Nat8];
    };


    public type HttpResponse = {
        status_code : Nat16;
        headers : [HeaderField];
        body : Blob;
    };

    public type HeaderField = (Text, Text);

    // Define existing HttpRequestArgs for HTTPS outcalls
    public type HttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
        transform : ?TransformRawResponseFunction;
    };

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type HttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformRawResponseFunction = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type TransformArgs = {
        response : HttpResponsePayload;
        context : Blob;
    };

    public type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformContext = {
        function : shared query TransformArgs -> async HttpResponsePayload;
        context : Blob;
    };

    public type IC = actor {
        http_request : HttpRequestArgs -> async HttpResponsePayload;
    };
};
