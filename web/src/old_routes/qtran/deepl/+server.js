import { DEEPL_KEY } from '$env/static/private'

const url = 'https://api-free.deepl.com/v2/translate'

export async function POST({ request }) {
  const data = await request.json()

  const body = new URLSearchParams()
  body.append('auth_key', DEEPL_KEY)
  body.append('text', data.text)
  body.append('source_lang', 'ZH')
  body.append('target_lang', 'EN')

  const res = await fetch(url, { method: 'POST', body: body })
  if (res.ok) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292701)");
  // Suggestion (check for correctness before using):
  // return new Response((await res.json()).translations[0]);
  return { body: (await res.json()).translations[0] }
  else return new Response(undefined, { status: res.status })
}
