const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

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

// Explicit route for Place Autocomplete
app.get('/api/places/autocomplete/json', async (req, res) => {
  const { input } = req.query;
  const baseUrl = BASE_URLS['places'];
  if (!baseUrl) return res.status(400).json({ error: 'Invalid service' });

  const url = `${baseUrl}/autocomplete/json`;

  try {
    const response = await axios.get(url, {
      params: {
        input: input,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Generic GET API route
app.get('/api/:service/:endpoint', async (req, res) => {
  const { service, endpoint } = req.params;
  const params = req.query;

  const baseUrl = BASE_URLS[service];
  if (!baseUrl) return res.status(400).json({ error: 'Invalid service' });

  let url = `${baseUrl}/${endpoint}`;
  if (endpoint.includes('json')) {
    // Already has /json, no need to add it again
  } else {
    url += '/json';
  }

  try {
    const response = await axios.get(url, {
      params: {
        ...params,
        key: process.env.GOOGLE_MAPS_API_KEY
      }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Special POST route for Geolocation API
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

app.listen(PORT, () => {
  console.log(`✅ Proxy server running at: http://localhost:${PORT}`);
});
