<script context="module">
  import { page, session } from '$app/stores'
  import { dlabels } from '$lib/constants'

  import DtopicCard from './Card.svelte'
  import DtopicForm, { ctrl as dtopic_form } from './Form.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
</script>

<script>
  import { SIcon } from '$lib/components'

  export let dboard
  export let dtlist = []
  export let _mode = 0

  $: pager = new Pager($page.url, { page: 1, label: '' })
  $: dlabel = pager.get('label')
</script>

<board-head>
  <span>Lọc nhãn:</span>
  <a href={pager.url.pathname} class="m-label _0">
    <span>Tất cả</span>
    {#if !dlabel}<SIcon name="check" /> {/if}
  </a>
  {#each Object.entries(dlabels) as [value, label]}
    <a class="m-label _{value}" href={pager.make_url({ label: value })}>
      <span>{label}</span>
      {#if dlabel == value}<SIcon name="check" /> {/if}
    </a>
  {/each}
</board-head>

<topic-list>
  {#each dtlist.items as dtopic}
    <DtopicCard {dtopic} {_mode} />
  {:else}
    <div class="empty">
      <h4>Chưa có chủ đề thảo luận :(</h4>
    </div>
  {/each}
</topic-list>

{#if dtlist.pgmax > 1}
  <board-pagi>
    <Mpager {pager} pgidx={dtlist.pgidx} pgmax={dtlist.pgmax} />
  </board-pagi>
{/if}

<board-foot>
  <button
    class="m-btn _primary _fill"
    disabled={$session.privi < 0}
    on:click={() => dtopic_form.show(0)}>
    <SIcon name="message-plus" />
    <span>Tạo chủ đề mới</span></button>
</board-foot>

{#if $dtopic_form.actived}<DtopicForm {dboard} />{/if}

<style lang="scss">
  board-head {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    margin: 0.75rem 0;
  }

  board-pagi {
    display: block;
    padding: 0.75rem 0;

    @include border($loc: bottom);
  }

  topic-list {
    display: block;
    @include border(--bd-main, $loc: top);
  }

  board-foot {
    @include flex-cx();
    margin: 0.75rem 0;
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
