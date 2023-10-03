import { writable, get } from 'svelte/store'

import {
  call_bt_zv_file,
  call_hviet_file,
  call_qt_v1_file,
  call_mt_ai_file,
} from '$utils/tran_util'

export interface Data {
  zpage: CV.Mtpage

  ztext: Array<string>
  hviet: Array<Array<[string, string]>>

  bt_zv: Array<string>
  qt_v1: Array<string>
  c_gpt: Array<string>

  mt_ai: Array<CV.Cvtree>
  m_alg: string
}

const init_data = {
  zpage: { fpath: '', pdict: 'combine', wn_id: 0 },

  ztext: [],
  hviet: [],

  bt_zv: [],
  qt_v1: [],

  mt_ai: [],
  m_alg: 'avail',

  c_gpt: [],
}

export const data = {
  ...writable<Data>(init_data),
  async put(new_data: Partial<Data>) {
    const old_data = get(data)
    let old_page = old_data.zpage || { fpath: '' }
    let new_page = new_data.zpage || { fpath: '' }

    if (old_page.fpath == new_page.fpath) {
      data.set({ ...old_data, ...new_data })
    } else {
      data.set({ ...init_data, ...new_data })
    }
  },

  async load_data(rinit: RequestInit = { cache: 'default' }) {
    const zdata = get(data)

    const { zpage, m_alg } = zdata
    const finit = { ...zpage, m_alg, force: false }

    if (zdata.hviet.length == 0) {
      const hviet = await call_hviet_file(finit, rinit)
      zdata.hviet = hviet.hviet || []
    }

    if (zdata.bt_zv.length == 0) {
      const bt_zv = await call_bt_zv_file(finit, rinit)
      zdata.bt_zv = bt_zv.lines || []
    }

    if (zdata.qt_v1.length == 0) {
      const qt_v1 = await call_qt_v1_file(finit, rinit)
      zdata.qt_v1 = qt_v1.lines || []
    }

    if (zdata.mt_ai.length == 0) {
      const mt_ai = await call_mt_ai_file(finit, rinit)
      zdata.mt_ai = mt_ai.lines || []
    }

    data.set(zdata)
  },

  async reload_mdata() {
    const zdata = get(data)

    const rinit = { cache: 'force-cache' } as RequestInit
    const finit = { ...zdata.zpage, m_alg: zdata.m_alg, force: true }

    const mt_ai = await call_mt_ai_file(finit, rinit)
    zdata.mt_ai = mt_ai.lines || []

    data.put(zdata)
  },
}

export const ctrl = {
  ...writable({ actived: false, panel: 'overview', fpath: '' }),
  hide: () => {
    ctrl.update((x) => ({ ...x, actived: false }))
  },
  async show(panel: string = '') {
    const zpage = get(data)

    let { fpath, panel: old_panel } = get(ctrl)
    if (fpath != zpage.zpage.fpath) data.load_data()

    panel ||= old_panel
    ctrl.set({ panel, fpath: zpage.zpage.fpath, actived: true })
  },
}
