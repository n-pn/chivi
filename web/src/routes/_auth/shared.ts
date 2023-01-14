import { api_call } from '$lib/api_call'

type Params = Record<string, string>
export const post_form = async (url: string, params: Params) => {
  return await api_call(url, params, 'POST')
    .then((_) => '')
    .catch((ex) => {
      console.log(ex)
      return ex.body.message
    })
}

export const return_back = () => {
  const back = sessionStorage.getItem('back') || window.location.origin
  window.location.href = back
}
