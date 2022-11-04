import { redirect } from '@sveltejs/kit'
import { get_nvbook } from '$lib/api'
import { suggest_read } from '$utils/ubmemo_utils'

export async function load({ params, url, fetch }) {
  const bslug = params.book

  try {
    const { nvinfo, ubmemo } = await get_nvbook(bslug, fetch)
    const _meta: App.PageMeta = {
      title: `${nvinfo.btitle_vi}`,
      left_nav: [
        // prettier-ignore
        { text: nvinfo.btitle_vi, icon: 'book', href: `/-${nvinfo.bslug}`, "data-show": 'tm', "data-kind": 'title' },
      ],
      right_nav: [suggest_read(nvinfo, ubmemo)],
    }

    return { nvinfo, ubmemo, _meta }
  } catch (error) {
    const location = error.location
    if (!location) throw error

    const decode = decodeURI(location)
    throw redirect(error.status, encodeURI(url.pathname.replace(bslug, decode)))
  }
}
