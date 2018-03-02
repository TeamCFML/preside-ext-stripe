/**
 * Handler providing front-end viewlets
 * and common actions for Stripe integration
 *
 */
component {

// VIEWLETS
	private string function paymentButton( event, rc, prc, arg={} ) {
		var stripePublicKey = getSystemSetting( category="stripe-credentials", setting="public_key" );

		event.include( "/js/specific/customPaymentForm/" )
		     .includeData( { stripePublicKey = stripePublicKey } );

		return renderView( view="/stripe/paymentButton", args=args );
	}

}