import { writable } from 'svelte/store'

export const scroll = writable(0)
export const toleft = writable(false)

export const wtheme = writable('light')
export const ftsize = writable('md')

export const zh_text = writable('')
export const zh_from = writable(0)
export const zh_upto = writable(1)

export const layers = writable(['#svelte'])

export function add_layer(layer) {
  layers.update((x) => [layer, ...x])
}

export function remove_layer(layer) {
  layers.update((x) => x.filter((i) => i != layer))
}
