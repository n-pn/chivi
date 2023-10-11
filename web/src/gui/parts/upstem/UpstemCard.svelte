<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'

  export let ustem: CV.Upstem
  export let upath = '/up'

  $: sroot = `/up/${ustem.sname}:${ustem.id}`

  $: intro = ustem.vintro.split('\n').slice(0, 3).join()
  $: uname = ustem.sname.substring(1)
</script>

<article class="ustem">
  <div class="xtags">
    <a class="m-chip _xs _primary" href="{upath}?by={uname}">
      <SIcon name="at" />
      {uname}</a>
    {#if ustem.wn_id}
      <a class="m-chip _xs _success" href="{upath}?wn={ustem.wn_id}">
        <SIcon name="book" />
        {ustem.wn_id}</a>
    {/if}
    {#each ustem.labels as label}
      <a class="m-chip _xs _warning" href="{upath}?lb={label}">{label}</a>
    {/each}
  </div>

  <a class="title u-fz-lg u-fg-secd" href={sroot}>{ustem.vname}</a>
  <p class="intro u-fz-sm u-fg-tert u-fs-i">{intro || 'Không có giới thiệu'}</p>

  <div class="stats u-fz-sm u-fs-i">
    <span class="group">
      <span class="u-fg-mute">Cập nhật:</span>
      <span class="u-fg-tert">{rel_time(ustem.mtime)}</span>
    </span>
    <span class="group">
      <span class="u-fg-mute">Số chương:</span>
      <span class="u-fg-tert">{ustem.chap_count}</span>
    </span>
    <span class="group">
      <span class="u-fg-mute">Hệ số nhân:</span>
      <span class="u-fg-tert">{ustem.multp}</span>
    </span>
    <span class="group">
      <span class="u-fg-mute">Lượt xem:</span>
      <span class="u-fg-tert">{ustem.view_count}</span>
    </span>
  </div>
</article>

<style lang="scss">
  .ustem {
    padding: 0.5rem 1rem;
    // max-width: 30rem;

    @include bgcolor(tert);
    @include bdradi;
    @include border(--bd-soft);

    & + :global(.ustem) {
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
