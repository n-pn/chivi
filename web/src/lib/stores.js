import { writable, get } from 'svelte/store'
import {
  create_config_store,
  create_layers_store,
} from '$utils/create_stores.js'

export const config = create_config_store('_pref', {
  wtheme: '',
  ftsize: 3,
  ftface: 1,
  textlh: 150,
  render: 0,
  showzh: false,
})

export const layers = create_layers_store(['#svelte'])
export const scroll = writable(0)
export const toleft = writable(false)

export * from './stores/cvdata_store'

export { form as dtopic_form } from './stores/dtopic_stores'
export { form as dtpost_form } from './stores/dtpost_stores'
export { appbar } from './stores/global_stores'
