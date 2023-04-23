const tabs = [
  ['zh', 'vi'],
  ['zh', 'en'],
  ['ja', 'en'],
]

const api =
  'https://translate.googleapis.com/translate_a/single?client=gtx&text=&dt=t'

const results = {}

export async function gtran(text: string, tab: number) {
  const key = `${text}-${tab}`

  const val = results[key]
  if (val) return val

  const [sl, tl] = tabs[tab]
  const url = `${api}&sl=${sl}&tl=${tl}&q=*,${text}`

  try {
    const res = await fetch(url)
    const data = JSON.parse(await res.text())

    let tran = data[0][0][0].replace(/\*\s*,\s*/, '')
    if (tab == 2) tran = fix_japanese_name(tran)

    results[key] = tran
    return results[key]
  } catch (ex) {
    console.log(ex)
    return null
  }
}

function fix_japanese_name(tran: string) {
  const [fname, lname] = tran.split(' ')
  return lname + ' ' + fname
}
