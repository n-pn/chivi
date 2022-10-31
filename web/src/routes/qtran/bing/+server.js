import { error } from '@sveltejs/kit'
import { translate } from 'bing-translate-api'

export async function POST({ request }) {
  const data = await request.json()

  try {
    return await translate(data.text, 'zh-Hans', data.to, true)
  } catch (err) {
    throw error(500, err.toString())
  }
}
