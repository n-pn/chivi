import { api_call } from '$lib/api_call'
import { chap_url } from './route_utils'

export async function update_status(nvinfo_id: number, status: string) {
  const url = `_self/books/${nvinfo_id}/status`
  return await api_call(fetch, url, { status }, 'PUT')
}

export function last_read({ bslug }, ubmemo: CV.Ubmemo) {
  return {
    href: chap_url(bslug, ubmemo),
    icon: ubmemo.locked ? 'player-skip-forward' : 'player-play',
    text: ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    mute: ubmemo.chidx == 0,
  }
}

export function update_ubmemo(
  ubmemo: CV.Ubmemo,
  chmeta: CV.Chmeta,
  chinfo: CV.Chinfo,
  lock_mode = 0
) {
  if (ubmemo.locked && lock_mode == 0) return
  ubmemo.locked = lock_mode == 1

  ubmemo.sname = chmeta.sname
  ubmemo.cpart = chmeta.cpart

  ubmemo.chidx = chinfo.chidx
  ubmemo.title = chinfo.title
  ubmemo.uslug = chinfo.uslug

  return ubmemo
}
