( function( $ ){

	var settings  = typeof cfrequest !== "undefined" ? cfrequest : {}
	  , stripeKey = typeof settings.stripePublicKey !== "undefined" ? settings.stripePublicKey : ""
	  , createHandler;

	createHandler = function( options ){
		return StripeCheckout.configure( $.extend( {}, options, { key : stripeKey } ) );
	};

	$.fn.customStripePaymentForm = function(){
		return this.each( function(){
			var $paymentFormButton = $( this )
			  , $form              = $paymentFormButton.closest( 'form' )
			  , $error             = $paymentFormButton.next( ".error" )
			  , buttonData         = $paymentFormButton.data()
			  , options            = {}
			  , possibleOptions    = [ "image", "name", "description", "amount", "locale", "currency", "panelLabel", "zipCode", "billingAddress", "shippingAddress", "email", "labelOnly", "allowRememberMe", "bitcoin", "alipay", "alipayReusable" ]
			  , optionCount        = possibleOptions.length
			  , i, optionName, paymentDialogHandler;

			for( i=0; i<optionCount; i++ ) {
				optionName = possibleOptions[ i ];

				if ( typeof buttonData[ optionName ] !== "undefined" ) {
					options[ optionName ] = buttonData[ optionName ];
				}
			}

			options.token = function( token ){
				var key;

				for( key in token ){
					if ( token.hasOwnProperty( key ) ) {
						$form.append( '<input name="stripe_' + key + '" type="hidden" value="' + token[ key ] + '">' );
					}
				}

				$form.submit();
			};

			paymentDialogHandler = createHandler( options );

			$paymentFormButton.on( "click", function( e ){
				e.preventDefault();

				var dynamicOptions = {};

				if ( typeof buttonData.amount_field !== "undefined" ) {
					var $amountField = $form.find( "[name=" + buttonData.amount_field + "]" );

					if ( !$amountField.length ) {
						$error.html( "<p>Could not find amount field, " + buttonData.amount_field + "</p>" );
						return;
					}

					try {
						dynamicOptions.amount = parseInt( parseFloat( $amountField.val() ) * 100 );
					} catch ( e ) {
						$error.html( "<p>Invalid amount. Please enter a valid payment amount.</p>" );
						return;
					}

					if ( isNaN( dynamicOptions.amount ) ) {
						$error.html( "<p>Invalid amount. Please enter a valid payment amount.</p>" );
						return;
					}
				}

				$error.html( "" );

				paymentDialogHandler.open( dynamicOptions );
			} );

			$( window ).on( 'popstate', function() {
				paymentDialogHandler.close();
			});
		} );
	};

	$( "[data-stripe-payment-button]" ).customStripePaymentForm();

} )( jQuery );




