<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { dlabels } from '$lib/constants'

  import { dtlist_data, dboard_ctrl, get_user } from '$lib/stores'

  import DtopicCard from './DtopicCard.svelte'
  import DtopicForm, { ctrl as cvpost_form } from './DtopicForm.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist

  export let tlabel = $page.url.searchParams.get('lb')
  export let _mode = 0

  export let on_cvpost_form = () => window.location.reload()
  const _user = get_user()

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
  {#each Object.entries(dlabels) as [value, klass]}
    <a
      class="m-label _{klass}"
      href={pager.gen_url({ lb: value })}
      on:click={(e) => dboard_ctrl.view_board(e, dboard, value)}>
      <span>{value}</span>
      {#if tlabel == value}<SIcon name="check" /> {/if}
    </a>
  {/each}
</board-head>

<topic-list>
  {#each dtlist.posts as post}
    <DtopicCard
      {post}
      user={dtlist.users[post.user_id]}
      memo={dtlist.memos[post.id]}
      size="sm"
      {_mode} />
  {:else}
    <div class="empty">
      <h4>Chưa có chủ đề thảo luận :-(</h4>
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
    disabled={$_user.privi < 0}
    on:click={() => cvpost_form.show(0)}>
    <SIcon name="message-plus" />
    <span>Tạo chủ đề mới</span></button>
</board-foot>

{#if $cvpost_form.actived}
  <DtopicForm {dboard} on_destroy={on_cvpost_form} />
{/if}

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
