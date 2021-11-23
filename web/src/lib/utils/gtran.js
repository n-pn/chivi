const langs = [
  ['zh', 'en'],
  ['zh', 'vi'],
  ['ja', 'en'],
]

const base_url =
  'https://translate.googleapis.com/translate_a/single?client=gtx&text=&dt=t'

const res_cache = {}

export async function gtran(text, lang) {
  const key = text + lang
  const val = res_cache[key]
  if (val) return val

  const [sl, tl] = langs[lang]

  const url = `${base_url}&sl=${sl}&tl=${tl}&q=${text}`
  const res = await fetch(url)

  const data = JSON.parse(await res.text())

  res_cache[key] = data[0][0][0]
  return res_cache[key]
}
