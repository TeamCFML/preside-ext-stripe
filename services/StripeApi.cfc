/**
 * A CFML Abstraction layer for the Stripe REST API
 *
 * @singleton true
 *
 */
component {

// CONSTRUCTOR
	/**
	 * @systemConfigurationService.inject systemConfigurationService
	 *
	 */
	public any function init(
		  required any    systemConfigurationService
		,          string apiEndpoint = "https://api.stripe.com/v1"
	) {
		_setSystemConfigurationService( arguments.systemConfigurationService );
		_setApiEndpoint( arguments.apiEndpoint );

		return this;
	}

// PUBLIC API METHODS
	/**
	 * Calls the stripe 'CreateCharge' API method. See: https://stripe.com/docs/api#create_charge
	 */
	public struct function createCharge(
		  required numeric amount
		, required string  currency
		,          string  customer             = ""
		,          string  source               = ""
		,          string  description          = ""
		,          struct  metadata             = {}
		,          boolean capture              = true
		,          string  statement_descriptor = ""
		,          string  receipt_email        = ""
		,          struct  shipping             = {}
		,          string  idempotencyKey       = ""
	) {
		var params = {
			  amount   = arguments.amount
			, currency = arguments.currency
			, capture  = arguments.capture
			, metadata = arguments.metadata
			, shipping = arguments.shipping
		};

		for( var argName in [ "customer", "source", "description", "statement_descriptor", "receipt_email" ] ) {
			if ( arguments[ argName ].len() ) {
				params[ argName ] = arguments[ argName ];
			}
		};

		return apiCall(
			  uri            = "/charges"
			, method         = "POST"
			, params         = params
			, idempotencyKey = arguments.idempotencyKey
		);
	}

	/**
	 * Generic API Call method for calling the API directly (should no abstract methods already exist for your desired operation)
	 */
	public any function apiCall(
		  required string uri
		,          string method         = "GET"
		,          struct params         = {}
		,          string idempotencyKey = ""
	) {
		var credentials = _getStripeCredentials();
		var paramtype   = arguments.method == "GET" ? "url" : "formfield";
		var httpRequest = new HTTP();

		httpRequest.setUrl( _getApiEndpoint() & arguments.uri );
		httpRequest.setUsername( credentials.privateKey );
		httpRequest.setPassword( "" );
		httpRequest.setMethod( arguments.method );
		httpRequest.setCharset( 'utf-8' );
		httpRequest.setTimeout( 30 );

		for( var paramName in arguments.params ) {
			if ( IsStruct( arguments.params[ paramName ] ) ) {
				for( var key in arguments.params[ paramName ] ) {
					httpRequest.addParam( type=paramType, name="#paramName#[#key#]", value=arguments.params[ paramName ][ key ] );
				}
			} else {
				httpRequest.addParam( type=paramType, name=paramName, value=arguments.params[ paramName ] );
			}
		}
		if ( arguments.idempotencyKey.len() ) {
			httpRequest.addParam( type="header", name="Idempotency-Key", value=arguments.idempotencyKey );
		}

		var httpResponse = httpRequest.send().getPrefix();

		return _processResponse( httpResponse );
	}

// PRIVATE HELPERS
	private struct function _getStripeCredentials() {
		var savedSettings = _getSystemConfigurationService().getCategorySettings( "stripe-credentials" );

		return {
			  publicKey  = ( savedSettings.public_key  ?: "" )
			, privateKey = ( savedSettings.private_key ?: "" )
		};
	}

	private any function _processResponse( required struct httpResponse ) {
		var statusCode     = httpResponse.status_code   ?: "";
		var responseBody   = httpResponse.fileContent ?: "";
		var responseObject = {};

		try {
			responseObject = DeSerializeJson( responseBody );
		} catch ( any e ) {
			throw(
				  type         = "StripeApi.invalid_response"
				, message      = "An unexpected and invalid response was received from the stripe API request. See error detail and extended info for full response details."
				, detail       = responseBody
				, extendedInfo = SerializeJson( arguments.httpResponse )
				, errorCode    = statusCode
			);
		}

		if ( responseObject.keyExists( "error" ) && IsStruct( responseObject.error ) && responseObject.error.count() ) {
			throw(
				  type         = "StripeApi.#( responseObject.error.type ?: 'unknowntype' )#"
				, message      = responseObject.error.message ?: ""
				, detail       = responseBody
				, extendedInfo = SerializeJson( arguments.httpResponse )
				, errorCode    = statusCode
			);
		}

		return responseObject;
	}

// GETTERS AND SETTERS
	private any function _getSystemConfigurationService() {
		return _systemConfigurationService;
	}
	private void function _setSystemConfigurationService( required any systemConfigurationService ) {
		_systemConfigurationService = arguments.systemConfigurationService;
	}

	private string function _getApiEndpoint() {
		return _apiEndpoint;
	}
	private void function _setApiEndpoint( required string apiEndpoint ) {
		_apiEndpoint = arguments.apiEndpoint;
	}
}