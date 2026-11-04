process.env.NODE_ENV = 'test';
const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const app = require('../src/server');

describe('MediVision AI - Medical Records API Tests', () => {
  let server;
  let baseUrl;

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
    await new Promise((resolve) => server.close(resolve));
  });

  test('1. GET /api/records returns list of medical records', async () => {
    const res = await fetch(`${baseUrl}/api/records`);
    const data = await res.json();

    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(Array.isArray(data.data));
  });

  test('2. POST /api/records creates a new record and saves it', async () => {
    const newRecord = {
      title: 'MRI Brain with Contrast',
      category: 'xRays',
      providerName: 'Advanced Imaging Center',
      date: new Date().toISOString(),
      fileSize: '32.4 MB DICOM',
      summary: 'Normal ventricular morphology, no acute infarct.',
      notes: 'Routine neurological checkup',
    };

    const res = await fetch(`${baseUrl}/api/records`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newRecord),
    });
    const data = await res.json();

    assert.strictEqual(res.status, 201);
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.title, 'MRI Brain with Contrast');
    assert.strictEqual(data.data.category, 'xRays');
    assert.ok(data.data.id);
  });

  test('3. POST /api/records/:id/analyze generates AI analysis', async () => {
    // Get existing records
    const listRes = await fetch(`${baseUrl}/api/records`);
    const listData = await listRes.json();
    const recordId = listData.data[0].id;

    const res = await fetch(`${baseUrl}/api/records/${recordId}/analyze`, {
      method: 'POST',
    });
    const data = await res.json();

    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.summary.includes('AI') || data.data.status.includes('Analyzed'));
  });
});

