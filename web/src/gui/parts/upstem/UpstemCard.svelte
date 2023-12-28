<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import BCover from '$gui/atoms/BCover.svelte'

  export let ustem: CV.Upstem
  export let upath = '/up'

  $: sroot = `/up/${ustem.sname}:${ustem.id}`

  $: uname = ustem.sname.substring(1)
  $: intro = ustem.vdesc || 'Chưa có giới thiệu'
</script>

<article class="ustem island">
  <section class="binfo">
    <a class="title u-fz-lg" href={sroot}>{ustem.vname}</a>

    <div class="xtags">
      <a class="m-chip _xs _primary" href="{upath}?vu={uname}">
        <SIcon name="at" />
        <span class="-trim">{uname}</span>
      </a>

      <a class="m-chip _xs _warning" href="{upath}?au={ustem.au_vi}">
        <SIcon name="edit" />
        <span>{ustem.au_vi}</span>
      </a>

      {#if ustem.wn_id}
        <a class="m-chip _xs _success" href="{upath}?wn={ustem.wn_id}">
          <SIcon name="book" />
          <span>{ustem.wn_id}</span>
        </a>
      {/if}
      {#each ustem.labels as label}
        <a class="m-chip _xs _default _tag" href="{upath}?lb={label}">
          <SIcon name="tag" />
          <span class="-trim">{label}</span>
        </a>
      {/each}
    </div>

    <p class="intro u-fz-sm u-fg-tert u-fs-i">
      {intro || 'Không có giới thiệu'}
    </p>

    <div class="stats u-fz-sm u-fs-i">
      <span class="group">
        <span class="u-fg-mute">Số chương:</span>
        <span class="u-fg-tert">{ustem.chap_count}</span>
      </span>

      <span class="group">
        <span class="u-fg-mute">Lượt xem:</span>
        <span class="u-fg-tert">{ustem.view_count}</span>
      </span>
    </div>
  </section>

  <a href={sroot} class="cover">
    <BCover srcset={ustem.img_cv || ustem.img_og} />
  </a>
</article>

<style lang="scss">
  .ustem {
    display: flex;
    padding: 0.5rem var(--gutter);
    @include border(--bd-soft);

    &:hover {
      border-color: color(primary, 5, 5);
    }

    & + :global(.ustem) {
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
