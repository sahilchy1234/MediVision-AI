require('dotenv').config();
const http = require('http');
const ngrok = require('@ngrok/ngrok');

function isServerRunning(port) {
  return new Promise((resolve) => {
    const req = http.get(`http://127.0.0.1:${port}/api/health`, (res) => {
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.setTimeout(1200, () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function startTunnel() {
  const token = process.env.NGROK_AUTHTOKEN;
  const port = process.env.PORT || 5000;

  if (!token) {
    console.log('\n===============================================');
    console.log('⚠️  NGROK_AUTHTOKEN is missing in backend/.env');
    console.log('===============================================');
    console.log('1. Get your free authtoken at:');
    console.log('   https://dashboard.ngrok.com/get-started/your-authtoken');
    console.log('2. Add it to backend/.env:');
    console.log('   NGROK_AUTHTOKEN=your_token_here');
    console.log('3. Re-run: npm run tunnel');
    console.log('===============================================\n');
    process.exit(1);
  }

  // Automatically start backend server if it is not already running
  const running = await isServerRunning(port);
  if (!running) {
    console.log(`Starting Express backend server on port ${port}...`);
    require('./src/server');
    // Wait briefly for server to bind
    await new Promise((r) => setTimeout(r, 600));
  } else {
    console.log(`Express backend is already running on port ${port}.`);
  }

  try {
    const listener = await ngrok.forward({
      addr: port,
      authtoken: token,
    });

    const url = listener.url();
    console.log('\n===============================================');
    console.log('🚀 MediVision AI Server + Ngrok Tunnel are LIVE!');
    console.log(`📍 Local Server: http://127.0.0.1:${port}`);
    console.log(`🌐 Public URL:   ${url}`);
    console.log(`🩺 Health Check: ${url}/api/health`);
    console.log('===============================================');
    console.log('🟢 Leave this terminal running while using the app.');
    console.log('===============================================\n');

    // Keep the process alive
    setInterval(() => {}, 1000 * 60 * 60);

    process.on('SIGINT', async () => {
      console.log('\nClosing ngrok tunnel...');
      await listener.close();
      process.exit(0);
    });
  } catch (err) {
    console.error('❌ Failed to establish ngrok tunnel:', err.message || err);
  }
}

startTunnel();
