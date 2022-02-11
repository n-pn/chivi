import { writable, get } from 'svelte/store'
import { make_vdict } from '../utils/vpdict_utils'

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

export const vdict = {
  ...writable(make_vdict('combine')),
  put: (dname, d_dub, descs) => vdict.set(make_vdict(dname, d_dub, descs)),
}
