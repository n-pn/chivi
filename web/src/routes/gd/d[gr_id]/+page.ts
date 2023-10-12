import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

type Data = { gdroot: CV.Gdroot; rplist: CV.Rplist }

export const load: PageLoad = async ({ fetch, params }) => {
  const { gr_id } = params

  const rppath = `/_db/droots/show/id:${parseInt(gr_id, 10)}?lm=9999`
  const { gdroot, rplist } = await api_get<Data>(rppath, fetch)

  const { title } = gdroot

  const _meta = {
    left_nav: [
      nav_link('/gd', 'Diễn đàn', 'messages'),
      nav_link(`/gd/d${gr_id}`, title, null, { kind: 'title' }),
    ],
  }

  return { gdroot, rplist, _meta, _title: `${title} -  Diễn đàn` }
}
