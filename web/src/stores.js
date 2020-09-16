import { writable } from 'svelte/store'

export const self_uname = writable('Khách')
export const self_power = writable(-1)

// export const search_page = writable(false)
// export const search_term = writable('')

export const upsert_input = writable('')
export const upsert_lower = writable(0)
export const upsert_upper = writable(1)

export const upsert_atab = writable('special')
export const upsert_udic = writable('dich-nhanh')

export const upsert_actived = writable(false)
export const upsert_changed = writable(false)
