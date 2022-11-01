import { call_api } from '$lib/api_call'
import { chap_url } from './route_utils'

export async function update_status(nvinfo_id: number, status: string) {
  const url = `/api/_self/books/${nvinfo_id}/status`
  return await call_api(url, 'PUT', { status }, fetch)
}

export function last_read({ bslug }, ubmemo: CV.Ubmemo) {
  return {
    href: chap_url(bslug, ubmemo),
    icon: ubmemo.locked ? 'player-skip-forward' : 'player-play',
    text: ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    mute: ubmemo.chidx == 0,
  }
}

export function suggest_read(
  nvinfo: CV.Nvinfo,
  ubmemo: CV.Ubmemo
): App.HeadItem {
  const { text, icon, href, mute } = last_read(nvinfo, ubmemo)
  return { text, icon, href, 'data-show': 'tm', 'disable': mute ? true : null }
}

export function update_memo(
  ubmemo: CV.Ubmemo,
  { sname, cpart },
  { chidx, title, uslug },
  mode = 0
) {
  if (ubmemo.locked && mode == 0) return
  ubmemo.locked = mode == 2

  ubmemo.sname = sname
  ubmemo.cpart = cpart

  ubmemo.chidx = chidx
  ubmemo.title = title
  ubmemo.uslug = uslug

  return ubmemo
}
