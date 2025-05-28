export default async function handler(req, res) {
  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": "Bearer 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",
      "Content-Type": "application/json",
      "X-Title": "Free ChatBot"
    },
    body: JSON.stringify(req.body),
  });

  const data = await response.json();
  res.status(response.status).json(data);
}
