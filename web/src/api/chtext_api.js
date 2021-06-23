// import { api_call } from './_api_call'

export async function get_chinfo(fetch, bhash, chinfo, mode = 0) {
  const { zseed, snvid, chidx } = chinfo
  const url = `/api/texts/${bhash}/${zseed}/${snvid}/${chidx}?mode=${mode}`

  const res = await fetch(url)
  if (!res.ok) return [res.status, res.text()]

  const data = await res.json()
  chinfo = { ...chinfo, ...data }
  // if (mode < 1) return [0, { chinfo, cvdata: '' }]

  const [err, cvdata] = await get_chtext(fetch, bhash, chinfo, mode)
  return err ? [err, cvdata] : [0, { chinfo, cvdata }]
}

export async function get_chtext(fetch, bhash, chinfo, mode = 0) {
  const { zseed, snvid, chidx, schid } = chinfo
  const url = `/api/texts/${bhash}/${zseed}/${snvid}/${chidx}/${schid}?mode=${mode}`
  const res = await fetch(url)
  return [0, await res.text()]
}
