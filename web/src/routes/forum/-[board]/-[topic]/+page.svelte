<script lang="ts">
  import { CvpostFull, CvreplList } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ dboard, cvpost, tplist } = data)
</script>

<svelte:head>
  <title>{cvpost.title} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostFull {dboard} {cvpost} fluid={true} />

<cvpost-posts>
  <cvrepl-head>
    <h3>Bình luận</h3>
  </cvrepl-head>

  <CvreplList {tplist} {cvpost} fluid={true} />
</cvpost-posts>

<style lang="scss">
  cvpost-posts {
    display: block;
    max-width: 40rem;
    margin: 1.25rem auto 0;
    padding: 0 var(--gutter);

    @include bgcolor(secd);
    @include bdradi();
    @include shadow();

    @include tm-dark {
      @include linesd(--bd-main);
    }
  }

  cvrepl-head {
    display: block;
    padding: 0.5rem var(--gutter);
  }
</style>
