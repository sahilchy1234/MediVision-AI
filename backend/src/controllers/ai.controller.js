const CLINICAL_SYSTEM_PROMPT = `You are MediVision AI, an empathetic, highly intelligent, evidence-based clinical AI health companion.

Your responsibilities:
1. Provide accurate, empathetic, and scientifically grounded explanations of clinical queries, biomarkers, symptoms, and health telemetry.
2. Format your responses with structured Markdown: use clean headings, bullet points, bold key metrics, and actionable takeaways.
3. If medical attachments (X-rays, blood reports, prescriptions, discharge summaries) are mentioned or attached, analyze their findings thoroughly against standard reference ranges.
4. Suggest constructive questions the patient can discuss with their prescribing physician or specialist.
5. Maintain patient safety: always include an educational note clarifying that MediVision AI insights assist comprehension but do not replace personalized physician diagnosis.`;

const SUPPORTED_MODELS = [
  { id: 'llama-3.3-70b-versatile', name: 'Llama 3.3 70B (Versatile & Clinical)', default: true },
  { id: 'llama-3.1-8b-instant', name: 'Llama 3.1 8B Instant (Ultra-Fast)' },
  { id: 'openai/gpt-oss-20b', name: 'GPT OSS 20B' },
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

    const apiKey = (req.headers['x-groq-api-key'] || process.env.GROQ_API_KEY || '').trim();

    if (!apiKey) {
      return res.status(401).json({
        success: false,
        code: 'NO_GROQ_KEY',
        message: 'Groq API key is not configured. Please supply GROQ_API_KEY in backend/.env or in the app settings.'
      });
    }

    const selectedModel = model || process.env.GROQ_MODEL || 'llama-3.3-70b-versatile';

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

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: selectedModel,
        messages,
        temperature: 0.5,
        max_tokens: 1200
      })
    });

    const data = await response.json();

    if (!response.ok) {
      const errorMsg = data?.error?.message || `Groq API responded with status ${response.status}`;
      return res.status(response.status).json({
        success: false,
        code: 'GROQ_API_ERROR',
        message: errorMsg
      });
    }

    const replyText = data.choices?.[0]?.message?.content || 'No response generated.';

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
  const isConfigured = !!(process.env.GROQ_API_KEY && process.env.GROQ_API_KEY.trim().length > 0);
  res.json({
    success: true,
    data: {
      provider: 'Groq LPU Inference Engine',
      isConfigured,
      defaultModel: process.env.GROQ_MODEL || 'llama-3.3-70b-versatile',
      models: SUPPORTED_MODELS
    }
  });
}

module.exports = {
  handleChat,
  getAiStatus,
  CLINICAL_SYSTEM_PROMPT,
  SUPPORTED_MODELS
};
