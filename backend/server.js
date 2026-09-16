const http = require('http');
const { URL } = require('url');

const PORT = Number(process.env.PORT || 8787);
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';
const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-5.6-luna';
const OPENAI_URL = process.env.OPENAI_URL || 'https://api.openai.com/v1/responses';
const started = Date.now();
const rate = new Map();
const WINDOW_MS = 60_000;
const MAX_REQUESTS = Number(process.env.RATE_LIMIT_PER_MINUTE || 60);
const MAX_BODY = 1_000_000;
const PROVIDER_TIMEOUT_MS = Number(process.env.AI_TIMEOUT_MS || 45_000);

const MODE_INSTRUCTIONS = {
  assistant: 'ساعد الطالب في طلبه الدراسي بدقة، ونظّم الإجابة بعناوين ونقاط واضحة.',
  explain: 'اشرح المفهوم خطوة بخطوة بلغة عربية مناسبة للطالب، مع مثال بسيط وتحقق قصير من الفهم.',
  summary: 'لخّص المحتوى دون اختلاق معلومات، مع الأفكار الرئيسية والمصطلحات والأمثلة المهمة.',
  questions: 'حوّل المحتوى إلى أسئلة متنوعة تغطي ما تمت مذاكرته، مع إجابات مختصرة في النهاية.',
  flashcards: 'أنشئ بطاقات مراجعة بصيغة سؤال ثم جواب، قصيرة وواضحة وقابلة للحفظ.',
  mindmap: 'حوّل المحتوى إلى خريطة ذهنية هرمية: موضوع رئيسي ← محاور ← نقاط فرعية.',
  design: 'أعد تنظيم المحتوى في تصميم نصي مناسب للمذاكرة: عنوان، مفاهيم، خطوات، أمثلة، مراجعة سريعة.',
  review: 'حلّل المحتوى لتحديد نقاط الضعف والأخطاء المتوقعة واقترح مراجعة عملية.',
  homework: 'ساعد في حل الواجب خطوة بخطوة، وفسّر سبب كل خطوة ثم اقترح طريقة للتحقق من الإجابة.',
};

function json(res, status, data) {
  const body = JSON.stringify(data);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  });
  res.end(body);
}

function allowed(ip) {
  const now = Date.now();
  const current = rate.get(ip) || { at: now, count: 0 };
  if (now - current.at > WINDOW_MS) {
    current.at = now;
    current.count = 0;
  }
  current.count += 1;
  rate.set(ip, current);
  return current.count <= MAX_REQUESTS;
}

function extractResponseText(data) {
  if (typeof data?.output_text === 'string') return data.output_text;
  if (!Array.isArray(data?.output)) return '';

  const parts = [];
  for (const item of data.output) {
    if (!Array.isArray(item?.content)) continue;
    for (const content of item.content) {
      if (typeof content?.text === 'string') parts.push(content.text);
    }
  }
  return parts.join('\n').trim();
}

async function callOpenAI(prompt, mode) {
  if (!OPENAI_API_KEY) {
    const error = new Error('OPENAI_API_KEY is not configured on the backend.');
    error.statusCode = 503;
    throw error;
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), PROVIDER_TIMEOUT_MS);

  const instructions = [
    'أنت مساعد دراسي داخل تطبيق «مساعد الطالب الذكي».',
    'أجب بالعربية افتراضياً ما لم يطلب الطالب لغة أخرى.',
    'لا تخترع معلومات غير موجودة في المحتوى المقدم، واطلب التوضيح عند نقص البيانات.',
    MODE_INSTRUCTIONS[mode] || MODE_INSTRUCTIONS.assistant,
  ].join('\n');

  try {
    const response = await fetch(OPENAI_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        instructions,
        input: prompt,
      }),
      signal: controller.signal,
    });

    const raw = await response.text();
    let data;
    try {
      data = JSON.parse(raw);
    } catch (_) {
      data = {};
    }

    if (!response.ok) {
      const providerMessage = data?.error?.message || `OpenAI HTTP ${response.status}`;
      const error = new Error(providerMessage);
      error.statusCode = response.status === 429 ? 429 : 502;
      throw error;
    }

    const text = extractResponseText(data);
    if (!text) {
      const error = new Error('وصل رد من OpenAI بدون نص قابل للعرض.');
      error.statusCode = 502;
      throw error;
    }
    return text;
  } finally {
    clearTimeout(timer);
  }
}

async function readJsonBody(req) {
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    if (Buffer.byteLength(raw, 'utf8') > MAX_BODY) {
      const error = new Error('payload_too_large');
      error.statusCode = 413;
      throw error;
    }
  }
  try {
    return JSON.parse(raw || '{}');
  } catch (_) {
    const error = new Error('invalid_json');
    error.statusCode = 400;
    throw error;
  }
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') return json(res, 204, {});

  const ip = req.socket.remoteAddress || 'unknown';
  if (!allowed(ip)) return json(res, 429, { error: 'rate_limit', message: 'تم تجاوز حد الطلبات مؤقتاً.' });

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (req.method === 'GET' && url.pathname === '/health') {
    return json(res, 200, {
      ok: true,
      version: '2251.0.0',
      uptimeSeconds: Math.floor((Date.now() - started) / 1000),
      provider: 'openai',
      providerConfigured: Boolean(OPENAI_API_KEY),
      model: OPENAI_MODEL,
    });
  }

  if (req.method === 'POST' && url.pathname === '/ai') {
    try {
      const body = await readJsonBody(req);
      const prompt = typeof body.prompt === 'string' ? body.prompt.trim() : '';
      const mode = typeof body.mode === 'string' ? body.mode : 'assistant';

      if (!prompt) return json(res, 400, { error: 'prompt_required', message: 'الطلب الدراسي مطلوب.' });
      if (prompt.length > 200_000) {
        return json(res, 413, { error: 'prompt_too_large', message: 'المحتوى المرسل كبير جداً.' });
      }

      const text = await callOpenAI(prompt, mode);
      return json(res, 200, { text, mode, model: OPENAI_MODEL });
    } catch (error) {
      const status = Number(error.statusCode) || 502;
      const safeMessage = status === 503
        ? 'خدمة الذكاء الاصطناعي غير مهيأة على الخادم بعد.'
        : status === 429
          ? 'تم تجاوز حد الطلبات. حاول مرة أخرى بعد قليل.'
          : status === 413
            ? 'حجم الطلب كبير جداً.'
            : status === 400
              ? 'صيغة الطلب غير صحيحة.'
              : 'تعذر تنفيذ طلب الذكاء الاصطناعي حالياً.';
      console.error('[AI]', error.message);
      return json(res, status, { error: 'ai_provider_error', message: safeMessage });
    }
  }

  return json(res, 404, { error: 'not_found' });
});

server.listen(PORT, () => {
  console.log(`Smart Student Assistant backend listening on ${PORT}`);
});
