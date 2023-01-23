import type { PageLoad } from './$types'
import { suggest_read } from '$utils/ubmemo_utils'
import { book_path } from '$lib/kit_path'

export const load = (async ({ parent }) => {
  const { nvinfo, ubmemo } = await parent()

  const _meta: App.PageMeta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      {
        'text': nvinfo.btitle_vi,
        'icon': 'book',
        'href': book_path(nvinfo.id, nvinfo.btitle_vi).index,
        'data-kind': 'title',
      },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { _meta }
}) satisfies PageLoad
