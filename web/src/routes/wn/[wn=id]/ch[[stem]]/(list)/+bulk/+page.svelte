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
  import ChapsView from './ChapsView.svelte'

  export let data: PageData
  $: ({ nvinfo, curr_seed, seed_data } = data)
  $: min_privi = seed_data.edit_privi

  let chdiv = data.chdiv || ''
  let start = data.start

  let input = ''
  let pg_no = 1

  let files: FileList
  let chaps: Zchap[] = []

  let opts = new Opts()
  let err_msg = ''

  $: if (input) {
    console.log(`parsing input: ${input.length}`)
    chaps = []
    err_msg = ''

    try {
      chaps = split_text(input, opts)
    } catch (ex) {
      err_msg = ex.toString()
      console.log(ex)
    }
  }

  $: if (start) {
    console.log(`update start offset: ${start}`)
    for (let i = 0; i < chaps.length; i++) chaps[i].ch_no = start + i
  }

  $: if (chdiv) {
    console.log(`update initial division: ${chdiv}`)
    for (const chap of chaps) chap.chdiv ||= chdiv
  }

  const split_text = (input: string, options: Opts) => {
    input = input.replace(/\r?\n|\r/g, '\n')

    switch (options.split_mode) {
      case 1:
        let min_blanks = +options.min_blanks
        if (min_blanks < 1) min_blanks = 1
        let trim_space = options.trim_space

        return split.split_mode_1(input, min_blanks, trim_space, chdiv, start)
      case 2:
        return split.split_mode_2(input, options.need_blank, chdiv, start)
      case 3:
        return split.split_mode_3(input, options.chdiv_labels, chdiv, start)
      case 4:
        return split.split_mode_4(input, options.custom_regex, chdiv, start)
      default:
        return split.split_mode_0(input, 3, chdiv, start)
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

    for (let index = 0; index < chaps.length; index += 32) {
      const page = chaps.slice(index, index + 32)

      pg_no = index / 32 + 1
      err_msg = await submit_part(page)
      if (err_msg) break
    }

    _onload = false

    if (err_msg) {
      alert(err_msg)
    } else {
      await invalidateAll()
      await goto(seed_path(nvinfo.bslug, curr_seed.sname, _pgidx(start)))
    }
  }

  async function submit_part(chaps: Zchap[]) {
    const url = `/_wn/texts/${nvinfo.id}/${curr_seed.sname}`
    const headers = { 'Content-type': 'application/json' }
    const body = JSON.stringify(chaps)
    const res = await fetch(url, { headers, method: 'POST', body })

    if (res.ok) return ''
    else return await res.text()
  }

  const trad2sim = async (_: Event) => {
    _onload = true
    input = await opencc(input, 'hk2s')
    _onload = false
  }
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
        <em data-tip="Tổng số ký tự">{input.length}</em>
      </div>

      <textarea
        class="m-input"
        name="input"
        rows="25"
        bind:value={input}
        disabled={_onload}
        placeholder="Nội dung chương tiết"
        required />
    </section>

    <section class="preview">
      <SplitOpts {_onload} bind:opts />
      <ChapsView {chaps} bind:pg_no />
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
          disabled={_onload || $_user.privi < min_privi}
          data-tip="Bạn cần quyền hạn tối thiểu là {min_privi} để thêm chương"
          data-tip-pos="right"
          on:click={submit}>
          <SIcon name={_onload ? 'loader-2' : 'send'} spin={_onload} />
          <span class="m-show-ts -text">Đăng tải</span>
          <SIcon name="privi-{min_privi}" iset="extra" />
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
