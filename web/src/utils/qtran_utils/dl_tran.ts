const word_cached = new Map<string, string>()

export async function deepl_word(text: string, tab = 0) {
  const url = tab == 0 ? `/_sp/qtran/dl_ze` : `/_sp/qtran/dl_je`
  const key = `${text}-${tab}`

  const cached = word_cached.get(key)
  if (cached) return cached

  const res = await fetch(url, { method: 'POST', body: text })
  const data = await res.text()

  if (res.ok) word_cached.set(key, data)
  return data
}
