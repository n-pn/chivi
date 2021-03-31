import { api_call } from './_api_call'

export async function get_chseed(fetch, bhash, { sname, snvid }, mode = 0) {
  let url = `chseeds/${bhash}/${sname}/${snvid}?mode=${mode}`
  const opts = { key: `chseed:${sname}/${snvid}`, ttl: 2, fresh: mode > 0 }
  return await api_call(fetch, url, opts)
}

export async function get_chlist(fetch, bhash, { sname, snvid, page }) {
  let skip = (page - 1) * 30
  if (skip < 0) skip = 0

  let url = `chitems/${bhash}/${sname}/${snvid}?take=30&skip=${skip}`
  return await api_call(fetch, url, `chlist:${sname}/${snvid}/${page}`, 2)
}
