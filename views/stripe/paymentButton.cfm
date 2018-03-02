<cfscript>
	possibleArgs  = [ "image", "name", "description", "amount", "locale", "currency", "panelLabel", "zipCode", "billingAddress", "shippingAddress", "email", "labelOnly", "allowRememberMe", "bitcoin", "alipay", "alipayReusable" ];
	buttonName    = args.buttonName    ?: "";
	buttonClass   = args.buttonClass   ?: "";
	buttonLabel   = args.buttonLabel   ?: "";
</cfscript>

<cfoutput>
	<button data-stripe-payment-button="true" <cfif buttonName.len()> name="#buttonName#"</cfif><cfif buttonClass.len()> class="#buttonClass#"</cfif>
	<cfloop array="#possibleArgs#" item="argName" index="i">
		<cfif args.keyExists( argName )>
			data-#LCase( ReReplace( argName, "([A-Z])", "-\1", "all" ) )#="#HtmlEditFormat( args[ argname ] )#"
		</cfif>
	</cfloop>
	>#buttonLabel#</button>
</cfoutput>