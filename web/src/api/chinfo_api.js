import { api_call } from './_api_call'

export async function get_chseed(fetch, { sname, snvid }, bhash, mode = 0) {
  let url = `chseeds/${sname}/${snvid}?bhash=${bhash}&mode=${mode}`
  const opts = { key: `chseed:${sname}/${snvid}`, ttl: 3, fresh: mode > 0 }
  return await api_call(fetch, url, opts)
}

export async function get_chlist(fetch, { sname, snvid, page }) {
  let skip = (page - 1) * 30
  if (skip < 0) skip = 0

  let url = `chitems/${sname}/${snvid}?take=30&skip=${skip}`
  return await api_call(fetch, url, `chlist:${sname}/${snvid}/${page}`, 3)
}
