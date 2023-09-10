import { writable } from 'svelte/store'

import { type Cdata, render_ztext } from '$lib/mt_data_2'

interface Data {
  cdata: Cdata
  ztext: string
  zfrom: number
  zupto: number
}

const init_data = {
  cdata: undefined,
  ztext: '',
  zfrom: 0,
  zupto: 0,
}

export const data = {
  ...writable<Data>(init_data),
  from_data(cdata: Cdata, ztext = '', zfrom = 0, zupto = ztext.length) {
    if (!ztext) ztext = render_ztext(cdata, 0)
    if (!zupto) zupto = ztext.length
    data.set({ cdata, ztext, zfrom, zupto })
  },
}

export const ctrl = {
  ...writable({ actived: false, tab: 0 }),
  show: (tab = 0) => ctrl.set({ actived: true, tab }),
  hide: () => ctrl.set({ actived: false, tab: 0 }),
}
