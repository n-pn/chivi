<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { rel_time } from '$utils/time_utils'

  export let ustem: CV.Upstem
  export let upath = '/up'

  $: sroot = `/up/${ustem.sname}:${ustem.id}`

  $: intro = ustem.vintro.split('\n').slice(0, 3).join()
  $: uname = ustem.sname.substring(1)
</script>

<article class="ustem island">
  <div class="xtags">
    <a class="m-chip _xs _primary" href="{upath}?by={uname}">
      <SIcon name="at" />
      <span class="-trim">{uname}</span>
    </a>
    {#if ustem.wn_id}
      <a class="m-chip _xs _success" href="{upath}?wn={ustem.wn_id}">
        <SIcon name="book" />
        <span>{ustem.wn_id}</span>
      </a>
    {/if}
    {#each ustem.labels as label}
      <a class="m-chip _xs _warning" href="{upath}?lb={label}">
        <span class="-trim">{label}</span>
      </a>
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
    padding: 0.5rem var(--gutter);
    row-gap: 0.5rem;

    // @include bgcolor(tert);
    @include border(--bd-soft);

    & + :global(.ustem) {
      margin-top: 1rem;
    }
  }

  .-trim {
    max-width: 30vw;
    @include clamp($width: null);
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
