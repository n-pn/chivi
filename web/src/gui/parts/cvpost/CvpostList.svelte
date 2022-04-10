<script context="module" lang="ts">
  import { page, session } from '$app/stores'
  import { dlabels } from '$lib/constants'

  import { dtlist_data, dboard_ctrl } from '$lib/stores'

  import CvpostCard from './CvpostCard.svelte'
  import CvpostForm, { ctrl as cvpost_form } from './CvpostForm.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
</script>

<script lang="ts">
  import { SIcon } from '$gui'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist

  export let tlabel = $page.url.searchParams.get('tl')
  export let _mode = 0

  $: pager = new Pager($page.url, { pg: 1, tl: '' })

  function on_navigate(evt: Event, pgidx: number) {
    dboard_ctrl.stop_event(evt)
    dtlist_data.set_pgidx(pgidx)
  }
</script>

<board-head>
  <span>Lọc nhãn:</span>
  <a
    href={pager.url.pathname}
    class="m-label _0"
    on:click={(e) => dboard_ctrl.view_board(e, dboard, '')}>
    <span>Tất cả</span>
    {#if !tlabel}<SIcon name="check" /> {/if}
  </a>
  {#each dlabels as value, index}
    <a
      class="m-label _{index + 1}"
      href={pager.gen_url({ tl: value })}
      on:click={(e) => dboard_ctrl.view_board(e, dboard, value)}>
      <span>{value}</span>
      {#if tlabel == value}<SIcon name="check" /> {/if}
    </a>
  {/each}
</board-head>

<topic-list>
  {#each dtlist.items as cvpost}
    <CvpostCard size="sm" {cvpost} {_mode} />
  {:else}
    <div class="empty">
      <h4>Chưa có chủ đề thảo luận :(</h4>
    </div>
  {/each}
</topic-list>

{#if dtlist.pgmax > 1}
  <board-pagi>
    <Mpager {pager} pgidx={dtlist.pgidx} pgmax={dtlist.pgmax} {on_navigate} />
  </board-pagi>
{/if}

<board-foot>
  <button
    class="m-btn _primary _fill"
    disabled={$session.privi < 0}
    on:click={() => cvpost_form.show('0')}>
    <SIcon name="message-plus" />
    <span>Tạo chủ đề mới</span></button>
</board-foot>

{#if $cvpost_form.actived}<CvpostForm {dboard} />{/if}

<style lang="scss">
  board-head {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    margin-bottom: 0.75rem;
  }

  board-pagi {
    display: block;
    padding: 0.75rem 0;

    @include border($loc: bottom);
  }

  topic-list {
    display: block;

    > :global(* + *) {
      margin-top: 0.375rem;
    }
  }

  board-foot {
    @include flex-cx();
    margin-top: 0.75rem;
  }

  .empty {
    @include flex-ca();
    height: 20rem;
    max-height: 50vh;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);
  }
</style>
