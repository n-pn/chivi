import { error } from '@sveltejs/kit'
import { translate } from 'bing-translate-api'

export async function POST({ request }) {
  const data = await request.json()

  try {
    const body = await translate(data.text, 'zh-Hans', data.to, true)

    return new Response(JSON.stringify(body), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (err) {
    throw error(500, err.toString())
  }
}
