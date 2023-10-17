import { detitlize } from './qtran_util'

const api =
  'https://translate.googleapis.com/translate_a/single?client=gtx&dt=at'

const results = {}

export async function gtran_word(text: string, tl = 'vi', no_cap = true) {
  const key = `${text}-${tl}`

  const val = results[key]
  if (val) return val

  const url = `${api}&sl=auto&tl=${tl}&q=${text}`

  try {
    const res = await fetch(url)
    const data = JSON.parse(await res.text())[5][0][2]

    const tran = data.map((x) => x[0])
    results[key] = tran

    if (!no_cap) return tran
    return tran.map((x) => detitlize(x))
  } catch (ex) {
    console.log(ex)
    return []
  }
}
