import { writable, get } from 'svelte/store'

function init() {
  return {
    input: '',
    itype: 'md',
  }
}

async function load(id) {
  if (id == 0) return init(id)

  const api_url = `/api/tposts/${id}`
  const api_res = await fetch(api_url)

  if (api_res.ok) return await api_res.json()
  else return init()
}

export const form = {
  ...writable(init()),
  init: async (id = 0) => form.set(await load(id)),
  // prettier-ignore
  validate(data = get(form)) {
    const { input } = data

    if (input.length < 1) return 'Độ dài của nội dung phải dài hơn 1 ký tự'
    if (input.length > 2000) return 'Độ dài của nội dung phải nhỏ hơn 2000 ký tự'

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
