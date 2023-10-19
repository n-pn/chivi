import { writable, get } from 'svelte/store'

import {
  call_bt_zv_text,
  call_hviet_file,
  call_qt_v1_file,
  call_mt_ai_file,
} from '$utils/tran_util'

export interface Data {
  ropts: CV.Rdopts

  ztext: string[]
  hviet: string[][]

  bt_zv: string[]
  qt_v1: string[]
  c_gpt: string[]
  mt_ai: CV.Cvtree[]

  vtran: Record<string, string>
}

export const init_opts = {
  fpath: '',
  pdict: 'combine',
  wn_id: 0,
  rmode: 'qt',
  qt_rm: 'qt_v1',
  mt_rm: 'mtl_1',
}

const init_data = {
  ropts: init_opts,

  ztext: [],
  hviet: [],

  bt_zv: [],
  qt_v1: [],
  c_gpt: [],
  mt_ai: [],

  vtran: {},
}

export const data = {
  ...writable<Data>(init_data),
  async put(new_data: Partial<Data>) {
    const old_data = get(data)

    let old_opts = old_data.ropts || init_opts
    let new_opts = new_data.ropts || init_opts

    if (old_opts.fpath == new_opts.fpath) {
      data.set({ ...old_data, ...new_data })
    } else {
      data.set({ ...init_data, ...new_data })
    }
  },

  async reload_data(rinit: RequestInit = { cache: 'default' }) {
    const zdata = get(data)

    const { ropts } = zdata
    const finit = { ...ropts, force: false }

    if (zdata.hviet.length == 0) {
      const hviet = await call_hviet_file(finit, rinit)
      console.log({ hviet })
      zdata.hviet = hviet || []
    }

    if (zdata.bt_zv.length == 0) {
      const bt_zv = await call_bt_zv_text(zdata.ztext, finit, rinit)
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

  async reload_mt_ai() {
    const zdata = get(data)

    const rinit = { cache: 'no-cache' } as RequestInit
    const finit = { ...zdata.ropts, force: true }

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
    const ropts = get(data)

    let { fpath, panel: old_panel } = get(ctrl)
    if (fpath != ropts.ropts.fpath) data.reload_data()

    panel ||= old_panel
    ctrl.set({ panel, fpath: ropts.ropts.fpath, actived: true })
  },
}
