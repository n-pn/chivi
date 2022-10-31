import { json as json$1 } from '@sveltejs/kit';
import { translate } from 'bing-translate-api'

export async function POST({ request }) {
  const data = await request.json()

  try {
    const res = await translate(data.text, 'zh-Hans', data.to, true)
    throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292701)");
    // Suggestion (check for correctness before using):
    // return json$1(res);
    return {
      body: res,
    }
  } catch (err) {
    return new Response(undefined, { status: 400 })
  }
}
