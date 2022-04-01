<script context="module" lang="ts">
  import { page } from '$app/stores'

  import { tplist_data, dboard_ctrl } from '$lib/stores'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import DtpostCard from './DtpostCard.svelte'
  import DtpostForm from './DtpostForm.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Dtopic
  export let tplist: CV.Tplist

  $: pager = new Pager($page.url, { pg: 1, tl: '' })
  let active_card = $page.url.hash.substring(1)

  function on_navigate(evt: Event, pgidx: number) {
    dboard_ctrl.stop_event(evt)
    tplist_data.update((x) => {
      x.query.pg = pgidx
      return x
    })
  }
</script>

<cvrepl-list>
  {#each tplist.items as cvrepl}
    <DtpostCard {cvrepl} bind:active_card fluid={$$props.fluid} />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}

  {#if tplist.pgmax > 1}
    <cvrepl-pagi>
      <Mpager {pager} pgidx={tplist.pgidx} pgmax={tplist.pgmax} {on_navigate} />
    </cvrepl-pagi>
  {/if}

  <dtlist-foot>
    <DtpostForm cvpost_id={cvpost.id} />
  </dtlist-foot>
</cvrepl-list>

<style lang="scss">
  cvrepl-list {
    // margin-left: 0.75rem;
    display: block;
    padding-bottom: 0.75rem;
  }

  cvrepl-pagi {
    display: block;
    @include border($loc: top);

    // padding-bottom: 0.75rem;
    // @include border($loc: bottom);
  }

  dtlist-foot {
    display: block;

    @include border($loc: top);
  }

  .empty {
    @include flex-ca();
    height: 10rem;
    max-height: 30vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
