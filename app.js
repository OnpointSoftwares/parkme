const express = require('express');
const bodyParser = require('body-parser');
const mpesaRoutes = require('./mpesa');

const app = express();

// Trust first proxy (ngrok or reverse proxy)
app.set('trust proxy', 1);
const cors = require('cors');
app.use(cors());
app.use(bodyParser.json());
app.use('/api/mpesa', mpesaRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
