<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { invalidateAll } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import RepoList from '$gui/shared/wnovel/RepoList.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import ChapList from './ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crepo, rmemo, xstem, chaps, pg_no } = data)
  $: pager = new Pager($page.url, { pg: 1 })

  let _onload = false
  let err_msg: string

  async function do_reload(cmode = 1) {
    _onload = true
    err_msg = ''

    const url = `/_rd/tsrepos/${crepo.sroot}/reload?cmode=${cmode}`
    const res = await fetch(url)
    _onload = false

    if (!res.ok) {
      err_msg = await res.text()
      console.log({ err_msg })
    } else {
      const data = await res.json()
      console.log(data)
      await invalidateAll()
    }
  }

  $: free_chaps = calc_free_chaps(crepo)

  function calc_free_chaps({ chmax }) {
    const free_until = (chmax / 4) | 0
    return free_until < 120 ? free_until : 120
  }
</script>

{#if crepo.wn_id}
  <RepoList
    wn_id={crepo.wn_id}
    pg_no={+$page.url.searchParams.get('pg')}
    sname={crepo.sname}
    sn_id={crepo.sn_id} />
{/if}

<header class="pinfo">
  <div class="infos">
    <span class="sname">{crepo.sname}</span>
    <span class="rstat">{crepo.chmax} chương</span>
    <span class="rstat"><RTime mtime={crepo.mtime} /></span>
  </div>

  <btn-group>
    <button
      class="m-btn _success"
      class:_fill={crepo.rm_slink}
      disabled={$_user.privi < 0}
      data-tip="Cập nhật từ nguồn ngoài hoặc dịch lại nội dung"
      data-tip-pos="right"
      data-tip-loc="bottom"
      on:click={() => do_reload(2)}>
      <SIcon name={_onload ? 'loader-2' : 'refresh'} spin={_onload} />
      <span class="u-show-pm">Làm mới</span>
    </button>
  </btn-group>
</header>

{#if crepo.rm_slink}
  <div class="phint">
    <SIcon name="alert-circle" />

    Danh sách chương tiết được đồng bộ với
    <a href={crepo.rm_slink} class="m-link" target="_blank">
      <strong>nguồn ngoài</strong>
    </a>
    khoảng <strong class="u-warn"><RTime mtime={crepo.mtime} /></strong>. Bấm
    biểu tượng <SIcon name={'refresh'} spin={_onload} /> phía trên để đồng bộ với
    nguồn ngoài.
  </div>
{/if}

{#if err_msg}<div class="phint _error">{err_msg}</div>{/if}

{#if crepo.chmax > 0}
  <div class="phint">
    <SIcon name="alert-circle" />
    <span>
      Chương từ <strong class="u-warn">{free_chaps + 1}</strong> cần
      <strong class="u-warn">thanh toán vcoin</strong> để mở khoá.
    </span>
    <span
      >Hệ số nhân: <strong class="u-warn">{crepo.multp || 3}</strong> (tương
      đương với bạn cần thanh toán
      <strong class="u-warn">0.0{crepo.multp}</strong>
      <SIcon name="vcoin" iset="icons"></SIcon> / một nghìn chữ.)</span>
  </div>

  <section>
    <ChapList {crepo} rmemo={$rmemo} chaps={data.lasts} />
    <hr class="ruler" />
    <ChapList {crepo} rmemo={$rmemo} {chaps} />
  </section>

  <Footer>
    <div class="pager">
      <Mpager
        {pager}
        pgidx={pg_no}
        pgmax={Math.floor((crepo.chmax - 1) / 32) + 1} />
    </div>
  </Footer>
{:else}
  <div class="d-empty">
    <h1>Chưa có text gốc.</h1>

    <p class="p-empty u-warn">
      Hãy thử đổi sang các nguồn chương khác ở phía trên nếu có. Hoặc liên hệ
      với ban quản trị thông qua các kênh thông tin
      <a class="m-link" href="https://www.facebook.com/chivi.fb">Facebook</a>
      hoặc <a class="m-link" href="https://discord.gg/mdC3KQH">Discord</a>
      để được hỗ trợ.
    </p>

    <p class="p-empty">
      Nếu bạn có đủ quyền hạn, có thể bấm vào <a
        href="/ts/{crepo.sroot}/+text"
        class="m-link">Đăng tải</a> để tự thêm text gốc.
    </p>
  </div>
{/if}

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .pinfo {
    display: flex;
    padding: 0.75rem 0;
    @include border(--bd-main, $loc: bottom);
    line-height: 1.25rem;
  }

  .infos {
    @include flex-cy;
    flex: 1;
    margin: 0.25rem 0;

    // transform: translateX(1px);
    @include bps(font-size, 13px, 14px);
  }

  .sname {
    padding-left: 0.375rem;
    @include label();
    @include fgcolor(tert);
    @include border(primary, 5, $width: 3px, $loc: left);
  }

  .rstat {
    font-style: italic;
    @include fgcolor(neutral, 4);

    &:before {
      content: '·';
      padding: 0 0.25rem;
    }
  }
  a.rstat:hover {
    @include fgcolor(primary, 5);
  }

  btn-group {
    @include flex($gap: 0.5rem);
  }

  .phint {
    // text-align: center;
    // font-style: italic;
    // @include flex-cx($gap: 0.5rem);
    margin: 0.5rem 0;

    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1.25rem;

    &._error {
      font-size: italic;
      @include fgcolor(harmful, 5);
    }

    :global(svg) {
      display: inline-block;
      margin-top: -0.15rem;
    }
  }

  .ruler {
    width: 70%;
    margin: var(--gutter) auto;
    @include border(--bd-main, $loc: bottom);
  }

  .pager {
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;
  }

  .p-empty {
    max-width: 40rem;
    margin: 1rem 0;
  }
</style>
