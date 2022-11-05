// @ts-ignore
import { DEEPL_KEY } from '$env/static/private'
import { error } from '@sveltejs/kit'

const url = 'https://api-free.deepl.com/v2/translate'

export async function POST({ request, fetch }) {
  const data = await request.json()

  const body = new URLSearchParams()
  body.append('auth_key', DEEPL_KEY)
  body.append('text', data.text)
  body.append('source_lang', 'ZH')
  body.append('target_lang', 'EN')

  const res = await fetch(url, { method: 'POST', body: body })
  if (!res.ok) throw error(res.status, await res.text())

  const res_body = (await res.json()).translations[0]

  return new Response(JSON.stringify(res_body), {
    headers: { 'Content-Type': 'application/json' },
  })
}
