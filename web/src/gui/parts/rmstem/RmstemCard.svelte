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
  <section class="binfo">
    <a class="title fz-fluid-lg" href={sroot}>{btitle}</a>

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

    <p class="intro u-fz-sm u-fg-tert u-fs-i">
      {intro || 'Không có giới thiệu'}
    </p>

    <div class="stats u-fz-sm u-fs-i">
      <span class="group">
        <span class="u-fg-mute">Số chương:</span>
        <span class="u-fg-tert">{rstem.chap_count}</span>
      </span>
      <span class="group">
        <span class="u-fg-mute">Lượt xem:</span>
        <span class="u-fg-tert">{rstem.view_count}</span>
      </span>
    </div>
  </section>

  <a class="cover" href={sroot}><BCover srcset={rstem.cover_rm} /></a>
</article>

<style lang="scss">
  .rstem {
    display: flex;
    padding: 0.5rem var(--gutter);
    @include border(--bd-soft);

    &:hover {
      border-color: color(primary, 5, 5);
    }

    & + :global(.rstem) {
      margin-top: 1rem;
    }
  }

  .binfo {
    flex: 1;
    width: calc(100% - 96px);
    padding-right: 0.75rem;
  }

  .title {
    display: block;
    padding: 0.25rem 0 0.5rem;
    line-height: 1.2;
    @include clamp($width: null);
    @include fgcolor(main);

    &:hover {
      @include fgcolor(primary);
    }
  }

  .xtags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25em;
  }

  .m-chip {
    gap: 0.125em;

    &._tag {
      text-transform: capitalize;
    }

    .-trim {
      max-width: 30vw;
      @include clamp($width: null);
    }
  }

  .intro {
    line-height: 1.25rem;
    margin-top: 0.5rem;
    @include clamp($width: null);
  }

  .stats {
    @include flex($gap: 0.5rem);
    margin-top: 0.375rem;
    line-height: 1rem;
  }

  .cover {
    display: block;
    width: 30vw;
    max-width: 96px;
    margin-left: auto;
  }
</style>
