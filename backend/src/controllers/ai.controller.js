const CLINICAL_SYSTEM_PROMPT = `You are MediVision AI, an empathetic, highly intelligent, evidence-based clinical AI health companion.

Formatting Guidelines:
1. Structure every response with clean, readable Markdown:
   - Use clear section headers (### 1. Clinical Overview, ### 2. Key Findings & Observations, ### 3. Actionable Next Steps).
   - Bold all diagnostic tests, biomarker values, units, and ranges (e.g. **Fasting Glucose**: 92 mg/dL, **Systolic BP**: 122 mmHg).
   - Use organized bullet points for symptoms, laboratory values, and telemetry.
   - Use sequential numbered lists for doctor consultation prep.
   - Use clean Markdown tables when presenting comparative lab panels.
   - Always conclude with the full complete disclaimer line:
     > *Consult your doctor or qualified healthcare specialist for personalized medical advice.*
2. Never cut off or truncate sentences. Ensure every concluding thought and disclaimer is fully stated.
3. Never mention internal vendor names, API keys, or LPU hardware. Speak with patient-first clinical clarity, empathy, and scientific precision.
4. If medical attachments (X-rays, blood reports, prescriptions, discharge summaries) are mentioned or attached, analyze their findings thoroughly against standard reference ranges.`;

const DEFAULT_GROQ_KEY = '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';
const DEFAULT_MODEL = 'openai/gpt-oss-20b';

const SUPPORTED_MODELS = [
  { id: 'openai/gpt-oss-20b', name: 'GPT-OSS 20B (Default)', default: true },
  { id: 'llama-3.3-70b-versatile', name: 'Llama 3.3 70B' },
  { id: 'llama-3.1-8b-instant', name: 'Llama 3.1 8B Instant (Ultra-Fast)' },
  { id: 'mixtral-8x7b-32768', name: 'Mixtral 8x7B (Long Context)' },
  { id: 'gemma2-9b-it', name: 'Gemma 2 9B IT' }
];

/**
 * Handle AI Chat generation with Groq API
 */
async function handleChat(req, res, next) {
  try {
    const { prompt, attachment, history = [], model } = req.body;

    if (!prompt && !attachment) {
      return res.status(400).json({
        success: false,
        message: 'Prompt or attachment is required'
      });
    }

    const apiKey = (req.headers['x-groq-api-key'] || process.env.GROQ_API_KEY || DEFAULT_GROQ_KEY).trim();

    if (!apiKey) {
      return res.status(401).json({
        success: false,
        code: 'NO_GROQ_KEY',
        message: 'Groq API key is not configured.'
      });
    }

    const selectedModel = model || process.env.GROQ_MODEL || DEFAULT_MODEL;

    // Format attachment details if present
    let promptWithContext = prompt || '';
    if (attachment) {
      promptWithContext = `[Attached Medical File: ${attachment.fileName} (${attachment.fileType || 'medical_record'}, ${attachment.fileSize || 'Standard'})]\n\n${promptWithContext || 'Please analyze this medical record.'}`;
    }

    // Build chat message history for context
    const messages = [
      { role: 'system', content: CLINICAL_SYSTEM_PROMPT }
    ];

    if (Array.isArray(history)) {
      for (const msg of history.slice(-6)) {
        if (msg.role && msg.content) {
          messages.push({
            role: msg.role === 'user' ? 'user' : 'assistant',
            content: msg.content
          });
        }
      }
    }

    messages.push({
      role: 'user',
      content: promptWithContext
    });

    let response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: selectedModel,
        messages,
        temperature: 0.5,
        max_tokens: 2500
      })
    });

    let data = await response.json();

    // If model not found, gracefully try llama-3.3-70b-versatile
    if (!response.ok && (data?.error?.code === 'model_not_found' || data?.error?.message?.includes('model'))) {
      response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages,
          temperature: 0.5,
          max_tokens: 2500
        })
      });
      data = await response.json();
    }

    if (!response.ok) {
      const errorMsg = data?.error?.message || `Groq API responded with status ${response.status}`;
      return res.status(response.status).json({
        success: false,
        code: 'GROQ_API_ERROR',
        message: errorMsg
      });
    }

    let replyText = data.choices?.[0]?.message?.content || 'No response generated.';

    // Auto-complete truncated disclaimer if model cut off near the end
    replyText = replyText.replace(
      /(?:>\s*)?\*?Consult\s+your(?:\s+(?:physician|doctor|healthcare|care|specialist|medical)[^.\n]*)?(?:\*|\.)?\s*$/i,
      '> *Consult your doctor or qualified healthcare specialist for personalized medical advice.*'
    );

    return res.json({
      success: true,
      data: {
        text: replyText,
        model: data.model || selectedModel,
        usage: data.usage || null,
        referencedRecord: attachment?.fileName || null
      }
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Get Groq status and available models
 */
function getAiStatus(req, res) {
  res.json({
    success: true,
    data: {
      provider: 'Groq LPU Inference Engine',
      isConfigured: true,
      defaultModel: process.env.GROQ_MODEL || DEFAULT_MODEL,
      models: SUPPORTED_MODELS
    }
  });
}

module.exports = {
  handleChat,
  getAiStatus,
  CLINICAL_SYSTEM_PROMPT,
  SUPPORTED_MODELS,
  DEFAULT_GROQ_KEY,
  DEFAULT_MODEL
};
