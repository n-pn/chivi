import { detitlize } from './qtran_util'

const endpoint = 'https://api.cognitive.microsofttranslator.com'
const free_api = 'https://edge.microsoft.com/translate/auth'

const results = {}
let api_key = { key: '', exp: 0 }

async function get_free_api_key() {
  const res = await fetch(free_api)
  if (!res.ok) return { key: '', exp: new Date().getTime() }
  return { key: await res.text(), exp: new Date().getTime() + 480_000 }
}

async function gen_headers() {
  if (!api_key.key || api_key.exp < new Date().getTime()) {
    api_key = await get_free_api_key()
  }

  if (!api_key.key) throw 'Không lấy được api key free'

  return {
    'Authorization': `Bearer ${api_key.key}`,
    'Content-type': 'application/json',
    'X-ClientTraceId': crypto.randomUUID(),
  }
}

export async function btran_word(text: string, sl = 'auto', no_cap = true) {
  const key = `${text}-${sl}`

  const val = results[key]
  if (val) return val

  let url = `${endpoint}/translate?to=vi&to=en&api-version=3.0&textType=plain`
  if (sl == 'zh') sl = 'zh-Hans'
  if (sl != 'auto') url += '&from=' + sl

  const body = JSON.stringify([{ text }])
  const headers = await gen_headers()

  try {
    const res = await fetch(url, { method: 'POST', body, headers })
    const [{ translations: data }] = await res.json()
    let tran = data.map((x) => x.text) as string[]
    if (no_cap) tran = tran.map((x) => detitlize(x))
    return [...new Set(tran)]
  } catch (ex) {
    console.log(ex)
    return []
  }
}
