const express = require('express');
const router = express.Router();
const { handleChat, handlePhysiologicalSystems, getAiStatus } = require('../controllers/ai.controller');

// Chat endpoint (Accepts prompt & returns real Groq LLM completion)
router.post('/chat', handleChat);

// Physiological Systems real-time AI evaluation feed
router.post('/physiological-systems', handlePhysiologicalSystems);

// Status endpoint (Returns current Groq provider status & models)
router.get('/status', getAiStatus);

module.exports = router;

