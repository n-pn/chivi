<script lang="ts">
  import { CvpostFull, CvreplList } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, cvpost, rplist } = data)
</script>

<svelte:head>
  <title>{cvpost.title} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostFull {dboard} {cvpost} fluid={true} />

<section>
  <h3>Bình luận</h3>
  <CvreplList {rplist} {cvpost} fluid={true} />
</section>

<style lang="scss">
  h3 {
    padding: 0.5rem 0;
  }
  section {
    padding: 0 var(--gutter);
  }
</style>
