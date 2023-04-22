<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let name = 'mdform'
  export let value = ''

  export let placeholder = ''
  export let disabled = false
  export let min_rows = 2

  let input: HTMLTextAreaElement

  let old_value = ''

  function apply(type: string) {
    const { selectionStart: start, selectionEnd: end } = input

    switch (type) {
      case 'bold':
        return insert_text([start, end], '**')

      case 'italic':
        return insert_text([start, end], '_')

      case 'code':
        return insert_text([start, end], '`')

      case 'link':
        return insert_text([start, end], '[', '](url)')

      case 'heading':
        return insert_text(extend_range(start, end), '# ', '')

      case 'blockquote':
        return insert_text(extend_range(start, end), '> ', '')

      case 'list':
        return insert_text(extend_range(start, end), '- ', '')

      case 'list-numbers':
        return insert_text(extend_range(start, end), '+ ', '')

      default:
        return
    }
  }

  function insert_text(
    [start, end]: [number, number],
    prefix: string,
    suffix = prefix
  ) {
    const text = input.value.substring(start, end)
    const data = text.split(/\r?\n|\r/).map((x) => prefix + x + suffix)

    input.focus()
    old_value = value

    input.setSelectionRange(start, end)
    input.setRangeText(data.join('\n'))

    const offset = prefix.length
    if (!text) {
      input.setSelectionRange(start + offset, end + offset * data.length)
    } else {
      const after = end + offset * data.length + suffix.length * data.length
      input.setSelectionRange(after, after)
    }
  }

  function extend_range(start: number, end: number): [number, number] {
    const chars = Array.from(value.replace(/\r\n?/g, '\n'))
    while (start > 0 && chars[start - 1] != '\n') start -= 1
    while (end < chars.length && chars[end] != '\n') end += 1
    return [start, end]
  }

  function handle_key(evt: KeyboardEvent) {
    if (!evt.ctrlKey) return

    switch (evt.key) {
      case 'z':
        if (old_value) {
          evt.preventDefault()
          input.value = old_value
        }
    }
  }

  const menu = [
    ['bold', '*', 'In đậm'],
    ['italic', '_', 'In nghiêng'],
    ['blockquote', '>', 'Trích dẫn'],
    ['code', '`', 'Đoạn code'],
    ['link', '[', 'Liên kết'],
    ['list', '-', 'Danh sách'],
    ['list-numbers', '+', 'Danh sách đánh số'],
  ]

  let mode = 'edit'
  let html = ''

  const change_mode = async () => {
    if (mode == 'edit') {
      const init = { method: 'POST', body: value }
      const res = await fetch('/_sp/mdpost', init)
      if (!res.ok) return

      html = await res.text()
      mode = 'html'
    } else {
      mode = 'edit'
    }
  }

  $: [mode_icon, mode_btip] =
    mode == 'edit' ? ['eye', 'Xem trước'] : ['edit', 'Soạn thảo']
</script>

<svelte:window on:keydown={handle_key} />

<div class="md-form" class:active={mode == 'html'}>
  <section class="input">
    <header class="md-head">
      <div class="md-menu">
        {#each menu as [name, kbd, tip]}
          <button
            type="button"
            class="md-btn"
            on:click={() => apply(name)}
            data-kbd={kbd}
            data-tip={tip}><SIcon {name} /></button>
        {/each}
      </div>

      <div class="md-menu _right">
        <button
          type="button"
          class="md-btn"
          data-tip={mode_btip}
          disabled={!value}
          on:click={change_mode}>
          <SIcon name={mode_icon} />
        </button>
      </div>
    </header>

    {#if mode == 'edit' || !html}
      <textarea
        {name}
        {placeholder}
        {disabled}
        lang="vi"
        bind:value
        rows={min_rows}
        bind:this={input} />
    {:else}
      <div class="preview">
        {@html html}
      </div>
    {/if}
  </section>

  <section class="md-foot">
    <slot name="footer" />
  </section>
</div>

<style lang="scss">
  .md-form {
    &.active,
    &:focus-within {
      .md-head {
        display: flex;
      }

      .md-foot {
        display: initial;
      }

      textarea {
        min-height: 7rem;
      }
    }
  }

  .input {
    @include fgcolor(main);
    @include bgcolor(main);

    @include bdradi();
    @include border($width: 1px);

    &:focus-within {
      @include bgcolor(secd);
      border-color: color(primary, 5);
      box-shadow: 0 0 0 2px color(primary, 5, 5);
    }
  }

  .md-head,
  .md-foot {
    display: none;
  }

  .md-head {
    height: 2rem;
    padding: 0 0.5rem;
    @include bdradi($loc: top);
    @include border($loc: bottom);
    // @include bgcolor(tert);
  }

  .md-menu {
    display: inline-flex;

    &._right {
      margin-left: auto;
    }
  }

  .md-btn {
    background: none;
    height: 2rem;
    width: 1.875rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;

    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 5);
      @include bgcolor(secd);
    }
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 4rem;
    max-height: 80vh;
    border: 0;
    outline: 0;
    line-height: 1.5rem;
    background: transparent;
    padding: 0.375rem 0.75rem;
    // font-size: rem(17px);
    @include fgcolor(main);

    &::placeholder {
      font-style: italic;
      @include fgcolor(tert);
    }
  }

  .preview {
    padding: 0.75rem;
    line-height: 1.5rem;

    > :global(* + *) {
      margin-top: 1em;
    }
  }
</style>
