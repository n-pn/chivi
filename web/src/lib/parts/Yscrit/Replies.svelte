<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'

  export let replies = []
  export let _active = true
</script>

<div class="wrap" data-kbd="esc" on:click={() => (_active = false)}>
  <div class="main" on:click={(e) => e.stopPropagation()}>
    <header class="head">
      <div class="title">Phản hồi bình luận</div>
      <button on:click={() => (_active = false)}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="body">
      <div class="repls">
        {#each replies as repl}
          <div class="repl">
            <header class="repl-head">
              <a class="-user" href="/crits?user={repl.uslug}">{repl.uname}</a>
              <span class="-sep">·</span>
              <time class="-time">{get_rtime(repl.mftime)}</time>

              <div class="-like">
                <SIcon name="thumb-up" />
                <span>{repl.like_count}</span>
              </div>
            </header>

            <section class="repl-body">
              {@html repl.vhtml}
            </section>
          </div>
        {:else}
          <div class="empty">Không có nội dung!</div>
        {/each}
      </div>
    </section>
  </div>
</div>

<style lang="scss">
  .wrap {
    @include flex($center: both);
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 9999;
    background: rgba(#000, 0.75);
  }

  .main {
    width: rem(40);
    min-width: 320px;
    max-width: 100%;
    @include bgcolor(tert);
    @include bdradi();
    @include shadow(3);
  }

  .head {
    position: relative;
    text-align: center;
    padding: 0.25rem;
    line-height: 2rem;
    font-weight: 500;
    // @include ftsize(lg);

    button {
      position: absolute;
      right: 0.5rem;
      // top: 0.25rem;
      top: 0;
      background: transparent;
      padding: 0.25rem;
      @include fgcolor(tert);
      --linesd: none !important;
    }
  }

  .body {
    // @include bgcolor(secd);
    padding: 0 var(--gutter-small);
    margin-top: 0.25rem;
    margin-bottom: 0.25rem;
    overflow: auto;
    max-height: calc(100vh - 6rem);
    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }

  .repl {
    margin-bottom: 1rem;
    @include shadow();
    @include bdradi();
    @include bgcolor(secd);
  }

  .repl-head {
    @include flex($gap: 0.3rem);

    @include bgcolor(secd);
    @include bdradi($loc: top);
    // @include border(--bd-main, $loc: bottom);

    padding: 0.375rem var(--gutter-small);
    line-height: 1.75rem;
    @include bps(font-size, rem(13px), rem(14px), rem(15px));

    .-user,
    .-time {
      @include fgcolor(secd);
      @include clamp($width: null);
      &:hover {
        @include fgcolor(primary, 5);
      }
    }

    .-user {
      font-weight: 500;
      max-width: 50vw;
    }

    .-time {
      @include fgcolor(tert);
    }

    .-like {
      margin-left: auto;
      @include fgcolor(tert);
      > span {
        @include ftsize(sm);
      }
    }
  }

  .repl-body {
    margin: 0 var(--gutter-small);
    @include bps(font-size, rem(15px), rem(16px));
    padding-bottom: 0.75rem;
    > :global(*) + :global(*) {
      margin-top: 0.75rem;
    }
  }

  .empty {
    @include flex($center: both);
    @include fgcolor(tert);
    font-style: italic;
    height: 3rem;
    margin-bottom: 1.5rem;
  }
</style>
