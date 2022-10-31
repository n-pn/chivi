import { page, session } from '$lib/stores'
import { invalidate } from '$app/navigation'

import { make_vdict } from '$utils/vpdict_utils'

import Lookup, { ctrl as lookup } from '$gui/parts/Lookup.svelte'
import Upsert, { ctrl as upsert } from '$gui/parts/Upsert.svelte'
import pt_labels from '$lib/consts/postag_labels.json'

import Postag from '$gui/parts/Postag.svelte'

throw new Error(
  '@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)'
)
export async function load({ fetch, url, params: { dict } }) {
  const api_url = `/api/dicts/${dict}${url.search}`
  const api_res = await fetch(api_url)

  const payload = await api_res.json()
  const { d_dub, d_tip } = make_vdict(dict, payload.props.d_dub)

  payload.props.d_dub = d_dub
  payload.props.d_tip = d_tip
  payload.props.query = Object.fromEntries(url.searchParams)

  const topbar = {
    left: [
      ['Từ điển', 'package', { href: '/dicts', show: 'ts' }],
      [d_dub, null, { href: url.pathname, kind: 'title' }],
    ],
    right: [['Dịch nhanh', 'bolt', { href: `/qtran?dname=${dict}` }]],
  }

  payload.stuff = { topbar }

  throw new Error(
    '@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)'
  )
  return payload
}
