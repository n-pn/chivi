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
      const res = await fetch(`/_db/tlspecs/${ukey}`)
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
  import { gtran } from '$utils/qtran_utils'
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
  $: try {
    prefill_match($ztext, lower, upper)
  } catch (err) {
    console.log(err)
  }

  async function prefill_match(ztext: String, lower: number, upper: number) {
    if (!$ctrl.actived) return

    const input = ztext.substring(lower, upper)
    if (!input) return

    const body = { input, vd_id: $vdict.vd_id }
    const data = await api_call('/_m1/qtran/debug', body, 'PUT')

    const [convert, hanviet] = data.split('\n')
    if (!$entry.match || $entry.match == $entry.cvmtl) $entry.match = convert

    $entry.cvmtl = convert
    hvmtl = hanviet

    setTimeout(() => {
      hanzi_elem.querySelector('.active').scrollIntoView()
      match_elem.focus()
    }, 10)
  }

  async function handle_submit(evt: Event) {
    evt.preventDefault()

    const path = `/_mt/specs/${$entry._ukey}`
    const body = { ztext: $ztext, lower, upper, ...$vdict, ...$entry }

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
      await api_call(`/_mt/specs/${$entry._ukey}`, {}, 'DELETE', fetch)
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

  function appy_cvmtl() {
    $entry.match = $entry.cvmtl
    match_elem.focus()
  }

  async function apply_gtran() {
    $entry.match = await gtran($ztext.substring(lower, upper), 1)
    match_elem.focus()
  }
</script>

<Dialog
  actived={$ctrl.actived}
  --z-idx={80}
  class="tlspec"
  on_close={ctrl.hide}>
  <tlspec-title slot="header">
    <title-lbl><SIcon name="flag" /></title-lbl>
    <title-dic>{$vdict.vd_id} [{$vdict.label}]</title-dic>
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
          disabled={lower == $ztext.length - 1}
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
          disabled={lower == $ztext.length}
          on:click={() => shift_upper(1)}
          data-tip="Mở rộng sang phải">
          <SIcon name="arrow-right" />
        </button>

        <button
          data-kbd="c"
          on:click={copy_ztext}
          data-tip="Copy đoạn text vào clipboard">
          <SIcon name="clipboard" />
        </button>
      </btn-group>
    </form-label>

    <tlspec-input>
      <tlspec-hanzi bind:this={hanzi_elem}>
        {#each Array.from($ztext) as char, index}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <x-z
            class:active={index >= lower && index < upper}
            on:click={() => change_focus(index)}>{char}</x-z>
        {/each}
      </tlspec-hanzi>

      <tlspec-cvmtl>{hvmtl}</tlspec-cvmtl>
      <tlspec-cvmtl>{$entry.cvmtl}</tlspec-cvmtl>
    </tlspec-input>

    <form
      action="/_db/tlspecs"
      method="POST"
      class="form"
      on:submit={handle_submit}>
      <form-group>
        <form-label>
          <span>Kết quả dịch chính xác</span>
          <btn-group>
            <button
              type="button"
              on:click={() => ($entry.match = '')}
              data-tip="Xoá hết kết quả dịch">
              <SIcon name="eraser" />
            </button>
            <button
              type="button"
              on:click={apply_gtran}
              data-tip="Lấy kết quả từ Google Translate">
              <SIcon name="language" />
            </button>
            <!-- svelte-ignore security-anchor-rel-noreferrer -->
            <a
              href="/sp/qtran?wn_id={$vdict.vd_id}&input={$ztext}"
              target="_blank"
              data-tip="Mở bằng trang dịch nhanh">
              <SIcon name="external-link" />
            </a>
            <button
              type="button"
              on:click={appy_cvmtl}
              data-tip="Copy từ kết quả dịch máy">
              <SIcon name="copy" />
            </button>
          </btn-group>
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
            type="button"
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
          {#if $entry._ukey}
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
