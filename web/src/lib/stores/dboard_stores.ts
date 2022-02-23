import { writable } from 'svelte/store'

export class DtlistData {
  _t = 0
  b0 = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
  pg = 1
  tl = ''
  kw = ''
}

export class TplistData {
  _t = 0
  t0?: CV.Dtopic
  pg = 1
  op = ''
}

export class DboardData {
  actived = false
  tab = 0

  tab_0 = new DtlistData()
  tab_1 = new TplistData()
}

function patch(store: DboardData, key: string, val: any) {
  store[key] = val
  return store
}

export const dboard_ctrl = {
  ...writable(new DboardData()),
  show: () => dboard_ctrl.update((x) => patch(x, 'actived', true)),
  hide: () => dboard_ctrl.update((x) => patch(x, 'actived', false)),
  change_tab: (tab: number) => dboard_ctrl.update((x) => ({ ...x, tab })),
  view(evt: Event, fn: (x: DboardData) => DboardData) {
    dboard_ctrl.update((x) => {
      if (x.actived) evt.preventDefault()
      return fn(x)
    })
  },
  set_tlabel(evt: Event, tl: string) {
    dboard_ctrl.view(evt, (x) => {
      x.tab = 0
      x.tab_0.tl = tl
      return x
    })
  },
  view_board(evt: Event, dboard: CV.Dboard, tlabel = '', pgidx = 1) {
    dboard_ctrl.view(evt, (x) => {
      x.tab_0._t = 0
      x.tab_0.b0 = dboard
      x.tab_0.tl = tlabel
      x.tab_0.pg = pgidx
      return x
    })
  },
  view_topic(evt: Event, topic: CV.Dtopic) {
    dboard_ctrl.view(evt, (x) => {
      x.tab = 1
      x.tab_1._t = 0
      x.tab_1.t0 = topic
      return x
    })
  },
}
