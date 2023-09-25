import { writable, get } from 'svelte/store'

import {
  get_nctext_btran,
  get_nctext_hviet,
  get_nctext_qtran,
  get_nctext_mtran,
} from '$utils/tran_util'

export interface Data {
  zpath: string
  pdict: string

  ztext: Array<string>
  hviet: Array<Array<[string, string]>>
  btran: Array<string>
  qtran: Array<string>

  ctree: Array<CV.Cvtree>
  m_alg: string
}

const init_data = {
  pdict: '',
  zpath: '',

  hviet: [],
  ztext: [],
  btran: [],
  qtran: [],
  ctree: [],
  m_alg: 'avail',
}

export const data = {
  ...writable<Data>(init_data),
  async put(zpath: string, pdict: string, opts: Partial<Data> = {}) {
    const zdata = get(data)
    if (zdata.zpath == zpath) opts = { ...zdata, ...opts }

    data.set({
      pdict,
      zpath,
      ztext: opts.ztext || [],
      hviet: opts.hviet || [],
      btran: opts.btran || [],
      qtran: opts.qtran || [],
      ctree: opts.ctree || [],
      m_alg: opts.m_alg || 'avail',
    })
  },
}

async function fill_data(page: Data) {
  const { zpath, m_alg } = page

  if (page.hviet.length == 0) {
    const hviet = await get_nctext_hviet(zpath, false, 'force-cache')
    page.hviet = hviet.hviet || []
  }

  if (page.btran.length == 0) {
    const btran = await get_nctext_btran(zpath, false, 'force-cache')
    page.btran = btran.lines || []
  }

  if (page.qtran.length == 0) {
    const qtran = await get_nctext_qtran(zpath, 'reload')
    page.qtran = qtran.lines || []
  }

  if (page.ctree.length == 0) {
    const mtran = await get_nctext_mtran(zpath, false, m_alg, 'force-cache')
    page.ctree = mtran.lines || []
  }

  return page
}

export const ctrl = {
  ...writable({ actived: false, enabled: true, zpath: '' }),
  hide: (enabled = true) => {
    ctrl.update(({ zpath }) => ({ actived: false, enabled, zpath }))
  },
  async show(forced = true) {
    const zpage = get(data)
    let { enabled, actived, zpath } = get(ctrl)

    if (zpage.zpath != zpath) {
      zpath = zpage.zpath
      data.set(await fill_data(zpage))
    }

    if (forced || actived || enabled) {
      ctrl.set({ enabled, zpath, actived: true })
    }
  },
}
