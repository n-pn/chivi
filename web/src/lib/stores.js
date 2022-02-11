import { writable } from 'svelte/store'
import { create_config_store } from '$utils/create_stores.js'

export const config = create_config_store('_pref', {
  wtheme: '',
  ftsize: 3,
  ftface: 1,
  textlh: 150,
  render: 0,
  showzh: false,
})

export const layers = {
  ...writable(['#svelte']),
  add: (l) => layers.update((x) => [l, ...x]),
  remove: (l) => layers.update((x) => x.filter((i) => i != l)),
  toggle: (active, l) => (active ? layers.add(l) : layers.remove(l)),
}

export * from './stores/cvdata_stores'
export * from './stores/global_stores'

export { form as dtopic_form } from './stores/dtopic_stores'
export { form as dtpost_form } from './stores/dtpost_stores'
