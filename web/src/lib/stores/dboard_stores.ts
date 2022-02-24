import { writable, get } from 'svelte/store'

export class DtlistData {
  show = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
  book?: CV.Dboard

  tab: CV.DtlistType = ''
  query = { pg: 1, tl: '', kw: '', op: '' }
}

export const dtlist_data = {
  ...writable(new DtlistData()),
  set_board(board: CV.Dboard | null, tl = '', pg = 1) {
    dtlist_data.update((x) => {
      x.query = { tl, pg, kw: '', op: '' }
      if (!board) return x

      if (board.id == x.book?.id) {
        x.tab = 'book'
      } else {
        x.tab = 'show'
        x.show = board
      }

      return x
    })
  },
  set_pgidx(pgidx = 1) {
    dtlist_data.update((x) => {
      x.query.pg = pgidx
      return x
    })
  },
  set_label(label = '') {
    dtlist_data.update((x) => {
      x.query.tl = label
      return x
    })
  },
}

export class TplistData {
  _t = 0
  t0?: CV.Dtopic
  query = { pg: 1, tl: '', kw: '', op: '' }
}

export class DboardData {
  actived = false
  tab = 0
  topic = new TplistData()
}

export const dboard_ctrl = {
  ...writable(new DboardData()),
  show: () => dboard_ctrl.update((x) => ({ ...x, actived: true })),
  hide: () => dboard_ctrl.update((x) => ({ ...x, actived: false })),
  change_tab: (tab: number) => dboard_ctrl.update((x) => ({ ...x, tab })),
  stop_event(evt: Event) {
    const actived = get(dboard_ctrl).actived
    if (actived) evt.preventDefault()
  },
  view_board(evt: Event, board: CV.Dboard | null, tl = '', pg = 1) {
    dboard_ctrl.stop_event(evt)
    dtlist_data.set_board(board, tl, pg)
  },
  view_topic(evt: Event, topic: CV.Dtopic) {
    dboard_ctrl.stop_event(evt)
    dboard_ctrl.update((x) => {
      x.tab = 1
      x.topic._t = 0
      x.topic.t0 = topic
      return x
    })
  },
}
