<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params, query }, fetch, context }) {
    const { cvbook, ubmemo } = context

    const { snames } = cvbook
    const sname = extract_sname(snames, params.seed)

    const page = +query.get('page') || 1
    const mode = +query.get('mode') || 0

    const url = `chaps/${cvbook.id}/${sname}?page=${page}&mode=${mode}`

    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > cvbook.mftime) cvbook.mftime = chinfo.utime
    return { props: { cvbook, ubmemo, chinfo } }
  }

  function extract_sname(snames, param) {
    return snames.includes(param) ? param : snames[1] || 'chivi'
  }
</script>

<script>
  import ChapPage from '../_layout/ChapPage.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo
</script>

<ChapPage {cvbook} {ubmemo} {chinfo} />
