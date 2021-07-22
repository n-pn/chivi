<script context="module">
  export async function load({ page, context }) {
    const { nvinfo } = context
    const sname = page.params.seed
    const chidx = +page.params.chidx || 1
    return { props: { nvinfo, sname, chidx: chidx } }
  }
</script>

<script>
  import { goto } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'

  export let nvinfo

  export let sname
  export let chidx = 1

  let label = '正文'
  let input = ''

  async function submit_text() {
    const url = `/api/texts/${nvinfo.id}/${sname}`
    const res = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chidx, label, input }),
    })

    if (res.ok) {
      const data = await res.json()
      goto(`/~${nvinfo.bslug}/-${data.uslug}-${sname}-${data.chidx}`)
    } else {
      await res.text()
    }
  }
</script>

<svelte:head>
  <title>Thêm chương - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href="/~{nvinfo.bslug}" class="header-item _title">
      <SIcon name="book-open" />
      <span class="header-text _show-md _title">{nvinfo.btitle_vi}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{sname}]</span>
    </button>
  </svelte:fragment>

  <nav class="navi">
    <div class="-item _sep">
      <a href="/~{nvinfo.bslug}" class="-link">{nvinfo.btitle_vi}</a>
    </div>

    <div class="-item">
      <span class="-text">Chương mới</span>
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
    <span class="label">Nhãn quyển</span>
    <input class="m-input" name="label" lang="zh" bind:value={label} />

    <span class="label">Chương số</span>
    <input class="m-input" name="chidx" bind:value={chidx} />

    <button class="m-button _primary _fill" on:click={submit_text}>
      <SIcon name="plus-square" />
      <span class="-text">Thêm</span>
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
    @include flex($gap: 0.5rem);

    // prettier-ignore
    > .m-input {
      display: inline-block;
      &[name='label'] { width: 16rem; }
      &[name='chidx'] { width: 4rem; }
    }

    > .m-button {
      margin-left: auto;
    }
  }

  .label {
    display: inline-block;
    line-height: 2.25rem;
    text-transform: uppercase;
    font-weight: 500;
    @include ftsize(xs);
    @include fgcolor(tert);
  }
</style>
