import { detitlize, send_vcache } from './shared'

let api_key = ''
let api_exp = 0

export async function ms_api_key() {
  if (api_exp >= new Date().getTime()) return api_key
  else api_key = ''

  const res = await fetch('https://edge.microsoft.com/translate/auth')
  if (!res.ok) return api_key

  api_exp = new Date().getTime() + 500_000
  api_key = await res.text()

  return api_key
}

async function gen_headers() {
  const api_key = ms_api_key()
  if (!api_key) throw 'Không lấy được api key free!'

  return {
    'Authorization': `Bearer ${api_key}`,
    'Content-type': 'application/json',
    'X-ClientTraceId': crypto.randomUUID(),
  }
}

const api_url = 'https://api.cognitive.microsofttranslator.com'
const tl_root = `${api_url}/translate?api-version=3.0&textType=plain`

const word_cached = new Map<string, string[]>()

export async function btran_word(text: string, sl = 'auto', keep_caps = false) {
  const key = `${text}-${sl}`
  let res = word_cached.get(key)

  if (!res) {
    res = await call_btran_word(text, sl)
    if (res.length > 0) word_cached.set(key, res)
  }

  const res2 = res.map((x: string) => detitlize(x))
  if (!keep_caps) res = res2
  else res = res.concat(res2)

  return [...new Set(res)]
}

async function call_btran_word(text: string, sl = 'auto') {
  const body = JSON.stringify([{ text }])
  const headers = await gen_headers()

  try {
    let url = `${tl_root}&to=vi&to=en`
    if (sl == 'zh') sl = 'zh-Hans'
    if (sl != 'auto') url += '&from=' + sl
    const res = await fetch(url, { method: 'POST', body, headers })

    const [{ translations: data }] = await res.json()
    const tran = data.map(({ text }) => text) as string[]

    send_vcache('btran-line', { lang: 've', text, tran })
    return tran
  } catch (ex) {
    console.log(ex)
    return []
  }
}

export async function btran_text(lines: string[]) {
  const url = `${tl_root}&to=vi&from=zh-Hans`
  const body = JSON.stringify(lines.map((text) => ({ text })))
  const headers = await gen_headers()

  try {
    const res = await fetch(url, { method: 'POST', body, headers })
    if (!res.ok) return []

    const data = await res.json()
    const trans = data.map(({ translations: [{ text }] }) => text) as string[]

    send_vcache('btran-chap', { lang: 'v', lines, trans })

    return trans
  } catch (ex) {
    console.log(ex)
    return []
  }
}
