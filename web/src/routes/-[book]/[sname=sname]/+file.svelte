<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ stuff }) {
    const { nvinfo } = stuff

    stuff.topbar = gen_topbar(nvinfo)
    return { props: { nvinfo }, stuff }
  }

  function gen_topbar({ btitle_vi, bslug }) {
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
        ['Thêm/sửa chương', 'file-plus', { href: '.', show: 'pl' }],
      ],
    }
  }

  const split_modes = [
    'Phân thủ công bằng ///',
    'Phân bởi khoảng trắng',
    'Nội dung thụt vào',
  ]

  const split_descs = [
    `
    `,
    `Cách chương tiết sẽ `,
  ]
</script>

<script lang="ts">
  import { goto } from '$app/navigation'

  import { SIcon, Footer } from '$gui'

  export let nvinfo: CV.Nvinfo

  export let input = ''
  let files: FileList

  let form = {
    chidx: 1,
    chvol: '',
    tosimp: false,
    unwrap: false,
    encoding: 'auto',
    split_mode: 1,
  }

  let modes = {
    0: {},
    1: {
      min_blank: 2,
      trim_space: false,
    },
    2: {
      require_blank: false,
    },
    3: {
      suffix: '章节回幕',
    },
    4: {
      regex: '^\\s*第?[d+零〇一二两三四五六七八九十百千]+章)',
    },
  }

  $: action_url = `/api/texts/${nvinfo.id}`

  async function submit(evt: SubmitEvent) {
    const body = new FormData()

    body.append('text', input)
    body.append('file', files && files[0])

    for (let key in form) {
      const val = form[key]
      if (val) body.append(key, val.toString())
    }

    const mode_params = modes[form.split_mode]
    for (let key in mode_params) {
      body.append(key, mode_params[key].toString())
    }

    const res = await fetch(action_url, {
      method: 'POST',
      body,
    })

    if (res.ok) {
      await res.json()
      goto(`/-${nvinfo.bslug}/$self`)
    } else {
      alert(await res.text())
    }
  }
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.btitle_vi} - Chivi</title>
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
  <h2>Thêm/sửa chương</h2>

  <form action={action_url} method="POST" on:submit|preventDefault={submit}>
    <div class="form-field">
      <label class="label" for="file">Chọn tệp tin:</label>
      <input type="file" bind:files accept=".txt" required />
    </div>

    <div class="form-field">
      <div class="label">Cách thức chia chương</div>
      <div class="options">
        {#each split_modes as label, value}
          <label class="label">
            <input
              type="radio"
              name="split_mode"
              bind:group={form.split_mode}
              {value} />
            <span>{label}</span>
          </label>
        {/each}
      </div>
    </div>

    <div class="form-field">
      {#if form.split_mode == 0}
        <div class="split-descs">
          <p>
            Chèn bằng tay các dòng trắng <code>///</code> để phân chia các chương:
          </p>
          <pre>nội dung chương 1<br />///<br />nội dung chương 2</pre>
          <p>
            Với các truyện có phân chia theo tập, thêm tên tập ngay sau<code
              >///</code
            >:
          </p>
          <pre>/// 第二十四集 今当升云<br />nội dung chương 1<br />///<br />nội dung chương hai sẽ thừa kế tên tập đằng trước</pre>
        </div>
      {:else if form.split_mode == 1}
        {@const min_blank = modes[1].min_blank}

        <div class="split-descs">
          <p>
            Cách chương tiết sẽ được tách nếu giữa chúng có ít nhất {min_blank} khoảng
            trắng:
          </p>
          <pre>chương 1<br />nội dung chương 1<br />nội dung chương 1
{#each Array.from( { length: min_blank } ) as _}<br />{/each}chương 2<br />nội dung chương 2<br />nội dung chương 2
{#each Array.from( { length: min_blank } ) as _}<br />{/each}nếu chỉ có một dòng trắng thì đây là tên bộ
{#each Array.from( { length: min_blank } ) as _}<br />{/each}chương 3<br />nội dung chương 3</pre>
        </div>

        <div class="label">Lựa chọn bổ sung</div>
        <div class="split-extra options">
          <label class="label"
            >Số khoảng trắng tối thiểu: <input
              class="m-input"
              type="number"
              name="min_blank"
              bind:value={modes[1].min_blank}
              min={1} /></label>

          <label class="label"
            ><input
              class="m-input"
              type="checkbox"
              name="trim_space"
              bind:checked={modes[1].trim_space}
              min={1} /> Xoá các ký tự khoảng trắng</label>
        </div>
      {:else}
        <p>Chưa có hướng dẫn</p>
      {/if}
    </div>

    <div class="form-field">
      <div class="label">Lựa chọn nâng cao</div>
      <div class="options">
        <label class="label">
          <input type="checkbox" name="tosimp" bind:checked={form.tosimp} />
          <span>Chuyển từ Phồn -> Giản</span>
        </label>

        <label class="label">
          <input type="checkbox" name="tosimp" bind:checked={form.unwrap} />
          <span>Sửa lỗi xuống dòng</span>
        </label>
      </div>
    </div>

    <Footer>
      <div class="pagi">
        <label class="label" for="chidx">
          <span>Chương bắt đầu</span>
          <input class="m-input" name="chidx" bind:value={form.chidx} />
        </label>

        <button type="submit" class="m-btn _primary _fill">
          <SIcon name="upload" />
          <span class="-text">Đăng tải</span>
        </button>
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

  .options {
    display: flex;
    gap: 0.5rem;
    align-items: center;
    padding: 0.25rem 0;

    label {
      @include fgcolor(secd);
    }
  }

  pre {
    line-height: 1.25rem;
    padding: 0 0.75rem;
  }

  [name='min_blank'] {
    width: 4rem;
  }

  .split-descs {
    @include fgcolor(tert);
    @include ftsize(sm);
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
    @include ftsize(sm);
    @include fgcolor(tert);
  }
</style>
