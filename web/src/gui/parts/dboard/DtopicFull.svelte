<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import { dlabels } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let post: CV.Dtopic
  export let user: CV.Viuser
  export let memo: CV.Memoir = { liked: 0, track: 0, tagged: 0, viewed: 0 }
  export let _all = post.bhtml.length < 500

  $: board_url = `/gd/b-${post.dboard.bslug}`

  async function toggle_like() {
    const type = memo.liked > 0 ? 'unlike' : 'like'
    const api_url = `/_db/memos/dtopic/${post.id}/${type}`
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

<article class:fluid={$$props.fluid}>
  <topic-navi>
    <a href="/gd" class="m-board">
      <SIcon name="messages" />
      <span>Diễn đàn</span>
    </a>

    <span class="fs-sm fg-mute">/</span>

    <a class="m-board" href={board_url}>
      <SIcon name="message" />
      <span>{post.dboard.bname}</span>
    </a>

    {#each post.labels as label}
      <a class="m-label _{dlabels[label]}" href="{board_url}?lb={label}"
        >{label}</a>
    {/each}
  </topic-navi>

  <header class="topic-head {_all}">
    <a class="topic-title" href="/gd/t{post.id}-{post.tslug}">
      {post.title}
    </a>

    <topic-foot>
      <topic-user>
        <SIcon name="user" />
        <a class="cv-user" href="/@{user.uname}">{user.uname}</a>
      </topic-user>

      <topic-sep>·</topic-sep>
      <topic-time>{rel_time(post.ctime)}</topic-time>

      {#if $_user.privi > 3 || $_user.uname == user.uname}
        <topic-sep>·</topic-sep>
        <a class="action fg-tert" href="/gd/+topic?id={post.id}"
          ><span>Sửa</span>
        </a>
      {/if}

      <foot-right>
        <topic-meta class="meta">
          <SIcon name="messages" />
          <span>{post.post_count}</span>
        </topic-meta>

        <topic-sep>·</topic-sep>
        <topic-meta class="meta">
          <SIcon name="eye" />
          <span>{post.view_count}</span>
        </topic-meta>

        <span class="fg-mute">&middot;</span>

        <button
          class="meta"
          class:_active={memo.liked > 0}
          disabled={$_user.privi < 0}
          on:click={toggle_like}>
          <SIcon name="star" />
          <span>{post.like_count}</span>
        </button>
      </foot-right>
    </topic-foot>
  </header>

  <topic-pbody class:_all>
    <section class="m-article">{@html post.bhtml}</section>

    {#if post.bhtml.length >= 500}
      <pbody-foot>
        <button
          class="m-btn _primary _xs btn-show"
          on:click={() => (_all = !_all)}>
          <SIcon name="chevrons-{_all ? 'up' : 'down'}" />
          <span class="-text">{_all ? 'Thu hẹp' : 'Mở rộng'}</span>
        </button>
      </pbody-foot>
    {/if}
  </topic-pbody>
</article>

<style lang="scss">
  .topic-head {
    display: block;
    // @include flex-cy($gap: 0.25rem);
    padding: 0.5rem 0 0.25rem;
    @include border($loc: bottom);
  }

  .m-board {
    @include clamp($width: null);
    max-width: 40vw;

    line-height: 1.375rem;
    @include fgcolor(tert);

    @include ftsize(sm);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  topic-navi {
    @include flex-cy($gap: 0.25rem);
    flex-wrap: wrap;
  }

  .m-label {
    font-size: rem(12px);
    padding: 0 0.375rem;
    line-height: 1.25rem;
  }

  .topic-title {
    display: block;
    font-weight: 500;

    @include fgcolor(secd);
    @include hover {
      @include fgcolor(primary, 5);
    }

    // typography
    line-height: 1.5rem;
    font-size: rem(18px);

    .fluid & {
      @include bps(line-height, 1.375rem, $pl: 1.5rem, $tm: 1.75rem);
      @include bps(font-size, rem(17px), $pl: rem(20px), $tm: rem(24px));
    }
  }

  .m-article {
    display: block;
    padding: 0.75rem 0;
    max-height: 10rem;
    overflow: hidden;
    transform: max-height 1s ease-in-out;
    font-size: rem(16px);

    ._all & {
      max-height: initial;
      overflow: initial;
    }

    .fluid & {
      @include bps(font-size, rem(16px), $tm: rem(17px));
    }
  }

  topic-foot {
    @include flex-cy($gap: 0.25rem);
    // line-height: 2rem;

    padding: 0.5rem 0 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
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

  foot-right {
    display: inline-flex;
    gap: 0.25rem;
    margin-left: auto;
  }

  .action {
    font-style: italic;
    border: none;
    background: none;

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  // prettier-ignore
  topic-pbody {
    --hide: #{color(neutral, 7, 2)};
    display: block;
    position: relative;

    background: linear-gradient(to top, color(--hide) .25rem, transparent 1rem);
    // @include border(--bd-main, $loc: bottom);
    // @include tm-dark { --hide: #{color(neutral, 5, 2)}; }
    &._all { background: none; }
  }

  pbody-foot {
    @include flex-cx;
    position: absolute;
    bottom: -0.75rem;
    left: 0;
    right: 0;
    height: 1.5rem;
  }

  .btn-show {
    text-transform: uppercase;
    padding: 0.25rem;
    display: inline-flex;
    align-items: center;
    :global(svg) {
      width: 1rem;
      height: 1rem;
    }
  }
</style>
