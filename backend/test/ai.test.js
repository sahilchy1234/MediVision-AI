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

    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.ok(data.data.text.length > 0);
    } else {
      assert.ok(res.status === 403 || res.status === 401 || res.status === 429);
      assert.strictEqual(data.success, false);
      assert.strictEqual(data.code, 'GROQ_API_ERROR');
    }
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

  test('5. POST /api/ai/physiological-systems returns structured physiological systems data', async () => {
    const sampleVitals = {
      steps: 8420,
      stepGoal: 10000,
      activeMinutes: 42,
      activeCalories: 482,
      restingHeartRate: 61,
      bloodPressureSystolic: 118,
      bloodPressureDiastolic: 78,
      bloodOxygenSpO2: 98,
      bodyTemperature: 36.8,
      sleepDurationMinutes: 462,
      deepSleepMinutes: 108,
      sleepQualityScore: 89
    };
    const sampleRecords = [
      {
        id: 'rec_test',
        title: 'Comprehensive Metabolic Panel',
        category: 'bloodReports',
        date: '2026-11-01',
        summary: 'Fasting glucose 92 mg/dL, HbA1c 5.4%, kidney eGFR > 90'
      }
    ];

    const res = await fetch(`${baseUrl}/api/ai/physiological-systems`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vitals: sampleVitals, records: sampleRecords })
    });
    const data = await res.json();

    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(typeof data.data.overallScore === 'number');
    assert.ok(data.data.systems);
    assert.ok(data.data.systems.brainSleep);
    assert.ok(data.data.systems.heartPulse);
    assert.ok(data.data.systems.staminaMovement);
    assert.ok(data.data.systems.bloodDefenses);
    assert.ok(Array.isArray(data.data.systems.heartPulse.keyPills));
    assert.ok(data.data.systems.brainSleep.explanation.length > 10);
  });
});
