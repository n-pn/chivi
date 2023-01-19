import { nvinfo_bar } from '$utils/topbar_utils'

type JsonLoad = { bintro: string; genres: string; bcover: string }

import type { PageLoad } from './$types'
export const load: PageLoad = async ({ parent, fetch }) => {
  const { nvinfo } = await parent()

  const api_url = `/_db/books/${nvinfo.bslug.substring(0, 8)}/+edit`
  const api_res = await fetch(api_url)

  const { bintro, genres, bcover }: JsonLoad = await api_res.json()

  const nvinfo_form = { ...nvinfo, bintro, genres, bcover }

  const _meta = {
    title: 'Sửa thông tin truyện ' + nvinfo.btitle_vi,
    left_nav: [
      nvinfo_bar(nvinfo, { 'data-show': 'tm' }),
      { text: 'Sửa thông tin', icon: 'pencil', href: './+info' },
    ],
  }

  return { nvinfo_form: nvinfo_form, _meta }
}
