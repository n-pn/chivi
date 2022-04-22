<script context="module" lang="ts">
  export async function load({ url, fetch, stuff: { nvinfo } }) {
    const chidx = +url.searchParams.get('chidx') || 1

    let input = ''

    if (url.searchParams.get('mode') == 'edit') {
      input = await load_text(fetch, nvinfo.id, chidx)
    }

    return { props: { nvinfo, chidx, input } }
  }

  async function load_text(fetch: CV.Fetch, book_id: number, chidx: number) {
    const res = await fetch(`/api/chaps/${book_id}/chivi/${chidx}/_raw`)
    return await res.text()
  }
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { page } from '$app/stores'
  import { topbar } from '$lib/stores'

  import { SIcon, Footer } from '$gui'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let chidx = 1
  export let input = ''

  let _trad = false

  async function submit_text() {
    const url = `/api/chaps/${nvinfo.id}/users`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chidx, input, _trad }),
    })

    const payload = await res.json()
    if (res.ok) {
      const { props } = payload
      goto(`/-${nvinfo.bslug}/-chivi/${props.chidx}-${props.uslug}`)
    } else {
      alert(payload.error)
    }
  }

  $: topbar.set({
    left: [
      [nvinfo.vname, 'book', { href: `/-${nvinfo.bslug}`, kind: 'title' }],
      ['Thêm/sửa chương', 'file-plus', { href: '.', show: 'pl' }],
    ],
  })
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.vname} - Chivi</title>
</svelte:head>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.vname}</span>
  </a>
  <span>/</span>
  <a href="/-{nvinfo.bslug}/-chivi" class="crumb _link">Chương tiết</a>
</nav>

<section class="article">
  <h2>Thêm/sửa chương</h2>

  <textarea
    class="m-input"
    name="input"
    lang="zh"
    id="input"
    bind:value={input} />

  <Footer>
    <div class="pagi">
      <label class="label" for="chidx">
        <span>Chương số</span>
        <input class="m-input" name="chidx" bind:value={chidx} />
      </label>

      <label class="label">
        <input type="checkbox" name="_trad" bind:checked={_trad} />
        <span>Phồn -> Giản</span>
      </label>

      <button class="m-btn _primary _fill" on:click={submit_text}>
        <SIcon name="square-plus" />
        <span class="-text">Lưu</span>
      </button>
    </div>
  </Footer>
</section>

<style lang="scss">
  textarea {
    display: block;
    width: 100%;
    min-height: 10rem;
    height: calc(100vh - 12rem);
    padding: 0.75rem;
    font-size: rem(18px);
  }

  h2 {
    padding: 0.75rem 0;
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
