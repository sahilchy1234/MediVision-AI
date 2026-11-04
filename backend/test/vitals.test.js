process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/server');

describe('MediVision AI - Vitals & Activity API Tests', () => {
  let server;
  let baseUrl;

  before(async () => {
    await new Promise((resolve) => {
      server = app.listen(0, () => {
        const port = server.address().port;
        baseUrl = `http://127.0.0.1:${port}`;
        resolve();
      });
    });
  });

  after(async () => {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  });

  test('1. GET /api/vitals returns user vitals snapshot and logs', async () => {
    const res = await fetch(`${baseUrl}/api/vitals`);
    const data = await res.json();
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.ok(data.data.snapshot);
    assert.ok(typeof data.data.snapshot.steps === 'number');
    assert.ok(typeof data.data.snapshot.restingHeartRate === 'number');
  });

  test('2. POST /api/vitals updates vitals snapshot and records a vital log', async () => {
    const payload = {
      steps: 9200,
      restingHeartRate: 64,
      bloodPressureSystolic: 119,
      bloodPressureDiastolic: 79,
      bloodOxygenSpO2: 99,
      logEntry: {
        category: 'pulse',
        label: 'Heart Rate Measured',
        value: '64 bpm',
        unit: 'bpm',
      },
    };

    const res = await fetch(`${baseUrl}/api/vitals`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const data = await res.json();
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.equal(data.data.snapshot.steps, 9200);
    assert.equal(data.data.snapshot.restingHeartRate, 64);
    assert.equal(data.data.snapshot.bloodPressureSystolic, 119);
    assert.equal(data.data.snapshot.bloodOxygenSpO2, 99);
  });

  test('3. POST /api/vitals/activity records a workout session and accumulates steps', async () => {
    const activityPayload = {
      type: 'Running',
      durationMinutes: 20,
      steps: 2200,
      calories: 140,
      distanceKm: 2.1,
    };

    const res = await fetch(`${baseUrl}/api/vitals/activity`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(activityPayload),
    });
    const data = await res.json();
    assert.equal(res.status, 201);
    assert.equal(data.success, true);
    assert.equal(data.data.activity.type, 'Running');
    assert.equal(data.data.activity.steps, 2200);
    assert.ok(data.data.snapshot.steps >= 2200);
  });

  test('4. GET /api/vitals/history returns activities and logs', async () => {
    const res = await fetch(`${baseUrl}/api/vitals/history`);
    const data = await res.json();
    assert.equal(res.status, 200);
    assert.equal(data.success, true);
    assert.ok(Array.isArray(data.data.activities));
    assert.ok(Array.isArray(data.data.logs));
  });
});
