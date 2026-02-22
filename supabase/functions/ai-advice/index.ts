import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `Jesteś życzliwym ekspertem ds. żywienia i aktywności fizycznej w aplikacji Łatwa Forma.
Odpowiadaj krótko i konkretnie (max 2–3 akapity). Daj praktyczne porady.
Używaj języka polskiego. Nie podawaj informacji medycznych zastępujących konsultację z lekarzem.`;

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
    try {
      const body = (await req.json()) as { question?: string } | null;
      question = typeof body?.question === "string" ? body.question.trim() : "";
    } catch {
      // ignore
    }
    if (!question) {
      return new Response(
        JSON.stringify({ error: "Brak pytania (question)." }),
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
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: question },
        ],
        max_tokens: 500,
      }),
    });

    if (!openaiRes.ok) {
      const errText = await openaiRes.text();
      console.error("OpenAI API error:", openaiRes.status, errText);
      let userMessage = "Błąd usługi porad. Spróbuj ponownie później.";
      try {
        const errJson = JSON.parse(errText) as { error?: { message?: string }; message?: string };
        const apiMsg = errJson?.error?.message ?? errJson?.message;
        if (typeof apiMsg === "string") {
          if (openaiRes.status === 401) userMessage = "Nieprawidłowy klucz OpenAI. Sprawdź OPENAI_API_KEY w Supabase.";
          else if (openaiRes.status === 429) userMessage = "Limit zapytań OpenAI. Spróbuj za chwilę.";
          else if (apiMsg.toLowerCase().includes("insufficient_quota")) userMessage = "Brak środków na koncie OpenAI. Doładuj konto na platform.openai.com.";
          else userMessage = apiMsg;
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
