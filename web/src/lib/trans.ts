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

  try {
    const res = await fetch(url)

    const data = JSON.parse(await res.text())

    gtran_cached[key] = data[0][0][0]
    return gtran_cached[key]
  } catch (err) {
    console.log(err)
    return null
  }
}

const btran_cached = {}

export async function btran(text: string, lang: number) {
  const key = `${text}-${lang}`
  const val = btran_cached[key]
  if (val) return val

  const body = { text, to: lang == 0 ? 'vi' : 'en' }
  const res = await fetch('/qtran/bing', {
    method: 'POST',
    body: JSON.stringify(body),
  })

  if (!res.ok) return ''
  const { translation } = await res.json()
  btran_cached[key] = translation
  return translation
}
