import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

type Data = { gdroot: CV.Gdroot; rplist: CV.Rplist }

export const load: PageLoad = async ({ fetch, params: { user } }) => {
  const rppath = `/_db/droots/show/vu:${user}?lm=9999`
  const { gdroot, rplist } = await api_get<Data>(rppath, fetch)

  const _meta = {
    left_nav: [
      home_nav('tm'),
      nav_link(`/@${user}`, `@${user}`, null, { kind: 'title' }),
    ],
  }

  return { gdroot, rplist, _meta, _title: `@${user} -  Diễn đàn` }
}
