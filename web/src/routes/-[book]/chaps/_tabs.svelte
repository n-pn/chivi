<script context="module" lang="ts">
  import { page, session } from '$app/stores'
  import { seed_url } from '$utils/route_utils'

  const icon_types = ['affiliate', 'archive', 'cloud-off', 'cloud-fog', 'cloud']

  function map_info({ sname, slink }) {
    switch (sname) {
      case 'users':
        return 'Chương tiết do người dùng Chivi đăng tải'

      case 'staff':
        return 'Chương tiết do ban quản trị Chivi đăng tải'

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

  export let cur_sname = 'union'
  export let cur_pgidx = 1

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

  let _free = make_seed('union')
  let _self = make_seed(uname)
  let _curr = make_seed(cur_sname)

  $: base_snames = ['union', '$free', uname]

  let users: CV.Nvseed[] = []
  let other: CV.Nvseed[] = []

  $: map_nslist(nslist)

  let show_users = false
  let show_other = false

  function map_nslist(nslist: CV.Nvseed[]) {
    users = []
    other = []

    for (const nvseed of nslist) {
      if (base_snames.includes(nvseed.sname)) {
        switch (nvseed.sname) {
          case 'union':
          case '$free':
            _free = nvseed
            continue

          case uname:
            _self = nvseed
            continue

          default:
            continue
        }
      }

      if (nvseed.sname == cur_sname) _curr = nvseed

      if (nvseed.sname.charAt(0) == '@') {
        users.push(nvseed)
      } else {
        other.push(nvseed)
      }
    }
  }
</script>

<seed-list>
  <a
    href={seed_url(nvinfo.bslug, _free.sname, cur_pgidx)}
    class="seed-name umami--click---swap-seed"
    class:_active={_free.sname == cur_sname}
    data-tip="Danh sách chương tổng hợp từ các nguồn khác">
    <seed-label>
      <span>$free</span>
      <SIcon name="affiliate" />
    </seed-label>

    <seed-stats><strong>{_free.chaps}</strong> chương</seed-stats>
  </a>

  {#if _self.chaps > 0 || $session.privi > 0}
    <a
      href={seed_url(nvinfo.bslug, _self.sname, cur_pgidx)}
      class="seed-name umami--click---swap-seed"
      class:_active={_self.sname == cur_sname}
      data-tip="Danh sách chương của cá nhân bạn">
      <seed-label>
        <span>$self</span>
        <SIcon name="affiliate" />
      </seed-label>

      <seed-stats><strong>{_self.chaps}</strong> chương</seed-stats>
    </a>
  {/if}

  {#if !base_snames.includes(cur_sname)}
    <a
      href={seed_url(nvinfo.bslug, cur_sname, cur_pgidx)}
      class="seed-name umami--click---swap-seed"
      class:_active={true}
      data-tip={map_info(_curr)}>
      <seed-label>
        <span>{cur_sname}</span>
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
        href={seed_url(nvinfo.bslug, nvseed.sname, cur_pgidx)}
        class="seed-name umami--click---swap-seed"
        hidden={nvseed.sname == cur_sname}
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
        <SIcon name="cloud" />
      </seed-label>

      <seed-stats><strong>{other.length}</strong> nguồn</seed-stats>
    </button>
  {/if}

  {#if show_other}
    {#each other as nvseed}
      <a
        href={seed_url(nvinfo.bslug, nvseed.sname, cur_pgidx)}
        class="seed-name umami--click---swap-seed"
        hidden={nvseed.sname == cur_sname}
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
    font-size: rem(12px);

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
