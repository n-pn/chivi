export async function dict_search(http, term, bdic) {
  const url = `/_search?term=${term}&bdic=${bdic}`
  const res = await http(url)

  const data = await res.json()
  return data
}

export async function dict_upsert(http, dic, key, val = '') {
  const url = `/_upsert?dic=${dic}`
  const res = await http(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ key, val }),
  })

  const data = await res.json()
  // console.log({ data })
  return data.status
}

export async function load_chtext(fetch, bslug, seed, scid, mode = 0) {
  const url = `/_load_text?slug=${bslug}&seed=${seed}&scid=${scid}&mode=${mode}`

  try {
    const res = await fetch(url)
    const data = await res.json()

    if (res.status == 200) return data
    else this.error(res.status, data.msg)
  } catch (err) {
    this.error(500, err.message)
  }
}
