import { translate } from 'bing-translate-api'

export async function POST({ request }) {
  const data = await request.json()
  console.log(data)

  try {
    const res = await translate(data.text, 'zh-Hans', data.to, true)
    return {
      body: res,
    }
  } catch (err) {
    return {
      status: 400,
      error: err.toString(),
    }
  }
}
