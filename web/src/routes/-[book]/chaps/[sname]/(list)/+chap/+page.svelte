<script context="module" lang="ts">
  import { hash_str } from '$utils/text_utils'

  const split_modes = [
    'Phân thủ công bằng ///',
    'Phân bởi dòng trắng giữa chương',
    'Nội dung thụt vào so với tên chương',
    'Theo định dạng tên chương',
    'Theo regular expression tự nhập',
  ]

  const numbers = '零〇一二两三四五六七八九十百千'

  function format_str(input: string) {
    return input.replace(/\r?\n|\r/g, '\n')
  }

  function build_split_regex(split_mode: number, opts: any) {
    switch (split_mode) {
      case 0:
        return /^\/{3,}/mu

      case 1:
        return new RegExp(`\\n{${opts.min_blanks + 1},}`, 'mu')

      case 2:
        const count = opts.need_blank ? 2 : 1
        return new RegExp(`\\n{${count},}[^\\s]`, 'mu')

      case 3:
        return new RegExp(`^\\s*第[\\d${numbers}]+[${opts.label}]`, 'mu')

      case 4:
        return new RegExp(opts.regex, 'mu')

      default:
        return /\\n{3,}/mu
    }
  }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import { goto } from '$app/navigation'

  import { SIcon, Footer } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  let nvseed: CV.Chroot
  $: ({ nvinfo, nvseed } = data)

  let input = ''
  let chidx = data.chidx
  let files: FileList

  let file_hash = ''

  let form = {
    tosimp: false,
    unwrap: false,
    split_mode: 1,
    trunc_after: false,
  }

  let opts = {
    min_blanks: 2,
    trim_space: false,
    need_blank: false,
    label: '章节回幕折集卷季',
    regex: `^\\s*第?[\\d${numbers}]+[章节回]`,
  }

  $: action_url = `/_db/texts/${nvinfo.id}/${nvseed.sname}`

  let loading = false
  let changed = false

  let err_msg = ''

  let reader: FileReader

  $: if (files) {
    loading = true
    reader.readAsArrayBuffer(files[0])
  }

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

  const get_encoding = async (buffer: ArrayBuffer) => {
    const headers = { 'content-type': 'text/plain' }

    const opts = { method: 'POST', body: buffer.slice(0, 200), headers }
    const res = await fetch('/_sp/chardet', opts)

    const res_data = await res.text()
    if (res.ok) return res_data

    console.log('error', res_data)
    return 'UTF-8'
  }

  $: chap_count = dry_check(input, form.split_mode, opts)

  function dry_check(input: string, mode: number, opts: any) {
    if (loading || !input) return 0
    err_msg = ''

    if (changed) {
      input = format_str(input)
      changed = false
    }

    let data = input

    if (mode == 1 && opts.trim_space) {
      data = data.replace(/[\u3000 ]+/gu, '')
    }

    try {
      const regex = build_split_regex(mode, opts)
      return data.split(regex).length
    } catch (err) {
      err_msg = err.toString()
      return 0
    }
  }

  async function submit(_evt: Event) {
    const body = new FormData()
    err_msg = ''

    const text_hash = hash_str(input)
    body.append('hash', text_hash)

    body.append('chidx', chidx.toString())
    body.append('encoding', 'UTF-8')

    if (text_hash != file_hash) {
      file_hash = text_hash
      body.append('file', new Blob([input], { type: 'text/plain' }))
    }

    for (const key in form) body.append(key, form[key].toString())
    for (const key in opts) body.append(key, opts[key].toString())

    const res = await fetch(action_url, { method: 'PUT', body })

    if (!res.ok) {
      err_msg = await res.text()
      return
    }

    const { from } = await res.json()
    const pgidx = Math.floor((from - 1) / 128) + 1

    goto(`/-${nvinfo.bslug}/chaps/${nvseed.sname}?pg=${pgidx}`)
  }
</script>

<svelte:head>
  <title>Thêm text chương - {nvinfo.btitle_vi} - Chivi</title>
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
        <strong>{chap_count}</strong>
        <em>(chưa tính gộp tên tập)</em>
      </div>
      <p>Lưu ý: Chương chỉ có một dòng sẽ được coi là tên tập.</p>
    </div>

    <div class="form-field">
      <span class="label">Cách thức chia chương: </span>
      <select
        name="split_mode"
        class="m-input _sm"
        disabled={loading}
        bind:value={form.split_mode}
        on:change={() => (changed = true)}>
        {#each split_modes as label, value}
          <option {value}>{label}</option>
        {/each}
      </select>
    </div>

    <div class="split-extra">
      {#if form.split_mode == 1}
        <div class="options">
          <label class="label"
            >Số dòng trắng tối thiểu: <input
              class="m-input _xs"
              type="number"
              name="min_blanks"
              bind:value={opts.min_blanks}
              min={1}
              max={4} /></label>

          <label class="label"
            ><input
              class="m-input"
              type="checkbox"
              name="trim_space"
              bind:checked={opts.trim_space} /> Lọc bỏ dấu cách</label>
        </div>
      {:else if form.split_mode == 2}
        <label class="label"
          ><input
            class="m-input"
            type="checkbox"
            name="need_blank"
            bind:checked={opts.need_blank} /> Phía trước phải là dòng trắng</label>
      {:else if form.split_mode == 3}
        <label class="label"
          >Đằng sau <code>第[số từ]+</code> là:
          <input
            class="m-input _xs"
            name="label"
            bind:value={opts.label} /></label>
      {:else if form.split_mode == 4}
        <label class="label"
          >Custom regex:
          <input
            class="m-input _xs"
            name="regex"
            bind:value={opts.regex} /></label>
      {/if}
    </div>

    <div class="errors">{err_msg}</div>

    <details class="split-descs">
      <summary>Giải thích cách chia</summary>
      {#if form.split_mode == 0}
        <p>
          Chèn bằng tay các dòng <code>///</code> để phân chia các chương:
        </p>
        <pre>chương 1<br />nội dung chương 1<br /><br />///<br /><br />chương 2<br />nội dung chương 2</pre>
        <p>
          Với các truyện có phân chia theo tập, thêm tên tập ngay sau<code
            >///</code
          >:
        </p>
        <pre>/// 第二十四集 今当升云<br />chương 1<br />nội dung chương 1<br />///<br />chương hai sẽ thừa kế tên tập phía trên<br />xxxxxxxx</pre>
      {:else if form.split_mode == 1}
        {@const min_blanks = opts.min_blanks}

        <p>
          Cách chương tiết sẽ được tách nếu giữa chúng có ít nhất {min_blanks} khoảng
          trắng:
        </p>
        <pre>第1章.这位同学，等等<br />“我们出生在一个好时代，却不是一个最好的时代。”
{#each Array.from( { length: min_blanks } ) as _}<br />{/each}第2章.正确的开门方式<br />“喂，让你等等你怎么还走那么快啊。”<br />沈童在心中无奈的叹了一口气，望着拦在自己面前的“非主流”，说道：“同学有什么事情吗？”
{#each Array.from( { length: min_blanks } ) as _}<br />{/each}第3章.非主流进化……网红！<br />“所以说，我们现在处于一个很奇怪的空间里，我开门，就是回到了我的2007年。你开门，就是回到了你的2017年，而我们两个又可以跟着对方去双方的时空……”</pre>
      {:else if form.split_mode == 2}
        <p>Nội dung của chương sẽ lùi vào phía trong so với tên chương</p>
        <pre>第1章.我是一个只喜欢兽耳娘的咸鱼挂哔<br />　　“哈欠。”<br />　　随着一声响亮的哈欠在流水线上响起，不少穿着白色工作服，带着头套的老员工都转过头看了一眼那个睡眼朦胧的年轻男子。<br /><br />第2章.挂机途中的异常<br />　　女朋友，在沈项眼里是一个很麻烦的东西。<br />　　因为她们的行为，举措，说辞都没有任何的规律可言，这种无规律，心情化的存在，让沈项没办法用自动代理系统来挂机处理。</pre>
      {:else}
        <p>Chưa có giải thích</p>
      {/if}
    </details>

    <div class="form-field">
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
    </div>

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

        <label class="label" data-tip="Xoá các chương thừa phía sau">
          <input type="checkbox" bind:checked={form.trunc_after} />
          <span>Xoá phía sau</span>
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

  .split-descs {
    @include fgcolor(tert);
    @include ftsize(sm);
    margin-top: 0.25rem;

    summary {
      @include fgcolor(secd);
    }
  }

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

  summary {
    font-weight: 500;
    font-size: 1rem;
  }

  pre {
    font-size: rem(15px);
    line-height: 1.25rem;
    padding: 0.75rem;
    margin-top: 0.25rem;
    // word-wrap: break-word;
    white-space: break-spaces;
  }

  .errors:not(:empty) {
    margin: 0.5rem;
    @include fgcolor(harmful, 5);
  }
</style>
