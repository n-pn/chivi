import { writable } from 'svelte/store'

export const u_dname = writable('Khách')
export const u_power = writable(-1)

export const lookup_enabled = writable(false)
export const lookup_actived = writable(false)
export const lookup_sticked = writable(false)

export const lookup_input = writable(['', 0, 0])
export const lookup_dname = writable('various')
