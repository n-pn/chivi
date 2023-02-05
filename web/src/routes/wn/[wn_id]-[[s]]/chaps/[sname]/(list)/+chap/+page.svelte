<script lang="ts">
  import { onMount } from 'svelte'
  import { goto, invalidateAll } from '$app/navigation'

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
  $: ({ nvinfo, curr_seed, seed_data, _user } = data)

  let input = ``
  let start = data.start

  let files: FileList

  let chaps: Zchap[] = []

  let opts = new Opts()
  let err_msg = ''

  $: {
    try {
      err_msg = ''
      chaps = split_text(input, opts)
    } catch (ex) {
      err_msg = ex.message
      chaps = []
    }
  }

  const split_text = (input: string, options: Opts) => {
    switch (options.split_mode) {
      case 1:
        return split.split_mode_1(input, options.min_blanks, options.trim_space)
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

  let loading = false

  let reader: FileReader

  onMount(() => {
    reader = new FileReader()
    reader.onloadend = async () => {
      loading = false
      const buffer = reader.result as ArrayBuffer
      const encoding = await get_encoding(buffer)
      const decoder = new TextDecoder(encoding)
      input = decoder.decode(buffer).replace(/\r?\n|\r/g, '\n')
    }
  })

  $: if (files) {
    loading = true
    reader.readAsArrayBuffer(files[0])
  }

  async function submit(_evt: Event) {
    err_msg = ''

    const url = `/_wn/texts/${nvinfo.id}/${curr_seed.sname}?start=${start}`
    const body = render_body(chaps)
    const res = await fetch(url, { method: 'POST', body })

    if (!res.ok) {
      err_msg = await res.text()
    } else {
      await invalidateAll()
      goto(seed_path(nvinfo.bslug, curr_seed.sname, _pgidx(start)))
    }
  }

  function render_body(chaps: Zchap[]) {
    let text = ''
    for (const { title, chdiv, lines } of chaps) {
      text += `///${chdiv}\n${title}`
      for (const line of lines) text += '\n' + line
      text += '\n'
    }
    return text
  }

  const trad2sim = async (_: Event) => (input = await opencc(input))

  const max_lenth_allowed = [0, 300_000, 1_000_000, 5_000_000, 10_000_000]

  $: max_lenth = _user.privi < 0 ? 0 : max_lenth_allowed[_user.privi]

  $: cant_submit =
    _user.privi < seed_data.edit_privi || input.length > max_lenth
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<section class="article">
  <h2>Thêm/sửa chương</h2>

  <div class="content">
    <section class="input">
      <div class="label">
        <span>Nội dung:</span>
        <em data-tip="Giới hạn số ký tự">{input.length}/{max_lenth}</em>
      </div>

      <textarea
        class="m-input"
        name="input"
        rows="25"
        bind:value={input}
        disabled={loading}
        placeholder="Nội dung chương tiết"
        required />
    </section>

    <section class="preview">
      <SplitOpts bind:opts {loading} />
      <ChapList {chaps} {start} {err_msg} />
    </section>
  </div>

  <footer class="footer">
    <div class="left">
      <div class="file-prompt">
        <label
          class="m-btn _primary"
          data-tip="Đăng tải nội dung chương tiết từ máy tính"
          data-tip-pos="left">
          <SIcon name="upload" />
          <span class="show-tm">Chọn tệp tin</span>
          <input type="file" bind:files accept=".txt" />
        </label>
      </div>

      <button
        type="button"
        class="m-btn _line"
        data-tip="Chuyển đổi từ phồn thể sang giản thể"
        on:click={trad2sim}>
        <SIcon name="language" />
        <span class="show-tl">Phồn 🠖 Giản</span>
      </button>

      <button
        type="button"
        class="m-btn _line"
        data-tip="Gộp các dòng bị vỡ thành các câu văn hoàn chỉnh."
        on:click={() => (input = fix_breaks(input))}>
        <SIcon name="bandage" />
        <span class="show-tl">Sửa vỡ dòng</span>
      </button>
    </div>

    <div class="right">
      <label class="label">
        <span data-tip="Vị trí bắt đầu ghi đè">Chương bắt đầu</span>
        <input class="m-input" type="number" name="start" bind:value={start} />
      </label>

      <button
        type="button"
        class="m-btn _primary _fill"
        disabled={cant_submit}
        data-tip="Bạn cần quyền hạn tối thiểu là {seed_data.edit_privi} để thêm chương"
        data-tip-pos="right"
        on:click={submit}>
        <SIcon name="upload" />
        <span class="show-ts -text">Đăng tải</span>
        <SIcon name="privi-{seed_data.edit_privi}" iset="sprite" />
      </button>
    </div>
  </footer>
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

  .count {
    @include fgcolor(tert);
    font-size: rem(15px);
  }

  .show-ts {
    @include bps(display, none, $ts: initial);
  }

  .show-tm {
    @include bps(display, none, $tm: initial);
  }

  .show-tl {
    @include bps(display, none, $tl: initial);
  }

  .err_msg {
    @include flex-ca();
    min-height: 10rem;
    font-style: italic;
    @include fgcolor(harmful);
  }
</style>
