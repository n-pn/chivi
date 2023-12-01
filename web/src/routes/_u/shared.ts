import { api_call } from '$lib/api_call'

type Params = Record<string, string>
export const post_form = async (url: string, params: Params) => {
  try {
    await api_call(url, params, 'POST')
    return
  } catch (ex) {
    console.log(ex)
    return ex.body?.message || 'Không rõ lỗi!'
  }
}

export const return_back = () => {
  const back = sessionStorage.getItem('back') || window.location.origin
  window.location.href = back
}
