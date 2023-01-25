<script context="module" lang="ts">
  const split_modes = [
    [1, 'Phân bởi dòng trắng giữa chương'],
    [2, 'Nội dung thụt vào so với tên chương'],
    [3, 'Theo định dạng tên chương'],
    [4, 'Theo regular expression tự nhập'],
    [0, 'Phân thủ công bằng ///'],
  ]

  const numbers = '零〇一二两三四五六七八九十百千'

  function format_str(input: string) {
    return input.replace(/\r?\n|\r/g, '\n')
  }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import { goto } from '$app/navigation'

  import { SIcon, Footer } from '$gui'

  import * as split from './text_split'
  import type { Zchap } from './text_split'
  import { get_encoding } from './get_encoding'

  import type { PageData } from './$types'
  export let data: PageData
  $: ({ nvinfo } = data)

  let input = ''
  let chidx = data.chidx
  let files: FileList

  let chapters: Zchap[] = []

  let split_mode = 1

  let min_blanks = 2
  let trim_space = false
  let need_blank = false

  let chdiv_labels = '章节回幕折集卷季'
  let custom_regex = `^\\s*第?[\\d${numbers}]+[章节回]`

  $: {
    switch (split_mode) {
      case 1:
        chapters = split.split_mode_1(input, min_blanks, trim_space)
        break
      case 2:
        chapters = split.split_mode_2(input, need_blank)
        break
    }
  }

  $: _seed = data._curr._seed
  $: action_url = `/_wn/texts/${_seed.sname}/${_seed.snvid}`

  let loading = false
  let changed = false

  let err_msg = ''

  let reader: FileReader

  onMount(() => {
    reader = new FileReader()
    reader.onloadend = async () => {
      changed = loading = false
      const buffer = reader.result as ArrayBuffer
      const encoding = await get_encoding(buffer)
      const decoder = new TextDecoder(encoding)
      input = format_str(decoder.decode(buffer))
    }
  })

  $: if (files) {
    loading = true
    reader.readAsArrayBuffer(files[0])
  }

  async function submit(_evt: Event) {
    err_msg = ''

    const body = JSON.stringify({ chidx, chapters })
    const headers = { 'Content-Type': 'application/json' }
    const res = await fetch(action_url, { method: 'POST', body, headers })

    if (!res.ok) {
      err_msg = await res.text()
    } else {
      const { pg_no } = await res.json()
      goto(`/wn/${nvinfo.bslug}/chaps/${_seed.sname}?pg=${pg_no}`)
    }
  }
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<section class="article">
  <h2>Thêm/sửa chương</h2>

  <form action={action_url} method="POST" on:submit|preventDefault={submit}>
    <div class="form-field file-prompt">
      <label class="m-btn">
        <span>Chọn tệp tin</span>
        <input type="file" bind:files accept=".txt" />
      </label>
    </div>

    <div class="form-field">
      <textarea
        class="m-input"
        name="input"
        rows="10"
        bind:value={input}
        disabled={loading}
        placeholder="Nội dung chương tiết"
        required />
      <div class="preview">
        <span class="label">Số chương đại khái theo cách chia:</span>
        <strong>{chapters.length}</strong>
        <em>(chưa tính gộp tên tập)</em>
      </div>
      <p>Lưu ý: Chương chỉ có một dòng sẽ được coi là tên tập.</p>
    </div>

    <div class="form-field">
      <span class="label">Cách chia chương: </span>
      <select
        name="split_mode"
        class="m-input _sm"
        disabled={loading}
        bind:value={split_mode}
        on:change={() => (changed = true)}>
        {#each split_modes as [value, label]}
          <option {value}>{label}</option>
        {/each}
      </select>

      <a
        class="guide"
        href="/guide/chuong-tiet/them-loat-chuong"
        target="_blank">
        <span>Giải thích cách chia</span>
        <SIcon name="external-link" />
      </a>
    </div>

    <div class="split-extra">
      {#if split_mode == 1}
        <div class="options">
          <label class="label"
            >Số dòng trắng tối thiểu: <input
              class="m-input _xs"
              type="number"
              name="min_blanks"
              bind:value={min_blanks}
              min={1}
              max={4} /></label>

          <label class="label"
            ><input
              class="m-input"
              type="checkbox"
              name="trim_space"
              bind:checked={trim_space} /> Lọc bỏ dấu cách</label>
        </div>
      {:else if split_mode == 2}
        <label class="label"
          ><input
            class="m-input"
            type="checkbox"
            name="need_blank"
            bind:checked={need_blank} /> Phía trước phải là dòng trắng</label>
      {:else if split_mode == 3}
        <label class="label"
          >Đằng sau <code>第[số từ]+</code> là:
          <input
            class="m-input _xs"
            name="label"
            bind:value={chdiv_labels} /></label>
      {:else if split_mode == 4}
        <label class="label"
          >Custom regex:
          <input
            class="m-input _xs"
            name="regex"
            bind:value={custom_regex} /></label>
      {/if}
    </div>

    <div class="errors">{err_msg}</div>

    <div class="guide" />

    <!-- <div class="form-field">
      <div class="label">Lựa chọn nâng cao</div>
      <div class="options">
        <label class="label">
          <input type="checkbox" name="tosimp" bind:checked={form.tosimp} />
          <span>Chuyển từ Phồn -> Giản</span>
        </label>

        <label class="label">
          <input type="checkbox" name="unwrap" bind:checked={form.unwrap} />
          <span>Sửa lỗi vỡ dòng</span>
        </label>
      </div>
    </div> -->

    <Footer>
      <div class="pagi">
        <label class="label" data-tip="Vị trí bắt đầu ghi đè">
          <span>Chương bắt đầu</span>
          <input
            class="m-input"
            type="number"
            name="chidx"
            bind:value={chidx} />
        </label>

        <button type="submit" class="m-btn _primary _fill">
          <SIcon name="upload" />
          <span class="-text">Đăng tải</span>
          <SIcon
            name={input.length > 30000 ? 'privi-2' : 'privi-1'}
            iset="sprite" />
        </button>
      </div>
    </Footer>
  </form>
</section>

<style lang="scss">
  h2 {
    padding: 0.75rem 0;
  }

  textarea {
    display: block;
    width: 100%;
  }

  .preview {
    @include ftsize(sm);
    font-style: italic;
    @include fgcolor(tert);
    margin-top: 0.25rem;

    strong {
      @include fgcolor(secd);
    }
  }

  .m-btn > input {
    display: none;
  }

  .file-prompt {
    display: flex;
  }

  section {
    padding-bottom: 0.5rem;
  }

  select {
    padding: 0 0.25rem;
  }

  .options {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    align-items: center;
    padding: 0.25rem 0;

    label {
      @include fgcolor(secd);
    }
  }

  [name='min_blanks'] {
    width: 2rem;
    text-align: center;
  }

  // .split-descs {
  //   @include fgcolor(tert);
  //   @include ftsize(sm);
  //   margin-top: 0.25rem;

  //   summary {
  //     @include fgcolor(secd);
  //   }
  // }

  [name='regex'] {
    width: 20rem;
  }

  .split-extra {
    margin-top: 0.5rem;
  }

  .pagi {
    @include flex-cy($gap: 0.5rem);

    .m-input {
      display: inline-block;
      &[name='chidx'] {
        margin-left: 0.25rem;
        width: 3.5rem;
        text-align: center;
        padding: 0 0.25rem;
      }
    }

    .m-btn {
      margin-left: auto;
    }
  }

  .label {
    // text-transform: uppercase;
    font-weight: 500;
    font-size: rem(15px);
    // @include ftsize(sm);
    @include fgcolor(tert);
  }

  // summary {
  //   font-weight: 500;
  //   font-size: 1rem;
  // }

  // pre {
  //   font-size: rem(15px);
  //   line-height: 1.25rem;
  //   padding: 0.75rem;
  //   margin-top: 0.25rem;
  //   // word-wrap: break-word;
  //   white-space: break-spaces;
  // }

  .errors:not(:empty) {
    margin: 0.5rem;
    @include fgcolor(harmful, 5);
  }

  .guide {
    margin-left: 1rem;
    display: inline-block;
    @include fgcolor(warning, 5);
  }
</style>
