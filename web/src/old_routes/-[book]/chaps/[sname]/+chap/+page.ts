/** @type {import('./[slug]').PageLoad} */
throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, url }) {
  const { nvinfo, nvseed } = stuff

  stuff.topbar = gen_topbar(nvinfo)
  const chidx = +url.searchParams.get('chidx') || 1
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { nvinfo, nvseed, chidx }, stuff }
}

function gen_topbar({ btitle_vi, bslug }) {
  return {
    left: [
      [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
      ['Thêm/sửa chương', 'file-plus', { href: '.', show: 'pl' }],
    ],
  }
}

const split_modes = [
  'Phân thủ công bằng ///',
  'Phân bởi dòng trắng giữa chương',
  'Nội dung thụt vào so với tên chương',
  'Theo định dạng tên chương',
  'Theo regular expression tự nhập',
]

const numbers = '零〇一二两三四五六七八九十百千'

import { hash_str } from '$utils/text_utils'

function format_str(input: string) {
  return input.replace(/\r?\n|\r/g, '\n')
}

function build_split_regex(split_mode: number, opts: any) {
  switch (split_mode) {
    case 0:
      return /^\/{3,}/mu

    case 1:
      return new RegExp(`\\n{${opts.min_blanks + 1},}`, 'mu')

    case 2:
      const count = opts.need_blank ? 2 : 1
      return new RegExp(`\\n{${count},}[^\\s]`, 'mu')

    case 3:
      return new RegExp(`^\\s*第[\\d${numbers}]+[${opts.label}]`, 'mu')

    case 4:
      return new RegExp(opts.regex, 'mu')

    default:
      return /\\n{3,}/mu
  }
}
