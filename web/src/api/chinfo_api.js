import { call_api } from './_api_call'

export async function get_chseed(fetch, bhash, { sname, snvid }, mode = 0) {
  const url = `chaps/${bhash}/${sname}/${snvid}?mode=${mode}`
  // const opts = { key: `chseed:${sname}/${snvid}`, ttl: 2, fresh: mode > 0 }
  return await call_api(fetch, url, null, 'GET')
}

export async function get_chlist(fetch, bhash, { sname, snvid, page }) {
  const url = `chaps/${bhash}/${sname}/${snvid}/${page}`
  return await call_api(fetch, url, null, 'GET')
}
