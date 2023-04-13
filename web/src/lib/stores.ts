import { writable, derived } from 'svelte/store'
import { page } from '$app/stores'

export const layers = {
  ...writable(['#svelte']),
  add: (l: string) => layers.update((x) => [l, ...x]),
  remove: (l: string) => layers.update((x) => x.filter((i) => i != l)),
  toggle: (a: boolean, l: string) => (a ? layers.add(l) : layers.remove(l)),
}

export const session = derived(page, ($page) => $page.data._user)

export * from './stores/config_stores'
export * from './stores/cvdata_stores'
export * from './stores/global_stores'
export * from './stores/dboard_stores'

export { form as cvpost_form } from './stores/cvpost_stores'
export { form as murepl_form } from './stores/murepl_stores'
