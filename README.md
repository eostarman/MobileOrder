# MobileOrder

This contains the definition of the new 'Order' - the replacement for the LegacyMobileOrder.

Data trasmitted from eonetservice (the web API used to communicate with eoStar) is an encoded LegacyOrder - the LegacyOrder reflects what is in dbo.Orders and dbo.OrderLines.

To transmit an order to eonetservice, it must be converted to a LegacyOrder, then encoded using the LegacyOrder encoder, then packaged into a MobileUpload. It is then transmitted to eonetservice (in a zipstream format) and a separate web methoc is called to actually decode and post the zipped MobileUpload.

eonetservice will respond with a message showing what was changed in the order (e.g. any price corrections or quantity adjustments due to inventory limitations or rules such as the layer rounding rules)
