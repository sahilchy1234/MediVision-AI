require('dotenv').config();
const ngrok = require('@ngrok/ngrok');

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

  try {
    const listener = await ngrok.forward({
      addr: port,
      authtoken: token,
    });

    const url = listener.url();
    console.log('\n===============================================');
    console.log('🚀 Ngrok Tunnel is Live & Connected!');
    console.log(`🌐 Public URL: ${url}`);
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
