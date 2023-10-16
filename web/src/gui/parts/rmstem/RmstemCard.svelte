<script lang="ts">
  import BCover from '$gui/atoms/BCover.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'

  export let rstem: CV.Rmstem
  export let rpath = '/rm'

  $: sroot = `/rm/${rstem.sname}:${rstem.sn_id}`

  $: intro = rstem.intro_vi || rstem.intro_zh
  $: sname = rstem.sname.substring(1)

  $: author = rstem.author_vi || rstem.author_zh
  $: btitle = rstem.btitle_vi || rstem.btitle_zh

  $: labels = rstem.genre_vi || rstem.genre_zh
</script>

<article class="rstem island">
  <div class="xtags">
    <a class="m-chip _xs _primary" href="{rpath}?sn={rstem.sname}">
      <SIcon name="world" />
      <span class="-trim">{sname}</span>
    </a>
    <a class="m-chip _xs _primary" href="{rpath}?by={author}">
      <SIcon name="edit" />
      <span class="-trim">{author}</span>
    </a>
    {#if rstem.wn_id}
      <a class="m-chip _xs _success" href="{rpath}?wn={rstem.wn_id}">
        <SIcon name="book" />
        {rstem.wn_id}</a>
    {/if}
    {#if labels}
      {#each labels.split('\t') as label}
        <a class="m-chip _xs _warning" href="{rpath}?lb={label}">
          <span class="-trim">{label}</span>
        </a>
      {/each}
    {/if}
  </div>

  <div class="rinfo">
    <a class="title fz-fluid-lg" href={sroot}>{btitle}</a>
    <p class="intro u-fz-sm u-fg-tert u-fs-i">
      {intro || 'Không có giới thiệu'}
    </p>

    <div class="stats u-fz-sm u-fs-i">
      <span class="group">
        <span class="u-fg-mute">Cập nhật:</span>
        <span class="u-fg-tert">{rel_time(rstem.update_int)}</span>
      </span>
      <span class="group">
        <span class="u-fg-mute">Số chương:</span>
        <span class="u-fg-tert">{rstem.chap_count}</span>
      </span>
      <span class="group">
        <span class="u-fg-mute">Hệ số nhân:</span>
        <span class="u-fg-tert">{rstem.multp}</span>
      </span>
      <span class="group">
        <span class="u-fg-mute">Lượt xem:</span>
        <span class="u-fg-tert">{rstem.view_count}</span>
      </span>
    </div>
  </div>

  <a class="cover" href={sroot}><BCover srcset={rstem.cover_rm} /></a>
</article>

<style lang="scss">
  .rstem {
    display: grid;

    padding: 0.5rem var(--gutter);
    row-gap: 0.5rem;
    // column-gap: 0.5rem;

    // max-width: 30rem;
    grid-template-columns: 80% 20%;
    grid-template-areas:
      'xtags xtags'
      'rinfo cover';

    @include border(--bd-soft);

    @include bp-min(ts) {
      grid-template-areas:
        'xtags cover'
        'rinfo cover';
      grid-template-columns: 83% 17%;

      .xtags {
        margin-top: 0;
      }
    }

    @include bp-min(tm) {
      grid-template-columns: 85% 15%;
    }

    & + :global(.rstem) {
      margin-top: 1rem;
    }
  }

  .xtags {
    grid-area: xtags;

    margin-top: 0.5rem;
    display: flex;
    flex-wrap: wrap;
    gap: 0.25em;
  }

  .rinfo {
    // flex: 1;

    display: flex;
    flex-direction: column;
    margin-right: var(--gutter-small);
    grid-area: rinfo;
  }

  .cover {
    display: block;
    height: 100%;
    grid-area: cover;
  }

  .m-chip {
    gap: 0.125em;
  }

  .-trim {
    max-width: 30vw;
    @include clamp($width: null);
  }

  .title {
    // padding: 0.5em 0;
    padding-bottom: 0.5rem;
    @include clamp($lines: 2);

    @include fgcolor(main);
    line-height: 1.2;

    &:hover {
      @include fgcolor(primary);
    }
  }

  .intro {
    line-height: 1.25rem;
    display: -webkit-box;
    overflow: hidden;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    @include bp-min(ts) {
      -webkit-line-clamp: 2;
    }
  }

  .stats {
    display: flex;
    flex-wrap: wrap;
    padding: 0.25rem 0;
    line-height: 1rem;
    gap: 0.25rem;
    margin-top: 0.25rem;
  }
</style>
