const express = require('express');
const axios = require('axios');
const moment = require('moment');
const router = express.Router();

const consumerKey = 'vahwanLGhxm1NIk7AXMM6oXt4cNbq1B3';
const consumerSecret = 'JmPtlVDNciBLLXCM';
const baseUrl = 'https://sandbox.safaricom.co.ke';
const shortcode = '174379'; // Default shortcode for Safaricom sandbox
const passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919'; // Default passkey for Safaricom sandbox
const callbackUrl = 'https://eminently-rare-pegasus.ngrok-free.app/api/mpesa/callback';
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
// Rate limiting middleware
const stkPushLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: { error: 'Too many STK push requests, please try again later' }
});

// Phone number validation helper
function validatePhoneNumber(phone) {
  // Remove any spaces, dashes, or plus signs
  const cleanPhone = phone.replace(/[\s\-\+]/g, '');
  
  // Check if it's a valid Kenyan number
  const kenyanPhoneRegex = /^(254|0)?([17][0-9]{8})$/;
  const match = cleanPhone.match(kenyanPhoneRegex);
  
  if (!match) {
    return null;
  }
  
  // Return formatted number with 254 prefix
  return '254' + match[2];
}

// Get access token with caching
let cachedToken = null;
let tokenExpiry = null;

const https = require('https');

async function getAccessToken() {
  // Return cached token if still valid (with 5 minute buffer)
  if (cachedToken && tokenExpiry && moment().isBefore(moment(tokenExpiry).subtract(5, 'minutes'))) {
    return cachedToken;
  }

  try {
    const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString('base64');
    const agent = new https.Agent({ family: 4 }); // Force IPv4
    const response = await axios.get(
      `${baseUrl}/oauth/v1/generate?grant_type=client_credentials`,
      { 
        headers: { Authorization: `Basic ${auth}` },
        timeout: 10000, // 10 second timeout
        httpsAgent: agent
      }
    );
    
    cachedToken = response.data.access_token;
    // M-Pesa tokens typically expire in 1 hour
    tokenExpiry = moment().add(1, 'hour').toDate();
    
    return cachedToken;
  } catch (error) {
    console.error('Failed to get access token:', error.message);
    throw new Error('Authentication failed');
  }
}

// Validation middleware
const validateSTKPush = [
  body('phone')
    .notEmpty()
    .withMessage('Phone number is required')
    .custom((value) => {
      if (!validatePhoneNumber(value)) {
        throw new Error('Invalid phone number format. Use format: 254XXXXXXXXX or 07XXXXXXXX');
      }
      return true;
    }),
  body('amount')
    .isNumeric()
    .withMessage('Amount must be numeric')
    .custom((value) => {
      const amount = parseFloat(value);
      if (amount < 1 || amount > 70000) {
        throw new Error('Amount must be between 1 and 70,000 KES');
      }
      return true;
    })
];

// Initiate STK Push
router.post('/stkpush', stkPushLimiter, validateSTKPush, async (req, res) => {
  try {
    // Check validation results
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    console.log('Incoming STK Push request:', {
      phone: req.body.phone,
      amount: req.body.amount,
      ip: req.ip
    });

    const { amount } = req.body;
    const phone = validatePhoneNumber(req.body.phone);

    // Debug print credentials
    console.log('STK Credentials:', {
      consumerKey,
      consumerSecret,
      shortcode,
      passkey: '[REDACTED]'
    });
    
    const accessToken = await getAccessToken();
    const timestamp = moment().format('YYYYMMDDHHmmss');
    const password = Buffer.from(shortcode + passkey + timestamp).toString('base64');

    const payload = {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(parseFloat(amount)), // Ensure integer amount
      PartyA: phone,
      PartyB: shortcode,
      PhoneNumber: phone,
      CallBackURL: callbackUrl,
      AccountReference: 'ParkMe',
      TransactionDesc: 'Payment for Parking',
    };

    console.log('STK Payload:', {
      ...payload,
      Password: '[REDACTED]' // Don't log sensitive data
    });

    const response = await axios.post(
      `${baseUrl}/mpesa/stkpush/v1/processrequest`,
      payload,
      { 
        headers: { 
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout
      }
    );

    console.log('STK Push Response:', response.data);

    // Return standardized response
    res.json({
      success: true,
      message: 'STK Push initiated successfully',
      data: response.data
    });

  } catch (error) {
    console.error('STK Push Error:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status
    });

    if (error.response) {
      const status = error.response.status;
      const errorData = error.response.data;
      
      // Handle specific M-Pesa error codes
      if (status === 401) {
        return res.status(401).json({
          error: 'Authentication failed',
          message: 'Invalid credentials or expired token'
        });
      } else if (status === 400) {
        return res.status(400).json({
          error: 'Bad request',
          message: errorData.errorMessage || 'Invalid request parameters',
          details: errorData
        });
      } else if (status >= 500) {
        return res.status(503).json({
          error: 'Service unavailable',
          message: 'M-Pesa service is currently unavailable. Please try again later.'
        });
      }
      
      res.status(500).json({
        error: 'STK Push failed',
        message: errorData.errorMessage || 'Unknown error occurred',
        details: errorData
      });
    } else if (error.code === 'ECONNABORTED') {
      res.status(408).json({
        error: 'Request timeout',
        message: 'The request took too long to process. Please try again.'
      });
    } else {
      res.status(500).json({
        error: 'Internal server error',
        message: 'An unexpected error occurred'
      });
    }
  }
});

// Enhanced callback endpoint with basic validation
router.post('/callback', (req, res) => {
  try {
    console.log('M-Pesa Callback received:', {
      timestamp: moment().toISOString(),
      body: req.body,
      headers: req.headers
    });

    const { Body } = req.body;
    
    if (Body && Body.stkCallback) {
      const callback = Body.stkCallback;
      
      // Process the callback based on ResultCode
      if (callback.ResultCode === 0) {
        console.log('Payment successful:', {
          merchantRequestID: callback.MerchantRequestID,
          checkoutRequestID: callback.CheckoutRequestID
        });
        // TODO: Update database with successful payment
      } else {
        console.log('Payment failed:', {
          resultCode: callback.ResultCode,
          resultDesc: callback.ResultDesc
        });
        // TODO: Update database with failed payment
      }
    }

    // Always respond with success to acknowledge receipt
    res.json({ 
      ResultCode: 0, 
      ResultDesc: 'Callback received successfully' 
    });
    
  } catch (error) {
    console.error('Callback processing error:', error.message);
    // Still acknowledge receipt to prevent retries
    res.json({ 
      ResultCode: 0, 
      ResultDesc: 'Callback received with errors' 
    });
  }
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: moment().toISOString(),
    environment: 'sandbox'
  });
});

module.exports = router;