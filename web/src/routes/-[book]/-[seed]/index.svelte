<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params, query }, fetch, stuff }) {
    const { cvbook, ubmemo } = stuff

    const sname = extract_sname(cvbook.snames, params.seed)

    const url = `chaps/${cvbook.id}/${sname}?page=${+query.get('page') || 1}`
    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > cvbook.mftime) cvbook.mftime = chinfo.utime
    return { props: { cvbook, ubmemo, chinfo } }
  }

  function extract_sname(snames, sname) {
    switch (sname) {
      case 'chivi':
      case 'users':
        return sname

      default:
        return snames.includes(sname) ? sname : snames[0]
    }
  }
</script>

<script>
  import ChapPage from '../_layout/ChapPage.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo
</script>

<ChapPage {cvbook} {ubmemo} {chinfo} />
