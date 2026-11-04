process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const app = require('../src/server');

describe('MediVision AI - Groq AI Companion API Tests', () => {
  let server;
  let baseUrl;
  const savedKey = process.env.GROQ_API_KEY;

  before(async () => {
    await new Promise((resolve) => {
      server = app.listen(0, () => {
        const port = server.address().port;
        baseUrl = `http://localhost:${port}`;
        resolve();
      });
    });
  });

  after(async () => {
    process.env.GROQ_API_KEY = savedKey;
    await new Promise((resolve) => server.close(resolve));
  });

  test('1. GET /api/ai/status returns provider and model details', async () => {
    const res = await fetch(`${baseUrl}/api/ai/status`);
    const data = await res.json();

    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.provider, 'Groq LPU Inference Engine');
    assert.ok(Array.isArray(data.data.models));
    assert.ok(data.data.models.length >= 3);
  });

  test('2. POST /api/ai/chat rejects request when prompt is missing', async () => {
    const res = await fetch(`${baseUrl}/api/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
    const data = await res.json();

    assert.strictEqual(res.status, 400);
    assert.strictEqual(data.success, false);
    assert.ok(data.message.includes('required'));
  });

  test('3. POST /api/ai/chat succeeds with default Groq key without manual header', async () => {
    const res = await fetch(`${baseUrl}/api/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'Brief greeting for health app' })
    });
    const data = await res.json();

    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.text.length > 0);
  });

  test('4. POST /api/ai/chat handles invalid Groq key gracefully', async () => {
    const res = await fetch(`${baseUrl}/api/ai/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-groq-api-key': 'gsk_invalid_test_key_1234567890'
      },
      body: JSON.stringify({ prompt: 'Hello MediVision' })
    });
    const data = await res.json();

    assert.strictEqual(data.success, false);
    assert.strictEqual(data.code, 'GROQ_API_ERROR');
    assert.ok(data.message);
  });
});
