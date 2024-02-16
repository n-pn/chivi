<script lang="ts">
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let yrepl: CV.Ysrepl

  const gen_avatar_url = (yu_id: number, u_pic: string) => {
    return u_pic ? `https://image.lkong.com/avatar/${yu_id}/${u_pic}` : '/imgs/blank.png'
  }

  $: user_href = `/uc/crits?og=ysapp&by=${yrepl.yu_id}`
  $: repl_date = new Date(yrepl.ctime * 1000).toString()
  // $: repl_isrc = gen_avatar_url(yrepl.yu_id, yrepl.u_pic)
</script>

<div class="yrepl">
  <!-- <img class="yuimg" src={repl_isrc} alt={yrepl.uname} /> -->

  <header class="rhead">
    <a class="ruser" href={user_href}>{yrepl.uname}</a>
    <span class="u-fg-tert">·</span>
    <time class="rtime" datetime={repl_date}>{get_rtime(yrepl.ctime)}</time>
    <div class="rlink">
      <SIcon name="thumb-up" />
      <span>{yrepl.like_count}</span>
    </div>
  </header>

  <section class="rbody">
    {@html yrepl.vhtml}
  </section>
</div>

<style lang="scss">
  .yrepl {
    @include border(--bd-soft, $loc: top);
  }

  .rhead {
    @include flex($gap: 0.3rem);
    line-height: 1.5rem;
    padding-top: 0.375rem;
    @include bps(font-size, rem(13px), rem(14px), rem(15px));
  }

  .rtime {
    @include fgcolor(tert);
  }

  .ruser {
    font-weight: 500;
    max-width: min(50vw, 12rem);

    @include clamp($width: null);
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .rlink {
    margin-left: auto;
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;

    > span {
      @include ftsize(sm);
    }
  }

  .rbody {
    @include bps(font-size, rem(15px), rem(16px));
    padding-bottom: 0.5rem;
    > :global(*) + :global(*) {
      margin-top: 0.75rem;
    }
  }
</style>
