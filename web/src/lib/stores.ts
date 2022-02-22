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

export { form as dtopic_form } from './stores/dtopic_stores'
export { form as dtpost_form } from './stores/dtpost_stores'
