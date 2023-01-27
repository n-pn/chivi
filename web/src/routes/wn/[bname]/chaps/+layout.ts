import { api_get } from '$lib/api_call'

export interface SeedList {
  _main: CV.Chroot
  users: CV.Chroot[]
  backs: CV.Chroot[]
}

export async function load({ fetch, depends, params }) {
  depends('wn:seed_list')

  const wn_id = params.bname.split('-')[0]
  const path = `/_wn/seeds?wn_id=${wn_id}`

  const seeds: SeedList = await api_get(path, null, fetch)

  return { seeds }
}
