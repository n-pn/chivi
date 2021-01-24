export async function get_chlist(fetch, bhash, opts) {
  const page = opts.page || 1
  let skip = (page - 1) * 30
  if (skip < 0) skip = 0

  let url = `/api/chseeds/${bhash}/${opts.source}?take=30&skip=${skip}`
  if (opts.order) url += `&order=${opts.order}`
  if (opts.mode) url += `&mode=${opts.mode}`

  try {
    const res = await fetch(url)
    const data = await res.json()
    if (res.ok) return data
    else throw data.msg
  } catch (err) {
    throw err.message
  }
}

export async function get_chinfo(fetch, bslug, sname, ch_idx, mode = 0) {
  const url = `/api/chinfos/${bslug}/${sname}/${ch_idx}`
  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const chinfo = await res.json()
  if (mode < 0) return [true, { chinfo, cvdata: '' }]

  const [ok, cvdata] = await get_chtext(fetch, chinfo, mode)
  return [ok, ok ? { chinfo, cvdata } : cvdata]
}

export async function get_chtext(fetch, chinfo, mode = 0) {
  const { sname, snvid, schid, bhash } = chinfo
  const url = `/api/chtexts/${sname}/${snvid}/${schid}?dname=${bhash}&mode=${mode}`

  const res = await fetch(url)
  if (!res.ok) return await wrap_error(res)

  const data = await res.text()
  return [true, data]
}

async function wrap_error(res) {
  return [false, { status: res.status, message: await res.text() }]
}

export async function dict_search(fetch, key, dname = 'various') {
  const url = `/api/dictdb/search/${key}?dname=${dname}`
  const res = await fetch(url)
  return await res.json()
}

export async function dict_upsert(fetch, dname, params) {
  const url = `/api/dictdb/upsert/${dname}`
  const res = await fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })

  return res
}

export async function dict_lookup(fetch, input, dname) {
  const url = `/api/dictdb/lookup/${dname}`
  const res = await fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ input: input }),
  })

  const data = await res.json()
  return data
}
