import { writable, get } from 'svelte/store'

export interface CvpostForm {
  title: string
  labels: string
  body_input: string
  body_itype: string
}

function init(): CvpostForm {
  return {
    title: '',
    labels: 'Thảo luận',
    body_input: '',
    body_itype: 'md',
  }
}

async function load(id: number): Promise<CvpostForm> {
  if (id == 0) return init()

  try {
    return await fetch(`/_db/topics/${id}/detail`).then((r) => r.json())
  } catch (ex) {
    console.log(ex)
    return init()
  }
}

export const form = {
  ...writable(init()),
  init: async (id = 0) => form.set(await load(id)),
  validate(data: CvpostForm = get(form)) {
    const { title, body_input: body } = data

    if (title.length < 4) return 'Độ dài của chủ đề phải dài hơn 4 ký tự'
    if (title.length > 200) return 'Độ dài của chủ đề phải nhỏ hơn 200 ký tự'

    if (body.length < 1) return 'Độ dài của nội dung phải dài hơn 1 ký tự'
    if (body.length > 5000) return 'Độ dài của nội dung phải nhỏ hơn 5000 ký tự'

    // TODO
    return false
  },
  reset: () => form.set(init()),
  async submit(api_url: string) {
    const err = form.validate()
    if (err) return err

    const res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(get(form)),
    })

    return res.ok ? '' : (await res.json()).error
  },
}
