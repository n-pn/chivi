<script context="module">
  import { get_nvinfo } from '$api/nvinfo_api'

  export async function preload({ params }) {
    const { book, seed: sname } = params

    const [err, nvinfo] = await get_nvinfo(this.fetch, book)
    if (err) return this.error(404, nvinfo)

    const [snvid, _, total] = nvinfo.chseed[sname] || [bhash, '0', '0']
    return { nvinfo, sname, snvid, chidx: +total + 1 }
  }
</script>

<script>
  import { goto } from '@sapper/app'

  import SIcon from '$lib/blocks/SIcon.svelte'
  import Vessel from '$lib/layouts/Vessel.svelte'

  export let nvinfo

  export let sname
  export let snvid
  export let chidx = 1

  let label = '正文'
  let input = ''

  async function submit_text() {
    const url = `/api/texts/${nvinfo.bhash}/${sname}/${snvid}`
    const res = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chidx: +chidx, label, input }),
    })

    if (res.ok) {
      const data = await res.json()
      goto(`/~${nvinfo.bslug}/-${data.uslug}-${sname}-${data.chidx}`)
    } else {
      console.log(await res.text())
    }
  }
</script>

<svelte:head>
  <title>Thêm chương - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<Vessel>
  <svelte:fragment slot="header-left">
    <a href="/~{nvinfo.blsug}" class="header-item _title">
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

  <footer class="foot">
    <span class="label">Nhãn quyển</span>
    <input class="m-input" name="label" lang="zh" bind:value={label} />

    <span class="label">Chương số</span>
    <input class="m-input" name="chidx" bind:value={chidx} />

    <button class="m-button _primary" on:click={submit_text}>
      <SIcon name="plus-square" />
      <span class="-text">Thêm</span>
    </button>
  </footer>
</Vessel>

<style lang="scss">
  .navi {
    padding: 0.5rem 0;
    line-height: 1.25rem;

    @include font-size(2);

    .-item {
      display: inline;
      // float: left;
      @include fgcolor(neutral, 6);

      &._sep:after {
        display: inline-block;
        padding-left: 0.325em;
        content: '>';
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

  .m-input {
    @include tm-dark {
      @include fgcolor(neutral, 3);
      @include bgcolor(neutral, 7, 0.3);
      @include bdcolor(neutral, 6);

      &:focus {
        @include bdcolor(primary, 6);
      }
    }
  }

  #input {
    height: calc(100vh - 10rem);
    padding: 0.75rem;
    font-size: rem(18px);
  }

  .foot {
    display: flex;

    padding: 1rem 0;

    // prettier-ignore
    > .m-input {
      display: inline-block;
      &[name='label'] { width: 16rem; }
      &[name='chidx'] { width: 4rem; }
    }

    > * + * {
      margin-left: 0.5rem;
    }

    > .m-button {
      margin-left: auto;
    }
  }

  .label {
    display: inline-block;
    line-height: 2.5rem;
    text-transform: uppercase;
    font-size: rem(12px);
    font-weight: 500;
    @include fgcolor(neutral, 5);
  }
</style>
