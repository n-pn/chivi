<script lang="ts">
  import { chap_path, _pgidx } from '$lib/kit_path'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'

  async function load_rdmemos(): Promise<Array<CV.Rdmemo>> {
    const url = `/_rd/rdmemos?rtype=rdlog&lm=3`
    const res = await fetch(url)

    if (!res.ok) {
      alert(await res.text())
      return []
    }

    const data = await res.json()
    return data.items
  }

  const gen_cdata = (rmemo: CV.Rdmemo) => {
    const ch_no = rmemo.last_ch_no
    const cinfo = rmemo.last_cinfo
    const chref = chap_path(rmemo.rpath, ch_no, cinfo)
    return { ch_no, cinfo, chref }
  }

  const stypes = [
    ['', 'Tất cả'],
    ['?sn=wn', 'Truyện chữ'],
    ['?sn=up', 'Sưu tầm'],
    ['?sn=rm', 'Liên kết'],
  ]
</script>

<details open>
  <summary>Chương tiết vừa đọc</summary>

  <nav class="links">
    {#each stypes as [filter, label]}
      <a class="m-btn _xs _primary" href="/me/rdlog{filter}">{label}</a>
    {/each}
  </nav>

  <div class="chaps">
    {#await load_rdmemos()}
      <div class="d-empty-sm">Đang tải lịch sử đọc truyện.</div>
    {:then rdmemos}
      {#each rdmemos as rmemo}
        {@const cdata = gen_cdata(rmemo)}

        <a class="chap" href={cdata.chref}>
          <div class="chap-text">
            <div class="chap-title">{cdata.cinfo.title}</div>
            <div class="chap-chidx">{cdata.ch_no}.</div>
          </div>

          <div class="chap-meta">
            <div class="chap-bname">
              [{rmemo.sname}] {rmemo.vname}
            </div>
            <div
              class="chap-state"
              data-tip="Xem: {get_rtime(rmemo.rtime)}"
              data-tip-pos="right">
              <SIcon name="eye" />
            </div>
          </div>
        </a>
      {:else}
        <div class="d-empty-sm">Không có lịch sử đọc truyện</div>
      {/each}
    {/await}
  </div>
</details>

<style lang="scss">
  .links {
    margin-bottom: 0.5rem;
    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }
  }

  .chaps {
    margin-bottom: 0.5rem;
  }

  .chap {
    display: block;
    @include border(--bd-main, $loc: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
    }
  }

  // prettier-ignore
  .chap-title {
    flex: 1;
    margin-right: 0.125rem;
    @include fgcolor(secd);
    @include clamp($width: null);

    .chap:visited & { @include fgcolor(neutral, 5); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  .chap-meta {
    @include flex($gap: 0.25rem);
    padding: 0;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;

    @include ftsize(xs);
    @include fgcolor(neutral, 5);
  }

  .chap-chidx {
    @include fgcolor(tert);
    @include ftsize(xs);
  }

  .chap-state {
    @include fgcolor(tert);
    position: relative;
    font-size: 1rem;
    margin-top: -0.125rem;
  }

  .chap-bname {
    flex: 1 1;
    @include clamp($width: null);
  }
</style>
