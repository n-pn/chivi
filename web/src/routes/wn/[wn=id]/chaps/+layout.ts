import { api_get } from '$lib/api_call'

export interface SeedList {
  _main: CV.Chroot
  users: CV.Chroot[]
  backs: CV.Chroot[]
}

export async function load({ fetch, depends, params }) {
  const path = `/_wn/seeds?wn_id=${parseInt(params.wn, 10)}`

  const seed_list = await api_get<SeedList>(path, fetch)

  depends('wn:seed_list')
  return { seed_list }
}
