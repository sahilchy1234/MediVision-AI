process.env.NODE_ENV = 'test';
const test = require('node:test');
const assert = require('node:assert');
const http = require('http');
const app = require('../src/server');

let server;
let port;
let baseUrl;

test.before(async () => {
  await new Promise((resolve) => {
    server = http.createServer(app);
    server.listen(0, () => {
      port = server.address().port;
      baseUrl = `http://localhost:${port}`;
      resolve();
    });
  });
});

test.after(async () => {
  await new Promise((resolve) => {
    if (server.closeAllConnections) {
      server.closeAllConnections();
    }
    server.close(resolve);
  });
});

async function apiRequest(path, options = {}) {
  const url = `${baseUrl}${path}`;
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Connection: 'close',
      ...(options.headers || {}),
    },
  });
  const data = await response.json();
  return { status: response.status, data };
}

test('1. Health check endpoint returns status ok', async () => {
  const res = await apiRequest('/api/health');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.status, 'ok');
  assert.strictEqual(res.data.service, 'MediVision AI Clinical Backend');
});

test('2. Seed user login succeeds with valid credentials', async () => {
  const res = await apiRequest('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      email: 'alex.morgan@medivision.health',
      password: 'Password123!',
    }),
  });

  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.success, true);
  assert.ok(res.data.data.tokens.accessToken, 'Access token should be present');
  assert.strictEqual(res.data.data.user.email, 'alex.morgan@medivision.health');
  assert.strictEqual(res.data.data.user.fullName, 'Alex Morgan');
  assert.strictEqual(res.data.data.user.gender, 'female');
});

test('3. Login fails with incorrect password', async () => {
  const res = await apiRequest('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      email: 'alex.morgan@medivision.health',
      password: 'WrongPassword!',
    }),
  });

  assert.strictEqual(res.status, 401);
  assert.strictEqual(res.data.success, false);
});

test('4. Register a brand new patient account', async () => {
  const uniqueEmail = `patient_${Date.now()}@medivision.health`;
  const res = await apiRequest('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      fullName: 'Dr. Sarah Connor',
      email: uniqueEmail,
      password: 'SecurePassword2026!',
      gender: 'female',
      dateOfBirth: '1990-08-15',
    }),
  });

  assert.strictEqual(res.status, 201);
  assert.strictEqual(res.data.success, true);
  assert.strictEqual(res.data.data.user.fullName, 'Dr. Sarah Connor');
  assert.strictEqual(res.data.data.user.email, uniqueEmail);
  assert.ok(res.data.data.tokens.accessToken, 'Token generated on registration');
});

test('5. Reject duplicate registration with same email', async () => {
  const res = await apiRequest('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      fullName: 'Alex Duplicate',
      email: 'alex.morgan@medivision.health',
      password: 'Password123!',
    }),
  });

  assert.strictEqual(res.status, 409);
  assert.strictEqual(res.data.success, false);
});

test('6. Access protected /api/auth/me with Bearer token', async () => {
  const loginRes = await apiRequest('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      email: 'alex.morgan@medivision.health',
      password: 'Password123!',
    }),
  });
  const token = loginRes.data.data.tokens.accessToken;

  const meRes = await apiRequest('/api/auth/me', {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  assert.strictEqual(meRes.status, 200);
  assert.strictEqual(meRes.data.success, true);
  assert.strictEqual(meRes.data.data.user.email, 'alex.morgan@medivision.health');
});

test('7. Reject access to /api/auth/me without valid Bearer token', async () => {
  const meRes = await apiRequest('/api/auth/me', {
    method: 'GET',
  });

  assert.strictEqual(meRes.status, 401);
  assert.strictEqual(meRes.data.success, false);
});

test('8. Logout client acknowledgment succeeds', async () => {
  const res = await apiRequest('/api/auth/logout', {
    method: 'POST',
  });

  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.success, true);
});
