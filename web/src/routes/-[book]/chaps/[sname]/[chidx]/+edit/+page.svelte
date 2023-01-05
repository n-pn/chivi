<script lang="ts">
  import { browser } from '$app/environment'
  import { goto } from '$app/navigation'
  import { page } from '$app/stores'

  import { session } from '$lib/stores'
  import { debounce } from '$lib/svelte'

  import { SIcon, Footer } from '$gui'

  import { opencc, diff_html, fix_breaks, translate } from '$utils/text_utils'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, sname } = $page.data)

  let chidx = data.chidx
  let chvol = data.chvol
  let title = data.title
  let input = data.input

  $: privi = $session.privi || -1
  $: disabled = privi < 1 || (privi == 1 && input.length > 30000)

  $: action_url = `/api/texts/${nvinfo.id}/${sname}/${chidx}`

  async function submit(event: Event) {
    event.preventDefault()

    const res = await fetch(action_url, { method: 'PUT', body: input })

    if (res.ok) {
      await res.json()
      goto(`/-${nvinfo.bslug}/chaps/${sname}/${chidx}`)
    } else {
      alert(await res.text())
    }
  }

  const trad2sim = async (_: Event) => (input = await opencc(input))

  let vtext: string = ''
  let vhtml: string = diff_html(data.vtext, data.vtext, false)

  const compare = debounce(async (input: string) => {
    data.vtext ||= await translate(data.input, data.dname)
    vtext = await translate(input, data.dname)
    vhtml = diff_html(data.vtext, vtext, true)
  }, 300)

  $: if (browser) compare(input)

  let edit_elem: HTMLElement
  let view_elem: HTMLElement

  function sync_scroll(source: HTMLElement, target: HTMLElement) {
    if (!source || !target) return

    const source_height = source.scrollHeight
    const target_height = target.scrollHeight

    const target_scrollTop = (source.scrollTop / source_height) * target_height

    const _event = target.onscroll
    target.onscroll = null
    target.scrollTop = Math.round(target_scrollTop)
    target.onscroll = _event
  }
</script>

<svelte:head>
  <title>Sửa text gốc chương #{chidx} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <a href="/-{nvinfo.bslug}/-union" class="crumb _link">Chương tiết</a>
</nav>

<section class="article">
  <h2>Sửa text chương #{chidx}</h2>

  <form action={action_url} method="POST" on:submit={submit}>
    <div class="form-group _fluid">
      <span class="form-field">
        <label class="label" for="chvol">Tên tập truyện</label>
        <input
          class="m-input"
          name="chvol"
          lang="zh"
          bind:value={chvol}
          placeholder="Có thể để trắng" />
      </span>

      <span class="form-field">
        <label class="label" for="title">Tên chương tiết</label>
        <input class="m-input" name="title" lang="zh" bind:value={title} />
      </span>

      <span class="form-field _chidx">
        <label class="label" for="chidx">Vị trí chương</label>
        <input class="m-input" name="chidx" bind:value={chidx} />
      </span>
    </div>

    <div class="content">
      <div class="edit">
        <label class="label" for="input">Nội dung chương</label>
        <textarea
          class="m-input"
          name="text"
          lang="zh"
          bind:value={input}
          bind:this={edit_elem}
          on:scroll={() => sync_scroll(edit_elem, view_elem)} />
      </div>

      <div class="view">
        <span class="label">Xem trước</span>
        <div
          class="output"
          bind:this={view_elem}
          on:scroll={() => sync_scroll(view_elem, edit_elem)}>
          {@html vhtml}
        </div>
      </div>
    </div>

    <Footer>
      <div class="actions">
        <button
          type="button"
          class="m-btn _line"
          on:click={() => (input = data.input)}>
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
          on:click={() => (input = fix_breaks(input))}>
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

    > .form-field {
      width: 100%;
    }

    @include bp-min(ts) {
      flex-direction: row;
    }

    > .form-field {
      display: flex;
      gap: 0.5rem;
      position: relative;
      align-items: center;

      @include bp-min(ts) {
        &:first-child {
          width: 45%;
        }

        &:last-child {
          width: 25%;
        }
      }
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

  .content {
    display: flex;
    margin-top: 0.75rem;

    height: calc(100vh - 10rem);
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

  textarea {
    display: block;
    width: 100%;
    flex: 1;

    @include bdradi(0, $loc: right);

    padding: 0.75rem;
    font-size: rem(16px);
  }

  .output {
    flex: 1;
    padding: 0.75rem 0.75rem;
    white-space: pre-wrap;

    @include border;
    border-left: none;
    @include bdradi($loc: right);

    overflow: scroll;

    :global(ins) {
      @include fgcolor(success, 5);
    }

    :global(del) {
      @include fgcolor(harmful, 5);
    }
  }
</style>
