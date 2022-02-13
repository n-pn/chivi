<script context="module" lang="ts">
  import { page } from '$app/stores'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import DtpostCard from './DtpostCard.svelte'
  import DtpostForm from './DtpostForm.svelte'
</script>

<script lang="ts">
  export let dtopic: CV.Dtopic
  export let dtlist: CV.Dtlist

  $: pager = new Pager($page.url, { pg: 1, tl: '' })
  let active_card = $page.url.hash.substring(1)
</script>

<h3>Bình luận</h3>

<dtpost-list>
  {#each dtlist.items as dtpost}
    <DtpostCard {dtpost} bind:active_card />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}
</dtpost-list>

{#if dtlist.pgmax > 1}
  <dtpost-pagi>
    <Mpager {pager} pgidx={dtlist.pgidx} pgmax={dtlist.pgmax} />
  </dtpost-pagi>
{/if}

<dtlist-foot>
  <DtpostForm dtopic_id={dtopic.id} />
</dtlist-foot>

<style lang="scss">
  dtpost-list {
    margin-left: 0.75rem;
    display: block;
    margin-bottom: 0.75rem;
  }

  dtpost-pagi {
    display: block;
    // padding-bottom: 0.75rem;
    // @include border($loc: bottom);
  }

  dtlist-foot {
    @include flex();
    margin: 0.75rem;
  }

  .empty {
    @include flex-ca();
    height: 10rem;
    max-height: 30vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
