import { get } from 'svelte/store'
import { config } from '$lib/stores'

// prettier-ignore
export function gen_api_url( { id: book }, sname: string, chidx: number, cpart = 0, redo = false ) {
  let api_url = `/api/chaps/${book}/${sname}/${chidx}/${cpart}?redo=${redo}`

  const { tosimp, w_temp } = get(config)
  if (tosimp) api_url += '&trad=t'
  if (w_temp) api_url += '&temp=t'

  return api_url
}

export function gen_retran_url(rl_key: string, uname: string, reload = false) {
  // const base = $config.engine == 2 ? '/_v2/qtran/chaps' : '/api/qtran/chaps'

  const api_url = `/api/qtran/chaps/${rl_key}`
  const params = new URLSearchParams()

  const { tosimp, w_temp } = get(config)
  if (tosimp) params.set('trad', 'true')
  if (w_temp) params.set('temp', 'true')
  params.set('user', uname)

  if (reload) {
    params.set('_raw', 'true')
    params.set('_new', 'true')
  }

  return api_url + '?' + params.toString()
}
