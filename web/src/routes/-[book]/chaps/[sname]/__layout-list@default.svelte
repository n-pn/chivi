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
      case 'users':
        return 'Chương tiết do người dùng Chivi đăng tải'

      case 'zxcs_me':
        return 'Nguồn text tải bằng tay từ trang zxcs.me (bản đẹp)'

      case 'hetushu':
        return 'Nguồn truyện từ trang hetushu.com (phần lớn là bản đẹp)'

      default:
        if (sname.startsWith('@')) return `Nguồn truyện của ${sname}`
        if (!slink || slink == '/') return `Nguồn truyện đặc biệt`

        const hostname = new URL(slink).hostname.replace('www.', '')

        return `Nguồn truyện từ trang ${hostname} `
    }
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nvseed[]

  export let _curr: CV.Nvseed
  export let pgidx = 1

  function make_seed(sname: string) {
    return {
      sname,
      snvid: nvinfo.bhash,
      chaps: 0,
      utime: 0,
      stype: 0,
      slink: '/',
    }
  }

  let uname = '@' + $session.uname

  let _base = make_seed('=base')
  let _user = make_seed('=user')
  let _self = make_seed(uname)

  $: base_snames = ['=base', '=user', uname]

  let users: CV.Nvseed[] = []
  let other: CV.Nvseed[] = []

  $: map_nslist(nslist)

  let show_users = false
  let show_other = false

  function map_nslist(nslist: CV.Nvseed[]) {
    users = []
    other = []
    show_users = false
    show_other = false

    for (const nvseed of nslist) {
      switch (nvseed.sname.charAt(0)) {
        case '@':
          if (nvseed.sname == _self.sname) _self = nvseed
          else users.push(nvseed)
          break

        case '=':
          if (nvseed.sname == '=base') _base = nvseed
          else if (nvseed.sname == '=user') _user = nvseed
          break

        default:
          other.push(nvseed)
      }
    }
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
    href={seed_url(nvinfo.bslug, _base.sname, pgidx)}
    class="seed-name umami--click---swap-seed"
    class:_active={_base.sname == _curr.sname}
    data-tip="Danh sách chương tổng hợp từ các nguồn khác">
    <seed-label>
      <span>{_base.sname}</span>
      <SIcon name="affiliate" />
    </seed-label>

    <seed-stats><strong>{_base.chaps}</strong> chương</seed-stats>
  </a>

  {#if _self.chaps > 0 || $session.privi > 0}
    <a
      href={seed_url(nvinfo.bslug, _self.sname, pgidx)}
      class="seed-name umami--click---swap-seed"
      class:_active={_self.sname == _curr.sname}
      data-tip="Danh sách chương của cá nhân bạn">
      <seed-label>
        <span>=self</span>
        <SIcon name="rss" />
      </seed-label>

      <seed-stats><strong>{_self.chaps}</strong> chương</seed-stats>
    </a>
  {/if}

  {#if _user.chaps > 0}
    <a
      href={seed_url(nvinfo.bslug, _user.sname, pgidx)}
      class="seed-name umami--click---swap-seed"
      class:_active={_user.sname == _curr.sname}
      data-tip="Danh sách chương tổng hợp từ người dùng Chivi">
      <seed-label>
        <span>{_user.sname}</span>
        <SIcon name="rss" />
      </seed-label>

      <seed-stats><strong>{_self.chaps}</strong> chương</seed-stats>
    </a>
  {/if}

  {#if !base_snames.includes(_curr.sname)}
    <a
      href={seed_url(nvinfo.bslug, _curr.sname, pgidx)}
      class="seed-name umami--click---swap-seed"
      class:_active={true}
      data-tip={map_info(_curr)}>
      <seed-label>
        <span>{_curr.sname}</span>
        <SIcon name={icon_types[_curr.stype]} />
      </seed-label>

      <seed-stats><strong>{_curr.chaps}</strong> chương</seed-stats>
    </a>
  {/if}

  {#if users.length > 0}
    <button
      class="seed-name _btn"
      data-tip="Các danh sách chương từ người dùng Chivi"
      on:click={() => (show_users = !show_users)}>
      <seed-label>
        <span>users</span>
        <SIcon name="users" />
      </seed-label>

      <seed-stats><strong>{users.length}</strong> người</seed-stats>
    </button>
  {/if}

  {#if show_users}
    {#each users as nvseed}
      <a
        href={seed_url(nvinfo.bslug, nvseed.sname, pgidx)}
        class="seed-name umami--click---swap-seed"
        class:_active={nvseed.sname == _curr.sname}
        data-tip={map_info(nvseed)}>
        <seed-label>
          <span>{nvseed.sname}</span>
          <SIcon name={icon_types[nvseed.stype]} />
        </seed-label>

        <seed-stats><strong>{nvseed.chaps}</strong> chương</seed-stats>
      </a>
    {/each}
  {/if}

  {#if other.length > 0}
    <button
      class="seed-name _btn"
      data-tip="Các nguồn chương tiết khác"
      on:click={() => (show_other = !show_other)}>
      <seed-label>
        <span>Khác</span>
        <SIcon name="archive" />
      </seed-label>

      <seed-stats><strong>{other.length}</strong> nguồn</seed-stats>
    </button>
  {/if}

  {#if show_other}
    {#each other as nvseed}
      <a
        href={seed_url(nvinfo.bslug, nvseed.sname, pgidx)}
        class="seed-name umami--click---swap-seed"
        class:_active={nvseed.sname == _curr.sname}
        data-tip={map_info(nvseed)}>
        <seed-label>
          <span>{nvseed.sname}</span>
          <SIcon name={icon_types[nvseed.stype]} />
        </seed-label>

        <seed-stats><strong>{nvseed.chaps}</strong> chương</seed-stats>
      </a>
    {/each}
  {/if}
</seed-list>

<slot />

<style lang="scss">
  seed-list {
    @include flex-cx($gap: 0.25rem);
    flex-wrap: wrap;
    padding: 0 var(--gutter);
    margin-bottom: 0.75rem;
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
    padding: 0.375em;

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
  }

  seed-label {
    @include flex($center: both);
    @include label();

    line-height: 1rem;
    font-size: rem(13px);

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }

    span {
      margin-right: 0.125em;
    }
  }

  seed-stats {
    display: block;
    text-align: center;
    @include fgcolor(tert);
    font-size: rem(11px);
    line-height: 100%;
  }
</style>
