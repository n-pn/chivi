import { writable, get } from 'svelte/store'

import {
  call_btran_file,
  call_hviet_file,
  call_qtran_file,
  call_mtran_file,
} from '$utils/tran_util'

export interface Data {
  pdict: string
  fpath: string
  ftype: string

  ztext: Array<string>
  hviet: Array<Array<[string, string]>>

  btran: Array<string>
  qtran: Array<string>
  c_gpt: Array<string>

  ctree: Array<CV.Cvtree>
  m_alg: string
}

const init_data = {
  pdict: 'combine',
  fpath: '',
  ftype: 'nc',

  hviet: [],
  ztext: [],
  btran: [],
  qtran: [],
  ctree: [],
  c_gpt: [],

  m_alg: 'avail',
}

export const data = {
  ...writable<Data>(init_data),
  async put(new_data: Partial<Data> = {}) {
    const old_data = get(data)
    if (old_data.fpath == new_data.fpath) {
      data.set({ ...old_data, ...new_data })
    } else {
      data.set({ ...init_data, ...new_data })
    }
  },

  async load_data(rinit: RequestInit = { cache: 'default' }) {
    const zdata = get(data)

    const { fpath, ftype, pdict, m_alg } = zdata
    const finit = { fpath, ftype, pdict, m_alg, force: false }

    if (zdata.hviet.length == 0) {
      const hviet = await call_hviet_file(finit, rinit)
      zdata.hviet = hviet.hviet || []
    }

    if (zdata.btran.length == 0) {
      const btran = await call_btran_file(finit, rinit)
      zdata.btran = btran.lines || []
    }

    if (zdata.qtran.length == 0) {
      const qtran = await call_qtran_file(finit, rinit)
      zdata.qtran = qtran.lines || []
    }

    if (zdata.ctree.length == 0) {
      const mtran = await call_mtran_file(finit, rinit)
      zdata.ctree = mtran.lines || []
    }

    data.set(zdata)
  },
}

export const ctrl = {
  ...writable({ actived: false, enabled: true, fpath: '' }),
  hide: (enabled = true) => {
    ctrl.update(({ fpath }) => ({ actived: false, enabled, fpath }))
  },
  async show(forced = true) {
    const zpage = get(data)
    let { enabled, actived, fpath } = get(ctrl)

    if (actived || forced) {
      if (fpath != zpage.fpath) data.load_data()
      ctrl.set({ enabled, fpath: zpage.fpath, actived: true })
    }
  },
}
