<script lang="ts">
  import { page } from '$app/stores'

  import Footer from '$gui/sects/Footer.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import TsrepoCard from './TsrepoCard.svelte'

  export let repos: CV.Tsrepo[] = []
  export let memos: Record<number, CV.Rdmemo> = {}

  export let pgidx: number
  export let pgmax: number

  $: pager = new Pager($page.url)
</script>

<div class="list">
  {#each repos as crepo (crepo)}
    <TsrepoCard {crepo} rmemo={memos[crepo.id]} />
  {:else}
    <div class="d-empty">Danh sách trống</div>
  {/each}
</div>

<Footer>
  <div class="pagi">
    <Mpager {pager} {pgidx} {pgmax} />
  </div>
</Footer>

<style lang="scss">
  .pagi {
    @include flex($center: horz, $gap: 0.375rem);
  }
  .list {
    margin: 1rem 0;
    display: grid;
    grid-gap: 0.5rem;

    grid-template-columns: repeat(3, 1fr);

    @include bp-min(pl) {
      grid-template-columns: repeat(4, 1fr);
    }

    @include bp-min(tm) {
      grid-template-columns: repeat(5, 1fr);
    }

    @include bp-min(ls) {
      grid-template-columns: repeat(6, 1fr);
    }
  }
</style>
