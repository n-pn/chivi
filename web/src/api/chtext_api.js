// import { api_call } from './_api_call'

export async function get_chinfo(fetch, chinfo, { bhash }, mode = 0) {
  const { sname, snvid, chidx } = chinfo
  const url = `/api/chinfos/${sname}/${snvid}/${chidx}`

  const res = await fetch(url)
  if (!res.ok) return [res.status, res.text()]

  const data = await res.json()
  chinfo = { ...chinfo, ...data }
  if (mode < 0) return [500, { chinfo, cvdata: '' }]

  const [err, cvdata] = await get_chtext(fetch, chinfo, bhash, mode)
  return err ? [err, cvdata] : [0, { chinfo, cvdata }]
}

export async function get_chtext(fetch, chinfo, bhash, mode = 0) {
  const { sname, snvid, schid } = chinfo
  const url = `/api/chtexts/${sname}/${snvid}/${schid}?dname=${bhash}&mode=${mode}`
  const res = await fetch(url)
  return [0, await res.text()]
}
