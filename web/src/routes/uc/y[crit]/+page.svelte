<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ycrit: crit, ylist: list, yuser: user, vbook: book } = data)
</script>

<article class="article island _narrow">
  <h2>Đánh giá của {user.uname} cho bộ truyện {book.vtitle}</h2>

  <YscritCard {crit} {book} {list} {user} view_all={true} />

  <section class="replies">
    <h3 class="replies-header">Phản hồi bình luận:</h3>
    {#each data.repls as repl}
      {@const user = data.users[repl.yu_id]}
      <div class="repl">
        <header class="repl-head">
          <a class="repl-user" href="/uc?from=ys&user={user.id}"
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
      <div class="empty">Không có phản hồi.</div>
    {/each}
  </section>
</article>

<style lang="scss">
  article {
    margin-top: 0.75rem;
  }

  .replies {
    @include padding-x(var(--gutter));
    max-width: min(40rem, 100%);
    // margin: 0 auto;
  }

  .replies-header {
    margin-bottom: 1rem;
  }

  .repl {
    @include border(--bd-soft, $loc: top);
  }

  .repl-head {
    @include flex($gap: 0.3rem);

    line-height: 1.75rem;
    padding-top: 0.375rem;

    @include bps(font-size, rem(13px), rem(14px), rem(15px));
  }

  .repl-body {
    @include bps(font-size, rem(15px), rem(16px));
    padding-bottom: 0.75rem;
    > :global(* + *) {
      margin-top: 0.75rem;
    }
  }

  .repl-user,
  .repl-time {
    @include clamp($width: null);
  }

  .repl-time,
  .repl-like {
    @include fgcolor(tert);
  }

  .repl-user {
    font-weight: 500;
    max-width: 50vw;
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

  .empty {
    @include flex($center: both);
    @include fgcolor(tert);
    font-style: italic;
    height: 3rem;
    margin-bottom: 1.5rem;
  }
</style>
