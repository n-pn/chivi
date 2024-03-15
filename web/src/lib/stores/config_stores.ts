import { writable } from 'svelte/store'
import { browser } from '$app/environment'
import type { Cookies } from '@sveltejs/kit'

// const parse_cookie = (cookie: string) => {
//   const cookies = new Map<string, string>()

//   for (const entry of cookie.split(';')) {
//     const [key, val] = entry.trim().split('=')
//     cookies.set(decodeURIComponent(key), decodeURIComponent(val))
//   }

//   return cookies
// }

interface ConfigData {
  wtheme: string // global theme
  wfface: number // global font face

  rfface: number // reader font face
  rfsize: number // reader font size
  textlh: number // reader line height

  r_mode: number
  show_z: boolean

  _regen: number
  _auto_: boolean
}

export const read_confg = (cookies?: Cookies | Map<string, string>): ConfigData => {
  cookies ||= new Map<string, string>()

  return {
    wtheme: cookies.get('wtheme') || 'light',
    wfface: +cookies.get('wfface') || 1,

    rfsize: +cookies.get('rfsize') || 4,
    rfface: +cookies.get('rfface') || 1,
    textlh: +cookies.get('textlh') || 150,

    r_mode: +cookies.get('r_mode') || 0,
    show_z: cookies.get('show_z') == 't',
    _regen: +cookies.get('_regen') || 0,

    _auto_: cookies.get('_auto_') != 'f',
  }
}

const write_cookie = (key: string, value: string) => {
  document.cookie = `${key}=${value}; max-age=31536000; path=/; SameSite=Lax`
}

function save_config(data: ConfigData) {
  write_cookie('wtheme', data.wtheme)
  write_cookie('wfface', `${data.wfface}`)

  write_cookie('rfsize', `${data.rfsize}`)
  write_cookie('rfface', `${data.rfface}`)
  write_cookie('textlh', `${data.textlh}`)

  write_cookie('r_mode', `${data.r_mode}`)
  write_cookie('show_z', data.show_z ? 't' : 'f')

  write_cookie('_auto_', data._auto_ ? 't' : 'f')
  write_cookie('_regen', data._regen.toString())
}

export const config = {
  ...writable(read_confg()),
  put(key: string, val: any) {
    config.update((x: ConfigData) => ({ ...x, [key]: val }))
  },
  put_fn(key: string, fn: (x: any) => any) {
    config.update((x: ConfigData) => ({ ...x, [key]: fn(x[key]) }))
  },
  toggle: (key: string) => config.put_fn(key, (val) => !val),
  set_r_mode: (val: number) => {
    config.update((x: ConfigData) => {
      return { ...x, r_mode: val == x.r_mode ? 0 : val }
    })
  },
}

if (browser) {
  config.subscribe((data: ConfigData) => save_config(data))
}
