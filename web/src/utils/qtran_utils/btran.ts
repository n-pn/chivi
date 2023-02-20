const tabs = [
  ['zh', 'vi'],
  ['zh', 'en'],
  ['ja', 'en'],
]

const headers = { 'content-type': 'text/plain' }
const results = {}

export async function btran(text: string, tab: number, no_cap = true) {
  const key = `${text}-${tab}`

  const val = results[key]
  if (val) return val

  const [sl, tl] = tabs[tab]
  const url = `/_sp/btran?sl=${sl}&tl=${tl}&no_cap=${no_cap}`

  try {
    const res = await fetch(url, { method: 'PUT', body: text, headers })
    results[key] = await res.text()
    return results[key]
  } catch (ex) {
    console.log(ex)
    return ''
  }
}
