import { writable } from 'svelte/store'
import { dialog_store } from '$utils/store_utils'

const storage_key = '_pref'

class ConfigData {
  wtheme = ''
  ftsize = 3
  ftface = 1
  textlh = 150
  render = 0
  showzh = false
}

function load_config(): ConfigData {
  if (globalThis.localStorage) {
    const stored = localStorage.getItem(storage_key)
    if (stored) return JSON.parse(stored)
  }
  return new ConfigData()
}

function save_config(data: ConfigData) {
  if (globalThis.localStorage) {
    localStorage.setItem(storage_key, JSON.stringify(data))
  }
}

export const config_data = {
  ...writable(load_config()),
  put(key: string, val: any) {
    config_data.update((x: ConfigData) => ({ ...x, [key]: val }))
  },
  put_fn(key: string, fn: (x: any) => any) {
    config_data.update((x: ConfigData) => ({ ...x, [key]: fn(x[key]) }))
  },
  toggle: (key: string) => config_data.put_fn(key, (val) => !val),
  set_render: (val: number) => {
    config_data.update((x: ConfigData) => {
      return { ...x, render: val == x.render ? 0 : val }
    })
  },
}

config_data.subscribe((data: ConfigData) => save_config(data))

export const config_ctrl = dialog_store()
