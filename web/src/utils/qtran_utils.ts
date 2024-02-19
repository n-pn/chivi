const word_cache = new Map<string, string[]>()

const gtran_href = 'https://translate.googleapis.com/translate_a/single?client=gtx'

export async function gtran_word(text: string, tl = 'vi', sl = 'auto') {
  if (!text) return []

  const c_ukey = `gword-${text}-${tl}-${sl}`
  const cached = word_cache.get(c_ukey)
  if (cached) return cached

  const resp = await fetch(`${gtran_href}&dt=at&sl=${sl}&tl=${tl}&q=${text}`)
  const body = await resp.text()
  if (!resp.ok) return [body]

  const data = JSON.parse(body)[5][0][2]
  const tran = data.map(([x]) => x) as string[]

  send_vcache('gtran-line', { tl, sl, text, tran })
  if (tran.length > 0) word_cache.set(c_ukey, tran)

  return tran
}

export async function gtran_text(text: string, tl = 'vi', sl = 'auto') {
  if (!text) return []

  const c_ukey = `gtext-${text}-${tl}-${sl}`
  const cached = word_cache.get(c_ukey)
  if (cached) return cached

  const resp = await fetch(`${gtran_href}&dt=t&sl=${sl}&tl=${tl}&q=${text}`)

  const body = await resp.text()
  if (!resp.ok) return [body]

  const data = JSON.parse(body)[0][0][0]
  const tran = data.map(([x]) => x) as string[]

  send_vcache('gtran-line', { tl, sl, text, tran })
  if (tran.length > 0) word_cache.set(c_ukey, tran)

  return tran
}

export const send_vcache = (type: string, data: Record<string, any>) => {
  const init = { method: 'POST', body: JSON.stringify(data) }
  fetch(`/_sp/vcache/${type}`, init).catch((x) => console.log(x))
}

export const call_qtran = async (
  body: string,
  type: string,
  opts: Record<string, any> = {}
): Promise<string[] | CV.Cvtree[]> => {
  if (type == 'gg_zv') return await gtran_text(body)

  const { pdict = 'combine', regen = 0, h_sep = 1, l_sep = 0, otype = 'mtl' } = opts
  const url = `/_sp/qtran/${type}?pd=${pdict}&rg=${regen}&hs=${h_sep}&ls=${l_sep}&op=${otype}`

  const start = performance.now()
  const res = await fetch(url, { method: 'POST', body })
  if (!res.ok) return [await res.text()]

  let vtran: string[] | CV.Cvtree[]

  if (type.startsWith('mtl') && otype == 'mtl') {
    vtran = (await res.json()) as CV.Cvtree[]
  } else {
    vtran = (await res.text()).trim().split('\n')
  }

  const spent = performance.now() - start
  console.log(`- ${type}: ${body.length} chars, ${spent} milliseconds`)

  if (!res.ok) return []
  return vtran
}
