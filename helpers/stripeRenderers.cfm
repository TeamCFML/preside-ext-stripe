<cffunction name="renderStripePaymentButton" access="public" returntype="string" output="false">
	<cfreturn getController().renderViewlet( event="stripe.paymentButton", args=arguments ) />
</cffunction>