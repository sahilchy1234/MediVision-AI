process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/server');

describe('MediVision AI - Real Clinical Timeline API Tests', () => {
  let server;
  let baseUrl;
  let createdEventId = null;

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

  test('1. GET /api/timeline returns aggregated real health events (records & vitals)', async () => {
    const res = await fetch(`${baseUrl}/api/timeline`);
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.data));

    const entries = body.data;
    assert.ok(entries.length > 0, 'Timeline should have real data entries from records and vitals');

    const first = entries[0];
    assert.ok(first.id, 'Entry must have id');
    assert.ok(first.title, 'Entry must have title');
    assert.ok(first.category, 'Entry must have category');
    assert.ok(first.timestamp, 'Entry must have timestamp');
  });

  test('2. POST /api/timeline creates a new user health event', async () => {
    const payload = {
      title: 'Blood Pressure & Heart Checkup',
      description: 'Clinic visit reading 118/78 mmHg.',
      category: 'symptoms',
      metricValue: '118/78 mmHg',
      statusLabel: 'Optimal',
      plainEnglishInsight: 'Blood pressure is completely within target range.',
      simplePillTag: 'Clinical Visit',
    };

    const res = await fetch(`${baseUrl}/api/timeline`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.success, true);
    assert.ok(body.data.id);
    assert.equal(body.data.title, payload.title);
    createdEventId = body.data.id;
  });

  test('3. DELETE /api/timeline/:id deletes the created event', async () => {
    assert.ok(createdEventId);
    const res = await fetch(`${baseUrl}/api/timeline/${createdEventId}`, {
      method: 'DELETE',
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.success, true);
  });
});
