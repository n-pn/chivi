<script lang="ts">
  import { page } from '$app/stores'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import BCover from '$gui/atoms/BCover.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ rstem, sroot, crepo, rmemo } = data)

  $: tabs = [
    { type: 'index', href: `${sroot}`, icon: 'article', text: 'Mục lục' },
    {
      type: 'bants',
      href: `${sroot}/bants`,
      icon: 'message',
      text: 'Thảo luận',
    },
    // { type: 'notif', href: `${sroot}/notif`, icon: 'activity', text: 'Thay đổi' },
  ]

  $: sname = rstem.sname.substring(1)
  $: author = rstem.author_vi || rstem.author_zh

  $: $crumbs = [
    { text: 'Nguồn liên kết nhúng', href: `/rm` },
    { text: sname, href: `/rm?sn=${rstem.sname}` },
    { text: `ID: ${rstem.sn_id}` },
  ]

  const status_strs = ['Còn tiếp', 'Hoàn thành', 'Tạm dừng', 'Không rõ']
</script>

<section class="bwrap">
  <div class="binfo">
    <h1 class="title">{rstem.btitle_vi} - {rstem.btitle_zh}</h1>

    <div class="links">
      <span class="xstat">
        <span class="-text"><SIcon name="edit" /></span>
        <a class="-data _link" href="/rm?by={author}">{author}</a>
      </span>

      <span class="xstat">
        <span class="-text"><SIcon name="world" /></span>
        <a class="-data _link" href="/rm?sn={rstem.sname}">{sname}</a>
        {#if rstem.rlink}
          <a class="-data _link" href={rstem.rlink}
            ><SIcon name="external-link" /></a>
        {/if}
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
        <span class="-text">Trạng thái:</span>
        <span class="-data">{status_strs[rstem.status_int]}</span>
      </span>

      <span class="xstat">
        <span class="-text">Hệ số:</span>
        <span class="-data">{crepo.multp}</span>
      </span>

      <span class="xstat">
        <span class="-text">Lượt xem:</span>
        <span class="-data">{crepo.view_count}</span>
      </span>
    </div>
  </div>

  <div class="cover">
    <BCover srcset={rstem.cover_rm} />
  </div>
</section>

<UserMemo {crepo} {rmemo} />

<Section {tabs} _now={$page.data.ontab}>
  <slot />
</Section>

<style lang="scss">
  .bwrap {
    display: flex;
  }

  .title {
    display: block;
    padding: 0.25em 0;
    line-height: 1.5em;

    // @include ftsize();
    @include fgcolor(secd);

    @include bps(
      font-size,
      rem(18px),
      $pl: rem(20px),
      $ts: rem(24px),
      $tm: rem(28px)
    );
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
    flex-wrap: wrap;
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
