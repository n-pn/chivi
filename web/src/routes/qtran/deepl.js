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
  if (res.ok) return { body: (await res.json()).translations[0] }
  else return { status: res.status, error: await res.text() }
}