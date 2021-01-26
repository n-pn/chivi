async function api_call(fetch, url, key = url, ttl = 1, fresh = false) {
  const now = Math.round(new Date().getTime() / 60000)

  if (localStorage && !fresh) {
    const value = localStorage.getItem(key)
    if (value) {
      try {
        let cached = JSON.parse(value)
        if (cached[2] >= now) return cached
      } catch (err) {
        console.log({ value, err })
      }
    }
  }

  const res = await fetch(`/api/${url}`)
  let value = res.ok ? [0, await res.json()] : [res.status, await res.text()]

  if (localStorage) {
    value.push(now + ttl)
    localStorage.setItem(key, JSON.stringify(value))
  }

  return value
}

export async function get_self(fetch) {
  return await api_call(fetch, `_self`, `_self`, 10)
}

export async function get_nvinfo(fetch, bslug) {
  return await api_call(fetch, `nvinfos/${bslug}`, `nvinfo:${bslug}`, 1)
}

function nvmark_key(bslug, uname) {
  return `nvmark:${uname.toLowerCase()}-${bslug}`
}

export async function get_nvmark(fetch, bhash, uname, ttl = 1) {
  const key = nvmark_key(bhash, uname)
  return await api_call(fetch, `_self/nvmarks/${bhash}`, key, ttl)
}

export async function set_nvmark(fetch, bhash, nvmark, uname) {
  if (uname == 'Khách') return

  const url = `/api/book-marks/${bhash}?nvmark=${nvmark}`
  await fetch(url, { method: 'PUT' })

  if (localStorage) {
    const key = nvmark_key(bslug, uname)
    const val = [0, nvmark, new Date().getTime() + 1]
    localStorage.setItem(key, JSON.stringify(val))
  }
}

export async function get_chseed(fetch, { sname, snvid }, bhash, mode = 0) {
  let url = `chseeds/${sname}/${snvid}?bhash=${bhash}&mode=${mode}`
  return await api_call(fetch, url, `chseed:${sname}/${snvid}`, 3, mode > 0)
}

export async function get_chlist(fetch, { sname, snvid, page }) {
  let skip = (page - 1) * 30
  if (skip < 0) skip = 0

  let url = `chitems/${sname}/${snvid}?take=30&skip=${skip}`
  return await api_call(fetch, url, `chlist:${sname}/${snvid}/${page}`, 3)
}

export async function get_chinfo(fetch, bslug, sname, chidx, mode = 0) {
  const url = `/api/chinfos/${bslug}/${sname}/${chidx}`
  const res = await fetch(url)
  if (!res.ok) return [res.status, res.text()]

  const chinfo = await res.json()
  if (mode < 0) return [500, { chinfo, cvdata: '' }]

  const [err, data] = await get_chtext(fetch, chinfo, mode)
  return err ? [err, data] : [0, { chinfo, cvdata: data }]
}

export async function get_chtext(fetch, chinfo, mode = 0) {
  const { sname, snvid, schid, bhash } = chinfo
  const url = `/api/chtexts/${sname}/${snvid}/${schid}?dname=${bhash}&mode=${mode}`
  const res = await fetch(url)
  return [0, await res.text()]
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

  return await res.json()
}
