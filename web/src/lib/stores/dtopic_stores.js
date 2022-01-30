import { writable, get } from 'svelte/store'

function init() {
  return {
    title: '',
    labels: '1',
    body_input: '',
    body_itype: 'md',
  }
}

async function load(id) {
  if (id == 0) return init(id)

  const api_url = `/api/topics/${id}/detail`
  const api_res = await fetch(api_url)

  if (api_res.ok) return await api_res.json()
  else return init()
}

export const form = {
  ...writable(init()),
  init: async (id = 0) => form.set(await load(id)),
  validate(data = get(form)) {
    const { title, body_input: body } = data

    if (title.length < 4) return 'Độ dài của chủ đề phải dài hơn 4 ký tự'
    if (title.length > 200) return 'Độ dài của chủ đề phải nhỏ hơn 200 ký tự'

    if (body.length < 1) return 'Độ dài của nội dung phải dài hơn 1 ký tự'
    if (body.length > 5000) return 'Độ dài của nội dung phải nhỏ hơn 5000 ký tự'

    // TODO
    return false
  },

  async submit(api_url) {
    const err = form.validate()
    if (err) return err

    const res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(get(form)),
    })

    return res.ok ? '' : await res.text()
  },
}
