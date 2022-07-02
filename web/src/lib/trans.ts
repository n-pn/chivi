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

  const url = `${gtran_api}&sl=${sl}&tl=${tl}&q=${text}`
  const res = await fetch(url)

  const data = JSON.parse(await res.text())

  gtran_cached[key] = data[0][0][0]
  return gtran_cached[key]
}

export async function btran(text: string, lang: number) {
  const body = new FormData()

  body.append('from', 'zh-Hans')
  body.append('to', lang == 0 ? 'vi' : 'en')
  body.append('text', text)

  const headers = {
    'sec-fetch-site': 'same-origin',
    'sec-fetch-mode': 'cors',
    'sec-fetch-dest': 'empty',
    'content-type': 'application/x-www-form-urlencoded',
  }

  const url = 'https://www.bing.com/ttranslatev3'
  const res = await fetch(url, { method: 'POST', headers, body })

  const data = await res.json()
  console.log(data)
  return '?'
}
