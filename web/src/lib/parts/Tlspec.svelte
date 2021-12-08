<script context="module">
  import { onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { call_api } from '$api/_api_call'
  import { create_input } from '$utils/create_stores'

  const input = create_input()

  const entry = writable({
    _ukey: '',
    dname: 'combine',
    d_dub: 'Tổng hợp',
    cvmtl: '',
    match: '',
    extra: '',
  })

  export const ctrl = {
    ...writable({ actived: false }),
    deactivate: () => ctrl.set({ actived: false }),
    activate: (_input, _entry) => {
      input.put(_input)
      entry.update((x) => ({ ...x, ..._entry }))
      ctrl.set({ actived: true })
    },
    load: async (ukey) => {
      const res = await fetch(`/api/tlspecs/${ukey}`)
      const data = await res.json()

      input.put(data.input)
      entry.set(data.entry)

      ctrl.set({ actived: true })
    },
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  export let on_destroy = () => {}
  onDestroy(on_destroy)

  $: prefill_match($input)

  let error

  function change_focus(index) {
    if (index < $input.lower) {
      $input.lower = index
    } else if (index + 1 > $input.upper) {
      $input.upper = index + 1
    } else {
      $input.lower = index
      $input.upper = index + 1
    }
  }

  async function prefill_match({ ztext, lower, upper }) {
    if (!ztext || lower >= upper) return
    const input = ztext.substring(lower, upper)
    navigator.clipboard.writeText(input)

    const { dname, d_dub } = $entry
    const res = await fetch('/api/qtran', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input, dname, d_dub, plain: true }),
    })

    $entry.cvmtl = $entry.match = await res.text()
  }

  async function handle_submit() {
    const params = { ...$input, ...$entry }
    const [err, data] = await call_api(fetch, 'tlspecs', params, 'POST')
    if (err) error = data
    else ctrl.deactivate()
  }

  function focus(node) {
    node.focus()
  }
</script>

<Gmodal actived={$ctrl.actived} _z_idx={80} on_close={ctrl.deactivate}>
  <tlspec-wrap>
    <tlspec-head>
      <tlspec-title>
        <title-lbl>Báo lỗi dịch:</title-lbl>
        <title-dub>{$entry.d_dub}</title-dub>
      </tlspec-title>
      <button type="button" class="close-btn" on:click={ctrl.deactivate}>
        <SIcon name="x" />
      </button>
    </tlspec-head>

    <tlspec-body>
      <form-label>Khoanh phạm vi lỗi dịch</form-label>

      <tlspec-input>
        <tlspec-hanzi>
          {#each Array.from($input.ztext) as char, index}
            <x-z
              class:active={index >= $input.lower && index < $input.upper}
              on:click={() => change_focus(index)}>{char}</x-z>
          {/each}
        </tlspec-hanzi>

        <tlspec-cvmtl>
          {$entry.cvmtl}
        </tlspec-cvmtl>
      </tlspec-input>

      <div hidden>
        <button
          data-kbd="h"
          disabled={$input.lower == 0}
          on:click={() => input.move_lower(-1)} />

        <button
          data-kbd="j"
          disabled={$input.lower + 1 == $input.ztext.length}
          on:click={() => input.move_lower(1)} />

        <button
          data-kbd="k"
          disabled={$input.upper == 1}
          on:click={() => input.move_upper(-1)} />

        <button
          data-kbd="l"
          disabled={$input.upper == $input.ztext.length}
          on:click={() => input.move_upper(1)} />
      </div>

      <form
        action="/api/tlspecs"
        method="POST"
        class="tlspec-form"
        on:submit|preventDefault={handle_submit}>
        <form-group>
          <form-label>Kết quả dịch chính xác</form-label>
          <textarea
            class="m-input _match"
            name="match"
            bind:value={$entry.match}
            use:focus />
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
          <button
            type="submit"
            class="m-btn _primary _lg _fill"
            data-kbd="⇧↵"
            disabled={!$entry.match}>
            <SIcon name="send" />
            <span>Báo lỗi</span>
          </button>
        </form-action>
      </form>
    </tlspec-body>
  </tlspec-wrap>
</Gmodal>

<style lang="scss">
  tlspec-wrap {
    display: block;
    width: 28rem;
    max-width: 100%;
    padding-bottom: 0.25rem;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  $head-height: 2.25rem;

  tlspec-head {
    @include flex($gap: 0.25rem, $center: vert);
    padding-left: 0.75rem;
    padding-right: 0.25rem;

    height: $head-height;
    // margin-bottom: 0.25rem;

    @include border(--bd-main, $loc: bottom);
    @include bdradi($loc: top);
    @include bgcolor(tert);

    :global(svg) {
      width: 1rem;
      height: 1rem;
      margin-top: -0.125rem;
    }
  }

  tlspec-title {
    flex: 1;
    display: flex;
    overflow: hidden;
    line-height: $head-height;
  }

  title-lbl {
    font-weight: 500;
    padding-right: 0.25rem;
  }

  title-dub {
    flex: 1;
    @include fgcolor(tert);
    @include clamp($width: null);

    &:before {
      content: '[';
    }
    &:after {
      content: ']';
    }
  }

  .close-btn {
    padding: 0.25rem;
    @include fgcolor(tert);
    @include bgcolor(tert);

    > :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }

    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  tlspec-body {
    display: block;
    padding: 0 0.75rem;
    // @include scroll();
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
    @include fgcolor(mute);
    @include bgcolor(tert);
    @include border();
    @include bdradi();

    > * {
      padding: 0.25rem 0.5rem;
    }
  }

  tlspec-hanzi {
    $height: 1.25rem;
    display: block;
    line-height: $height;
    max-height: $height * 4 + 0.75rem;
    overflow-y: auto;
    @include ftsize(lg);
  }

  tlspec-cvmtl {
    display: block;
    @include ftsize(sm);
    // @include fgcolor(tert);
    @include border($loc: top);
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
    @include scroll();

    &._match {
      height: 3.25rem;
    }

    &._extra {
      height: 2rem;
    }
  }

  form-label {
    display: block;
    width: 100%;
    font-weight: 500;
    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(sm);
  }

  form-action {
    @include flex($gap: 0.75rem);
    justify-content: right;
    margin: 0.75rem 0 0.5rem;
  }
</style>
