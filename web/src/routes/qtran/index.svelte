<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import CvPage from '$sects/CvPage.svelte'

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'

  let zhtext = ''
  let cvdata = ''

  let edit_mode = true
  let text_elem = null

  $: if (edit_mode) text_elem && text_elem.focus()
  $: on_edit = edit_mode || !cvdata

  const on_change = () => convert()

  async function convert() {
    // if ($session.privi < 0) return

    const url = `/api/qtran`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: zhtext, dname, d_dub }),
    })

    cvdata = await res.text()
    edit_mode = false
  }

  function cleanup() {
    zhtext = ''
    edit_mode = true
  }

  function split_input(input) {
    return input
      .split('\n')
      .map((x) => x.trim())
      .filter((x) => x)
  }
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Appbar ptype="cvmtl">
  <span slot="left" class="header-item _active">
    <SIcon name="bolt" />
    <span class="header-text">Dịch nhanh</span>
  </span>
</Appbar>

<Vessel>
  <section class="main">
    {#if on_edit}
      <textarea
        class="m-input"
        lang="zh"
        bind:value={zhtext}
        bind:this={text_elem}
        placeholder="Nhập dữ liệu vào đây" />
    {:else}
      <CvPage zhtext={split_input(zhtext)} {cvdata} {on_change} />
    {/if}
  </section>

  <div slot="footer" class="foot">
    {#if on_edit}
      <button class="m-btn" on:click={cleanup}>
        <SIcon name="eraser" />
        <span>Xoá</span>
      </button>

      <button class="m-btn _primary _fill" on:click={convert}>
        <span>Dịch nhanh</span>
      </button>
    {:else}
      <button class="m-btn" on:click={() => (edit_mode = true)}>
        <SIcon name="pencil" />
        <span>Sửa</span>
      </button>

      <button class="m-btn _fill" on:click={convert}>
        <SIcon name="rotate-clockwise" />
        <span>Dịch lại</span>
      </button>

      <button class="m-btn _success _fill" on:click={cleanup}>
        <span>Dịch mới</span>
      </button>
    {/if}
  </div>
</Vessel>

<style lang="scss">
  .main {
    margin-top: 1rem;
  }

  .m-input {
    width: 100%;
    min-height: calc(100vh - 10.5rem);

    padding: var(--gutter-small) var(--gutter);

    &::placeholder {
      font-style: normal;
      text-align: center;
    }
  }

  .foot {
    @include flex($center: horz, $gap: 0.5rem);
    // justify-content: right;
  }
</style>
