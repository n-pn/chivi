import { writable, get } from 'svelte/store'

export interface RpnodeForm {
  input: string
  repl_id: number
}

function init(repl_id = 0): RpnodeForm {
  return { input: '', repl_id }
}

async function load(id: number, repl_id: number): Promise<RpnodeForm> {
  if (id == 0) return init(repl_id)

  const api_url = `/_db/mrepls/edit/${id}`
  const api_res = await fetch(api_url)

  if (!api_res.ok) return init(repl_id)
  return await api_res.json()
}

export const form = {
  ...writable(init()),
  init: async (id = 0, repl_id = 0) => form.set(await load(id, repl_id)),
  // prettier-ignore
  validate(data: RpnodeForm = get(form) ) {
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
