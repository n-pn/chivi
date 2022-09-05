<script context="module" lang="ts">
  import { page, session } from '$app/stores'
  import { seed_url } from '$utils/route_utils'

  export async function load({ stuff, url }) {
    const { nvinfo, nslist, nvseed } = stuff
    const pgidx = +url.searchParams.get('pg') || 1

    return { props: { nvinfo, nslist, _curr: nvseed, pgidx } }
  }

  const icon_types = ['affiliate', 'archive', 'cloud-off', 'cloud-fog', 'cloud']

  function map_info({ sname, slink }) {
    switch (sname) {
      case 'zxcs_me':
        return 'Nguồn text tải bằng tay từ trang zxcs.me (bản đẹp).'

      case 'hetushu':
        return 'Chương tiết từ trang hetushu.com (phần lớn là bản đẹp)'

      default:
        if (sname.startsWith('@')) return `Danh sách chương của ${sname}`
        if (!slink || slink == '/') return `Nguồn truyện chưa có chú thích.`

        const hostname = new URL(slink).hostname.replace('www.', '')
        return `Chương tiết tải ngoài từ trang ${hostname}`
    }
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nslist

  export let _curr: CV.Chroot
  export let pgidx = 1

  function make_seed(sname: string) {
    return {
      sname,
      snvid: nvinfo.bhash,
      chmax: 0,
      utime: 0,
      stype: 0,
      slink: '/',
    }
  }

  $: uname = '@' + $session.uname
  $: _self = nslist.users.find((x) => x.sname == uname) || make_seed(uname)

  $: show_subtype = init_show_subtype(_curr)

  function init_show_subtype(curr: CV.Chroot) {
    if (curr.stype < -1 || curr.sname == uname) return 0
    return curr.stype > 0 ? 1 : 2
  }

  function change_subtype(subtype: number) {
    if (show_subtype == subtype) show_subtype = 0
    else show_subtype = subtype
  }
</script>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span class="-text">{nvinfo.btitle_vi}</span></a>
  <span>/</span>
  <span class="crumb _text">Chương tiết</span>
</nav>

<seed-list>
  <a
    href={seed_url(nvinfo.bslug, nslist._base.sname, pgidx)}
    class="seed-name"
    class:_active={nslist._base.sname == _curr.sname}
    data-tip="Danh sách chương trộn tổng hợp miễn phí">
    <seed-label>Tổng hợp</seed-label>
    <seed-stats><strong>{nslist._base.chmax}</strong> chương</seed-stats>
  </a>

  <button
    class="seed-name _btn"
    class:_active={show_subtype == 1}
    data-tip="Chương tiết cập nhật tự động từ các trang web truyện lậu"
    on:click={() => change_subtype(1)}>
    <seed-label>Tải ngoài</seed-label>
    <seed-stats><strong>{nslist.other.length}</strong> nguồn</seed-stats>
  </button>

  <button
    class="seed-name _btn"
    class:_active={show_subtype == 2}
    data-tip="Các danh sách chương của mỗi người dùng Chivi"
    on:click={() => change_subtype(2)}>
    <seed-label>
      <span>Cá nhân</span>
    </seed-label>

    <seed-stats><strong>{nslist.users.length}</strong> người</seed-stats>
  </button>

  {#if _self.chmax > 0 || $session.privi > 0}
    <a
      href={seed_url(nvinfo.bslug, _self.sname, pgidx)}
      class="seed-name"
      class:_active={_self.sname == _curr.sname}
      data-tip="Danh sách chương của cá nhân bạn">
      <seed-label>Của bạn</seed-label>
      <seed-stats><strong>{_self.chmax}</strong> chương</seed-stats>
    </a>
  {/if}
</seed-list>

{#if show_subtype == 1}
  <seed-list class="extra">
    {#each nslist.other as nvseed}
      <a
        href={seed_url(nvinfo.bslug, nvseed.sname, pgidx)}
        class="seed-name _sub"
        class:_active={nvseed.sname == _curr.sname}
        data-tip={map_info(nvseed)}>
        <seed-label>
          <span>{nvseed.sname}</span>
          <SIcon name={icon_types[nvseed.stype]} />
        </seed-label>
        <seed-stats><strong>{nvseed.chmax}</strong> chương</seed-stats>
      </a>
    {/each}
  </seed-list>

  <div class="seed-task">
    <a
      href={seed_url(nvinfo.bslug, '+seed')}
      class="m-btn _xs _success"
      class:_disable={$session.privi < 2}
      data-tip="Thêm nguồn truyện tải tự động">
      <SIcon name="folder-plus" />
      <span class="label">Thêm nguồn</span>
    </a>

    <a
      href={seed_url(nvinfo.bslug, 'prune')}
      class="m-btn _xs"
      class:_disable={$session.privi < 3}
      data-tip="Sửa/xoá các nguồn truyện ngoài">
      <SIcon name="tools" />
      <span class="label">Quản lý nguồn</span>
    </a>
  </div>
{:else if show_subtype == 2}
  <seed-list class="extra">
    <a
      href={seed_url(nvinfo.bslug, nslist._user.sname, pgidx)}
      class="seed-name _sub"
      class:_active={nslist._user.sname == _curr.sname}
      data-tip="Danh sách chương tổng hợp từ các người dùng">
      <seed-label>Nhiều người</seed-label>
      <seed-stats><strong>{_self.chmax}</strong> chương</seed-stats>
    </a>

    {#each nslist.users as nvseed}
      <a
        href={seed_url(nvinfo.bslug, nvseed.sname, pgidx)}
        class="seed-name _sub"
        class:_active={nvseed.sname == _curr.sname}
        data-tip={map_info(nvseed)}>
        <seed-label>{nvseed.sname}</seed-label>
        <seed-stats><strong>{nvseed.chmax}</strong> chương</seed-stats>
      </a>
    {/each}
  </seed-list>
{/if}

<slot />

<style lang="scss">
  seed-list {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    padding: 0 var(--gutter);

    & + & {
      margin-top: 0.5rem;
    }

    &:last-of-type {
      margin-bottom: 0.5rem;
    }
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    display: inline-block;
    align-items: center;
    flex-direction: column;
    background-color: transparent;
    padding: 0.375rem;

    @include bdradi();
    @include linesd(--bd-main);

    // &._btn {
    // }

    &._active {
      @include linesd(primary, 5, $ndef: true);
    }

    // prettier-ignore
    &._active, &:hover, &:active {
      > seed-label { @include fgcolor(primary, 5); }
    }

    &._sub {
      padding: 0.25rem 0.375rem;
    }
  }

  seed-label {
    @include flex($center: both);
    @include label();

    line-height: 1rem;
    @include bps(font-size, rem(12px), $ts: rem(13px));

    ._sub > & {
      line-height: 0.875rem;
      @include bps(font-size, rem(11px), $ts: rem(12px));
    }

    > :global(svg) {
      width: 0.875rem;
      height: 0.875rem;
    }

    > span {
      margin-right: 0.125em;
    }
  }

  seed-stats {
    display: block;
    text-align: center;
    line-height: 0.875rem;
    @include fgcolor(tert);
    @include bps(font-size, rem(11px), $ts: rem(12px));

    ._sub > & {
      line-height: 1rem;
      line-height: 0.75rem;
      @include bps(font-size, rem(10px), $ts: rem(11px));
    }
  }

  .seed-task {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.25rem;
    // text-align: center;
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
  }
</style>
