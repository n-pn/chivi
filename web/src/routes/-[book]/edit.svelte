<script context="module">
  import { page } from '$app/stores'
</script>

<script>
  import Nvinfo from '$sects/Nvinfo.svelte'
  import { data as appbar } from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  $: nvinfo = $page.stuff.nvinfo

  $: params = {
    author: nvinfo.author,
    btitle: nvinfo.zname,
    bcover: nvinfo.bcover,
    status: 0,
  }
  $: appbar.set({ left: [['Sửa nội dung']] })
</script>

<Vessel>
  <Nvinfo {params} />
</Vessel>
