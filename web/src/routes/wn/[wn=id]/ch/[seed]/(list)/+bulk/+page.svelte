<script lang="ts">
  import { onMount } from 'svelte'
  import { goto, invalidateAll } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { opencc, fix_breaks } from '$utils/text_utils'

  import { SIcon, Footer } from '$gui'

  import * as split from './text_split'
  import type { Zchap } from './text_split'
  import { get_encoding } from './get_encoding'

  import type { PageData } from './$types'
  import { seed_path, _pgidx } from '$lib/kit_path'

  import SplitOpts, { Opts } from './SplitOpts.svelte'
  import ChapList from './ChapList.svelte'

  export let data: PageData
  $: ({ nvinfo, curr_seed, seed_data } = data)

  let input = ''
  let start = data.start
  let files: FileList
  let chaps: Zchap[] = []

  let opts = new Opts()
  let err_msg = ''

  $: {
    chaps = []
    try {
      err_msg = ''
      chaps = split_text(input, opts)
    } catch (ex) {
      console.log(ex)
      err_msg = ex
    }
  }

  const split_text = (input: string, options: Opts) => {
    input = input.replace(/\r?\n|\r/g, '\n')

    switch (options.split_mode) {
      case 1:
        let min_blanks = +options.min_blanks
        if (min_blanks < 1) min_blanks = 1
        return split.split_mode_1(input, min_blanks, options.trim_space)
      case 2:
        return split.split_mode_2(input, options.need_blank)
      case 3:
        return split.split_mode_3(input, options.chdiv_labels)
      case 4:
        return split.split_mode_4(input, options.custom_regex)
      default:
        return split.split_mode_0(input, 3)
    }
  }

  let _onload = false

  let reader: FileReader

  onMount(() => {
    reader = new FileReader()
    reader.onloadend = async () => {
      _onload = false
      const buffer = reader.result as ArrayBuffer
      const encoding = await get_encoding(buffer)
      const decoder = new TextDecoder(encoding)
      input = decoder.decode(buffer)
    }
  })

  $: if (files) {
    _onload = true
    reader.readAsArrayBuffer(files[0])
  }

  async function submit(_evt: Event) {
    err_msg = ''
    _onload = true

    const body = render_body(chaps)

    const url = `/_wn/texts/${nvinfo.id}/${curr_seed.sname}?start=${start}`
    const res = await fetch(url, { method: 'POST', body })
    _onload = false

    if (!res.ok) {
      err_msg = await res.text()
      console.log({ err_msg })
    } else {
      await invalidateAll()
      await goto(seed_path(nvinfo.bslug, curr_seed.sname, _pgidx(start)))
    }
  }

  function render_body(chaps: Zchap[]) {
    let body = ''

    for (let idx = 0; idx < chaps.length; idx++) {
      const { chdiv, title, lines } = chaps[idx]

      if (chdiv) body += chdiv + '\n\n'

      body += title
      for (const line of lines) {
        const clean_line = line.trim()
        if (clean_line) body += '\n' + clean_line
      }

      if (idx < chaps.length - 1) body += '\n\n'
    }

    return body
  }

  const trad2sim = async (_: Event) => {
    _onload = true
    input = await opencc(input, 'hk2s')
    _onload = false
  }

  const max_chars_allowed = [
    100_000, 500_000, 2_000_000, 5_000_000, 10_000_000, 20_000_000,
  ]

  $: _privi = $_user.privi
  $: max_chars = _privi < 0 ? 0 : max_chars_allowed[_privi]
  $: limit_exceed = input.length > max_chars
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.vtitle} - Chivi</title>
</svelte:head>

<section class="article">
  <h2>Thêm/sửa chương</h2>

  <div class="content">
    <section class="input">
      <div class="label">
        <span>Nội dung:</span>
        <em data-tip="Giới hạn số ký tự">{input.length}/{max_chars}</em>
      </div>

      <textarea
        class="m-input"
        class:_err={input.length > max_chars}
        name="input"
        rows="25"
        bind:value={input}
        disabled={_onload}
        placeholder="Nội dung chương tiết"
        required />
    </section>

    <section class="preview">
      <SplitOpts bind:opts {_onload} />
      <ChapList {chaps} {start} />
    </section>
  </div>

  {#if err_msg}<div class="form-msg _err">{err_msg}</div>{/if}

  <Footer>
    <footer class="footer">
      <div class="left">
        <div class="file-prompt">
          <label
            class="m-btn _primary"
            data-tip="Đăng tải nội dung chương tiết từ máy tính"
            data-tip-pos="left">
            <SIcon name="upload" />
            <span class="m-show-tm">Chọn tệp tin</span>
            <input type="file" bind:files accept=".txt" />
          </label>
        </div>

        <button
          type="button"
          class="m-btn _line"
          data-tip="Chuyển đổi từ phồn thể sang giản thể"
          on:click={trad2sim}>
          <SIcon name="language" />
          <span class="m-show-tl">Phồn 🠖 Giản</span>
        </button>

        <button
          type="button"
          class="m-btn _line"
          data-tip="Gộp các dòng bị vỡ thành các câu văn hoàn chỉnh."
          on:click={() => (input = fix_breaks(input))}>
          <SIcon name="bandage" />
          <span class="m-show-tl">Sửa vỡ dòng</span>
        </button>
      </div>

      <div class="right">
        <label class="label">
          <span data-tip="Vị trí bắt đầu ghi đè">Chương bắt đầu</span>
          <input
            class="m-input"
            type="number"
            name="start"
            bind:value={start} />
        </label>

        <button
          type="button"
          class="m-btn _primary _fill"
          disabled={_onload || _privi < seed_data.edit_privi || limit_exceed}
          data-tip="Bạn cần quyền hạn tối thiểu là {seed_data.edit_privi} để thêm chương"
          data-tip-pos="right"
          on:click={submit}>
          <SIcon name={_onload ? 'loader-2' : 'send'} spin={_onload} />
          <span class="m-show-ts -text">Đăng tải</span>
          <SIcon name="privi-{seed_data.edit_privi}" iset="sprite" />
        </button>
      </div>
    </footer>
  </Footer>
</section>

<style lang="scss">
  h2 {
    // padding: 0.75rem 0;
    margin-top: var(--gutter);
    margin-bottom: 0.5rem;
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 20rem;
    flex: 1;
    @include ftsize(sm);
  }

  .preview {
    padding-left: 0.75rem;
    display: flex;
    flex-direction: column;
    // @include ftsize(sm);
    // font-style: italic;
    // @include fgcolor(tert);
    // margin-top: 0.25rem;

    // strong {
    //   @include fgcolor(secd);
    // }
  }

  .m-btn > input {
    display: none;
  }

  .file-prompt {
    display: flex;
  }

  .input {
    display: flex;
    flex-direction: column;
  }

  .content {
    display: flex;

    > * {
      width: 50%;
      max-height: 100vh;
    }
  }

  .footer {
    @include flex-cy($gap: 0.75rem);
    justify-content: space-between;
    margin: 0.75rem 0;
  }

  .left {
    @include flex-cy($gap: 0.5rem);
  }

  .right {
    @include flex-cy($gap: 0.5rem);

    .m-input {
      width: 3.5rem;
      text-align: center;
      padding: 0 0.25rem;
    }
  }

  .label {
    line-height: 2rem;
    display: flex;
    justify-content: space-between;
    gap: 0.5rem;
    font-size: rem(15px);
    @include fgcolor(tert);

    span {
      font-weight: 500;
    }
  }

  ._err {
    @include fgcolor(harmful);
    font-style: italic;
  }
</style>
