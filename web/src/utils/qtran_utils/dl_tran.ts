const tabs = [
  ['ZH', 'EN'],
  ['JA', 'EN'],
]

const headers = { 'content-type': 'text/plain' }
const results = {}

export async function deepl_word(text: string, tab = 0, no_cap = false) {
  const key = `${text}-${tab}`

  const val = results[key]
  if (val) return val

  const [sl, tl] = tabs[tab]
  const url = `/_sp/deepl?sl=${sl}&tl=${tl}&no_cap=${no_cap}`

  try {
    const res = await fetch(url, { method: 'POST', body: text, headers })
    results[key] = await res.text()
    return results[key]
  } catch (ex) {
    console.log(ex)
    return ''
  }
}
