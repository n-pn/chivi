<script context="module">
  export async function load({ url, fetch, stuff }) {
    const chidx = +url.searchParams.get('chidx') || 1

    let input = ''

    if (url.searchParams.get('mode') == 'edit') {
      input = await load_text(fetch, stuff.nvinfo.id, chidx)
    }

    return { props: { chidx, input } }
  }

  async function load_text(fetch, book_id, chidx) {
    const res = await fetch(`/api/chaps/${book_id}/chivi/${chidx}/_raw`)
    return await res.text()
  }
</script>

<script>
  import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import { data as appbar } from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let chidx = 1
  export let input = ''

  $: nvinfo = $page.stuff.nvinfo
  let _trad = false

  async function submit_text() {
    const url = `/api/chaps/${nvinfo.id}/users`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chidx, input, _trad }),
    })

    if (res.ok) {
      const data = await res.json()
      goto(`/-${nvinfo.bslug}/-chivi/-${data.uslug}-${data.chidx}`)
    } else {
      await res.text()
    }
  }

  $: appbar.set({
    left: [
      [nvinfo.vname, 'book', `/-${nvinfo.bslug}`, '_title', '_show-md'],
      ['Thêm/sửa chương'],
    ],
  })
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.vname} - Chivi</title>
</svelte:head>

<Vessel>
  <nav class="navi">
    <div class="-item _sep">
      <a href="/-{nvinfo.bslug}" class="-link">{nvinfo.vname}</a>
    </div>

    <div class="-item">
      <a href="/-{nvinfo.bslug}/-chivi" class="-link">Chương tiết</a>
    </div>
  </nav>

  <section class="body">
    <textarea
      class="m-input"
      name="input"
      lang="zh"
      id="input"
      bind:value={input} />
  </section>

  <div slot="footer" class="vessel">
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
</Vessel>

<style lang="scss">
  .navi {
    padding: 0.5rem 0;
    line-height: 1.25rem;

    @include ftsize(sm);

    .-item {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);

      &._sep:after {
        display: inline-block;
        padding-left: 0.325em;
        content: '/';
        @include fgcolor(neutral, 4);
      }
    }

    .-link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 6);
      }
    }
  }

  #input {
    width: 100%;
    height: calc(100vh - 12rem);
    padding: 0.75rem;
    font-size: rem(18px);
  }

  .vessel {
    @include flex-cy($gap: 0.5rem);

    .m-input {
      display: inline-block;
      &[name='chidx'] {
        margin-left: 0.25rem;
        width: 3.5rem;
        text-align: center;
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
