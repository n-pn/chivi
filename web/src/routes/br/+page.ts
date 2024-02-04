import { load_vi_crits, load_ys_crits } from '$lib/fetch_data'

import type { PageLoad } from './$types'

export const load = (async ({ fetch }) => {
  return {
    vdata: await load_vi_crits('lm=5&sort=utime', fetch),
    ydata: await load_ys_crits('lm=5&sort=utime', fetch),
    ontab: '',
    _meta: { title: 'Đánh giá truyện chữ' },
  }
}) satisfies PageLoad
