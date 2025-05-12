const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Google API base URLs
const BASE_URLS = {
  places: 'https://maps.googleapis.com/maps/api/place',
  geocode: 'https://maps.googleapis.com/maps/api/geocode',
  directions: 'https://maps.googleapis.com/maps/api/directions',
  distance: 'https://maps.googleapis.com/maps/api/distancematrix',
  staticmap: 'https://maps.googleapis.com/maps/api/staticmap',
  streetview: 'https://maps.googleapis.com/maps/api/streetview',
  timezone: 'https://maps.googleapis.com/maps/api/timezone',
  elevation: 'https://maps.googleapis.com/maps/api/elevation',
  roads: 'https://roads.googleapis.com/v1',
  routes: 'https://routes.googleapis.com/directions',
  geolocation: 'https://www.googleapis.com/geolocation/v1'
};

// Specific route for Place Autocomplete (commonly used)
app.get('/api/places/autocomplete/json', async (req, res) => {
  const { input } = req.query;

  if (!input) {
    return res.status(400).json({ error: 'Missing required parameter: input' });
  }

  const url = `${BASE_URLS.places}/autocomplete/json`;

  try {
    const response = await axios.get(url, {
      params: {
        input,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// General-purpose GET proxy route
app.get('/api/:service/:endpoint', async (req, res) => {
  const { service, endpoint } = req.params;
  const baseUrl = BASE_URLS[service];

  if (!baseUrl) {
    return res.status(400).json({ error: `Invalid service: ${service}` });
  }

  // Construct URL
  let url = `${baseUrl}/${endpoint}`;
  if (!endpoint.includes('json') && baseUrl.includes('googleapis.com/maps/api')) {
    url += '/json'; // Add JSON if it's a Maps API and not already present
  }

  try {
    const response = await axios.get(url, {
      params: {
        ...req.query,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Geolocation POST route
app.post('/api/geolocation', async (req, res) => {
  try {
    const response = await axios.post(
      `${BASE_URLS.geolocation}/geolocate?key=${process.env.GOOGLE_MAPS_API_KEY}`,
      req.body
    );
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server on all interfaces
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Proxy server running at: http://0.0.0.0:${PORT}`);
});

