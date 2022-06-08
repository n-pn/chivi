<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ url, params, stuff }) {
    const { nvinfo } = stuff
    const sname = params.seed
    const chidx = +url.searchParams.get('chidx') || 1

    stuff.topbar = gen_topbar(nvinfo)
    return { props: { nvinfo, sname, chidx }, stuff }
  }

  function gen_topbar({ btitle_vi, bslug }) {
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
        ['Thêm/sửa chương', 'file-plus', { href: '.', show: 'pl' }],
      ],
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { page } from '$app/stores'

  import { SIcon, Footer } from '$gui'

  export let nvinfo: CV.Nvinfo
  export let sname = 'users'
  export let chidx = 1

  export let input = ''
  let files: FileList
  let _trad = false

  $: action_url = `/api/texts/${nvinfo.id}/${sname}`

  async function submit(evt: SubmitEvent) {
    const body = new FormData()

    body.append('chidx', chidx.toString())
    body.append('_trad', _trad.toString())
    body.append('text', input)
    body.append('file', files && files[0])

    const res = await fetch(action_url, {
      method: 'POST',
      body,
    })

    if (res.ok) {
      const { entry } = await res.json()
      goto(`/-${nvinfo.bslug}/+${sname}/${entry}`)
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
      <label class="label" for="text">Nhập văn bản</label>
      <textarea
        class="m-input"
        name="text"
        lang="zh"
        id="text"
        bind:value={input} />
    </div>

    <div class="form-field">
      <label class="label" for="file">Hoặc chọn text file:</label>
      <input type="file" bind:files accept=".txt" />
    </div>

    <Footer>
      <div class="pagi">
        <label class="label" for="chidx">
          <span>Đánh số chương</span>
          <input class="m-input" name="chidx" bind:value={chidx} />
        </label>

        <label class="label">
          <input type="checkbox" name="_trad" bind:checked={_trad} />
          <span>Phồn -> Giản</span>
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
  textarea {
    display: block;
    width: 100%;
    min-height: 10rem;
    height: calc(100vh - 20rem);
    padding: 0.75rem;
    font-size: rem(18px);
    margin-bottom: 0.5rem;
  }

  h2 {
    padding: 0.75rem 0;
  }

  section {
    padding-bottom: 0.5rem;
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
