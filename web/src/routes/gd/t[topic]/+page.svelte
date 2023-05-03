<script lang="ts">
  import DtopicFull from '$gui/parts/dboard/DtopicFull.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dtopic, rplist } = data)

  $: gdroot = `dt:${dtopic.dt_id}`
  $: touser = dtopic.user_id
</script>

<svelte:head>
  <title>{dtopic.title} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicFull post={dtopic} fluid={true} />

<section>
  <h3>Bình luận chủ đề ({rplist.repls.length})</h3>
  <GdreplList {rplist} {gdroot} {touser} fluid={true} />
</section>

<style lang="scss">
  h3 {
    padding: 0.5rem 0;
  }
</style>
