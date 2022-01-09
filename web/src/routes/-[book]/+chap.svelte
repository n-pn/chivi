<script context="module">
  export async function load({ url, fetch, stuff }) {
    const { nvinfo } = stuff
    const chidx = +url.searchParams.get('chidx') || 1

    let input = ''

    if (url.searchParams.get('mode') == 'edit') {
      input = await load_text(fetch, nvinfo.id, chidx)
    }

    return { props: { nvinfo, chidx, input } }
  }

  async function load_text(fetch, book_id, chidx) {
    const res = await fetch(`/api/chaps/${book_id}/chivi/${chidx}/_raw`)
    return await res.text()
  }
</script>

<script>
  import { goto } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let nvinfo

  export let chidx = 1
  export let input = ''

  async function submit_text() {
    const url = `/api/chaps/${nvinfo.id}/users`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chidx, input }),
    })

    if (res.ok) {
      const data = await res.json()
      goto(`/-${nvinfo.bslug}/-chivi/-${data.uslug}-${data.chidx}`)
    } else {
      await res.text()
    }
  }
</script>

<svelte:head>
  <title>Thêm/sửa chương - {nvinfo.vname} - Chivi</title>
</svelte:head>

<Appbar>
  <svelte:fragment slot="left">
    <a href="/-{nvinfo.bslug}" class="header-item _title">
      <SIcon name="book" />
      <span class="header-text _show-md _title">{nvinfo.vname}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _title">Thêm/sửa chương</span>
    </button>
  </svelte:fragment>
</Appbar>

<Vessel>
  <nav class="navi">
    <div class="-item _sep">
      <a href="/-{nvinfo.bslug}" class="-link">{nvinfo.vname}</a>
    </div>

    <div class="-item">
      <a href="/-{nvinfo.bslug}/-chivi" class="-link">Mục lục</a>
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
    <span class="label">Chương bắt đầu</span>
    <input class="m-input" name="chidx" bind:value={chidx} />

    <button class="m-btn _primary _fill" on:click={submit_text}>
      <SIcon name="square-plus" />
      <span class="-text">Lưu trữ</span>
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

    // prettier-ignore
    > .m-input {
      display: inline-block;
      &[name='chidx'] { width: 4rem; }
    }

    > .m-btn {
      margin-left: auto;
    }
  }

  .label {
    text-transform: uppercase;
    font-weight: 500;
    @include ftsize(sm);
    @include fgcolor(tert);
  }
</style>
