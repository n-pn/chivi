import { detitlize } from './qtran_util'

const api =
  'https://translate.googleapis.com/translate_a/single?client=gtx&dt=at'

async function call_gtran_word(text: string, tl = 'vi') {
  const url = `${api}&sl=auto&tl=${tl}&q=${text}`
  const res = await fetch(url)
  const data = JSON.parse(await res.text())[5][0][2]
  return data.map((x) => x[0]) as string[]
}

const cached = new Map<string, string[]>()

export async function gtran_word(text: string, tl = 'vi', keep_caps = false) {
  const key = `${text}-${tl}`
  let res = cached.get(key)

  if (!res) {
    res = await call_gtran_word(text, tl)
    if (res.length > 0) cached.set(key, res)
  }

  const res2 = res.map((x: string) => detitlize(x))
  if (!keep_caps) res = res2
  else res = res.concat(res2)

  return [...new Set(res)]
}
