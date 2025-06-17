export default async function handler(req, res) {
  const allowedOrigins = [
    "https://sinlimites.vercel.app",
    "https://sinlimitesai.vercel.app",
    "https://sinlimites-lzg3uwshe-karen-moyolemas-projects.vercel.app",
    "https://sinlimites-jua6dp62e-karen-moyolemas-projects.vercel.app",
    "https://sinlimitesai-7y238qjkm-karen-moyolemas-projects.vercel.app",
  ];

  const origin = req.headers.origin;

  if (allowedOrigins.includes(origin)) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Vary", "Origin");
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  } else {
    return res.status(403).json({ error: "Origen no permitido" });
  }

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { messages } = req.body;

  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "X-Title": "Free ChatBot",
      },
      body: JSON.stringify({
        model: "openai/gpt-3.5-turbo",
        messages: messages,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({ error: data });
    }

    res.status(200).json(data);
  } catch (error) {
    console.error("❌ Error en OpenRouter API:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
}
