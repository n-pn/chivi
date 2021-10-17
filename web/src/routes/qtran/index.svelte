<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import Cvdata from '$sects/Cvdata.svelte'
  import { enabled as lookup_enabled } from '$parts/Lookup.svelte'

  let zhtext = ''
  let cvdata = ''

  let edit_mode = true
  let text_elem = null

  $: if (edit_mode) text_elem && text_elem.focus()
  $: on_edit = edit_mode || !cvdata

  let _dirty = false
  $: if (_dirty) convert()

  async function convert() {
    // if ($session.privi < 1) return

    const url = `/api/tools/convert/various`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: zhtext }),
    })

    _dirty = false
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

<Vessel>
  <span slot="header-left" class="header-item _active">
    <SIcon name="bolt" />
    <span class="header-text">Dịch nhanh</span>
  </span>

  <svelte:fragment slot="header-right">
    <button
      class="header-item"
      class:_active={$lookup_enabled}
      on:click={() => lookup_enabled.update((x) => !x)}
      data-kbd="\">
      <SIcon name="compass" />
      <span class="header-text _show-md">Giải nghĩa</span>
    </button>
  </svelte:fragment>

  <section class="main">
    {#if on_edit}
      <textarea
        class="m-input"
        lang="zh"
        bind:value={zhtext}
        bind:this={text_elem}
        placeholder="Nhập dữ liệu vào đây" />
    {:else}
      <Cvdata zhtext={split_input(zhtext)} {cvdata} bind:_dirty />
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
