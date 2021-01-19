export async function get_chinfo(fetch, b_slug, s_name, ch_idx, mode = 1) {
  const url = `/api/chinfos/${b_slug}/${s_name}/${ch_idx}`
  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const chinfo = await res.json()
  if (mode < 1) return [true, { chinfo, cvdata: '' }]

  const [ok, data] = await get_chtext(fetch, chinfo, mode)
  return [ok, ok ? { chinfo, cvdata: data.cvdata } : data]
}

export async function get_chtext(fetch, chinfo, mode = 0) {
  const { s_name, s_nvid, s_chid, b_hash } = chinfo
  const url = `/api/chtexts/${s_name}/${s_nvid}/${s_chid}?dname=${b_hash}&mode=${mode}`

  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const data = await res.json()
  return [true, data]
}

async function wrap_error(res) {
  return [false, { status: res.status, message: await res.text() }]
}
