const langs = [
  ['zh', 'en'],
  ['zh', 'vi'],
  ['ja', 'en'],
]

// prettier-ignore
const root = 'https://translate.googleapis.com/translate_a/single?client=gtx&text=&dt=t'

const cached = {}

export async function gtran(text: string, lang: number) {
  const key = `${text}-${lang}`
  const val = cached[key]
  if (val) return val

  const [sl, tl] = langs[lang]

  const url = `${root}&sl=${sl}&tl=${tl}&q=${text}`
  const res = await fetch(url)

  const data = JSON.parse(await res.text())

  cached[key] = data[0][0][0]
  return cached[key]
}
