export async function get_chinfo(fetch, bslug, seed, scid, mode = 1) {
  const url = `/api/chinfos/${bslug}/${seed}/${scid}`

  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const chinfo = await res.json()
  if (mode < 1) return [true, { chinfo, cvdata: '' }]

  const [ok, data] = await get_chtext(fetch, chinfo)
  return [ok, ok ? { chinfo, cvdata: data.cvdata } : data]
}

export async function get_chtext(fetch, chinfo, mode = 0) {
  const { seed, sbid, scid, bhash } = chinfo
  const url = `/api/chtexts/${seed}/${sbid}/${scid}?dict=${bhash}&mode=${mode}`

  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const data = await res.json()
  return [true, data]
}

async function wrap_error(res) {
  return [false, { status: res.status, message: await res.text() }]
}
