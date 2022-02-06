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

export const zfrom = {
  ...writable(0),
  at_min: () => get(zfrom) == 0,
  at_max: () => get(zfrom) + 1 >= get(ztext).length,
  shift(value) {
    zfrom.update((x) => {
      const v = x + value
      if (v < 0 || v >= get(ztext).length) return x
      if (v >= get(zupto)) zupto.set(v + 1)
      return v
    })
  },
}

export const zupto = {
  ...writable(0),
  at_min: () => get(zupto) == 1,
  at_max: () => get(zupto) == get(ztext).length,
  shift(value) {
    zfrom.update((x) => {
      const v = x + value

      if (value < 0) {
        // shift left
        if (v < 1) return x
      } else {
        // shift right
        if (v > get(ztext).length) return x
        if (v >= get(zfrom)) zfrom.set(v - 1)
      }

      return v
    })
  },
}

export const ztext = {
  ...writable(''),
  put(input, lower = 0, upper = input.length) {
    if (get(ztext) == input) return

    ztext.set(input)
    zfrom.set(lower)
    zupto.set(upper)
  },
  shrink(index) {
    zfrom.set(index)
    zupto.set(index + 1)
  },
}

export const vdict = writable({
  dname: 'combine',
  d_dub: 'Tổng hợp',
  scope: '',
})

export { form as dtopic_form } from './stores/dtopic_stores'
export { form as dtpost_form } from './stores/dtpost_stores'
export { appbar } from './stores/global_stores'
