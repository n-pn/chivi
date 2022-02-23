<script context="module" lang="ts">
  import { page } from '$app/stores'

  import { dboard_ctrl } from '$lib/stores'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import DtpostCard from './DtpostCard.svelte'
  import DtpostForm from './DtpostForm.svelte'
</script>

<script lang="ts">
  export let dtopic: CV.Dtopic
  export let tplist: CV.Tplist

  $: pager = new Pager($page.url, { pg: 1, tl: '' })
  let active_card = $page.url.hash.substring(1)

  function on_navigate(evt: Event, pgidx: number) {
    dboard_ctrl.view(evt, (x) => {
      x.tab_1.pg = pgidx
      return x
    })
  }
</script>

<dtpost-list>
  <dtpost-head>
    <h3>Bình luận</h3>
  </dtpost-head>

  {#each tplist.items as dtpost}
    <DtpostCard {dtpost} bind:active_card />
  {:else}
    <div class="empty">Chưa có bình luận</div>
  {/each}

  {#if tplist.pgmax > 1}
    <dtpost-pagi>
      <Mpager {pager} pgidx={tplist.pgidx} pgmax={tplist.pgmax} {on_navigate} />
    </dtpost-pagi>
  {/if}

  <dtlist-foot>
    <DtpostForm dtopic_id={dtopic.id} />
  </dtlist-foot>
</dtpost-list>

<style lang="scss">
  dtpost-list {
    // margin-left: 0.75rem;
    display: block;
    padding: 0 var(--gutter) 0.75rem;
    max-width: 40rem;
    margin: 0 auto;

    @include bgcolor(secd);
    @include bdradi();
    @include shadow();

    @include tm-dark {
      @include linesd(--bd-main);
    }
  }

  dtpost-head {
    display: block;
    padding: 0.5rem 0;
  }

  dtpost-pagi {
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
