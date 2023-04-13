<script lang="ts">
  import CvpostFull from '$gui/parts/dboard/CvpostFull.svelte'
  import MureplList from '$gui/parts/dboard/MureplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, cvpost, rplist } = data)

  $: thread = {
    to: cvpost.post.user_id,
    id: cvpost.post.id,
    mu: 0,
  }
</script>

<svelte:head>
  <title>{cvpost.title} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostFull
  post={cvpost.post}
  user={cvpost.user}
  memo={cvpost.memo}
  {dboard}
  fluid={true} />

<section>
  <h3>Bình luận</h3>
  <MureplList {rplist} {thread} fluid={true} />
</section>

<style lang="scss">
  h3 {
    padding: 0.5rem 0;
  }
  section {
    padding: 0 var(--gutter);
  }
</style>
