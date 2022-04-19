import { writable } from 'svelte/store'

export const layers = {
  ...writable(['#svelte']),
  add: (l: string) => layers.update((x) => [l, ...x]),
  remove: (l: string) => layers.update((x) => x.filter((i) => i != l)),
  toggle: (a: boolean, l: string) => (a ? layers.add(l) : layers.remove(l)),
}

export * from './stores/config_stores'
export * from './stores/cvdata_stores'
export * from './stores/global_stores'
export * from './stores/dboard_stores'

export { form as cvpost_form } from './stores/cvpost_stores'
export { form as cvrepl_form } from './stores/cvrepl_stores'

export const popups = {
  ...writable({
    appnav: false,
    usercp: false,
    config: false,
    dboard: false,
  }),
  show(popup: string) {
    popups.update((x) => ({ ...x, [popup]: true }))
  },
  hide(popup: string) {
    popups.update((x) => ({ ...x, [popup]: false }))
  },
}
