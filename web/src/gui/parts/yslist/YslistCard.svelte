<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'

  export let list: CV.Yslist

  $: uslug = list.id + list.vslug + '-' + list.uslug

  function humanize(num: number) {
    if (num < 1000) return num
    return Math.round(num / 1000) + 'k'
  }
</script>

<article class="yslist">
  <div class="covers">
    {#each list.covers as cover, idx}
      <div class="cover _{idx}"><img src="/covers/{cover}" alt="" /></div>
    {:else}
      <div class="cover _0"><img src="/imgs/blank.png" alt="" /></div>
    {/each}
  </div>

  <div class="infos">
    <a class="vname" href="/lists/{uslug}">{list.vname}</a>

    <div class="genres">
      {#each list.genres.slice(0, 4) as genre}
        <span class="genre">{genre}</span>
      {/each}
      {#if list.genres.length > 4}
        <span class="genre">(+{list.genres.length - 4})</span>
      {/if}
    </div>

    <div class="vdesc">
      {list.vdesc}
    </div>

    <footer class="footer">
      <def class="left">
        <span class="entry">
          <SIcon name="user" />
          <a class="uname" href="/lists?by={list.op_id}">{list.uname}</a>
        </span>

        <span class="entry">
          <SIcon name="clock" />
          <span>{rel_time(list.utime)}</span>
        </span>
      </def>

      <div class="right">
        <span class="entry" data-tip="Bộ truyện">
          <SIcon name="bookmarks" />
          <span>{list.book_count}</span>
        </span>

        <span class="entry" data-tip="Lượt xem">
          <SIcon name="eye" />
          <span>{humanize(list.view_count)}</span>
        </span>

        <span class="entry" data-tip="Ưa thích">
          <SIcon name="heart" />
          <span>{list.like_count}</span>
        </span>
      </div>
    </footer>
  </div>
</article>

<style lang="scss">
  .yslist {
    display: flex;
    margin-top: 0.75rem;
    padding: 0.75rem;

    @include bgcolor(tert);
    @include bdradi;
    @include shadow;
    @include linesd(--bd-soft);
  }

  .covers {
    position: relative;
    width: 7rem;
    min-height: 9rem;
  }

  .cover {
    position: absolute;
    top: 0.5rem;
    left: 0.5rem;
    width: 6rem;
    height: 8rem;

    z-index: 2;
    @include shadow(2);

    &._1 {
      transform: translate(0.5rem, 0.5rem);
      z-index: 1;
      opacity: 0.9;
    }

    &._2 {
      transform: translate(-0.5rem, -0.5rem);
      // z-index: 1;
      // opacity: 0.8;
    }

    > img {
      @include bdradi;
      width: 100%;
      height: 100%;
    }
  }

  .infos {
    flex: 1;
    padding-left: 0.75rem;
    display: flex;
    flex-direction: column;
  }

  .genres {
    display: flex;
    margin: 0.25rem 0;
  }

  .vdesc {
    @include clamp(2);
    @include fgcolor(tert);
    font-size: rem(14px);
    line-height: 1.25rem;
    margin-bottom: 0.25rem;
    font-style: italic;
  }

  .genre {
    @include fgcolor(tert);
    font-weight: 500;
    margin-right: 0.5rem;
    font-size: rem(15px);
  }

  .vname {
    display: block;
    @include clamp(2);
    @include fgcolor(secd);
    @include ftsize(lg);
    line-height: 1.5rem;
    font-weight: 500;

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  .footer {
    margin-top: auto;

    display: flex;
    @include bps(flex-direction, column, $tm: row);
  }

  .left {
    flex: 1;
  }

  .uname {
    font-weight: 500;
    @include fgcolor(secd);
  }

  .entry {
    display: inline-flex;
    gap: 0.125rem;
    font-size: rem(15px);
    align-items: center;
    @include fgcolor(tert);

    :global(svg) {
      @include fgcolor(mute);
    }

    & + & {
      margin-left: 0.25rem;
    }
  }
</style>
