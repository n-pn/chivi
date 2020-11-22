<script context="module">
  import SvgIcon from '$atoms/SvgIcon'

  import Convert, { toggle_lookup, active_upsert } from '$parts/Convert'
  import Vessel from '$parts/Vessel'

  import {
    // self_uname,
    self_power,
    upsert_dicts,
    lookup_dname,
    upsert_actived,
    lookup_enabled,
    lookup_actived,
  } from '$src/stores'
</script>

<script>
  let zh_text = ''
  let cv_data = ''

  let edit_mode = true
  let text_elem = null

  $: if (edit_mode && text_elem) text_elem.focus()

  let dirty = false
  $: if (dirty) convert()

  $: $lookup_dname = 'dich-nhanh'
  $: $upsert_dicts = [
    ['dich-nhanh', 'Dịch Nhanh', true],
    ['generic', 'Thông dụng'],
    ['hanviet', 'Hán việt'],
  ]

  function handle_keypress(evt) {
    if (edit_mode) return
    if (evt.ctrlKey) return
    if ($upsert_actived) return

    switch (evt.key) {
      case '\\':
        toggle_lookup()
        break

      case 'x':
        evt.preventDefault()
        active_upsert(0)
        break

      case 'c':
        evt.preventDefault()
        active_upsert(1)
        break

      case 'r':
        evt.preventDefault()
        dirty = true
        break

      default:
        if (evt.keyCode == 13) {
          evt.preventDefault()
          active_upsert()
        }
    }
  }

  async function convert() {
    // if ($self_power < 1) return

    const url = `/_tools/convert?dname=dich-nhanh`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input: zh_text }),
    })

    const data = await res.json()

    dirty = false
    cv_data = data.join('\n')
    edit_mode = false
  }
</script>

<svelte:head>
  <title>Dịch nhanh - Chivi</title>
</svelte:head>

<svelte:body on:keydown={handle_keypress} />

<Vessel shift={$lookup_enabled && $lookup_actived}>
  <span slot="header-left" class="header-item _active">
    <SvgIcon name="zap" />
    <span class="header-text">Dịch nhanh</span>
  </span>

  <nav class="tabs">
    <span
      class="tab"
      class:_active={edit_mode}
      on:click={() => (edit_mode = true)}>Nguồn tiếng Trung</span>
    {#if cv_data}
      <span
        class="tab"
        class:_active={!edit_mode}
        on:click={() => (edit_mode = false)}>Kết quả dịch</span>
    {/if}
  </nav>

  {#if edit_mode}
    <textarea
      lang="zh"
      bind:value={zh_text}
      bind:this={text_elem}
      placeholder="Nhập dữ liệu vào đây" />

    <footer>
      <button class="m-button _line" on:click={() => (zh_text = '')}>
        <span>Xoá</span>
      </button>

      <button class="m-button _primary" on:click={convert}>
        <span>Dịch nhanh</span>
      </button>
    </footer>
  {:else if cv_data}
    <Convert input={cv_data} bind:dirty />
  {:else}
    <div class="empty">Mời nhập dữ liệu trong ô tiếng Trung</div>
  {/if}
</Vessel>

<style lang="scss">
  .tabs {
    margin: 0.5rem 0;
    display: flex;
    line-height: 2.5rem;
    text-transform: uppercase;
    font-weight: 500;
    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include border($sides: bottom);
  }

  .tab {
    cursor: pointer;
    padding: 0 0.75rem;
    height: 2.5rem;

    &:hover {
      @include fgcolor(primary, 5);
    }
    &._active {
      @include border($sides: bottom, $width: 2px, $color: primary, $shade: 5);
    }
  }

  textarea {
    width: 100%;
    min-height: calc(100vh - 10rem);

    padding: 0.75rem;

    @include border();
    @include radius();

    &:hover,
    &:focus {
      background-color: #fff;
      @include bdcolor(primary, 3);
    }

    &:focus {
      box-shadow: 0 0 1px 1px color(primary, 2);
    }

    &::placeholder {
      font-style: italic;
      @include fgcolor(neutral, 4);
    }
  }

  footer {
    margin: 0.5rem 0;
    @include flex();
    justify-content: right;
    // > * {
    //   @include flex-gap(0.5rem);
    // }
  }
</style>
