<script lang="ts">
  import { browser } from '$app/environment'
  import { goto, invalidateAll } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { chap_path } from '$lib/kit_path'
  import { debounce, sync_scroll } from '$lib/svelte'

  import { SIcon, Footer } from '$gui'
  import { opencc, diff_html, fix_breaks, translate } from '$utils/text_utils'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = data.ztext
  let title = data.title
  let chdiv = data.chdiv
  let ch_no = data.ch_no

  $: ({ nvinfo } = data)
  $: disabled = $_user.privi < 1 || ($_user.privi == 1 && ztext.length > 30000)

  $: action_url = `/_wn/texts/${data.wn_id}/${data.sname}/${ch_no}`

  async function submit(event: Event) {
    event.preventDefault()

    const headers = { 'Content-Type': 'application/json' }
    const body = JSON.stringify({ chdiv, title, ztext })

    const res = await fetch(action_url, { method: 'PUT', headers, body })

    if (res.ok) {
      await invalidateAll()
      goto(chap_path(nvinfo.bslug, data.sname, ch_no))
    } else {
      alert(await res.text())
    }
  }

  const trad2sim = async (_: Event) => (ztext = await opencc(ztext))

  let old_vtext: string = ''
  let new_vtext: string = ''
  let html_diff: string = ''

  const compare = debounce(async (ztext: string) => {
    old_vtext ||= await translate(data.ztext, data.wn_id)
    new_vtext = await translate(ztext, data.wn_id)
    html_diff = diff_html(old_vtext, new_vtext, true)
  }, 300)

  $: if (browser) compare(ztext)

  let edit_elem: HTMLElement
  let view_elem: HTMLElement

  const revert_changes = () => {
    ztext = data.ztext
    chdiv = data.chdiv
    title = data.title
  }
</script>

<nav class="bread">
  <a href="/wn/{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.vtitle}</span>
  </a>
  <span>/</span>
  <a href="/wn/{nvinfo.bslug}/-union" class="crumb _link">Chương tiết</a>
</nav>

<section class="article">
  <h2>Sửa text chương #{ch_no}</h2>

  <form action={action_url} method="POST" on:submit={submit}>
    <div class="form-group _fluid">
      <span class="form-field _title">
        <label class="label" for="title">Tên chương tiết</label>
        <input class="m-input" name="title" lang="zh" bind:value={title} />
      </span>

      <span class="sub-group">
        <span class="form-field _chdiv">
          <label class="label" for="chdiv">Tên tập truyện</label>
          <input
            class="m-input"
            name="chdiv"
            lang="zh"
            bind:value={chdiv}
            placeholder="Có thể để trắng" />
        </span>

        <span class="form-field _ch_no">
          <label class="label" for="ch_no">Vị trí chương</label>
          <input class="m-input" name="ch_no" bind:value={ch_no} />
        </span>
      </span>
    </div>

    <div class="content">
      <div class="edit">
        <label class="label" for="ztext">Nội dung chương</label>
        <textarea
          class="m-input"
          name="text"
          lang="zh"
          bind:value={ztext}
          bind:this={edit_elem}
          on:scroll={() => sync_scroll(edit_elem, view_elem)} />
      </div>

      <div class="view">
        <span class="label">Xem trước</span>
        <div
          class="output"
          bind:this={view_elem}
          on:scroll={() => sync_scroll(view_elem, edit_elem)}>
          {@html html_diff}
        </div>
      </div>
    </div>

    <Footer>
      <div class="actions">
        <button type="button" class="m-btn _line" on:click={revert_changes}>
          <SIcon name="arrow-back-up" />
          <span class="hide">Phục hồi</span>
        </button>

        <button type="button" class="m-btn _line" on:click={trad2sim}>
          <SIcon name="language" />
          <span class="hide">Phồn 🠖 Giản</span>
        </button>

        <button
          type="button"
          class="m-btn _line"
          on:click={() => (ztext = fix_breaks(ztext))}>
          <SIcon name="bandage" />
          <span class="hide">Sửa vỡ dòng</span>
        </button>

        <div class="right">
          <button type="submit" class="m-btn _primary _fill" {disabled}>
            <SIcon name="upload" />
            <span class="-text">Đăng tải</span>
            <SIcon name="privi-1" iset="sprite" />
          </button>
        </div>
      </div>
    </Footer>
  </form>
</section>

<style lang="scss">
  h2 {
    padding: 0.75rem 0;
  }

  section {
    padding-bottom: 0.5rem;
  }

  .actions {
    @include flex-cy($gap: 0.5rem);
    > .right {
      margin-left: auto;
    }
  }

  .label {
    display: block;
    // text-transform: uppercase;
    font-weight: 500;
    @include ftsize(sm);
    @include fgcolor(tert);
    // margin-bottom: 0.25rem;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;

    flex-direction: column;

    @include bp-min(tm) {
      flex-direction: row;
    }

    label {
      position: absolute;
      bottom: 100%;
      left: 0;
    }

    input {
      width: 100%;
    }
  }

  .sub-group {
    display: flex;
    gap: 0.75rem;

    @include bp-min(tm) {
      width: 40%;
    }
  }

  .form-field {
    flex: 1;
    gap: 0.5rem;
    position: relative;

    &._ch_no {
      max-width: 25%;
      min-width: 6rem;
    }

    // @include bp-min(ts) {
    //   &:first-of-type {
    //     width: 50%;
    //   }

    //   &:last-of-type {
    //     width: 15%;
    //   }
    // }
  }

  .content {
    display: flex;
    margin-top: 0.75rem;

    height: calc(100vh - 15rem);
    min-height: 25rem;
    margin-bottom: 0.25rem;

    .edit,
    .view {
      flex: 1;
      height: 100%;
      display: flex;
      flex-direction: column;
    }
  }

  // .preview span {
  //   padding-left: 0.75rem;
  // }

  @mixin thin-scrollbar() {
    scrollbar-width: thin;
    &::-webkit-scrollbar {
      cursor: pointer;
      width: 8px;
    }
  }

  textarea {
    width: 100%;
    flex: 1;
    padding: 0.75rem;

    @include bdradi(0, $loc: right);
    @include thin-scrollbar();
  }

  .output {
    flex: 1;
    padding: 0.75rem 0.75rem;
    white-space: pre-wrap;

    @include border;
    border-left: none;
    overflow: scroll;

    @include bdradi($loc: right);
    @include thin-scrollbar();

    :global(ins) {
      @include fgcolor(success, 5);
    }

    :global(del) {
      @include fgcolor(harmful, 5);
    }
  }
</style>
