process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/server');

describe('MediVision AI - Real Clinical Summary & Dossier API Tests', () => {
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

  test('1. GET /api/summary returns complete 360-degree patient clinical dossier', async () => {
    const res = await fetch(`${baseUrl}/api/summary`);
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(body.reportId);
    assert.ok(body.patient);
    assert.equal(body.patient.fullName, 'Alex Morgan MD');
    assert.ok(body.patient.bmi);
    assert.ok(body.executiveSummary);
    assert.ok(body.executiveSummary.healthScore >= 50);
    assert.ok(body.vitalsTelemetry);
    assert.ok(body.vitalsTelemetry.hemodynamics);
    assert.ok(body.vitalsTelemetry.hemodynamics.meanArterialPressure);
    assert.ok(body.physiologicalSystems);
    assert.ok(body.physiologicalSystems.cardiovascular);
    assert.ok(body.medicalRecordsVault);
    assert.ok(body.timelineMilestones);
    assert.ok(body.carePlan);
    assert.ok(Array.isArray(body.carePlan.physicianDiscussionGuide));
  });

  test('2. POST /api/summary/generate generates clinical summary dynamically', async () => {
    const res = await fetch(`${baseUrl}/api/summary/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(body.reportId);
    assert.ok(body.patient);
  });
});
