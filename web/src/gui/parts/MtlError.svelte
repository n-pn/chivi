<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'

  const data = {
    ...writable({ _ukey: '', ztext: '', pdict: '', qtran: '', extra: '', uname: '', mtime: '' }),
  }

  export const ctrl = {
    ...writable({ actived: false }),
    show: () => ctrl.set({ actived: true }),
    hide: () => {
      ctrl.set({ actived: false })
    },
    load: async (ukey: string) => {
      const res = await fetch(`/_sp/mt_errs/${ukey}`)
      data.set(await res.json())
      ctrl.set({ actived: true })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let on_destroy = () => {}
  onDestroy(on_destroy)

  // export let rline
  // export let ropts

  let hvmtl = ''
  let error = ''

  let hanzi_elem: HTMLElement
  let match_elem: HTMLElement

  let lower = 0
  let upper = $data.ztext.length

  async function handle_submit(evt: Event) {
    evt.preventDefault()

    const path = `/_mt/mt_err/${$data._ukey}`
    const body = { ...$data, lower, upper }

    try {
      await api_call(path, body, 'POST', fetch)
      ctrl.hide()
      on_destroy()
    } catch (ex) {
      error = ex.body.message
      // console.error(ex)
    }
  }

  async function delete_tlspec() {
    try {
      await api_call(`/_sp/mt_errs/${$data._ukey}`, {}, 'DELETE', fetch)
      ctrl.hide()
      on_destroy()
    } catch (ex) {
      console.error(ex)
      error = ex.body.message
    }
  }

  function change_focus(index: number, _prev = lower) {
    if (index < upper) lower = index
    if (index >= _prev) upper = index + 1
  }

  function shift_lower(value = 0) {
    value += lower
    if (value < 0 || value >= $data.ztext.length) return

    lower = value
    if (upper <= value) upper = value + 1
  }

  function shift_upper(value = 0) {
    value += upper
    if (value < 1 || value > $data.ztext.length) return

    upper = value
    if (lower >= value) lower = value - 1
  }

  function copy_ztext() {
    const input = $data.ztext.substring(lower, upper)
    navigator.clipboard.writeText(input)
  }

  function appy_cvmtl() {
    $data.match = $data.cvmtl
    match_elem.focus()
  }
</script>

<Dialog actived={$ctrl.actived} --z-idx={80} class="tlspec" on_close={ctrl.hide}>
  <tlspec-title slot="header">
    <title-lbl><SIcon name="flag" /></title-lbl>
  </tlspec-title>

  <tlspec-body>
    <form-label>
      <span>Khoanh phạm vi lỗi dịch</span>

      <btn-group>
        <button
          data-kbd="←"
          disabled={lower == 0}
          on:click={() => shift_lower(-1)}
          data-tip="Mở rộng sang trái">
          <SIcon name="arrow-left" />
        </button>

        <button
          data-kbd="⇧←"
          disabled={lower == rline.ztext.length - 1}
          on:click={() => shift_lower(1)}
          data-tip="Thu hẹp về trái">
          <SIcon name="arrow-bar-to-right" />
        </button>

        <span>({upper - lower})</span>

        <button
          data-kbd="⇧→"
          disabled={lower == 1}
          on:click={() => shift_upper(-1)}
          data-tip="Tu hẹp từ phải">
          <SIcon name="arrow-bar-to-left" />
        </button>

        <button
          data-kbd="→"
          disabled={lower == rline.ztext.length}
          on:click={() => shift_upper(1)}
          data-tip="Mở rộng sang phải">
          <SIcon name="arrow-right" />
        </button>

        <button data-kbd="c" on:click={copy_ztext} data-tip="Copy đoạn text vào clipboard">
          <SIcon name="clipboard" />
        </button>
      </btn-group>
    </form-label>

    <tlspec-input>
      <tlspec-hanzi bind:this={hanzi_elem}>
        {#each Array.from($data.ztext) as char, index}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-static-element-interactions -->
          <x-z class:active={index >= lower && index < upper} on:click={() => change_focus(index)}
            >{char}</x-z>
        {/each}
      </tlspec-hanzi>

      <tlspec-cvmtl>{hvmtl}</tlspec-cvmtl>
      <tlspec-cvmtl>{$data.qtran}</tlspec-cvmtl>
    </tlspec-input>

    <form action="/_db/tlspecs" method="POST" class="form" on:submit={handle_submit}>
      <form-group>
        <form-label>Giải thích thêm nếu cần</form-label>
        <textarea class="m-input _extra" name="extra" bind:value={$data.extra} />
      </form-group>

      {#if error}
        <form-error>{error}</form-error>
      {/if}

      <form-action>
        {#if $data._ukey}
          <button type="button" class="m-btn _harmful" data-kbd="delete" on:click={delete_tlspec}>
            <SIcon name="trash" />
            <span>Xoá bỏ</span>
          </button>
        {/if}

        <button type="submit" class="m-btn _primary _fill" data-kbd="⇧↵" disabled={!$data.match}>
          {#if $data._ukey}
            <SIcon name="device-floppy" />
            <span>Lưu lại</span>
          {:else}
            <SIcon name="send" />
            <span>Báo lỗi</span>
          {/if}
        </button>
      </form-action>
    </form>
  </tlspec-body>
</Dialog>

<style lang="scss">
  tlspec-title {
    display: flex;
    flex: 1;
    overflow: hidden;
  }

  title-lbl {
    padding-right: 0.25rem;
  }

  title-dic {
    flex: 1;
    @include clamp($width: null);
  }

  tlspec-body {
    display: block;
    margin: 0.75rem;
    margin-top: 0.5rem;
    @include bgcolor(secd);
  }

  form-group {
    display: block;
    margin-top: 0.5rem;
  }

  form-error {
    display: block;
    line-height: 1.25rem;
    margin-top: -0.25rem;
    margin-bottom: -0.75rem;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }

  tlspec-input {
    display: block;
    @include fgcolor(tert);
    @include bgcolor(tert);
    @include border();
    @include bdradi();

    > * {
      padding: 0.25rem 0.5rem;
    }
  }

  tlspec-hanzi {
    display: block;
    $height: 1.25rem;
    line-height: $height;
    max-height: $height * 3 + 0.5rem;
    @include scroll();
    @include ftsize(lg);
  }

  tlspec-cvmtl {
    display: block;

    $height: 1rem;
    line-height: $height;
    max-height: $height * 2 + 0.5rem;

    @include ftsize(sm);
    // @include fgcolor(tert);

    @include border($loc: top);
    @include scroll();
  }

  x-z {
    display: inline-block;
    cursor: pointer;
    min-width: 1em;
    text-align: center;
    &.active {
      @include fgcolor(primary, 5);
    }
  }

  textarea {
    display: block;
    width: 100%;
    padding: 0.25rem 0.5rem;

    line-height: 1.25rem;
    height: 3.25rem;
    @include scroll();
  }

  form-label {
    display: flex;
    width: 100%;
    font-weight: 500;
    // margin-top: 0.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(sm);
  }

  form-action {
    @include flex($gap: 0.75rem);
    justify-content: right;
    margin: 0.75rem 0;
  }

  btn-group {
    display: flex;
    margin-left: auto;

    > * + * {
      margin-left: 0.25rem;
    }

    // prettier-ignore
    > button, > a {
      background: none;
      padding: 0;
      width: 1.5rem;
      height: 1.5rem;

      @include fgcolor(tert);
      &:hover { @include fgcolor(main); }
      &:disabled { @include fgcolor(mute); }

      :global(svg) {
        width: 1rem;
        height: 1rem;
        margin: 0.25rem;
      }
    }
  }
</style>
