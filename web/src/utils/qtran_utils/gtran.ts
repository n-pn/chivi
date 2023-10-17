const api =
  'https://translate.googleapis.com/translate_a/single?client=gtx&dt=t'

const results = {}

export async function gtran(text: string, sl = 'zh', tl = 'vi') {
  const key = `${text}-${sl}-${tl}`

  const val = results[key]
  if (val) return val

  const url = `${api}&sl=${sl}&tl=${tl}&q=${text}`

  try {
    const res = await fetch(url)
    const data = JSON.parse(await res.text())

    let tran = data[0][0][0].replace(/\*\s*,\s*/, '')
    if (sl == 'ja') tran = fix_japanese_name(tran)

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
