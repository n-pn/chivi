<script lang="ts">
  import { browser } from '$app/environment'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let wn_id = 0
  export let pg_no = 1

  export let sname = ''
  // export let sn_id = 0

  let repos: Array<CV.Tsrepo> = []

  $: chivi = repos.find((x) => x.sname == '~avail' && x.sn_id == wn_id) || {
    sroot: `wn~avail/${wn_id}`,
    sname: '~avail',
    sn_id: wn_id,
    chmax: 0,
  }

  $: up_repos = repos.filter((x) => x.stype == 1)
  $: rm_repos = repos.filter((x) => x.stype == 2)

  $: if (browser) reload_repos(wn_id)

  const reload_repos = async (wn_id: number) => {
    const res = await fetch(`/_rd/tsrepos/for_wn?wn_id=${wn_id}`)

    if (!res.ok) {
      console.log(await res.text())
      return
    }

    repos = (await res.json()) as Array<CV.Tsrepo>
  }

  const repo_path = ({ sroot }, pg_no = 1) => {
    return pg_no > 1 ? `/ts/${sroot}?pg=${pg_no}` : `/ts/${sroot}`
  }

  let show_more = 0
</script>

<h3 class="title">Các nguồn chương tiết khác:</h3>

<div class="rlist">
  <a href={repo_path(chivi, pg_no)} class="rchip" class:_active={sname == '~avail'}>
    <div class="sname">Nguồn tổng hợp</div>
    <div class="chmax">
      <strong>{chivi.chmax}</strong> chương
    </div>
  </a>

  <button
    class="rchip"
    on:click={() => (show_more = show_more == 1 ? 0 : 1)}
    class:_active={show_more == 1}
    data-tip="Sưu tầm cá nhân liên kết với bộ truyện"
    data-tip-loc="bottom">
    <div class="sname">Sưu tầm riêng</div>

    <div class="chmax">
      <strong>{up_repos.length}</strong> nguồn
    </div>
  </button>

  <button
    class="rchip"
    on:click={() => (show_more = show_more == 2 ? 0 : 2)}
    class:_active={show_more == 2}
    data-tip="Các nguồn ngoài liên kết với bộ truyện"
    data-tip-loc="bottom">
    <div class="sname">Liên kết nhúng</div>

    <div class="chmax">
      <strong>{rm_repos.length}</strong> nguồn
    </div>
  </button>
</div>

{#if show_more == 1}
  <h4 class="title">Sưu tầm cá nhân:</h4>
  <div class="rlist _extra">
    {#each up_repos as crepo}
      <a
        href={repo_path(crepo, pg_no)}
        class="rchip _sub"
        class:_active={crepo.sname == sname}
        data-tip="Danh sách chương cá nhân của {crepo.sname}"
        data-tip-loc="bottom">
        <div class="sname">{crepo.sname}</div>
        <div class="chmax"><strong>{crepo.chmax}</strong> chương</div>
      </a>
    {/each}

    <a
      href="/up/+proj?wn={wn_id}"
      class="rchip _sub _btn"
      data-tip="Tạo dự án cá nhân mới liên kết tới bộ truyện"
      data-tip-loc="bottom">
      <SIcon name="file-plus" />
      <div class="btn-label">Tạo mới</div>
    </a>
  </div>
{:else if show_more == 2}
  <h4 class="title">Nguồn liên kết ngoài:</h4>
  <div class="rlist _extra">
    {#each rm_repos as crepo}
      <a href={repo_path(crepo, pg_no)} class="rchip _sub" class:_active={crepo.sname == sname}>
        <div class="sname">{crepo.sname}</div>
        <div class="chmax"><strong>{crepo.chmax}</strong> chương</div>
      </a>
    {/each}

    <a
      href="/rm/+stem?wn={wn_id}"
      class="rchip _sub _btn"
      data-tip="Thêm liên kết tới nguồn ngoài"
      data-tip-loc="bottom">
      <SIcon name="square-plus" />
      <span class="btn-label">Thêm mới</span>
    </a>
  </div>
{/if}

<style lang="scss">
  .rlist {
    @include flex-cx($gap: 0.375rem);
    flex-wrap: wrap;
    padding: 0 var(--gutter);

    // margin-top: 0.5rem;
    margin-left: auto;
    margin-right: auto;
    max-width: 35rem;

    &:last-of-type {
      margin-bottom: 0.5rem;
    }

    &._extra {
      margin-top: 0;
    }
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .rchip {
    display: flex;
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
      .sname { @include fgcolor(primary, 5); }
    }

    &._sub {
      padding: 0.25rem 0.375rem;
    }

    &._btn {
      @include label();
      @include fgcolor(success, 5);
      flex-direction: row;
    }
  }

  .sname {
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

    // > span {
    //   margin-right: 0.125em;
    // }
  }

  .btn-label {
    @include bps(font-size, rem(11px), $ts: rem(12px));
  }

  .chmax {
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

  .title {
    @include fgcolor(tert);
    @include ftsize(sm);
    padding: 0.25rem 0;
    font-style: italic;
    text-align: center;
  }
</style>
