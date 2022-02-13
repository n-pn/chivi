<script context="module" lang="ts">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import { ztext, zfrom, zupto, vdict } from '$lib/stores'

  const entry = {
    ...writable({ _ukey: '', match: '', extra: '', cvmtl: '' }),
    reset() {
      this.set({ match: '', extra: '', cvmtl: '' })
    },
  }

  export const ctrl = {
    ...writable({ actived: false }),
    show: () => ctrl.set({ actived: true }),
    hide: () => {
      entry.reset()
      ctrl.set({ actived: false })
    },
    load: async (ukey: string) => {
      const res = await fetch(`/api/tlspecs/${ukey}`)
      const { props } = await res.json()

      ztext.set(props.ztext)
      zfrom.set(props.lower)
      zupto.set(props.upper)
      vdict.put(props.dname, props.d_dub)

      entry.set(props.entry)
      ctrl.set({ actived: true })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let on_destroy = () => {}
  onDestroy(on_destroy)

  let hvmtl = ''
  let error = ''

  let hanzi_elem: HTMLElement
  let match_elem: HTMLElement

  $: lower = $zfrom
  $: upper = $zupto
  $: prefill_match($ztext, lower, upper)

  async function prefill_match(ztext: String, lower: number, upper: number) {
    if (!$ctrl.actived) return

    const input = ztext.substring(lower, upper)
    if (!input) return

    const res = await fetch('/api/qtran', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input, dname: $vdict.dname, mode: 'tlspec' }),
    })

    const [convert, hanviet] = (await res.text()).split('\n')
    if (!$entry.match || $entry.match == $entry.cvmtl) $entry.match = convert

    $entry.cvmtl = convert
    hvmtl = hanviet

    setTimeout(() => {
      hanzi_elem.querySelector('.active').scrollIntoView()
      match_elem.focus()
    }, 10)
  }

  async function handle_submit() {
    let url = 'tlspecs'
    if ($entry._ukey) url += '/' + $entry._ukey

    const params = { ztext: $ztext, lower, upper, ...$vdict, ...$entry }
    const [err, data] = await api_call(fetch, url, params, 'POST')
    if (err) error = data
    else {
      ctrl.hide()
      on_destroy()
    }
  }

  async function delete_tlspec() {
    const url = 'tlspecs/' + $entry._ukey
    const [err, data] = await api_call(fetch, url, null, 'DELETE')
    if (err) error = data
    else {
      ctrl.hide()
      on_destroy()
    }
  }

  function init_match() {
    $entry.match = $entry.cvmtl
    match_elem.focus()
  }

  function change_focus(index: number, _prev = lower) {
    if (index < upper) lower = index
    if (index >= _prev) upper = index + 1
  }

  function shift_lower(value = 0) {
    value += lower
    if (value < 0 || value >= $ztext.length) return

    lower = value
    if (upper <= value) upper = value + 1
  }

  function shift_upper(value = 0) {
    value += upper
    if (value < 1 || value > $ztext.length) return

    upper = value
    if (lower >= value) lower = value - 1
  }

  function copy_ztext() {
    const input = $ztext.substring(lower, upper)
    navigator.clipboard.writeText(input)
  }
</script>

<Dialog
  actived={$ctrl.actived}
  --z-idx={80}
  class="tlspec"
  on_close={ctrl.hide}>
  <tlspec-title slot="header">
    <title-lbl><SIcon name="flag" /></title-lbl>
    <title-dic>{$vdict.d_dub} [{$vdict.dname}]</title-dic>
  </tlspec-title>

  <tlspec-body>
    <form-label>
      <span>Khoanh phạm vi lỗi dịch</span>

      <btn-group>
        <button
          data-kbd="←"
          disabled={lower == 0}
          on:click={() => shift_lower(-1)}>
          <SIcon name="arrow-left" />
        </button>

        <button
          data-kbd="⇧←"
          disabled={lower == $ztext.length - 1}
          on:click={() => shift_lower(1)}>
          <SIcon name="arrow-bar-to-right" />
        </button>

        <span>({upper - lower})</span>

        <button
          data-kbd="⇧→"
          disabled={lower == 1}
          on:click={() => shift_upper(-1)}>
          <SIcon name="arrow-bar-to-left" />
        </button>

        <button
          data-kbd="→"
          disabled={lower == $ztext.length}
          on:click={() => shift_upper(1)}>
          <SIcon name="arrow-right" />
        </button>

        <button data-kbd="c" on:click={copy_ztext}>
          <SIcon name="copy" />
        </button>
      </btn-group>
    </form-label>

    <tlspec-input>
      <tlspec-hanzi bind:this={hanzi_elem}>
        {#each Array.from($ztext) as char, index}
          <x-z
            class:active={index >= lower && index < upper}
            on:click={() => change_focus(index)}>{char}</x-z>
        {/each}
      </tlspec-hanzi>

      <tlspec-cvmtl>{hvmtl}</tlspec-cvmtl>
      <tlspec-cvmtl>{$entry.cvmtl}</tlspec-cvmtl>
    </tlspec-input>

    <form
      action="/api/tlspecs"
      method="POST"
      class="tlspec-form"
      on:submit|preventDefault={handle_submit}>
      <form-group>
        <form-label>
          <span>Kết quả dịch chính xác</span>
          <span class="hint" on:click={init_match}>Chép từ dịch máy</span>
        </form-label>
        <textarea
          class="m-input _match"
          name="match"
          bind:value={$entry.match}
          bind:this={match_elem} />
      </form-group>

      <form-group>
        <form-label>Giải thích thêm nếu cần</form-label>
        <textarea
          class="m-input _extra"
          name="extra"
          bind:value={$entry.extra} />
      </form-group>

      {#if error}
        <form-error>{error}</form-error>
      {/if}

      <form-action>
        {#if $entry._ukey}
          <button
            class="m-btn _harmful"
            data-kbd="delete"
            on:click={delete_tlspec}>
            <SIcon name="trash" />
            <span>Xoá bỏ</span>
          </button>
        {/if}

        <button
          type="submit"
          class="m-btn _primary _fill"
          data-kbd="⇧↵"
          disabled={!$entry.match}>
          <SIcon name="device-floppy" />
          <span>{$entry._ukey ? 'Lưu lại' : 'Báo lỗi'}</span>
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
    @include bgcolor(secd);
  }

  form-group {
    display: block;
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
    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(sm);
  }

  .hint {
    cursor: pointer;
    margin-left: auto;
    font-weight: 400;
    font-style: italic;
    @include fgcolor(tert);
  }

  form-action {
    @include flex($gap: 0.75rem);
    justify-content: right;
    margin: 0.75rem 0;
  }

  btn-group {
    display: flex;
    margin-left: auto;

    * + * {
      margin-left: 0.25rem;
    }

    // prettier-ignore
    button {
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
