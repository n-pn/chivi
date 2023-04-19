<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let replies: CV.YsreplPage
  export let _active = true
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="wrap" data-kbd="esc" on:click={() => (_active = false)}>
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <div class="main island" on:click={(e) => e.stopPropagation()}>
    <header class="head">
      <div class="title">Phản hồi bình luận</div>
      <button on:click={() => (_active = false)}>
        <SIcon name="x" />
      </button>
    </header>

    <section class="body">
      <div class="repls">
        {#each replies.repls as repl}
          {@const user = replies.users[repl.yu_id]}
          <div class="repl">
            <header class="repl-head">
              <a class="repl-user" href="/wn/crits?from=ys&user={user.id}"
                >{user.uname}</a>
              <span class="fg-tert">·</span>
              <time class="repl-time">{get_rtime(repl.ctime)}</time>

              <div class="repl-like">
                <SIcon name="thumb-up" />
                <span>{repl.like_count}</span>
              </div>
            </header>

            <section class="repl-body">
              {@html repl.vhtml}
            </section>
          </div>
        {:else}
          <div class="empty">Không có phản hồi</div>
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
    $max-width: 40rem;

    width: $max-width;
    min-width: 320px;
    max-width: 100%;

    @include bgcolor(tert);
    @include shadow(3);

    @include bp-min($max-width) {
      @include bdradi();
    }
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
    padding: 0 var(--gutter);

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
    @include border(--bd-soft, $loc: top);
  }

  .repl-head {
    @include flex($gap: 0.3rem);

    line-height: 1.5rem;
    padding-top: 0.375rem;

    @include bps(font-size, rem(13px), rem(14px), rem(15px));
  }

  .repl-time {
    @include fgcolor(tert);
  }

  .repl-user {
    font-weight: 500;
    max-width: min(50vw, 12rem);

    @include clamp($width: null);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .repl-like {
    margin-left: auto;
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;

    > span {
      @include ftsize(sm);
    }
  }

  .repl-body {
    @include bps(font-size, rem(15px), rem(16px));
    padding-bottom: 0.5rem;
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
