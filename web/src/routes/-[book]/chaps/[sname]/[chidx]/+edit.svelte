<script context="module" lang="ts">
  /** @type {import('./[slug]').Load} */
  export async function load({ stuff, params, fetch }) {
    const { nvinfo, nvseed } = stuff
    const { sname, snvid } = nvseed

    const chidx = params.chidx.split('-', 2)[0]

    const api_res = await fetch(`/api/texts/${sname}/${snvid}/${chidx}`)
    if (!api_res) return { status: api_res.status, error: await api_res.text() }

    const input = await api_res.text()
    const props = { nvinfo, chidx, input, sname, snvid }

    const topbar = gen_topbar(nvinfo, sname, chidx)
    return { props, stuff: { topbar } }
  }

  function gen_topbar({ bslug, btitle_vi }, sname: string, chidx: number) {
    const chap_href = `/-${bslug}/chaps/${sname}`
    return {
      left: [
        [btitle_vi, 'book', { href: `/-${bslug}`, kind: 'title', show: 'tm' }],
        [sname, 'list', { href: chap_href, show: 'ts' }],
        [`Ch. ${chidx}`, '', { href: `${chap_href}/${chidx}` }],
        [`Sửa`, 'edit', { href: '+edit', show: 'pl' }],
      ],
    }
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { SIcon, Footer } from '$gui'
  import { hash_str } from '$utils/text_utils'

  export let nvinfo: CV.Nvinfo

  export let sname = ''
  export let snvid = ''
  export let chidx = 1
  export let input = ''

  let form = {
    tosimp: false,
    unwrap: false,
    split_mode: 0,
  }

  $: action_url = `/api/texts/${sname}/${snvid}/${chidx}`

  async function submit(evt: SubmitEvent) {
    const body = new FormData()

    body.append('text', input)
    body.append('hash', hash_str(input))
    body.append('encoding', 'UTF-8')
    body.append('split_mode', '0')

    for (const key in form) body.append(key, form[key].toString())
    const res = await fetch(action_url, { method: 'POST', body })

    if (res.ok) {
      await res.json()
      goto(`/-${nvinfo.bslug}/chaps/${sname}/${chidx}`)
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
      <textarea class="m-input" name="text" lang="zh" bind:value={input} />
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
