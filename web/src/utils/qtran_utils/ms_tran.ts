import { send_vcache } from './shared'

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

async function gen_headers(api_key: string) {
  if (!api_key) throw 'Không lấy được api key free!'

  return {
    'Authorization': `Bearer ${api_key}`,
    'Content-type': 'application/json',
    'X-ClientTraceId': crypto.randomUUID(),
  }
}

const api_url = 'https://api.cognitive.microsofttranslator.com'
const tl_root = `${api_url}/translate`

const word_cached = new Map<string, string[]>()

export async function btran_word(text: string, sl = 'auto') {
  const c_ukey = `${text}-${sl}`
  let trans = word_cached.get(c_ukey)
  if (trans) return trans

  trans = await call_btran_word(text, sl)
  if (trans.length > 0) word_cached.set(c_ukey, trans)
  return trans
}

async function call_btran_word(text: string, sl = 'auto') {
  const body = JSON.stringify([{ text }])
  const headers = await gen_headers(await ms_api_key())

  try {
    if (sl == 'zh') sl = 'zh-Hans'
    let url = `${api_url}/translate?from=${sl}&to=vi&to=en&api-version=3.0&textType=plain`
    const res = await fetch(url, { method: 'POST', body, headers })
    if (!res.ok) return []

    const [{ translations: data }] = await res.json()
    let tran = data.map(({ text }) => text) as string[]
    tran = [...new Set(tran)]

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
  const headers = await gen_headers(await ms_api_key())

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
