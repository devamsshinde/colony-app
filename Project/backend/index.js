require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { supabase, supabaseAdmin } = require('./config/supabase');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    supabase: supabaseUrl ? 'configured' : 'missing'
  });
});

// Test Supabase connection endpoint
app.get('/test-supabase', async (req, res) => {
  try {
    const { data, error } = await supabase.from('_test').select('*').limit(1);
    
    if (error) {
      return res.status(500).json({
        success: false,
        message: 'Supabase connection test failed',
        error: error.message
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Supabase connection successful',
      data: data || 'Test query executed (table may not exist)'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Supabase connection test failed',
      error: error.message
    });
  }
});

// Basic info endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Backend API is running',
    services: {
      supabase: {
        url: supabaseUrl ? 'configured' : 'not configured',
        features: ['Auth', 'PostgreSQL + PostGIS', 'Realtime', 'Storage']
      },
      redis: process.env.REDIS_URL ? 'configured' : 'not configured'
    },
    endpoints: {
      health: '/health',
      testSupabase: '/test-supabase',
      docs: 'Coming soon...'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Supabase URL: ${supabaseUrl ? 'Configured' : 'Not configured'}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
});