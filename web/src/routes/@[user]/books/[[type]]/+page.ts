import { nav_link } from '$gui/global/header_util'
import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ url, params, fetch }) => {
  const { user: uname, type: bmark = 'reading' } = params
  const extras = { lm: 24, order: 'update', uname: uname, bmark }

  const path = api_path('wnovels.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta = {
    title: `Tủ truyện của @${uname}`,
    left_nav: [
      nav_link(`/@${uname}`, uname, 'user', { show: 'md' }),
      { text: 'Tủ truyện', icon: 'notebook', href: url.pathname },
    ],
  }

  return { ...data, uname: uname, bmark, _meta }
}) satisfies PageLoad
