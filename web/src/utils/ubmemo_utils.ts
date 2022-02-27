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
