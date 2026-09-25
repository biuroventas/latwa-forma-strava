import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT_PL = `Jesteś życzliwym ekspertem ds. żywienia i aktywności fizycznej w aplikacji Łatwa Forma.
Odpowiadaj krótko i konkretnie (max 2–3 akapity). Daj praktyczne porady.
Używaj języka polskiego.
Nie diagnozuj chorób, nie przepisuj leków i nie zastępuj konsultacji z lekarzem.
Odrzucaj prośby o niebezpieczne diety, skrajne ograniczenie kalorii, treści samookaleczające, nielegalne lub medyczne.
Jeśli pytanie dotyczy choroby, objawów lub leczenia – zasugeruj konsultację z lekarzem lub dietetykiem.
Na końcu krótkiej odpowiedzi dodaj: „To nie jest porada medyczna.”`;

const SYSTEM_PROMPT_EN = `You are a friendly nutrition and physical activity expert in the Łatwa Forma app.
Answer briefly and specifically (max 2–3 paragraphs). Give practical advice.
Use English.
Do not diagnose illnesses, prescribe medication, or replace a medical consultation.
Refuse requests for dangerous diets, extreme calorie restriction, self-harm, illegal, or medical content.
If the question is about a disease, symptoms, or treatment, suggest talking to a doctor or dietitian.
End the short answer with: "This is not medical advice."`;

const SYSTEM_PROMPT_UK = `Ти доброзичливий експерт із харчування та фізичної активності в застосунку Łatwa Forma.
Відповідай коротко і конкретно (максимум 2–3 абзаци). Давай практичні поради.
Використовуй українську мову.
Не став діагнозів, не призначай ліків і не замінюй консультацію лікаря.
Відхиляй прохання про небезпечні дієти, крайнє обмеження калорій, самоушкодження, незаконний або медичний зміст.
Якщо питання стосується хвороби, симптомів або лікування — порадь звернутися до лікаря чи дієтолога.
Наприкінці короткої відповіді додай: «Це не медична порада.»`;

function adviceLanguage(code: string | undefined): "pl" | "en" | "uk" {
  if (code === "en") return "en";
  if (code === "uk") return "uk";
  return "pl";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Brak autoryzacji" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "Porada AI nie jest skonfigurowana (brak OPENAI_API_KEY)." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let question = "";
    let language = "pl";
    try {
      const body = (await req.json()) as { question?: string; language?: string } | null;
      question = typeof body?.question === "string" ? body.question.trim() : "";
      language = adviceLanguage(body?.language);
    } catch {
      // ignore
    }
    const en = language === "en";
    const uk = language === "uk";
    if (!question) {
      return new Response(
        JSON.stringify({
          error: en
            ? "Missing question."
            : uk
            ? "Немає запитання (question)."
            : "Brak pytania (question).",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: en ? SYSTEM_PROMPT_EN : uk ? SYSTEM_PROMPT_UK : SYSTEM_PROMPT_PL,
          },
          { role: "user", content: question },
        ],
        max_tokens: 500,
      }),
    });

    if (!openaiRes.ok) {
      const errText = await openaiRes.text();
      console.error("OpenAI API error:", openaiRes.status, errText);
      let userMessage = en
        ? "Advice service error. Try again later."
        : uk
        ? "Помилка служби порад. Спробуй пізніше."
        : "Błąd usługi porad. Spróbuj ponownie później.";
      try {
        const errJson = JSON.parse(errText) as { error?: { message?: string }; message?: string };
        const apiMsg = errJson?.error?.message ?? errJson?.message;
        if (typeof apiMsg === "string") {
          if (openaiRes.status === 401) {
            userMessage = en
              ? "AI advice is not configured."
              : uk
              ? "Пораду ШІ не налаштовано."
              : "Nieprawidłowy klucz OpenAI. Sprawdź OPENAI_API_KEY w Supabase.";
          } else if (openaiRes.status === 429) {
            userMessage = en
              ? "Too many AI requests. Try again in a moment."
              : uk
              ? "Забагато запитів до ШІ. Спробуй за хвилину."
              : "Limit zapytań OpenAI. Spróbuj za chwilę.";
          } else if (apiMsg.toLowerCase().includes("insufficient_quota")) {
            userMessage = en
              ? "AI advice is temporarily unavailable."
              : uk
              ? "Порада ШІ тимчасово недоступна."
              : "Brak środków na koncie OpenAI. Doładuj konto na platform.openai.com.";
          } else userMessage = apiMsg;
        }
      } catch {
        // use default userMessage
      }
      return new Response(
        JSON.stringify({ error: userMessage, detail: openaiRes.status }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const data = (await openaiRes.json()) as {
      choices?: Array<{ message?: { content?: string } }>;
    };
    const content = data?.choices?.[0]?.message?.content ?? "";

    return new Response(
      JSON.stringify({ content }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("ai-advice error:", err);
    return new Response(
      JSON.stringify({
        error: err instanceof Error ? err.message : "Wystąpił błąd. Spróbuj ponownie.",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
