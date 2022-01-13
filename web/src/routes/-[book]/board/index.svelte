<script context="module">
  import { dlabels } from '$lib/constants'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { nvinfo } = stuff

    const page = +searchParams.get('page') || 1
    const dlbl = searchParams.get('label')

    const api_url = `/api/boards/${nvinfo.id}/topics?page=${page}&take=${15}`
    const api_res = await fetch(dlbl ? `${api_url}&dlabel=${dlbl}` : api_url)

    if (api_res.ok) return { props: { content: await api_res.json() } }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

<script>
  import { page, session } from '$app/stores'
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  // export let dboard
  export let content = { items: [], pgidx: 1, pgmax: 1 }

  $: nvinfo = $page.stuff.nvinfo
  $: pager = new Pager($page.url, { page: 1, tl: '' })

  const _navi = { replace: true, scrollto: '#board' }
</script>

{#if $session.privi > 2}
  <board-content id="board">
    {#each content.items as topic}
      <topic-card>
        <topic-body>
          <a
            class="topic-title"
            href="/-{nvinfo.bslug}/board/-{topic.uslug}-{topic.id}">
            {topic.title}
          </a>

          {#each topic.labels as label}
            <a class="topic-label _{label}" href="./board?tl={label}"
              >{dlabels[label]}</a>
          {/each}
        </topic-body>

        <topic-foot>
          <topic-user>{topic.u_dname}</topic-user>
          <topic-sep>·</topic-sep>
          <topic-time>{get_rtime(topic.ctime || 1212121200)}</topic-time>
          <topic-sep>·</topic-sep>
          <topic-repl>
            {#if topic.posts > 0}
              <span>{topic.posts} lượt trả lời</span>
            {:else}
              <span>Trả lời</span>
            {/if}
          </topic-repl>
        </topic-foot>
      </topic-card>
    {:else}
      <div class="empty">
        <div>
          <h4>Chưa có chủ đề thảo luận :(</h4>

          <p>
            <a
              class="m-btn _primary _fill"
              href="/-{nvinfo.bslug}/board/+topic">
              <SIcon name="message-plus" />
              <span>Tạo chủ đề mới</span></a>
          </p>
        </div>
      </div>
    {/each}

    {#if content.total > 10}
      <board-pagi>
        <Mpager {pager} pgidx={content.pgidx} pgmax={content.pgmax} {_navi} />
      </board-pagi>
    {/if}
  </board-content>
{:else}
  <div class="empty">Chức năng đang hoàn thiện :(</div>
{/if}

<style lang="scss">
  board-content {
    display: block;
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  board-pagi {
    display: block;
    margin-top: 0.75rem;
  }

  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);

    h4 {
      margin-bottom: 1rem;
    }
  }

  topic-card {
    display: block;

    @include border(--bd-main, $loc: bottom);
    &:first-of-type {
      @include border(--bd-main, $loc: top);
    }

    > * {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  topic-foot {
    @include flex($gap: 0.25rem);
    line-height: 2rem;
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-user {
    font-weight: 200;
    // @include ftsize(md);
  }

  topic-body {
    display: block;
    padding-top: 0.5rem;

    @include bps(font-size, rem(16px), rem(17px));

    cursor: pointer;
    &:hover .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  .topic-title {
    @include ftsize(lg);
    @include fgcolor(secd);
    word-wrap: break-word;

    font-weight: 500;
    line-height: 1.5rem;
  }

  .topic-label {
    display: inline-block;
    line-height: 1.5rem;
    padding: 0 0.375rem;

    font-weight: 500;
    cursor: pointer;

    @include bdradi(0.375rem);
    @include ftsize(sm);

    color: var(--color, #{color(primary, 5)});
    box-shadow: 0 0 0 1px var(--color, #{color(primary, 5)}) inset;

    &:hover,
    &:active,
    &._active {
      background: var(--bgcolor, #{color(primary, 2)});
    }

    &._2 {
      --color: #{color(success, 5)};
      --bgcolor: #{color(success, 2)};
    }

    &._3 {
      --color: #{color(harmful, 5)};
      --bgcolor: #{color(harmful, 1)};
    }

    &._4 {
      --color: #{color(warning, 5)};
      --bgcolor: #{color(warning, 1)};
    }

    &._5 {
      --color: #{color(purple, 5)};
      --bgcolor: #{color(purple, 1)};
    }

    topic-body & + & {
      margin-left: 0.25rem;
    }
  }

  topic-repl {
    font-style: italic;
    cursor: pointer;
    @include hover {
      @include fgcolor(primary, 5);
      text-decoration: underline;
    }
  }
</style>
