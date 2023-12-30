<script lang="ts">
  import { page } from '$app/stores'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import BCover from '$gui/atoms/BCover.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'
  import Section from '$gui/sects/Section.svelte'

  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ ustem, sroot, crepo, rmemo } = data)

  $: tabs = [
    { type: 'index', href: sroot, icon: 'album', text: 'Tổng quan' },
    {
      type: 'bants',
      href: `${sroot}/bants`,
      icon: 'message',
      text: 'Thảo luận',
    },
  ]

  $: $crumbs = [
    { text: 'Sưu tầm cá nhân', href: `/up` },
    { text: ustem.sname, href: `/up?vu=${ustem.sname.substring(1)}` },
    { text: `ID: ${ustem.id}` },
  ]

  $: author = ustem.au_vi || ustem.au_zh || 'Dật Danh'
</script>

<section class="bwrap">
  <div class="binfo">
    <h1 class="title">{ustem.vname}</h1>

    <div class="links">
      <span class="xstat">
        <span class="-text"><SIcon name="edit" /></span>
        <a class="-data _link" href="/rm?by={author}">{author}</a>
      </span>
    </div>

    <div class="stats">
      <span class="xstat">
        <span class="-text">Số chương:</span>
        <span class="-data">{crepo.chmax}</span>
      </span>

      <span class="xstat">
        <span class="-text">Cập nhật:</span>
        <span class="-data">{get_rtime(crepo.mtime)}</span>
      </span>

      <span class="xstat">
        <span class="-text">Lượt xem:</span>
        <span class="-data">{crepo.view_count}</span>
      </span>
    </div>
  </div>

  <div class="cover">
    <BCover srcset={ustem.img_cv || ustem.img_og} />
  </div>
</section>

<UserMemo {crepo} {rmemo} conf_path={`/up/+proj?id=${ustem.id}`} />

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

<style lang="scss">
  .bwrap {
    display: flex;
  }

  .title {
    display: block;
    padding: 0.5rem 0;

    @include ftsize(x2);
    @include fgcolor(secd);
  }

  .links {
    @include fgcolor(tert);
    @include flex-cy($gap: 0.5rem);
    flex-wrap: wrap;
    margin-bottom: 0.5rem;

    font-style: normal;

    @include bps(
      font-size,
      rem(14px),
      $pl: rem(15px),
      $ts: rem(16px),
      $tm: rem(17px)
    );
  }

  .stats {
    @include flex($gap: 0.5rem);
    font-style: italic;
    margin-bottom: 0.5rem;
    line-height: 1em;
    padding: 0.25em;

    @include bps(
      font-size,
      rem(13px),
      $pl: rem(14px),
      $ts: rem(15px),
      $tm: rem(16px)
    );
  }

  .xstat {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;

    .-text {
      @include fgcolor(mute);
    }

    .-data {
      @include fgcolor(secd);
    }

    :global(svg) {
      display: inline-flex;
      width: 1em;
      margin-bottom: 0.2em;
    }

    ._link {
      font-weight: 500;
      @include fgcolor(primary, 5);
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  .cover {
    width: 30vw;
    max-width: 96px;
    padding-left: 0.75rem;
    margin-left: auto;
  }
</style>
