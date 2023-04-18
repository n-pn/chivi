<script lang="ts">
  import { get_user } from '$lib/stores'
  import { dboard_ctrl } from '$lib/stores'

  import { dlabels } from '$lib/constants'
  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let post: CV.Dtopic
  export let user: CV.Viuser
  export let memo: CV.Memoir = { liked: 0, track: 0, tagged: 0, viewed: 0 }
  export let _mode = 0

  const _user = get_user()
  $: dboard = post.dboard
  $: board_url = `/gd/b-${dboard.bslug}`

  async function toggle_like() {
    const action = memo?.liked > 0 ? 'unlike' : 'like'
    const api_url = `/_db/memos/posts/${post.id}/${action}`
    const api_res = await fetch(api_url, { method: 'PUT' })

    if (!api_res.ok) {
      alert(await api_res.text())
    } else {
      const { like_count, memo_liked } = await api_res.json()
      post.like_count = like_count
      memo.liked = memo_liked
    }
  }
</script>

<topic-card class:sm={$$props.size == 'sm'}>
  <topic-head>
    <a
      class="topic-title"
      href="/gd/t-{post.id}-{post.tslug}"
      on:click={(e) => dboard_ctrl.view_topic(e, post)}>
      {post.title}
    </a>

    {#each post.labels as label}
      <a
        class="m-label _{dlabels[label]} _sm"
        href="/gd?lb={label}"
        on:click={(e) => dboard_ctrl.view_board(e, dboard, label)}>{label}</a>
    {/each}
  </topic-head>

  <topic-brief>
    <span><SIcon name="send" /></span>
    <cv-user data-privi={user.privi}>{user.uname}</cv-user>
    <span>·</span>
    <topic-time>{rel_time(post.ctime)}</topic-time>
    <topic-sep>·</topic-sep>
    <span class="brief">{post.brief}</span>
  </topic-brief>

  <topic-foot>
    {#if _mode > 0}
      <a
        class="m-board"
        href={board_url}
        on:click={(e) => dboard_ctrl.view_board(e, dboard)}>
        <SIcon name="message" />
        <span>{dboard.bname}</span>
      </a>
    {/if}

    <foot-right>
      <topic-meta class="meta">
        <SIcon name="eye" />
        <span>{post.view_count}</span>
      </topic-meta>

      <topic-meta class="meta">
        <SIcon name="messages" />
        <span>{post.post_count}</span>
      </topic-meta>

      <button
        class="meta"
        class:_active={memo?.liked > 0}
        disabled={$_user.privi < 0}
        on:click={toggle_like}>
        <SIcon name="star" />
        <span>{post.like_count}</span>
      </button>
    </foot-right>
  </topic-foot>
</topic-card>

<style lang="scss">
  topic-card {
    display: block;
    @include padding-x(0.75rem);
    @include bdradi;
    @include border(--bd-main);
  }

  topic-head {
    @include flex-cy($gap: 0.25rem);
    flex-wrap: wrap;

    padding-top: 0.5rem;
    line-height: 1.5rem;

    topic-card.sm & {
      @include ftsize(md);
      // padding-top: 0.375rem;
      // padding-bottom: 0.25rem;
      line-height: 1.375rem;
    }
  }

  .topic-title {
    font-weight: 500;

    @include fgcolor(secd);
    @include ftsize(lg);

    topic-card:hover & {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    @include clamp($lines: 2);
    line-height: 1.25rem;
    padding: 0.25rem 0;
    word-wrap: break-word;

    topic-card.sm & {
      @include ftsize(sm);
    }
  }

  .brief {
    font-style: italic;
    @include fgcolor(secd);
  }

  topic-foot {
    @include flex-cy($gap: 0.25rem);
    // line-height: 2rem;

    line-height: 1.375rem;
    padding-bottom: 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .m-board {
    @include clamp($width: null);
    max-width: 40vw;

    @include fgcolor(tert);

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  foot-right {
    margin-left: auto;
    @include flex-cy($gap: 0.5rem);
  }

  topic-time {
    @include clamp($width: null);
  }

  .meta {
    @include flex-cy;

    @include fgcolor(tert);
    padding: 0;
    background: transparent;
    gap: 0.25rem;

    &._active {
      @include fgcolor(warning, 5);
    }
  }
</style>
