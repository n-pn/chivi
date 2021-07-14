<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import Cvdata from '$sects/Cvdata.svelte'

  import {
    enabled as lookup_enabled,
    actived as lookup_actived,
  } from '$parts/Lookup.svelte'

  let zhtext = ''
  let cvdata = ''

  let edit_mode = true
  let text_elem = null

  $: if (edit_mode) text_elem && text_elem.focus()
  $: on_edit = edit_mode || !cvdata

  let dirty = false
  $: if (dirty) convert()

  async function convert() {
    // if ($session.privi < 1) return

    const url = `/api/tools/convert/various`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: zhtext }),
    })

    dirty = false
    cvdata = await res.text()
    edit_mode = false
  }

  function cleanup() {
    zhtext = cvdata = ''
    edit_mode = true
  }
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<Vessel shift={$lookup_enabled && $lookup_actived}>
  <span slot="header-left" class="header-item _active">
    <SIcon name="zap" />
    <span class="header-text">Dịch nhanh</span>
  </span>

  <section class="main">
    {#if on_edit}
      <div class="m-input">
        <textarea
          lang="zh"
          bind:value={zhtext}
          bind:this={text_elem}
          placeholder="Nhập dữ liệu vào đây" />
      </div>
    {:else}
      <Cvdata input={cvdata} bind:dirty />
    {/if}
  </section>

  <div slot="footer" class="foot">
    {#if on_edit}
      <button class="m-button" on:click={cleanup}>
        <span>Xoá</span>
      </button>

      <button class="m-button _primary _fill" on:click={convert}>
        <span>Dịch nhanh</span>
      </button>
    {:else}
      <button class="m-button" on:click={() => (edit_mode = true)}>
        <span>Sửa</span>
      </button>

      <button class="m-button _primary _fill" on:click={cleanup}>
        <span>Dịch mới</span>
      </button>
    {/if}
  </div>
</Vessel>

<style lang="scss">
  .main {
    margin-top: 1rem;
  }

  textarea {
    width: 100%;
    min-height: calc(100vh - 7.5rem);

    padding: var(--gutter-small) var(--gutter);

    &::placeholder {
      font-style: normal;
      text-align: center;
    }
  }

  .foot {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
