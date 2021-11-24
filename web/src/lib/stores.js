import { writable } from 'svelte/store'
import {
  create_config_store,
  create_layers_store,
} from '$utils/create_stores.js'

export const config = create_config_store('_pref', {
  wtheme: '',
  ftsize: 3,
  ftface: 1,
  textlh: 160,
  reader: 0,
  showzh: false,
})

export const layers = create_layers_store(['#svelte'])
export const scroll = writable(0)
export const toleft = writable(false)

export const zh_text = writable('')
export const zh_from = writable(0)
export const zh_upto = writable(1)
