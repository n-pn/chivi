<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import { toggle_like } from '$utils/memo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let list: CV.Vilist

  function humanize(num: number) {
    if (num < 1000) return num
    return Math.round(num / 1000) + 'k'
  }

  $: list_path = `/wn/lists/v${list.tslug}`

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like(
      'vilist',
      list.vl_id,
      list.me_liked,
      ({ like_count, memo_liked }) => {
        list.like_count = like_count
        list.me_liked = memo_liked
      }
    )
  }
</script>

<article class="yslist">
  <div class="infos">
    <def class="uname">
      <a class="cv-user" href="/@{list.u_uname}" data-privi={list.u_privi}
        >{list.u_uname}</a>
      <span class="u-fg-tert">&middot;</span>
      <span class="m-meta _larger">{rel_time(list.utime)} </span>
    </def>

    <a class="vname" href={list_path}>{list.title}</a>

    <div class="genres">
      {#each (list.genres || []).slice(0, 4) as genre}
        <span class="genre">{genre}</span>
      {/each}
      {#if list.genres.length > 4}
        <span class="genre">(+{list.genres.length - 4})</span>
      {/if}
    </div>

    <div class="vdesc">
      {@html list.dhtml}
    </div>

    <footer class="footer">
      <span class="m-meta _larger">
        <span class="u-fg-mute">Bộ truyện:</span>
        <span class="u-fg-tert">{list.book_count}</span>
        <SIcon name="bookmarks" />
      </span>

      <button
        type="button"
        class="m-meta _larger"
        class:_active={list.me_liked > 0}
        disabled={$_user.privi < 0}
        on:click={handle_like}>
        <span class="u-fg-mute">Ưa thích:</span>
        <span>{list.like_count}</span>
        <SIcon name="heart" />
      </button>

      <span class="m-meta _larger">
        <span class="u-fg-mute">Lượt xem:</span>
        <span>{humanize(list.view_count)}</span>
        <SIcon name="eye" />
      </span>
    </footer>
  </div>

  <a class="covers" href={list_path}>
    {#each list.covers || [] as cover, idx}
      <div class="cover _{idx}">
        <picture>
          <source
            type="image/webp"
            srcset="https://cdn.chivi.app/covers/{cover}" />
          <img src="/imgs/empty.png" alt="" />
        </picture>
      </div>
    {:else}
      <div class="cover _0"><img src="/imgs/empty.png" alt="" /></div>
    {/each}
  </a>
</article>

<style lang="scss">
  .yslist {
    display: flex;

    margin: 0.75rem 0;
    padding: var(--gutter);

    @include bgcolor(tert);
    @include bdradi;
    // @include shadow;
    @include linesd(--bd-soft);
  }

  .infos {
    flex: 1 1;
    padding-right: 0.75rem;
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
    padding-top: 0.25rem;
    @include clamp($width: 2);
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
    gap: 0.5rem;
    // @include bps(flex-direction, column, $tm: row);
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
</style>
