import { writable, get } from 'svelte/store'

import { get_wntext_btran, get_wntext_hviet } from '$utils/tran_util'

import { type Ctree, render_ztext } from '$lib/mt_data_2'

export const ctrl = {
  ...writable({ actived: false, enabled: true }),
  hide: (enabled = true) => ctrl.set({ enabled, actived: false }),
  show(forced = true) {
    const { enabled, actived } = get(ctrl)
    if (actived || forced || enabled) ctrl.set({ enabled, actived: true })
  },
}

// const headers = { 'Content-Type': 'application/json' }

export async function get_hviet(zpath: string, l_idx: number, force = false) {
  const { cdata } = await get_wntext_hviet(zpath, force)
  return cdata[l_idx]
}

export async function get_btran(zpath: string, l_idx: number, force = false) {
  const { cdata } = await get_wntext_btran(zpath, force)
  return cdata[l_idx]
}

export interface Data {
  zpath: string
  pdict: string

  l_idx: number
  l_max: number

  ztext: string
  btran: string

  cdata: Ctree
  hviet: Ctree
}

const init_data = {
  zpath: '',
  pdict: '',
  l_idx: -1,
  l_max: 0,
  ztext: '',
  btran: '',
  cdata: undefined,
  hviet: undefined,
}

export const data = {
  ...writable<Data>(init_data),
  async from_cdata(lines: Array<Ctree>, l_idx: number, zpath = '', pdict = '') {
    const l_max = lines.length
    if (l_idx >= l_max) l_idx = l_max - 1

    const cdata = lines[l_idx]
    const ztext = render_ztext(cdata, 0)

    const hviet = await get_hviet(zpath, l_idx)
    const btran = await get_btran(zpath, l_idx)

    data.set({ zpath, pdict, l_idx, l_max, ztext, btran, cdata, hviet })
  },

  move_up() {
    const l_idx = get(data).l_idx - 1
    if (l_idx >= 0) data.update((x) => ({ ...x, l_idx }))
  },

  move_down() {
    const l_idx = get(data).l_idx + 1
    if (l_idx < get(data).l_max) data.update((x) => ({ ...x, l_idx }))
  },
}
