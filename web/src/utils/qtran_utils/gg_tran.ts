import { detitlize, send_vcache } from './shared'

const word_cached = new Map<string, string[]>()
const text_cached = new Map<string, string[]>()

export async function gtran_word(text: string, tl = 'vi', keep_caps = false) {
  const key = `${text}-${tl}`
  let res = word_cached.get(key)

  if (!res) {
    res = await call_gtran_word(text, tl)
    if (res.length > 0) word_cached.set(key, res)
  }

  const res2 = res.map((x: string) => detitlize(x))
  if (!keep_caps) res = res2
  else res = res.concat(res2)

  return [...new Set(res)]
}

export async function gtran_text(text: string, tl = 'vi') {
  const key = `${text}-${tl}`
  let cached = text_cached.get(key)
  if (cached) return cached

  cached = await call_gtran_text(text, tl)
  if (cached) text_cached.set(key, cached)

  return cached
}

const api = 'https://translate.googleapis.com/translate_a/single?client=gtx'

async function call_gtran_word(text: string, tl = 'vi') {
  if (!text) return []

  const url = `${api}&dt=at&sl=auto&tl=${tl}&q=${text}`
  const res = await fetch(url)

  const body = await res.text()
  if (!res.ok) return [body]

  const data = JSON.parse(body)[5][0][2]
  const tran = data.map(([x]) => x) as string[]

  send_vcache('gtran-line', { tl, text, tran })
  return tran
}

async function call_gtran_text(text: string, tl = 'vi') {
  if (!text) return []

  const url = `${api}&dt=t&sl=auto&tl=${tl}&q=${text}`
  const res = await fetch(url)

  const body = await res.text()
  if (!res.ok) return [body]

  const tran = JSON.parse(body)[0][0][0]
  send_vcache('gtran-line', { tl, text, tran })
  return tran.split('\n')
}
