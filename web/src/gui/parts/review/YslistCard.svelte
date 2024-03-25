<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let list: CV.Yslist
  export let user: CV.Ysuser

  function humanize(num: number) {
    if (num < 1000) return num
    return Math.round(num / 1000) + 'k'
  }

  $: list_path = `/uc/lists/y${list.id}${list.vslug}`
</script>

<article class="blcard">
  <div class="blcard-infos">
    <def class="fz-fluid">
      <a class="cv-user" href="/uc/lists?from=ys&user={user.id}">{user.uname}</a>

      <span class="u-fg-tert">&middot;</span>
      <span class="u-fg-tert">{rel_time(list.utime)} </span>
    </def>

    <a class="blcard-vtitle fz-fluid-lg" href={list_path}>{list.vname}</a>
    <div class="blcard-vbrief fz-fluid-sm">{list.vdesc}</div>

    <footer class="footer fz-fluid-sm">
      <span class="m-meta">
        <span class="u-fg-mute u-show-pl">Bộ truyện:</span>
        <span class="u-fg-tert">{list.book_count}</span>
        <SIcon name="bookmarks" />
      </span>

      <span class="m-meta">
        <span class="u-fg-mute u-show-pl">Ưa thích:</span>
        <span>{list.like_count}</span>
        <SIcon name="heart" />
      </span>

      <span class="m-meta">
        <span class="u-fg-mute u-show-pl">Lượt xem:</span>
        <span>{humanize(list.view_count)}</span>
        <SIcon name="eye" />
      </span>
    </footer>
  </div>

  <a class="blcard-covers" href={list_path}>
    {#each list.covers as cover, idx}
      <div class="blcard-bcover _{idx}">
        <picture>
          <source type="image/webp" srcset="https://img.chivi.app/covers/{cover}" />
          <img src="https://img.chivi.app/empty.png" alt="" />
        </picture>
      </div>
    {:else}
      <div class="blcard-covers _0">
        <img src="https://img.chivi.app/empty.png" alt="" />
      </div>
    {/each}
  </a>
</article>

<style lang="scss">
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

  .footer {
    display: flex;
    gap: 0.5rem;
    margin-top: auto;
  }
</style>
