<script context="module">
  import { page } from '$app/stores'
</script>

<script>
  import Nvinfo from '$sects/Nvinfo.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  $: nvinfo = $page.stuff.nvinfo

  $: params = {
    author: nvinfo.author,
    btitle: nvinfo.zname,
    bcover: nvinfo.bcover,
    status: 0,
  }
</script>

<Appbar>
  <svelte:fragment slot="left">
    <div class="header-item">
      <span class="header-text">Thêm/sửa sách</span>
    </div>
  </svelte:fragment>
</Appbar>

<Vessel>
  <Nvinfo {params} />
</Vessel>
