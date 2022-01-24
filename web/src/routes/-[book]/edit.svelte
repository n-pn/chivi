<script context="module">
  import { page } from '$app/stores'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ stuff }) {
    appbar.set({ left: [['Sửa nội dung']] })
    return { props: stuff }
  }
</script>

<script>
  import NvinfoForm from '$sects/Nvinfo/Form.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let nvinfo = $page.stuff.nvinfo || {}

  $: params = {
    author: nvinfo.author,
    btitle: nvinfo.zname,
    bcover: nvinfo.bcover,
    status: 0,
  }
</script>

<Vessel>
  <NvinfoForm {params} />
</Vessel>
