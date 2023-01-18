const gtran_langs = [
  ['zh', 'en'],
  ['zh', 'vi'],
  ['ja', 'en'],
]

// prettier-ignore
const gtran_api = 'https://translate.googleapis.com/translate_a/single?client=gtx&text=&dt=t'

const gtran_cached = {}

export async function gtran(text: string, lang: number) {
  const key = `${text}-${lang}`
  const val = gtran_cached[key]
  if (val) return val

  const [sl, tl] = gtran_langs[lang]

  const url = `${gtran_api}&sl=${sl}&tl=${tl}&q=*,${text}`

  try {
    const res = await fetch(url)
    const data = JSON.parse(await res.text())

    const tran = data[0][0][0]
    gtran_cached[key] = tran.replace(/\*,\s*/, '')
    return gtran_cached[key]
  } catch (err) {
    console.log(err)
    return null
  }
}

const headers = { 'content-type': 'text/plain' }

const btran_cached = {}

export async function btran(text: string, lang: string, no_cap = false) {
  const key = `${text}-${lang}`

  const val = btran_cached[key]
  if (val) return val

  const url = `/_sp/btran?lang=${lang}&no_cap=${no_cap}`
  const res = await fetch(url, { method: 'PUT', body: text, headers })

  const res_text = await res.text()
  btran_cached[key] = res_text
  return res_text
}

const deepl_cached = {}

export async function deepl(text: string, no_cap = false) {
  const val = deepl_cached[text]
  if (val) return val

  const url = `/_sp/deepl?no_cap=${no_cap}`
  const res = await fetch(url, { method: 'PUT', body: text, headers })

  const res_text = await res.text()
  deepl_cached[text] = res_text
  return res_text
}
