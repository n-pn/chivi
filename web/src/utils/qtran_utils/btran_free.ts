import { detitlize } from './qtran_util'

async function get_free_api_key() {
  const res = await fetch('https://edge.microsoft.com/translate/auth')
  if (!res.ok) return { key: '', exp: new Date().getTime() }
  return { key: await res.text(), exp: new Date().getTime() + 500_000 }
}

let api_key = { key: '', exp: 0 }
async function gen_headers() {
  if (!api_key.key || api_key.exp < new Date().getTime()) {
    api_key = await get_free_api_key()
  }

  if (!api_key.key) throw 'Không lấy được api key free!'

  return {
    'Authorization': `Bearer ${api_key.key}`,
    'Content-type': 'application/json',
    'X-ClientTraceId': crypto.randomUUID(),
  }
}

const api_url = 'https://api.cognitive.microsofttranslator.com'
const tl_root = `${api_url}/translate?api-version=3.0&textType=plain`

async function call_btran_word(text: string, sl = 'auto') {
  let url = `${tl_root}&to=vi&to=en`
  if (sl == 'zh') sl = 'zh-Hans'
  if (sl != 'auto') url += '&from=' + sl

  const body = JSON.stringify([{ text }])
  const headers = await gen_headers()

  try {
    const res = await fetch(url, { method: 'POST', body, headers })
    const [{ translations: data }] = await res.json()
    return data.map((x) => x.text) as string[]
  } catch (ex) {
    console.log(ex)
    return []
  }
}

const cached = new Map<string, string[]>()

export async function btran_word(text: string, sl = 'auto', no_cap = true) {
  const key = `${text}-${sl}`
  let res = cached.get(key)

  if (!res) {
    res = await call_btran_word(text, sl)
    if (res.length > 0) cached.set(key, res)
  }

  if (no_cap) res = res.map((x: string) => detitlize(x))
  return [...new Set(res)]
}

export async function btran_text(lines: string[]) {
  const url = `${tl_root}&to=vi&from=zh-Hans`
  const body = JSON.stringify(lines.map((text) => ({ text })))
  const headers = await gen_headers()

  try {
    const res = await fetch(url, { method: 'POST', body, headers })
    if (!res.ok) return []

    const data = await res.json()
    return data.map((x) => x.translations[0].text) as string[]
  } catch (ex) {
    console.log(ex)
    return []
  }
}
