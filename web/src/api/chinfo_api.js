import { api_call } from './_api_call'

export async function get_chseed(fetch, bhash, { zseed, snvid }, mode = 0) {
  const url = `chaps/${bhash}/${zseed}/${snvid}?mode=${mode}`
  const opts = { key: `chseed:${zseed}/${snvid}`, ttl: 2, fresh: mode > 0 }
  return await api_call(fetch, url, opts)
}

export async function get_chlist(fetch, bhash, { zseed, snvid, page }) {
  const url = `chaps/${bhash}/${zseed}/${snvid}/${page}`
  return await api_call(fetch, url)
}
