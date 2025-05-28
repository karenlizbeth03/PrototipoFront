export default async function handler(req, res) {
  const { messages, model } = req.body;

  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`,
      "Content-Type": "application/json",
      "X-Title": "Free ChatBot",
    },
    body: JSON.stringify({
      model: model || "openai/gpt-3.5-turbo",
      messages: messages,
    }),
  });

  const data = await response.json();
  res.status(200).json(data);
}
