<script lang="ts">
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

<article class="rstem">
  <div class="xtags">
    <a class="m-chip _xs _primary" href="{rpath}?sn={rstem.sname}">
      <SIcon name="share" />
      {sname}</a>
    <a class="m-chip _xs _primary" href="{rpath}?by={author}">
      <SIcon name="ballpen" />
      {author}</a>
    {#if rstem.wn_id}
      <a class="m-chip _xs _success" href="{rpath}?wn={rstem.wn_id}">
        <SIcon name="book" />
        {rstem.wn_id}</a>
    {/if}
    {#if labels}
      {#each labels.split('\t') as label}
        <a class="m-chip _xs _warning" href="{rpath}?lb={label}">{label}</a>
      {/each}
    {/if}
  </div>

  <a class="title u-fz-lg u-fg-secd" href={sroot}>{btitle}</a>
  <p class="intro u-fz-sm u-fg-tert u-fs-i">{intro || 'Không có giới thiệu'}</p>

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
</article>

<style lang="scss">
  .rstem {
    padding: 0.5rem 1rem;
    // max-width: 30rem;

    @include bgcolor(tert);
    @include bdradi;
    @include border(--bd-soft);

    & + :global(.rstem) {
      margin-top: 1rem;
    }
  }

  .xtags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25em;
  }

  .m-chip {
    gap: 0.125em;
  }

  .title {
    display: block;
    padding: 0.5rem 0;

    &:hover {
      @include fgcolor(primary);
    }
  }

  .intro {
    line-height: 1.25rem;
    @include clamp($lines: 1);
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
