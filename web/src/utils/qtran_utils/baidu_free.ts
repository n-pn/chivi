import { detitlize } from './qtran_util'
import { send_vcache } from './shared'

const api =
  'https://fetch.nipin.workers.dev?q=https://fanyi.baidu.com/ait/text/translate'

export async function call_baidu(text: string, tl = 'vie') {
  const init = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query: text,
      from: 'zh',
      to: tl,
      reference: '',
      corpusIds: [],
      qcSettings: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'],
      domain: 'common',
    }),
  }
  const res = await fetch(api, init)
  const data = await res.text().then((x) => x.split('\n'))

  const json = extract_tran(data)
  const tran = json.data.list.map(({ dst }) => dst)

  send_vcache(`baidu-${tran.length > 1 ? 'chap' : 'line'}`, { tl, text, tran })
  return tran
}

function extract_tran(data: string[]) {
  for (let i = 0; i < data.length; i++) {
    if (
      data[i].includes('event: message') &&
      data[i + 1].includes('event":"Translating"')
    ) {
      // Extract the JSON data associated with the "Translating" event
      return JSON.parse(data[i + 1].replace('data: ', ''))
    }
  }

  return []
}

const cached = new Map<string, string[]>()

export async function baidu_word(text: string, tl = 'vi', keep_caps = false) {
  const key = `${text}-${tl}`
  let res = cached.get(key)

  if (!res) {
    res = await call_baidu(text, tl)
    if (res.length > 0) cached.set(key, res)
  }

  const res2 = res.map((x: string) => detitlize(x))
  if (!keep_caps) res = res2
  else res = res.concat(res2)

  return [...new Set(res)]
}
