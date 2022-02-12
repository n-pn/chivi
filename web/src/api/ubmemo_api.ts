import { call_api } from './_api_call'
import { kit_chap_url } from '$utils/route_utils'

export async function update_status(nvinfo_id: number, status: string) {
  const url = `_self/books/${nvinfo_id}/status`
  return await call_api(fetch, url, { status }, 'PUT')
}

export function last_read({ bslug }, ubmemo: any) {
  return {
    href: kit_chap_url(bslug, ubmemo),
    icon: ubmemo.locked ? 'player-skip-forward' : 'player-play',
    text: ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
    mute: ubmemo.chidx == 0,
  }
}
