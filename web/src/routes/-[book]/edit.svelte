<script context="module" lang="ts">
  export async function load({ stuff, fetch }) {
    const { nvinfo } = stuff
    const api_url = `/api/books/${nvinfo.bslug.substr(0, 8)}/detail`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    Object.assign(nvinfo, payload)
    return { props: stuff }
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import { Crumb } from '$gui'

  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo

  $: book_href = `-${nvinfo.bslug}`

  $: topbar.set({
    left: [
      [nvinfo.btitle_vi, 'book', { href: book_href, show: 'tm' }],
      ['Sửa nội dung', 'pencil', { href: '.' }],
    ],
  })
</script>

<Crumb
  tree={[
    [nvinfo.btitle_vi, book_href],
    ['Sửa nội dung', '.'],
  ]} />

<NvinfoForm params={new Params(nvinfo)}>
  <h1 slot="header">Sửa nội dung truyện [{nvinfo.btitle_vi}]</h1>
</NvinfoForm>
