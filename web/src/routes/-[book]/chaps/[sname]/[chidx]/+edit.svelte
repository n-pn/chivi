<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ stuff }) {
    const { nvinfo } = stuff

    stuff.chidx = stuff.chinfo.chidx
    stuff.input = stuff.zhtext.join('\n')
    const topbar = gen_topbar(nvinfo)
    return { props: stuff, stuff: { topbar } }
  }

  function gen_topbar({ btitle_vi, bslug }) {
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title' }],
        ['Sửa chương', 'file-plus', { href: '.', show: 'pl' }],
      ],
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'

  import { SIcon, Footer } from '$gui'

  export let nvinfo: CV.Nvinfo

  export let input = ''
  export let chidx = 1

  let files: FileList

  let form = {
    tosimp: false,
    unwrap: false,
  }

  $: action_url = `/api/texts/${nvinfo.id}`

  async function submit(evt: SubmitEvent) {
    const body = new FormData()

    body.append('text', input)
    body.append('file', files && files[0])
    body.append('chidx', chidx.toString())
    for (let key in form) body.append(key, form[key].toString())

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
  <title>Sửa text gốc - {nvinfo.btitle_vi} - Chivi</title>
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
  <h2>Sửa chương</h2>

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

    <Footer>
      <div class="pagi">
        <label class="label" for="chidx">
          <span>Đánh số chương</span>
          <input class="m-input" name="chidx" bind:value={chidx} />
        </label>

        <label class="label">
          <input type="checkbox" name="tosimp" bind:checked={form.tosimp} />
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
