import { api_call } from '$lib/api_call'

type Params = Record<string, string>
export const post_form = async (url: string, params: Params) => {
  try {
    await api_call(url, params, 'POST')
    const back = sessionStorage.getItem('back') || window.location.origin
    return { error: '', back }
  } catch (ex) {
    console.log(ex)
    return { error: ex.body.message, back: '' }
  }
}
