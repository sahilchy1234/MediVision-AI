process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/server');

describe('MediVision AI - Real Women\'s Health API Tests', () => {
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

  test('1. GET /api/womens-health returns real user cycle data, logs and assessments', async () => {
    const res = await fetch(`${baseUrl}/api/womens-health`);
    const body = await res.json();

    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(body.data, 'Should return user women health data');
    assert.ok(body.data.cycleData, 'Should have cycleData');
    assert.ok(typeof body.data.cycleData.currentDayOfCycle === 'number');
    assert.ok(typeof body.data.cycleData.averageCycleLength === 'number');
    assert.ok(body.data.cycleData.currentPhase);
    assert.ok(Array.isArray(body.data.symptomLogs));
    assert.ok(Array.isArray(body.data.assessments));
  });

  test('2. POST /api/womens-health/cycle updates real cycle settings and recalculates metrics', async () => {
    const lastPeriod = new Date(Date.now() - 10 * 86400000).toISOString();
    const payload = {
      averageCycleLength: 30,
      averagePeriodDuration: 5,
      lastPeriodStartDate: lastPeriod,
      cycleVariationDays: 1.8,
    };

    const res = await fetch(`${baseUrl}/api/womens-health/cycle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json();

    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.averageCycleLength, 30);
    assert.equal(body.data.currentDayOfCycle, 11);
    assert.equal(body.data.currentPhase, 'follicular');
  });

  test('3. POST /api/womens-health/symptoms persists real daily symptom log', async () => {
    const logPayload = {
      date: new Date().toISOString(),
      flow: 'medium',
      crampsSeverity: 3,
      pelvicPainSeverity: 1,
      mood: 'Calm',
      physicalSymptoms: ['Mild Bloating', 'Tender Breasts'],
      pcosObservations: ['Jawline / Cystic Breakout'],
      basalBodyTemp: 36.8,
      cervicalMucus: 'Egg-white (Fertile)',
      notes: 'Logged via mobile clinical telemetry.',
    };

    const res = await fetch(`${baseUrl}/api/womens-health/symptoms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(logPayload),
    });
    const body = await res.json();

    assert.equal(res.status, 201);
    assert.equal(body.success, true);
    assert.equal(body.data.crampsSeverity, 3);
    assert.equal(body.data.basalBodyTemp, 36.8);
    assert.ok(Array.isArray(body.symptomLogs));
  });

  test('4. POST /api/womens-health/screenings/analyze generates real clinical screening patterns', async () => {
    const payload = {
      userProfile: {
        fullName: 'Alex Morgan',
        gender: 'Female',
        dateOfBirth: '1995-04-12',
        heightCm: 168,
        weightKg: 58,
        medicalConditions: ['Asthma'],
      },
      cycleData: {
        currentDayOfCycle: 14,
        averageCycleLength: 29,
        averagePeriodDuration: 5,
        cycleVariationDays: 2.5,
      },
      symptomLogs: [
        {
          date: new Date().toISOString(),
          flow: 'none',
          crampsSeverity: 3,
          pelvicPainSeverity: 2,
          physicalSymptoms: ['Lower Back Pain'],
          pcosObservations: ['Jawline / Cystic Breakout'],
          basalBodyTemp: 36.7,
          cervicalMucus: 'Egg-white (Fertile)',
        }
      ],
      records: [],
    };

    const res = await fetch(`${baseUrl}/api/womens-health/screenings/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json();

    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.assessments));
    assert.equal(body.assessments.length, 4);

    const pcos = body.assessments.find(a => a.id === 'pcos_pcod');
    assert.ok(pcos, 'PCOS assessment must be present');
    assert.ok(typeof pcos.scorePercent === 'number');
    assert.ok(Array.isArray(pcos.identifiedMarkers));
    assert.ok(Array.isArray(pcos.recommendedLabTests));
  });

  test('5. POST /api/womens-health/vault/toggle toggles real private vault lock state', async () => {
    const res = await fetch(`${baseUrl}/api/womens-health/vault/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });
    const body = await res.json();

    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(typeof body.vaultLocked === 'boolean');
  });
});

