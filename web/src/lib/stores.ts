import { getContext } from 'svelte'
import { writable, type Writable } from 'svelte/store'

export const layers = {
  ...writable(['#svelte']),
  add: (l: string) => layers.update((x) => [l, ...x]),
  remove: (l: string) => layers.update((x) => x.filter((i) => i != l)),
  toggle: (a: boolean, l: string) => {
    if (a) layers.add(l)
    else layers.remove(l)
  },
}

export * from './stores/config_stores'
export * from './stores/cvdata_stores'
export * from './stores/global_stores'
export * from './stores/dboard_stores'

export const get_user = () => {
  return getContext<Writable<App.CurrentUser>>('_user')
}
