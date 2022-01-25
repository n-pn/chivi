<script context="module">
  import { page, session } from '$app/stores'

  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import { SIcon } from '$lib/components'

  import DtpostCard from './Card.svelte'

  import DtpostForm, { ctrl as dtpost_ctrl } from './Form.svelte'
</script>

<script>
  export let dtopic
  export let dtlist = {
    pgidx: 1,
    pgmax: 1,
    items: [],
  }

  $: pager = new Pager($page.url, { page: 1, tl: '' })
  let active_card = $page.url.hash.substring(1)
</script>

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
  <button
    class="m-btn _primary _fill"
    disabled={$session.privi < 0}
    on:click={() => dtpost_ctrl.show(0)}>
    <SIcon name="plus" />
    <span>Thêm bình luận</span>
  </button>

  {#if $dtpost_ctrl.actived}
    <DtpostForm {dtopic} />
  {/if}
</dtlist-foot>

<style lang="scss">
  dtlist-foot {
    @include flex-cx();
    padding-top: 0.75rem;
    margin-top: 0.75rem;
    @include border($loc: top);
  }

  .empty {
    @include flex-ca();
    height: 15rem;
    max-height: 40vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
