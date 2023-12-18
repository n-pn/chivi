<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ycrit, repls } = data)

  // const gen_avatar_url = (yu_id: number, u_pic: string) => {
  //   if (!u_pic) return '/img/blank.png'
  //   return `https://image.lkong.com/avatar/${yu_id}/${u_pic}`
  // }
</script>

<YscritCard {...ycrit} view_all={true} big_text={true} />

<section id="repls" class="repls">
  <h3 class="repls-head">Phản hồi đánh giá ({ycrit.crit.repl_count}):</h3>

  {#each repls as repl}
    {@const user_href = `/wn/crits?from=ys&user=${repl.yu_id}`}
    {@const repl_date = new Date(repl.ctime * 1000).toString()}
    <div class="repl">
      <header class="repl-head">
        <a class="repl-user" href={user_href}>{repl.uname}</a>
        <span class="u-fg-tert">·</span>
        <time class="repl-time" datetime={repl_date}
          >{get_rtime(repl.ctime)}</time>
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
    <div class="d-empty-sm">Không có phản hồi.</div>
  {/each}
</section>

<style lang="scss">
  .repls {
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
  }

  .repls-head {
    margin-bottom: 0.25rem;
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

    > :global(p) {
      max-width: 70ch;
    }

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
</style>
