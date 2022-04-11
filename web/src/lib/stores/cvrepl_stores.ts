import { writable, get } from 'svelte/store'

export interface CvreplForm {
  input: string
  itype: string
  rp_id: number
}

function init(rp_id = 0, itype = 'md'): CvreplForm {
  return { input: '', itype, rp_id }
}

async function load(id: number, rp_id: number): Promise<CvreplForm> {
  if (id == 0) return init(rp_id)

  const api_url = `/api/tposts/${id}/detail`
  const api_res = await fetch(api_url)

  if (!api_res.ok) return init(rp_id)
  return await api_res.json()
}

export const form = {
  ...writable(init()),
  init: async (id = 0, rp_id = 0) => form.set(await load(id, rp_id)),
  // prettier-ignore
  validate(data: CvreplForm = get(form) ) {
    const { input } = data

    if (input.length < 1) return 'Độ dài của nội dung phải dài hơn 1 ký tự'
    if (input.length > 2000) return 'Độ dài của nội dung phải nhỏ hơn 2000 ký tự'

    // TODO
    return false
  },

  async submit(api_url: string) {
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
