const functions = require("firebase-functions");
const stripe = require("stripe")("sk_test_51PaRqBHdm0or1WleGzDwi2431e6LmQXykaewCu1mxzmYbXc7FUcZkZqPOU7XYNXAc286XG1cD8fg5EBwg0C8W4XU00qBxd22Tw");

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
  const { email, amount } = req.body;

  if (!email || !amount) {
    return res.status(400).send({ error: 'Email and amount are required.' });
  }

  try {
    console.log(`Creating payment intent for ${email} with amount ${amount}`);

    let customerList = await stripe.customers.list({ email });
    let customer;
    if (customerList.data.length === 0) {
      customer = await stripe.customers.create({ email });
      console.log(`Created new customer: ${customer.id}`);
    } else {
      customer = customerList.data[0];
      console.log(`Found existing customer: ${customer.id}`);
    }

    let paymentIntentParams = {
      amount: Math.round(parseFloat(amount) * 100),
      currency: 'brl',
      receipt_email: email,
      customer: customer.id,
      setup_future_usage: 'off_session', // Adiciona setup_future_usage para salvar o cartão
      metadata: { integration_check: 'accept_a_payment' }
    };

    const paymentIntent = await stripe.paymentIntents.create(paymentIntentParams);
    console.log(`Payment intent created: ${paymentIntent.id}`);

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2020-08-27' }
    );

    res.status(200).send({
      id: paymentIntent.id,
      clientSecret: paymentIntent.client_secret,
      amount: paymentIntent.amount,
      customer: customer.id,
      ephemeralKey: ephemeralKey.secret,
    });
  } catch (error) {
    console.error("Error creating Payment Intent:", error);
    res.status(400).send({
      error: error.message
    });
  }
});

exports.capturePaymentIntent = functions.https.onRequest(async (req, res) => {
  const { paymentIntentId } = req.body;

  if (!paymentIntentId) {
    return res.status(400).send({ error: 'PaymentIntent ID is required.' });
  }

  try {
    console.log(`Capturing payment intent: ${paymentIntentId}`);
    const paymentIntent = await stripe.paymentIntents.capture(paymentIntentId);
    console.log(`Payment intent captured: ${paymentIntent.id}`);
    res.status(200).send(paymentIntent);
  } catch (error) {
    console.error("Failed to capture Payment Intent:", error);
    res.status(500).send({ error: error.message });
  }
});

exports.cancelPaymentIntent = functions.https.onRequest(async (req, res) => {
  const { paymentIntentId } = req.body;

  if (!paymentIntentId) {
    return res.status(400).send({ error: 'PaymentIntent ID is required.' });
  }

  try {
    console.log(`Canceling payment intent: ${paymentIntentId}`);
    const canceledPaymentIntent = await stripe.paymentIntents.cancel(paymentIntentId);
    console.log(`Payment intent canceled: ${canceledPaymentIntent.id}`);
    res.status(200).send(canceledPaymentIntent);
  } catch (error) {
    console.error("Failed to cancel Payment Intent:", error);
    res.status(500).send({ error: error.message });
  }
});

exports.refundPaymentIntent = functions.https.onRequest(async (req, res) => {
  const { paymentIntentId } = req.body;

  if (!paymentIntentId) {
    return res.status(400).send({ error: 'PaymentIntent ID is required.' });
  }

  try {
    console.log(`Attempting to refund Payment Intent: ${paymentIntentId}`);

    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    console.log(`Retrieved Payment Intent: ${paymentIntent.id}, Status: ${paymentIntent.status}`);

    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
    });

    console.log(`Refund successful for Payment Intent: ${paymentIntentId}`);
    res.status(200).send(refund);
  } catch (error) {
    console.error("Failed to refund Payment Intent:", error);
    console.error(`Error details: ${error.message}`);
    console.error(`Error stack: ${error.stack}`);
    console.error(`Full error object: ${JSON.stringify(error)}`);
    res.status(500).send({ error: error.message });
  }
});

exports.createSetupIntent = functions.https.onRequest(async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).send({ error: 'Email is required.' });
  }

  try {
    console.log(`Creating setup intent for ${email}`);

    let customerList = await stripe.customers.list({ email });
    let customer;
    if (customerList.data.length === 0) {
      customer = await stripe.customers.create({ email });
      console.log(`Created new customer: ${customer.id}`);
    } else {
      customer = customerList.data[0];
      console.log(`Found existing customer: ${customer.id}`);
    }

    // Check if customer already has a saved payment method
    const paymentMethods = await stripe.paymentMethods.list({
      customer: customer.id,
      type: 'card',
    });

    if (paymentMethods.data.length > 0) {
      console.log(`Customer already has a saved card: ${paymentMethods.data[0].id}`);
      return res.status(200).send({
        message: 'Customer already has a saved card.',
        paymentMethodId: paymentMethods.data[0].id,
      });
    }

    const setupIntent = await stripe.setupIntents.create({
      customer: customer.id,
      payment_method_types: ['card'],
    });

    console.log(`Setup intent created: ${setupIntent.id}`);

    res.status(200).send({
      clientSecret: setupIntent.client_secret,
    });
  } catch (error) {
    console.error("Error creating Setup Intent:", error);
    res.status(400).send({
      error: error.message
    });
  }
});

exports.listPaymentMethods = functions.https.onRequest(async (req, res) => {
  const { customerId } = req.body;

  try {
    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    res.status(200).send(paymentMethods);
  } catch (error) {
    console.error('Error listing payment methods:', error);
    res.status(400).send({ error: error.message });
  }
});
