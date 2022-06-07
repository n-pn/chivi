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
  tosimp = false
  engine = 1
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

export const config = {
  ...writable(load_config()),
  put(key: string, val: any) {
    config.update((x: ConfigData) => ({ ...x, [key]: val }))
  },
  put_fn(key: string, fn: (x: any) => any) {
    config.update((x: ConfigData) => ({ ...x, [key]: fn(x[key]) }))
  },
  toggle: (key: string) => config.put_fn(key, (val) => !val),
  set_render: (val: number) => {
    config.update((x: ConfigData) => {
      return { ...x, render: val == x.render ? 0 : val }
    })
  },
  set_engine: (engine: number) => {
    config.update((x: ConfigData) => ({ ...x, engine }))
  },
}

config.subscribe((data: ConfigData) => save_config(data))

export const config_ctrl = dialog_store()
