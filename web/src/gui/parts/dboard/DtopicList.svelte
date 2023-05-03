<script lang="ts">
  import { page } from '$app/stores'
  import { dlabels } from '$lib/constants'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import DtopicCard from './DtopicCard.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist

  export let tlabel = $page.url.searchParams.get('lb')
  export let _mode = 0

  $: pager = new Pager($page.url, { pg: 1, tl: '' })
</script>

<board-head>
  <span>Lọc nhãn:</span>
  <a href={pager.url.pathname} class="m-label _0">
    <span>Tất cả</span>
    {#if !tlabel}<SIcon name="check" /> {/if}
  </a>
  {#each Object.entries(dlabels) as [value, klass]}
    <a class="m-label _{klass}" href={pager.gen_url({ lb: value })}>
      <span>{value}</span>
      {#if tlabel == value}<SIcon name="check" /> {/if}
    </a>
  {/each}
</board-head>

<topic-list>
  {#each dtlist.posts as post}
    <DtopicCard {post} size="sm" {_mode} />
  {:else}
    <div class="empty">
      <h4>Chưa có chủ đề thảo luận :-(</h4>
    </div>
  {/each}
</topic-list>

{#if dtlist.pgmax > 1}
  <footer>
    <Mpager {pager} pgidx={dtlist.pgidx} pgmax={dtlist.pgmax} />
  </footer>
{/if}

<board-foot>
  <a
    href="/gd/+topic?tb={dboard?.id || -1}"
    class="m-btn _primary _fill"
    class:_disable={$_user.privi < 0}>
    <SIcon name="message-plus" />
    <span>Tạo chủ đề mới</span>
  </a>
</board-foot>

<style lang="scss">
  board-head {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    margin-bottom: 0.75rem;
  }

  .footer {
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
    height: 30vh;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);
  }
</style>
