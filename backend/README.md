# MediVision AI — Node.js Clinical API Backend

Production-ready Node.js & Express RESTful API backend for **MediVision AI — Your Personal AI Health Companion & Intelligent Medical History Platform**.

---

## ⚡ Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment
Copy `.env.example` to `.env` (already created with sensible defaults):
```env
PORT=5000
NODE_ENV=development
JWT_SECRET=medivision_ultra_secure_jwt_secret_key_2026_clinical_ai
JWT_REFRESH_SECRET=medivision_ultra_secure_refresh_token_key_2026
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d
CLIENT_URL=*
```

### 3. Run Automated Tests
```bash
npm test
```
*Executes all 8 end-to-end authentication and health check test suites in under 1 second.*

### 4. Start the Server
* **Development (Auto-reload):**
  ```bash
  npm run dev
  ```
* **Production:**
  ```bash
  npm start
  ```
The server will boot up at `http://localhost:5000`.

---

## 🔐 Built-in Seed Demo Account

The database auto-initializes with a pre-configured demo patient account that matches the default prefilled credentials in the Flutter UI:
* **Email:** `alex.morgan@medivision.health`
* **Password:** `Password123!`
* **Full Name:** `Alex Morgan`
* **Gender:** `female`
* **Role:** `patient`

---

## 📡 API Reference & Endpoints

### 1. Health Check
* **`GET /api/health`**
* **Response (200 OK):**
```json
{
  "status": "ok",
  "service": "MediVision AI Clinical Backend",
  "version": "1.0.0",
  "timestamp": "2026-11-04T05:40:00.000Z",
  "uptimeSeconds": 42,
  "environment": "development"
}
```

---

### 2. User Sign In (Login)
* **`POST /api/auth/login`**
* **Headers:** `Content-Type: application/json`
* **Request Body:**
```json
{
  "email": "alex.morgan@medivision.health",
  "password": "Password123!"
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Authentication successful.",
  "data": {
    "user": {
      "id": "usr_demo_alex_morgan",
      "fullName": "Alex Morgan",
      "email": "alex.morgan@medivision.health",
      "gender": "female",
      "role": "patient",
      "lastLoginAt": "2026-11-04T05:45:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "eyJhbGciOi...",
      "tokenType": "Bearer"
    }
  }
}
```

---

### 3. User Sign Up (Register)
* **`POST /api/auth/register`**
* **Headers:** `Content-Type: application/json`
* **Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "password": "SecurePassword123!",
  "gender": "male",
  "dateOfBirth": "1992-06-20"
}
```
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Account created successfully. Welcome to MediVision AI!",
  "data": {
    "user": {
      "id": "usr_1730700000000_abc12",
      "fullName": "John Doe",
      "email": "john.doe@example.com",
      "gender": "male",
      "role": "patient",
      "createdAt": "2026-11-04T05:45:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "eyJhbGciOi...",
      "tokenType": "Bearer"
    }
  }
}
```

---

### 4. Get Current Authenticated Profile
* **`GET /api/auth/me`**
* **Headers:** 
  * `Authorization: Bearer <accessToken>`
* **Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_demo_alex_morgan",
      "fullName": "Alex Morgan",
      "email": "alex.morgan@medivision.health",
      "gender": "female",
      "role": "patient",
      "allergies": ["Penicillin", "Dust Mites"],
      "existingConditions": ["Asthma (Mild intermittent)"]
    }
  }
}
```

---

### 5. Refresh Access Token
* **`POST /api/auth/refresh`**
* **Request Body:**
```json
{
  "refreshToken": "<refreshToken>"
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOi...",
    "tokenType": "Bearer"
  }
}
```

---

### 6. Sign Out (Logout)
* **`POST /api/auth/logout`**
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "User logged out successfully. Tokens invalidated on client."
}
```

---

## 🏗 Architecture & Security Features

* **Password Security:** Salted hashes using `bcryptjs` (10 rounds).
* **JWT Access & Refresh Tokens:** Role-based claims with separate access and refresh secrets.
* **CORS Enabled:** Seamlessly accepts requests from Flutter Web (`http://localhost:*`), Flutter Mobile, and Flutter Desktop.
* **Zero Configuration Persistence:** Atomic file-based JSON repository in `data/users.json` that requires no external database engine installation and persists across server restarts.
* **Central Error & 404 Handling:** Structured JSON error responses across all routes.
