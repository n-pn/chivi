<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { dlabels } from '$lib/constants'
  import { rel_time } from '$utils/time_utils'
  import { toggle_like } from '$utils/memo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let post: CV.Dtopic
  export let _mode = 0

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like(
      'dtopic',
      post.dt_id,
      post.me_liked,
      ({ like_count, memo_liked }) => {
        post.like_count = like_count
        post.me_liked = memo_liked
      }
    )
  }
</script>

<topic-card class:sm={$$props.size == 'sm'}>
  <topic-head>
    {#if _mode > 0}
      <a class="m-board" href="/gd/b-{post.b_uslug}">
        <SIcon name="message" />
        <span>{post.b_title}</span>
      </a>
    {/if}

    {#each post.dtags as label}
      <a class="m-label _{dlabels[label]} _sm" href="/gd?lb={label}">{label}</a>
    {/each}
  </topic-head>

  <a class="topic-title" href="/gd/t{post.tslug}">
    {post.title}
  </a>

  <topic-foot>
    <topic-brief>
      <a href="/@{post.u_uname}" class="cv-user" data-privi={post.u_privi}>
        {post.u_uname}
      </a>
      <span class="fg-tert">&middot;</span>
      <time>{rel_time(post.ctime)}</time>
    </topic-brief>

    <foot-right>
      <topic-meta class="meta">
        <SIcon name="eye" />
        <span>{post.view_count}</span>
      </topic-meta>

      <topic-meta class="meta">
        <SIcon name="messages" />
        <span>{post.repl_count}</span>
      </topic-meta>

      <button
        class="meta"
        class:_active={post.me_liked > 0}
        disabled={$_user.privi < 0}
        on:click={handle_like}>
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
    display: block;
    margin: 0.5rem 0;

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
