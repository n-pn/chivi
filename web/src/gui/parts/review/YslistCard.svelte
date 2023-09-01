<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let list: CV.Yslist
  export let user: CV.Ysuser

  function humanize(num: number) {
    if (num < 1000) return num
    return Math.round(num / 1000) + 'k'
  }
</script>

<article class="yslist">
  <div class="covers">
    {#each list.covers as cover, idx}
      <div class="cover _{idx}">
        <picture>
          <source type="image/webp" srcset="/covers/{cover}" />
          <img src="/imgs/empty.png" alt="" />
        </picture>
      </div>
    {:else}
      <div class="cover _0"><img src="/imgs/empty.png" alt="" /></div>
    {/each}
  </div>

  <div class="infos">
    <a class="vname" href="/wn/lists/y{list.id}{list.vslug}">{list.vname}</a>

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
          <a class="uname" href="/wn/lists?from=ys&user={user.id}"
            >{user.uname}</a>
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

        <span class="entry" data-tip="Ưa thích">
          <SIcon name="heart" />
          <span>{list.like_count}</span>
        </span>

        <span class="entry" data-tip="Lượt xem">
          <SIcon name="eye" />
          <span>{humanize(list.view_count)}</span>
        </span>
      </div>
    </footer>
  </div>
</article>

<style lang="scss">
  .yslist {
    display: flex;

    margin: 1rem 0;
    padding: var(--gutter);

    @include bgcolor(tert);
    @include bdradi;
    // @include shadow;
    @include linesd(--bd-soft);
  }

  .covers {
    position: relative;
    width: 30%;
    padding: 0.5rem;
    max-width: 7rem;
    min-height: 9rem;
  }

  .cover {
    position: absolute;
    width: 6rem;
    height: 8rem;

    z-index: 2;

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

    img {
      display: block;
      width: 100%;
      height: 100%;

      @include bdradi;
      @include shadow(2);
    }
  }

  .infos {
    flex: 1 1;
    padding-left: 0.75rem;
    display: flex;
    flex-direction: column;
    z-index: 9;
    background: inherit;
  }

  .genres {
    display: flex;
    margin: 0.25rem 0;
    overflow: hidden;
  }

  .genre {
    @include fgcolor(tert);
    font-weight: 500;
    margin-right: 0.5rem;
    font-size: rem(15px);
    @include clamp($width: null);
  }

  .vdesc {
    @include clamp(2);
    @include fgcolor(tert);
    font-size: rem(14px);
    line-height: 1.25rem;
    margin-bottom: 0.25rem;
    font-style: italic;
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
