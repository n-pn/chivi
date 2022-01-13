<script context="module">
  import { api_call } from '$api/_api_call'

  export async function load({ params, url, fetch, stuff }) {
    const { nvinfo, chseed } = stuff
    const sname = extract_sname(chseed, params.seed)

    const page = url.searchParams.get('page') || 1
    const api_url = `chaps/${nvinfo.id}/${sname}?page=${page}`
    const [status, chinfo] = await api_call(fetch, api_url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > nvinfo.mftime) nvinfo.mftime = chinfo.utime
    return { props: { chinfo } }
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
  export let chinfo
</script>

<ChapPage {chinfo} />
