import { writable } from 'svelte/store'

export const self_uname = writable('Khách')
export const self_power = writable(-1)

// export const search_page = writable(false)
// export const search_term = writable('')

export const upsert_input = writable('')
export const upsert_lower = writable(0)
export const upsert_upper = writable(1)

export const upsert_d_idx = writable(0)
export const upsert_dicts = writable([
  ['dich-nhanh', 'Dịch nhanh', true],
  ['generic', 'Thông dụng'],
  ['hanviet', 'Hán việt'],
])

export const upsert_actived = writable(false)
export const upsert_changed = writable(false)

// export const cv_input = writable('')
// export const cv_lower = writable(0)
// export const cv_upper = writable(1)
