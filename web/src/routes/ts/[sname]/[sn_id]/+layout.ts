import { api_get } from '$lib/api_call'
import { writable } from 'svelte/store'
import type { LayoutLoad } from './$types'

interface LayoutData {
  crepo: CV.Chrepo
  rmemo: CV.Rdmemo
  xstem: CV.Upstem | CV.Wnstem | CV.Rmstem
}

export const load = (async ({ fetch, parent, params: { sname, sn_id } }) => {
  const api_url = `/_rd/chrepos/${sname}/${sn_id}`
  const { crepo, rmemo, xstem } = await api_get<LayoutData>(api_url, fetch)
  return { crepo, xstem, rmemo: writable(rmemo) }
}) satisfies LayoutLoad
