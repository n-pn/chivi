<script context="module" lang="ts">
  import { page } from '$app/stores'

  import { tplist_data, dboard_ctrl } from '$lib/stores'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import CvreplCard from './CvreplCard.svelte'
  import CvreplForm from './CvreplForm.svelte'
</script>

<script lang="ts">
  export let cvpost: CV.Cvpost
  export let tplist: CV.Tplist

  export let on_cvrepl_form = (dirty = false) => {
    if (dirty) window.location.reload()
  }

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
    <CvreplCard {cvrepl} bind:active_card fluid={$$props.fluid} />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}

  {#if tplist.pgmax > 1}
    <cvrepl-pagi>
      <Mpager {pager} pgidx={tplist.pgidx} pgmax={tplist.pgmax} {on_navigate} />
    </cvrepl-pagi>
  {/if}

  <dtlist-foot>
    <CvreplForm cvpost_id={cvpost.id} on_destroy={on_cvrepl_form} />
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
