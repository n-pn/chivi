import { api_call } from './_api_call'

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
