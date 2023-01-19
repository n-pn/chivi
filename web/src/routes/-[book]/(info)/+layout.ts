import type { PageLoad } from './$types'
import { suggest_read } from '$utils/ubmemo_utils'

export const load = (async ({ parent }) => {
  const { nvinfo, ubmemo } = await parent()

  const _meta: App.PageMeta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      // prettier-ignore
      { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-kind": 'title' },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { _meta }
}) satisfies PageLoad
