import { api_get } from '$lib/api_call'

export interface SeedList {
  _main: CV.Chroot
  users: CV.Chroot[]
  backs: CV.Chroot[]
}

export async function load({ fetch, depends, params }) {
  depends('wn:seed_list')

  const path = `/_wn/seeds?wn_id=${params.wn_id}`
  const seed_list = await api_get<SeedList>(path, fetch)

  return { seed_list }
}
