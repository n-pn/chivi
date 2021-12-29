<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ page: { params, query }, fetch, stuff }) {
    const { nvinfo, ubmemo, chseed } = stuff
    const sname = extract_sname(chseed, params.seed)

    const url = `chaps/${nvinfo.id}/${sname}?page=${+query.get('page') || 1}`
    const [status, chinfo] = await api_call(fetch, url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > nvinfo.mftime) nvinfo.mftime = chinfo.utime
    return { props: { nvinfo, ubmemo, chseed, chinfo } }
  }

  function extract_sname(chseed, sname) {
    switch (sname) {
      case 'chivi':
      case 'users':
        return sname

      default:
        const snames = chseed?.map((x) => x.sname) || []
        return snames.includes(sname) ? sname : snames[0]
    }
  }
</script>

<script>
  import ChapPage from '../_layout/ChapPage.svelte'

  export let nvinfo
  export let ubmemo
  export let chinfo
  export let chseed
</script>

<ChapPage {nvinfo} {ubmemo} {chseed} {chinfo} />
