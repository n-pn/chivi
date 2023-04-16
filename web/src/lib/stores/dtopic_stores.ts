import { api_get } from '$lib/api_call'
import { writable, get } from 'svelte/store'

export interface DtopicForm {
  labels: string
  title: string
  btext: string
}

function init(): DtopicForm {
  return {
    labels: 'Thảo luận',
    title: '',
    btext: '',
  }
}

async function load(id: number): Promise<DtopicForm> {
  if (id == 0) return init()

  try {
    return await api_get<CV.DtopicForm>(`/_db/topics/edit/${id}`)
  } catch (ex) {
    console.log(ex)
    return init()
  }
}

export const form = {
  ...writable(init()),
  init: async (id = 0) => form.set(await load(id)),
  validate(data: DtopicForm = get(form)) {
    const { title, btext } = data

    if (title.length < 4) return 'Độ dài của chủ đề phải dài hơn 4 ký tự'
    if (title.length > 200) return 'Độ dài của chủ đề phải nhỏ hơn 200 ký tự'

    if (btext.length < 4) return 'Độ dài của nội dung phải dài hơn 4 ký tự'

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
