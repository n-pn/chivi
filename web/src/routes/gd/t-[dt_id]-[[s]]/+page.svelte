<script lang="ts">
  import DtopicFull from '$gui/parts/dboard/DtopicFull.svelte'
  import RpnodeList from '$gui/parts/dboard/RpnodeList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, cvpost, rplist } = data)

  $: muhead = `gd:${cvpost.post.id}`
  $: touser = cvpost.post.user_id
</script>

<svelte:head>
  <title>{cvpost.post.title} - Diễn đàn - Chivi</title>
</svelte:head>

<DtopicFull
  post={cvpost.post}
  user={cvpost.user}
  memo={cvpost.memo}
  {dboard}
  fluid={true} />

<section>
  <h3>Bình luận</h3>
  <RpnodeList {rplist} {muhead} {touser} fluid={true} />
</section>

<style lang="scss">
  h3 {
    padding: 0.5rem 0;
  }
  section {
    padding: 0 var(--gutter);
  }
</style>
