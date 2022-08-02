<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy, onMount } from 'svelte'

  const suggest_maps = {
    '的': [
      ['的', '地'],
      ['的', '得'],
    ],
    '地': [
      ['地', '的'],
      ['地', '得'],
    ],
    '得': [
      ['得', '的'],
      ['得', '地'],
    ],
    '"': [
      ['"', '“'],
      ['"', '”'],
    ],
    '＂': [
      ['"', '“'],
      ['"', '”'],
    ],
    '”': [['”', '“']],
    '“': [['“', '”']],
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'
  import { page } from '$app/stores'

  export let fix_raw = false

  export let rawtxt = ''
  export let lineid = 0

  export let dname = 'combine'
  export let caret = 0

  export let on_fixraw = (_n: number, _s: string, _s2: string) => {}
  export let on_destroy = () => {}

  onDestroy(() => {
    document.removeEventListener('selectionchange', change_focus)
    on_destroy()
  })

  onMount(() => document.addEventListener('selectionchange', change_focus))

  let oldraw = rawtxt
  let underlay: HTMLElement
  let on_focus: HTMLElement
  let overlay: HTMLElement

  let hanviet = ''
  let convert = ''
  let suggests = []
  let preview_mode = 0

  $: update_preview(rawtxt)

  $: if (underlay && rawtxt) on_update_caret()

  function render_rawtxt(input: String) {
    return Array.from(input)
      .map((x, i) => `<x-c i=${i}>${x}</x-c>`)
      .join('')
  }

  function change_focus() {
    const range = window.getSelection().getRangeAt(0)
    caret = range.endOffset
    on_update_caret()
  }

  function update_rawtxt(e: Event) {
    rawtxt = (<HTMLElement>e.target).innerText
  }

  async function update_preview(input: string) {
    const api_url = `/api/qtran/mterror?caps=t`
    const params = { input, dname }

    const res = await $page.stuff.api.call(api_url, 'PUT', params)
    if (res.error) alert(res.error)
    else {
      const lines = res.split('\n')
      convert = lines[0]
      hanviet = lines[1]
    }
  }

  function save_change() {
    if (rawtxt != oldraw) on_fixraw(lineid, oldraw, rawtxt)
    fix_raw = false
  }

  function replace_text(from: string, to: string) {
    const pre = rawtxt.substring(0, caret)
    const suf = rawtxt.substring(caret + from.length)
    rawtxt = pre + to + suf

    setTimeout(() => {
      const selection = window.getSelection()
      const startNode = overlay.firstChild
      selection.collapse(startNode, caret)
    }, 20)
  }

  function on_update_caret(new_focus?: HTMLElement) {
    if (on_focus) on_focus.classList.remove('active')
    suggests = suggest_maps[rawtxt[caret]] || []

    if (new_focus) {
      on_focus = new_focus
      on_focus.classList.add('active')
    } else {
      on_focus = underlay && underlay.querySelector(`[i="${caret}"]`)
      if (on_focus) on_focus.classList.add('active')
    }
  }
</script>

<Dialog
  actived={fix_raw}
  on_close={() => (fix_raw = false)}
  class="fixraw"
  _size="lg">
  <header slot="header">Sửa text gốc</header>

  <div class="body">
    <section class="suggest">
      <span class="label">Text gốc:</span>

      <div class="suggests">
        {#each suggests as [from, to]}
          <button class="suggest-btn" on:click={() => replace_text(from, to)}
            >{from}<span class="mute"><SIcon name="chevron-right" /></span
            >{to}</button>
        {:else}
          <div class="no-suggest">Không có gợi ý sửa từ</div>
        {/each}
      </div>
    </section>

    <section class="rawtxt m-input ">
      <div class="underlay" bind:this={underlay}>
        {@html render_rawtxt(rawtxt)}
      </div>

      <div
        class="overlay"
        bind:this={overlay}
        on:input={update_rawtxt}
        contenteditable="true">
        {rawtxt}
      </div>
    </section>

    <section class="preview">
      <div class="preview-modes">
        <span class="label">Xem trước:</span>

        <label>
          <input type="radio" bind:group={preview_mode} value={0} />
          <span>Dịch máy</span>
        </label>

        <label>
          <input type="radio" bind:group={preview_mode} value={1} />
          <span>Hán việt</span>
        </label>

        <label>
          <input type="radio" bind:group={preview_mode} value={2} />
          <span>Cả hai</span>
        </label>

        <label>
          <input type="radio" bind:group={preview_mode} value={3} />
          <span>Không xem</span>
        </label>
      </div>

      {#if preview_mode == 0 || preview_mode == 2}
        <div class="convert">{convert}</div>
      {/if}
      {#if preview_mode == 1 || preview_mode == 2}
        <div class="hanviet">{hanviet}</div>
      {/if}
    </section>
  </div>

  <footer>
    <button class="m-btn" data-kbd="r" on:click={() => (rawtxt = oldraw)}>
      <span>Phục hồi</span>
      <SIcon name="arrow-back-up" />
    </button>

    <button
      class="m-btn _primary _fill"
      on:click={save_change}
      disabled={oldraw == rawtxt}>
      <span>Lưu thay đổi</span>
      <SIcon name="send" />
    </button>
  </footer>
</Dialog>

<style lang="scss">
  .rawtxt {
    position: relative;
    padding: 0;
  }

  .overlay,
  .underlay {
    padding: 0.25rem 0.5rem;
  }

  .overlay {
    position: relative;
    color: transparent;
    caret-color: color(primary, 5);
    background: transparent;
  }

  .underlay {
    position: absolute;
    // top: 0;
    // left: 0;

    // bottom: 0;
    // right: 0;
    // user-select: none;

    :global(x-c.active) {
      font-weight: 500;
      @include fgcolor(primary, 5);
    }
  }
  // div.m-input {
  //   display: flex;
  //   flex-wrap: wrap;
  // }

  .body {
    padding: 0.75rem;
    padding-top: 0.5rem;
  }

  .suggest {
    display: flex;
    align-items: center;
    height: 1.5rem;
    margin-bottom: 0.25rem;
  }

  .suggests {
    margin-left: auto;
  }

  .suggest,
  .preview {
    font-size: rem(15px);
    @include fgcolor(tert);
  }

  .no-suggest {
    font-style: italic;
    @include fgcolor(mute);
  }

  footer {
    @include flex();
    padding-bottom: 0.75rem;
    gap: 0.75rem;
    justify-content: center;
  }

  .suggest-btn {
    background: none;
    font-size: rem(14px);

    @include fgcolor(main);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  .mute {
    @include fgcolor(mute);
  }

  .label {
    font-weight: 500;
  }
  .preview {
    margin-top: 0.5rem;
  }

  .hanviet,
  .convert {
    @include border();
    @include bdradi();
    padding: 0.25rem 0.75rem;
    margin-top: 0.25rem;
    line-height: 1.25rem;
    font-weight: 400;
    font-size: rem(14px);
    @include fgcolor(tert);
    @include bgcolor(tert);
  }
</style>
