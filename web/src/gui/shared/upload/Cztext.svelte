<script lang="ts" context="module">
  const get_encoding = async (body: ArrayBuffer) => {
    const opts = {
      body,
      method: 'POST',
      headers: { 'content-type': 'text/plain' },
    }
    return await fetch('/_sp/chardet', opts).then((r) => r.text())
  }
</script>

<script lang="ts">
  import { SIcon } from '$gui'
  import { copy_to_clipboard } from '$utils/btn_utils'
  import { opencc, fix_breaks, trim_spaces } from '$utils/text_utils'
  import { onMount } from 'svelte'

  export let ztext = ''
  export let state = 1

  let history = {
    items: [ztext],
    h_idx: 0,
    get text() {
      return this.item[this.h_idx]
    },

    get has_prev() {
      return this.h_idx > 0
    },

    undo() {
      if (this.has_prev) this.h_idx -= 1
      return this.text
    },

    get has_next() {
      return this.h_idx < this.items.size
    },

    redo() {
      if (this.has_next) this.h_idx += 1
      return this.text
    },

    push(text: string) {
      this.items.push(text)
      this.h_idx += 1
    },

    apply(fn: (text: string) => string) {
      this.push(fn(this.text))
      return this.text
    },

    async apply_async(fn: (text: string) => Promise<string>) {
      this.push(await fn(this.text))
      return this.text
    },
  }

  let reader: FileReader
  let encoding = 'UTF-8'

  onMount(() => {
    reader = new FileReader()

    reader.onloadend = async () => {
      const buffer = reader.result as ArrayBuffer

      encoding = await get_encoding(buffer.slice(0, 1000))
      const decoder = new TextDecoder(encoding)

      ztext = decoder.decode(buffer)
      history.push(ztext)
      state = 0
    }
  })

  let files: FileList
  $: if (files) {
    state = 1
    reader.readAsArrayBuffer(files[0])
    state = 0
  }

  function apply(fn: (text: string) => string) {
    state = 1
    ztext = fn(ztext)
    state = 0
  }

  async function apply_async(fn: (text: string) => Promise<string>) {
    state = 1
    ztext = await fn(ztext)
    state = 0
  }
</script>

<div class="ztext m-input">
  {#if state == 1}
    <div class="onload">
      <div class="loader"><SIcon name="loader-2" spin={true} /></div>
    </div>
  {/if}

  <header>
    <label
      class="m-btn _xs _warning picker"
      data-tip="Đăng tải nội dung chương tiết từ máy tính"
      data-tip-pos="left">
      <SIcon name="upload" />
      <span class="-txt">Chọn tập tin</span>
      <input type="file" bind:files accept=".txt" />
    </label>

    <div class="v-field">
      <span class="u-show-tm">Mã ký tự:</span>
      <span>{encoding}</span>
    </div>

    <div class="u-right v-field">
      <span>{ztext.length}</span>
      <span class="u-show-pl">chữ</span>
    </div>
  </header>

  <textarea
    name="text"
    lang="zh"
    bind:value={ztext}
    disabled={state > 0}
    on:change={() => history.push(ztext)} />

  <footer>
    <button
      type="button"
      class="m-btn _sm"
      data-tip="Xóa hết khoảng trắng thừa"
      disabled={state > 0 || !ztext}
      on:click={() => apply(trim_spaces)}>
      <SIcon name="clear-all" />
    </button>

    <button
      type="button"
      class="m-btn _sm"
      data-tip="Chuyển đổi từ Phồn thể sang Giản thể"
      disabled={state > 0 || !ztext}
      on:click={() => apply_async(opencc)}>
      <SIcon name="bolt" />
    </button>

    <button
      type="button"
      class="m-btn _sm"
      data-tip="Gộp câu văn bị tách ra nhiều dòng"
      disabled={state > 0 || !ztext}
      on:click={() => apply(fix_breaks)}>
      <SIcon name="bandage" />
    </button>

    <button
      type="button"
      class="m-btn _sm u-right"
      data-tip="Xóa sạch"
      disabled={state > 0 || !ztext}
      on:click={() => (ztext = '')}>
      <SIcon name="eraser" />
    </button>
    <!--
    <button
      type="button"
      class="m-btn _sm"
      data-tip="Hoàn tác (Undo)"
      disabled={state > 0 || !history.has_prev}
      on:click={() => (ztext = history.undo())}>
      <SIcon name="arrow-back-up" />
    </button>

    <button
      type="button"
      class="m-btn _sm"
      data-tip="Làm lại (Redo)"
      disabled={state > 0 || !history.has_next}
      on:click={() => (ztext = history.redo())}>
      <SIcon name="arrow-forward-up" />
    </button> -->

    <button
      type="button"
      class="m-btn _sm"
      data-tip="Sao chép"
      disabled={state > 0 || !ztext}
      on:click={() => copy_to_clipboard(ztext)}>
      <SIcon name="copy" />
    </button>
  </footer>
</div>

<style lang="scss">
  .ztext {
    position: relative;
    @include flex;
    flex-direction: column;
    padding: 0;
    @include border;
    @include bdradi;
    &:focus-within {
      border-color: color(primary, 5);
    }
  }

  .picker {
    // @include flex-ca;
    input {
      display: none;
    }
  }

  header {
    @include flex-cy($gap: 0.5rem);
    padding: 0.25rem 0.5rem;
    @include border($loc: bottom);

    div,
    label {
      @include flex-cy($gap: 0.25rem);
    }

    label {
      cursor: pointer;
    }
  }

  textarea {
    width: 100%;
    flex: 1;
    padding: 0.75rem;
    border: 0;
    border-radius: 0;
    box-shadow: none;
    overflow-y: scroll;
    min-height: 60vh;
    line-height: 1.5rem;
    outline: 0;
    padding: 0.375rem 0.75rem;
    @include bgcolor(main);
    @include fgcolor(main);
  }

  footer {
    @include flex-cy($gap: 0.25rem);
    padding: 0 0.5rem;
    @include border($loc: top);

    .m-btn {
      box-shadow: none;
      background: inherit;
    }
  }

  .onload {
    @include flex-ca;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    @include bgcolor(neutral, 5, 1);
  }
</style>
