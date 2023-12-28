import { Rdline } from '$lib/reader'
import { writable } from 'svelte/store'

export interface Data {
  rline: Rdline

  pdict: string
  mt_rm: string
  wn_id: number
}

const init_data = {
  rline: new Rdline(''),
  pdict: 'combine',
  mt_rm: 'mtl_1',
  wn_id: 0,
}

export const data = writable<Data>(init_data)

export const ctrl = {
  ...writable({ actived: false, panel: 'overview' }),
  hide: () => {
    ctrl.update((x) => ({ ...x, actived: false }))
  },
  async show(new_panel: string = '') {
    ctrl.update(({ panel }) => ({ actived: true, panel: new_panel || panel }))
  },
}
