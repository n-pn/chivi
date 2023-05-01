<script lang="ts">
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ gdroot, rplist } = data)
</script>

<svelte:head>
  <title>{gdroot.title} - Diễn đàn - Chivi</title>
</svelte:head>

<h1>{gdroot.title}</h1>

<a class="fg-link" href={gdroot.olink}>Liên kết tới gốc</a>

<section>
  <h3>Bình luận chủ đề ({rplist.repls.length})</h3>
  <RpnodeList
    {rplist}
    gdroot="id:{gdroot.id}"
    touser={gdroot.user_id}
    fluid={true} />
</section>

<style lang="scss">
  h3 {
    padding: 0.5rem 0;
  }
</style>
